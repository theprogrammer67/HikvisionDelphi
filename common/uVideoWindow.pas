unit uVideoWindow;

interface

uses uCHCNetSDK, Vcl.Controls, Winapi.Windows, uHikvisionErrors, System.Classes,
  Vcl.Graphics, System.SysUtils, System.Generics.Collections, Vcl.Menus,
  Vcl.Forms, Winapi.Messages, System.Math;

const
  WM_PLAYVIDEO = WM_USER + 0;
  WM_STOPVIDEO = WM_USER + 1;
  WM_CHANGESELECTED = WM_USER + 2;

type
  TTextRectPosition = (tpTopLeft, tpTopRight, tpBottomRight, tpBottomLeft);

  TVideoWindow = class;

  TTextRectangle = class
  private const
    DEF_BKALPHABLEND = 128;
    DEF_BKCOLOR = clWhite;
    DEF_WIDTH = 50;
    DEF_HEIGHT = 50;
  private
    FParent: TVideoWindow;
    FWidth: Integer;
    FHeight: Integer;
    FPosition: TTextRectPosition;
    FText: string;
    FBackgroundAlfaBlend: Byte;
    FRectangle: TRect;
    FBackground: TBitmap;
  private
    procedure Resize(ARefresh: Boolean = True);
    procedure SetHeight(const Value: Integer);
    procedure SetPosition(const Value: TTextRectPosition);
    procedure SetWidth(const Value: Integer);
  public
    constructor Create(AParent: TVideoWindow);
    destructor Destroy; override;
    procedure DrawText(hDc: IntPtr);
  public
    property Position: TTextRectPosition read FPosition write SetPosition;
    property Width: Integer read FWidth write SetWidth;
    property Height: Integer read FHeight write SetHeight;
    property Text: string read FText write FText;
  end;

  TSelfParentControl = class(TCustomControl)
  private const
    DEF_FONTNAME = 'Courier New';
    DEF_FONTSIZE = 24;
    DEF_FONTCOLOR = clLime;
  protected
    FParentForm: TForm;
  private
    function CreateParentForm: TWinControl;
  public
    constructor Create(AParent: HWND); reintroduce; overload; virtual;
    constructor Create(AParent: TWinControl); reintroduce; overload;
    destructor Destroy; override;
    procedure Show;
  end;

  TVideoWindow = class(TSelfParentControl)
  public const
    STATUS_FONTCOLOR = $00FF96A0;
  private const
    CAPTION_DISABLED: string = 'DISABLED';
    CAPTION_STOPPED: string = 'VIDEO STOPPED';
    DEF_COLOR = clNavy;
    ERROR_FONTCOLOR = clYellow;
    ERROR_FONTSIZE = 10;
    STATUS_FONTNAME = 'Impact';
    STATUS_FONTSIZE = 24;
    DEF_FONTNAME = 'Courier New';
    DEF_FONTSIZE = 24;
    DEF_FONTCOLOR = clBlack;
  private
    FId: Cardinal;
    FUsed: Boolean;
    FSelected: Boolean;
    FChannel: Integer;
    FUserID: Integer;
    FRealHandle: Integer;
    FShowOverlayText: Boolean;
    FPopup: TPopupMenu;
    FMenuItemChannel: TMenuItem;
    FMenuItemPrintOverlayText: TMenuItem;
    FMenuItemPalyStop: TMenuItem;
    FLastErrorDecription: string;
    FTextRectangle: TTextRectangle;
    FEvenFrame: Boolean;
  private
    class var FObjects: TThreadList<TVideoWindow>;
    class var FGlobalId: Cardinal;
    procedure RegisterObj;
    procedure UnRegisterObj;
  public
    class constructor Create;
    class destructor Destroy;
  private
    class procedure DrawFun(lRealHandle: LongInt; hDc: IntPtr; dwUser: UINT);
      stdcall; static;
    procedure DrawFunction(hDc: IntPtr);
  private
    procedure WMPlayVideo(var Message: TMessage); message WM_PLAYVIDEO;
    procedure WMStopVideo(var Message: TMessage); message WM_STOPVIDEO;
  private
    procedure ClearError;
    function GetIsPlaying: Boolean;
    procedure PrintErrorDescription;
    procedure PrintStatusCaption;
    procedure CreatePopupMenu;
    procedure OnPopup(Sender: TObject);
    procedure PopupSetChannel(Sender: TObject);
    procedure PopupPlayStop(Sender: TObject);
    procedure PopupSetPrintOverlayText(Sender: TObject);
    procedure UpdatePopupItems;
    procedure SetChannel(const Value: Integer);
    procedure SetUsed(const Value: Boolean);
    function GetOverlayText: string;
    procedure SetOverlayText(const Value: string);
  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure Paint; override;
    procedure Resize; override;
  public
    constructor Create(AParent: TWinControl); reintroduce;
    destructor Destroy; override;
  public
    procedure PlayLiveVideo;
    procedure StopLiveVideo;
  public
    property Font;
    property Used: Boolean read FUsed write SetUsed;
    property Selected: Boolean read FSelected write FSelected;
    property Channel: Integer read FChannel write SetChannel;
    property OverlayText: string read GetOverlayText write SetOverlayText;
    property IsPlaying: Boolean read GetIsPlaying;
    property ShowOverlayText: Boolean read FShowOverlayText
      write FShowOverlayText;
    property UserID: Integer read FUserID write FUserID;
  end;

