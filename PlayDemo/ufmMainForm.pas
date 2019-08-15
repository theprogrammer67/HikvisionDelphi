unit ufmMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, uCHCNetSDK;

type
  TForm1 = class(TForm)
    pnlPictureBox: TPanel;
    lbledtAddress: TLabeledEdit;
    lbledtPort: TLabeledEdit;
    lbledtUser: TLabeledEdit;
    lbledtPassword: TLabeledEdit;
    btnPlay: TButton;
    btnStop: TButton;
    lbledtChannel: TLabeledEdit;
    edtText: TEdit;
    btnTextOut: TButton;
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnPlayClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure btnTextOutClick(Sender: TObject);
  private
    FUserID: Integer;
    FSDKInited: Boolean;
    FRealHandle: Integer;
  private
    procedure StopVideo;
  public
    FText: string;
  end;

var
  Form1: TForm1;

implementation

procedure DrawFun(lRealHandle: Longint; hDc: IntPtr; dwUser: UINT); stdcall;
var
  // LCurHPen: hPen;
  LObj: HGDIOBJ;
  LHFont: HFONT;
begin
  // LCurHPen := CreatePen(PS_GEOMETRIC or PS_DASH, 10, RGB(255, 255, 0));
  // LObj := SelectObject(hDc, LCurHPen);
  // MoveToEx(hDc, 10, 10, nil);
  // LineTo(hDc, 100, 200);
  // DeleteObject(LObj);

  if Length(Form1.FText) = 0 then
    Exit;

  LHFont := CreateFont(60, 0, 0, 0, FW_BOLD, 0, 0, 0, 0, 0, 0, 2, 0,
    'SYSTEM_FIXED_FONT');
  LObj := SelectObject(hDc, LHFont);
  // SetBkMode(hDC,TRANSPARENT);
  // DrawText(hDC,"Hello, World!",-1,&rc,DT_SINGLELINE|DT_CENTER|DT_VCENTER);
  SetBkMode(hDc, TRANSPARENT);
  SetTextColor(hDc, RGB(160, 255, 150));
  TextOut(hDc, 0, 0, PWideChar(Form1.FText), Length(Form1.FText));
  DeleteObject(SelectObject(hDc, LObj));
end;

{$R *.dfm}

procedure TForm1.FormDestroy(Sender: TObject);
begin
  StopVideo;
  if FSDKInited then
    NET_DVR_Cleanup;
end;

procedure TForm1.StopVideo;
begin
  if FRealHandle >= 0 then
  begin
    NET_DVR_StopRealPlay(FRealHandle);
    FRealHandle := -1;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  FSDKInited := False;
  FRealHandle := -1;
  FText := '';
end;

procedure TForm1.btnPlayClick(Sender: TObject);
var
  LDeviceInfo: NET_DVR_DEVICEINFO_V30;
  LPreviewInfo: NET_DVR_PREVIEWINFO;
begin
  StopVideo;

  if not FSDKInited then
  begin
    FSDKInited := NET_DVR_Init;
    if not FSDKInited then
      raise Exception.Create('NET_DVR_Init error!');
  end;

  ZeroMemory(@LDeviceInfo, SizeOf(LDeviceInfo));
  FUserID := NET_DVR_Login_V30(PAnsiChar(AnsiString(lbledtAddress.Text)),
    StrToInt(lbledtPort.Text), PAnsiChar(AnsiString(lbledtUser.Text)),
    PAnsiChar(AnsiString(lbledtPassword.Text)), LDeviceInfo);
  if FUserID < 0 then
    raise Exception.Create('NET_DVR_Login_V30 failed, error code= ' +
      IntToStr(NET_DVR_GetLastError));

  ZeroMemory(@LPreviewInfo, SizeOf(LPreviewInfo));
  LPreviewInfo.hPlayWnd := pnlPictureBox.Handle;
  LPreviewInfo.lChannel := StrToInt(lbledtChannel.Text);
  LPreviewInfo.dwStreamType := 0;
  LPreviewInfo.dwLinkMode := 0;
  LPreviewInfo.bBlocked := true;
  LPreviewInfo.dwDisplayBufNum := 1;
  LPreviewInfo.byProtoType := 0;
  LPreviewInfo.byPreviewMode := 0;

  FRealHandle := NET_DVR_RealPlay_V40(FUserID, LPreviewInfo, nil, 0);
  if FRealHandle < 0 then
    raise Exception.Create('NET_DVR_RealPlay_V40 failed, error code= ' +
      IntToStr(NET_DVR_GetLastError));

  if not NET_DVR_RigisterDrawFun(FRealHandle, DrawFun, 0) then
    raise Exception.Create('NET_DVR_RigisterDrawFun failed, error code= ' +
      IntToStr(NET_DVR_GetLastError));
end;

procedure TForm1.btnStopClick(Sender: TObject);
begin
  StopVideo;
end;

procedure TForm1.btnTextOutClick(Sender: TObject);
begin
  FText := edtText.Text;
end;

end.
