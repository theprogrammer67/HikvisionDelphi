unit ufmMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, uVideoDevice,
  Vcl.StdCtrls, uVideoPanel;

type
  TfrmMainForm = class(TForm)
    pnlBottom: TPanel;
    pnlRight: TPanel;
    pnlVideo: TPanel;
    btnEnable: TButton;
    btnDisable: TButton;
    chkBuiltin: TCheckBox;
    cbbMode: TComboBox;
    procedure btnDisableClick(Sender: TObject);
    procedure btnEnableClick(Sender: TObject);
    procedure cbbModeChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FVideoDevice: TVideoDevice;
  public
    { Public declarations }
  end;

var
  frmMainForm: TfrmMainForm;

implementation

{$R *.dfm}

procedure TfrmMainForm.btnDisableClick(Sender: TObject);
begin
  FVideoDevice.Disable;
end;

procedure TfrmMainForm.btnEnableClick(Sender: TObject);
begin
  if chkBuiltin.Checked then
    FVideoDevice.ParentWnd := pnlVideo.Handle
  else
    FVideoDevice.ParentWnd := 0;

  FVideoDevice.Enable;
  FVideoDevice.VideoPanel.PanelMode := TPanelMode(cbbMode.ItemIndex);
end;

procedure TfrmMainForm.cbbModeChange(Sender: TObject);
begin
  if Assigned(FVideoDevice.VideoPanel) then
    FVideoDevice.VideoPanel.PanelMode := TPanelMode(cbbMode.ItemIndex);
end;

procedure TfrmMainForm.FormDestroy(Sender: TObject);
begin
  FVideoDevice.Disable;
  FreeAndNil(FVideoDevice);
end;

procedure TfrmMainForm.FormCreate(Sender: TObject);
begin
  FVideoDevice := TVideoDevice.Create;
end;

end.
