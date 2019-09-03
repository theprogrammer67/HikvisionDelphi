unit uVideoDevice;

interface

uses uCHCNetSDK, uHikvisionErrors, uVideoPanel, uVideoWindow, Winapi.Windows,
  System.SysUtils, uCommonUtils;

type
  TVideoDevice = class
  private
    FLibHandle: THandle;
    FVideoPanel: TVideoPanel;
    FEnabled: Boolean;
    FParentWnd: HWND;
    FPort: Integer;
    FPassword: string;
    FAddress: string;
    FLogin: string;
  private
    procedure Authorize;
    procedure SetEnabled(const Value: Boolean);
    procedure LoadDLL;
    procedure UnloadDLL;
  public
    constructor Create;
    destructor Destroy; override;
  public
    procedure Enable;
    procedure Disable;
  public
    property ParentWnd: HWND read FParentWnd write FParentWnd;
    property Enabled: Boolean read FEnabled write SetEnabled;
    property VideoPanel: TVideoPanel read FVideoPanel write FVideoPanel;
    property Address: string read FAddress write FAddress;
    property Port: Integer read FPort write FPort;
    property Login: string read FLogin write FLogin;
    property Password: string read FPassword write FPassword;
  end;

implementation

resourcestring
  RsErrEmptyAddress = 'IP addres is empty';
  RsErrUserEmpty = 'User name is empty';

  { TVideoDevice }

procedure TVideoDevice.Authorize;
var
  LDeviceInfo: NET_DVR_DEVICEINFO_V30;
begin
  if FAddress = '' then
    raise Exception.Create(RsErrEmptyAddress);
  if FLogin = '' then
    raise Exception.Create(RsErrUserEmpty);

  FVideoPanel.StopAll;

  ZeroMemory(@LDeviceInfo, SizeOf(LDeviceInfo));
  FVideoPanel.UserID := NET_DVR_Login_V30(PAnsiChar(AnsiString(FAddress)),
    FPort, PAnsiChar(AnsiString(FLogin)), PAnsiChar(AnsiString(FPassword)),
    LDeviceInfo);
  if FVideoPanel.UserID < 0 then
    RaiseLastHVError;
end;

constructor TVideoDevice.Create;
begin
  FPort := 8000;
  FLibHandle := 0;
end;

destructor TVideoDevice.Destroy;
begin
  Disable;
  inherited;
end;

procedure TVideoDevice.Disable;
begin
  if not FEnabled then
    Exit;
  FEnabled := False;

  if Assigned(FVideoPanel) then
  begin
    FVideoPanel.StopAll;
    if FVideoPanel.UserID >= 0 then
      NET_DVR_Logout(FVideoPanel.UserID);
    FVideoPanel.OnLoseParentWindow := nil;
  end;
  FreeAndNil(FVideoPanel);
  NET_DVR_Cleanup;

  UnloadDLL;
end;

procedure TVideoDevice.Enable;
begin
  Disable;
  LoadDLL;

  try
    NET_DVR_Init;
    FVideoPanel := TVideoPanel.Create(FParentWnd);
    Authorize;
    FVideoPanel.Show;

    FEnabled := True;
  except
    Disable;
    raise;
  end;
end;

procedure TVideoDevice.LoadDLL;
var
  OldCurrentDir: string;
begin
  OldCurrentDir := GetCurrentDir;
  SetCurrentDir(GetModuleDirectory);

  // Берем dll из локальной папки! 1С меняет временную директорию
  try
    LoadLib(FLibHandle, GetModuleDirectory);
  finally
    SetCurrentDir(OldCurrentDir);
  end;
end;

procedure TVideoDevice.SetEnabled(const Value: Boolean);
begin
  Enable;
end;

procedure TVideoDevice.UnloadDLL;
begin
  FreeLib(FLibHandle);
end;

end.
