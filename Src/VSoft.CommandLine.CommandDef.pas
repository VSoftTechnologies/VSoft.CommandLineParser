unit VSoft.CommandLine.CommandDef;

interface

uses
  Generics.Collections,
  VSoft.CommandLine.Options;

type
  TCommandDefImpl = class(TInterfacedObject, ICommandDefinition)
  private
    FName         : string;
    FAlias        : string;
    FDescription  : string;
    FHelpText     : string;
    FUsage        : string;
    FVisible      : boolean;
    FIsDefault    : boolean;
    FOptionsLookup      : TDictionary<string,IOptionDefintion>;
    //can't put unnamed options in dictionary, so we keep a list
    FUnnamedOptions     : TList<IOptionDefintion>;
    //all registered options.
    FRegisteredOptions  : TList<IOptionDefintion>;
  protected
    procedure AddOption(const value: IOptionDefintion);
    function HasOption(const name : string) : boolean;
    function GetRegisteredOptions : TList<IOptionDefintion>;
    function GetUnNamedOptions  : TList<IOptionDefintion>;
    function GetName : string;
    function GetAlias : string;
    function GetDescription : string;
    function GetHelpText : string;
    function GetIsDefault : boolean;
    function GetUsage : string;
    function GetVisible : boolean;

    function TryGetOption(const name : string; var option : IOptionDefintion) : boolean;
    procedure Clear;
    procedure GetAllRegisteredOptions(const list : TList<IOptionDefintion>);
    procedure EmumerateCommandOptions(const proc : TConstProc<string,string, string>);overload;
    procedure EmumerateCommandOptions(const proc : TConstProc<IOptionDefintion>);overload;

  public
    constructor Create(const name : string; const alias : string; const usage : string; const description : string; const helpText : string; const visible : boolean; const isDefault : boolean = false);
    destructor Destroy;override;

  end;

implementation

uses
  Generics.Defaults,
  System.SysUtils;

{ TCommandDef }

procedure TCommandDefImpl.AddOption(const value: IOptionDefintion);
begin
  if value.IsUnnamed then
    FUnNamedOptions.Add(value)
  else
  begin
    FRegisteredOptions.Add(value);
    FOptionsLookup.AddOrSetValue(LowerCase(value.LongName),value);
    if value.ShortName <> '' then
      FOptionsLookup.AddOrSetValue(LowerCase(value.ShortName),value);
  end;

end;

procedure TCommandDefImpl.Clear;
begin
  FOptionsLookup.Clear;
  FRegisteredOptions.Clear;
  FUnnamedOptions.Clear;
end;

constructor TCommandDefImpl.Create(const name: string; const alias : string;  const usage : string; const description : string; const helpText : string; const visible : boolean; const isDefault : boolean = false);
begin
  FName               := name;
  FUsage              := usage;
  FDescription        := description;
  FHelpText           := helpText;
  FAlias              := alias;
  FVisible            := visible;
  FIsDefault          := isDefault;

  FOptionsLookup      := TDictionary<string,IOptionDefintion>.Create;
  FUnnamedOptions     := TList<IOptionDefintion>.Create;
  FRegisteredOptions  := TList<IOptionDefintion>.Create;
end;

destructor TCommandDefImpl.Destroy;
begin
  FOptionsLookup.Free;
  FUnnamedOptions.Free;
  FRegisteredOptions.Free;
  inherited;
end;

procedure TCommandDefImpl.EmumerateCommandOptions(const proc: TConstProc<IOptionDefintion>);
var
  optionList : TList<IOptionDefintion>;
  opt : IOptionDefintion;
begin
  optionList := TList<IOptionDefintion>.Create;
  try
    optionList.AddRange(FRegisteredOptions);

    optionList.Sort(TComparer<IOptionDefintion>.Construct(
      function (const L, R: IOptionDefintion): integer
      begin
        Result := CompareText(L.LongName,R.LongName);
      end));

    for opt in optionList do
      proc(opt);
  finally
    optionList.Free;
  end;
end;

procedure TCommandDefImpl.EmumerateCommandOptions(const proc: TConstProc<string, string, string>);
var
  optionList : TList<IOptionDefintion>;
  opt : IOptionDefintion;
begin
  optionList := TList<IOptionDefintion>.Create;
  try
    optionList.AddRange(FRegisteredOptions);

    optionList.Sort(TComparer<IOptionDefintion>.Construct(
      function (const L, R: IOptionDefintion): integer
      begin
        Result := CompareText(L.LongName,R.LongName);
      end));

    for opt in optionList do
      proc(opt.LongName,opt.ShortName, opt.HelpText);
  finally
    optionList.Free;
  end;

end;

function TCommandDefImpl.GetAlias: string;
begin
  result := FAlias;
end;

procedure TCommandDefImpl.GetAllRegisteredOptions(const list: TList<IOptionDefintion>);
begin
  list.AddRange(FUnnamedOptions);
  list.AddRange(FRegisteredOptions);
end;

function TCommandDefImpl.GetDescription: string;
begin
  result := FDescription;
end;

function TCommandDefImpl.GetHelpText: string;
begin
  result := FHelpText;
end;

function TCommandDefImpl.GetIsDefault: boolean;
begin
  result := FIsDefault;
end;

function TCommandDefImpl.GetName: string;
begin
  result := FName;
end;

function TCommandDefImpl.GetRegisteredOptions: TList<IOptionDefintion>;
begin
  result := FRegisteredOptions;
end;

function TCommandDefImpl.GetUnNamedOptions: TList<IOptionDefintion>;
begin
  result := FUnNamedOptions;
end;

function TCommandDefImpl.GetUsage: string;
begin
  result := FUsage;
end;

function TCommandDefImpl.GetVisible: boolean;
begin
  result := FVisible;
end;

function TCommandDefImpl.HasOption(const name: string): boolean;
begin
  result := FOptionsLookup.ContainsKey(LowerCase(name));
end;

function TCommandDefImpl.TryGetOption(const name: string; var option: IOptionDefintion): boolean;
begin
  result := FOptionsLookup.TryGetValue(LowerCase(name),option);
end;

end.
