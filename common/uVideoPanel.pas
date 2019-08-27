﻿unit uVideoPanel;

interface

uses uVideoWindow, Vcl.Controls, System.Generics.Collections, Winapi.Windows,
  System.SysUtils, Vcl.Graphics, Winapi.Messages;

type
  TPanelMode = (pmSingle, mt22, mt33, mt44);

  TVideoPanel = class(TCustomControl)
  private const
    FWindowsCount: Byte = 16;
  private
    class var FObject: TVideoPanel;
  private
    FPanelMode: TPanelMode;
    FParentWndHook: HHOOK;
    FVideoWindows: TObjectList<TVideoWindow>;
  private
    procedure SetPanelMode(const Value: TPanelMode);
    procedure InstallHookParent;
    procedure UninstallHookParent;
    procedure AdjustWindowSize;
  public
    constructor Create(AParent: HWND); reintroduce;
    destructor Destroy; override;
  public
    procedure ShowPanel;
  public
    property PanelMode: TPanelMode read FPanelMode write SetPanelMode;
  end;

implementation

resourcestring
  RsErrSingletoneOnly =
    'Допустимо использование только одного объекта TVideoPanel';

function ParentHookProc(nCode: integer; wParam: wParam; lParam: lParam)
  : LRESULT; stdcall;
var
  LMessage: UINT;
    LHwnd: HWND;
begin
  Result := CallNextHookEx(TVideoPanel.FObject.FParentWndHook, nCode, wParam, lParam);
  if (nCode < 0) then
    Exit;

  if nCode = HC_ACTION then
  begin
    LHwnd := tagCWPRETSTRUCT(pointer(lParam)^).hwnd;
    if LHwnd <> TVideoPanel.FObject.ParentWindow then
      Exit;

    LMessage := tagCWPRETSTRUCT(pointer(lParam)^).message;
    case LMessage of
      WM_SIZE:
        TVideoPanel.FObject.AdjustWindowSize;
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
//    DoLoseParentWindow;
    Exit;
  end;

  if not GetWindowREct(ParentWindow, R) then
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

  FVideoWindows := TObjectList<TVideoWindow>.Create;
  for I := 0 to FWindowsCount - 1 do
    FVideoWindows.Add(TVideoWindow.Create(Self));

  Align := alClient;
  Color := clNavy;
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

procedure TVideoPanel.InstallHookParent;
begin
  if ParentWindow <> 0 then
    FParentWndHook := SetWindowsHookEx(WH_CALLWNDPROCRET, @ParentHookProc, 0,
      GetCurrentThreadID)
  else
    FParentWndHook := 0;
end;

procedure TVideoPanel.SetPanelMode(const Value: TPanelMode);
begin
  FPanelMode := Value;
end;

procedure TVideoPanel.ShowPanel;
begin
  Winapi.Windows.ShowWindow(Self.Handle, SW_MAXIMIZE);
  Self.Visible := True;
end;

procedure TVideoPanel.UninstallHookParent;
begin
  if FParentWndHook <> 0 then
    UnhookWindowsHookEx(FParentWndHook);
  FParentWndHook := 0;
end;

end.