implementation

uses System.Types;

{ TWideoWindow }

procedure TVideoWindow.ClearError;
begin
  FLastErrorDecription := '';
end;

constructor TVideoWindow.Create(AParent: TWinControl);
begin
  inherited Create(AParent);

  FUserID := -1;
  FRealHandle := -1;
  Color := DEF_COLOR;
  Used := True;
  FChannel := 1;

  if Assigned(Parent) then
    ParentFont := True
  else
  begin
    Font.Name := DEF_FONTNAME;
    Font.Size := DEF_FONTSIZE;
    Font.Color := DEF_FONTCOLOR;
  end;

  RegisterObj;
  CreatePopupMenu;

  FTextRectangle := TTextRectangle.Create(Self);
end;

procedure TVideoWindow.CreatePopupMenu;
var
  LSubItem: TMenuItem;
  I: Integer;
begin
  FPopup := TPopupMenu.Create(Self);
  FPopup.AutoHotkeys := maManual;
  FPopup.OnPopup := OnPopup;

  FMenuItemChannel := TMenuItem.Create(FPopup);
  FMenuItemChannel.Caption := 'Set channel';
  FPopup.Items.Add(FMenuItemChannel);

  for I := 1 to 16 do
  begin
    LSubItem := TMenuItem.Create(FPopup);
    LSubItem.Caption := 'Channel ' + IntToStr(I);
    LSubItem.Tag := I;
    LSubItem.OnClick := PopupSetChannel;
    FMenuItemChannel.Add(LSubItem);
  end;

  FMenuItemPalyStop := TMenuItem.Create(FPopup);
  FMenuItemPalyStop.OnClick := PopupPlayStop;
  FPopup.Items.Add(FMenuItemPalyStop);

  FMenuItemPrintOverlayText := TMenuItem.Create(FPopup);
  FMenuItemPrintOverlayText.Caption := 'Print overlay text';
  FMenuItemPrintOverlayText.OnClick := PopupSetPrintOverlayText;
  FPopup.Items.Add(FMenuItemPrintOverlayText);

  PopupMenu := FPopup;
end;

class constructor TVideoWindow.Create;
begin
  FObjects := TThreadList<TVideoWindow>.Create;
  FGlobalId := 0;
end;

destructor TVideoWindow.Destroy;
begin
  StopLiveVideo;
  UnRegisterObj;
  FreeAndNil(FPopup);
  FreeAndNil(FTextRectangle);
  inherited;
  FreeAndNil(FParentForm);
end;

