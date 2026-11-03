unit TestCommandLineParser;
{***************************************************************************}
{                                                                           }
{           DUnitX                                                          }
{                                                                           }
{           Copyright (C) 2012 Vincent Parrett                              }
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

interface

uses
  DUnitX.TestFramework,
  VSoft.CommandLine.Options,
  VSoft.CommandLine.Parser;

type
  TExampleEnum = (enOne,enTwo,enThree);

  TExampleSet = set of TExampleEnum;

  [TestFixture]
  TCommandLineParserTests = class
  public

  [Setup]
  procedure Setup;

  [TearDown]
  procedure TearDown;

  [Test]
  procedure Will_Raise_On_Registering_Duplicate_Options;

  [Test]
  procedure Will_Raise_On_Registering_UnNamed_Option;

  [Test]
  procedure Test_Single_Option;

  [Test]
  procedure Will_Generate_Error_For_Unknown_Option;

  [Test]
  procedure Will_Generate_Error_For_Missing_Value;

  [Test]
  procedure Can_Register_Unnamed_Parameter;

  [Test]
  procedure Can_Parse_Unnamed_Parameter;

  [Test]
  procedure Can_Parse_Multiple_Unnamed_Parameters;

  [Test]
  procedure Will_Generate_Error_For_Extra_Unamed_Parameter;

  [Test]
  procedure Can_Parse_Quoted_Value;

  [Test]
  procedure Will_Raise_For_Missing_Param_File;

  [Test]
  procedure Can_Parse_Enum_Parameter;

  [Test]
  procedure Will_Generate_Error_For_Invalid_Enum;

  [Test]
  procedure Can_Parse_Set_Parameter;

  [Test]
  procedure Will_Generate_Error_For_Invalid_Set;

  [Test]
  procedure Can_Parse_EqualNameValueSeparator;

  [Test]
  procedure Can_Parse_ColonEqualNameValueSeparator;

  [Test]
  procedure Can_Parse_SpaceNameValueSeparator;

  [Test]
  procedure Test_String_Split;

  [Test]
  procedure Can_Parse_Command_By_Name;

  [Test]
  procedure Can_Parse_Command_By_Alias;

  [Test]
  procedure Can_Parse_Command_By_Alias_Ignoring_Case;

  [Test]
  procedure Will_Prefer_Command_Name_Over_Alias;

  [Test]
  procedure Can_Get_Command_By_Alias;

  [Test]
  procedure Can_Print_Usage_For_Command_By_Alias;

  [Test]
  procedure Can_Enumerate_Command_Options_By_Alias;

  [Test]
  procedure Can_Enumerate_Command_Options_Ignoring_Case;

  [Test]
  procedure Will_Generate_Error_For_Unknown_Command;

  end;

implementation

uses
  Classes,
  VSoft.CommandLine.Utils,
  VSoft.CommandLine.OptionDef;

{ TCommandLineParserTests }

procedure TCommandLineParserTests.Can_Parse_Command_By_Alias;
var
  sList : TStringList;
  parseResult : ICommandLineParseResult;
begin
  TOptionsRegistry.RegisterCommand('aliascommand','ac','a test command','','aliascommand [options]');
  try
    sList := TStringList.Create;
    sList.Add('ac');
    try
      parseResult := TOptionsRegistry.Parse(sList);
    finally
      sList.Free;
    end;
    Assert.IsFalse(parseResult.HasErrors, parseResult.ErrorText);
    Assert.AreEqual('aliascommand', parseResult.Command);
  finally
    TOptionsRegistry.Clear;
  end;
end;


procedure TCommandLineParserTests.Can_Parse_Command_By_Alias_Ignoring_Case;
var
  sList : TStringList;
  parseResult : ICommandLineParseResult;
begin
  TOptionsRegistry.RegisterCommand('aliascommand','ac','a test command','','aliascommand [options]');
  try
    sList := TStringList.Create;
    sList.Add('AC');
    try
      parseResult := TOptionsRegistry.Parse(sList);
    finally
      sList.Free;
    end;
    Assert.IsFalse(parseResult.HasErrors, parseResult.ErrorText);
    Assert.AreEqual('aliascommand', parseResult.Command);
  finally
    TOptionsRegistry.Clear;
  end;
end;


procedure TCommandLineParserTests.Can_Get_Command_By_Alias;
var
  cmd : ICommandDefinition;
begin
  TOptionsRegistry.RegisterCommand('aliascommand','ac','a test command','','aliascommand [options]');
  try
    cmd := TOptionsRegistry.GetCommandByName('AC');
    Assert.IsNotNull(cmd, 'command not found by alias');
    Assert.AreEqual('aliascommand', cmd.Name);
  finally
    TOptionsRegistry.Clear;
  end;
