unit uVideoDevice;

interface

uses uCHCNetSDK, uHikvisionErrors, uVideoPanel, uVideoWindow;

type
  TVideoDevice = class
  private
    FVideoPanel: TVideoPanel;
    FEnabled: Boolean;
  public
    constructor Create;
    destructor Destroy; override;
  public
    procedure Enable;
    procedure Disable;
  public
    property Enabled: Boolean read FEnabled write FEnabled;
    property VideoPanel: TVideoPanel read FVideoPanel write FVideoPanel;
  end;

implementation

{ TVideoDevice }

constructor TVideoDevice.Create;
begin
  FVideoPanel
end;

destructor TVideoDevice.Destroy;
begin

  inherited;
end;

procedure TVideoDevice.Disable;
begin

end;

procedure TVideoDevice.Enable;
begin

end;

end.
