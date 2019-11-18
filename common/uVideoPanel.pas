unit uVideoPanel;

interface

uses uVideoWindow, Vcl.Controls, System.Generics.Collections, Winapi.Windows,
  System.SysUtils, Vcl.Graphics, Winapi.Messages, System.Classes, System.Math,
  uHikvisionErrors;

type
  TPanelMode = (pmSingle, pm22, mt33, pm44);

  TWindowNotifyEvent = procedure(AIndex: Integer) of object;

  TVideoPanel = class(TSelfParentControl)
  public
    class var Obj: TVideoPanel;
  public
  class var
    DefFontSize: Integer;
    DefFontName: string;
    DefFontColor: TColor;
  public const
    WIN_COUNT: Byte = 16;
  private const
    DEF_COLOR = TVideoWindow.STATUS_FONTCOLOR;
    DEF_FONTNAME = 'Courier New';
    DEF_FONTSIZE = 12;
    DEF_FONTCOLOR = clBlack;
  private
    FUserID: Integer;
    FPanelMode: TPanelMode;
    FParentWndHook: HHOOK;
    FVideoWindows: TObjectList<TVideoWindow>;
    FOnLoseParentWindow: TNotifyEvent;
    FOnSelectWindow: TWindowNotifyEvent;
    FOnCustomEvent: TWindowNotifyEvent;
    FMaximizedWindow: TVideoWindow;
  private
    function GetWindowIndex(AHWnd: HWND): Integer;
    procedure SetPanelMode(const Value: TPanelMode);
    procedure InstallHookParent;
    procedure UninstallHookParent;
    procedure RecalcVideoWindows;
    procedure AdjustWindowSize;
    procedure DoLoseParentWindow;
    procedure SetUserID(const Value: Integer);
    procedure SelectWindow(AHWnd: HWND);
    procedure MaximizeWindow(AHWnd: HWND);
    procedure SelectItem(AIndex: Integer);
    procedure MaximizeItem(AIndex: Integer);
    procedure DoSelectWindow(AIndex: Integer);
    procedure DoCustomEvent(AIndex: Integer);
    procedure PaintBorders;
    function GetItemIndex: Integer;
    procedure SetItemIndex(const Value: Integer);
    function GetSelectedWindow: TVideoWindow;
  protected
    procedure WMLButtonDown(var Message: TWMLButtonDown);
      message WM_LBUTTONDOWN;
    procedure WMChangeSelected(var Message: TMessage);
      message WM_CHANGESELECTED;
    procedure WMCustomEvent(var Message: TMessage); message WM_CUSTOMEVENT;
    procedure WMMaximizeWindow(var Message: TMessage); message WM_MAXIMIZEWND;
    procedure Paint; override;
    procedure Resize; override;
  public
    class constructor Create;
    constructor Create(AParent: HWND); overload; override;
    constructor Create(AParent: HWND; APanelMode: TPanelMode); overload;
    destructor Destroy; override;
  public
    class procedure CheckWindowIndex(AValue: Integer);
    procedure EnableAll(AEnabled: Boolean);
    procedure PlayAll(APlay: Boolean);
    procedure ShowOverlayTextAll(AShow: Boolean);
  public
    property PanelMode: TPanelMode read FPanelMode write SetPanelMode;
    property OnLoseParentWindow: TNotifyEvent read FOnLoseParentWindow
      write FOnLoseParentWindow;
    property VideoWindows: TObjectList<TVideoWindow> read FVideoWindows;
    property UserID: Integer read FUserID write SetUserID;
    property ItemIndex: Integer read GetItemIndex write SetItemIndex;
    property SelectedWindow: TVideoWindow read GetSelectedWindow;
    property OnSelectWindow: TWindowNotifyEvent read FOnSelectWindow
      write FOnSelectWindow;
    property OnCustomEvent: TWindowNotifyEvent read FOnCustomEvent
      write FOnCustomEvent;
  end;

implementation

uses System.Types;

