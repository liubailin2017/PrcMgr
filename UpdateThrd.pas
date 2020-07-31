unit UpdateThrd;

interface

uses
  TlHelp32, {CreateToolhelp32Snapshot }
  Windows, SysUtils, Classes,
  CustomTypes, CustomUtil, uCpuUsage,
  Generics.Collections, { TList,TDictionary}
  Graphics, { Ticon }
  PsAPI, { GetProcessMemoryInfo }
  CompareForProcess;

type
  TSetData = procedure(list: TList; P : Pointer) of object;
//type
//  TSetData2 = procedure(list: TList;P: PTDictionary) of object;

type
  TUpdateThrd = class(TThread)
  private
    CacheDict: TDictionary<Cardinal, TProcessInfoCache>;
    list: TList;
    OrderColum: Integer;
    up: Boolean;
    IsQuit: Boolean;
  protected
  public
    cbSetData: TSetData;
    { 选择用哪一列排序  }
    procedure ChooseOrderByColum(colum: Integer; up: Boolean);
    procedure Quit();
    procedure sort;
    constructor Create;
    destructor Destroy; override;
    procedure Execute; override;
    procedure clear;
    procedure setData;
  end;

implementation

procedure TUpdateThrd.setData;
begin
  if Assigned(cbSetData) then
  begin
    cbSetData(list,CacheDict);
  end;
end;

procedure TUpdateThrd.clear;
var
  I: Integer;
  t: TProcessInfo;
begin
  for I := 0 to List.Count - 1 do
  begin
    t := list.Items[I];
    t.Free;
  end;

  list.Clear;
end;

procedure TUpdateThrd.Execute;
var
  HwndHelp, hProcess: Thandle;
  fprocessentry32: TProcessEntry32;
  pPMC: PPROCESS_MEMORY_COUNTERS;
  pPMCSize: Cardinal;
  More: Boolean;
  icon: TIcon;
  prcsInfo: TProcessInfo;
  prcinfCache: TProcessInfoCache;
  n : integer;
begin
n := 0;
//    PromoteProcessPrivilege(GetCurrentProcess,'SeDebugPrivilege');
  icon := TIcon.Create;
  pPMCSize := Sizeof(PROCESS_MEMORY_COUNTERS);
  GetMem(pPMC, pPMCSize);
  pPMC^.cb := pPMCSize;
  while not IsQuit do
  begin
    clear;
    HwndHelp := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    fprocessentry32.dwSize := sizeof(fprocessentry32);
    More := Process32First(HwndHelp, fprocessentry32);
    while More do
    begin
      More := Process32Next(HwndHelp, fprocessentry32);
      prcsInfo := TProcessInfo.Create;
      prcsInfo.ImageIndex := -1;
      prcsInfo.pid := fprocessentry32.th32ProcessID;
      prcsInfo.Name := fprocessentry32.szExeFile;

      hProcess := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, False, prcsInfo.pid);
      begin  { 获取内存使用 }
        if GetProcessMemoryInfo(hProcess, pPMC, pPMCSize) then
        begin
          prcsInfo.MemUsg := pPMC^.WorkingSetSize div 1000; { 暂时用这个 }
        end
        else
          prcsInfo.MemUsg := -1;
      end;
          { 优先级  }
      prcsInfo.Priority := PriorityToStr(GetPriorityClass(hProcess));
          { 用户 }
      prcsInfo.UserName := GetProcessUser(hProcess);

      if not CacheDict.ContainsKey(prcsInfo.pid) then
      begin
        prcinfCache := TProcessInfoCache.Create;
//        prcsInfo.icon := GetProcessIco(hProcess);
//        prcinfCache.icon := prcsInfo.icon;
        prcsInfo.AbsolutePath := GetProcessFullName(hProcess);
        prcinfCache.CPUUsageData := wsCreateUsageCounter(prcsInfo.pid);
        wsGetCpuUsage(prcinfCache.CPUUsageData);
        prcsInfo.CPUUsg := 0;
        CacheDict.Add(prcsInfo.pid, prcinfCache);
      end
      else
      begin
        prcinfCache := CacheDict[prcsInfo.pid];
//        prcsInfo.icon := prcinfCache.icon;
        prcsInfo.CPUUsg := wsGetCpuUsage(prcinfCache.CPUUsageData);
        prcsInfo.imageindex := prcinfCache.index;
      end;
      Inc(n);
      list.Add(prcsInfo);
    end;

    sort;
    setData;
    Sleep(500);
  end;
  FreeMem(pPMC);
  icon.Free;
end;

constructor TUpdateThrd.Create;
begin
  inherited Create(True);
  CacheDict := TDictionary<Cardinal, TProcessInfoCache>.Create;
  list := TList.Create;
  IsQuit := False;
end;

destructor TUpdateThrd.Destroy;
var
  prcinfCache: TProcessInfoCache;
  I: Integer;
  key: Integer;
begin
  for key in CacheDict.Keys do
  begin
    prcinfCache := CacheDict.Items[key];
    prcinfCache.Free;
  end;
  CacheDict.Keys.Free; { 必须手动释放这个？  }
  CacheDict.Free;
  clear;
  list.Free;
  list := nil;
end;

procedure TUpdateThrd.ChooseOrderByColum(colum: Integer; up: Boolean);
begin
  if (colum >= 0) and (colum <= 5) then
    OrderColum := colum;
  Self.up := up;
end;

procedure TUpdateThrd.Quit();
begin
  IsQuit := True;
end;

procedure TUpdateThrd.sort;
var
  comparefun: TListSortCompare;
begin
  if up then
  begin
    if OrderColum = 0 then
    begin
      comparefun := CompareNmU;
    end
    else if OrderColum = 1 then
    begin
      comparefun := CompareMemU;
    end
    else if OrderColum = 2 then
    begin
      comparefun := CompareCpuU;
    end
    else if OrderColum = 3 then
    begin
      comparefun := ComparePriU;
    end
    else if OrderColum = 4 then
    begin
      comparefun := CompareUNmU;
    end;
  end
  else
  begin
    if OrderColum = 0 then
    begin
      comparefun := CompareNmD;
    end
    else if OrderColum = 1 then
    begin
      comparefun := CompareMemD;
    end
    else if OrderColum = 2 then
    begin
      comparefun := CompareCpuD;
    end
    else if OrderColum = 3 then
    begin
      comparefun := ComparePriD;
    end
    else if OrderColum = 4 then
    begin
      comparefun := CompareUNmD;
    end;
  end;
  list.Sort(comparefun);
end;

end.

