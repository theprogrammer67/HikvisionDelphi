program VideoPanelTest;

uses
  Vcl.Forms,
  ufmMainForm in 'ufmMainForm.pas' {frmMainForm},
  uCHCNetSDK in '..\..\common\uCHCNetSDK.pas',
  uVideoWindow in '..\..\common\uVideoWindow.pas',
  uVideoPanel in '..\..\common\uVideoPanel.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMainForm, frmMainForm);
  Application.Run;
end.