end;


procedure TCommandLineParserTests.Can_Print_Usage_For_Command_By_Alias;
var
  byName : string;
  byAlias : string;
begin
  TOptionsRegistry.RegisterCommand('aliascommand','ac','a test command','','aliascommand [options]');
  try
    byName := '';
    byAlias := '';
    TOptionsRegistry.PrintUsage('aliascommand',
      procedure(const value : string)
      begin
        byName := byName + value + #13#10;
      end);
    TOptionsRegistry.PrintUsage('ac',
      procedure(const value : string)
      begin
        byAlias := byAlias + value + #13#10;
      end);
    Assert.IsTrue(Pos('aliascommand [options]', byName) > 0, byName);
    Assert.AreEqual(byName, byAlias);
  finally
    TOptionsRegistry.Clear;
  end;
end;


procedure TCommandLineParserTests.Can_Enumerate_Command_Options_By_Alias;
var
  cmd : TCommandDefinition;
  names : string;
  defNames : string;
begin
  cmd := TOptionsRegistry.RegisterCommand('aliascommand','ac','a test command','','aliascommand [options]');
  try
    cmd.RegisterOption<boolean>('verbose','v','verbose output',nil);
    names := '';
    defNames := '';
    Assert.WillNotRaise(
      procedure
      begin
        TOptionsRegistry.EmumerateCommandOptions('ac',
          procedure(const longName : string; const shortName : string; const helpText : string)
          begin
            names := names + longName + ';';
          end);
        TOptionsRegistry.EmumerateCommandOptions('ac',
          procedure(const value : IOptionDefinition)
          begin
            defNames := defNames + value.LongName + ';';
          end);
      end);
    Assert.AreEqual('verbose;', names);
    Assert.AreEqual('verbose;', defNames);
  finally
    TOptionsRegistry.Clear;
  end;
end;


procedure TCommandLineParserTests.Can_Enumerate_Command_Options_Ignoring_Case;
var
  cmd : TCommandDefinition;
  defNames : string;
begin
  cmd := TOptionsRegistry.RegisterCommand('aliascommand','ac','a test command','','aliascommand [options]');
  try
    cmd.RegisterOption<boolean>('verbose','v','verbose output',nil);
    defNames := '';
    Assert.WillNotRaise(
      procedure
      begin
        TOptionsRegistry.EmumerateCommandOptions('AliasCommand',
          procedure(const value : IOptionDefinition)
          begin
            defNames := defNames + value.LongName + ';';
          end);
      end);
    Assert.AreEqual('verbose;', defNames);
  finally
    TOptionsRegistry.Clear;
  end;
end;


procedure TCommandLineParserTests.Can_Parse_Command_By_Name;
var
  sList : TStringList;
  parseResult : ICommandLineParseResult;
begin
  TOptionsRegistry.RegisterCommand('namedcommand','nc','a test command','','namedcommand [options]');
  try
    sList := TStringList.Create;
    sList.Add('namedcommand');
    try
      parseResult := TOptionsRegistry.Parse(sList);
    finally
      sList.Free;
    end;
    Assert.IsFalse(parseResult.HasErrors, parseResult.ErrorText);
    Assert.AreEqual('namedcommand', parseResult.Command);
  finally
    TOptionsRegistry.Clear;
  end;
end;


procedure TCommandLineParserTests.Can_Parse_Enum_Parameter;
var
  def : IOptionDefinition;
  test : TExampleEnum;
  sList : TStringList;
  parseResult : ICommandLineParseResult;

begin
  def := TOptionsRegistry.RegisterOption<TExampleEnum>('test','t',
                  procedure(const value : TExampleEnum)
                  begin
                    test := value;
                  end);

  sList := TStringList.Create;
  sList.Add('--test:enTwo');
  try
    parseResult := TOptionsRegistry.Parse(sList);
  finally
    sList.Free;
  end;
  Assert.IsFalse(parseResult.HasErrors);
  Assert.AreEqual(Ord(enTwo), Ord(test));
end;

procedure TCommandLineParserTests.Can_Parse_Multiple_Unnamed_Parameters;
var
  def : IOptionDefinition;
  file1 : string;
  file2 : string;
  sList : TStringList;
  parseResult : ICommandLineParseResult;
  test : boolean;