class destructor TVideoWindow.Destroy;
begin
  FreeAndNil(FObjects);
end;

class procedure TVideoWindow.DrawFun(lRealHandle: Integer; hDc: IntPtr;
  dwUser: UINT);
var
  LObj: TVideoWindow;
  I: Integer;
  LObjects: TList<TVideoWindow>;
begin
  LObjects := FObjects.LockList;
  try
    for I := 0 to LObjects.Count - 1 do
    begin
      LObj := LObjects[I];
      if LObj.FId = dwUser then
      begin
        LObj.DrawFunction(hDc);
        Break;
      end;
    end;
  finally
    FObjects.UnlockList;
  end;
end;

procedure TVideoWindow.DrawFunction(hDc: IntPtr);
begin
  if (not FShowOverlayText) or (Length(OverlayText) = 0) or (not Visible) or
    (not Used) then
    Exit;

  FEvenFrame := not FEvenFrame;
  if not FEvenFrame then // Обрабатываем только нечетные вызовы
    FTextRectangle.DrawText(hDc);
end;

function TVideoWindow.GetIsPlaying: Boolean;
begin
  Result := FRealHandle >= 0;
end;

function TVideoWindow.GetOverlayText: string;
begin
  Result := FTextRectangle.Text;
end;

procedure TVideoWindow.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  if Assigned(Parent) and (Button = mbLeft) then
    SendMessage(Parent.Handle, WM_CHANGESELECTED, Handle, 0);

  inherited;
end;

procedure TVideoWindow.WMPlayVideo(var Message: TMessage);
begin
  try
    PlayLiveVideo;
  except
    FLastErrorDecription := Exception(ExceptObject).Message;
    PrintErrorDescription;
  end;
end;

procedure TVideoWindow.OnPopup(Sender: TObject);
begin
  UpdatePopupItems;
end;

procedure TVideoWindow.WMStopVideo(var Message: TMessage);
begin
  try
    StopLiveVideo;
  except
    FLastErrorDecription := Exception(ExceptObject).Message;
    PrintErrorDescription;
  end;
end;

procedure TVideoWindow.Paint;
begin
  inherited;
  PrintStatusCaption;
end;

procedure TVideoWindow.PlayLiveVideo;
var
  LPreviewInfo: NET_DVR_PREVIEWINFO;
begin
  StopLiveVideo;
  ClearError;
  if UserID < 0 then
    raise Exception.Create(RsErrUserNotAuthorized);

  ZeroMemory(@LPreviewInfo, SizeOf(LPreviewInfo));
  LPreviewInfo.hPlayWnd := Self.Handle;
  LPreviewInfo.lChannel := FChannel;
  LPreviewInfo.dwStreamType := 0;
  LPreviewInfo.dwLinkMode := 0;
  LPreviewInfo.bBlocked := True;
  LPreviewInfo.dwDisplayBufNum := 1;
  LPreviewInfo.byProtoType := 0;
  LPreviewInfo.byPreviewMode := 0;

  FRealHandle := NET_DVR_RealPlay_V40(UserID, LPreviewInfo, nil, 0);
  if FRealHandle < 0 then
    RaiseLastHVError;
  FEvenFrame := False;
  if not NET_DVR_RigisterDrawFun(FRealHandle, DrawFun, FId) then
    RaiseLastHVError;
end;

procedure TVideoWindow.PopupPlayStop(Sender: TObject);
begin
  if IsPlaying then
    StopLiveVideo
  else
    PlayLiveVideo;
end;

procedure TVideoWindow.PopupSetChannel(Sender: TObject);
begin
  Channel := TMenuItem(Sender).Tag;
end;

procedure TVideoWindow.PopupSetPrintOverlayText(Sender: TObject);
begin
  ShowOverlayText := not ShowOverlayText;
end;

procedure TVideoWindow.PrintErrorDescription;
var
  LRect: TRect;
