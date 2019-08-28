unit uVideoWindow;

interface

uses uCHCNetSDK, Vcl.Controls, Winapi.Windows, uHikvisionErrors, System.Classes,
  Vcl.Graphics, System.SysUtils, System.Generics.Collections;

type
  TVideoWindow = class(TCustomControl)
  private const
    CAPTION_DISABLED: string = 'DISABLED';
    CAPTION_STOPPED: string = 'VIDEO STOPPED';
    DEF_COLOR = clNavy;
    STATUS_FONTCOLOR = $00FF96A0;
    STATUS_FONTNAME = 'Impact';
    STATUS_FONTSIZE = 24;
    DEF_FONTNAME = 'Courier New';
    DEF_FONTSIZE = 24;
    DEF_FONTCOLOR = clLime;
  private
    FChannel: Integer;
    FRealHandle: Integer;
    FOverlayText: string;
    FPrintOverlayText: Boolean;
  private
    class var FObjects: TObjectList<TVideoWindow>;
    procedure RegisterObj;
    procedure UnRegisterObj;
  public
    class constructor Create;
    class destructor Destroy;
  private
    function GetIsPlaying: Boolean;
    procedure PrintStatusCaption;
  private
    class procedure DrawFun(lRealHandle: LongInt; hDc: IntPtr; dwUser: UINT);
      stdcall; static;
    procedure DrawFunction(hDc: IntPtr);
  protected
    procedure Paint; override;
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
    property PrintOverlayText: Boolean read FPrintOverlayText
      write FPrintOverlayText;
  end;

implementation

uses System.Types;

{ TWideoWindow }

constructor TVideoWindow.Create(AParent: TWinControl);
begin
  inherited Create(AParent);
  Parent := AParent;
  FRealHandle := -1;
  Color := DEF_COLOR;
  Enabled := False;

  if Assigned(Parent) then
    ParentFont := True
  else
  begin
    Font.Name := DEF_FONTNAME;
    Font.Size := DEF_FONTSIZE;
    Font.Color := DEF_FONTCOLOR;
  end;

  RegisterObj;
end;

class constructor TVideoWindow.Create;
begin
  FObjects := TObjectList<TVideoWindow>.Create(False);
end;

destructor TVideoWindow.Destroy;
begin
  Stop;
  UnRegisterObj;
  inherited;
end;

class destructor TVideoWindow.Destroy;
begin
  FreeAndNil(FObjects);
end;

class procedure TVideoWindow.DrawFun(lRealHandle: Integer; hDc: IntPtr;
  dwUser: UINT);
var
  LObj: TVideoWindow;
begin
  for LObj in FObjects do
    if LObj.FRealHandle = lRealHandle then
    begin
      LObj.DrawFunction(hDc);
      Break;
    end;
end;

procedure TVideoWindow.DrawFunction(hDc: IntPtr);
var
  LObj: HGDIOBJ;
  LHFont: HFONT;
  LRect: TRect;
begin
  if (not FPrintOverlayText) or (Length(OverlayText) = 0) or (not Visible) or
    (not Enabled) then
    Exit;

  LHFont := CreateFont(Font.Size, 0, 0, 0, FW_NORMAL, 0, 0, 0, 0, 0, 0, 2, 0,
    PWideChar(Font.Name));
  LObj := SelectObject(hDc, LHFont);
  try
    SetBkMode(hDc, TRANSPARENT);
    SetTextColor(hDc, Font.Color);
    LRect := Rect(0, 0, Width, Height);
    DrawText(hDc, PWideChar(OverlayText), Length(OverlayText), LRect,
      DT_LEFT or DT_TOP);
  finally
    DeleteObject(SelectObject(hDc, LObj));
  end;
end;

function TVideoWindow.GetIsPlaying: Boolean;
begin
  Result := FRealHandle >= 0;
end;

procedure TVideoWindow.Paint;
begin
  inherited;
  PrintStatusCaption;
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
  LPreviewInfo.bBlocked := True;
  LPreviewInfo.dwDisplayBufNum := 1;
  LPreviewInfo.byProtoType := 0;
  LPreviewInfo.byPreviewMode := 0;

  FRealHandle := NET_DVR_RealPlay_V40(AUserID, LPreviewInfo, nil, 0);
  if FRealHandle < 0 then
    RaiseLastHVError;
  if not NET_DVR_RigisterDrawFun(FRealHandle, DrawFun, 0) then
    RaiseLastHVError;
end;

procedure TVideoWindow.PrintStatusCaption;
var
  LRect: TRect;
  LText: string;
begin
  if not Enabled then
    LText := CAPTION_DISABLED
  else if not IsPlaying then
    LText := CAPTION_STOPPED
  else
    Exit;

  Canvas.Font.Size := 12;
  Canvas.Font.Name := 'Impact';
  Canvas.Font.Color := STATUS_FONTCOLOR;
  Canvas.Brush.Style := bsClear;

  LRect := Rect(0, 0, Width, Height);
  DrawText(Canvas.Handle, LText, Length(LText), LRect, DT_SINGLELINE or
    DT_CENTER or DT_VCENTER);
end;

procedure TVideoWindow.RegisterObj;
begin
  FObjects.Add(Self);
end;

procedure TVideoWindow.Stop;
begin
  if FRealHandle >= 0 then
    NET_DVR_StopRealPlay(FRealHandle);
  FRealHandle := -1;
  Invalidate;
end;

procedure TVideoWindow.UnRegisterObj;
begin
  FObjects.Remove(Self);
end;

end.