resourcestring
  RsErrSingletoneOnly = 'Only one TVideoPanel object is allowed';
  RsErrWinIndexOutOfRange = 'Номер окна вне диапазона';

function CallWndRetProc(nCode: Integer; wParam: wParam; lParam: lParam)
  : LRESULT; stdcall;
var
  LMessage: UINT;
  LHwnd: HWND;
begin
  Result := CallNextHookEx(TVideoPanel.Obj.FParentWndHook, nCode,
    wParam, lParam);
  if (nCode < 0) then
    Exit;

  if nCode = HC_ACTION then
  begin
    if not Assigned(TVideoPanel.Obj) then
      Exit;
    LHwnd := tagCWPRETSTRUCT(pointer(lParam)^).HWND;
    if LHwnd <> TVideoPanel.Obj.ParentWindow then
      Exit;

    LMessage := tagCWPRETSTRUCT(pointer(lParam)^).Message;
    case LMessage of
      WM_SIZE:
        SendMessage(TVideoPanel.Obj.Handle, WM_SIZE, 0, 0);
      WM_DESTROY:
        TVideoPanel.Obj.DoLoseParentWindow;
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

  if Assigned(Obj) then
    raise Exception.Create(RsErrSingletoneOnly);
  Obj := Self;

  DoubleBuffered := True;

  Color := DEF_COLOR;
  Font.Name := DefFontName;
  Font.Size := DefFontSize;
  Font.Color := DefFontColor;
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

class procedure TVideoPanel.CheckWindowIndex(AValue: Integer);
begin
  if not(AValue in [0 .. TVideoPanel.WIN_COUNT - 1]) then
    raise Exception.Create(RsErrWinIndexOutOfRange);
end;

constructor TVideoPanel.Create(AParent: HWND; APanelMode: TPanelMode);
begin
  Create(AParent);
  FPanelMode := APanelMode;
end;

class constructor TVideoPanel.Create;
begin
  DefFontSize := DEF_FONTSIZE;
  DefFontName := DEF_FONTNAME;
  DefFontColor := DEF_FONTCOLOR;
end;

destructor TVideoPanel.Destroy;
begin
  UninstallHookParent;
  FreeAndNil(FVideoWindows);
  Obj := nil;
  inherited;
end;

procedure TVideoPanel.DoCustomEvent(AIndex: Integer);
begin
  if Assigned(FOnCustomEvent) then
    FOnCustomEvent(AIndex);
end;

procedure TVideoPanel.DoLoseParentWindow;
begin
  if Assigned(OnLoseParentWindow) then
    OnLoseParentWindow(Self);
end;

procedure TVideoPanel.DoSelectWindow(AIndex: Integer);
begin
  if Assigned(FOnSelectWindow) then
    FOnSelectWindow(AIndex);
end;

procedure TVideoPanel.EnableAll(AEnabled: Boolean);
var
  LVideoWindow: TVideoWindow;
begin
  for LVideoWindow in VideoWindows do
    LVideoWindow.Used := True;
  Invalidate;
end;

function TVideoPanel.GetWindowIndex(AHWnd: HWND): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to FVideoWindows.Count - 1 do
    if FVideoWindows[I].Handle = AHWnd then
      Exit(I);
end;

function TVideoPanel.GetItemIndex: Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to FVideoWindows.Count - 1 do
    if FVideoWindows[I].Selected then
      Exit(I);
end;

function TVideoPanel.GetSelectedWindow: TVideoWindow;
var
  LIndex: Integer;
begin
  LIndex := ItemIndex;
  if LIndex >= 0 then
    Result := FVideoWindows[LIndex]
  else
    Result := nil;
end;

procedure TVideoPanel.InstallHookParent;
begin
  if ParentWindow <> 0 then
    FParentWndHook := SetWindowsHookEx(WH_CALLWNDPROCRET, @CallWndRetProc, 0,
      GetCurrentThreadID)
  else
    FParentWndHook := 0;
end;

