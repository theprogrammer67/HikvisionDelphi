unit uAlphaWindow;

interface

uses Vcl.Controls, System.Classes, Winapi.Windows, Vcl.Graphics, System.Types,
  System.Math, System.Generics.Collections, Winapi.Messages, System.SysUtils,
  Vcl.ExtCtrls, Vcl.Menus;

type
  TWindowPosition = (tpTopLeft, tpTopRight, tpBottomRight, tpBottomLeft);

const
  WPOSITION_NAMES: array [TWindowPosition] of string = ('Top-Left', 'Top-Right',
    'Bottom-Right', 'Bottom-Left');

type
  TColorScheme = (csWhiteBlack, csRedBlack, csGreenBlack, csBlueBlack,
    csBlackWhite, csRedWhite, csGreenWhite, csBlueWhite);

  TParentControl = class(TCustomControl)
  public
    property Font;
  end;

  TAlphaWindow = class(TCustomControl)
  private type
    TColorSchemeParams = record
      Name: string;
      BgColor: TColor;
      FontColor: TColor;
    end;

    TMenuItems = record
      ColorScheme: TMenuItem;
      Brightness: TMenuItem;
      AlphaBlend: TMenuItem;
      TransparentBackground: TMenuItem;
      Position: TMenuItem;
      Width: TMenuItem;
      Height: TMenuItem;
      Margin: TMenuItem;
    end;
  private const
    TIMER_INTERVAL = 150;
    DEF_MARGIN = 5;
    DEF_WIDTHRELATIVE = 50;
    DEF_HEIGHTRELATIVE = 50;
    TRANSPARENT_COLOR = clTeal;
    DEF_BRIGHTNESS = -50;
    DEF_ALPHABLEND = 127;
    DEF_COLORSCHEME = csGreenWhite;
    COLORSCHEME_PARAMS: array [TColorScheme] of TColorSchemeParams =
      ((Name: 'White/Black'; BgColor: clWhite; FontColor: clBlack),
      (Name: 'Red/Black'; BgColor: clRed; FontColor: clBlack),
      (Name: 'Green/Black'; BgColor: clGreen; FontColor: clBlack),
      (Name: 'Blue/Black'; BgColor: clBlue; FontColor: clBlack),
      (Name: 'Black/White'; BgColor: clBlack; FontColor: clWhite),
      (Name: 'Red/White'; BgColor: clRed; FontColor: clWhite),
      (Name: 'Green/White'; BgColor: clGreen; FontColor: clWhite),
      (Name: 'Blue/White'; BgColor: clBlue; FontColor: clWhite));
  private
    FParentControl: TParentControl;
    FUsed: Boolean;
    FText: string;
    FMargin: Integer;
    FWidthRelative: Integer;
    FHeightRelative: Integer;
    FTimer: TTimer;
    FParentPos: TPoint;
    FMenu: TPopupMenu;
    FMenuItems: TMenuItems;
    FColorScheme: TColorScheme;
    FAlphaBlend: Byte;
    FBrightness: Integer;
    FTransparentBackground: Boolean;
    FPosition: TWindowPosition;
  private
    class var FParentWndHook: HHOOK;
    class var FObjects: TThreadList<TAlphaWindow>;
    procedure RegisterObj;
    procedure UnRegisterObj;
  private
    class function CallWndRetProc(ACode: Integer; AwParam: WPARAM;
      AlParam: LPARAM): LRESULT; stdcall; static;
    class procedure InstallHookParent;
    class procedure UninstallHookParent;
  private // Обработка сообщений
    procedure WMMove(var Message: TWMMove); message WM_MOVE;
    procedure CMVisibleChanged(var Message: TMessage);
      message CM_VISIBLECHANGED;
    procedure WMWindowPosChanged(var Message: TWMWindowPosChanged);
      message WM_WINDOWPOSCHANGED;
  private // Меню
    procedure CreatePopupMenu;
    procedure UpdatePopupItems;
    procedure OnPopup(Sender: TObject);
    procedure PopupSetColorScheme(Sender: TObject);
    procedure PopupSetBrigtness(Sender: TObject);
    procedure PopupSetAlphaBlend(Sender: TObject);
    procedure PopupSetTransparentBackground(Sender: TObject);
    procedure PopupSetSetPosition(Sender: TObject);
    procedure PopupSetWidth(Sender: TObject);
    procedure PopupSetHeight(Sender: TObject);
    procedure PopupSetMargin(Sender: TObject);
  private
    procedure UpdateVisible;
    procedure SetUsed(const Value: Boolean);
    procedure SetColors;
    procedure ShowText;
    procedure OnTimer(Sender: TObject);
    procedure SetText(const Value: string);
    procedure SetMargin(const Value: Integer);
    procedure SetHeightRelative(const Value: Integer);
    procedure SetWidthRelative(const Value: Integer);
    procedure SetColorScheme(const Value: TColorScheme);
    procedure SetBrightness(const Value: Integer);
    procedure SetAlphaBlend(const Value: Byte);
    procedure SetTransparentBackground(const Value: Boolean);
    procedure SetPosition(const Value: TWindowPosition);
  protected
    procedure Paint; override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWindowHandle(const Params: TCreateParams); override;
  public
    procedure CalculateSize;
    procedure CalculatePosition;
  public // Конструкторы/Деструкторы
    class constructor Create;
    class destructor Destroy;
    constructor Create(AParent: TCustomControl); reintroduce;
    destructor Destroy; override;
  public
    property Text: string read FText write SetText;
    property Margin: Integer read FMargin write SetMargin;
    property WidthRelative: Integer read FWidthRelative write SetWidthRelative;
    property HeightRelative: Integer read FHeightRelative
      write SetHeightRelative;
    property Used: Boolean read FUsed write SetUsed;
    property AlphaBlend: Byte read FAlphaBlend write SetAlphaBlend;
    property ColorScheme: TColorScheme read FColorScheme write SetColorScheme;
    property Brightness: Integer read FBrightness write SetBrightness;
    property TransparentBackground: Boolean read FTransparentBackground
      write SetTransparentBackground;
    property Position: TWindowPosition read FPosition write SetPosition;
  end;

