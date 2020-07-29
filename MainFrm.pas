unit MainFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  CPUUsage, ComCtrls, ImgList,
  CustomTypes,CustomUtil;
const
  CDATA = 100;

type
  TPrcMainFrm = class(TForm)
    BoxCPUUsage: TGroupBox;
    BoxMemUsage: TGroupBox;
    PaintBoxCPUUsage: TPaintBox;
    PaintBoxMemUsage: TPaintBox;
    Panel1: TPanel;
    TimerUpdateUsageHistory: TTimer;
    LabelStatus: TLabel;
    ProcessList: TListView;
    IconList: TImageList;
    procedure FormCreate(Sender: TObject);
    procedure PBConPaint(Sender: TObject);

    procedure PBMonPaint(Sender: TObject);
    procedure TimerUpdateUsageHistoryTimer(Sender: TObject);
    procedure FormOnDestroy(Sender: TObject);
    procedure BoxCPUUsageClick(Sender: TObject);
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

  public
    procedure addCpuDate(rate : Integer); { 添加一个 cpu占用 历史数据  }
    procedure init();
    procedure addMemeryDate(rate : Integer); { 添加一个内存使用 历史数据 }
    procedure setStatusText(text : string); { 设置下面的状态信息  }

    procedure setData(datas : TList); { 设置 进程显示的列表数据 }

  end;

var
  PrcMainFrm: TPrcMainFrm;

implementation

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

  procedure TPrcMainFrm.addCpuDate(rate : Integer);
  begin
    if( (rate >= 0) and (rate <= 100) ) then
    begin
      CpuUsgData[CpuUsgDataNext] := (100 - rate);{ 存100 - rate 主要是为了画图时方便 }
      CpuUsgDataNext := CpuUsgDataNext + 1;
      CpuUsgDataNext := CpuUsgDataNext Mod CDATA;
      PaintBoxCPUUsage.Refresh;
    end;
  end;

  procedure TPrcMainFrm.addMemeryDate(rate : Integer);
  begin
    if( (rate >= 0) and (rate <= 100) ) then
    begin
      MemeryUsgData[MemeryUsgDataNext] := (100-rate);
      MemeryUsgDataNext := MemeryUsgDataNext + 1;
      MemeryUsgDataNext := MemeryUsgDataNext Mod CDATA;
      PaintBoxMemUsage.Refresh;
    end;

  end;



procedure TPrcMainFrm.BoxCPUUsageClick(Sender: TObject);
begin

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
    addMemeryDate(mem.ullAvailPhys * 100 div mem.ullTotalPhys);
  end;

  setStatusText('CPU Usage: '+ IntToStr(T) + '%   Memery '+ MemStatus);
end;

procedure TPrcMainFrm.FormCreate(Sender: TObject);
var
List : TList;
prcInfo : TProcessInfo;
begin

  init;
  ProcessList.SmallImages := IconList;

  List := TList.Create;
  CpuUsageTotal := TCpuUsage.Create;

  prcInfo := TProcessInfo.Create;
  prcInfo.pid := 5204;
  prcInfo.Name := 'QQ.exe';
  prcInfo.MemUsg := 19222;
  prcInfo.CPUUsg := 20;
  prcInfo.Priority := '高';
  prcInfo.UserName := GetProcessUserByPic(5204);
  prcInfo.icon := GetProcessIcoByPid(5204);
  List.Add(@prcInfo);
  setData(List);
end;

procedure TPrcMainFrm.FormOnDestroy(Sender: TObject);
begin
  CpuUsageTotal.Free;
end;

procedure TPrcMainFrm.setData(datas : TList);
var
  I : Integer;
  P : ^TProcessInfo;
  icon : TIcon;
begin
  Icon := TIcon.Create;
  ProcessList.Clear;
  IconList.Clear;
  for I := 0 to datas.Count - 1 do
  begin
    P := datas.Items[I];
    icon.Handle := P.icon;
    IconList.AddIcon(icon);
    with ProcessList.Items.Add do
    begin
      Caption := P^.Name;
      SubItems.Add(IntToStr(P^.MemUsg) );
      SubItems.Add(IntToStr(P^.CPUUsg));
      SubItems.Add(P^.Priority);
      SubItems.Add(P^.UserName);
      ImageIndex := IconList.Count - 1;
    end;
  end;
  icon.Free;
end;

{$R *.dfm}

end.
