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

unit VSoft.CommandLine.Parser;

interface

uses
  Classes,
  VSoft.CommandLine.Options,
  VSoft.CommandLine.OptionDef;

type
  IInternalParseResult = interface
    ['{9EADABED-511B-4095-9ACA-A5E431AB653D}']
    procedure AddError(const value : string);
    procedure SetCommand(const command : ICommandDefinition);
    function GetCommand : ICommandDefinition;
    property Command : ICommandDefinition read GetCommand;
  end;

  TCommandLineParseResult = class(TInterfacedObject,ICommandLineParseResult,IInternalParseResult)
  private
    FErrors : TStringList;
    FCommand : ICommandDefinition;
  protected
    function GetErrorText: string;
    function GetHasErrors: Boolean;
    procedure AddError(const value: string);
    function GetCommandName : string;
    procedure SetCommand(const command : ICommandDefinition);
    function GetCommand : ICommandDefinition;
  public
    constructor Create;
    destructor Destroy;override;
  end;


  TCommandLineParser = class(TInterfacedObject,ICommandLineParser)
  private
    FUnamedIndex : integer;
    FNameValueSeparator: string;
  protected
    procedure InternalValidate(const parseResult: IInternalParseResult);

    procedure InternalParseFile(const fileName : string; const parseResult : IInternalParseResult);
    procedure InternalParse(const values : TStrings; const parseResult : IInternalParseResult);

    function Parse: ICommandLineParseResult;overload;
    function Parse(const values : TStrings) : ICommandLineParseResult;overload;
  public
    constructor Create(const ANameValueSeparator: string);
    destructor Destroy;override;
  end;

implementation

uses
  Generics.Collections,
  StrUtils,
  SysUtils;

procedure StripQuotes(var value : string);
var
  l : integer;