implementation

function AdjustColor(AColor: TColor; APercent: ShortInt): TColor;

  function AdjustValue(AValue: Byte): Byte;
  begin
    if APercent > 0 then
      Result := AValue + MulDiv(255 - AValue, APercent, 100)
    else
      Result := AValue - MulDiv(AValue, -APercent, 100);
  end;

var
  r, g, b: Byte;
begin
  AColor := ColorToRGB(AColor);
  r := AdjustValue(GetRValue(AColor));
  g := AdjustValue(GetGValue(AColor));
  b := AdjustValue(GetBValue(AColor));
  Result := RGB(r, g, b);
end;

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
          // SendMessage(LObj.Handle, LMessage, LwParam, LlParam);
          case LMessage of
            WM_SIZE, WM_MOVE, WM_SHOWWINDOW, CM_VISIBLECHANGED, WM_PAINT:
              SendMessage(LObj.Handle, LMessage, LwParam, LlParam);
            WM_WINDOWPOSCHANGED:
              LObj.UpdateVisible;
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
  if Visible and Showing then
    Winapi.Windows.ShowWindow(Handle, SW_SHOWNORMAL)
  else
    Winapi.Windows.ShowWindow(Handle, SW_HIDE);
end;

constructor TAlphaWindow.Create(AParent: TCustomControl);
begin
  inherited CreateParented(AParent.Handle);

  Enabled := False; // Отображаем только при воспроизведении

  FParentControl := TParentControl(AParent);
  FParentPos := Point(AParent.Left, AParent.Top);

  FTimer := TTimer.Create(nil);
  FTimer.Interval := TIMER_INTERVAL;
  FTimer.OnTimer := OnTimer;

  Canvas.Brush.Style := bsClear;
  Font := FParentControl.Font;
  Canvas.Font := Font;
  AlphaBlend := DEF_ALPHABLEND;
  Brightness := DEF_BRIGHTNESS;
  ColorScheme := DEF_COLORSCHEME;
  TransparentBackground := False;
  FMargin := DEF_MARGIN;
  FWidthRelative := DEF_WIDTHRELATIVE;
  FHeightRelative := DEF_HEIGHTRELATIVE;

  RegisterObj;
  CreatePopupMenu;
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
  Params.Style := WS_POPUP or WS_VISIBLE;
  Params.ExStyle := WS_EX_LAYERED or WS_EX_TOOLWINDOW;
end;

procedure TAlphaWindow.CreatePopupMenu;
var
  LSubItem: TMenuItem;
  LScheme: TColorScheme;
  I, LValue: Integer;
  LPosition: TWindowPosition;
