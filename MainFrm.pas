unit MainFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  CPUUsage, ComCtrls, ImgList,
  CustomTypes,CustomUtil,UpdateThrd,
  TlHelp32, {CreateToolhelp32Snapshot }

Generics.Collections, { TList}
PsAPI,ShellAPI { GetProcessMemoryInfo }
;
const
  CDATA = 100;

type
  TPrcMainFrm = class(TForm)
    PaintBoxCPUUsage: TPaintBox;
    PaintBoxMemUsage: TPaintBox;
    TimerUpdateUsageHistory: TTimer;
    LabelStatus: TLabel;
    ProcessList: TListView;
    IconList: TImageList;
    Label1: TLabel;
    Label2: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure PBConPaint(Sender: TObject);

    procedure PBMonPaint(Sender: TObject);
    procedure TimerUpdateUsageHistoryTimer(Sender: TObject);
    procedure FormOnDestroy(Sender: TObject);
    procedure PrcListOnColumClick(Sender: TObject; Column: TListColumn);

    procedure ProcessListAdd(n : Integer);
    procedure ProcessListDelete(n : Integer);
    procedure LVOnSelected(Sender: TObject; Item: TListItem; Selected: Boolean);

  private
  { 1 2 3 4 5 6  7 }
    CpuUsgData : array[0..CDATA] of Integer;
    CpuUsgDataNext : Integer; { 下一个添加位置 }
    CputUsgBoxWidth : Integer;
    CpuUsgBoxHeight : Integer;

    MemeryUsgData : array[0..CDATA] of Integer;
    MemeryUsgDataNext : Integer;
    MemeryUsgBoxWidth : Integer;
    MemeryUsgBoxHeight : Integer;
    CpuUsageTotal : TCpuUsage;

    UpdateThrd : TUpdateThrd;

    columid : Integer;
    up :Boolean;
    icon : TIcon;
    PrcNmb : Integer;
  public
    procedure addCpuDate(rate : Integer); { 添加一个 cpu占用 历史数据  }
    procedure init();
    procedure addMemeryDate(rate : Integer); { 添加一个内存使用 历史数据 }
    procedure setStatusText(text : string); { 设置下面的状态信息  }
    procedure setData(list : TList); { 设置 进程显示的列表数据 }
    function addImage(path : string): Integer;
  end;

var
  PrcMainFrm: TPrcMainFrm;

implementation
{$R *.dfm}
  procedure TPrcMainFrm.init();
  var
  I : Integer;
  begin
    for I := 0 to CDATA - 1 do
    begin
       CpuUsgData[I] := 100;
       MemeryUsgData[I] := 100;
    end;
    CpuUsgDataNext := 0;
    MemeryUsgDataNext := 0;
    CputUsgBoxWidth :=  PaintBoxCPUUsage.ClientWidth;
    CpuUsgBoxHeight := PaintBoxCPUUsage.ClientHeight;
    MemeryUsgBoxWidth := PaintBoxMemUsage.ClientWidth;
    MemeryUsgBoxHeight := PaintBoxMemUsage.ClientHeight;
  end;

  procedure TPrcMainFrm.LVOnSelected(Sender: TObject; Item: TListItem;
  Selected: Boolean);
  begin
    if UpdateThrd <> nil then UpdateThrd.Select(Item.Index);
  end;