begin
  def := TOptionsRegistry.RegisterUnNamedOption<string>('the file we want to process',
                  procedure(const value : string)
                  begin
                    file1 := value;
                  end);

  def := TOptionsRegistry.RegisterUnNamedOption<string>('the second file we want to process',
                  procedure(const value : string)
                  begin
                    file2 := value;
                  end);

  def := TOptionsRegistry.RegisterOption<boolean>('test','t',
                  procedure(const value : boolean)
                  begin
                    test := value;
                  end);
  def.HasValue := False;

  sList := TStringList.Create;
  sList.Add('c:\file1.txt');
  sList.Add('--test');
  sList.Add('c:\file2.txt');
  try
    parseResult := TOptionsRegistry.Parse(sList);
  finally
    sList.Free;
  end;
  Assert.IsFalse(parseResult.HasErrors);
  Assert.AreEqual('c:\file1.txt',file1);
  Assert.AreEqual('c:\file2.txt',file2);
end;

procedure TCommandLineParserTests.Can_Parse_Quoted_Value;
var
  def : IOptionDefinition;
  test : string;
  test2 : string;
  parseResult : ICommandLineParseResult;
  sList : TStringList;
begin
  def := TOptionsRegistry.RegisterOption<string>('test','t',
                  procedure(const value : string)
                  begin
                    test := value;
                  end);

  def := TOptionsRegistry.RegisterOption<string>('test2','t2',
                  procedure(const value : string)
                  begin
                    test2 := value;
                  end);

  sList := TStringList.Create;
  sList.Add('--test:"hello world"');
  sList.Add('--test2:''hello world''');
  try
    parseResult := TOptionsRegistry.Parse(sList);
  finally
    sList.Free;
  end;
  Assert.AreEqual('hello world',test);
  Assert.AreEqual('hello world',test2);
end;

procedure TCommandLineParserTests.Can_Parse_Set_Parameter;
var
  def : IOptionDefinition;
  test : TExampleSet;
  sList : TStringList;
  parseResult : ICommandLineParseResult;

begin
  def := TOptionsRegistry.RegisterOption<TExampleSet>('test','t',
                  procedure(const value : TExampleSet)
                  begin
                    test := value;
                  end);

  sList := TStringList.Create;
  sList.Add('--test:[enOne,enThree]');
  try
    parseResult := TOptionsRegistry.Parse(sList);
  finally
    sList.Free;
  end;
  Assert.IsFalse(parseResult.HasErrors);
  Assert.IsTrue(test = [enOne,enThree]);
end;

procedure TCommandLineParserTests.Can_Parse_SpaceNameValueSeparator;
var
  def : IOptionDefinition;
  test : string;
  another : string;
  parseResult : ICommandLineParseResult;
  sList : TStringList;
begin
  def := TOptionsRegistry.RegisterOption<string>('test','t',
                  procedure(const value : string)
                  begin
                    test := value;
                  end);

  def := TOptionsRegistry.RegisterOption<string>('another','a',
                  procedure(const value : string)
                  begin
                    another:= value;
                  end);


  sList := TStringList.Create;
  sList.Add('--test');
  sList.Add('hello');
  sList.Add('-a');
  sList.Add('gotit');
  try
    TOptionsRegistry.NameValueSeparator := ' ';
    parseResult := TOptionsRegistry.Parse(sList);
  finally
    sList.Free;
  end;
  Assert.AreEqual('hello',test);
  Assert.AreEqual('gotit',another);

end;

procedure TCommandLineParserTests.Can_Parse_EqualNameValueSeparator;
var
  def : IOptionDefinition;
  test : string;
  parseResult : ICommandLineParseResult;
  sList : TStringList;
begin
  def := TOptionsRegistry.RegisterOption<string>('test','t',
                  procedure(const value : string)
                  begin
                    test := value;
                  end);

  sList := TStringList.Create;
  sList.Add('--test=hello');
  try
    TOptionsRegistry.NameValueSeparator := '=';
    parseResult := TOptionsRegistry.Parse(sList);
  finally
    sList.Free;
  end;
  Assert.AreEqual('hello',test);
end;

procedure TCommandLineParserTests.Can_Parse_ColonEqualNameValueSeparator;
var
  def : IOptionDefinition;
  test : string;
  parseResult : ICommandLineParseResult;
  sList : TStringList;
begin
  def := TOptionsRegistry.RegisterOption<string>('test','t',
                  procedure(const value : string)
                  begin
                    test := value;
                  end);

  sList := TStringList.Create;
  sList.Add('--test:=hello');
  try
    TOptionsRegistry.NameValueSeparator := ':=';
    parseResult := TOptionsRegistry.Parse(sList);
  finally
    sList.Free;
  end;
  Assert.AreEqual('hello',test);
