unit uCommandSampleConfig;

interface

implementation


uses
  VSoft.CommandLine.Options,
  uCommandSampleOptions;

procedure ConfigureOptions;
var
  cmd    : TCommandDefinition;
  option : IOptionDefinition;
begin
  option := TOptionsRegistry.RegisterOption<boolean>('verbose','v','verbose output',
    procedure(const value : boolean)
    begin
        TGlobalOptions.Verbose := value;
    end);
  option.HasValue := false;


  cmd := TOptionsRegistry.RegisterCommand('help','h','get some help','','help [command]');
  option := cmd.RegisterUnNamedOption<string>('The command you need help for, a long description so that it probably wraps on the console', 'command',
                  procedure(const value : string)
                  begin
                      THelpOptions.HelpCommand := value;
                  end);

  cmd := TOptionsRegistry.RegisterCommand('install','','install something', '', 'install [options]');
  option := cmd.RegisterOption<string>('installpath','i','The path to the exe to install',
                  procedure(const value : string)
                  begin
                      TInstallOptions.InstallPath := value;
                  end);
  option.Required := true;

  cmd.Examples.Add('install -installpath="c:\program files"');
  cmd.Examples.Add('install -i="c:\temp"');
end;



initialization
  ConfigureOptions;

end.
