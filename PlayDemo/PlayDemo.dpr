program PlayDemo;

uses
  Vcl.Forms,
  ufmMainForm in 'ufmMainForm.pas' {Form1},
  uCHCNetSDK in 'uCHCNetSDK.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