end;


procedure TCommandLineParserTests.Can_Parse_Unnamed_Parameter;
var
  def : IOptionDefinition;
  res : string;
  sList : TStringList;
  parseResult : ICommandLineParseResult;
begin
  def := TOptionsRegistry.RegisterUnNamedOption<string>('the file we want to process',
                  procedure(const value : string)
                  begin
                    res := value;
                  end);

  sList := TStringList.Create;
  sList.Add('c:\test.txt');
  try
    parseResult := TOptionsRegistry.Parse(sList);
  finally
    sList.Free;
  end;

  Assert.AreEqual('c:\test.txt',res);
end;

procedure TCommandLineParserTests.Can_Register_Unnamed_Parameter;
var
  def : IOptionDefinition;
begin
  def := TOptionsRegistry.RegisterUnNamedOption<string>('the file we want to process',
                  procedure(const value : string)
                  begin
                  end);

  Assert.IsTrue(def.IsUnnamed);

end;

procedure TCommandLineParserTests.Setup;
begin
  TOptionsRegistry.DefaultCommand.Clear;
end;

procedure TCommandLineParserTests.TearDown;
begin
  TOptionsRegistry.DefaultCommand.Clear;
end;

procedure TCommandLineParserTests.Test_Single_Option;
var
  def : IOptionDefinition;
  result : boolean;
  parseResult : ICommandLineParseResult;
  sList : TStringList;
begin
  def := TOptionsRegistry.RegisterOption<boolean>('test','t',
                  procedure(const value : boolean)
                  begin
                    result := value;
                  end);
  def.HasValue := False;

  sList := TStringList.Create;
  sList.Add('--test');
  try
    parseResult := TOptionsRegistry.Parse(sList);
  finally
    sList.Free;
  end;
  Assert.IsTrue(result);


end;

procedure TCommandLineParserTests.Test_String_Split;
const
  s : string = 'Hello' + #13#10 + 'World' + #13#10;
var
  values : TArray<string>;
