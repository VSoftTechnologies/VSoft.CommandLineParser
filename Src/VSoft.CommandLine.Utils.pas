unit VSoft.CommandLine.Utils;

interface


function GetConsoleWidth : integer;

implementation

uses
{$IFDEF MSWINDOWS}
  Windows,
{$ENDIF}
  System.SysUtils,
  System.StrUtils;
 



{$IFDEF MSWINDOWS}
function GetConsoleWidth : integer;
var
  info : CONSOLE_SCREEN_BUFFER_INFO;
  hStdOut : THandle;
begin
  Result := High(Integer); // Default is unlimited width
  hStdOut := GetStdHandle(STD_OUTPUT_HANDLE);
  if GetConsoleScreenBufferInfo(hStdOut, info) then
    Result := info.dwSize.X;
end;
{$ENDIF}
{$IFDEF MACOS}
function GetConsoleWidth : integer;
begin
  result := 80;
  //TODO : Find a way to get the console width on osx
end;
{$ENDIF}

end.
