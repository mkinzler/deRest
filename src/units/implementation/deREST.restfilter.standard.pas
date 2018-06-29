unit deREST.restfilter.standard;

interface
uses
  system.generics.collections,
  deREST;

type
  TRESTFilterGroup = class( TInterfacedObject, IRESTFilterGroup, IRESTFilterItem )
  private
    fChildren: TList<IRESTFilterItem>;
    fGroupOperator: TGroupOperator;
  private //- IRESTFilterItem -//
    function AsFilter: IRESTFilter;
    function ASGroup: IRESTFilterGroup;
    function IsFilter: boolean;
    function IsGroup: boolean;
    function ToFilterString( FieldTypes: array of TFieldRecord ): string;
  private //- IRESTFilterGroup -//
    function getCount: uint32;
    function getItem( Index: uint32 ): IRESTFilterItem;
    function getGroupOperator: TGroupOperator;
    procedure setGroupOperator( value: TGroupOperator );
    function AddFilter( Identifier: string; Constraint: TConstraint; Value: string ): IRESTFilter;
    function AddGroup( GroupOperator: TGroupOperator ): IRESTFilterGroup;
    function AddItem( Item: IRESTFilterItem ): IRestFilterItem;
  public
    constructor Create; reintroduce;
    destructor Destroy; override;
  end;

  TRESTFilter = class( TInterfacedObject, IRESTFilter, IRESTFilterItem )
  private
    fIdentifier: string;
    fConstraint: TConstraint;
    fValue: string;
  private //- IRESTFilterItem -//
    function AsFilter: IRESTFilter;
    function ASGroup: IRESTFilterGroup;
    function IsFilter: boolean;
    function IsGroup: boolean;
    function ToFilterString( FieldTypes: array of TFieldRecord ): string;
  private //- IRESTFilter -//
    function getIdentifier: string;
    procedure setIdentifier( value: string );
    function getConstraint: TConstraint;
    procedure setConstraint( value: TConstraint );
    function getValueAsString: string;
    procedure setValueAsString( value: string );
    function getValueAsInteger: int32;
    procedure setValueAsInteger( value: int32 );
    function getValueAsFloat: double;
    procedure setValueAsFloat( value: double );
    function getValueAsBoolean: boolean;
    procedure setValueAsBoolean( value: boolean );
    function getValueAsDateTime: TDateTime;
    procedure setValueAsDateTime( value: TDateTime );
  private
    function FieldType( FieldTypes: array of TFieldRecord; FieldName: string ): TRESTFieldType;
  end;



implementation
uses
  sysutils;

{ TRESTFilter }

function TRESTFilter.AsFilter: IRESTFilter;
begin
  Result := (Self as IRESTFilter);
end;

function TRESTFilter.ASGroup: IRESTFilterGroup;
begin
  Result := nil;
end;

function TRESTFilter.getConstraint: TConstraint;
begin
  Result := fConstraint;
end;

function TRESTFilter.getIdentifier: string;
begin
  Result := fIdentifier;
end;

function TRESTFilter.getValueAsBoolean: boolean;
var
  utValue: string;
begin
  utValue := Uppercase(Trim(fValue));
  Result := (utValue='YES') or (utValue='TRUE');
end;

function TRESTFilter.getValueAsDateTime: TDateTime;
begin
  Result := StrToDateTime(fValue);
end;

function TRESTFilter.getValueAsFloat: double;
begin
  Result := StrToFloat(fValue);
end;

function TRESTFilter.getValueAsInteger: int32;
begin
  Result := StrToInt(fValue);
end;

function TRESTFilter.getValueAsString: string;
begin
  Result := fValue;
end;

function TRESTFilter.IsFilter: boolean;
begin
  Result := True;
end;

function TRESTFilter.IsGroup: boolean;
begin
  Result := False;
end;

procedure TRESTFilter.setConstraint(value: TConstraint);
begin
  fConstraint := value;
end;

procedure TRESTFilter.setIdentifier(value: string);
begin
  fIdentifier := value;
end;

procedure TRESTFilter.setValueAsBoolean(value: boolean);
begin
  if Value then begin
    fValue := 'TRUE';
  end else begin
    fValue := 'FALSE';
  end;
end;

procedure TRESTFilter.setValueAsDateTime(value: TDateTime);
begin
  fValue := FormatDateTime('YYYY:MM:DD HH:nn:SS:nnnn',Value);
end;

procedure TRESTFilter.setValueAsFloat(value: double);
begin
  fValue := FloatToStr(Value);
end;

