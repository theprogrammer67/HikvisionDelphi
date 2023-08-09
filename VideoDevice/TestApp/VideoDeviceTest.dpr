program VideoDeviceTest;

uses
  Vcl.Forms,
  ufmMainForm in 'ufmMainForm.pas' {frmMainForm},
  uCHCNetSDK in '..\..\common\uCHCNetSDK.pas',
  uHikvisionErrors in '..\..\common\uHikvisionErrors.pas',
  uVideoPanel in '..\..\common\uVideoPanel.pas',
  uVideoWindow in '..\..\common\uVideoWindow.pas',
  uVideoDevice in '..\..\common\uVideoDevice.pas',
  uAlphaWindow in '..\..\common\uAlphaWindow.pas',
  uCommonTypes in '..\..\common\uCommonTypes.pas',
  uCommonUtils in '..\..\common\uCommonUtils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMainForm, frmMainForm);
  Application.Run;
end.
