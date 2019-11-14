unit uVideoWindow;

interface

uses uCHCNetSDK, Vcl.Controls, Winapi.Windows, uHikvisionErrors, System.Classes,
  Vcl.Graphics, System.SysUtils, System.Generics.Collections, Vcl.Menus,
  Vcl.Forms, Winapi.Messages, System.Math, uAlphaWindow;

const
  WM_PLAYVIDEO = WM_USER + 0;
  WM_STOPVIDEO = WM_USER + 1;
  WM_CHANGESELECTED = WM_USER + 2;
  WM_MAXIMIZEWND = WM_USER + 3;

type
  TSelfParentControl = class(TCustomControl)
  private const
    DEF_FONTNAME = 'Courier New';
    DEF_FONTSIZE = 12;
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
  private type
    TMenuItems = record
      Channel: TMenuItem;
      PrintOverlayText: TMenuItem;
      PalyStop: TMenuItem;
    end;
  public const
    STATUS_FONTSIZE = 12;
    STATUS_FONTNAME = 'Impact';
    STATUS_FONTCOLOR = $00FF96A0;
  private const
    CAPTION_DISABLED: string = 'DISABLED';
    CAPTION_STOPPED: string = 'VIDEO STOPPED';
    DEF_COLOR = clNavy;
    ERROR_FONTCOLOR = clYellow;
    ERROR_FONTSIZE = 10;
  private
    FUsed: Boolean;
    FSelected: Boolean;
    FChannel: Integer;
    FUserID: Integer;
    FRealHandle: Integer;
    FLastErrorDecription: string;
    FTextPanel: TAlphaWindow;
    FMenu: TPopupMenu;
    FMenuItems: TMenuItems;
  private // Обработка сообщений
    procedure WMPlayVideo(var Message: TMessage); message WM_PLAYVIDEO;
    procedure WMStopVideo(var Message: TMessage); message WM_STOPVIDEO;
  private // Меню
    procedure CreatePopupMenu;
    procedure OnPopup(Sender: TObject);
    procedure PopupSetChannel(Sender: TObject);
    procedure PopupPlayStop(Sender: TObject);
    procedure PopupSetPrintOverlayText(Sender: TObject);
    procedure UpdatePopupItems;
  private
    procedure ClearError;
    function GetIsPlaying: Boolean;
    procedure PrintErrorDescription;
    procedure PrintStatusCaption;
    procedure SetChannel(const Value: Integer);
    procedure SetUsed(const Value: Boolean);
    procedure CreateTextPanel;
  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure Paint; override;
    procedure Resize; override;
    procedure DblClick; override;
  public
    procedure PlayLiveVideo;
    procedure StopLiveVideo;
  public // Конструкторы/Деструкторы
    constructor Create(AParent: TWinControl); reintroduce;
    destructor Destroy; override;
  public
    property Used: Boolean read FUsed write SetUsed;
    property Selected: Boolean read FSelected write FSelected;
    property Channel: Integer read FChannel write SetChannel;
//    property OverlayText: string read GetOverlayText write SetOverlayText;
    property IsPlaying: Boolean read GetIsPlaying;
//    property ShowOverlayText: Boolean read GetShowOverlayText
//      write SetShowOverlayText;
    property UserID: Integer read FUserID write FUserID;
    property TextPanel: TAlphaWindow read FTextPanel write FTextPanel;
    property Font;
  end;

implementation

uses System.Types;

resourcestring
  RsPlay = 'Play';
  RsStop = 'Stop';

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

  CreatePopupMenu;
  CreateTextPanel;
end;

procedure TVideoWindow.CreatePopupMenu;
var
  LSubItem: TMenuItem;
  I: Integer;
begin
  FMenu := TPopupMenu.Create(Self);
  FMenu.AutoHotkeys := maManual;
  FMenu.OnPopup := OnPopup;

  FMenuItems.Channel := TMenuItem.Create(FMenu);
  FMenuItems.Channel.Caption := 'Set channel';
  FMenu.Items.Add(FMenuItems.Channel);

  for I := 1 to 16 do
  begin
    LSubItem := TMenuItem.Create(FMenu);
    LSubItem.Caption := 'Channel ' + IntToStr(I);
    LSubItem.Tag := I;
    LSubItem.OnClick := PopupSetChannel;
    FMenuItems.Channel.Add(LSubItem);
  end;

  FMenuItems.PalyStop := TMenuItem.Create(FMenu);
  FMenuItems.PalyStop.OnClick := PopupPlayStop;
  FMenu.Items.Add(FMenuItems.PalyStop);

  FMenuItems.PrintOverlayText := TMenuItem.Create(FMenu);
  FMenuItems.PrintOverlayText.Caption := 'Print overlay text';
  FMenuItems.PrintOverlayText.OnClick := PopupSetPrintOverlayText;
  FMenu.Items.Add(FMenuItems.PrintOverlayText);

  PopupMenu := FMenu;
end;

procedure TVideoWindow.CreateTextPanel;
begin
  FreeAndNil(FTextPanel);
  FTextPanel := TAlphaWindow.Create(Self);
end;

procedure TVideoWindow.DblClick;
begin
  SendMessage(Parent.Handle, WM_MAXIMIZEWND, Handle, 0);
  inherited;
end;

destructor TVideoWindow.Destroy;
begin
  StopLiveVideo;
  FreeAndNil(FMenu);
  FreeAndNil(FTextPanel);
  inherited;
  FreeAndNil(FParentForm);
end;

function TVideoWindow.GetIsPlaying: Boolean;
begin
  Result := FRealHandle >= 0;
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
//  if not NET_DVR_RigisterDrawFun(FRealHandle, DrawFun, FId) then
//    RaiseLastHVError;

  FTextPanel.Enabled := True;
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
  TextPanel.Used := not TextPanel.Used;
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

  Canvas.Font.Size := STATUS_FONTSIZE;
  Canvas.Font.Name := STATUS_FONTNAME;
  Canvas.Font.Color := STATUS_FONTCOLOR;
  Canvas.Brush.Style := bsClear;

  LRect := ClientRect;
  DrawText(Canvas.Handle, LText, Length(LText), LRect, DT_SINGLELINE or
    DT_CENTER or DT_VCENTER);
end;

procedure TVideoWindow.Resize;
begin
  inherited;

  if Assigned(FTextPanel) then
    FTextPanel.CalculateSize;
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

procedure TVideoWindow.SetUsed(const Value: Boolean);
begin
  FUsed := Value;
  Invalidate;
end;

procedure TVideoWindow.StopLiveVideo;
begin
  FTextPanel.Enabled := False;
  ClearError;
  if FRealHandle >= 0 then
    NET_DVR_StopRealPlay(FRealHandle);
  FRealHandle := -1;
  Invalidate;
end;

procedure TVideoWindow.UpdatePopupItems;
var
  I: Integer;
begin
  for I := 1 to FMenuItems.Channel.Count do
    FMenuItems.Channel.Items[I - 1].Checked :=
      FChannel = FMenuItems.Channel.Items[I - 1].Tag;

  if IsPlaying then
    FMenuItems.PalyStop.Caption := RsStop
  else
    FMenuItems.PalyStop.Caption := RsPlay;

  FMenuItems.PrintOverlayText.Checked := TextPanel.Used;
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

end.