begin
  if FLastErrorDecription = '' then
    Exit;

  Canvas.Font.Size := ERROR_FONTSIZE;
  Canvas.Font.Name := DEF_FONTNAME;
  Canvas.Font.Color := ERROR_FONTCOLOR;
  Canvas.Brush.Style := bsClear;

  LRect := ClientRect;
  DrawText(Canvas.Handle, FLastErrorDecription, Length(FLastErrorDecription),
    LRect, DT_WORDBREAK or DT_LEFT or DT_TOP);
end;

procedure TVideoWindow.PrintStatusCaption;
var
  LText: string;
  LRect: TRect;
begin
  PrintErrorDescription;

  if not Used then
    LText := CAPTION_DISABLED
  else if not IsPlaying then
    LText := CAPTION_STOPPED
  else
    Exit;

  Canvas.Font.Size := 12;
  Canvas.Font.Name := 'Impact';
  Canvas.Font.Color := STATUS_FONTCOLOR;
  Canvas.Brush.Style := bsClear;

  LRect := ClientRect;
  DrawText(Canvas.Handle, LText, Length(LText), LRect, DT_SINGLELINE or
    DT_CENTER or DT_VCENTER);
end;

procedure TVideoWindow.RegisterObj;
begin
  FObjects.Add(Self);
  Self.FId := FGlobalId;
  Inc(FGlobalId);
end;

procedure TVideoWindow.Resize;
begin
  inherited;

  if Assigned(FTextRectangle) then
    FTextRectangle.Resize;
end;

procedure TVideoWindow.SetChannel(const Value: Integer);
begin
  FChannel := Value;
  if IsPlaying then
  begin
    StopLiveVideo;
    PlayLiveVideo;
  end;
end;

procedure TVideoWindow.SetOverlayText(const Value: string);
begin
  FTextRectangle.Text := Value;
end;

procedure TVideoWindow.SetUsed(const Value: Boolean);
begin
  FUsed := Value;
  Invalidate;
end;

procedure TVideoWindow.StopLiveVideo;
begin
  ClearError;
  if FRealHandle >= 0 then
    NET_DVR_StopRealPlay(FRealHandle);
  FRealHandle := -1;
  Invalidate;
end;

procedure TVideoWindow.UnRegisterObj;
begin
  FObjects.Remove(Self);
end;

procedure TVideoWindow.UpdatePopupItems;
var
  I: Integer;
begin
  for I := 1 to FMenuItemChannel.Count do
    FMenuItemChannel.Items[I - 1].Checked := FChannel = FMenuItemChannel.Items
      [I - 1].Tag;

  if IsPlaying then
    FMenuItemPalyStop.Caption := 'Stop'
  else
    FMenuItemPalyStop.Caption := 'Play';

  FMenuItemPrintOverlayText.Checked := FShowOverlayText;
end;

{ TSelfParentControl }

constructor TSelfParentControl.Create(AParent: HWND);
var
  LParent: HWND;
begin
  if (AParent = 0) or not IsWindow(AParent) then
    LParent := CreateParentForm.Handle
  else
    LParent := AParent;
  inherited CreateParented(LParent);

  if Assigned(FParentForm) then
  begin
    Parent := FParentForm;
    Align := alClient;
  end;
end;

constructor TSelfParentControl.Create(AParent: TWinControl);
begin
  if Assigned(AParent) then
  begin
    Create(AParent.Handle);
    Parent := AParent;
  end
  else
    Create(0);
end;

function TSelfParentControl.CreateParentForm: TWinControl;
begin
  FParentForm := TForm.Create(nil);
  FParentForm.BorderStyle := bsSizeToolWin;
  FParentForm.BorderIcons := [];
  FParentForm.Position := poScreenCenter;
  FParentForm.FormStyle := fsStayOnTop;
  FParentForm.Font.Name := DEF_FONTNAME;
  FParentForm.Font.Size := DEF_FONTSIZE;
  FParentForm.Font.Color := DEF_FONTCOLOR;
  FParentForm.Width := 320;
  FParentForm.Height := 240;

  Result := FParentForm;
end;

