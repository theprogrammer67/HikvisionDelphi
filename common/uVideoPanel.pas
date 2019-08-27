unit uVideoPanel;

interface

uses uVideoWindow, Vcl.Controls, System.Generics.Collections, Winapi.Windows,
  System.SysUtils, Vcl.Graphics, Winapi.Messages, System.Classes;

type
  TPanelMode = (pmSingle, pm22, mt33, pm44);

  TVideoPanel = class(TCustomControl)
  private const
    FWindowsCount: Byte = 16;
  private
    class var FObject: TVideoPanel;
  private
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
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
  public
    constructor Create(AParent: HWND); reintroduce;
    destructor Destroy; override;
  public
    procedure DoLoseParentWindow;
  public
    property OnResize;
    property PanelMode: TPanelMode read FPanelMode write SetPanelMode;
    property OnLoseParentWindow: TNotifyEvent read FOnLoseParentWindow
      write FOnLoseParentWindow;
    property VideoWindows: TObjectList<TVideoWindow> read FVideoWindows;
  end;

implementation

resourcestring
  RsErrSingletoneOnly =
    'Допустимо использование только одного объекта TVideoPanel';

function CallWndRetProc(nCode: integer; wParam: wParam; lParam: lParam)
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
    LHwnd := tagCWPRETSTRUCT(pointer(lParam)^).HWND;
    if LHwnd <> TVideoPanel.FObject.ParentWindow then
      Exit;

    LMessage := tagCWPRETSTRUCT(pointer(lParam)^).Message;
    case LMessage of
      WM_SIZE:
        TVideoPanel.FObject.AdjustWindowSize;
      WM_DESTROY:
        TVideoPanel.FObject.DoLoseParentWindow;
    end;
  end;
end;

{ TVideoPanel }

procedure TVideoPanel.AdjustWindowSize;
var
  R: TRect;
  LNewWidth, LNewHeight: integer;
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
begin
  inherited CreateParented(AParent);

  if Assigned(FObject) then
    raise Exception.Create(RsErrSingletoneOnly);
  FObject := Self;

  DoubleBuffered := True;

  FVideoWindows := TObjectList<TVideoWindow>.Create;
  for I := 0 to FWindowsCount - 1 do
    FVideoWindows.Add(TVideoWindow.Create(Self));

  Align := alClient;
  Color := clSilver;
  Winapi.Windows.ShowWindow(Self.Handle, SW_MAXIMIZE);

  InstallHookParent;
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

procedure TVideoPanel.InstallHookParent;
begin
  if ParentWindow <> 0 then
    FParentWndHook := SetWindowsHookEx(WH_CALLWNDPROCRET, @CallWndRetProc, 0,
      GetCurrentThreadID)
  else
    FParentWndHook := 0;
end;

procedure TVideoPanel.RecalcVideoWindows;
var
  FVideoWindow: TVideoWindow;
  LRatio: Byte;
  LCount, LHeight, LWidth, I, XNum, YNum: integer;
begin
  Visible := False;
  try
    LRatio := Ord(FPanelMode) + 1;
    LWidth := Width div LRatio;
    LHeight := Height div LRatio;
    LCount := LRatio * LRatio;

    for I := 0 to FVideoWindows.Count - 1 do
    begin
      FVideoWindow := FVideoWindows[I];
      FVideoWindow.Visible := I < LCount;
      if not FVideoWindow.Visible then
        Continue;

      FVideoWindow.Height := LHeight - 1;
      FVideoWindow.Width := LWidth - 1;

      XNum := ((I + LRatio) mod LRatio);
      YNum := I div LRatio;

      FVideoWindow.Left := XNum * LWidth;
      FVideoWindow.Top := YNum * LHeight;
    end;
  finally
    Visible := True;
  end;
end;

procedure TVideoPanel.SetPanelMode(const Value: TPanelMode);
begin
  FPanelMode := Value;
  RecalcVideoWindows;
end;

procedure TVideoPanel.UninstallHookParent;
begin
  if FParentWndHook <> 0 then
    UnhookWindowsHookEx(FParentWndHook);
  FParentWndHook := 0;
end;

procedure TVideoPanel.WMSize(var Message: TWMSize);
begin
  inherited;
  RecalcVideoWindows;
end;

end.
