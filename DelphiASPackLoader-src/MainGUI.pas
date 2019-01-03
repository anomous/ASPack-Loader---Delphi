unit MainGUI;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, ShellApi;

type
    TMainForm = class(TForm)
    CreateFilesOfRCDATA: TButton;
    procedure CreateFilesOfRCDATAClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  const

  RT_CURSOR       = MakeIntResource(1);
  RT_BITMAP       = MakeIntResource(2);
  RT_ICON         = MakeIntResource(3);
  RT_MENU         = MakeIntResource(4);
  RT_DIALOG       = MakeIntResource(5);
  RT_STRING       = MakeIntResource(6);
  RT_FONTDIR      = MakeIntResource(7);
  RT_FONT         = MakeIntResource(8);
  RT_ACCELERATOR  = MakeIntResource(9);
  RT_RCDATA       = RT_RCDATA; //MakeIntResource(10); // Types.RT_RCDATA;
  RT_MESSAGETABLE = MakeIntResource(11);

  DIFFERENCE = 11;

  RT_GROUP_CURSOR = MakeIntResource(DWORD(RT_CURSOR + DIFFERENCE));
  RT_GROUP_ICON   = MakeIntResource(DWORD(RT_ICON + DIFFERENCE));
  RT_VERSION      = MakeIntResource(16);
  RT_DLGINCLUDE   = MakeIntResource(17);
  RT_PLUGPLAY     = MakeIntResource(19);
  RT_VXD          = MakeIntResource(20);
  RT_ANICURSOR    = MakeIntResource(21);
  RT_ANIICON      = MakeIntResource(22);

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

//-------------------------------------------------------------------------------

procedure DeleteFiles(FileName: String);

begin

if FileExists(FileName) then begin

DeleteFile(FileName)

end

else

exit

end;

//-------------------------------------------------------------------------------

procedure SetFileAttributeHidden(FileName: String);

{
faReadOnly 	: 1 : Read-only files
faHidden 	  : 2 : Hidden files
faSysFile 	: 4 : System files
faVolumeID 	: 8 : Volume ID files
faDirectory : 16 : Directory files
faArchive 	: 32 : Archive files
faSymLink 	: 64 : Symbolic link
}

begin

FileSetAttr(FileName, faHidden);

end;

//-------------------------------------------------------------------------------

procedure CloseWindow(WindowName: PWideChar);

{
Closing (stopping) an application can be done by closing its main window.
That's done by sending a close message to that window:

PostMessage(WindowHandle, WM_CLOSE, 0, 0);
You get the handle of a window with:

FindWindow(PointerToWindowClass, PointerToWindowTitle)
}

  var

  H: HWND;

begin
  H := FindWindow(nil, WindowName);
  if H <> 0 then
    PostMessage(H, WM_CLOSE, 0, 0)
  else
    //ShowMessage(WindowName + ' was not found');
  exit

end;

//-------------------------------------------------------------------------------

procedure ExecuteProgramAndWaitUntilFinishing(ExecuteFile: String);

(*
SW_HIDE            Hides the window and activates another window.
SW_MAXIMIZE        Maximizes the specified window.
SW_MINIMIZE        Minimizes the specified window and activates the next top-level window in the Z order.
SW_RESTORE        Activates and displays the window. If the window is minimized or maximized, Windows restores it to its original size and position. An application should specify this flag when restoring a minimized window.
SW_SHOW            Activates the window and displays it in its current size and position.
SW_SHOWDEFAULT        Sets the show state based on the SW_ flag specified in the STARTUPINFO structure passed to the CreateProcess function by the program that started the application.
SW_SHOWMAXIMIZED    Activates the window and displays it as a maximized window.
SW_SHOWMINIMIZED    Activates the window and displays it as a minimized window.
SW_SHOWMINNOACTIVE    Displays the window as a minimized window. The active window remains active.
SW_SHOWNA        Displays the window in its current state. The active window remains active.
SW_SHOWNOACTIVATE    Displays a window in its most recent size and position. The active window remains active.
SW_SHOWNORMAL        Activates and displays a window. If the window is minimized or maximized, Windows restores it to its original size and position. An application should specify this flag when displaying the window for the first time.
*)

var
   SEInfo: TShellExecuteInfo;
   ExitCode: DWORD;
   ParamString, StartInString: String;

begin

   FillChar(SEInfo, SizeOf(SEInfo), 0) ;
   SEInfo.cbSize := SizeOf(TShellExecuteInfo) ;
   with SEInfo do begin
     fMask := SEE_MASK_NOCLOSEPROCESS;
     Wnd := Application.Handle;
     lpFile := PChar(ExecuteFile);
{
ParamString can contain the
application parameters.
}
// lpParameters := PChar(ParamString);
{
StartInString specifies the
name of the working directory.
If ommited, the current directory is used.
}
// lpDirectory := PChar(StartInString);
     nShow := SW_SHOWNORMAL;
   end;

   if ShellExecuteEx(@SEInfo) then begin
     repeat
       Application.ProcessMessages;
       GetExitCodeProcess(SEInfo.hProcess, ExitCode);
     until (ExitCode <> STILL_ACTIVE) or Application.Terminated;

   end

   else

   ShowMessage('Application was not started.');