procedure TVideoPanel.MaximizeItem(AIndex: Integer);
begin
  if FPanelMode = pmSingle then
    Exit;

  if Assigned(FMaximizedWindow) then
    FMaximizedWindow := nil
  else
    FMaximizedWindow := VideoWindows[AIndex];
  RecalcVideoWindows;
end;

procedure TVideoPanel.MaximizeWindow(AHWnd: HWND);
var
  I: Integer;
begin
  I := GetWindowIndex(AHWnd);
  if I >= 0 then
    MaximizeItem(I);
end;

procedure TVideoPanel.Paint;
begin
  inherited;
  PaintBorders;
end;

procedure TVideoPanel.PaintBorders;
var
  I: Integer;
  LBorder: TRect;
begin
  for I := 0 to FVideoWindows.Count - 1 do
  begin
    if not FVideoWindows[I].Visible then
      Continue;

    if FVideoWindows[I].Selected then
      Canvas.Brush.Color := clWhite
    else
      Canvas.Brush.Color := Color;

    LBorder := FVideoWindows[I].BoundsRect;
    InflateRect(LBorder, 1, 1);
    Canvas.FrameRect(LBorder);
  end;
end;

procedure TVideoPanel.PlayAll(APlay: Boolean);
var
  LVideoWindow: TVideoWindow;
begin
  for LVideoWindow in VideoWindows do
    if APlay then
    begin
      if (LVideoWindow.Used) and (LVideoWindow.Visible) then
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
  LMaxMode: Boolean;
begin
  if not Assigned(FVideoWindows) then
    Exit;

  Visible := False;
  try
    LMaxMode := Assigned(FMaximizedWindow);

    LRatio := IfThen(LMaxMode, 1, Ord(FPanelMode) + 1);
    LWidth := (Width - MARGIN) div LRatio;
    LHeight := (Height - MARGIN) div LRatio;
    LCount := LRatio * LRatio;

    for I := 0 to FVideoWindows.Count - 1 do
    begin
      FVideoWindow := FVideoWindows[I];

      FVideoWindow.Visible := (FVideoWindow = FMaximizedWindow) or (I < LCount);
      if not FVideoWindow.Visible then
        Continue;

      FVideoWindow.Height := LHeight - MARGIN;
      FVideoWindow.Width := LWidth - MARGIN;

      XNum := IfThen(LMaxMode, 0, (I + LRatio) mod LRatio);
      YNum := IfThen(LMaxMode, 0, I div LRatio);

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

procedure TVideoPanel.SelectItem(AIndex: Integer);
var
  I: Integer;
  LSelectedIndex: Integer;
begin
  LSelectedIndex := -1;
  for I := 0 to FVideoWindows.Count - 1 do
  begin
    if I = AIndex then
    begin
      FVideoWindows[I].Selected := True;
      LSelectedIndex := I;
    end
    else
      FVideoWindows[I].Selected := False;
  end;
  PaintBorders;

  if LSelectedIndex >= 0 then
    DoSelectWindow(LSelectedIndex);
end;

procedure TVideoPanel.SelectWindow(AHWnd: HWND);
var
  I: Integer;
begin
  I := GetWindowIndex(AHWnd);
  if I >= 0 then
    SelectItem(I);
end;

procedure TVideoPanel.SetItemIndex(const Value: Integer);
begin
  SelectItem(Value);
end;

procedure TVideoPanel.SetPanelMode(const Value: TPanelMode);
begin
  if FPanelMode = Value then
    Exit;

  FPanelMode := Value;
  FMaximizedWindow := nil;
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
    LVideoWindow.TextPanel.Used := AShow;
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

procedure TVideoPanel.WMChangeSelected(var Message: TMessage);
begin
  SelectWindow(Message.wParam);
end;

procedure TVideoPanel.WMCustomEvent(var Message: TMessage);
var
  I: Integer;
begin
  I := GetWindowIndex(Message.wParam);
  if I >= 0 then
    DoCustomEvent(I);
end;

procedure TVideoPanel.WMMaximizeWindow(var Message: TMessage);
begin
  MaximizeWindow(Message.wParam);
end;

end.
