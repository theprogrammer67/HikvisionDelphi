unit uVideoPanel;

interface

uses uVideoWindow, Vcl.Controls, System.Generics.Collections, Winapi.Windows,
  System.SysUtils, Vcl.Graphics, Winapi.Messages, System.Classes,
  uHikvisionErrors;

type
  TPanelMode = (pmSingle, pm22, mt33, pm44);

  TVideoPanel = class(TSelfParentControl)
  public const
    WIN_COUNT: Byte = 16;
  private const
    DEF_COLOR = TVideoWindow.STATUS_FONTCOLOR;
    DEF_FONTNAME = 'Courier New';
    DEF_FONTSIZE = 24;
    DEF_FONTCOLOR = clLime;
  private
    class var FObject: TVideoPanel;
  private
    FUserID: Integer;
    FPanelMode: TPanelMode;
    FParentWndHook: HHOOK;
    FVideoWindows: TObjectList<TVideoWindow>;
    FOnLoseParentWindow: TNotifyEvent;
  private
    procedure SetPanelMode(const Value: TPanelMode);
    procedure InstallHookParent;
    procedure UninstallHookParent;
    procedure RecalcVideoWindows;
    procedure AdjustWindowSize;
    procedure DoLoseParentWindow;
    procedure SetUserID(const Value: Integer);
    procedure SelectWindow(AHWnd: HWND);
  protected
    procedure WMLButtonDown(var Message: TWMLButtonDown);
      message WM_LBUTTONDOWN;
    procedure WMLChangeSelected(var Message: TMessage);
      message WM_CHANGESELECTED;
    procedure Paint; override;
    procedure Resize; override;
  public
    constructor Create(AParent: HWND); overload; override;
    constructor Create(AParent: HWND; APanelMode: TPanelMode); overload;
    destructor Destroy; override;
  public
    procedure EnableAll(AEnabled: Boolean);
    procedure PlayAll(APlay: Boolean);
    procedure ShowOverlayTextAll(AShow: Boolean);
  public
    property PanelMode: TPanelMode read FPanelMode write SetPanelMode;
    property OnLoseParentWindow: TNotifyEvent read FOnLoseParentWindow
      write FOnLoseParentWindow;
    property VideoWindows: TObjectList<TVideoWindow> read FVideoWindows;
    property UserID: Integer read FUserID write SetUserID;
  end;

implementation

uses System.Types;

resourcestring
  RsErrSingletoneOnly = 'Only one TVideoPanel object is allowed';

function CallWndRetProc(nCode: Integer; wParam: wParam; lParam: lParam)
  : LRESULT; stdcall;
var
  LMessage: UINT;
  LHwnd: HWND;
begin
  Result := CallNextHookEx(TVideoPanel.FObject.FParentWndHook, nCode,
    wParam, lParam);
  if (nCode < 0) then
    Exit;

  if nCode = HC_ACTION then
  begin
    if not Assigned(TVideoPanel.FObject) then
      Exit;
    LHwnd := tagCWPRETSTRUCT(pointer(lParam)^).HWND;
    if LHwnd <> TVideoPanel.FObject.ParentWindow then
      Exit;

    LMessage := tagCWPRETSTRUCT(pointer(lParam)^).Message;
    case LMessage of
      WM_SIZE:
        SendMessage(TVideoPanel.FObject.Handle, WM_SIZE, 0, 0);
      WM_DESTROY:
        TVideoPanel.FObject.DoLoseParentWindow;
    end;
  end;
end;

{ TVideoPanel }

procedure TVideoPanel.AdjustWindowSize;
var
  R: TRect;
  LNewWidth, LNewHeight: Integer;
begin
  if (not Visible) or (ParentWindow = 0) then
    Exit;

  if not IsWindow(ParentWindow) then
  begin // Потеряли родительское окно, криминал!
    DoLoseParentWindow;
    Exit;
  end;

  if not GetWindowRect(ParentWindow, R) then
    Exit;

  LNewWidth := R.Right - R.Left;
  LNewHeight := R.Bottom - R.Top;
  if (Width = LNewWidth) and (Height = LNewHeight) then
    Exit;

  MoveWindow(Self.Handle, 0, 0, LNewWidth, LNewHeight, True);
end;

constructor TVideoPanel.Create(AParent: HWND);
var
  I: Byte;
  LVideoWindow: TVideoWindow;
begin
  inherited Create(AParent);

  if Assigned(FObject) then
    raise Exception.Create(RsErrSingletoneOnly);
  FObject := Self;

  DoubleBuffered := True;

  Color := DEF_COLOR;
  Font.Name := DEF_FONTNAME;
  Font.Size := DEF_FONTSIZE;
  Font.Color := DEF_FONTCOLOR;
  Align := alClient;

  FVideoWindows := TObjectList<TVideoWindow>.Create;
  for I := 0 to WIN_COUNT - 1 do
  begin
    LVideoWindow := TVideoWindow.Create(Self);
    FVideoWindows.Add(LVideoWindow);
    LVideoWindow.Channel := I + 1;
  end;

  UserID := -1;
  // Winapi.Windows.ShowWindow(Self.Handle, SW_MAXIMIZE);

  InstallHookParent;
