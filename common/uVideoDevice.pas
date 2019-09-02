unit uVideoDevice;

interface

uses uCHCNetSDK, uHikvisionErrors, uVideoPanel, uVideoWindow, Winapi.Windows,
  System.SysUtils;

type
  TVideoDevice = class
  private
    FVideoPanel: TVideoPanel;
    FEnabled: Boolean;
    FParentWnd: HWND;
  private
    FPort: Integer;
    FPassword: string;
    FAddress: string;
    FLogin: string;
    procedure Authorize;
    procedure SetEnabled(const Value: Boolean);
  public
    constructor Create;
    destructor Destroy; override;
  public
    procedure Enable;
    procedure Disable;
  public
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
end;

destructor TVideoDevice.Destroy;
begin
  Disable;
  inherited;
end;

procedure TVideoDevice.Disable;
begin
  FEnabled := False;

  if Assigned(FVideoPanel) then
  begin
    FVideoPanel.StopAll;
    if FVideoPanel.UserID >= 0 then
      NET_DVR_Logout(FVideoPanel.UserID);
  end;
  FreeAndNil(FVideoPanel);
  NET_DVR_Cleanup;
end;

procedure TVideoDevice.Enable;
begin
  Disable;
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

procedure TVideoDevice.SetEnabled(const Value: Boolean);
begin
  Enable;
end;

end.
