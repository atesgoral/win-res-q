program WinResQ;

uses
  Forms,
  Main in 'Main.pas' {FormMain};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Win-Res-Q';
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
