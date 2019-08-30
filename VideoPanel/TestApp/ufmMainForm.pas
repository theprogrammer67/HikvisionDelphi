unit ufmMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, uVideoPanel,
  uCHCNetSDK, uHikvisionErrors,
  Vcl.AppEvnts, Vcl.ComCtrls, uVideoWindow;

type
  TfrmMainForm = class(TForm)
    pnlControls: TPanel;
    pnlVideo: TPanel;
    btnPlayStop: TButton;
    appev1: TApplicationEvents;
    cbbMode: TComboBox;
    pgcPages: TPageControl;
    tsVideo: TTabSheet;
    tsSettings: TTabSheet;
    lbledtAddress: TLabeledEdit;
    lbledtPort: TLabeledEdit;
    lbledtUser: TLabeledEdit;
    lbledtPassword: TLabeledEdit;
    grpWindow: TGroupBox;
    cbbWIndow: TComboBox;
    btnApply: TButton;
    lbledtChannel: TLabeledEdit;
    mmoText: TMemo;
    chkPrintText: TCheckBox;
    chkVisible: TCheckBox;
    chkEnable: TCheckBox;
    btnAuthorize: TButton;
    Button1: TButton;
    procedure appev1Idle(Sender: TObject; var Done: Boolean);
    procedure btn2Click(Sender: TObject);
    procedure btn3Click(Sender: TObject);
    procedure btn4Click(Sender: TObject);
    procedure btnApplyClick(Sender: TObject);
    procedure btnAuthorizeClick(Sender: TObject);
    procedure btnPlayStopClick(Sender: TObject);
    procedure cbbModeChange(Sender: TObject);
    procedure cbbWIndowChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure tsSettingsShow(Sender: TObject);
  private
    FVideoPanel: TVideoPanel;
  private
    procedure Authorize;
    procedure Play;
    procedure Stop;
    procedure UpdateWindowControls;
    procedure UpdateWindowSettings;
  private
    procedure OnLoseParentWindow(ASender: TObject);
  public
    { Public declarations }
  end;

var
  frmMainForm: TfrmMainForm;

implementation

{$R *.dfm}

procedure TfrmMainForm.appev1Idle(Sender: TObject; var Done: Boolean);
begin
  if not Assigned(FVideoPanel) then
  begin
    btnPlayStop.Enabled := False;
    Exit;
  end;

  if FVideoPanel.VideoWindows[0].IsPlaying then
    btnPlayStop.Caption := 'Stop'
  else
    btnPlayStop.Caption := 'Play';
end;

procedure TfrmMainForm.Authorize;
var
  LDeviceInfo: NET_DVR_DEVICEINFO_V30;
begin
  FVideoPanel.StopAll;

  ZeroMemory(@LDeviceInfo, SizeOf(LDeviceInfo));
  FVideoPanel.UserID := NET_DVR_Login_V30
    (PAnsiChar(AnsiString(lbledtAddress.Text)), StrToInt(lbledtPort.Text),
    PAnsiChar(AnsiString(lbledtUser.Text)),
    PAnsiChar(AnsiString(lbledtPassword.Text)), LDeviceInfo);
  if FVideoPanel.UserID < 0 then
    RaiseLastHVError;
end;

procedure TfrmMainForm.btn2Click(Sender: TObject);
begin
  FVideoPanel.PanelMode := pm22;
end;

procedure TfrmMainForm.btn3Click(Sender: TObject);
begin
  FVideoPanel.PanelMode := pm44;
end;

procedure TfrmMainForm.btn4Click(Sender: TObject);
begin
  FVideoPanel.PanelMode := pmSingle;
end;

procedure TfrmMainForm.btnApplyClick(Sender: TObject);
begin
  UpdateWindowSettings;
end;

procedure TfrmMainForm.btnAuthorizeClick(Sender: TObject);
begin
  Authorize;
end;

procedure TfrmMainForm.btnPlayStopClick(Sender: TObject);
begin
  if FVideoPanel.VideoWindows[0].IsPlaying then
    Stop
  else
    Play;
end;

procedure TfrmMainForm.cbbModeChange(Sender: TObject);
begin
  FVideoPanel.PanelMode := TPanelMode(cbbMode.ItemIndex);
end;

procedure TfrmMainForm.cbbWIndowChange(Sender: TObject);
begin
  UpdateWindowControls;
end;

procedure TfrmMainForm.FormDestroy(Sender: TObject);
begin
  NET_DVR_Cleanup;
  FreeAndNil(FVideoPanel);
end;

procedure TfrmMainForm.FormCreate(Sender: TObject);
begin
//  FVideoPanel := TVideoPanel.Create(0); // "Отвязанная" панель
  FVideoPanel := TVideoPanel.Create(pnlVideo.Handle); // "Привязанная" панель
  FVideoPanel.OnLoseParentWindow := OnLoseParentWindow;

  pgcPages.ActivePage := tsVideo;
  NET_DVR_Init;
end;

procedure TfrmMainForm.FormShow(Sender: TObject);
begin
  FVideoPanel.Show;
end;

procedure TfrmMainForm.OnLoseParentWindow(ASender: TObject);
begin
  FreeAndNil(FVideoPanel);
end;

procedure TfrmMainForm.Play;
begin
  FVideoPanel.StopAll;

  Screen.Cursor := crHourGlass;
  try
    FVideoPanel.PlayAll;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TfrmMainForm.Stop;
begin
  FVideoPanel.StopAll;
end;

procedure TfrmMainForm.tsSettingsShow(Sender: TObject);
begin
  UpdateWindowControls;
end;

procedure TfrmMainForm.UpdateWindowControls;
var
  LVideoWindow: TVideoWindow;
begin
  LVideoWindow := FVideoPanel.VideoWindows[cbbWIndow.ItemIndex];
  lbledtChannel.Text := IntToStr(LVideoWindow.Channel);
  chkPrintText.Checked := LVideoWindow.PrintOverlayText;
  chkEnable.Checked := LVideoWindow.Enabled;
  chkVisible.Checked := LVideoWindow.Visible;
end;

procedure TfrmMainForm.UpdateWindowSettings;
var
  LVideoWindow: TVideoWindow;
begin
  LVideoWindow := FVideoPanel.VideoWindows[cbbWIndow.ItemIndex];

  LVideoWindow.Channel := StrToInt(lbledtChannel.Text);
  LVideoWindow.PrintOverlayText := chkPrintText.Checked;
  LVideoWindow.Enabled := chkEnable.Checked;
  LVideoWindow.Visible := chkVisible.Checked;
  LVideoWindow.OverlayText := mmoText.Text;
end;

end.
