unit uCHCNetSDK;

interface

uses Winapi.Windows;

const
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

function NET_DVR_Login_V30(sDVRIP: PAnsiChar; wDVRPort: Int32;
  sUserName: PAnsiChar; sPassword: PAnsiChar;
  var lpDeviceInfo: NET_DVR_DEVICEINFO_V30): Integer; stdcall;
  external 'HCNetSDK.dll';
function NET_DVR_GetLastError: Integer; stdcall; external 'HCNetSDK.dll';
function NET_DVR_Init: Boolean; stdcall; external 'HCNetSDK.dll';
function NET_DVR_Cleanup: Boolean; stdcall; external 'HCNetSDK.dll';
function NET_DVR_RealPlay_V40(iUserID: Longint;
  var lpPreviewInfo: NET_DVR_PREVIEWINFO; fRealDataCallBack_V30: Pointer;
  pUser: IntPtr): Integer; stdcall; external 'HCNetSDK.dll';
function NET_DVR_StopRealPlay(iRealHandle: Longint): Bool; stdcall;
  external 'HCNetSDK.dll';
function NET_DVR_RigisterDrawFun(lRealHandle: Longint; fDrawFun: DRAWFUN;
  dwUser: UINT): Bool; stdcall; external 'HCNetSDK.dll';

implementation

end.