destructor TSelfParentControl.Destroy;
begin

  inherited;
  FreeAndNil(FParentForm);
end;

procedure TSelfParentControl.Show;
begin
  if Assigned(FParentForm) then
    FParentForm.Visible := True;

  Winapi.Windows.ShowWindow(Self.Handle, SW_MAXIMIZE);
end;

{ TTextRectangle }

procedure TTextRectangle.Resize(ARefresh: Boolean);
begin
  if not Assigned(FParent) or (FParent.Width = 0) or (FParent.Height = 0) then
    Exit;

  FRectangle.Left := 1;
  FRectangle.Top := 1;

  FRectangle.Width := Max(((FParent.Width - 2) * Width) div 100, 2);
  FRectangle.Height := Max(((FParent.Height - 2) * Height) div 100, 2);

  if FPosition in [tpTopRight, tpBottomRight] then
    FRectangle.Offset(FParent.Width - FRectangle.Width - 1, 0);

  if FPosition in [tpBottomLeft, tpBottomRight] then
    FRectangle.Offset(0, FParent.Height - FRectangle.Height - 1);

  FBackground.Canvas.Lock;
  try
    FBackground.SetSize(FRectangle.Width, FRectangle.Height);
    FBackground.Canvas.Rectangle(0, 0, FBackground.Width, FBackground.Height);
  finally
    FBackground.Canvas.Unlock;
  end;

  if ARefresh then
    FParent.Invalidate;
end;

constructor TTextRectangle.Create(AParent: TVideoWindow);
begin
  FBackground := TBitmap.Create;
  FBackground.PixelFormat := pfDevice;
  FBackground.Canvas.Pen.Color := DEF_BKCOLOR;
  FBackground.Canvas.Brush.Color := DEF_BKCOLOR;
  FBackgroundAlfaBlend := DEF_BKALPHABLEND;

  FParent := AParent;
  FPosition := tpTopLeft;
  FWidth := DEF_WIDTH;
  FHeight := DEF_HEIGHT;
  Resize(False);
end;

destructor TTextRectangle.Destroy;
begin
  FreeAndNil(FBackground);
  inherited;
end;

procedure TTextRectangle.DrawText(hDc: IntPtr);
var
  LObj: HGDIOBJ;
  LHFont: HFONT;
  Desc: TBlendFunction;
begin
  // Фон
  Desc.BlendOp := AC_SRC_OVER;
  Desc.BlendFlags := 0;
  Desc.SourceConstantAlpha := FBackgroundAlfaBlend;
  Desc.AlphaFormat := 0;

  FBackground.Canvas.Lock;
  try
    Winapi.Windows.AlphaBlend(hDc, FRectangle.Left, FRectangle.Top,
      FRectangle.Width, FRectangle.Height, FBackground.Canvas.Handle, 0, 0,
      FBackground.Width, FBackground.Height, Desc);
  finally
    FBackground.Canvas.Unlock;
  end;

  // Текст
  LHFont := CreateFont(FParent.Font.Size, 0, 0, 0, FW_NORMAL, 0, 0, 0, 0, 0, 0,
    2, 0, PWideChar(FParent.Font.Name));
  LObj := SelectObject(hDc, LHFont);
  try
    SetBkMode(hDc, TRANSPARENT);
    SetTextColor(hDc, FParent.Font.Color);
    Winapi.Windows.DrawText(hDc, PWideChar(FParent.OverlayText),
      Length(FParent.OverlayText), FRectangle, DT_LEFT or DT_TOP or
      DT_WORDBREAK);
  finally
    DeleteObject(SelectObject(hDc, LObj));
  end;
end;

procedure TTextRectangle.SetHeight(const Value: Integer);
begin
  FHeight := Value;
  Resize;
end;

procedure TTextRectangle.SetPosition(const Value: TTextRectPosition);
begin
  FPosition := Value;
  Resize;
end;

procedure TTextRectangle.SetWidth(const Value: Integer);
begin
  FWidth := Value;
  Resize;
end;

end.
