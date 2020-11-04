unit UpdateThrd;

interface

uses
  TlHelp32, {CreateToolhelp32Snapshot }
  Windows, SysUtils, Classes,
  CustomTypes, CustomUtil, uCpuUsage, //Generics.Collections2009,
  Generics.Collections, { TList,TDictionary}
  Graphics, { Ticon }
  PsAPI, { GetProcessMemoryInfo }
  CompareForProcess,Dialogs;
const
  PROCESS_QUERY_LIMITED_INFORMATION = 4096;
type
  TSetData = procedure(list: TList) of object;
  TAddImage = function(path : string): Integer of object;

type
  TUpdateThrd = class(TThread)
  private
    CacheDict: TDictionary<Cardinal, TProcessInfoCache>;
//    CS : TRTLCriticalSection;
    list: TList;
    list2: TList;
    OrderColum: Integer;
    up: Boolean;
    procedure setData;
    procedure sortList;
  protected
  public
    cbSetData: TSetData;
    cbAddImage: TAddImage;
    PidSelect : Integer;  { 被选中行的pid }
    { 选择用哪一列排序  }
    procedure ChooseOrderByColum(colum: Integer; up: Boolean);
    { 选中一行数据 }
    procedure Select(index : Integer);

    constructor Create;
    destructor Destroy; override;
    procedure Execute; override;
    procedure clearList;
    procedure changeList;

  end;

implementation

procedure TUpdateThrd.changeList;
var
 tmp : TList;
begin
  tmp := list;
  list := list2;
  list2 := tmp;

end;

procedure TUpdateThrd.Select(index : Integer);
var
  P : TProcessInfo;
begin

  if(list2.Count > index) then
  begin
    p := list2[index];
    PidSelect := p.pid;
  end;

end;

procedure TUpdateThrd.setData;
var
  I: Integer;
  t: TProcessInfo;
begin
  if Assigned(cbSetData) then
  begin
    changeList;
  for I := 0 to List2.Count - 1 do
  begin
    t := list2.Items[I];
    if t.pid = PidSelect then
    t.isSelected := True;
  end;
  cbSetData(list2);
  end;
end;

procedure TUpdateThrd.clearList;
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
  prcsInfo: TProcessInfo;
  prcinfCache: TProcessInfoCache;
begin
  pPMCSize := Sizeof(PROCESS_MEMORY_COUNTERS);
  GetMem(pPMC, pPMCSize);
  pPMC^.cb := pPMCSize;
  while not Terminated do
  begin

    clearList;
    HwndHelp := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    fprocessentry32.dwSize := sizeof(fprocessentry32);
    More := Process32First(HwndHelp, fprocessentry32);
    while More do
    begin
      prcsInfo := TProcessInfo.Create;
      prcsInfo.isSelected := False;
      prcsInfo.ImageIndex := -1;
      prcsInfo.pid := fprocessentry32.th32ProcessID;
      prcsInfo.Name := fprocessentry32.szExeFile;

      hProcess := OpenProcess(PROCESS_QUERY_INFORMATION , False, prcsInfo.pid);
      if hProcess <= 0 then
        hProcess := OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION , False, prcsInfo.pid);

//     if hProcess = 0 then
//       ShowMessage('errcode : ' + SysErrorMessage(GetLastError));
      { 获取内存使用 }
      if GetProcessMemoryInfo(hProcess, pPMC, pPMCSize) then
      begin
        prcsInfo.MemUsg := pPMC^.WorkingSetSize div 1000; { 暂时用这个 }
      end
      else
        prcsInfo.MemUsg := -1;

      { 优先级  }
      prcsInfo.Priority := PriorityToStr(GetPriorityClass(hProcess));

      { 用户 }
      prcsInfo.UserName := GetProcessUser(hProcess);

      { 确定的System进程 }
      if (prcsInfo.UserName ='! no Right') and (prcsInfo.Name ='System') then
      begin
        prcsInfo.UserName := 'SYSTEM';
      end;

      if not CacheDict.ContainsKey(prcsInfo.pid) then
      begin
        prcinfCache := TProcessInfoCache.Create;
        prcsInfo.AbsolutePath := GetProcessFullName(hProcess);
        { 图标 }
        if Assigned(cbAddImage) then
        begin
          prcsInfo.imageindex := cbAddImage(prcsInfo.AbsolutePath);
          prcinfCache.index := prcsInfo.imageindex;
        end;
        prcinfCache.CPUUsageData := wsCreateUsageCounter(prcsInfo.pid);
        wsGetCpuUsage(prcinfCache.CPUUsageData);
        prcsInfo.CPUUsg := 0;
        CacheDict.Add(prcsInfo.pid, prcinfCache);
      end else begin
        prcinfCache := CacheDict[prcsInfo.pid];
        prcsInfo.CPUUsg := wsGetCpuUsage(prcinfCache.CPUUsageData);
        prcsInfo.imageindex := prcinfCache.index;
      end;

      if prcsInfo.pid = 0 then
        prcsInfo.Free
      else
        list.Add(prcsInfo);

      More := Process32Next(HwndHelp, fprocessentry32);
    end;

    sortList;
    Synchronize(setData);

    Sleep(500);
  end;
  FreeMem(pPMC);
  //icon.Free;
end;

constructor TUpdateThrd.Create;
begin
  inherited Create(True);
  CacheDict := TDictionary<Cardinal, TProcessInfoCache>.Create;
  list := TList.Create;
  list2:= TList.Create;

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
//  if Assigned(CacheDict.Keys) then
//  begin
//    CacheDict.Keys.Free;{ 必须手动释放这个？  }
//  end;

  CacheDict.Free;

  clearList;
  changeList;
  clearList;

  freeandnil(list2);
  freeandnil(list);

end;

procedure TUpdateThrd.ChooseOrderByColum(colum: Integer; up: Boolean);
begin
  if (colum >= 0) and (colum <= 4) then
    OrderColum := colum;
  Self.up := up;
end;


procedure TUpdateThrd.sortList;
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

