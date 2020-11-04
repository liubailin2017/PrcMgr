{
(c) Janis Elsts, http://w-shadow.com/
Last Updated : 27.08.2006

uCpuUsage.pas provides some functions that let you
get the CPU usage (in percent) of a given process. Note that
the usage is calculated for a *period of time* elapsed since
last wsCreateUsageCounter or wsGetCpuUsage call for that process.
This unit is freeware, feel free to use/modify in any way you like.

Using this unit :

  cnt : PCPUUsageData;
  ....
  //Initialize the counter
  cnt:=wsCreateUsageCounter(Process_id);
  //Allow for some time to elapse
  Sleep(500);
  //Get the CPU usage
  usage:=wsGetCpuUsage(cnt);
  //The returned value is a real number between 0 and 100 (representint %).
  //Destroy the counter and free memory
  wsDestroyUsageCounter(cnt);
}

unit uCpuUsage;

interface
const
 wsMinMeasurementInterval=250; {minimum amount of time that must
 have elapsed to calculate CPU usage, miliseconds. If time elapsed
 is less than this, previous result is returned, or zero, if there
 is no previous result.}

type
  TCPUUsageData=record
    PID,Handle:cardinal;
    oldUser,oldKernel:Int64;
    LastUpdateTime:cardinal;
    LastUsage:single; //Last result of wsGetCpuUsage is saved here
    Tag:cardinal; //Use it for anythin you like, not modified by this unit
  end;
  PCPUUsageData=^TCPUUsageData;

function wsCreateUsageCounter(PID:cardinal):PCPUUsageData;
function wsGetCpuUsage(aCounter:PCPUUsageData):single;
procedure wsDestroyUsageCounter(aCounter:PCPUUsageData);
function GetCpuUsage_slowly(PID:cardinal):single;
function GetCpuNmb(): Integer;

implementation

uses Windows;
const
  PROCESS_QUERY_LIMITED_INFORMATION = 4096;
var
GCpuNmb : Integer = 0;

function GetCpuNmb(): Integer;
var
  SysInfo: TSystemInfo;
begin
  if GCpuNmb =0 then
  begin
    GetSystemInfo(SysInfo);
    GCpuNmb := SysInfo.dwNumberOfProcessors;
  end
  else
  Result := GCpuNmb;
end;

function wsCreateUsageCounter(PID:cardinal):PCPUUsageData;
var
 p:PCPUUsageData;
 mCreationTime,mExitTime,mKernelTime,
 mUserTime:_FILETIME;
 h:cardinal;
begin
 result:=nil;
 //We need a handle with PROCESS_QUERY_INFORMATION privileges
  h:=OpenProcess(PROCESS_QUERY_INFORMATION,false,PID);
  if h = 0 then
  h := OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION , False, PID);
 if h=0 then exit;
   new(p);
   p.PID:=PID;
   p.Handle:=h;
   p.LastUpdateTime:=GetTickCount;
   p.LastUsage:=0;
 if GetProcessTimes(p.Handle,mCreationTime,mExitTime,mKernelTime,
                 mUserTime) then begin
  //convert _FILETIME to Int64
  p.oldKernel:=int64(mKernelTime.dwLowDateTime or
          (mKernelTime.dwHighDateTime shr 32));
  p.oldUser:=int64(mUserTime.dwLowDateTime or
          (mUserTime.dwHighDateTime shr 32));
  Result:=p;
 end else begin
  dispose(p);
 end;
end;

procedure wsDestroyUsageCounter(aCounter:PCPUUsageData);
begin
if aCounter <> nil then
begin
  CloseHandle(aCounter.Handle);
  dispose(aCounter);
end;

end;

function wsGetCpuUsage(aCounter:PCPUUsageData):single;
var
 mCreationTime,mExitTime,mKernelTime,
 mUserTime:_FILETIME;
 DeltaMs,ThisTime:cardinal;
 mKernel,mUser,mDelta:int64;
begin

  if(aCounter = nil) then
  begin
    Result := -1;
    exit;
  end;

 result:=aCounter.LastUsage;

 ThisTime:=GetTickCount;
 //Get the time elapsed since last query
 DeltaMs:=ThisTime-aCounter.LastUpdateTime;
 if DeltaMs<wsMinMeasurementInterval then exit;
 aCounter.LastUpdateTime:=ThisTime;

 GetProcessTimes(aCounter.Handle,mCreationTime,mExitTime,mKernelTime,
                 mUserTime);

 //convert _FILETIME to Int64
 mKernel:=int64(mKernelTime.dwLowDateTime or
          (mKernelTime.dwHighDateTime shr 32));
 mUser:=int64(mUserTime.dwLowDateTime or
          (mUserTime.dwHighDateTime shr 32));

 //get the delta
 mDelta:= (mUser+mKernel-aCounter.oldUser-aCounter.oldKernel) div GetCpuNmb();
 aCounter.oldUser:=mUser;
 aCounter.oldKernel:=mKernel;
 Assert(DeltaMs>0);
 Result:=(mDelta/DeltaMs)/100; //mDelta is in units of 100 nanoseconds, so...
 aCounter.LastUsage:=Result; //just in case you want to use it later, too
end;

function GetCpuUsage_slowly(PID:cardinal):single;
const
    cWaitTime=750;
var
    h : Cardinal;
    mCreationTime,mExitTime,mKernelTime, mUserTime:_FILETIME;
    TotalTime1,TotalTime2:int64;
begin
     {We need to get a handle of the process with PROCESS_QUERY_INFORMATION privileges.}
    h:=OpenProcess(PROCESS_QUERY_INFORMATION,false,PID);
    {We can use the GetProcessTimes() function to get the amount of time the process has spent in kernel mode and user mode.}
    GetProcessTimes(h,mCreationTime,mExitTime,mKernelTime,mUserTime);

    TotalTime1:=
    int64(mKernelTime.dwLowDateTime or (mKernelTime.dwHighDateTime shr 32))+
    int64(mUserTime.dwLowDateTime or (mUserTime.dwHighDateTime shr 32));

    {Wait a little}
    Sleep(cWaitTime);

    GetProcessTimes(h,mCreationTime,mExitTime,mKernelTime,mUserTime);
    TotalTime2:=
    int64(mKernelTime.dwLowDateTime or (mKernelTime.dwHighDateTime shr 32))+
    int64(mUserTime.dwLowDateTime or (mUserTime.dwHighDateTime shr 32));

    {This should work out nicely, as there were approx. 250 ms between the calls
    and the result will be a percentage between 0 and 100}
    Result:=((TotalTime2-TotalTime1)/cWaitTime)/100;
    CloseHandle(h);
end;

end.