begin
  FMenu := TPopupMenu.Create(Self);
  FMenu.AutoHotkeys := maManual;
  FMenu.OnPopup := OnPopup;

  FMenuItems.ColorScheme := TMenuItem.Create(FMenu);
  FMenuItems.ColorScheme.Caption := 'Color scheme';
  FMenu.Items.Add(FMenuItems.ColorScheme);
  for LScheme := Low(TColorScheme) to High(TColorScheme) do
  begin
    LSubItem := TMenuItem.Create(FMenu);
    LSubItem.Caption := COLORSCHEME_PARAMS[LScheme].Name;
    LSubItem.Tag := Ord(LScheme);
    LSubItem.OnClick := PopupSetColorScheme;
    FMenuItems.ColorScheme.Add(LSubItem);
    if Ord(LScheme) = 3 then
      FMenuItems.ColorScheme.NewBottomLine;
  end;

  FMenuItems.Brightness := TMenuItem.Create(FMenu);
  FMenuItems.Brightness.Caption := 'Brightness';
  FMenu.Items.Add(FMenuItems.Brightness);
  for I := -4 to 4 do
  begin
    LValue := I * 25;
    LSubItem := TMenuItem.Create(FMenu);
    LSubItem.Caption := IntToStr(LValue) + '%';
    LSubItem.Tag := LValue;
    LSubItem.OnClick := PopupSetBrigtness;
    FMenuItems.Brightness.Add(LSubItem);
  end;

  FMenuItems.AlphaBlend := TMenuItem.Create(FMenu);
  FMenuItems.AlphaBlend.Caption := 'Transparency';
  FMenu.Items.Add(FMenuItems.AlphaBlend);
  for I := 1 to 4 do
  begin
    LValue := I * 64 - 1;
    LSubItem := TMenuItem.Create(FMenu);
    LSubItem.Caption := IntToStr(100 - Round(LValue / (256 / 100))) + '%';
    LSubItem.Tag := LValue;
    LSubItem.OnClick := PopupSetAlphaBlend;
    FMenuItems.AlphaBlend.Add(LSubItem);
  end;

  FMenuItems.TransparentBackground := TMenuItem.Create(FMenu);
  FMenuItems.TransparentBackground.Caption := 'Transparent background';
  FMenuItems.TransparentBackground.OnClick := PopupSetTransparentBackground;
  FMenu.Items.Add(FMenuItems.TransparentBackground);

  FMenuItems.Position := TMenuItem.Create(FMenu);
  FMenuItems.Position.Caption := 'Position';
  FMenu.Items.Add(FMenuItems.Position);
  for LPosition := Low(TWindowPosition) to High(TWindowPosition) do
  begin
    LSubItem := TMenuItem.Create(FMenu);
    LSubItem.Caption := WPOSITION_NAMES[LPosition];
    LSubItem.Tag := Ord(LPosition);
    LSubItem.OnClick := PopupSetSetPosition;
    FMenuItems.Position.Add(LSubItem);
  end;

  FMenuItems.Width := TMenuItem.Create(FMenu);
  FMenuItems.Width.Caption := 'Width';
  FMenu.Items.Add(FMenuItems.Width);
  for I := 1 to 4 do
  begin
    LValue := I * 25;
    LSubItem := TMenuItem.Create(FMenu);
    LSubItem.Caption := IntToStr(LValue) + '%';
    LSubItem.Tag := LValue;
    LSubItem.OnClick := PopupSetWidth;
    FMenuItems.Width.Add(LSubItem);
  end;

  FMenuItems.Height := TMenuItem.Create(FMenu);
  FMenuItems.Height.Caption := 'Height';
  FMenu.Items.Add(FMenuItems.Height);
  for I := 1 to 4 do
  begin
    LValue := I * 25;
    LSubItem := TMenuItem.Create(FMenu);
    LSubItem.Caption := IntToStr(LValue) + '%';
    LSubItem.Tag := LValue;
    LSubItem.OnClick := PopupSetHeight;
    FMenuItems.Height.Add(LSubItem);
  end;

  FMenuItems.Margin := TMenuItem.Create(FMenu);
  FMenuItems.Margin.Caption := 'Margin';
  FMenu.Items.Add(FMenuItems.Margin);
  for I := 0 to 3 do
  begin
    LValue := I * 5;
    LSubItem := TMenuItem.Create(FMenu);
    LSubItem.Caption := IntToStr(LValue) + ' px';
    LSubItem.Tag := LValue;
    LSubItem.OnClick := PopupSetMargin;
    FMenuItems.Margin.Add(LSubItem);
  end;

  PopupMenu := FMenu;
