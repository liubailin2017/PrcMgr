unit CPUUsage;

interface
uses
Windows;

function CompareFileTime(time1 : FILETIME;time2 : FILETIME): Int64 ;

function GetSystemTimes(
lpIdleTime : PFILETIME;
lpKernelTime:PFILETIME;
lpUserTime:PFILETIME): Boolean;stdcall;


type
TCpuUsage = class
  private
    IdleTime : FILETIME;
    KernelTime:FILETIME;
    UserTime:FILETIME;
  public
  constructor Create();
  function getUsage() : Integer;
end;

implementation

constructor TCpuUsage.Create();
begin
  GetSystemTimes(@IdleTime,@KernelTime,@UserTime);
end;

function TCpuUsage.getUsage() : Integer;
var
  curIdleTime : FILETIME;
  curKernelTime:FILETIME;
  curUserTime:FILETIME;
  t1 : Int64;
  t2 : Int64;
  t3 : Int64;
begin
  GetSystemTimes(@curIdleTime,@curKernelTime,@curUserTime);
  t1 := CompareFileTime(IdleTime,curIdleTime);
  t2 := CompareFileTime(KernelTime,curKernelTime);
  t3 := CompareFileTime(UserTime,curUserTime);
  IdleTime:=curIdleTime;
  KernelTime:=curKernelTime;
  UserTime := curUserTime;
  if(t2 + t3 < 10000) then   { 如果小于1毫秒就无效 }
  begin
    Result := -1;
  end
  else
  begin
    Result := (t2 + t3 -t1) * 100 div (t2 + t3);
  end;
end;

{ t2 - t1 }
function CompareFileTime(time1 : FILETIME;time2 : FILETIME): Int64 ;
var
t2 : Int64;
t : Int64;
begin
   t  := time1.dwHighDateTime shl 32 or time1.dwLowDateTime;
  t2 := time2.dwHighDateTime shl 32 or time2.dwLowDateTime;
  Result := t2 - t;
end;

function GetSystemTimes; external kernel32 name 'GetSystemTimes';

end.

