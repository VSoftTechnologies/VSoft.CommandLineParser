program CommandSample;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  SysUtils,
  VSoft.CommandLine.OptionDef in '..\..\Src\VSoft.CommandLine.OptionDef.pas',
  VSoft.CommandLine.Options in '..\..\Src\VSoft.CommandLine.Options.pas',
  VSoft.CommandLine.Parser in '..\..\Src\VSoft.CommandLine.Parser.pas',
  VSoft.CommandLine.CommandDef in '..\..\Src\VSoft.CommandLine.CommandDef.pas',
  uCommandSampleConfig in 'uCommandSampleConfig.pas',
  uCommandSampleOptions in 'uCommandSampleOptions.pas',
  VSoft.CommandLine.Utils in '..\..\Src\VSoft.CommandLine.Utils.pas';

{
Note : The Options are registered in uSampleOptions
}

var
  parseresult :  ICommandLineParseResult;



procedure PrintUsage(const command : string);
begin
  if command = 'help' then
  begin
    if THelpOptions.HelpCommand = '' then
      THelpOptions.HelpCommand := 'help';
  end
  else
    THelpOptions.HelpCommand := command;
  TOptionsRegistry.PrintUsage(THelpOptions.HelpCommand,
    procedure (const value : string)
    begin
      WriteLn(value);
    end);
end;

begin
  try
    //parse the command line options
    TOptionsRegistry.DescriptionTab := 35;
    parseresult := TOptionsRegistry.Parse;
    if parseresult.HasErrors then
    begin
      Writeln;
      Writeln(parseresult.ErrorText);
      PrintUsage(parseresult.Command);
    end
    else
    begin
      if (parseresult.Command = '') or (parseresult.Command = 'help') then
        PrintUsage(parseresult.Command)
      else
        //run your command handler here!
        writeLn('Will execute command : ' + parseResult.Command + '');
    end;
    ReadLn;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
