unit ufmMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, uVideoDevice;

type
  TfrmMainForm = class(TForm)
    pnlBottom: TPanel;
    pnlRight: TPanel;
    pnlVideo: TPanel;
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

procedure TfrmMainForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FVideoDevice);
end;

procedure TfrmMainForm.FormCreate(Sender: TObject);
begin
  FVideoDevice := TVideoDevice.Create;
end;

end.
