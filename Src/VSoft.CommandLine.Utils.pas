unit VSoft.CommandLine.Utils;

interface

function SplitDescription(const value : string; const maxLen : integer) : TArray<string>;
function SplitStringAt(const len : integer; const value : string) : TArray<string>;

function GetConsoleWidth : integer;

implementation

uses
  System.SysUtils,
  System.StrUtils,
  WinAPI.Windows;

function SplitStringAt(const len : integer; const value : string) : TArray<string>;
var
  l : integer;
  idx  : integer;
  count : integer;
begin
  SetLength(result,0); //to quieten down fix insight.
  l := length(value);
  if l < len then
  begin
    SetLength(result,1);
    result[0] := value;
    exit;
  end;

  idx    := 1;
  count := 0;
  while idx <= l do
  begin
    Inc(count);
    SetLength(result,count);
    result[count -1] := Copy(value, idx, len);
    Inc(idx, len);
  end;
end;

function SplitDescription(const value : string; const maxLen : integer) : TArray<string>;
var
  descStrings : TArray<string>;
  splitStrings : TArray<string>;
  i : integer;
  j : integer;
  k : integer;
  l : integer;
  s : string;
begin
  SetLength(result,0); //to quieten down fix insight.
  splitStrings := TArray<string>(SplitString(value,#13#10));
  k := 0;

  for i := 0 to Length(splitStrings) -1 do
  begin
    descStrings := SplitStringAt(maxLen,splitStrings[i]);
    j := k;
    l := Length(descStrings);
    Inc(k,l);
    SetLength(result,k);
    for s in descStrings do
    begin
      result[j] := s.Trim;
      Inc(j);
    end;
  end;
end;


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