begin
  l := Length(value);
  if l < 2 then
    exit;

  if CharInSet(value[1],['''','"']) and CharInSet(value[l],['''','"']) then
  begin
    Delete(value,l,1);
    Delete(value,1,1);
  end;
end;

{ TCommandLineParser }

constructor TCommandLineParser.Create(const ANameValueSeparator: string);
begin
  inherited Create;
  FUnamedIndex := 0;
  FNameValueSeparator := ANameValueSeparator;
end;

destructor TCommandLineParser.Destroy;
begin

  inherited;
end;

procedure TCommandLineParser.InternalParse(const values: TStrings; const parseResult: IInternalParseResult);
var
  i : integer;
  j : integer;
  value : string;
  key : string;
  option : IOptionDefintion;
  currentCommand : ICommandDefinition;
  newCommand     : ICommandDefinition;
  defaultCommand : ICommandDefinition;
  bTryValue : boolean;
  bUseKey : boolean;

begin
  defaultCommand := TOptionsRegistry.DefaultCommand;
  currentCommand := defaultCommand;

  for i := 0 to values.Count -1 do
  begin
    j := 0;
    option := nil;
    bTryValue := true;
    bUseKey := false;
    value := values.Strings[i];
    if value = '' then
      continue;
    if StartsStr('--',value)  then
      Delete(value,1,2)
    else if StartsStr('-',value)  then
      Delete(value,1,1)
    else if StartsStr('/',value)  then
      Delete(value,1,1)
    else if StartsStr('@',value)  then
      Delete(value,1,1)
    //if command name = '' then it's the default;
    else if (currentCommand.Name = '') and TOptionsRegistry.RegisteredCommands.TryGetValue(LowerCase(value),newCommand) then
    begin
      currentCommand := newCommand;
      newCommand := nil;
      //switching commands
      parseResult.SetCommand(currentCommand);
      FUnamedIndex := 0;
      continue;
    end
    else if FUnamedIndex < currentCommand.RegisteredUnamedOptions.Count  then
    begin
      option := currentCommand.RegisteredUnamedOptions.Items[FUnamedIndex];
      Inc(FUnamedIndex);
      bTryValue := false;
      bUseKey := True;
    end
    else
    begin
      //don't recognise the start so report it and continue.
      parseResult.AddError('Unknown option : ' + values.Strings[i]);
      continue;
    end;

    if bTryValue then
      j := Pos(FNameValueSeparator,value);
    if j > 0 then
    begin
      //separate out into key and value
      key := Copy(value,1,j-1);
      Delete(value,1,j + Length(FNameValueSeparator) - 1);
      //it should already come in here without quotes when parsing paramstr(x).
      //but it might have quotes if it came in from a parameter file;
      StripQuotes(value);
    end
    else
    begin
      //no value just a key
      key := value;
      value := '';
    end;

    if option = nil then
    begin

      if not currentCommand.TryGetOption(LowerCase(key), option) then
      begin
        if currentCommand <> defaultCommand then
        begin
          //last resort to find an option.
          defaultCommand.TryGetOption(LowerCase(key), option)
        end;
      end;
    end;

    if option <> nil then
    begin
      if option.HasValue and (value = '') then
      begin
        parseResult.AddError('Option [' + key +'] expected a following :value but none was found');
        continue;
      end;
      if option.IsOptionFile then
      begin
        if not option.HasValue then
           value := key;

        //TODO : should options file override other options or vica versa?
        if not FileExists(value) then
        begin
          parseResult.AddError('Parameter File [' + value +'] does not exist');
          continue;
        end;
        try
          InternalParseFile(value,parseResult);
        except
          on e : Exception do
          begin
            parseResult.AddError('Error parsing Parameter File [' + value +'] : ' + e.Message);
          end;
        end;
      end
      else
      begin
        try
          if bUseKey then
            (option as IOptionDefInvoke).Invoke(key)
          else
            (option as IOptionDefInvoke).Invoke(value);
        except
          on e : Exception do
          begin
            parseResult.AddError('Error setting option : ' + key + ' to ' + value + ' : ' + e.Message );
          end;
        end;
      end;
    end
    else
    begin
      parseResult.AddError('Unknown command line option : ' + values.Strings[i]);
      continue;
    end;
  end;
end;

procedure TCommandLineParser.InternalParseFile(const fileName: string; const parseResult: IInternalParseResult);
var
  sList : TStringList;
begin
  sList := TStringList.Create;
  try
    InternalParse(sList,parseResult);
  finally
    sList.Free;
  end;
end;

procedure TCommandLineParser.InternalValidate(const parseResult: IInternalParseResult);
var
  option : IOptionDefintion;
begin
  for option in TOptionsRegistry.DefaultCommand.RegisteredOptions do
  begin
    if option.Required then
    begin
      if not (option as IOptionDefInvoke).WasFound then
      begin
        parseResult.AddError('Required Option [' + option.LongName + '] was not specified');
      end;
    end;
  end;

  for option in TOptionsRegistry.DefaultCommand.RegisteredUnamedOptions do
  begin
    if option.Required then
    begin
      if not (option as IOptionDefInvoke).WasFound then
      begin
        parseResult.AddError('Missing required unnamed parameter(s)');
        Break;
      end;
    end;
  end;

  if parseResult.command <> nil then
  begin
    for option in parseResult.command.RegisteredOptions do
    begin
      if option.Required then
      begin
        if not (option as IOptionDefInvoke).WasFound then
        begin
          parseResult.AddError('Required Option [' + option.LongName + '] was not specified');
        end;
      end;
    end;
  end;

end;

function TCommandLineParser.Parse(const values: TStrings): ICommandLineParseResult;
begin
  result := TCommandLineParseResult.Create;
  InternalParse(values,result as IInternalParseResult);
  InternalValidate(result as IInternalParseResult);
end;

function TCommandLineParser.Parse: ICommandLineParseResult;
var
  sList : TStringList;
  i     : integer;
begin
  sList := TStringList.Create;
  try
    if ParamCount > 0 then
    begin
      for i := 1 to ParamCount do
        sList.Add(ParamStr(i));
    end;
    result := Self.Parse(sList);

  finally
    sList.Free;
  end;
end;

{ TCommandLineParseResult }

procedure TCommandLineParseResult.AddError(const value: string);
begin
  FErrors.Add(value)
end;

constructor TCommandLineParseResult.Create;
begin
  FErrors := TStringList.Create;
  FCommand := nil;
end;

destructor TCommandLineParseResult.Destroy;
begin
  FErrors.Free;
  inherited;
end;

function TCommandLineParseResult.GetCommand: ICommandDefinition;
begin
  result := FCommand;
end;

function TCommandLineParseResult.GetCommandName: string;
begin
  if FCommand <> nil then
    result := FCommand.Name
  else
    result := '';
end;

function TCommandLineParseResult.GetErrorText: string;
begin
  result := FErrors.Text;
end;

function TCommandLineParseResult.GetHasErrors: Boolean;
begin
  result := FErrors.Count > 0;
end;

procedure TCommandLineParseResult.SetCommand(const command: ICommandDefinition);
begin
  FCommand := command;
end;


end.
