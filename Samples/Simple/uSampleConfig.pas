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

unit uSampleConfig;

interface


implementation

uses
  VSoft.CommandLine.Options,
  uSampleOptions;

procedure ConfigureOptions;
var
  option : IOptionDefintion;
begin
  option := TOptionsRegistry.RegisterOption<string>('inputfile','i','The file to be processed',
    procedure(const value : string)
    begin
        TSampleOptions.InputFile := value;
    end);
  option.Required := true;

  option := TOptionsRegistry.RegisterOption<string>('outputfile','o','The processed output file',
    procedure(const value : string)
    begin
        TSampleOptions.OutputFile := value;
    end);
  option.Required := true;

  option := TOptionsRegistry.RegisterOption<boolean>('mangle','m','Mangle the file!',
    procedure(const value : boolean)
    begin
        TSampleOptions.MangleFile := value;
    end);
  option.HasValue := False;

  option := TOptionsRegistry.RegisterOption<boolean>('options','','Options file',nil);
  option.IsOptionFile := true;


end;


initialization
  ConfigureOptions;

end.
