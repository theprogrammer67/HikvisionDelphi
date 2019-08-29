program VideoDeviceTest;

uses
  Vcl.Forms,
  ufmMainForm in 'ufmMainForm.pas' {frmMainForm},
  uCHCNetSDK in '..\..\common\uCHCNetSDK.pas',
  uHikvisionErrors in '..\..\common\uHikvisionErrors.pas',
  uVideoPanel in '..\..\common\uVideoPanel.pas',
  uVideoWindow in '..\..\common\uVideoWindow.pas',
  uVideoDevice in '..\uVideoDevice.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMainForm, frmMainForm);
  Application.Run;
end.
