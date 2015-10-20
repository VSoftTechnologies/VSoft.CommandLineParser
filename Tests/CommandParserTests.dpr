program CommandParserTests;

{$APPTYPE CONSOLE}
uses
  SysUtils,
  DUnitX.Loggers.Console,
  DUnitX.Loggers.Xml.NUnit,
  DUnitX.TestRunner,
  DUnitX.TestFramework,
  TestCommandLineParser in 'TestCommandLineParser.pas',
  VSoft.CommandLine.OptionDef in '..\Src\VSoft.CommandLine.OptionDef.pas',
  VSoft.CommandLine.Options in '..\Src\VSoft.CommandLine.Options.pas',
  VSoft.CommandLine.Parser in '..\Src\VSoft.CommandLine.Parser.pas',
  VSoft.CommandLine.CommandDef in '..\Src\VSoft.CommandLine.CommandDef.pas';

var
  runner : ITestRunner;
  results : IRunResults;
  logger : ITestLogger;
  nunitLogger : ITestLogger;
begin
  try
    TDUnitX.CheckCommandLine;
    //Create the runner
    runner := TDUnitX.CreateRunner;
    runner.UseRTTI := True;
    //tell the runner how we will log things
    logger := TDUnitXConsoleLogger.Create(false);
    nunitLogger := TDUnitXXMLNUnitFileLogger.Create;
    runner.AddLogger(logger);
    runner.AddLogger(nunitLogger);

    //Run tests
    results := runner.Execute;

    {$IFNDEF CI}
      //We don't want this happening when running under CI.
      System.Write('Done.. press <Enter> key to quit.');
      System.Readln;
    {$ENDIF}
  except
    on E: Exception do
      System.Writeln(E.ClassName, ': ', E.Message);
  end;
end.