end;

procedure TAlphaWindow.CreateWindowHandle(const Params: TCreateParams);
begin
  inherited;
  Winapi.Windows.SetLayeredWindowAttributes(Handle, 0, FAlphaBlend, LWA_ALPHA);
end;

destructor TAlphaWindow.Destroy;
begin
  FreeAndNil(FTimer);
  FreeAndNil(FMenu);
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

procedure TAlphaWindow.OnPopup(Sender: TObject);
begin
  UpdatePopupItems;
end;

procedure TAlphaWindow.OnTimer(Sender: TObject);
var
  LParentPos: TPoint;
begin
  UpdateVisible;
  if not Visible then
    Exit;

  LParentPos := FParentControl.ClientToScreen(Point(0, 0));
  if LParentPos = FParentPos then
    Exit;

  FParentPos := LParentPos;
  Perform(WM_MOVE, 0, 0);
end;

procedure TAlphaWindow.Paint;
begin
  inherited;
  ShowText;
end;

procedure TAlphaWindow.PopupSetAlphaBlend(Sender: TObject);
begin
  AlphaBlend := TMenuItem(Sender).Tag;
end;

procedure TAlphaWindow.PopupSetBrigtness(Sender: TObject);
begin
  Brightness := TMenuItem(Sender).Tag;
end;

procedure TAlphaWindow.PopupSetColorScheme(Sender: TObject);
begin
  ColorScheme := TColorScheme(TMenuItem(Sender).Tag);
end;

procedure TAlphaWindow.PopupSetHeight(Sender: TObject);
begin
  HeightRelative := TMenuItem(Sender).Tag;
end;

procedure TAlphaWindow.PopupSetMargin(Sender: TObject);
begin
  Margin := TMenuItem(Sender).Tag;
end;

procedure TAlphaWindow.PopupSetSetPosition(Sender: TObject);
begin
  Position := TWindowPosition(TMenuItem(Sender).Tag);
end;

procedure TAlphaWindow.PopupSetTransparentBackground(Sender: TObject);
begin
  TransparentBackground := not TransparentBackground;
end;

procedure TAlphaWindow.PopupSetWidth(Sender: TObject);
begin
  WidthRelative := TMenuItem(Sender).Tag;
end;

procedure TAlphaWindow.RegisterObj;
begin
  FObjects.Add(Self);
end;

procedure TAlphaWindow.CalculatePosition;
var
  LLeftTop: TPoint;
begin
  LLeftTop := FParentControl.ClientToScreen(Point(0, 0));

  if FPosition in [tpTopRight, tpBottomRight] then
    Left := LLeftTop.X + (FParentControl.Width - Width - Margin)
  else
    Left := LLeftTop.X + Margin;

  if FPosition in [tpBottomLeft, tpBottomRight] then
    Top := LLeftTop.Y + (FParentControl.Height - Height - Margin)
  else
    Top := LLeftTop.Y + Margin;
end;

procedure TAlphaWindow.CalculateSize;
begin
  if not Assigned(FParentControl) then
    Exit;

  Width := Max(((FParentControl.Width - Margin * 2) * WidthRelative) div 100, 2);
  Height := Max(((FParentControl.Height - Margin * 2) * HeightRelative) div 100, 2);
end;

procedure TAlphaWindow.SetAlphaBlend(const Value: Byte);
begin
  FAlphaBlend := Value;
  if not TransparentBackground then
    Winapi.Windows.SetLayeredWindowAttributes(Handle, 0, FAlphaBlend,
      LWA_ALPHA);
end;

procedure TAlphaWindow.SetBrightness(const Value: Integer);
begin
  FBrightness := Value;
  SetColors;
end;

procedure TAlphaWindow.SetColors;
begin
  if TransparentBackground then
    Color := TRANSPARENT_COLOR
  else
    Color := AdjustColor(COLORSCHEME_PARAMS[FColorScheme].BgColor, FBrightness);

  Canvas.Brush.Color := Color;
  Canvas.Font.Color := COLORSCHEME_PARAMS[FColorScheme].FontColor;
  Invalidate;
