program CommandSample;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
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
begin
  try
    //parse the command line options
    parseresult := TOptionsRegistry.Parse;
    if parseresult.HasErrors then
    begin
      Writeln('Invalid options :');
      Writeln;
      Writeln(parseresult.ErrorText);
      Writeln;
      Writeln('Usage : commandsample [command] [options]');
      TOptionsRegistry.PrintUsage(
        procedure(const value : string)
        begin
          Writeln(value);
        end);
    end
    else
    begin
      if parseresult.Command = '' then
      begin
        Writeln;
        Writeln('Usage : commandsample [command] [options]');
        TOptionsRegistry.PrintUsage(
          procedure (const value : string)
          begin
            WriteLn(value);
          end);
      end
      else
      begin
        WriteLn('Command : ' + parseresult.Command);
        Writeln('Install Path : ' + TInstallOptions.InstallPath );
        Writeln('Help Command : ' + THelpOptions.HelpCommand );
      end;
    end;
    ReadLn;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
