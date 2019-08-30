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
  public
    constructor Create;
    destructor Destroy; override;
  public
    procedure Enable;
    procedure Disable;
  public
    property ParentWnd: HWND read FParentWnd write FParentWnd;
    property Enabled: Boolean read FEnabled write FEnabled;
    property VideoPanel: TVideoPanel read FVideoPanel write FVideoPanel;
  end;

implementation

{ TVideoDevice }

constructor TVideoDevice.Create;
begin
end;

destructor TVideoDevice.Destroy;
begin
  Disable;
  inherited;
end;

procedure TVideoDevice.Disable;
begin
  if Assigned(FVideoPanel) then
    FVideoPanel.StopAll;
  FreeAndNil(FVideoPanel);
end;

procedure TVideoDevice.Enable;
begin
  Disable;
  FVideoPanel := TVideoPanel.Create(FParentWnd);
end;

end.