procedure TRESTFilter.setValueAsInteger(value: int32);
begin
  fValue := IntToStr(Value);
end;

procedure TRESTFilter.setValueAsString(value: string);
begin
  fValue := value;
end;

function TRESTFilter.FieldType( FieldTypes: array of TFieldRecord; FieldName: string ): TRESTFieldType;
var
  idx: uint32;
  utFieldName: string;
begin
  Result := rftUnknown;
  if Length(FieldTypes)=0 then begin
    exit;
  end;
  utFieldName := Uppercase(Trim(FieldName));
  for idx := 0 to pred(Length(FieldTypes)) do begin
    if FieldTypes[idx].FieldName=utFieldName then begin
      Result := FieldTypes[idx].FieldType;
      exit;
    end;
  end;
end;

function TRESTFilter.ToFilterString( FieldTypes: array of TFieldRecord ): string;
begin
  Result := getIdentifier;
  case getConstraint of
    csUnknown: Result := Result + '??';
    csGreaterThan: Result := Result + '>';
    csLessThan: Result := Result + '<';
    csGreaterOrEqual: Result := Result + '>=';
    csLessOrEqual: Result := Result + '<=';
    csEqual: Result := Result + '=';
    csNotEqual: Result := Result + '<>';
  end;
  case FieldType(FieldTypes,getIdentifier) of
    rftUnknown,
    rftString: begin
      Result := Result + ''''+getValueAsString+'''';
    end;
    else begin
      Result := Result + getValueAsString;
    end;
  end;
end;

{ TRESTFilterGroup }

function TRESTFilterGroup.AddFilter(Identifier: string; Constraint: TConstraint; Value: string): IRESTFilter;
var
  NewFilter: IRESTFilter;
begin
  NewFilter := TRESTFilter.Create;
  NewFilter.Identifier := Identifier;
  NewFilter.Constraint := Constraint;
  NewFilter.AsString := Value;
  fChildren.Add(NewFilter);
  Result := NewFilter;
end;

function TRESTFilterGroup.AddGroup(GroupOperator: TGroupOperator): IRESTFilterGroup;
var
  NewGroup: IRESTFilterGroup;
begin
  NewGroup := TRESTFilterGroup.Create;
  NewGroup.GroupOperator := GroupOperator;
  fChildren.Add(NewGroup);
  Result := NewGroup;
end;

function TRESTFilterGroup.AddItem(Item: IRESTFilterItem): IRestFilterItem;
begin
  fChildren.Add(Item);
  Result := Item;
end;

function TRESTFilterGroup.AsFilter: IRESTFilter;
begin
  Result := nil;
end;

function TRESTFilterGroup.ASGroup: IRESTFilterGroup;
begin
  Result := (Self as IRESTFilterGroup);
end;

constructor TRESTFilterGroup.Create;
begin
  inherited Create;
  fChildren := TList<IRESTFilterItem>.Create;
  fGroupOperator := opAND;
end;

destructor TRESTFilterGroup.Destroy;
begin
  fChildren.Clear;
  fChildren.DisposeOf;
  inherited Destroy;
end;

function TRESTFilterGroup.getCount: uint32;
begin
  Result := fChildren.Count;
end;

function TRESTFilterGroup.getGroupOperator: TGroupOperator;
begin
  Result := fGroupOperator;
end;

function TRESTFilterGroup.getItem(Index: uint32): IRESTFilterItem;
begin
  Result := fChildren[index];
end;

function TRESTFilterGroup.IsFilter: boolean;
begin
  Result := False;
end;

function TRESTFilterGroup.IsGroup: boolean;
begin
  Result := True;
end;

procedure TRESTFilterGroup.setGroupOperator(value: TGroupOperator);
begin
  fGroupOperator := Value;
end;

function TRESTFilterGroup.ToFilterString( FieldTypes: array of TFieldRecord ): string;
var
  idx: uint32;
begin
  if getGroupOperator=opGroup then begin
    Result := '(';
  end;
  if getCount=0 then begin
    Result := '';
    exit;
  end;
  //- Loop the child groups and filters and output them.
  for idx := 0 to pred(getCount) do begin
    Result := Result + getItem(idx).ToFilterString( FieldTypes );
    if idx<pred(getCount) then begin
      case getGroupOperator of
        opGroup: Result := Result + ' AND ';
        opAND: Result := Result + ' AND ';
        opOR: Result := Result + ' OR ';
      end;
    end;
  end;
  if getGroupOperator=opGroup then begin
    Result := Result + ')';
  end;
end;

end.