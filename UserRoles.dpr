program UserRoles;

uses
  Forms,
  uMain in 'uMain.pas' {fmMain},
  uRB in 'uRB.pas',
  uLogin in 'uLogin.pas' {fmOraLogin};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfmMain, fmMain);
  Application.Run;
end.
