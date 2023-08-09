unit ufmMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, uVideoDevice,
  Vcl.StdCtrls, uVideoPanel, uVideoWindow, Vcl.AppEvnts;

type
  TfrmMainForm = class(TForm)
    pnlBottom: TPanel;
    pnlRight: TPanel;
    pnlVideo: TPanel;
    btnEnable: TButton;
    btnDisable: TButton;
    chkBuiltin: TCheckBox;
    cbbMode: TComboBox;
    lbledtAddress: TLabeledEdit;
    lbledtPort: TLabeledEdit;
    lbledtUser: TLabeledEdit;
    lbledtPassword: TLabeledEdit;
    cbbWIndow: TComboBox;
    lbledtChannel: TLabeledEdit;
    chkPrintText: TCheckBox;
    chkVisible: TCheckBox;
    chkEnable: TCheckBox;
    mmoText: TMemo;
    btnApply: TButton;
    appev1: TApplicationEvents;
    btnPlayAll: TButton;
    btnStopAll: TButton;
    btnEnableWindows: TButton;
    btnDisableWindows: TButton;
    procedure appev1Idle(Sender: TObject; var Done: Boolean);
    procedure btnApplyClick(Sender: TObject);
    procedure btnDisableClick(Sender: TObject);
    procedure btnDisableWindowsClick(Sender: TObject);
    procedure btnEnableClick(Sender: TObject);
    procedure btnEnableWindowsClick(Sender: TObject);
    procedure btnPlayAllClick(Sender: TObject);
    procedure btnStopAllClick(Sender: TObject);
    procedure cbbModeChange(Sender: TObject);
    procedure cbbWIndowChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FVideoDevice: TVideoDevice;
  private
    procedure UpdateWindowControls;
    procedure UpdateWindowSettings;
  public
    { Public declarations }
  end;

var
  frmMainForm: TfrmMainForm;

implementation

{$R *.dfm}

procedure TfrmMainForm.appev1Idle(Sender: TObject; var Done: Boolean);
begin
  pnlRight.Enabled := FVideoDevice.Enabled;
  btnPlayAll.Enabled := FVideoDevice.Enabled;
  btnStopAll.Enabled := FVideoDevice.Enabled;
  btnEnableWindows.Enabled := FVideoDevice.Enabled;
  btnDisableWindows.Enabled := FVideoDevice.Enabled;
end;

procedure TfrmMainForm.btnApplyClick(Sender: TObject);
begin
  UpdateWindowSettings;
end;

procedure TfrmMainForm.btnDisableClick(Sender: TObject);
begin
  FVideoDevice.Disable;
end;

procedure TfrmMainForm.btnDisableWindowsClick(Sender: TObject);
begin
  FVideoDevice.VideoPanel.EnableAll(False);
  UpdateWindowControls;
end;

procedure TfrmMainForm.btnEnableClick(Sender: TObject);
begin
  if chkBuiltin.Checked then
    FVideoDevice.ParentWnd := pnlVideo.Handle
  else
    FVideoDevice.ParentWnd := 0;

  FVideoDevice.Address := lbledtAddress.Text;
  FVideoDevice.Port := StrToInt(lbledtPort.Text);
  FVideoDevice.Login := lbledtUser.Text;
  FVideoDevice.Password := lbledtPassword.Text;
  FVideoDevice.Enable;
  FVideoDevice.VideoPanel.PanelMode := TPanelMode(cbbMode.ItemIndex);

  UpdateWindowControls;
end;

procedure TfrmMainForm.btnEnableWindowsClick(Sender: TObject);
begin
  FVideoDevice.VideoPanel.EnableAll(True);
  UpdateWindowControls;
end;

procedure TfrmMainForm.btnPlayAllClick(Sender: TObject);
begin
  FVideoDevice.VideoPanel.PlayAll(True);
end;

procedure TfrmMainForm.btnStopAllClick(Sender: TObject);
begin
  FVideoDevice.VideoPanel.PlayAll(False);
end;

procedure TfrmMainForm.cbbModeChange(Sender: TObject);
begin
  if Assigned(FVideoDevice.VideoPanel) then
    FVideoDevice.VideoPanel.PanelMode := TPanelMode(cbbMode.ItemIndex);
end;

procedure TfrmMainForm.cbbWIndowChange(Sender: TObject);
begin
  UpdateWindowControls;
end;

procedure TfrmMainForm.FormDestroy(Sender: TObject);
begin
  FVideoDevice.Disable;
  FreeAndNil(FVideoDevice);
end;

procedure TfrmMainForm.UpdateWindowControls;
var
  LVideoWindow: TVideoWindow;
begin
  LVideoWindow := FVideoDevice.VideoPanel.VideoWindows[cbbWIndow.ItemIndex];

  lbledtChannel.Text := IntToStr(LVideoWindow.Channel);
//  chkPrintText.Checked := LVideoWindow.ShowOverlayText;
  chkEnable.Checked := LVideoWindow.Enabled;
  chkVisible.Checked := LVideoWindow.Visible;
end;

procedure TfrmMainForm.UpdateWindowSettings;
var
  LVideoWindow: TVideoWindow;
begin
  LVideoWindow := FVideoDevice.VideoPanel.VideoWindows[cbbWIndow.ItemIndex];

  LVideoWindow.Channel := StrToInt(lbledtChannel.Text);
//  LVideoWindow.ShowOverlayText := chkPrintText.Checked;
  LVideoWindow.Enabled := chkEnable.Checked;
  LVideoWindow.Visible := chkVisible.Checked;
//  LVideoWindow.OverlayText := mmoText.Text;
  LVideoWindow.Invalidate;
end;

procedure TfrmMainForm.FormCreate(Sender: TObject);
begin
  FVideoDevice := TVideoDevice.Create;
end;

end.
