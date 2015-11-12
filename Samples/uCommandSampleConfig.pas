unit uCommandSampleConfig;

interface

implementation


uses
  VSoft.CommandLine.Options,
  uCommandSampleOptions;

procedure ConfigureOptions;
var
  cmd    : TCommandDefinition;
  option : IOptionDefintion;
begin

  cmd := TOptionsRegistry.RegisterCommand('help','h','get some help','commandsample help [command]');
  option := cmd.RegisterUnNamedOption<string>('The command you need help for',
                  procedure(const value : string)
                  begin
                      THelpOptions.HelpCommand := value;
                  end);

  cmd := TOptionsRegistry.RegisterCommand('install','','install something', 'command sample install [options]');
  option := cmd.RegisterOption<string>('installpath','i','The path to the exe to install',
                  procedure(const value : string)
                  begin
                      TInstallOptions.InstallPath := value;
                  end);
  option.Required := true;


end;



initialization
  ConfigureOptions;

end.
