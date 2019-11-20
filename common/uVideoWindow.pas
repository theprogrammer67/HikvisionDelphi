unit uVideoWindow;

interface

uses uCHCNetSDK, Vcl.Controls, Winapi.Windows, uHikvisionErrors, System.Classes,
  Vcl.Graphics, System.SysUtils, System.Generics.Collections, Vcl.Menus,
  Vcl.Forms, Winapi.Messages, System.Math, uAlphaWindow, uCommonTypes;

const
  WM_PLAYVIDEO = WM_USER + 0;
  WM_STOPVIDEO = WM_USER + 1;
  WM_CHANGESELECTED = WM_USER + 2;
  WM_MAXIMIZEWND = WM_USER + 3;
  WM_CUSTOMEVENT = WM_USER + 4;

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
    TMenuVideoWindow = class(TPopupMenuEx<TVideoWindow>)
    public
      constructor Create(AOwner: TVideoWindow); override;
    public
      Capture: TMenuItem;
      SendEvent: TMenuItem;
      Channel: TMenuItem;
      ShowTextPanel: TMenuItem;
      PlayStop: TMenuItem;
      StartStopRecord: TMenuItem;
    public
      procedure UpdateItems(Sender: TObject); override;
      procedure OnClickCapture(Sender: TObject);
      procedure OnSendEvent(Sender: TObject);
      procedure OnClickChannel(Sender: TObject);
      procedure OnClickPlayStop(Sender: TObject);
      procedure OnClickShowTextPanel(Sender: TObject);
      procedure OnClickStartStopRecord(Sender: TObject);
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
    FPlayHandle: Integer;
    FLastErrorDecription: string;
    FTextPanel: TAlphaWindow;
    FMenu: TMenuVideoWindow;
    FCaptureDir: string;
    FRecord: Boolean;
  private // Обработка сообщений
    procedure WMPlayVideo(var Message: TMessage); message WM_PLAYVIDEO;
    procedure WMStopVideo(var Message: TMessage); message WM_STOPVIDEO;
  private // Меню
    procedure CreatePopupMenu;
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
    procedure CapturePicture;
    procedure StartSaveRealData;
    procedure StopSaveRealData;
  public // Конструкторы/Деструкторы
    constructor Create(AParent: TWinControl); reintroduce;
    destructor Destroy; override;
  public
    property Used: Boolean read FUsed write SetUsed;
    property Selected: Boolean read FSelected write FSelected;
    property Channel: Integer read FChannel write SetChannel;
    // property OverlayText: string read GetOverlayText write SetOverlayText;
    property IsPlaying: Boolean read GetIsPlaying;
    // property ShowOverlayText: Boolean read GetShowOverlayText
    // write SetShowOverlayText;
    property UserID: Integer read FUserID write FUserID;
    property TextPanel: TAlphaWindow read FTextPanel write FTextPanel;
    property CaptureDir: string read FCaptureDir write FCaptureDir;
    property Font;
  end;

  TMenuVideoWindow = class(TPopupMenuEx<TVideoWindow>)
  end;

implementation

uses System.Types;

resourcestring
  RsPlay = 'Play';
  RsStop = 'Stop';
  RsStopRecord = 'Stop record';
  RsStartRecord = 'Start record';
  RsErrCaptureDirectory = 'Capture directory is not specified';

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
  FPlayHandle := -1;
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
begin
  FMenu := TMenuVideoWindow.Create(Self);
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
  StopSaveRealData;
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
  // if not NET_DVR_RigisterDrawFun(FRealHandle, DrawFun, FId) then
  // RaiseLastHVError;
  // FPlayHandle :=  NET_DVR_GetPlayBackPlayerIndex(FRealHandle);
  // if FPlayHandle < 0 then
  // RaiseLastHVError;

  FTextPanel.Enabled := True;
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

procedure TVideoWindow.CapturePicture;
var
  LFileName: string;
