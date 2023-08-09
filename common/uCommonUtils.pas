unit uCommonUtils;

interface

uses Classes, SysUtils, Controls, Windows, ActiveX
{$IF CompilerVersion > 24}
    , AnsiStrings
{$IFEND}
    ;

const
  c1C_WS_Error_Prefix = '1C_WS_Error: ';

type
  TStringsArray = array of string;

{$IF CompilerVersion > 24}

  TAnsiStringHelper = record helper for AnsiString
  public
    function Split(Separator: AnsiChar): TArray<AnsiString>; overload;
  end;
{$IFEND}

function BoolToStrRus(const Value: Boolean; UseYesNo: Boolean = False): string;
function GetEnvVariable(const Name: string; Expand: Boolean;
  User: Boolean = True): string;
procedure SetEnvVariable(const Name, Value: string; User: Boolean = True);
procedure AddPathEnvVariable(const APath: string);
function RegisterDll(const AFile: WideString;
  Unregister: Boolean = False): Boolean;
procedure RegisterExe(const AFile: WideString; Unregister: Boolean = False);
procedure RegisterCOM(const AFile: WideString; Unregister: Boolean = False);
function MoneyRound(Value: Extended): Extended;
function GetFolderDialog(Handle: Integer; Caption: string;
  var strFolder: string): Boolean;
function GetModuleFileNameStr: string;
function GetModuleDirectory: string;
function PadLA(const Str: AnsiString; Len: Integer; Trim: Boolean = True)
  : AnsiString; overload;
function PadLA(const Str: AnsiString; Len: Integer; Chr: AnsiChar = ' ')
  : AnsiString; overload;
function PadRA(const Str: AnsiString; Len: Integer; Trim: Boolean = True)
  : AnsiString; overload;
function PadRA(const Str: AnsiString; Len: Integer; Chr: AnsiChar)
  : AnsiString; overload;
function GetSpecialPath(CSIDL: Word): string;
function GetAppDataPath: string;
function GetCommonAppDataPath: string;
function GetWindowsTempPath(): string;
function GetProgramFilesPath: string;
function GetProgramFilesCommonPath: string;
procedure SetStringA(var S: AnsiString; Buffer: PAnsiChar; Length: Integer);
function HexToBinStr(const Value: AnsiString; BufSize: Integer = 0): AnsiString;
function BinStrToHex(const Value: AnsiString; BufSize: Integer = 0): AnsiString;
function BCDToInt(Value: Pointer; Size: Integer = 1): Int64;
function IntToBCDStr(Value: Int64; Size: Integer = 1): AnsiString;
function CheckBit(Value, N: Integer): Boolean;
procedure SetBit(var Value: Byte; N: Integer); overload;
procedure SetBit(var Value: Integer; N: Integer); overload;
procedure SetBit(var Value: Integer; N: Integer; BitValue: Boolean); overload;
procedure SetBit(var Value: Byte; N: Integer; BitValue: Boolean); overload;
function SetBits(b7, b6, b5, b4, b3, b2, b1, b0: Boolean): Byte;
function ConvertAnsiToOem(const S: AnsiString): AnsiString;
function ConvertOemToAnsi(const S: AnsiString): AnsiString;
procedure SetCtlNumberMode(WinCtl: TWinControl);
procedure SetCtlsNumberMode(WinCtls: array of TWinControl);
function CenterStr(const S: string; Len: Integer): string;
function CenterStrA(const S: AnsiString; Len: Integer): AnsiString;
function FormatRecLineA(const StrL, StrR: AnsiString; LineLen: Byte;
  Ch: AnsiChar = ' '): AnsiString;
function FormatRecLine(const StrL, StrR: string; LineLen: Byte;
  Ch: Char = ' '): string;
function ClearStringA(const Str: AnsiString): AnsiString;
function ClearStringAExceptWrap(const Str: AnsiString): AnsiString;
procedure SeparateString(const Str: string; var StringsArr: TStringsArray;
  Len: Integer);
function WordToBinStrRev(const Value: Word): AnsiString;
function BinStrRevToDWord(const Value: AnsiString): DWORD;
procedure ProcessMessages;
procedure Wait(Value: Cardinal);
function ExecuteApplication(const App, Str: string; HideWnd: Boolean = False;
  MaximizeWnd: Boolean = False; WaitForTerminate: Boolean = False;
  X: Integer = 0; Y: Integer = 0; XSize: Integer = 0;
  YSize: Integer = 0): THandle;
function Get_NewEnum(Value: OleVariant): IEnumVariant;
function Get_NextElement(var Value: OleVariant; _Enum: IEnumVariant): Boolean;
function NewXMLObject: OleVariant; overload;
function NewXMLObject(const RootName, ProcessingInstruction: WideString)
  : OleVariant; overload;
function VarToIntDef(const V: Variant; const ADefault: Integer): Integer;
function VarToDoubleDef(const V: Variant; const ADefault: Double): Double;
function VarToCurrDef(const V: Variant; const ADefault: Currency)
  : Currency; overload;
function VarToCurrDef(const V: Variant; const ADefault: Currency;
  AFormatSettings: TFormatSettings): Currency; overload;
function VarToBoolDef(const V: Variant; const ADefault: Boolean): Boolean;
function VarToStringDef(const V: Variant; const ADefault: string): string;
function VarToDateDef(const V: Variant; const ADefault: TDateTime): TDateTime;
function VarIsEmptyStr(const Value: Variant): Boolean;
function GetFilesCount(const aFolder: string;
  ExcludeDirectory: Boolean = True): Integer;
