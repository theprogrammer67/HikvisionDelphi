unit ufmMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, uVideoPanel, uCHCNetSDK, uHikvisionErrors,
  Vcl.AppEvnts;

type
  TfrmMainForm = class(TForm)
    pnlControls: TPanel;
    pnlVideo: TPanel;
    btnRemoveParent: TButton;
    btnPlayStop: TButton;
    appev1: TApplicationEvents;
    cbbMode: TComboBox;
    procedure appev1Idle(Sender: TObject; var Done: Boolean);
    procedure btnRemoveParentClick(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure btn3Click(Sender: TObject);
    procedure btn4Click(Sender: TObject);
    procedure btnPlayStopClick(Sender: TObject);
    procedure cbbModeChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FUserID: Integer;
    FSDKInited: Boolean;
    FVideoPanel: TVideoPanel;
  private
    procedure Play;
    procedure Stop;
  private
    procedure OnLoseParentWindow(ASender: TObject);
    procedure OnVideoPanelResize(ASender: TObject);
  public
    { Public declarations }
  end;

var
  frmMainForm: TfrmMainForm;

implementation

{$R *.dfm}

procedure TfrmMainForm.appev1Idle(Sender: TObject; var Done: Boolean);
begin
  if not Assigned(FVideoPanel) then
  begin
    btnPlayStop.Enabled := False;
    Exit;
  end;

  if  FVideoPanel.VideoWindows[0].IsPlaying then
    btnPlayStop.Caption := 'Stop'
  else
    btnPlayStop.Caption := 'Play';
end;

procedure TfrmMainForm.btnRemoveParentClick(Sender: TObject);
begin
  FreeAndNil(pnlVideo);
end;

procedure TfrmMainForm.btn2Click(Sender: TObject);
begin
  FVideoPanel.PanelMode := pm22;
end;

procedure TfrmMainForm.btn3Click(Sender: TObject);
begin
  FVideoPanel.PanelMode := pm44;
end;

procedure TfrmMainForm.btn4Click(Sender: TObject);
begin
  FVideoPanel.PanelMode := pmSingle;
end;

procedure TfrmMainForm.btnPlayStopClick(Sender: TObject);
begin
  if FVideoPanel.VideoWindows[0].IsPlaying then
    Stop
  else
    Play;
end;

procedure TfrmMainForm.cbbModeChange(Sender: TObject);
begin
  FVideoPanel.PanelMode := TPanelMode(cbbMode.ItemIndex);
end;

procedure TfrmMainForm.FormDestroy(Sender: TObject);
begin
  if FSDKInited then
    NET_DVR_Cleanup;
  FreeAndNil(FVideoPanel);
end;

procedure TfrmMainForm.FormCreate(Sender: TObject);
begin
  FSDKInited := False;
  FVideoPanel := TVideoPanel.Create(pnlVideo.Handle);
  FVideoPanel.OnResize := OnVideoPanelResize;
  FVideoPanel.OnLoseParentWindow := OnLoseParentWindow;
end;

procedure TfrmMainForm.OnLoseParentWindow(ASender: TObject);
begin
  FreeAndNil(FVideoPanel);
end;

procedure TfrmMainForm.OnVideoPanelResize(ASender: TObject);
begin
//  ShowMessage('resized');
end;

procedure TfrmMainForm.Play;
var
  LDeviceInfo: NET_DVR_DEVICEINFO_V30;
begin
  Stop;

  FVideoPanel.VideoWindows[0].Channel := 2;
  FVideoPanel.VideoWindows[1].Channel := 3;

  if not FSDKInited then
  begin
    FSDKInited := NET_DVR_Init;
    if not FSDKInited then
      raise Exception.Create('NET_DVR_Init error!');
  end;

  ZeroMemory(@LDeviceInfo, SizeOf(LDeviceInfo));
  FUserID := NET_DVR_Login_V30(PAnsiChar(AnsiString('172.20.162.43')),
    8000, PAnsiChar(AnsiString('admin')),
    PAnsiChar(AnsiString('admin12345')), LDeviceInfo);
  if FUserID < 0 then
    RaiseLastHVError;

  FVideoPanel.VideoWindows[0].Play(FUserID);
  FVideoPanel.VideoWindows[1].Play(FUserID);
end;

procedure TfrmMainForm.Stop;
begin
  FVideoPanel.VideoWindows[0].Stop;
  FVideoPanel.VideoWindows[1].Stop;
  FVideoPanel.VideoWindows[0].Invalidate;
  FVideoPanel.VideoWindows[1].Invalidate;
end;

end.