begin
  if FCaptureDir = '' then
    raise Exception.Create(RsErrCaptureDirectory);

  LFileName := Format('%s%s_%s.jpg', [IncludeTrailingPathDelimiter(FCaptureDir),
    'Picture', FormatDateTime('yyyy.mm.dd_hh.mm.ss', Now)]) + #0;
  if not NET_DVR_SetCapturePictureMode(1) then
    RaiseLastHVError;
  if not NET_DVR_CapturePicture(FRealHandle, PAnsiChar(AnsiString(LFileName)))
  then
    RaiseLastHVError;
end;

procedure TVideoWindow.StartSaveRealData;
var
  LFileName: string;
begin
  StopSaveRealData;
  if FCaptureDir = '' then
    raise Exception.Create(RsErrCaptureDirectory);

  LFileName := Format('%s%s_%s.mp4', [IncludeTrailingPathDelimiter(FCaptureDir),
    'Video', FormatDateTime('yyyy.mm.dd_hh.mm.ss', Now)]) + #0;
  if not NET_DVR_MakeKeyFrame(FUserID, FChannel) then
    RaiseLastHVError;

  FRecord := NET_DVR_SaveRealData(FRealHandle,
    PAnsiChar(AnsiString(LFileName)));
  if not FRecord then
    RaiseLastHVError;
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
  FPlayHandle := -1;
  Invalidate;
end;

procedure TVideoWindow.StopSaveRealData;
begin
  if not FRecord then
    Exit;
  NET_DVR_StopSaveRealData(FRealHandle);
  FRecord := False;
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

{ TVideoWindow.TMenuVideoWindow }

constructor TVideoWindow.TMenuVideoWindow.Create(AOwner: TVideoWindow);
begin
  inherited Create(AOwner);

  PlayStop := AddItem('', OnClickPlayStop);
  Capture := AddItem('Capture picture', OnClickCapture);
  StartStopRecord := AddItem('', OnClickStartStopRecord);
  SendEvent := AddItem('Send event', OnSendEvent);

  Items.Add(NewLine);

  Channel := AddItem('Channel', nil);
  AddSubItems(Channel, 1, 16,
    procedure(I: Integer; out ACaption: string; out AValue: Integer)
    begin
      AValue := I;
      ACaption := IntToStr(I);
    end, OnClickChannel);

  ShowTextPanel := AddItem('Show text panel', OnClickShowTextPanel);
end;

//
procedure TVideoWindow.TMenuVideoWindow.UpdateItems(Sender: TObject);
var
  I: Integer;
begin
  for I := 1 to Channel.Count do
    Channel.Items[I - 1].Checked := FObj.FChannel = Channel.Items[I - 1].Tag;

  if FObj.IsPlaying then
    PlayStop.Caption := RsStop
  else
    PlayStop.Caption := RsPlay;

  if FObj.FRecord then
    StartStopRecord.Caption := RsStopRecord
  else
    StartStopRecord.Caption := RsStartRecord;

  Capture.Enabled := FObj.IsPlaying;

  ShowTextPanel.Checked := FObj.TextPanel.Used;
end;

procedure TVideoWindow.TMenuVideoWindow.OnClickPlayStop(Sender: TObject);
begin
  if FObj.IsPlaying then
    FObj.StopLiveVideo
  else
    FObj.PlayLiveVideo;
end;

procedure TVideoWindow.TMenuVideoWindow.OnClickCapture(Sender: TObject);
begin
  FObj.CapturePicture;
end;

procedure TVideoWindow.TMenuVideoWindow.OnClickChannel(Sender: TObject);
begin
  FObj.Channel := TMenuItem(Sender).Tag;
end;

procedure TVideoWindow.TMenuVideoWindow.OnClickShowTextPanel(Sender: TObject);
begin
  FObj.TextPanel.Used := not FObj.TextPanel.Used;
end;

procedure TVideoWindow.TMenuVideoWindow.OnClickStartStopRecord(Sender: TObject);
begin
  if FObj.FRecord then
    FObj.StopSaveRealData
  else
    FObj.StartSaveRealData;
end;

procedure TVideoWindow.TMenuVideoWindow.OnSendEvent(Sender: TObject);
begin
  if Assigned(FObj.Parent) then
    SendMessage(FObj.Parent.Handle, WM_CUSTOMEVENT, FObj.Handle, 0);
end;

end.
