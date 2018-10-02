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
  procedure Will_Not_Print_GlobalOptions_Without_GlobalOptions;

  [Test]
  procedure Will_Print_GlobalOptions_With_GlobalOptions;

  end;

implementation

uses
  Classes,
  StrUtils,
  VSoft.CommandLine.OptionDef;

{ TCommandLineParserTests }

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
  TOptionsRegistry.Clear;
end;

procedure TCommandLineParserTests.TearDown;
begin
  TOptionsRegistry.Clear;
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

procedure TCommandLineParserTests.Will_Not_Print_GlobalOptions_Without_GlobalOptions;
var
  Usage: string;
begin
  TOptionsRegistry.RegisterCommand('command1', '', 'description for command 1', '', '');
  TOptionsRegistry.RegisterCommand('command2', '', 'description for command 2', '', '');
  TOptionsRegistry.PrintUsage(
    procedure(const Value: string)
    begin
      Usage := Usage + Value + #13;
    end);
  Assert.IsFalse(ContainsText(Usage, 'global options'));
end;

procedure TCommandLineParserTests.Will_Print_GlobalOptions_With_GlobalOptions;
var
  Usage: string;
  Test: string;
begin
  TOptionsRegistry.RegisterOption<string>('test', 't', 'helpText',
    procedure(const Value: string)
    begin
      Test := Value;
    end);
  TOptionsRegistry.RegisterCommand('command1', '', 'description for command 1', '', '');
  TOptionsRegistry.RegisterCommand('command2', '', 'description for command 2', '', '');
  TOptionsRegistry.PrintUsage(
    procedure(const Line: string)
    begin
      Usage := Usage + Line + #13;
    end);
  Assert.IsTrue(ContainsText(Usage, 'global options'));
end;

initialization
  TDUnitX.RegisterTestFixture(TCommandLineParserTests);
end.
