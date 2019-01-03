program ASPackLoader;



{$R *.dres}

uses
  Vcl.Forms,
  MainGUI in 'MainGUI.pas' {MainForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
