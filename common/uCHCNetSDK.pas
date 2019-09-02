unit uCHCNetSDK;

interface

uses Winapi.Windows, System.SysUtils;

const
  DLL_NAME = 'HCNetSDK.dll';
  SERIALNO_LEN = 48;
  STREAM_ID_LEN = 32;

type
  NET_DVR_DEVICEINFO_V30 = record
    sSerialNumber: array [0 .. SERIALNO_LEN - 1] of Byte;
    byAlarmInPortNum: Byte;
    byAlarmOutPortNum: Byte;
    byDiskNum: Byte;
    byDVRType: Byte;
    byChanNum: Byte;
    byStartChan: Byte;
    byAudioChanNum: Byte;
    byIPChanNum: Byte;
    byZeroChanNum: Byte;
    byMainProto: Byte;
    bySubProto: Byte;
    bySupport: Byte;
    bySupport1: Byte;
    bySupport2: Byte;
    wDevType: Word;
    bySupport3: Byte;
    byMultiStreamProto: Byte;
    byStartDChan: Byte;
    byStartDTalkChan: Byte;
    byHighDChanNum: Byte;
    bySupport4: Byte;
    byLanguageType: Byte;
    byRes2: array [0 .. 8] of Byte;
  end;

  NET_DVR_PREVIEWINFO = record
    lChannel: Int32;
    dwStreamType: UINT;
    dwLinkMode: UINT;
    hPlayWnd: IntPtr;
    bBlocked: Bool;
    bPassbackRecord: Bool;
    byPreviewMode: Byte;
    byStreamID: array [0 .. STREAM_ID_LEN - 1] of Byte;
    byProtoType: Byte;
    byRes1: array [0 .. 1] of Byte;
    dwDisplayBufNum: UINT;
    byRes: array [0 .. 215] of Byte;
  end;

  DRAWFUN = procedure(lRealHandle: Longint; hDc: IntPtr; dwUser: UINT); stdcall;

type
  TNET_DVR_Login_V30 = function(sDVRIP: PAnsiChar; wDVRPort: Int32;
    sUserName: PAnsiChar; sPassword: PAnsiChar;
    var lpDeviceInfo: NET_DVR_DEVICEINFO_V30): Integer; stdcall;
  TNET_DVR_Logout = function(iUserID: Longint): Bool; stdcall;
  TNET_DVR_GetLastError = function(): Integer; stdcall;
  TNET_DVR_GetErrorMsg = function(var ErrorNo: Longint): PAnsiChar; stdcall;
  TNET_DVR_Init = function(): Boolean; stdcall;
  TNET_DVR_Cleanup = function(): Boolean; stdcall;
  TNET_DVR_RealPlay_V40 = function(iUserID: Longint;
    var lpPreviewInfo: NET_DVR_PREVIEWINFO; fRealDataCallBack_V30: Pointer;
    pUser: IntPtr): Integer; stdcall;
  TNET_DVR_StopRealPlay = function(iRealHandle: Longint): Bool; stdcall;
  TNET_DVR_RigisterDrawFun = function(lRealHandle: Longint; fDrawFun: DRAWFUN;
    dwUser: UINT): Bool; stdcall;

{$IFDEF LoadLibStatic}
function NET_DVR_Login_V30(sDVRIP: PAnsiChar; wDVRPort: Int32;
  sUserName: PAnsiChar; sPassword: PAnsiChar;
  var lpDeviceInfo: NET_DVR_DEVICEINFO_V30): Integer; stdcall;
  external DLL_NAME;
function NET_DVR_Logout(iUserID: Longint): Bool; stdcall; external DLL_NAME;
function NET_DVR_GetLastError: Integer; stdcall; external DLL_NAME;
function NET_DVR_GetErrorMsg(var ErrorNo: Longint): PAnsiChar; stdcall;
  external DLL_NAME;
function NET_DVR_Init: Boolean; stdcall; external DLL_NAME;
function NET_DVR_Cleanup: Boolean; stdcall; external DLL_NAME;
function NET_DVR_RealPlay_V40(iUserID: Longint;
  var lpPreviewInfo: NET_DVR_PREVIEWINFO; fRealDataCallBack_V30: Pointer;
  pUser: IntPtr): Integer; stdcall; external DLL_NAME;
function NET_DVR_StopRealPlay(iRealHandle: Longint): Bool; stdcall;
  external DLL_NAME;
function NET_DVR_RigisterDrawFun(lRealHandle: Longint; fDrawFun: DRAWFUN;
  dwUser: UINT): Bool; stdcall; external DLL_NAME;
{$ELSE}
var
  NET_DVR_Login_V30: TNET_DVR_Login_V30;
  NET_DVR_Logout: TNET_DVR_Logout;
  NET_DVR_GetLastError: TNET_DVR_GetLastError;
  NET_DVR_GetErrorMsg: TNET_DVR_GetErrorMsg;
  NET_DVR_Init: TNET_DVR_Init;
  NET_DVR_Cleanup: TNET_DVR_Cleanup;
  NET_DVR_RealPlay_V40: TNET_DVR_RealPlay_V40;
  NET_DVR_StopRealPlay: TNET_DVR_StopRealPlay;
  NET_DVR_RigisterDrawFun: TNET_DVR_RigisterDrawFun;

procedure LoadLib(out ALibHandle: THandle; const LibDirectory: string);
procedure FreeLib(var ALibHandle: THandle);
{$ENDIF}

implementation

{$IFNDEF LoadLibStatic}
procedure FreeLib(var ALibHandle: THandle);
begin
  if ALibHandle = 0 then
    Exit;

  FreeLibrary(ALibHandle);
  ALibHandle := 0;
end;

procedure LoadLib(out ALibHandle: THandle; const LibDirectory: string);

  function GetModuleSymbol(const SymbolName: string): Pointer;
  begin
    Result := GetProcAddress(ALibHandle, PWideChar(SymbolName));
    if Result = nil then
      raise Exception.Create('Invalid HCNetSDK.dll version')
  end;

begin
  ALibHandle := LoadLibrary(PWideChar(IncludeTrailingPathDelimiter(LibDirectory)
    + DLL_NAME));
  if ALibHandle = 0 then
    raise Exception.Create('Library HCNetSDK.dll not found')
  else
  begin
    try
      @NET_DVR_Login_V30 := GetModuleSymbol('NET_DVR_Login_V30');
      @NET_DVR_Logout := GetModuleSymbol('NET_DVR_Logout');
      @NET_DVR_GetLastError := GetModuleSymbol('NET_DVR_GetLastError');
      @NET_DVR_GetErrorMsg := GetModuleSymbol('NET_DVR_GetErrorMsg');
      @NET_DVR_Init := GetModuleSymbol('NET_DVR_Init');
      @NET_DVR_Cleanup := GetModuleSymbol('NET_DVR_Cleanup');
      @NET_DVR_RealPlay_V40 := GetModuleSymbol('NET_DVR_RealPlay_V40');
      @NET_DVR_StopRealPlay := GetModuleSymbol('NET_DVR_StopRealPlay');
      @NET_DVR_RigisterDrawFun := GetModuleSymbol('NET_DVR_RigisterDrawFun');
    except
      FreeLib(ALibHandle);
      raise;
    end;
  end;
end;
{$ENDIF}

end.
