unit uHikvisionErrors;

interface

uses System.SysUtils, uCHCNetSDK;

type
  EHVException = class(Exception)
  private
    FErrorCode: Integer;
    function GetMessage: string;
  public
    constructor Create(AErrorCode: Integer);
  public
    property ErrorCode: Integer read FErrorCode write FErrorCode;
  end;

const
  NET_DVR_NOERROR = 0; // No error.
  NET_DVR_PASSWORD_ERROR = 1; // User name or password error.
  NET_DVR_NOINIT = 3; // SDK is not initialized.
  // The number of clients connected to the device has exceeded the max limit.
  NET_DVR_OVER_MAXLINK = 5;
  // Failed to connect to the device. The device is off-line, or connection timeout caused by network.
  NET_DVR_NETWORK_FAIL_CONNECT = 7;
  NET_DVR_NETWORK_SEND_ERROR = 8; // Failed to send data to the device.
  NET_DVR_NETWORK_RECV_ERROR = 9; // Failed to receive data from the device.
  // Timeout when receiving the data from the device.
  NET_DVR_NETWORK_RECV_TIMEOUT = 10;
  NET_DVR_COMMANDTIMEOUT = 14; // Executing command on the device is timeout.
  // Parameter error. Input or output parameter in the SDK API is NULL.
  NET_DVR_PARAMETER_ERROR = 17;
  NET_DVR_ALLOC_RESOURCE_ERROR = 41; // Resource allocation error.
  NET_DVR_NOENOUGH_BUF = 43; // Buffer is not enough.
  NET_DVR_CREATESOCKET_ERROR = 44; // Create SOCKET error.
  // User doest not exist. The user ID has been logged out or unavailable.
  NET_DVR_USERNOTEXIST = 47;
  NET_DVR_LOADPLAYERSDKFAILED = 64; // Failed to load the player SDK.
  // Can not find the function in player SDK.
  NET_DVR_LOADPLAYERSDKPROC_ERROR = 65;
  NET_DVR_LOADDSSDKFAILED = 66; // Failed to load the library file "DsSdk".
  NET_DVR_BINDSOCKET_ERROR = 72; // Failed to bind socket.
  // Socket disconnected. It is caused by network disconnection or destination unreachable.
  NET_DVR_SOCKETCLOSE_ERROR = 73;
  NET_DVR_IPCHAN_NOTALIVE = 83; // IP channel is not on-line when previewing.
  NET_DVR_RTSP_SDK_ERROR = 84; // Load StreamTransClient.dll failed.
  NET_DVR_CONVERT_SDK_ERROR = 85; // Load SystemTransform.dll failed.

resourcestring
  RsErr_NET_DVR_NOERROR = 'No error.';
  RsErr_NET_DVR_PASSWORD_ERROR = 'User name or password error.';
  RsErr_NET_DVR_NOINIT = 'SDK is not initialized.';
  RsErr_NET_DVR_OVER_MAXLINK =
    'The number of clients connected to the device has exceeded the max limit.';
  RsErr_NET_DVR_NETWORK_FAIL_CONNECT =
    'Failed to connect to the device. The device is off-line, or connection timeout caused by network. ';
  RsErr_NET_DVR_NETWORK_SEND_ERROR = 'Failed to send data to the device.';
  RsErr_NET_DVR_NETWORK_RECV_ERROR = 'Failed to receive data from the device.';
  RsErr_NET_DVR_NETWORK_RECV_TIMEOUT =
    'Timeout when receiving the data from the device.';
  RsErr_NET_DVR_COMMANDTIMEOUT = 'Executing command on the device is timeout.';
  RsErr_NET_DVR_PARAMETER_ERROR =
    'Parameter error. Input or output parameter in the SDK API is NULL.';
  RsErr_NET_DVR_ALLOC_RESOURCE_ERROR = 'Resource allocation error.';
  RsErr_NET_DVR_NOENOUGH_BUF = 'Buffer is not enough.';
  RsErr_NET_DVR_CREATESOCKET_ERROR = 'Create SOCKET error.';
  RsErr_NET_DVR_USERNOTEXIST =
    'User doest not exist. The user ID has been logged out or unavailable. ';
  RsErr_NET_DVR_LOADPLAYERSDKFAILED = 'Failed to load the player SDK.';
  RsErr_NET_DVR_LOADPLAYERSDKPROC_ERROR =
    'Can not find the function in player SDK.';
  RsErr_NET_DVR_LOADDSSDKFAILED = 'Failed to load the library file "DsSdk".';
  RsErr_NET_DVR_BINDSOCKET_ERROR = 'Failed to bind socket.';
  RsErr_NET_DVR_SOCKETCLOSE_ERROR =
    'Socket disconnected. It is caused by network disconnection or destination unreachable.';
  RsErr_NET_DVR_IPCHAN_NOTALIVE = 'IP channel is not on-line when previewing.';
  RsErr_NET_DVR_RTSP_SDK_ERROR = 'Load StreamTransClient.dll failed.';
  RsErr_NET_DVR_CONVERT_SDK_ERROR = 'Load SystemTransform.dll failed.';

