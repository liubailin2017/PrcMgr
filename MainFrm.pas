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
    CpuUsgDataNext : Integer; { ��һ�����λ�� }
    CputUsgBoxWidth : Integer;
    CpuUsgBoxHeight : Integer;

    MemeryUsgData : array[0..CDATA] of Integer;
    MemeryUsgDataNext : Integer;
    MemeryUsgBoxWidth : Integer;
    MemeryUsgBoxHeight : Integer;
    CpuUsageTotal : TCpuUsage;

  public
    procedure addCpuDate(rate : Integer); { ���һ�� cpuռ�� ��ʷ����  }
    procedure init();
    procedure addMemeryDate(rate : Integer); { ���һ���ڴ�ʹ�� ��ʷ���� }
    procedure setStatusText(text : string); { ���������״̬��Ϣ  }

    procedure setData(datas : TList); { ���� ������ʾ���б����� }

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
      CpuUsgData[CpuUsgDataNext] := (100 - rate);{ ��100 - rate ��Ҫ��Ϊ�˻�ͼʱ���� }
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

{ ����cpu ���� }
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

    PaintBoxCPUUsage.Canvas.FillRect(Rect); { ���� }

    for I := 1 to 4 do  { ��ˮƽ�� }
    begin
      PaintBoxCPUUsage.Canvas.MoveTo(0,I*CpuUsgBoxHeight div 5);
      PaintBoxCPUUsage.Canvas.LineTo(CputUsgBoxWidth,i*CpuUsgBoxHeight div 5);
    end;

    {
    note����I�����ݵ��±�ΪT
    }

    for I := 0 to CDATA - 1 do  { �� ��ֱ�� }
    begin
      T := (CpuUsgDataNext + I) mod  CDATA;
      if T mod 5 = 0 then { ÿ5���㻭һ����ֱ�� }
      begin
        PaintBoxCPUUsage.Canvas.Pen.Color := TColor($005000);
        PaintBoxCPUUsage.Canvas.MoveTo(I *CputUsgBoxWidth div (CDATA-1), 0);
        PaintBoxCPUUsage.Canvas.LineTo(I *CputUsgBoxWidth div (CDATA-1), CpuUsgBoxHeight);
      end;
    end;
    {1 2 3 4 5 6 }
    for I := 0 to CDATA - 1 do  { �� ������ }
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

 { �����ڴ�ʹ���� ���� }
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

    PaintBoxMemUsage.Canvas.FillRect(Rect); { ���� }

    for I := 1 to 4 do  { ��ˮƽ�� }
    begin
      PaintBoxMemUsage.Canvas.MoveTo(0,I*MemeryUsgBoxHeight div 5);
      PaintBoxMemUsage.Canvas.LineTo(MemeryUsgBoxWidth,i*MemeryUsgBoxHeight div 5);
    end;

    { note
      i :�ڼ������� (��0��ʼ)
      T :����λ��
      }

    for I := 0 to CDATA - 1 do  { �� ��ֱ�� }
    begin
      T := (MemeryUsgDataNext + I) mod  CDATA;
      if T mod 5 = 0 then { ÿ5���㻭һ����ֱ�� }
      begin
        PaintBoxMemUsage.Canvas.Pen.Color := TColor($005000);
        PaintBoxMemUsage.Canvas.MoveTo(I *MemeryUsgBoxWidth div (CDATA-1), 0);
        PaintBoxMemUsage.Canvas.LineTo(I *MemeryUsgBoxWidth div (CDATA-1), MemeryUsgBoxHeight);
      end;
    end;

    for I := 0 to CDATA - 1 do  { �� ������ }
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
  prcInfo.Priority := '��';
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
