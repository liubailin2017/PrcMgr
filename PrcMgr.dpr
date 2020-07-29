program PrcMgr;

uses
  Forms,
  MainFrm in 'MainFrm.pas' {PrcMainFrm},
  CPUUsage in 'CPUUsage.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TPrcMainFrm, PrcMainFrm);
  Application.Run;
end.
