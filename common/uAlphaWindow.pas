﻿unit uAlphaWindow;

interface

uses Vcl.Controls, System.Classes, Winapi.Windows, Vcl.Graphics, System.Types,
  System.Math, System.Generics.Collections, Winapi.Messages, System.SysUtils;

type
  TAlphaWindow = class(TCustomControl)
  private
    FParentControl: TCustomControl;
    FAlpha: Byte;
    FText: string;
    FMargin: Integer;
    FWidthRelative: Integer;
    FHeightRelative: Integer;
  private
    class var FParentWndHook: HHOOK;
    class var FObjects: TThreadList<TAlphaWindow>;
    procedure RegisterObj;
    procedure UnRegisterObj;
  private
    class function CallWndRetProc(ACode: Integer; AwParam: WPARAM;
      AlParam: LPARAM): LRESULT; stdcall; static;
  private
    class procedure InstallHookParent;
    class procedure UninstallHookParent;
  private
    procedure ShowText;
    procedure WMMove(var Message: TWMMove); message WM_MOVE;
    procedure CMVisibleChanged(var Message: TMessage);
      message CM_VISIBLECHANGED;
  protected
    procedure Paint; override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWindowHandle(const Params: TCreateParams); override;
  public
    class constructor Create;
    class destructor Destroy;
  public
    constructor Create(AParent: TCustomControl; AAlpha: Byte); reintroduce;
    destructor Destroy; override;
  public
    procedure CalcSize;
  public
    property Text: string read FText write FText;
    property Margin: Integer read FMargin write FMargin;
    property WidthRelative: Integer read FWidthRelative write FWidthRelative;
    property HeightRelative: Integer read FHeightRelative write FHeightRelative;
    property Color;
    property Canvas;
  end;

implementation

{ TAlphaWindow }

class function TAlphaWindow.CallWndRetProc(ACode: Integer; AwParam: WPARAM;
  AlParam: LPARAM): LRESULT;
var
  LMessage: UINT;
  LHwnd: HWND;
  LObj: TAlphaWindow;
  I: Integer;
  LObjects: TList<TAlphaWindow>;
  LlParam: LPARAM;
  LwParam: WPARAM;
begin
  Result := CallNextHookEx(FParentWndHook, ACode, AwParam, AlParam);
  if (ACode < 0) then
    Exit;

  if ACode = HC_ACTION then
  begin
    LHwnd := tagCWPRETSTRUCT(Pointer(AlParam)^).HWND;
    LMessage := tagCWPRETSTRUCT(Pointer(AlParam)^).Message;
    LlParam := tagCWPRETSTRUCT(Pointer(AlParam)^).LPARAM;
    LwParam := tagCWPRETSTRUCT(Pointer(AlParam)^).WPARAM;

    LObjects := FObjects.LockList;
    try
      for I := 0 to LObjects.Count - 1 do
      begin
        LObj := LObjects[I];
        if LObj.FParentControl.Handle = LHwnd then
        begin
          case LMessage of
            WM_SIZE, WM_MOVE, WM_SHOWWINDOW, CM_VISIBLECHANGED:
              SendMessage(LObj.Handle, LMessage, LwParam, LlParam);
          end;
        end;
      end;
    finally
      FObjects.UnlockList;
    end;
  end;
end;

procedure TAlphaWindow.CMVisibleChanged(var Message: TMessage);
begin
  inherited;
  if Visible then
    Winapi.Windows.ShowWindow(Handle, SW_SHOWNORMAL)
  else
    Winapi.Windows.ShowWindow(Handle, SW_HIDE);
end;

constructor TAlphaWindow.Create(AParent: TCustomControl; AAlpha: Byte);
begin
  inherited CreateParented(AParent.Handle);

  FParentControl := AParent;
  FAlpha := AAlpha;
  Canvas.Brush.Color := clWhite;
  Canvas.Brush.style := bsClear;
  Canvas.Font.Color := clBlack;
  FMargin := 1;
  FWidthRelative := 50;
  FHeightRelative := 50;
  Color := clWhite;

  RegisterObj;
end;

class constructor TAlphaWindow.Create;
begin
  FObjects := TThreadList<TAlphaWindow>.Create;
  FParentWndHook := 0;
  InstallHookParent;
end;

procedure TAlphaWindow.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.style := WS_POPUP or WS_VISIBLE;
  Params.ExStyle := WS_EX_LAYERED or WS_EX_TOOLWINDOW;
end;

procedure TAlphaWindow.CreateWindowHandle(const Params: TCreateParams);
begin
  inherited;
  Winapi.Windows.SetLayeredWindowAttributes(Handle, 0, FAlpha, LWA_ALPHA);
end;

destructor TAlphaWindow.Destroy;
begin
  UnRegisterObj;
  inherited;
end;

class destructor TAlphaWindow.Destroy;
begin
  UninstallHookParent;
  FreeAndNil(FObjects);
end;

class procedure TAlphaWindow.InstallHookParent;
begin
  FParentWndHook := SetWindowsHookEx(WH_CALLWNDPROCRET, @CallWndRetProc, 0,
    GetCurrentThreadID);
end;

procedure TAlphaWindow.Paint;
var
  LLeftTop: TPoint;
begin
  LLeftTop := FParentControl.ClientToScreen(Point(0, 0));
  Left := LLeftTop.X;
  Top := LLeftTop.Y;
  inherited;
  ShowText;
end;

procedure TAlphaWindow.RegisterObj;
begin
  FObjects.Add(Self);
end;

procedure TAlphaWindow.CalcSize;
begin
  if not Assigned(FParentControl) then
    Exit;

  Width := Max(((FParentControl.Width - Margin) * WidthRelative) div 100, 2);
  Height := Max(((FParentControl.Height - Margin) * HeightRelative) div 100, 2);
end;

procedure TAlphaWindow.ShowText;
var
  LRect: TRect;
begin
  if (Width <= (Margin * 2 + 1)) or (Height <= (Margin * 2 + 1)) then
    Exit;

  LRect := Rect(Margin, Margin, Width + Margin, Height + Margin);
  Canvas.TextRect(LRect, FText, [tfLeft, tfTop, tfWordBreak]);
end;

class procedure TAlphaWindow.UninstallHookParent;
begin
  if FParentWndHook <> 0 then
    UnhookWindowsHookEx(FParentWndHook);
  FParentWndHook := 0;
end;

procedure TAlphaWindow.UnRegisterObj;
begin
  FObjects.Remove(Self);
end;

procedure TAlphaWindow.WMMove(var Message: TWMMove);
begin
  Invalidate;
end;

end.