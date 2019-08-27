unit ufmMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, uVideoPanel;

type
  TfrmMainForm = class(TForm)
    pnlControls: TPanel;
    pnlVideo: TPanel;
    btnSIngle: TButton;
    btnMulti: TButton;
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FVideoPanel: TVideoPanel;
  public
    { Public declarations }
  end;

var
  frmMainForm: TfrmMainForm;

implementation

{$R *.dfm}

procedure TfrmMainForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FVideoPanel);
end;

procedure TfrmMainForm.FormCreate(Sender: TObject);
begin
  FVideoPanel := TVideoPanel.Create(pnlVideo.Handle);
end;

procedure TfrmMainForm.FormShow(Sender: TObject);
begin
//  FVideoPanel.ShowPanel;
end;

end.
