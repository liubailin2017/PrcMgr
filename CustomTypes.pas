unit CustomTypes;

interface

uses
  Graphics,Windows,uCpuUsage,Generics.Collections;

type
 { һ��������Ϣ��¼  }
TProcessInfo = class
  pid : THandle;
  Name : string;
  MemUsg : Integer;
  CPUUsg : Single;
  Priority : string;
  UserName : string;
  //icon : HICON; { ��ͼ��ľ�� }
  AbsolutePath : string;
  imageindex:Integer;
  tag:Byte;
end;
PTProcessInfo = ^TProcessInfo;

{ ������Ϣ�Ļ��� }
type
TProcessInfoCache = class
  icon : HICON;
  index : Integer;
  CPUUsageData :PCPUUsageData;
  IsAlive : Boolean; { û����ѯ�ͱ����յ��ڴ� }
  destructor Destroy; override;
end;


implementation

   destructor TProcessInfoCache.Destroy;
   begin
      wsDestroyUsageCounter(CPUUsageData);
   end;

end.