function CorrectLineBreaks(const Text: string): string;
procedure TextStrToStrings(const Text: string; sl: TStrings);
function EncodeBase64(Value: string): string;
function DecodeBase64(Value: string): string;
// преобразование GUID'а в строку БЕЗ или С фигурными скобками
// функция честно взята из pos-kernel/uUtils.pas (проект armwaiter)
function CastGUID(const aGUIDStr: Variant; aBracket: Boolean = True): Variant;
// возвращает текст сообщения из исключения веб-сервиса 1С
// такие исключения должны быть с заданным префиксом
function Extract1CSOAPError(const E: Exception;
  const APrefix: string = c1C_WS_Error_Prefix): string;
function ByteToBinStr(Value: Byte): string;
function StrCenter(const Str: string; Len: Integer): string;
function AddLeadZero(const Number, Length: Int64): string;
function StrToHex(const Source: AnsiString): string;
{$IF CompilerVersion > 24}
function IntToHexFirstLow(Val: Int64; Size: Integer): AnsiString;
function IntToHexFirstHigh(Val: Int64; Size: Integer): AnsiString;
function HexFirstLowToInt(Val: AnsiString): Int64;
function HexFirstHighToInt(Val: AnsiString): Int64;
function HexToInt(HexStr: AnsiString): Int64;
function BCDToStr(Value: Pointer; Size: Integer = 1): AnsiString;
{$IFEND}
procedure ReverseBytes(var ABytes: TBytes);
{$IF CompilerVersion > 24}
function CheckUuid(const AUuid: string): Boolean;
function GetValidXML(const AStr: string): string;
{$IFEND}
function GetAttribute(const Node: Variant; AttrName: string;
  DefValue: string = ''): string;

resourcestring
  rsYes = 'Да';
  rsNo = 'Нет';
  rsTrue = 'Истина';
  rsFalse = 'Ложь';

implementation

uses ShlObj, SHFolder, ComObj, Variants, Registry, Messages, StrUtils, ShellAPI,
  StdCtrls
{$IF CompilerVersion > 24}
    , RegularExpressions, DateUtils
{$IFEND}
    ;

resourcestring
  RsErrExitCode = 'Приложение %s завершено с ошибкой';

function StrToHex(const Source: AnsiString): string;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(Source) do
    Result := Result + IntToHex(Integer(Source[i]), 2) + ' ';
end;

function BoolToStrRus(const Value: Boolean; UseYesNo: Boolean = False): string;
begin
  if Value then
  begin
    if UseYesNo then
      Result := rsYes
    else
      Result := rsTrue;
  end
  else
  begin
    if UseYesNo then
      Result := rsNo
    else
      Result := rsFalse;
  end;
end;

function GetEnvVariable(const Name: string; Expand: Boolean;
  User: Boolean = True): string;
var
  Str: string;
  BufSize: Integer;
begin
  with TRegistry.Create do
    try
      if User then
      begin
        RootKey := HKEY_CURRENT_USER;
        OpenKeyReadOnly('Environment');
      end
      else
      begin
        RootKey := HKEY_LOCAL_MACHINE;
        OpenKeyReadOnly('SYSTEM\CurrentControlSet\Control\Session ' +
          'Manager\Environment');
      end;
      Result := ReadString(Name);
      if not Expand then
        Exit;

      BufSize := ExpandEnvironmentStrings(PChar(Result), nil, 0);
      if BufSize = 0 then
        Exit;
      SetLength(Str, BufSize);
      ExpandEnvironmentStrings(PChar(Result), PChar(Str), BufSize);
      Result := Str;
    finally
      Free;
    end;
end;

procedure SetEnvVariable(const Name, Value: string; User: Boolean = True);
var
  rv: Cardinal;
begin
  with TRegistry.Create do
    try
      if User then
      begin
        RootKey := HKEY_CURRENT_USER;
        if not OpenKey('Environment', False) then
          RaiseLastOSError;
        WriteString(Name, Value);
      end
      else
      begin
        RootKey := HKEY_LOCAL_MACHINE;
        if not OpenKey('SYSTEM\CurrentControlSet\Control\Session ' +
          'Manager\Environment', False) then
          RaiseLastOSError;
      end;
      WriteString(Name, Value);
{$IF CompilerVersion > 22}
      SendMessageTimeout(HWND_BROADCAST, WM_SETTINGCHANGE, 0,
        LParam(PChar('Environment')), SMTO_ABORTIFHUNG, 5000, @rv);
{$ELSE}
      SendMessageTimeout(HWND_BROADCAST, WM_SETTINGCHANGE, 0,
        LParam(PChar('Environment')), SMTO_ABORTIFHUNG, 5000, rv);
{$IFEND}
    finally
      Free;
    end;
end;

procedure AddPathEnvVariable(const APath: string);
var
  LPath: string;
begin
  with TRegistry.Create do
    try
      RootKey := HKEY_LOCAL_MACHINE;
      if not OpenKey('SYSTEM\CurrentControlSet\Control\Session ' +
        'Manager\Environment', False) then
        RaiseLastOSError;
      LPath := ReadString('Path');
      if Pos(UpperCase(APath), UpperCase(LPath)) > 0 then
        Exit;

      if (Length(LPath) > 0) and (LPath[Length(LPath)] <> ';') then
        LPath := LPath + ';';
      LPath := LPath + APath;
      SetEnvVariable('Path', LPath, False);
    finally
      Free;
    end;
end;

function RegisterDll(const AFile: WideString; Unregister: Boolean): Boolean;
type
  TRegFunc = function: Integer; stdcall;
var
  hMod: HMODULE;
  RegFunc: TRegFunc;
