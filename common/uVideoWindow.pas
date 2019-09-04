unit uVideoWindow;

interface

uses uCHCNetSDK, Vcl.Controls, Winapi.Windows, uHikvisionErrors, System.Classes,
  Vcl.Graphics, System.SysUtils, System.Generics.Collections, Vcl.Menus,
  Vcl.Forms, Winapi.Messages;

const
  WM_PLAYVIDEO = WM_USER + 0;
  WM_STOPVIDEO = WM_USER + 1;

type
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
  private const
    CAPTION_DISABLED: string = 'DISABLED';
    CAPTION_STOPPED: string = 'VIDEO STOPPED';
    DEF_COLOR = clNavy;
    ERROR_FONTCOLOR = clYellow;
    ERROR_FONTSIZE = 10;
    STATUS_FONTCOLOR = $00FF96A0;
    STATUS_FONTNAME = 'Impact';
    STATUS_FONTSIZE = 24;
    DEF_FONTNAME = 'Courier New';
    DEF_FONTSIZE = 24;
    DEF_FONTCOLOR = clLime;
  private
    // FParentForm: TForm;
    FChannel: Integer;
    FUserID: Integer;
    FRealHandle: Integer;
    FOverlayText: string;
    FShowOverlayText: Boolean;
    FPopup: TPopupMenu;
    FMenuItemChannel: TMenuItem;
    FMenuItemPrintOverlayText: TMenuItem;
    FMenuItemPalyStop: TMenuItem;
    FLastErrorDecription: string;
  private
    class var FObjects: TThreadList<TVideoWindow>;
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
    procedure OnPlayVideoMessage(var Msg: TMessage); message WM_PLAYVIDEO;
    procedure OnStopVideoMessage(var Msg: TMessage); message WM_STOPVIDEO;
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
  protected
    procedure Paint; override;
  public
    constructor Create(AParent: TWinControl); reintroduce;
    destructor Destroy; override;
  public
    procedure PlayLiveVideo;
    procedure StopLiveVideo;
  public
    property Channel: Integer read FChannel write SetChannel;
    property OverlayText: string read FOverlayText write FOverlayText;
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
  Enabled := False;
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
end;

destructor TVideoWindow.Destroy;
begin
  StopLiveVideo;
  UnRegisterObj;
  FreeAndNil(FPopup);
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
      if LObj.FRealHandle = lRealHandle then
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
var
  LObj: HGDIOBJ;
  LHFont: HFONT;
  LRect: TRect;
begin
  if (not FShowOverlayText) or (Length(OverlayText) = 0) or (not Visible) or
    (not Enabled) then
    Exit;

  LHFont := CreateFont(Font.Size, 0, 0, 0, FW_NORMAL, 0, 0, 0, 0, 0, 0, 2, 0,
    PWideChar(Font.Name));
  LObj := SelectObject(hDc, LHFont);
  try
    SetBkMode(hDc, TRANSPARENT);
    SetTextColor(hDc, Font.Color);
    LRect := Rect(0, 0, Width, Height);
    DrawText(hDc, PWideChar(OverlayText), Length(OverlayText), LRect,
      DT_LEFT or DT_TOP);
  finally
    DeleteObject(SelectObject(hDc, LObj));
  end;
end;

function TVideoWindow.GetIsPlaying: Boolean;
begin
  Result := FRealHandle >= 0;
end;

procedure TVideoWindow.OnPlayVideoMessage(var Msg: TMessage);
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

procedure TVideoWindow.OnStopVideoMessage(var Msg: TMessage);
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
  if not NET_DVR_RigisterDrawFun(FRealHandle, DrawFun, 0) then
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

  if not Enabled then
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

end.
