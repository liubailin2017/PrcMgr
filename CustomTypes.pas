unit CustomTypes;

interface

uses
  Graphics,Windows,uCpuUsage;

type
 { һ��������Ϣ��¼  }
ProcessInfo = class
  pid : THandle;
  Name : string;
  MemUsg : Integer;
  CPUUsg : Integer;
  Priority : string;
  UserName : string;
  icon : HICON; { ��ͼ��ľ�� }
end;

{ ������Ϣ�Ļ��� }
type
ProcessInfoCache = class
  icon : HICON;
  CPUUsageData :TCPUUsageData;
end;

implementation

end.
