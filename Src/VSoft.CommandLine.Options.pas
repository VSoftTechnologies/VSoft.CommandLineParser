{***************************************************************************}
{                                                                           }
{           VSoft.CommandLine                                               }
{                                                                           }
{           Copyright (C) 2014 Vincent Parrett                              }
{                                                                           }
{           vincent@finalbuilder.com                                        }
{           http://www.finalbuilder.com                                     }
{                                                                           }
{                                                                           }
{***************************************************************************}
{                                                                           }
{  Licensed under the Apache License, Version 2.0 (the "License");          }
{  you may not use this file except in compliance with the License.         }
{  You may obtain a copy of the License at                                  }
{                                                                           }
{      http://www.apache.org/licenses/LICENSE-2.0                           }
{                                                                           }
{  Unless required by applicable law or agreed to in writing, software      }
{  distributed under the License is distributed on an "AS IS" BASIS,        }
{  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. }
{  See the License for the specific language governing permissions and      }
{  limitations under the License.                                           }
{                                                                           }
{***************************************************************************}

unit VSoft.CommandLine.Options;

interface

uses
  Generics.Collections,
  Rtti,
  TypInfo,
  SysUtils,
  Classes;

type
  TConstProc<T> = reference to procedure (const Arg1: T);
  TConstProc<T,T2> = reference to procedure (const Arg1: T; const Arg2 : T2);
  TConstProc<T,T2, T3> = reference to procedure (const Arg1: T; const Arg2 : T2; const Arg3 : T3);

  ICommandLineParseResult = interface
    ['{1715B9FF-8A34-47C9-843E-619C5AEA3F32}']
    function GetHasErrors : boolean;
    function GetErrorText : string;
    function GetCommandName : string;
    property HasErrors : boolean read GetHasErrors;
    property ErrorText : string read GetErrorText;
    property Command : string read GetCommandName;
  end;

  ICommandLineParser = interface
    ['{6F970026-D1EE-4A3E-8A99-300AD3EE9C33}']
    //parses the command line
    function Parse : ICommandLineParseResult;overload;
    //parses the passed in string - makes testing easier.
    function Parse(const values : TStrings) : ICommandLineParseResult;overload;
  end;


  IOptionDefintion = interface
  ['{1EAA06BA-8FBF-43F8-86D7-9F5DE26C4E86}']
    function GetLongName : string;
    function GetShortName : string;
    function GetHasValue : boolean;
    procedure SetHasValue(const value : boolean);
    function GetHelpText : string;
    procedure SetHelpText(const value : string);
    function GetRequired : boolean;
    procedure SetRequired(const value : boolean);
    function GetValueRequired : boolean;
    procedure SetValueRequired(const value : boolean);
    function GetAllowMultiple : boolean;
    procedure SetAllowMultiple(const value : boolean);
    function GetIsOptionFile : boolean;
    procedure SetIsOptionFile(const value : boolean);
    function GetIsHidden : boolean;
    procedure SetIsHidden(const value : boolean);

    function GetIsUnnamed : boolean;
    property LongName       : string read GetLongName;
    property ShortName      : string read GetShortName;
    property HasValue       : boolean read GetHasValue write SetHasValue;
    property HelpText       : string read GetHelpText write SetHelpText;
    property Required       : boolean read GetRequired write SetRequired;
    property ValueRequired  : boolean read GetValueRequired write SetValueRequired;
    property AllowMultiple  : boolean read GetAllowMultiple write SetAllowMultiple;
    property IsOptionFile   : boolean read GetIsOptionFile write SetIsOptionFile;
    property IsUnnamed      : boolean read GetIsUnnamed;
    property Hidden         : boolean read GetIsHidden write SetIsHidden;
  end;


  ICommandDefinition = interface
  ['{58199FE2-19DF-4F9B-894F-BD1C5B62E0CB}']
    function GetRegisteredOptions : TList<IOptionDefintion>;
    function GetUnNamedOptions  : TList<IOptionDefintion>;
    procedure GetAllRegisteredOptions(const list : TList<IOptionDefintion>);
    function GetName : string;
    function GetAlias : string;
    function GetDescription : string;
    function GetHelpText : string;
    function GetUsage : string;
    function GetVisible : boolean;
    function GetIsDefault : boolean;
    procedure AddOption(const value : IOptionDefintion);
    function TryGetOption(const name : string; var option : IOptionDefintion) : boolean;
    function HasOption(const name : string) : boolean;
    procedure Clear;
    procedure EmumerateCommandOptions(const proc : TConstProc<string,string, string>);overload;
    procedure EmumerateCommandOptions(const proc : TConstProc<IOptionDefintion>);overload;

    property Name : string read GetName;
    property Alias : string read GetAlias;
    property Description : string read GetDescription;
    property HelpText : string read GetHelpText;
    property IsDefault : boolean read GetIsDefault;
    property Usage : string read GetUsage;
    property RegisteredOptions : TList<IOptionDefintion> read GetRegisteredOptions;
    property RegisteredUnamedOptions : TList<IOptionDefintion> read GetUnNamedOptions;
    property Visible : boolean read GetVisible;
  end;

  //Using a record here because non generic interfaces cannot have generic methods!! Still!
  //The actual command implementation is elsewhere.
  TCommandDefinition = record
  private
    FCommandDef : ICommandDefinition;
    function GetName: string;
    function GetDescription : string;
    function GetUsage : string;
    function GetAlias : string;
  public
    function RegisterOption<T>(const longName: string; const Action : TConstProc<T>) : IOptionDefintion;overload;
    function RegisterOption<T>(const longName: string; const shortName : string; const Action : TConstProc<T>) : IOptionDefintion;overload;
    function RegisterOption<T>(const longName: string; const shortName : string; const helpText : string; const Action : TConstProc<T>) : IOptionDefintion;overload;
    function RegisterUnNamedOption<T>(const helpText : string; const Action : TConstProc<T>) : IOptionDefintion;overload;
    function HasOption(const value : string) : boolean;
    constructor Create(const commandDef : ICommandDefinition);
    property Name : string read GetName;
    property Alias : string read GetAlias;
    property Description : string read GetDescription;
    property Usage : string read GetUsage;

  end;


  TOptionsRegistry = class
  private
    class var
      FNameValueSeparator: string;
      FDefaultCommand : TCommandDefinition;
      FCommandDefs : TDictionary<string,ICommandDefinition>;
      FDescriptionTab : integer;
      FConsoleWidth : integer;

  protected
    class function GetDefaultCommand: ICommandDefinition; static;
  protected
    class constructor Create;
    class destructor Destroy;
  public
    class procedure Clear; //use for testing only;
    class function RegisterOption<T>(const longName: string; const Action : TConstProc<T>) : IOptionDefintion;overload;
    class function RegisterOption<T>(const longName: string; const shortName : string; const Action : TConstProc<T>) : IOptionDefintion;overload;
    class function RegisterOption<T>(const longName: string; const shortName : string; const helpText : string; const Action : TConstProc<T>) : IOptionDefintion;overload;
    class function RegisterUnNamedOption<T>(const helpText : string; const Action : TConstProc<T>) : IOptionDefintion;overload;

    class function RegisterCommand(const name : string; const alias : string; const description : string; const helpString : string; const usage : string; const visible : boolean = true) : TCommandDefinition;

    class function Parse: ICommandLineParseResult;overload;
    class function Parse(const values : TStrings) : ICommandLineParseResult;overload;

    class procedure PrintUsage(const proc : TConstProc<string>);overload;
    class procedure PrintUsage(const commandName : string; const proc : TConstProc<string>);overload;
    class procedure PrintUsage(const command : ICommandDefinition; const proc : TConstProc<string>);overload;

    class procedure EnumerateCommands(const proc : TConstProc<string,string>);overload;
    class procedure EnumerateCommands(const proc : TConstProc<ICommandDefinition>);overload;

    class procedure EmumerateCommandOptions(const commandName : string; const proc : TConstProc<string,string, string>);overload;
    class procedure EmumerateCommandOptions(const commandName : string; const proc : TConstProc<IOptionDefintion>);overload;

    class function GetCommandByName(const name : string) : ICommandDefinition;

    class property NameValueSeparator: string read FNameValueSeparator write FNameValueSeparator;
    class property DescriptionTab : integer read FDescriptionTab write FDescriptionTab;
    class property DefaultCommand : ICommandDefinition read GetDefaultCommand;
    class property RegisteredCommands : TDictionary<string,ICommandDefinition> read FCommandDefs;

  end;

implementation

uses
  Generics.Defaults,
  System.StrUtils,
  VSoft.CommandLine.Utils,
  VSoft.CommandLine.Parser,
  VSoft.Commandline.OptionDef,
  VSoft.CommandLine.CommandDef;

{ TOptionsRegistry }

class function TOptionsRegistry.RegisterOption<T>(const longName, shortName: string; const Action: TConstProc<T>): IOptionDefintion;
begin
  result := FDefaultCommand.RegisterOption<T>(longName,shortName,Action);
end;

class function TOptionsRegistry.Parse: ICommandLineParseResult;
var
  parser : ICommandLineParser;
begin
  parser := TCommandLineParser.Create(NameValueSeparator);
  result := parser.Parse;
end;

class function TOptionsRegistry.RegisterCommand(const name: string; const alias : string; const description : string; const helpString : string; const usage : string; const visible : boolean): TCommandDefinition;
var
  cmdDef : ICommandDefinition;
begin
  cmdDef := TCommandDefImpl.Create(name,alias, usage, description, helpString,visible);
  result := TCommandDefinition.Create(cmdDef);
  FCommandDefs.Add(name.ToLower,cmdDef);
end;


class procedure TOptionsRegistry.Clear;
begin
  FDefaultCommand.FCommandDef.Clear;
  FCommandDefs.Clear;
end;

class constructor TOptionsRegistry.Create;
var
  cmdDef : ICommandDefinition;
begin
  cmdDef := TCommandDefImpl.Create('','','','','',false,true);
  FDefaultCommand := TCommandDefinition.Create(cmdDef);
  FCommandDefs := TDictionary<string,ICommandDefinition>.Create;
  FNameValueSeparator := ':';
  FDescriptionTab := 15;
  FConsoleWidth := GetConsoleWidth;
end;

class destructor TOptionsRegistry.Destroy;
begin
  FCommandDefs.Free;
end;

class function TOptionsRegistry.GetCommandByName(const name: string): ICommandDefinition;
begin
  result := nil;
  FCommandDefs.TryGetValue(name.ToLower,Result);

end;

class function TOptionsRegistry.GetDefaultCommand: ICommandDefinition;
begin
  result := TOptionsRegistry.FDefaultCommand.FCommandDef;
end;

class function TOptionsRegistry.Parse(const values: TStrings): ICommandLineParseResult;
var
  parser : ICommandLineParser;
begin
  parser := TCommandLineParser.Create(NameValueSeparator);
  result := parser.Parse(values);
end;

class procedure TOptionsRegistry.EmumerateCommandOptions(const commandName: string; const proc: TConstProc<string, string, string>);
var
  cmd : ICommandDefinition;
begin
  if not FCommandDefs.TryGetValue(commandName,cmd) then
    raise Exception.Create('Unknown command : ' + commandName);

  cmd.EmumerateCommandOptions(proc);

end;


class procedure TOptionsRegistry.EnumerateCommands(const proc: TConstProc<string,string>);
var
  cmd : ICommandDefinition;
  cmdList : TList<ICommandDefinition>;
begin
  //The commandDefs are stored in a dictionary, so we need to sort them ourselves.
  cmdList := TList<ICommandDefinition>.Create;
  try
    for cmd in FCommandDefs.Values do
    begin
      if cmd.Visible then
        cmdList.Add(cmd);
    end;
    
    cmdList.Sort(TComparer<ICommandDefinition>.Construct(
    function (const L, R: ICommandDefinition): integer
    begin
      Result := CompareText(L.Name,R.Name);
    end));

    for cmd in cmdList do
      proc(cmd.Name,cmd.Description);

  finally
    cmdList.Free;
  end;
end;

class procedure TOptionsRegistry.PrintUsage(const command: ICommandDefinition; const proc: TConstProc<string>);
var
  maxDescW : integer;
begin
  if not command.IsDefault then
  begin
    proc('usage: ' + command.Usage);
    proc('');
    proc(command.Description);
    if command.HelpText <> '' then
    begin
      proc('');
      proc('   ' + command.HelpText);
    end;
    proc('');
    proc('options :');
    proc('');
  end
  else
  begin
    proc('');
    if FCommandDefs.Count > 0 then
      proc('global options :')
    else
      proc('options :');
    proc('');
  end;

  if FConsoleWidth < High(Integer) then
    maxDescW := FConsoleWidth
  else
    maxDescW := High(Integer);

  maxDescW := maxDescW - FDescriptionTab;

  command.EmumerateCommandOptions(
    procedure(const opt : IOptionDefintion)
    var
       descStrings : TArray<string>;
       i : integer;
       numDescStrings : integer;
       al : integer;
       s  : string;
    begin
      descStrings := SplitDescription(opt.HelpText,maxDescW);
      al := Length(opt.ShortName);
      if al <> 0 then
        Inc(al,5); //ad backets and 2 spaces;

      s := ' -' + opt.LongName.PadRight(descriptionTab -1 - al);
      if al > 0 then
        s := s + '(-' + opt.ShortName + ')' + '  ';
      s := s + descStrings[0];
      proc(s);
  //          FConsole.WriteLine(' -' + name.PadRight(descriptionTab -1) + descStrings[0]);
      numDescStrings := Length(descStrings);
      if numDescStrings > 1 then
      begin
        for i := 1 to numDescStrings -1 do
          proc(''.PadRight(descriptionTab) + descStrings[i]);
      end;

    end);

end;

class procedure TOptionsRegistry.PrintUsage(const commandName: string; const proc: TConstProc<string>);
var
  cmd : ICommandDefinition;
begin
  if commandName = '' then
  begin
    PrintUsage(proc);
    exit;
  end;

  if not FCommandDefs.TryGetValue(LowerCase(commandName),cmd) then
  begin
    proc('Unknown command : ' + commandName);
    exit;
  end;
  PrintUsage(cmd,proc);
end;

class procedure TOptionsRegistry.PrintUsage(const proc: TConstProc<string>);
var
  cmd : ICommandDefinition;
  descStrings : TArray<string>;
  i : integer;
  numDescStrings : integer;
  maxDescW : integer;
begin
  proc('');
  if FCommandDefs.Count > 0 then
  begin
    if FConsoleWidth < High(Integer) then
      maxDescW := FConsoleWidth
    else
      maxDescW := High(Integer);
     maxDescW := maxDescW - FDescriptionTab;

    for cmd in FCommandDefs.Values do
    begin
      if cmd.Visible then
      begin
        descStrings := SplitDescription(cmd.Description,maxDescW);
        proc(' ' + cmd.Name.PadRight(descriptionTab -1) + descStrings[0]);
        numDescStrings := Length(descStrings);
        if numDescStrings > 1 then
        begin
          for i := 1 to numDescStrings -1 do
            proc(''.PadRight(descriptionTab) + descStrings[i]);
        end;
        proc('');
      end;
    end;
    PrintUsage(FDefaultCommand.FCommandDef,proc);
  end
  else
    PrintUsage(FDefaultCommand.FCommandDef,proc);
end;

class function TOptionsRegistry.RegisterOption<T>(const longName, shortName, helpText: string; const Action: TConstProc<T>): IOptionDefintion;
begin
  result := RegisterOption<T>(longName,shortName,Action);
  result.HelpText := helpText;
end;

class function TOptionsRegistry.RegisterOption<T>(const longName: string; const Action: TConstProc<T>): IOptionDefintion;
begin
  result := RegisterOption<T>(longName,'',Action);
end;

class function TOptionsRegistry.RegisterUnNamedOption<T>(const helpText: string; const Action: TConstProc<T>): IOptionDefintion;
begin
  result := FDefaultCommand.RegisterUnNamedOption<T>(helpText,Action);
end;

{ TCommandDef }

constructor TCommandDefinition.Create(const commandDef : ICommandDefinition);
begin
  FCommandDef := commandDef;
end;


function TCommandDefinition.RegisterOption<T>(const longName: string; const Action: TConstProc<T>): IOptionDefintion;
begin
  result := RegisterOption<T>(longName,'',Action);
end;

function TCommandDefinition.RegisterOption<T>(const longName, shortName: string; const Action: TConstProc<T>): IOptionDefintion;
begin
  if longName = '' then
    raise Exception.Create('Name required - use RegisterUnamed to register unamed options');

  if FCommandDef.HasOption(LowerCase(longName)) then
    raise Exception.Create('Option : ' + longName + 'already registered');

  if FCommandDef.HasOption(LowerCase(shortName)) then
    raise Exception.Create('Option : ' + shortName + 'already registered');

  result := TOptionDefinition<T>.Create(longName,shortName,Action);

  FCommandDef.AddOption(Result);
end;

function TCommandDefinition.GetAlias: string;
begin
  result := FCommandDef.Alias;
end;

function TCommandDefinition.GetDescription: string;
begin
  result := FCommandDef.Description;
end;

function TCommandDefinition.GetName: string;
begin
  result := FCommandDef.Name;
end;

function TCommandDefinition.GetUsage: string;
begin
  result := FCommandDef.Usage;
end;

function TCommandDefinition.HasOption(const value: string): boolean;
begin
  result := FCommandDef.HasOption(value);
end;

function TCommandDefinition.RegisterOption<T>(const longName, shortName, helpText: string; const Action: TConstProc<T>): IOptionDefintion;
begin
  result := RegisterOption<T>(longName,shortName,Action);
  result.HelpText := helpText;
end;

function TCommandDefinition.RegisterUnNamedOption<T>(const helpText: string; const Action: TConstProc<T>): IOptionDefintion;
begin
  result := TOptionDefinition<T>.Create('','',helptext,Action);
  result.HasValue := false;
  FCommandDef.AddOption(result);
end;


class procedure TOptionsRegistry.EmumerateCommandOptions(const commandName: string; const proc: TConstProc<IOptionDefintion>);
var
  cmd : ICommandDefinition;
begin
  if not FCommandDefs.TryGetValue(commandName,cmd) then
    raise Exception.Create('Unknown command : ' + commandName);
  cmd.EmumerateCommandOptions(proc);
end;

class procedure TOptionsRegistry.EnumerateCommands(const proc: TConstProc<ICommandDefinition>);
var
  cmd : ICommandDefinition;
  cmdList : TList<ICommandDefinition>;
begin
  //The commandDefs are stored in a dictionary, so we need to sort them ourselves.
  cmdList := TList<ICommandDefinition>.Create;
  try
    for cmd in FCommandDefs.Values do
    begin
      if cmd.Visible then
        cmdList.Add(cmd);
    end;

    cmdList.Sort(TComparer<ICommandDefinition>.Construct(
    function (const L, R: ICommandDefinition): integer
    begin
      Result := CompareText(L.Name,R.Name);
    end));

    for cmd in cmdList do
      proc(cmd);

  finally
    cmdList.Free;
  end;
end;

initialization



end.