begin
  values := TStringUtils.Split(s, #13#10);
  Assert.AreEqual(2, length(values));
  Assert.AreEqual('hello', values[0]);
  Assert.AreEqual('world', values[1]);
end;

procedure TCommandLineParserTests.Will_Generate_Error_For_Extra_Unamed_Parameter;
var
  def : IOptionDefinition;
  file1 : string;
  sList : TStringList;
  parseResult : ICommandLineParseResult;
  test : string;
begin
  def := TOptionsRegistry.RegisterUnNamedOption<string>('the file we want to process',
                  procedure(const value : string)
                  begin
                    file1 := value;
                  end);

  def := TOptionsRegistry.RegisterOption<string>('test','t',
                  procedure(const value : string)
                  begin
                    test := value;
                  end);
//  def.HasValue := False;

  sList := TStringList.Create;
  sList.Add('c:\file1.txt');
  sList.Add('--test:hello');
  sList.Add('c:\file2.txt');
  try
    parseResult := TOptionsRegistry.Parse(sList);
    WriteLn(parseResult.ErrorText);
  finally
    sList.Free;
  end;
  Assert.IsTrue(parseResult.HasErrors);
  Assert.AreEqual('c:\file1.txt',file1);
  Assert.AreEqual('hello',test);
end;

procedure TCommandLineParserTests.Will_Generate_Error_For_Missing_Value;
var
  def : IOptionDefinition;
  result : boolean;
  parseResult : ICommandLineParseResult;
  sList : TStringList;
begin
  def := TOptionsRegistry.RegisterOption<boolean>('test','t',
                  procedure(const value : boolean)
                  begin
                    result := value;
                  end);
  def.HasValue := True;

  sList := TStringList.Create;
  sList.Add('--test');
  try
    parseResult := TOptionsRegistry.Parse(sList);
    WriteLn(parseResult.ErrorText);
  finally
    sList.Free;
  end;
  Assert.IsTrue(parseResult.HasErrors);
end;

procedure TCommandLineParserTests.Will_Generate_Error_For_Unknown_Command;
var
  sList : TStringList;
  parseResult : ICommandLineParseResult;
begin
  TOptionsRegistry.RegisterCommand('knowncommand','kc','a test command','','knowncommand [options]');
  try
    sList := TStringList.Create;
    sList.Add('kcx');
    try
      parseResult := TOptionsRegistry.Parse(sList);
    finally
      sList.Free;
    end;
    Assert.IsTrue(parseResult.HasErrors);
    Assert.AreEqual('', parseResult.Command);
  finally
    TOptionsRegistry.Clear;
  end;
end;


procedure TCommandLineParserTests.Will_Generate_Error_For_Unknown_Option;
var
  parseResult : ICommandLineParseResult;
  sList : TStringList;
begin
  sList := TStringList.Create;
  sList.Add('--blah');
  try
    parseResult := TOptionsRegistry.Parse(sList);
    WriteLn(parseResult.ErrorText);
  finally
    sList.Free;
  end;
  Assert.IsTrue(parseResult.HasErrors);

end;

procedure TCommandLineParserTests.Will_Prefer_Command_Name_Over_Alias;
var
  sList : TStringList;
  parseResult : ICommandLineParseResult;
begin
  TOptionsRegistry.RegisterCommand('first','second','a test command','','first [options]');
  TOptionsRegistry.RegisterCommand('second','s','a test command','','second [options]');
  try
    sList := TStringList.Create;
    sList.Add('second');
    try
      parseResult := TOptionsRegistry.Parse(sList);
    finally
      sList.Free;
    end;
    Assert.IsFalse(parseResult.HasErrors, parseResult.ErrorText);
    Assert.AreEqual('second', parseResult.Command);
  finally
    TOptionsRegistry.Clear;
  end;
end;


procedure TCommandLineParserTests.Will_Raise_For_Missing_Param_File;
var
  def : IOptionDefinition;
  parseResult : ICommandLineParseResult;
  sList : TStringList;
begin
  def := TOptionsRegistry.RegisterOption<boolean>('options','o',nil);
  def.IsOptionFile := true;
  sList := TStringList.Create;
  sList.Add('--options:"x:\blah blah.txt"');
  try
    parseResult := TOptionsRegistry.Parse(sList);
    WriteLn(parseResult.ErrorText);
  finally
    sList.Free;
  end;
  Assert.IsTrue(parseResult.HasErrors);
end;

procedure TCommandLineParserTests.Will_Raise_On_Registering_Duplicate_Options;
var
  result : boolean;
begin
  //same long names
  Assert.WillRaise(
    procedure
    begin
          TOptionsRegistry.RegisterOption<boolean>('test','t',
                        procedure(const value : boolean)
                        begin
                          result := value;
                        end);
          TOptionsRegistry.RegisterOption<boolean>('test','t',
                          procedure(const value : boolean)
                          begin
                            result := value;
                          end);

    end);

  //same short names
  Assert.WillRaise(
    procedure
    begin
          TOptionsRegistry.RegisterOption<boolean>('test','t',
                        procedure(const value : boolean)
                        begin
                          result := value;
                        end);
          TOptionsRegistry.RegisterOption<boolean>('t','blah',
                          procedure(const value : boolean)
                          begin
                            result := value;
                          end);

    end);



end;

procedure TCommandLineParserTests.Will_Raise_On_Registering_UnNamed_Option;
begin
  //same long names
  Assert.WillRaise(
    procedure
    begin
          TOptionsRegistry.RegisterOption<boolean>('','t',
                        procedure(const value : boolean)
                        begin
                        end);

    end);
end;

procedure TCommandLineParserTests.Will_Generate_Error_For_Invalid_Enum;
var
  def : IOptionDefinition;
  test : TExampleEnum;
  sList : TStringList;
  parseResult : ICommandLineParseResult;

begin
  def := TOptionsRegistry.RegisterOption<TExampleEnum>('test','t',
                  procedure(const value : TExampleEnum)
                  begin
                    test := value;
                  end);

  sList := TStringList.Create;
  sList.Add('--test:enbBlah');
  try
    parseResult := TOptionsRegistry.Parse(sList);
    WriteLn(parseResult.ErrorText);
  finally
    sList.Free;
  end;
  Assert.IsTrue(parseResult.HasErrors);
end;

procedure TCommandLineParserTests.Will_Generate_Error_For_Invalid_Set;
var
  def : IOptionDefinition;
  test : TExampleSet;
  sList : TStringList;
  parseResult : ICommandLineParseResult;

begin
  def := TOptionsRegistry.RegisterOption<TExampleSet>('test','t',
                  procedure(const value : TExampleSet)
                  begin
                    test := value;
                  end);

  sList := TStringList.Create;
  sList.Add('--test:[enOne,enFoo]');
  try
    parseResult := TOptionsRegistry.Parse(sList);
    WriteLn(parseResult.ErrorText);
  finally
    sList.Free;
  end;
  Assert.IsTrue(parseResult.HasErrors);

end;

initialization
  TDUnitX.RegisterTestFixture(TCommandLineParserTests);
end.