begin
  Result := False;

  hMod := SafeLoadLibrary(PWideChar(AFile));
  if hMod <= HINSTANCE_ERROR then
    Exit;

  try
    if Unregister then
      @RegFunc := GetProcAddress(hMod, 'DllUnregisterServer')
    else
      @RegFunc := GetProcAddress(hMod, 'DllRegisterServer');

    if not Assigned(RegFunc) then
      Exit;
    if not Succeeded(RegFunc()) then
      Exit;

    Result := True;
  finally
    FreeLibrary(hMod);
  end;
end;

function RunAsCurrentUser(Hwnd: THandle; FileName, Params: string;
  WaitEnd: Boolean = False): Cardinal;
var
{$IFDEF FPC}
  SI: LPSHELLEXECUTEINFOW;
type
  PC = PWideChar;
{$ELSE}
  SI: TShellExecuteInfo;
type
  PC = PChar;
{$ENDIF}
begin
  FillChar(SI, SizeOf(SI), 0);
  SI.cbSize := SizeOf(SI);
  SI.Wnd := Hwnd;
  SI.fMask := SEE_MASK_FLAG_DDEWAIT or SEE_MASK_FLAG_NO_UI;
  if WaitEnd then
    SI.fMask := SI.fMask + SEE_MASK_NOCLOSEPROCESS;
  SI.lpVerb := 'open';
  SI.lpFile := PC(FileName);
  SI.lpParameters := PC(Params);
  SI.nShow := SW_HIDE;
{$IFDEF FPC}
  if not ShellExecuteEx(SI) then
    RaiseLastOSError;
{$ELSE}
  if not ShellExecuteEx(@SI) then
    RaiseLastOSError;
{$ENDIF}
  if WaitEnd then
    WaitForSingleObject(SI.hProcess, INFINITE);
  if SI.hProcess <> 0 then
    GetExitCodeProcess(SI.hProcess, Result);
end;

procedure RegisterExe(const AFile: WideString; Unregister: Boolean = False);
begin
  if Unregister then
    RunAsCurrentUser(0, AFile, '/unregserver', True)
  else
    RunAsCurrentUser(0, AFile, '/regserver', True);
end;

procedure RegisterCOM(const AFile: WideString; Unregister: Boolean = False);
begin
  if SameText(ExtractFileExt(AFile), '.exe') then
    RegisterExe(AFile, Unregister)
  else
    RegisterDll(AFile, Unregister);
end;

function MoneyRound(Value: Extended): Extended;
var
  D: Extended;
begin
  if Value < 0 then
    D := -0.5
  else
    D := 0.5;
  Result := Trunc(Value * 100 + D + 1E-12) / 100;
end;

function BrowseCallbackProc(Hwnd: Hwnd; uMsg: UINT; LParam: LParam;
  lpData: LParam): Integer; stdcall;
begin
  if (uMsg = BFFM_INITIALIZED) then
    SendMessage(Hwnd, BFFM_SETSELECTION, 1, lpData);
  BrowseCallbackProc := 0;
end;

function GetFolderDialog(Handle: Integer; Caption: string;
  var strFolder: string): Boolean;
const
  BIF_STATUSTEXT = $0004;
  BIF_NEWDIALOGSTYLE = $0040;
  BIF_RETURNONLYFSDIRS = $0080;
  BIF_SHAREABLE = $0100;
  BIF_USENEWUI = BIF_EDITBOX or BIF_NEWDIALOGSTYLE;
var
  BrowseInfo: TBrowseInfo;
  ItemIDList: PItemIDList;
  JtemIDList: PItemIDList;
  Path: PChar;
begin
  Result := False;
  Path := StrAlloc(MAX_PATH);
  SHGetSpecialFolderLocation(Handle, CSIDL_DRIVES, JtemIDList);
  with BrowseInfo do
  begin
    hwndOwner := GetActiveWindow;
    pidlRoot := JtemIDList;
    SHGetSpecialFolderLocation(hwndOwner, CSIDL_DRIVES, JtemIDList);
    ulFlags := BIF_RETURNONLYFSDIRS or BIF_NEWDIALOGSTYLE or
      BIF_NONEWFOLDERBUTTON;

    pszDisplayName := StrAlloc(MAX_PATH);
    { Возврат названия выбранного элемента }
    lpszTitle := PChar(Caption); { Установка названия диалога выбора папки }
    lpfn := @BrowseCallbackProc; { Флаги, контролирующие возврат }
    LParam := LongInt(PChar(strFolder));
    { Дополнительная информация, которая отдаётся обратно в обратный вызов (callback) }
  end;

  ItemIDList := SHBrowseForFolder(BrowseInfo);

  if (ItemIDList <> nil) then
    if SHGetPathFromIDList(ItemIDList, Path) then
    begin
      strFolder := Path;
      GlobalFreePtr(ItemIDList);
      Result := True;
    end;

  GlobalFreePtr(JtemIDList);
  StrDispose(Path);
  StrDispose(BrowseInfo.pszDisplayName);
end;

function GetModuleFileNameStr: string;
var
  Buffer: array [0 .. MAX_PATH] of Char;
