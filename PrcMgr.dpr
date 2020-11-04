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
{$R uac.res}
const
atm = 'identification20';

var
hMutex:THandle;
hwd : HWND;
errmsg : string;
bIsExit : Boolean;
begin
  bIsExit := False;
  hMutex := OpenMutex(MUTEX_ALL_ACCESS, True, 'Process Manager');
  if hMutex <> 0 then bIsExit := true;
  hMutex := CreateMutex(nil, False, 'Process Manager');
  if hMutex = 0 then  bIsExit := true;
  if bIsExit then
  begin
    hwd := FindWindow(nil,'Process Manager');
    if hwd <> 0 then
    begin
      ShowWindow(hwd ,SW_RESTORE);
      setForegroundWindow(hwd);
    end;
    Exit;
  end;

  try
    System.ReportMemoryLeaksOnShutdown := true;
    Application.Initialize;
    Application.MainFormOnTaskbar := True;
    Application.CreateForm(TPrcMainFrm, PrcMainFrm);
    Application.Run;
  finally
   // ReleaseMutex(hMutex);
  end;
end.

