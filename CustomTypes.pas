unit CustomTypes;

interface

uses
  Graphics,Windows,uCpuUsage;

type
 { 一条进程信息记录  }
ProcessInfo = class
  pid : THandle;
  Name : string;
  MemUsg : Integer;
  CPUUsg : Integer;
  Priority : string;
  UserName : string;
  icon : HICON; { 存图标的句柄 }
end;

{ 进程信息的缓存 }
type
ProcessInfoCache = class
  icon : HICON;
  CPUUsageData :TCPUUsageData;
end;

implementation

end.