begin
  FillChar(Buffer, MAX_PATH, #0);
  GetModuleFileName(hInstance, Buffer, MAX_PATH);
  Result := Buffer;
end;

function GetModuleDirectory: string;
begin
  Result := IncludeTrailingPathDelimiter(ExtractFileDir(GetModuleFileNameStr));
end;

function PadLA(const Str: AnsiString; Len: Integer; Trim: Boolean): AnsiString;
begin
  if Trim then
    Result := Copy(Str, 1, Len)
  else
    Result := Str;
  while Length(Result) < Integer(Len) do
    Result := AnsiChar(' ') + Result;
end;

function PadLA(const Str: AnsiString; Len: Integer; Chr: AnsiChar): AnsiString;
begin
  Result := Copy(Str, 1, Len);

  while Length(Result) < Integer(Len) do
    Result := Chr + Result;
end;

function PadRA(const Str: AnsiString; Len: Integer; Trim: Boolean): AnsiString;
begin
  if Trim then
    Result := Copy(Str, 1, Len)
  else
    Result := Str;
  while Length(Result) < Integer(Len) do
    Result := Result + AnsiChar(' ');
end;

function PadRA(const Str: AnsiString; Len: Integer; Chr: AnsiChar): AnsiString;
begin
  Result := Copy(Str, 1, Len);

  while Length(Result) < Integer(Len) do
    Result := Result + Chr;
end;

function GetSpecialPath(CSIDL: Word): string;
var
  S: string;
begin
  SetLength(S, MAX_PATH);
  if not SHGetSpecialFolderPath(0, PChar(S), CSIDL, True) then
    S := GetSpecialPath(CSIDL_APPDATA);
  Result := IncludeTrailingPathDelimiter(PChar(S));
end;

function GetAppDataPath: string;
begin
  Result := GetSpecialPath(CSIDL_APPDATA);
end;

function GetCommonAppDataPath: string;
begin
  Result := GetSpecialPath(CSIDL_COMMON_APPDATA);
end;

function GetWindowsTempPath(): string;
var
  tempFolder: array [0 .. MAX_PATH] of Char;
begin
  GetTempPath(MAX_PATH, @tempFolder);
  Result := IncludeTrailingPathDelimiter(StrPas(tempFolder));
end;

function GetProgramFilesPath: string;
begin
  Result := GetSpecialPath(CSIDL_PROGRAM_FILES);
end;

function GetProgramFilesCommonPath: string;
begin
  Result := GetSpecialPath(CSIDL_PROGRAM_FILES_COMMON);
end;

procedure SetStringA(var S: AnsiString; Buffer: PAnsiChar; Length: Integer);
begin
  SetLength(S, Length);
  CopyMemory(@S[1], Buffer, Length);
end;

{$IF CompilerVersion > 24}

function GetValidXML(const AStr: string): string;
const ValidChars: TSysCharSet = [#9,#10,#13];
var
  I: Integer;
begin
  Result := '';
  for I := Low(AStr) to High(AStr) do
  begin
    if CharInSet(AStr[I], ValidChars) then
      Result := Result + AStr[I]
    else
    if (AStr[I] >= #$20) and (AStr[I] <= #$D7FF) or
       (AStr[I] >= #$E000) and (AStr[I] <= #$FFFD) then
       Result := Result + AStr[I];
  end;
end;

function HexToInt(HexStr: AnsiString): Int64;
var
  RetVar: Int64;
  i: Byte;
begin
  HexStr := UpperCase(HexStr);
  if HexStr[Length(HexStr)] = 'H' then
    Delete(HexStr, Length(HexStr), 1);
  RetVar := 0;

  for i := 1 to Length(HexStr) do
  begin
    RetVar := RetVar shl 4;
    if CharInSet(HexStr[i], ['0' .. '9']) then
      RetVar := RetVar + (Byte(HexStr[i]) - 48)
    else if CharInSet(HexStr[i], ['A' .. 'F']) then
      RetVar := RetVar + (Byte(HexStr[i]) - 55)
    else
    begin
      RetVar := 0;
      break;
    end;
  end;

  Result := RetVar;
end;

function HexFirstLowToInt(Val: AnsiString): Int64;
var
  i: Integer;
  NewVal, HexVal: AnsiString;
begin
  HexVal := '';

  for i := 1 to Length(Val) do
    HexVal := HexVal + AnsiString(IntToHex(Ord(Val[i]), 2));

  for i := Length(HexVal) downto 1 do
  begin
    if i mod 2 = 0 then
      NewVal := NewVal + (HexVal[i - 1] + HexVal[i]);
  end;

  Result := HexToInt(AnsiString(NewVal));
end;

function HexFirstHighToInt(Val: AnsiString): Int64;
var
  i: Integer;
  NewVal, HexVal: AnsiString;
begin
  HexVal := '';

  for i := 1 to Length(Val) do
    HexVal := HexVal + AnsiString(IntToHex(Ord(Val[i]), 2));

  for i := 1 to Length(HexVal) do
  begin
    if i mod 2 = 0 then
      NewVal := NewVal + (HexVal[i - 1] + HexVal[i]);
  end;

  Result := HexToInt(AnsiString(NewVal));
end;

function IntToHexFirstLow(Val: Int64; Size: Integer): AnsiString;
var
  i: Integer;
  HexVal, NewVal: AnsiString;
begin
  NewVal := '';
  HexVal := AnsiString(IntToHex(Val, Size));
  if Length(HexVal) mod 2 = 1 then
    HexVal := '0' + HexVal;
  for i := Length(HexVal) downto 1 do
  begin
    if i mod 2 = 0 then
      NewVal := NewVal + AnsiChar(HexToInt(HexVal[i - 1] + HexVal[i]));
  end;
  Result := NewVal;
end;

function IntToHexFirstHigh(Val: Int64; Size: Integer): AnsiString;
var
  i: Integer;
  HexVal, NewVal: AnsiString;
begin
  NewVal := '';
  HexVal := AnsiString(IntToHex(Val, Size));
  if Length(HexVal) mod 2 = 1 then
    HexVal := '0' + HexVal;

  for i := 1 to Length(HexVal) do
  begin
    if i mod 2 = 0 then
      NewVal := NewVal + AnsiChar(HexToInt(HexVal[i - 1] + HexVal[i]));
  end;
  Result := NewVal;
end;

{$IFEND}

function HexToBinStr(const Value: AnsiString; BufSize: Integer): AnsiString;
var
  S: AnsiString;
  StrLen, _BufSize: Integer;
begin
  if BufSize = 0 then
    StrLen := Length(Value)
  else
    StrLen := BufSize * 2;

  _BufSize := StrLen div 2;

  S := Copy(Value, 1, StrLen);
  while Length(S) < StrLen do
    S := '0' + S;

  SetLength(Result, _BufSize);
  HexToBin(PAnsiChar(@S[1]), PAnsiChar(@Result[1]), _BufSize);
end;

function BinStrToHex(const Value: AnsiString; BufSize: Integer = 0): AnsiString;
var
  S: AnsiString;
  BCDLen: Integer;
begin
  if BufSize = 0 then
    BCDLen := Length(Value)
  else
    BCDLen := BufSize;

  S := Copy(Value, 1, BCDLen);
  while Length(S) < BCDLen do
    S := #0 + S;

  SetLength(Result, BCDLen * 2);
  BinToHex(PAnsiChar(@S[1]), PAnsiChar(@Result[1]), BCDLen);
end;

function BCDToInt(Value: Pointer; Size: Integer = 1): Int64;
var
  S: AnsiString;
begin
  SetLength(S, Size * 2);
  BinToHex(PAnsiChar(Value), PAnsiChar(@S[1]), Size);
  Result := StrToInt64Def(string(S), 0);
end;

function BCDToStr(Value: Pointer; Size: Integer = 1): AnsiString;
var
  S: AnsiString;
begin
  SetLength(S, Size * 2);
  BinToHex(PAnsiChar(Value), PAnsiChar(@S[1]), Size);
  Result := S;
end;

function IntToBCDStr(Value: Int64; Size: Integer): AnsiString;
var
  S: AnsiString;
begin
  S := AnsiString(IntToStr(Value));
  Result := HexToBinStr(S, Size);
end;

function CheckBit(Value, N: Integer): Boolean;
var
  Mask: Integer;
begin
  Mask := 1 shl N;
  Result := (Value and Mask) > 0;
end;

procedure SetBit(var Value: Byte; N: Integer);
var
  Mask: Integer;
begin
  Mask := 1 shl N;
  Value := Value or Mask;
end;

procedure SetBit(var Value: Integer; N: Integer); overload;
var
  Mask: Integer;
begin
  Mask := 1 shl N;
  Value := Value or Mask;
end;

procedure SetBit(var Value: Integer; N: Integer; BitValue: Boolean);
var
  Mask: Integer;
begin
  Mask := 1 shl N;

  if BitValue then
    Value := Value or Mask
  else
    Value := Value and (not Mask);
end;

procedure SetBit(var Value: Byte; N: Integer; BitValue: Boolean); overload;
var
  Mask: Integer;
begin
  Mask := 1 shl N;

  if BitValue then
    Value := Value or Mask
  else
    Value := Value and (not Mask);
end;

function SetBits(b7, b6, b5, b4, b3, b2, b1, b0: Boolean): Byte;
begin
  Result := 0;
  if b0 then
    Result := Result or $01;
  if b1 then
    Result := Result or $02;
  if b2 then
    Result := Result or $04;
  if b3 then
    Result := Result or $08;
  if b4 then
    Result := Result or $10;
  if b5 then
    Result := Result or $20;
  if b6 then
    Result := Result or $40;
  if b7 then
    Result := Result or $80;
end;

function ConvertAnsiToOem(const S: AnsiString): AnsiString;
begin
  SetLength(Result, Length(S));
  if Length(Result) > 0 then
    AnsiToOem(PAnsiChar(S), PAnsiChar(Result));
end;

function ConvertOemToAnsi(const S: AnsiString): AnsiString;
begin
  SetLength(Result, Length(S));
  if Length(Result) > 0 then
    OemToAnsi(PAnsiChar(S), PAnsiChar(Result));
end;

procedure SetCtlNumberMode(WinCtl: TWinControl);
var
  OldLong: Integer;
  hnd: Hwnd;
  Info: TComboBoxInfo;
begin
  if WinCtl is TCustomCombo then
  begin
    Info.cbSize := SizeOf(Info);
    GetComboBoxInfo(WinCtl.Handle, Info);
    hnd := Info.hwndItem;
  end
  else
    hnd := WinCtl.Handle;

  // Запретим ввод всего, кроме цифр
  OldLong := GetWindowLongA(hnd, GWL_STYLE);
  SetWindowLongA(hnd, GWL_STYLE, OldLong or ES_NUMBER);
end;

procedure SetCtlsNumberMode(WinCtls: array of TWinControl);
var
  i: Integer;
begin
  for i := 0 to Length(WinCtls) - 1 do
    SetCtlNumberMode(WinCtls[i]);
end;

function CenterStrA(const S: AnsiString; Len: Integer): AnsiString;
var
  StrLen, Delta1, Delta2: Integer;
begin
  Result := Trim(S);
  StrLen := Length(Result);

  Delta1 := (Len - StrLen) div 2;
  Delta2 := Len - StrLen - Delta1;
  if Delta1 > 0 then
    Result := StringOfChar(AnsiChar(' '), Abs(Delta1)) + Result +
      StringOfChar(AnsiChar(' '), Abs(Delta2))
  else
    Result := Copy(Result, Abs(Delta1) + 1, StrLen - Abs(Delta1) - Abs(Delta2));
end;

function CenterStr(const S: string; Len: Integer): string;
var
  StrLen, Delta1, Delta2: Integer;
begin
  Result := Trim(S);
  StrLen := Length(Result);

  Delta1 := (Len - StrLen) div 2;
  Delta2 := Len - StrLen - Delta1;
  if Delta1 > 0 then
    Result := StringOfChar(' ', Abs(Delta1)) + Result +
      StringOfChar(' ', Abs(Delta2))
  else
    Result := Copy(Result, Abs(Delta1) + 1, StrLen - Abs(Delta1) - Abs(Delta2));
end;

function FormatRecLineA(const StrL, StrR: AnsiString; LineLen: Byte;
  Ch: AnsiChar): AnsiString;
begin
  if Length(StrR) >= LineLen then
  begin
    Result := Copy(StrR, 1, LineLen);
    Exit;
  end;

  Result := Copy(StrL, 1, LineLen - Length(StrR));
  Result := Result + StringOfChar(Ch, LineLen - Length(StrR) -
    Length(Result)) + StrR;
end;

function FormatRecLine(const StrL, StrR: string; LineLen: Byte;
  Ch: Char = ' '): string;
begin
  if Length(StrR) >= LineLen then
  begin
    Result := Copy(StrR, 1, LineLen);
    Exit;
  end;

  Result := Copy(StrL, 1, LineLen - Length(StrR));
  Result := Result + StringOfChar(Ch, LineLen - Length(StrR) -
    Length(Result)) + StrR;
end;

function ClearStringA(const Str: AnsiString): AnsiString;
var
  i: Integer;
begin
  Result := Str;
  for i := Length(Result) downto 1 do
    if Ord(Result[i]) = 9 then
      Result[i] := Char(32)
    else if Ord(Result[i]) = 160 then
      Result[i] := Char(32)
    else if Ord(Result[i]) < 32 then
      Delete(Result, i, 1);
end;

function ClearStringAExceptWrap(const Str: AnsiString): AnsiString;
var
  i: Integer;
begin
  Result := Str;
  for i := Length(Result) downto 1 do
    if (Ord(Result[i]) = 13) then
      continue
    else if Ord(Result[i]) = 9 then
      Result[i] := Char(32)
    else if Ord(Result[i]) = 160 then
      Result[i] := Char(32)
    else if Ord(Result[i]) < 32 then
      Delete(Result, i, 1);
end;

procedure SeparateString(const Str: string; var StringsArr: TStringsArray;
  Len: Integer);
var
  i, N: Integer;
begin
  // Разобъем строку на массив строк
  N := (Length(Str) div Integer(Len));
  if (Length(Str) mod Integer(Len)) > 0 then
    Inc(N);
  SetLength(StringsArr, N);
  for i := 0 to N - 1 do
    StringsArr[i] := Copy(Str, i * Integer(Len) + 1, Len);
end;

function WordToBinStrRev(const Value: Word): AnsiString;
begin
  Result := AnsiChar(HiByte(Value)) + AnsiChar(LoByte(Value));
end;

function BinStrRevToDWord(const Value: AnsiString): DWORD;
begin
  Result := 0;
  if Length(Value) < 4 then
    Exit;

  Result := Ord(Value[4]) + Ord(Value[3]) shl 8 + Ord(Value[2]) shl 16 +
    Ord(Value[1]) shl 32;
end;

procedure ProcessMessages;
var
  Msg: TMsg;

  function ProcessMessage(var Msg: TMsg): Boolean;
  begin
    Result := False;
    try
      if PeekMessage(Msg, 0, 0, 0, PM_REMOVE) then
      begin
        Result := True;
        TranslateMessage(Msg);
        DispatchMessage(Msg);
      end;
    except
    end;
  end;

begin
  while ProcessMessage(Msg) do;
end;

procedure Wait(Value: Cardinal);
var
  gtEnd: Cardinal;
begin
  gtEnd := GetTickCount + Value;
  while gtEnd > GetTickCount do
  begin
    ProcessMessages;
    Sleep(1);
  end;
end;

function ExecuteApplication(const App, Str: string; HideWnd: Boolean = False;
  MaximizeWnd: Boolean = False; WaitForTerminate: Boolean = False;
  X: Integer = 0; Y: Integer = 0; XSize: Integer = 0;
  YSize: Integer = 0): THandle;
var
  SI: TStartupInfo;
  PI: TProcessInformation;
  BoolResult: Boolean;
begin
  Result := INVALID_HANDLE_VALUE;
  FillChar(SI, SizeOf(TStartupInfo), 0);
  with SI do
  begin
    cb := SizeOf(TStartupInfo);
    dwFlags := STARTF_USESHOWWINDOW or STARTF_FORCEONFEEDBACK;
  end;

  if HideWnd then
    SI.wShowWindow := SW_HIDE
  else if MaximizeWnd then
    SI.wShowWindow := SW_SHOWMAXIMIZED
  else
    SI.wShowWindow := SW_SHOWNORMAL;

  if (X > 0) or (Y > 0) then
  begin
    SI.dwFlags := SI.dwFlags or STARTF_USEPOSITION;
    SI.dwX := X;
    SI.dwY := Y;
  end;

  if (XSize > 0) and (YSize > 0) then
  begin
    SI.dwFlags := SI.dwFlags or STARTF_USESIZE;
    SI.dwXSize := XSize;
    SI.dwYSize := YSize;
  end;

  BoolResult := CreateProcess(PChar(App), PChar(Str), nil, nil, False,
    CREATE_DEFAULT_ERROR_MODE or NORMAL_PRIORITY_CLASS, nil, nil, SI, PI);

  if BoolResult then
    with PI do
    begin
      Result := dwProcessId;
      WaitForInputIdle(hProcess, { 3000 } INFINITE);
      // ждем завершения инициализации
      if WaitForTerminate then
      begin
        WaitForSingleObject(hProcess, INFINITE); // ждем завершения процесса
        // получаем код завершения
        GetExitCodeProcess(hProcess, Cardinal(ExitCode));
        if ExitCode <> 0 then
          raise Exception.CreateFmt(RsErrExitCode, [App]);
      end;
      CloseHandle(hThread); // закрываем дескриптор процесса
      CloseHandle(hProcess); // закрываем дескриптор потока
    end
end;

function Get_NewEnum(Value: OleVariant): IEnumVariant;
var
  Status: Integer;
  Dispatch: IDispatch;
  ExcepInfo: TExcepInfo;
  DispParams: TDispParams;
  Res: Variant;
begin
  FillChar(ExcepInfo, SizeOf(ExcepInfo), 0);
  FillChar(DispParams, SizeOf(DispParams), 0);
  Dispatch := IDispatch(Value);
  Res := Unassigned;
  Status := Dispatch.Invoke(DISPID_NEWENUM, GUID_NULL, 0, DISPATCH_METHOD,
    DispParams, @Res, @ExcepInfo, nil);
  if Status = 0 then
  begin
    Result := IEnumVariant(IDispatch(TVarData(Res).vDispatch));
    Result.Reset;
  end
  else
    OleCheck(Status);
end;

function Get_NextElement(var Value: OleVariant; _Enum: IEnumVariant): Boolean;
var
  i: Cardinal;
begin
  VarClear(Value);
  Result := _Enum.Next(1, Value, i) = S_Ok;
end;

function NewXMLObject: OleVariant;
begin
  try
    Result := CreateOleObject('Msxml2.DOMDocument');
  except
    Result := CreateOleObject('MSXML.DOMDocument');
  end;
  Result.setProperty('SelectionLanguage', 'XPath');
end;

function NewXMLObject(const RootName, ProcessingInstruction: WideString)
  : OleVariant;
var
  Root, PI: OleVariant;
begin
  Result := NewXMLObject;
  if ProcessingInstruction <> '' then
  begin
    Root := Result.documentElement;
    PI := Result.createProcessingInstruction('xml', ProcessingInstruction);
    Result.insertBefore(PI, Root);
  end;
  if RootName <> '' then
  begin
    Root := Result.CreateElement(RootName);
    Result.documentElement := Root;
  end;
  Result.Async := False;
end;

function VarToIntDef(const V: Variant; const ADefault: Integer): Integer;
begin
  if (not VarIsNull(V)) and (not VarIsEmpty(V)) then
    Result := StrToIntDef(Trim(VarToStr(V)), ADefault)
  else
    Result := ADefault;
end;

function VarToDoubleDef(const V: Variant; const ADefault: Double): Double;
begin
  if (not VarIsNull(V)) and (not VarIsEmpty(V)) then
    Result := StrToFloatDef(Trim(VarToStr(V)), ADefault)
  else
    Result := ADefault;
end;

function VarToCurrDef(const V: Variant; const ADefault: Currency): Currency;
begin
  if (not VarIsNull(V)) and (not VarIsEmpty(V)) then
    if VarIsStr(V) then
      Result := StrToCurrDef(V, 0)
    else
      Result := V
  else
    Result := ADefault;
end;

function VarToCurrDef(const V: Variant; const ADefault: Currency;
  AFormatSettings: TFormatSettings): Currency; overload;
begin
  if (not VarIsNull(V)) and (not VarIsEmpty(V)) then
    if VarIsStr(V) then
      Result := StrToCurrDef(V, 0, AFormatSettings)
    else
      Result := V
  else
    Result := ADefault;
end;

function VarToBoolDef(const V: Variant; const ADefault: Boolean): Boolean;
var
  S: string;
begin
  if (not VarIsNull(V)) and (not VarIsEmpty(V)) then
  begin
    if VarIsStr(V) then
    begin
      S := VarToStr(V);
      if SameText(S, DefaultTrueBoolStr) then
        Result := True
      else if SameText(S, DefaultFalseBoolStr) then
        Result := False
      else
        Result := ADefault;
    end
    else
      Result := V;
  end
  else
    Result := ADefault;
end;

function VarToStringDef(const V: Variant; const ADefault: string): string;
begin
  if (not VarIsNull(V)) and (not VarIsEmpty(V)) then
    Result := VarToStr(V)
  else
    Result := ADefault;
end;

function VarToDateDef(const V: Variant; const ADefault: TDateTime): TDateTime;
begin
  if (not VarIsNull(V)) and (not VarIsEmpty(V)) then
  begin
    if VarIsStr(V) then
    begin
{$IF CompilerVersion > 29}
      if not TryStrToDateTime(V, Result) then
      begin
        if not TryISO8601ToDate(V, Result) then
          Result := VarToDateTime(V);
      end;
{$ELSE}
      if not TryStrToDateTime(V, Result) then
        Result := VarToDateTime(V);
{$IFEND}
    end
    else
      Result := VarToDateTime(V);
  end
  else
    Result := ADefault;
end;

function VarIsEmptyStr(const Value: Variant): Boolean;
begin
  if VarIsStr(Value) and (Value <> '') then
    Result := False
  else
    Result := True;
end;

function GetFilesCount(const aFolder: string;
  ExcludeDirectory: Boolean = True): Integer;
var
  H: THandle;
  Data: TWin32FindData;
begin
  Result := 0;

  H := FindFirstFile(PChar(aFolder + '*.*'), Data);
  if H <> INVALID_HANDLE_VALUE then
    repeat
      if ExcludeDirectory then
        Inc(Result, Ord(Data.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY = 0))
      else
        Inc(Result);
    until not FindNextFile(H, Data);
  Windows.FindClose(H);
end;

function CorrectLineBreaks(const Text: string): string;
begin
  Result := StringReplace(Text, sLineBreak, #$1, [rfReplaceAll]);
  Result := StringReplace(Result, #$A, #$1, [rfReplaceAll]);
  Result := StringReplace(Result, #$D, #$1, [rfReplaceAll]);
  Result := StringReplace(Result, #$1, sLineBreak, [rfReplaceAll]);
end;

procedure TextStrToStrings(const Text: string; sl: TStrings);
var
  S: string;
begin
  if sl = nil then
    Exit;

  S := CorrectLineBreaks(Text);
  sl.LineBreak := sLineBreak;
  sl.Text := S;
end;

function EncodeBase64(Value: string): string;
const
  b64alphabet
    : PChar = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
  pad: PChar = '====';

  function EncodeChunk(const Chunk: string): string;
  var
    W: LongWord;
    i, N: Byte;
  begin
    N := Length(Chunk);
    W := 0;
    for i := 0 to N - 1 do
      W := W + Ord(Chunk[i + 1]) shl ((2 - i) * 8);
    Result := b64alphabet[(W shr 18) and $3F] + b64alphabet[(W shr 12) and $3F]
      + b64alphabet[(W shr 06) and $3F] + b64alphabet[(W shr 00) and $3F];
    if N <> 3 then
      Result := Copy(Result, 0, N + 1) + Copy(pad, 0, 3 - N);
    // add padding when out len isn't 24 bits
  end;

begin
  Result := '';
  while Length(Value) > 0 do
  begin
    Result := Result + EncodeChunk(Copy(Value, 0, 3));
    Delete(Value, 1, 3);
  end;
end;

function DecodeBase64(Value: string): string;
const
  b64alphabet
    : PChar = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
  function DecodeChunk(const Chunk: string): string;
  var
    W: LongWord;
    i: Byte;
  begin
    W := 0;
    Result := '';
    for i := 1 to 4 do
      if Pos(Chunk[i], b64alphabet) <> 0 then
        W := W + Word((Pos(Chunk[i], b64alphabet) - 1)) shl ((4 - i) * 6);
    for i := 1 to 3 do
      Result := Result + Chr(W shr ((3 - i) * 8) and $FF);
  end;

begin
  Result := '';
  if Length(Value) mod 4 <> 0 then
    Exit;
  while Length(Value) > 0 do
  begin
    Result := Result + DecodeChunk(Copy(Value, 0, 4));
    Delete(Value, 1, 4);
  end;
end;

function CastGUID(const aGUIDStr: Variant; aBracket: Boolean = True): Variant;
var
  S: string;
begin
  Result := aGUIDStr;
  S := Trim(aGUIDStr);
  if S = EmptyStr then
    Exit;
  if aBracket then
  begin
    if S[1] <> '{' then
      S := '{' + S + '}';
  end
  else if S[1] = '{' then
    S := Copy(S, 2, Length(S) - 2);
  Result := S;
end;

function Extract1CSOAPError(const E: Exception;
  const APrefix: string = c1C_WS_Error_Prefix): string;
var
  i: Integer;
begin
  Result := E.Message;
  i := 1;
  repeat
    // сообщения от 1С дублируются в стеке
    // берём самое последнее
    i := StrUtils.PosEx(APrefix, Result, i);
    if i > 0 then
      Result := Trim(Copy(Result, i + Length(APrefix), Length(Result)));
  until i <= 0;
end;

function ByteToBinStr(Value: Byte): string;
var
  i: Integer;
const
  BytePowers: array [1 .. 8] of Byte = (128, 64, 32, 16, 8, 4, 2, 1);
begin
  Result := '00000000'; { "default" value }
  if (Value <> 0) then
    for i := 1 to 8 do
      if (Value and BytePowers[i]) <> 0 then
        Result[i] := '1';
end;

function StrCenter(const Str: string; Len: Integer): string;
begin
  Result := Trim(Str);
  while Length(Result) < Integer(Len) do
    Result := Char(32) + Result + Char(32);
  Result := Copy(Result, 1, Len);
end;

function AddLeadZero(const Number, Length: Int64): string;
var
  i, Len: Integer;
begin
  Result := IntToStr(Number);
  Len := Length - System.Length(Result);
  for i := 1 to Len do
    Result := '0' + Result;
end;

procedure ReverseBytes(var ABytes: TBytes);
var
  i, Len: Integer;
  b: Byte;
begin
  Len := Length(ABytes);

  for i := 0 to (Len div 2) - 1 do
  begin
    b := ABytes[i];
    ABytes[i] := ABytes[Len - 1 - i];
    ABytes[Len - 1 - i] := b;
  end;
end;

function GetAttribute(const Node: Variant; AttrName, DefValue: string): string;
var
  Ov: OleVariant;
  vd: TVarData;
begin
  Result := DefValue;
  vd := TVarData(Node);
  if vd.vDispatch <> nil then
  begin
    Ov := Node.GetAttribute(AttrName);
    if Ov <> Null then
      Result := Ov;
  end;
end;

{$IF CompilerVersion > 24}

function CheckUuid(const AUuid: string): Boolean;
begin
  Result := TRegEx.IsMatch(AUuid,
    '^[0-9A-Fa-f]{8}\-[0-9A-Fa-f]{4}\-[0-9A-Fa-f]{4}\-[0-9A-Fa-f]{4}\-[0-9A-Fa-f]{12}$');
end;

{ TStringHelper }

function TAnsiStringHelper.Split(Separator: AnsiChar): TArray<AnsiString>;
var
  i: Integer;
  LStr: AnsiString;
begin
  SetLength(Result, 0);

  LStr := '';
  for i := Low(Self) to High(Self) do
  begin
    if Self[i] = Separator then
    begin
      SetLength(Result, Length(Result) + 1);
      Result[Length(Result) - 1] := LStr;
      LStr := '';
    end
    else
      LStr := LStr + Self[i];
  end;

  if LStr <> '' then
  begin
    SetLength(Result, Length(Result) + 1);
    Result[Length(Result) - 1] := LStr;
  end;
end;
{$IFEND}

end.
