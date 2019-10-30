program VideoWindowTest;

uses
  Vcl.Forms,
  ufmMainForm in 'ufmMainForm.pas' {frmMainForm},
  uCHCNetSDK in '..\..\common\uCHCNetSDK.pas',
  uHikvisionErrors in '..\..\common\uHikvisionErrors.pas',
  uVideoWindow in '..\..\common\uVideoWindow.pas',
  uAlphaWindow in '..\..\common\uAlphaWindow.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMainForm, frmMainForm);
  Application.Run;
end.