end;

constructor TVideoPanel.Create(AParent: HWND; APanelMode: TPanelMode);
begin
  Create(AParent);
  FPanelMode := APanelMode;
end;

destructor TVideoPanel.Destroy;
begin
  UninstallHookParent;
  FreeAndNil(FVideoWindows);
  FObject := nil;
  inherited;
end;

procedure TVideoPanel.DoLoseParentWindow;
begin
  if Assigned(OnLoseParentWindow) then
    OnLoseParentWindow(Self);
end;

procedure TVideoPanel.EnableAll(AEnabled: Boolean);
var
  LVideoWindow: TVideoWindow;
begin
  for LVideoWindow in VideoWindows do
    LVideoWindow.Enabled := True;
  Invalidate;
end;

procedure TVideoPanel.InstallHookParent;
begin
  if ParentWindow <> 0 then
    FParentWndHook := SetWindowsHookEx(WH_CALLWNDPROCRET, @CallWndRetProc, 0,
      GetCurrentThreadID)
  else
    FParentWndHook := 0;
end;

procedure TVideoPanel.Paint;
var
  I: Integer;
  LRect: TRect;
begin
  inherited;

  Canvas.Pen.Color := clWhite;
  for I := 0 to FVideoWindows.Count - 1 do
  begin
    if not FVideoWindows[I].Selected then
      Continue;

    LRect := FVideoWindows[I].BoundsRect;
    InflateRect(LRect, 1, 1);
    Canvas.Rectangle(LRect);
  end;
end;

procedure TVideoPanel.PlayAll(APlay: Boolean);
var
  LVideoWindow: TVideoWindow;
begin
  for LVideoWindow in VideoWindows do
    if APlay then
    begin
      if LVideoWindow.Enabled then
        PostMessage(LVideoWindow.Handle, WM_PLAYVIDEO, 0, 0);
    end
    else
      SendMessage(LVideoWindow.Handle, WM_STOPVIDEO, 0, 0);
  Invalidate;
end;

procedure TVideoPanel.RecalcVideoWindows;
const
  MARGIN: Integer = 2;
var
  FVideoWindow: TVideoWindow;
  LRatio: Byte;
  LCount, LHeight, LWidth, I, XNum, YNum: Integer;
begin
  if not Assigned(FVideoWindows) then
    Exit;

  Visible := False;
  try
    LRatio := Ord(FPanelMode) + 1;
    LWidth := (Width - MARGIN) div LRatio;
    LHeight := (Height - MARGIN) div LRatio;
    LCount := LRatio * LRatio;

    for I := 0 to FVideoWindows.Count - 1 do
    begin
      FVideoWindow := FVideoWindows[I];
      FVideoWindow.Visible := I < LCount;
      if not FVideoWindow.Visible then
        Continue;

      FVideoWindow.Height := LHeight - MARGIN;
      FVideoWindow.Width := LWidth - MARGIN;

      XNum := ((I + LRatio) mod LRatio);
      YNum := I div LRatio;

      FVideoWindow.Left := XNum * LWidth + MARGIN;
      FVideoWindow.Top := YNum * LHeight + MARGIN;
    end;
  finally
    Visible := True;
  end;
end;

procedure TVideoPanel.Resize;
begin
  AdjustWindowSize;
  RecalcVideoWindows;
  inherited;
end;

procedure TVideoPanel.SelectWindow(AHWnd: HWND);
var
  I: Integer;
begin
  for I := 0 to FVideoWindows.Count - 1 do
  begin
    if FVideoWindows[I].Handle = AHWnd then
      FVideoWindows[I].Selected := True
    else
      FVideoWindows[I].Selected := False;
  end;
  Invalidate;
end;

procedure TVideoPanel.SetPanelMode(const Value: TPanelMode);
begin
  FPanelMode := Value;
  RecalcVideoWindows;
end;

procedure TVideoPanel.SetUserID(const Value: Integer);
var
  LVideoWindow: TVideoWindow;
begin
  FUserID := Value;
  if not Assigned(VideoWindows) then
    Exit;

  for LVideoWindow in VideoWindows do
    LVideoWindow.UserID := FUserID;
end;

procedure TVideoPanel.ShowOverlayTextAll(AShow: Boolean);
var
  LVideoWindow: TVideoWindow;
begin
  for LVideoWindow in VideoWindows do
    LVideoWindow.ShowOverlayText := AShow;
  Invalidate;
end;

procedure TVideoPanel.UninstallHookParent;
begin
  if FParentWndHook <> 0 then
    UnhookWindowsHookEx(FParentWndHook);
  FParentWndHook := 0;
end;

procedure TVideoPanel.WMLButtonDown(var Message: TWMLButtonDown);
var
  LHwnd: HWND;
begin
  LHwnd := ChildWindowFromPoint(Self.Handle, Point(Message.XPos, Message.YPos));
  if LHwnd <> 0 then
    SelectWindow(LHwnd);
end;

procedure TVideoPanel.WMLChangeSelected(var Message: TMessage);
begin
  SelectWindow(Message.wParam);
end;

end.