end;

procedure TAlphaWindow.SetColorScheme(const Value: TColorScheme);
begin
  FColorScheme := Value;
  SetColors;
end;

procedure TAlphaWindow.SetHeightRelative(const Value: Integer);
begin
  FHeightRelative := Value;
  CalculateSize;
end;

procedure TAlphaWindow.SetMargin(const Value: Integer);
begin
  FMargin := Value;
  CalculateSize;
end;

procedure TAlphaWindow.SetPosition(const Value: TWindowPosition);
begin
  FPosition := Value;
  CalculatePosition;
end;

procedure TAlphaWindow.SetText(const Value: string);
begin
  FText := Value;
  Invalidate;
end;

procedure TAlphaWindow.SetTransparentBackground(const Value: Boolean);
begin
  FTransparentBackground := Value;
  if FTransparentBackground then
    SetLayeredWindowAttributes(Handle, ColorToRGB(TRANSPARENT_COLOR), 0,
      LWA_COLORKEY)
  else
    SetLayeredWindowAttributes(Handle, 0, FAlphaBlend, LWA_ALPHA);

  SetColors;
end;

procedure TAlphaWindow.SetUsed(const Value: Boolean);
begin
  FUsed := Value;
  UpdateVisible;
end;

procedure TAlphaWindow.SetWidthRelative(const Value: Integer);
begin
  FWidthRelative := Value;
  CalculateSize;
end;

procedure TAlphaWindow.ShowText;
var
  LRect: TRect;
  LBrushColor: TColor;
begin
  if (Width <= (Margin * 2 + 1)) or (Height <= (Margin * 2 + 1)) then
    Exit;

  LRect := Rect(Margin, Margin, Width - Margin, Height - Margin);
  Canvas.TextRect(LRect, FText, [tfLeft, tfTop, tfWordBreak]);
  LBrushColor := Canvas.Brush.Color;
  try
    InflateRect(LRect, Margin, Margin);
    if TransparentBackground then
      Canvas.Brush.Color := clSilver
    else
      Canvas.Brush.Color := AdjustColor(Color, 50);
    Canvas.FrameRect(LRect);
  finally
    Canvas.Brush.Color := LBrushColor;
  end;
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

procedure TAlphaWindow.UpdatePopupItems;
var
  I: Integer;
begin
  for I := 0 to FMenuItems.ColorScheme.Count - 1 do
    FMenuItems.ColorScheme.Items[I].Checked := Ord(FColorScheme)
      = FMenuItems.ColorScheme.Items[I].Tag;
  for I := 0 to FMenuItems.Brightness.Count - 1 do
    FMenuItems.Brightness.Items[I].Checked :=
      FBrightness = FMenuItems.Brightness.Items[I].Tag;
  for I := 0 to FMenuItems.AlphaBlend.Count - 1 do
    FMenuItems.AlphaBlend.Items[I].Checked :=
      FAlphaBlend = FMenuItems.AlphaBlend.Items[I].Tag;
  FMenuItems.TransparentBackground.Checked := TransparentBackground;
  for I := 0 to FMenuItems.Position.Count - 1 do
    FMenuItems.Position.Items[I].Checked := Ord(FPosition)
      = FMenuItems.Position.Items[I].Tag;
  for I := 0 to FMenuItems.Width.Count - 1 do
    FMenuItems.Width.Items[I].Checked := WidthRelative
      = FMenuItems.Width.Items[I].Tag;
  for I := 0 to FMenuItems.Height.Count - 1 do
    FMenuItems.Height.Items[I].Checked := HeightRelative
      = FMenuItems.Height.Items[I].Tag;
  for I := 0 to FMenuItems.Margin.Count - 1 do
    FMenuItems.Margin.Items[I].Checked := Margin
      = FMenuItems.Margin.Items[I].Tag;
end;

procedure TAlphaWindow.UpdateVisible;
begin
  Visible := IsWindowVisible(FParentControl.Handle) and Used and Enabled;
end;

procedure TAlphaWindow.WMMove(var Message: TWMMove);
begin
  inherited;
  CalculatePosition;
  Invalidate;
end;

procedure TAlphaWindow.WMWindowPosChanged(var Message: TWMWindowPosChanged);
begin
  inherited;
  CalculatePosition;
  Invalidate;
end;

end.
