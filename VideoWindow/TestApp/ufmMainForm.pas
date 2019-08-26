unit ufmMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, uVideoWindow, uCHCNetSDK,
  Vcl.ExtCtrls, Vcl.AppEvnts;

type
  TfrmMainForm = class(TForm)
    btnPlayStop: TButton;
    lbledtAddress: TLabeledEdit;
    lbledtPort: TLabeledEdit;
    lbledtUser: TLabeledEdit;
    lbledtPassword: TLabeledEdit;
    lbledtChannel: TLabeledEdit;
    appev1: TApplicationEvents;
    btnSetOverlayText: TButton;
    mmoText: TMemo;
    chkPrintText: TCheckBox;
    procedure appev1Idle(Sender: TObject; var Done: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnPlayStopClick(Sender: TObject);
    procedure btnSetOverlayTextClick(Sender: TObject);
    procedure chkPrintTextClick(Sender: TObject);
  private
    FUserID: Integer;
    FVideoWindow: TVideoWindow;
    FSDKInited: Boolean;
  private
    procedure Play;
    procedure Stop;
  public
    { Public declarations }
  end;

var
  frmMainForm: TfrmMainForm;

implementation

uses uHikvisionErrors;

{$R *.dfm}

procedure TfrmMainForm.appev1Idle(Sender: TObject; var Done: Boolean);
begin
  if not Assigned(FVideoWindow) then
    Exit;

  if FVideoWindow.IsPlaying then
    btnPlayStop.Caption := 'Stop'
  else
    btnPlayStop.Caption := 'Play';
end;

procedure TfrmMainForm.FormDestroy(Sender: TObject);
begin
  if FSDKInited then
    NET_DVR_Cleanup;
  FreeAndNil(FVideoWindow);
end;

procedure TfrmMainForm.Play;
var
  LDeviceInfo: NET_DVR_DEVICEINFO_V30;
begin
  Stop;

  FVideoWindow.Channel := StrToInt(lbledtChannel.Text);

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
    RaiseLastHVError;

  FVideoWindow.Play(FUserID);
end;

procedure TfrmMainForm.Stop;
begin
  FVideoWindow.Stop;
  FVideoWindow.Invalidate;
end;

procedure TfrmMainForm.FormCreate(Sender: TObject);
begin
  FVideoWindow := TVideoWindow.Create(self);

  FVideoWindow.Height := 250;
  FVideoWindow.Width := Width;
  FVideoWindow.Left := 0;
  FVideoWindow.Top := 0;

  FSDKInited := False;
end;

procedure TfrmMainForm.btnPlayStopClick(Sender: TObject);
begin
  if not Assigned(FVideoWindow) then
    Exit;

  if FVideoWindow.IsPlaying then
    Stop
  else
    Play;
end;

procedure TfrmMainForm.btnSetOverlayTextClick(Sender: TObject);
begin
  FVideoWindow.OverlayText := mmoText.Text;
  FVideoWindow.PrintOverlayText := chkPrintText.Checked;
end;

procedure TfrmMainForm.chkPrintTextClick(Sender: TObject);
begin
  FVideoWindow.PrintOverlayText := chkPrintText.Checked;
end;

end.
