unit uVideoWindow;

interface

uses uCHCNetSDK, Vcl.Controls, Winapi.Windows, uHikvisionErrors, System.Classes,
  Vcl.Graphics, System.SysUtils;

type
  TVideoWindow = class(TCustomControl)
  private
    FChannel: Integer;
    FRealHandle: Integer;
    FOverlayText: string;
    function GetIsPlaying: Boolean;
  public
    constructor Create(AParent: TWinControl); reintroduce;
    destructor Destroy; override;
  public
    procedure Play(AUserID: Integer);
    procedure Stop;
  public
    property Channel: Integer read FChannel write FChannel;
    property OverlayText: string read FOverlayText write FOverlayText;
    property IsPlaying: Boolean read GetIsPlaying;
  end;

implementation

{ TWideoWindow }

constructor TVideoWindow.Create(AParent: TWinControl);
begin
  inherited Create(AParent);
  Parent := AParent;
  FRealHandle := -1;
  Color := clNavy;
end;

destructor TVideoWindow.Destroy;
begin
  Stop;
  inherited;
end;

function TVideoWindow.GetIsPlaying: Boolean;
begin
  Result := FRealHandle >= 0;
end;

procedure TVideoWindow.Play(AUserID: Integer);
var
  LPreviewInfo: NET_DVR_PREVIEWINFO;
begin
  ZeroMemory(@LPreviewInfo, SizeOf(LPreviewInfo));
  LPreviewInfo.hPlayWnd := Self.Handle;
  LPreviewInfo.lChannel := FChannel;
  LPreviewInfo.dwStreamType := 0;
  LPreviewInfo.dwLinkMode := 0;
  LPreviewInfo.bBlocked := true;
  LPreviewInfo.dwDisplayBufNum := 1;
  LPreviewInfo.byProtoType := 0;
  LPreviewInfo.byPreviewMode := 0;

  FRealHandle := NET_DVR_RealPlay_V40(AUserID, LPreviewInfo, nil, 0);
  if FRealHandle < 0 then
    RaiseLastHVError;
end;

procedure TVideoWindow.Stop;
begin
  if FRealHandle >= 0 then
    NET_DVR_StopRealPlay(FRealHandle);
  FRealHandle := -1;
end;

end.
