program VideoPanelTest;

uses
  Vcl.Forms,
  ufmMainForm in 'ufmMainForm.pas' {frmMainForm},
  uCHCNetSDK in '..\..\common\uCHCNetSDK.pas',
  uVideoWindow in '..\..\common\uVideoWindow.pas',
  uVideoPanel in '..\..\common\uVideoPanel.pas',
  uHikvisionErrors in '..\..\common\uHikvisionErrors.pas',
  uAlphaWindow in '..\..\common\uAlphaWindow.pas',
  uCommonTypes in '..\..\common\uCommonTypes.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMainForm, frmMainForm);
  Application.Run;
end.
