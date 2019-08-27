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
    btn1: TButton;
    procedure btn1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FVideoPanel: TVideoPanel;
    procedure OnLoseParentWindow(ASender: TObject);
    procedure OnVideoPanelResize(ASender: TObject);
  public
    { Public declarations }
  end;

var
  frmMainForm: TfrmMainForm;

implementation

{$R *.dfm}

procedure TfrmMainForm.btn1Click(Sender: TObject);
begin
  FreeAndNil(pnlVideo);
end;

procedure TfrmMainForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FVideoPanel);
end;

procedure TfrmMainForm.FormCreate(Sender: TObject);
begin
  FVideoPanel := TVideoPanel.Create(pnlVideo.Handle);
  FVideoPanel.OnResize := OnVideoPanelResize;
end;

procedure TfrmMainForm.OnLoseParentWindow(ASender: TObject);
begin
  FreeAndNil(FVideoPanel);
end;

procedure TfrmMainForm.OnVideoPanelResize(ASender: TObject);
begin
//  ShowMessage('resized');
end;

end.
