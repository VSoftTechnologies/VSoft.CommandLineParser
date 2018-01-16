unit VSoft.CommandLine.Utils;

interface

function SplitDescription(const value : string; const maxLen : integer) : TArray<string>;
function SplitStringAt(const len : integer; const value : string) : TArray<string>;

function GetConsoleWidth : integer;

implementation

uses
{$IFDEF MSWINDOWS}
  Windows,
{$ENDIF}
  SysUtils,
  StrUtils;

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

{$IFDEF VER210}
type
  TStringDynArray = array of string;

function SplitString(const s, delimiters: string): TStringDynArray;
var
  splitCount: Integer;
  startIndex: Integer;
  foundIndex: Integer;
  i: Integer;
begin
  Result := nil;

  if s <> '' then
  begin
    splitCount := 0;
    for i := 1 to Length(s) do
      if IsDelimiter(delimiters, s, i) then
        Inc(splitCount);

    SetLength(Result, splitCount + 1);

    startIndex := 1;
    for i := 0 to splitCount - 1 do
    begin
      foundIndex := FindDelimiter(delimiters, s, startIndex);
      Result[i] := Copy(s, startIndex, foundIndex - startIndex);
      startIndex := foundIndex + 1;
    end;

    Result[splitCount] := Copy(s, startIndex, Length(s) - startIndex + 1);
  end;
end;
{$ENDIF}

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
  s := StringReplace(value,sLineBreak,#13,[rfReplaceAll]); // Otherwise a CRLF will result in two lines.
  splitStrings := TArray<string>(SplitString(s,#13#10));   // Splits at each CR *and* each LF!
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
      result[j] := Trim(s);
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
