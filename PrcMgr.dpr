program PrcMgr;

uses
  Forms,
  MainFrm in 'MainFrm.pas' {PrcMainFrm},
  CPUUsage in 'CPUUsage.pas',
  CustomTypes in 'CustomTypes.pas',
  uCpuUsage in 'uCpuUsage.pas',
  CustomUtil in 'CustomUtil.pas',
  UpdateThrd in 'UpdateThrd.pas',
  CompareForProcess in 'CompareForProcess.pas',
  Windows;
{$R *.res}
const
atm = 'identification';
atm2 = 'identification2';
var
hwd : HWND;

begin
 if GlobalFindAtom(atm)=1 then
 begin
  GlobalAddAtom(atm);
  System.ReportMemoryLeaksOnShutdown := true;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TPrcMainFrm, PrcMainFrm);
  Application.Run;
  GlobalDeleteAtom(GlobalFindAtom(atm));
 end;
 hwd := FindWindow(nil,'Process Manager');
 ShowWindow(hwd ,SW_SHOW);

end.
