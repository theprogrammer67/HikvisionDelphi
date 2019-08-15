unit ufmMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, uCHCNetSDK;

type
  TForm1 = class(TForm)
    pnlPictureBox: TPanel;
    lbledtAddress: TLabeledEdit;
    lbledtPort: TLabeledEdit;
    lbledtUser: TLabeledEdit;
    lbledtPassword: TLabeledEdit;
    btnPlay: TButton;
    btnStop: TButton;
    lbledtChannel: TLabeledEdit;
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnPlayClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
  private
    FUserID: Integer;
    FSDKInited: Boolean;
    FRealHandle: Integer;
  private
    procedure StopVideo;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormDestroy(Sender: TObject);
begin
  StopVideo;
  if FSDKInited then
    NET_DVR_Cleanup;
end;

procedure TForm1.StopVideo;
begin
  if FRealHandle >= 0 then
  begin
    NET_DVR_StopRealPlay(FRealHandle);
    FRealHandle := -1;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  FSDKInited := False;
  FRealHandle := -1;
end;

procedure TForm1.btnPlayClick(Sender: TObject);
var
  LDeviceInfo: NET_DVR_DEVICEINFO_V30;
  LPreviewInfo: NET_DVR_PREVIEWINFO;
begin
  StopVideo;

  if not FSDKInited then
  begin
    FSDKInited := NET_DVR_Init;
    if not FSDKInited then
      raise Exception.Create('NET_DVR_Init error!');
  end;

  ZeroMemory(@LDeviceInfo, SizeOf(LDeviceInfo));
  FUserID := NET_DVR_Login_V30(PAnsiChar(AnsiString(lbledtAddress.Text)),
    StrToInt(lbledtPort.Text), PAnsiChar(AnsiString(lbledtUser.Text)),
    PAnsiChar(AnsiString(lbledtPassword.Text)), LDeviceInfo);
  if FUserID < 0 then
    raise Exception.Create('NET_DVR_Login_V30 failed, error code= ' +
      IntToStr(NET_DVR_GetLastError));

  ZeroMemory(@LPreviewInfo, SizeOf(LPreviewInfo));
  LPreviewInfo.hPlayWnd := pnlPictureBox.Handle;
  LPreviewInfo.lChannel := StrToInt(lbledtChannel.Text);
  LPreviewInfo.dwStreamType := 0;
  LPreviewInfo.dwLinkMode := 0;
  LPreviewInfo.bBlocked := true;
  LPreviewInfo.dwDisplayBufNum := 1;
  LPreviewInfo.byProtoType := 0;
  LPreviewInfo.byPreviewMode := 0;

  FRealHandle := NET_DVR_RealPlay_V40(FUserID, LPreviewInfo, nil, 0);
  if FRealHandle < 0 then
    raise Exception.Create('NET_DVR_RealPlay_V40 failed, error code= ' +
      IntToStr(NET_DVR_GetLastError));
end;

procedure TForm1.btnStopClick(Sender: TObject);
begin
  StopVideo;
end;

end.
