program PrcMgr;

uses
  Forms,
  MainFrm in 'MainFrm.pas' {PrcMainFrm},
  CPUUsage in 'CPUUsage.pas',
  CustomTypes in 'CustomTypes.pas',
  uCpuUsage in 'uCpuUsage.pas',
  CustomUtil in 'CustomUtil.pas';

{$R *.res}

begin
  System.ReportMemoryLeaksOnShutdown := true;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TPrcMainFrm, PrcMainFrm);
  Application.Run;
end.