procedure TPrcMainFrm.addCpuDate(rate : Integer);
  begin
    if rate > 100 then
       rate := 100;
    if rate <= 0 then
       rate := 0;
    CpuUsgData[CpuUsgDataNext] := (100 - rate);{ 存100 - rate 主要是为了画图时方便 }
    CpuUsgDataNext := CpuUsgDataNext + 1;
    CpuUsgDataNext := CpuUsgDataNext Mod CDATA;
    PaintBoxCPUUsage.Refresh;
  end;

  procedure TPrcMainFrm.addMemeryDate(rate : Integer);
  begin
    if rate > 100 then
       rate := 100;
    if rate <= 0 then
       rate := 0;
      MemeryUsgData[MemeryUsgDataNext] := (100-rate);
      MemeryUsgDataNext := MemeryUsgDataNext + 1;
      MemeryUsgDataNext := MemeryUsgDataNext Mod CDATA;
      PaintBoxMemUsage.Refresh;

  end;


  { 绘制cpu 数据 }
  procedure TPrcMainFrm.PBConPaint(Sender: TObject);
  var
    Rect : TRect;
    I : Integer;
    T : Integer;
  begin
    Rect.Left := 0;
    Rect.Top := 0;
    Rect.Right := Rect.Left+ CputUsgBoxWidth;
    Rect.Bottom := Rect.Top + CpuUsgBoxHeight;
    PaintBoxCPUUsage.Canvas.Pen.Color := TColor($005000);
    PaintBoxCPUUsage.Canvas.Brush.Color := clBlack;

    PaintBoxCPUUsage.Canvas.FillRect(Rect); { 背景 }

    for I := 1 to 4 do  { 画水平线 }
    begin
      PaintBoxCPUUsage.Canvas.MoveTo(0,I*CpuUsgBoxHeight div 5);
      PaintBoxCPUUsage.Canvas.LineTo(CputUsgBoxWidth,i*CpuUsgBoxHeight div 5);
    end;

    {
    note：第I个数据的下标为T
    }

    for I := 0 to CDATA - 1 do  { 画 垂直线 }
    begin
      T := (CpuUsgDataNext + I) mod  CDATA;
      if T mod 5 = 0 then { 每5个点画一个垂直线 }
      begin
        PaintBoxCPUUsage.Canvas.Pen.Color := TColor($005000);
        PaintBoxCPUUsage.Canvas.MoveTo(I *CputUsgBoxWidth div (CDATA-1), 0);
        PaintBoxCPUUsage.Canvas.LineTo(I *CputUsgBoxWidth div (CDATA-1), CpuUsgBoxHeight);
      end;
    end;
    {1 2 3 4 5 6 }
    for I := 0 to CDATA - 1 do  { 画 波形线 }
    begin
      T := (CpuUsgDataNext + I) mod  CDATA;
      PaintBoxCPUUsage.Canvas.Pen.Color :=  TColor($00F000);
      if I=0 then
      begin
        PaintBoxCPUUsage.Canvas.MoveTo(0, CpuUsgData[T] * CpuUsgBoxHeight div 101 );
      end else
      begin
        PaintBoxCPUUsage.Canvas.LineTo(I*CputUsgBoxWidth div (CDATA-1),  CpuUsgData[T] * CpuUsgBoxHeight div 101);
      end;

    end;
  end;

  { 绘制内存使用率 数据 }
  procedure TPrcMainFrm.PBMonPaint(Sender: TObject);
  var
    Rect : TRect;
    I : Integer;
    T : Integer;
  begin
    Rect.Left := 0;
    Rect.Top := 0;
    Rect.Right := Rect.Left+ MemeryUsgBoxWidth;
    Rect.Bottom := Rect.Top + MemeryUsgBoxHeight;
    PaintBoxMemUsage.Canvas.Pen.Color := TColor($005000);
    PaintBoxMemUsage.Canvas.Brush.Color := clBlack;

    PaintBoxMemUsage.Canvas.FillRect(Rect); { 背景 }

    for I := 1 to 4 do  { 画水平线 }
    begin
      PaintBoxMemUsage.Canvas.MoveTo(0,I*MemeryUsgBoxHeight div 5);
      PaintBoxMemUsage.Canvas.LineTo(MemeryUsgBoxWidth,i*MemeryUsgBoxHeight div 5);
    end;

    { note
      i :第几个数据 (从0开始)
      T :数据位置
      }

    for I := 0 to CDATA - 1 do  { 画 垂直线 }
    begin
      T := (MemeryUsgDataNext + I) mod  CDATA;
      if T mod 5 = 0 then { 每5个点画一个垂直线 }
      begin
        PaintBoxMemUsage.Canvas.Pen.Color := TColor($005000);
        PaintBoxMemUsage.Canvas.MoveTo(I *MemeryUsgBoxWidth div (CDATA-1), 0);
        PaintBoxMemUsage.Canvas.LineTo(I *MemeryUsgBoxWidth div (CDATA-1), MemeryUsgBoxHeight);
      end;
    end;

    for I := 0 to CDATA - 1 do  { 画 波形线 }
    begin
      T := (MemeryUsgDataNext + I) mod  CDATA;
      PaintBoxMemUsage.Canvas.Pen.Color :=  TColor($00F000);
      if I=0 then
      begin
        PaintBoxMemUsage.Canvas.MoveTo(0, MemeryUsgData[T] * MemeryUsgBoxHeight div 101 );
      end else
      begin
        PaintBoxMemUsage.Canvas.LineTo(I*MemeryUsgBoxWidth div (CDATA-1), MemeryUsgData[T] * MemeryUsgBoxHeight div 101 );
      end;

    end;
  end;

  procedure TPrcMainFrm.PrcListOnColumClick(Sender: TObject; Column: TListColumn);
  begin
    if up then
    begin
        up := False;
    end else
    begin
       up := True;
    end;

    if Self.columid <> Column.ID then
      up := True;
    Self.columid  := Column.ID;
    ProcessList.Columns[0].Caption := 'Name';
    ProcessList.Columns[1].Caption := 'Memery  (KB)';
    ProcessList.Columns[2].Caption := 'CPU Usage(%)';
    ProcessList.Columns[3].Caption := 'Priority';
    ProcessList.Columns[4].Caption := 'User Name';
    if up then
    begin
    case Column.ID  of
      0: Column.Caption := 'Name         ^';
      1: Column.Caption := 'Memery  (KB) ^';
      2: Column.Caption := 'CPU Usage(%) ^';
      3: Column.Caption := 'Priority     ^';
      4: Column.Caption := 'User Name    ^';
    end
    end else
    begin
    case Column.ID  of
      0: Column.Caption := 'Name         v';
      1: Column.Caption := 'Memery  (KB) v';
      2: Column.Caption := 'CPU Usage(%) v';
      3: Column.Caption := 'Priority     v';
      4: Column.Caption := 'User Name    v';
    end;
    end;

    UpdateThrd.ChooseOrderByColum(Column.ID,up);
  end;

  procedure TPrcMainFrm.setStatusText(text : string);
  begin
    LabelStatus.Caption := text;
  end;

  procedure TPrcMainFrm.TimerUpdateUsageHistoryTimer(Sender: TObject);
  var
    T : Integer;
    mem : _MEMORYSTATUSEX;
    MemStatus : string;
  begin
    T :=  CpuUsageTotal.getUsage();
    addCpuDate(T);
    mem.dwLength := SizeOf(mem);
    if GlobalMemoryStatusEx(mem) then
    begin
      MemStatus := 'availe : ' + IntToStr(mem.ullAvailPhys div 1024 div 1024)+'M '
       + 'total : ' + IntToStr(mem.ullTotalPhys div 1024 div 1024)+'M';
      MemStatus := Format('Memery Total:%5d M Availe:%5d M ',[mem.ullAvailPhys div 1024 div 1024,
      mem.ullTotalPhys div 1024 div 1024]);
      addMemeryDate(mem.ullAvailPhys * 100 div mem.ullTotalPhys);
    end;
    setStatusText(Format('CPU Usage:%2d%%  ' + MemStatus + 'Process Number:%3d' , [T,PrcNmb] ));
  end;

  procedure TPrcMainFrm.FormCreate(Sender: TObject);
  //var
    //List : TList;
    //prcInfo : TProcessInfo;
  begin

    Icon := TIcon.Create;
    init;
    PromoteProcessPrivilege(GetCurrentProcess,'SeDebugPrivilege');
    ProcessList.SmallImages := IconList;
    CpuUsageTotal := TCpuUsage.Create;
    UpdateThrd := TUpdateThrd.Create;
    UpdateThrd.cbSetData := setData;
    UpdateThrd.cbAddImage := addImage;
    UpdateThrd.Resume;

    ProcessList.Columns[0].Caption := 'Name         ^';
    ProcessList.Columns[1].Caption := 'Memery  (KB)';
    ProcessList.Columns[2].Caption := 'CPU Usage(%)';
    ProcessList.Columns[3].Caption := 'Priority';
    ProcessList.Columns[4].Caption := 'User Name';
    PrcNmb := 0;
    ProcessList.Columns[0].Width := ProcessList.ClientWidth * 20 div 100;
    ProcessList.Columns[1].Width := ProcessList.ClientWidth * 20 div 100;
    ProcessList.Columns[2].Width := ProcessList.ClientWidth * 20 div 100;
    ProcessList.Columns[3].Width := ProcessList.ClientWidth * 20 div 100;
    ProcessList.Columns[4].Width := ProcessList.ClientWidth * 20 div 100;
  end;

  procedure TPrcMainFrm.FormOnDestroy(Sender: TObject);
  begin
    CpuUsageTotal.Free;
    CpuUsageTotal := nil;
    ShowWindow(Self.Handle, SW_HIDE);
    //UpdateThrd.Quit;
    UpdateThrd.Terminate;
    UpdateThrd.WaitFor;
    freeandnil(UpdateThrd);
    freeandnil(icon);
  //  if Assigned(icon) then icon.Free;
  //  icon := nil;
  end;

  procedure TPrcMainFrm.ProcessListDelete(n : Integer);
  var
  I : Integer;
  begin
    for I := 0 to n - 1  do
      ProcessList.Items.Delete(ProcessList.Items.Count-1);
  end;


  procedure TPrcMainFrm.ProcessListAdd(n : Integer);
  var
  I : Integer;
  begin
    for I := 0 to n - 1  do
    with ProcessList.Items.Add do
      begin

        Caption := '';
        SubItems.Add('' );

        SubItems.Add('');
        SubItems.Add('');
        SubItems.Add('');
        ImageIndex := -1;
      end;
  end;

  function TPrcMainFrm.addImage(path : string):Integer;
  var
    psfi : _SHFILEINFOW;
  begin
  if path = '' then
      path := 'C:\Windows\System32\PING.EXE';  { 如果没有获取到路径，就使用默认图标 }
    if 0 = SHGetFileInfo(PChar(path), 0, psfi, 0, SHGFI_SMALLICON or SHGFI_ICON) then
          SHGetFileInfo(PChar('C:\Windows\System32\PING.EXE'),
           0, psfi, 0, SHGFI_SMALLICON or SHGFI_ICON); {   如果打开文件失败，也使用默认图标 }
    icon.Handle := psfi.hIcon;
    if (path <> '') and (icon.Handle <> 0) then
      Result := IconList.AddIcon(icon)
  end;

  procedure TPrcMainFrm.setData(list: TList);
  var
    I : Integer;
    P : TProcessInfo;

    prps : Integer;
    psfi : _SHFILEINFOW;
    cmpr : Integer;
  begin
    cmpr := list.Count - ProcessList.Items.Count;
  //LockWindowUpdate(ProcessList.Handle);
    if cmpr > 0 then
    begin
      ProcessListAdd(cmpr);
    end else if cmpr < 0 then
    begin
      ProcessListDelete(-cmpr);
    end;

    for I := 0 to list.Count - 1 do
    begin
      P := list.Items[I];
      with ProcessList.Items[i] do
      begin
        Caption := P.Name;
        SubItems[0] := IntToStr(P.MemUsg);

        SubItems[1] := Format('%.1f',[P.CPUUsg]);
        SubItems[2] := P.Priority;
        SubItems[3] := P.UserName;
        ImageIndex := P.ImageIndex;//IconList.Count - 1;
      end;
        if p.isSelected then
            ProcessList.Items[i].Selected := True;
    end;
  //LockWindowUpdate(0);
    PrcNmb := list.Count;
    ProcessList.Columns[0].Width := ProcessList.ClientWidth * 20 div 100;
    ProcessList.Columns[1].Width := ProcessList.ClientWidth * 20 div 100;
    ProcessList.Columns[2].Width := ProcessList.ClientWidth * 20 div 100;
    ProcessList.Columns[3].Width := ProcessList.ClientWidth * 20 div 100;
    ProcessList.Columns[4].Width := ProcessList.ClientWidth * 20 div 100;
  end;

end.
