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
  Windows,sysUtils,Dialogs;
{$R *.res}
const
atm = 'identification11';
atm2 = 'identification2';
var
hwd : HWND;
errmsg : string;
begin
 if GlobalFindAtom(atm)=0 then
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
 ShowWindow(hwd ,SW_RESTORE);
 setForegroundWindow(hwd);

 if hwd = 0 then
   ShowMessage('errcode : ' + IntToStr(GetLastError));

end.
