program CommandSample;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  VSoft.CommandLine.OptionDef in '..\Src\VSoft.CommandLine.OptionDef.pas',
  VSoft.CommandLine.Options in '..\Src\VSoft.CommandLine.Options.pas',
  VSoft.CommandLine.Parser in '..\Src\VSoft.CommandLine.Parser.pas',
  uCommandSampleConfig in 'uCommandSampleConfig.pas',
  uCommandSampleOptions in 'uCommandSampleOptions.pas',
  VSoft.CommandLine.CommandDef in '..\Src\VSoft.CommandLine.CommandDef.pas';

{
Note : The Options are registered in uSampleOptions
}

var
  parseresult :  ICommandLineParseResult;
begin
  try
    //parse the command line options
    parseresult := TOptionsRegistry.Parse;
    if parseresult.HasErrors then
    begin
      Writeln(parseresult.ErrorText);
      Writeln('Usage :');
      TOptionsRegistry.PrintUsage(
        procedure(value : string)
        begin
          Writeln(value);
        end);
    end
    else
    begin
      WriteLn('Command : ' + parseresult.Command);
      Writeln('Install Path : ' + TInstallOptions.InstallPath );
      Writeln('Help Command : ' + THelpOptions.HelpCommand );
    end;
    ReadLn;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
