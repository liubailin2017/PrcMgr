unit CustomTypes;

interface

uses
  Graphics,Windows,uCpuUsage,Generics.Collections;

type
 { 一条进程信息记录  }
TProcessInfo = class
  pid : THandle;
  Name : string;
  MemUsg : Integer;
  CPUUsg : Single;
  Priority : string;
  UserName : string;
  //icon : HICON; { 存图标的句柄 }
  AbsolutePath : string;
  imageindex:Integer;
  tag:Byte;
end;
PTProcessInfo = ^TProcessInfo;

{ 进程信息的缓存 }
type
TProcessInfoCache = class
  icon : HICON;
  index : Integer;
  CPUUsageData :PCPUUsageData;
  IsAlive : Boolean; { 没被查询就被回收掉内存 }
  destructor Destroy; override;
end;


implementation

   destructor TProcessInfoCache.Destroy;
   begin
      wsDestroyUsageCounter(CPUUsageData);
   end;

end.