end;

//-------------------------------------------------------------------------------

procedure RemoveNull(var Str : string);

var

n: Integer;

begin
n := 1;
while n <= Length(Str) do begin
  if str[n] = #0 then begin
    Delete(Str, n, 1);
    Continue;
  end;
  inc(n);
end;
end;

//-------------------------------------------------------------------------------

//-------------------------------------------------------------------------------

procedure UnpackRCDATA(FileName: String; ResourceIdentifier: Integer);

var

  FS: TFileStream;
  RS: TResourceStream;

 begin
        //    This section of code extracts/unpacks our RCDATA

 RS := TResourceStream.CreateFromID(hInstance, ResourceIdentifier, RT_RCDATA);
 try
  FS := TFileStream.Create(FileName, fmCreate);
        // Make File Hidden
  SetFileAttributeHidden(FileName);
  try
   FS.CopyFrom(RS, RS.Size);
  finally
   FS.Free;
  end;
 finally
  RS.Free;
 end;

 end;

//-------------------------------------------------------------------------------

procedure TMainForm.CreateFilesOfRCDATAClick(Sender: TObject);

begin

UnpackRCDATA('ASPack.chm',        1);
UnpackRCDATA('aspack.dll',        2);
UnpackRCDATA('ASPack.exe',        3);
UnpackRCDATA('aspack.x86',        4);
UnpackRCDATA('ASPack_ru.chm',     5);
UnpackRCDATA('Chinese BIG5.ini',  6);
UnpackRCDATA('Chinese GB.ini',    7);
UnpackRCDATA('Czech.ini',         8);
UnpackRCDATA('Danish.ini',        9);
UnpackRCDATA('Dutch.ini',         10);
UnpackRCDATA('English.ini',       11);
UnpackRCDATA('French.ini',        12);
UnpackRCDATA('German.ini',        13);
UnpackRCDATA('History.txt',       14);
UnpackRCDATA('Hungarian.ini',     15);
UnpackRCDATA('Indonesian.ini',    16);
UnpackRCDATA('Italian.ini',       17);
UnpackRCDATA('Japanese.ini',      18);
UnpackRCDATA('license.rtf',       19);
UnpackRCDATA('license_ru.rtf',    20);
UnpackRCDATA('Norwegian.ini',     21);
UnpackRCDATA('pcnsl.exe',         22);
UnpackRCDATA('Polski.ini',        23);
UnpackRCDATA('Portuguese-BR.ini', 24);
UnpackRCDATA('Russian.ini',       25);
UnpackRCDATA('Slovak.ini',        26);
UnpackRCDATA('Slovene.ini',       27);
UnpackRCDATA('Spanish.ini',       28);
UnpackRCDATA('Suomi.ini',         29);
UnpackRCDATA('Swedish.ini',       30);
UnpackRCDATA('Turkish.ini',       31);

// Execute ASPack 2.42 - Win32
ExecuteProgramAndWaitUntilFinishing('ASPack.exe');

//RemoveNull(Str);

end;

//-------------------------------------------------------------------------------

procedure TMainForm.FormDestroy(Sender: TObject);

begin

// Close Window of ASPack

CloseWindow('ASPack 2.42');

// DeleteFiles of ASPack

DeleteFiles('ASPack.chm');
DeleteFiles('aspack.dll');
DeleteFiles('ASPack.exe');
DeleteFiles('aspack.x86');
DeleteFiles('ASPack_ru.chm');
DeleteFiles('Chinese BIG5.ini');
DeleteFiles('Chinese GB.ini');
DeleteFiles('Czech.ini');
DeleteFiles('Danish.ini');
DeleteFiles('Dutch.ini');
DeleteFiles('English.ini');
DeleteFiles('French.ini');
DeleteFiles('German.ini');
DeleteFiles('History.txt');
DeleteFiles('Hungarian.ini');
DeleteFiles('Indonesian.ini');
DeleteFiles('Italian.ini');
DeleteFiles('Japanese.ini');
DeleteFiles('license.rtf');
DeleteFiles('license_ru.rtf');
DeleteFiles('Norwegian.ini');
DeleteFiles('pcnsl.exe');
DeleteFiles('Polski.ini');
DeleteFiles('Portuguese-BR.ini');
DeleteFiles('Russian.ini');
DeleteFiles('Slovak.ini');
DeleteFiles('Slovene.ini');
DeleteFiles('Spanish.ini');
DeleteFiles('Suomi.ini');
DeleteFiles('Swedish.ini');
DeleteFiles('Turkish.ini');

end;

//-------------------------------------------------------------------------------

end.