procedure RaiseLastHVError;

implementation

procedure RaiseLastHVError;
var
  LErrorCode: LongInt;
  LErrorMsg: AnsiString;
begin
  LErrorMsg := NET_DVR_GetErrorMsg(LErrorCode);
  raise Exception.CreateFmt('%s (error code: %d)', [LErrorMsg, LErrorCode]);
end;

{ EHVException }

constructor EHVException.Create(AErrorCode: Integer);
begin
  FErrorCode := AErrorCode;
  Message := GetMessage;
end;

function EHVException.GetMessage: string;
begin
  case FErrorCode of
    NET_DVR_NOERROR:
      Result := RsErr_NET_DVR_NOERROR;
    NET_DVR_PASSWORD_ERROR:
      Result := RsErr_NET_DVR_PASSWORD_ERROR;
    NET_DVR_NOINIT:
      Result := RsErr_NET_DVR_NOINIT;
    NET_DVR_OVER_MAXLINK:
      Result := RsErr_NET_DVR_OVER_MAXLINK;
    NET_DVR_NETWORK_FAIL_CONNECT:
      Result := RsErr_NET_DVR_NETWORK_FAIL_CONNECT;
    NET_DVR_NETWORK_SEND_ERROR:
      Result := RsErr_NET_DVR_NETWORK_SEND_ERROR;
    NET_DVR_NETWORK_RECV_ERROR:
      Result := RsErr_NET_DVR_NETWORK_RECV_ERROR;
    NET_DVR_NETWORK_RECV_TIMEOUT:
      Result := RsErr_NET_DVR_NETWORK_RECV_TIMEOUT;
    NET_DVR_COMMANDTIMEOUT:
      Result := RsErr_NET_DVR_COMMANDTIMEOUT;
    NET_DVR_PARAMETER_ERROR:
      Result := RsErr_NET_DVR_PARAMETER_ERROR;
    NET_DVR_ALLOC_RESOURCE_ERROR:
      Result := RsErr_NET_DVR_ALLOC_RESOURCE_ERROR;
    NET_DVR_NOENOUGH_BUF:
      Result := RsErr_NET_DVR_NOENOUGH_BUF;
    NET_DVR_CREATESOCKET_ERROR:
      Result := RsErr_NET_DVR_CREATESOCKET_ERROR;
    NET_DVR_USERNOTEXIST:
      Result := RsErr_NET_DVR_USERNOTEXIST;
    NET_DVR_LOADPLAYERSDKFAILED:
      Result := RsErr_NET_DVR_LOADPLAYERSDKFAILED;
    NET_DVR_LOADPLAYERSDKPROC_ERROR:
      Result := RsErr_NET_DVR_LOADPLAYERSDKPROC_ERROR;
    NET_DVR_LOADDSSDKFAILED:
      Result := RsErr_NET_DVR_LOADDSSDKFAILED;
    NET_DVR_BINDSOCKET_ERROR:
      Result := RsErr_NET_DVR_BINDSOCKET_ERROR;
    NET_DVR_SOCKETCLOSE_ERROR:
      Result := RsErr_NET_DVR_SOCKETCLOSE_ERROR;
    NET_DVR_IPCHAN_NOTALIVE:
      Result := RsErr_NET_DVR_IPCHAN_NOTALIVE;
    NET_DVR_RTSP_SDK_ERROR:
      Result := RsErr_NET_DVR_RTSP_SDK_ERROR;
    NET_DVR_CONVERT_SDK_ERROR:
      Result := RsErr_NET_DVR_CONVERT_SDK_ERROR;
  else
    Result := 'Unknown EHVException. Code=' + IntToStr(FErrorCode);
  end;
end;

end.
