unit CustomUtil;

interface
uses
  Windows,PsAPI,ShellAPI,SysUtils;

function GetProcessIcoByPid(Pid : Cardinal): HICON;
{ 通过 THandle 获取图标}
function GetProcessIco(pHandle: THandle): HICON;
procedure FreeIcon(icon : HICON);
function AddFileTimes(KernelTime, UserTime: TFileTime): TDateTime;
{ 获取进程用户 }
function GetProcessUser(hprocess: THandle): string;
function GetProcessUserByPic(Pid : Cardinal): string;
{ 好像提不提权都一样 。。。 }
function PromoteProcessPrivilege(Processhandle:Thandle;Token_Name:pchar):boolean;
function PriorityToStr(priority: Cardinal): string;

implementation

function GetProcessIco(pHandle: THandle): HICON;
var
  lpiIcon: Word;
  buf: array[0..MAX_PATH] of WideChar;
begin
  lpiIcon := 0;
  GetModuleFileNameEx(pHandle, 0, buf, Length(buf));
  Result := ExtractAssociatedIcon(HInstance,buf, lpiIcon);
end;

function GetProcessIcoByPid(Pid : Cardinal): HICON;
begin
  Result := GetProcessIco( OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ,False,Pid));
end;

function AddFileTimes(KernelTime, UserTime: TFileTime): TDateTime;
var
  SysTimeK, SysTimeU: TSystemTime;
begin
  FileTimeToSystemTime(KernelTime, SysTimeK);
  FileTimeToSystemTime(UserTime, SysTimeU);
  Result :=SystemTimeToDateTime(SysTimeK)+SystemTimeToDateTime(SysTimeU);
end;

procedure FreeIcon(icon : HICON);
begin

end;

function GetProcessUserByPic(Pid : Cardinal): string;
begin
 Result := GetProcessUser( OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ,False,Pid));
end;

function GetProcessUser(hprocess: THandle): string;
var
  hToken:THandle;
  dwSize,dwUserSize,dwDomainSize:DWORD;
  pUser:PTokenUser;
  szUserName, szDomainName: array of Char;
  peUse:   SID_NAME_USE;
begin
  if not OpenProcessToken(hprocess,TOKEN_QUERY,hToken) then Exit;

  GetTokenInformation(hToken,TokenUser,nil,0,dwSize);
  pUser := nil;
  ReallocMem(pUser,dwSize);
  dwUserSize := 0;
  dwDomainSize := 0;

  if not GetTokenInformation(hToken,TokenUser,pUser,dwSize,dwSize) then Exit;
  LookupAccountSid(nil,pUser.User.Sid,nil,dwUserSize,nil,dwDomainSize,peUse);
  if (dwUserSize <> 0) and (dwDomainSize <> 0) then
  begin
    SetLength(szUserName,dwUserSize);
    SetLength(szDomainName,dwDomainSize);
    LookupAccountSid(nil,pUser.User.Sid,PChar(szUserName),dwUserSize,PChar(szDomainName),dwDomainSize,peUse);
  end;
  Result := PChar(szUserName);
  Result := Result +'/';
  Result := Result +PChar(szDomainName);
  CloseHandle(hToken);
  FreeMem(pUser);
end;

function PromoteProcessPrivilege(Processhandle:Thandle;Token_Name:pchar):boolean;
var
    Token:cardinal;
    TokenPri:_TOKEN_PRIVILEGES;
    Luid:int64;
    i:DWORD;
begin
    Result:=false;
    if OpenProcessToken(Processhandle,TOKEN_ADJUST_PRIVILEGES,Token) then
    begin
        if LookupPrivilegeValue(nil,Token_Name,Luid) then
        begin
            TokenPri.PrivilegeCount:=1;
            TokenPri.Privileges[0].Attributes:=SE_PRIVILEGE_ENABLED;
            TokenPri.Privileges[0].Luid:=Luid;
            i:=0;
            if AdjustTokenPrivileges(Token,false,TokenPri,sizeof(TokenPri),nil,i) then
                Result:=true;
        end;
    end;
    CloseHandle(Token);
end;

function PriorityToStr(priority: Cardinal): string;
begin
  case priority of
    IDLE_PRIORITY_CLASS: Result := 'IDLE';
    NORMAL_PRIORITY_CLASS: Result := 'NORMAL';
    HIGH_PRIORITY_CLASS: Result := 'HIGH';
    REALTIME_PRIORITY_CLASS: Result := 'REALTIME';
  end;
end;
end.
