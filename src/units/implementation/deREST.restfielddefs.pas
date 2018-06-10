unit deREST.restfielddefs;

interface
uses
  classes,
  Data.DB,
  FireDAC.Comp.Dataset;

type
  ///  <summary>
  ///    TRestField is a class representing a database field but using an
  ///    alias as the public name for that field. When a rest call is made
  ///    the call is mapped to genuine field names using a collection of
  ///    TRestField.
  ///  </summary>
  TRestFieldDef = class(TCollectionItem)
  private
    fField: string;
    fPublicName: string;
    procedure setPublicName(const Value: string);
  protected
    procedure setField(const Value: string);
  public
    procedure Assign( Source: TPersistent ); override;
  public
    constructor Create( aOwner: TCollection ); override;
    destructor Destroy; override;
  published
    property Field: string read fField write fField;
    property PublicName: string read fPublicName write setPublicName;
  end;

  ///  <summary>
  ///    A simple collection class, representing TRestField aliases for
  ///    database fields.
  ///  </summary>
  TRestFieldDefs = class(TCollection)
  private
    fOwner: TComponent;
  private
    function GetItem(Index: Integer): TRestFieldDef;
    function GetFieldByName(name: string): TRestFieldDef;
  public
    constructor Create(Owner: TComponent); reintroduce;
    destructor Destroy; override;
    function GetOwner: TPersistent; override;
    procedure Update(Item: TCollectionItem); override;
  public
    property FieldByName[ name: string ]: TRestFieldDef read GetFieldByName;
    function Add: TRestFieldDef; reintroduce;
    property Item[Index: Integer]: TRestFieldDef read GetItem;
  end;


implementation
uses
  sysutils;

{ TRestField }

procedure TRestFieldDef.Assign(Source: TPersistent);
var
  SourceField: TRestFieldDef;
begin
  if not (Source is TRestFieldDef) then begin
    exit;
  end;
  SourceField := (Source as TRestFieldDef);
  SetField(SourceField.Field);
  Self.PublicName := SourceField.PublicName;
end;

constructor TRestFieldDef.Create(aOwner: TCollection);
begin
  inherited Create(aOwner);
end;

destructor TRestFieldDef.Destroy;
begin
  inherited Destroy;
end;

procedure TRestFieldDef.setField(const Value: string);
begin
  fField := Value;
end;

procedure TRestFieldDef.setPublicName(const Value: string);
begin
  fPublicName := Value;
end;

{ TRestFields }

function TRESTFieldDefs.Add: TRestFieldDef;
begin
  Result := (inherited Add) as TRestFieldDef;
end;

constructor TRestFieldDefs.Create(Owner: TComponent);
begin
  inherited Create(TRestFieldDef);
  fOwner := Owner;
end;

destructor TRestFieldDefs.Destroy;
begin
  inherited Destroy;
end;

function TRestFieldDefs.GetFieldByName(name: string): TRestFieldDef;
var
  idx: int32;
  utName: string;
begin
  Result := nil;
  if Self.Count=0 then begin
    exit;
  end;
  utName := Uppercase(Trim(name));
  for idx := 0 to (pred(Self.Count)) do begin
    if Uppercase(Trim(TRestFieldDEf(Items[idx]).Field))=utName then begin
      Result := TRestFieldDef(Items[idx]);
      exit;
    end;
  end;
end;

function TRestFieldDefs.GetItem(Index: Integer): TRestFieldDef;
begin
  Result := (self.Items[index] as TRestFieldDef);
end;

function TRestFieldDefs.GetOwner: TPersistent;
begin
  Result := fOwner;
end;

procedure TRestFieldDefs.Update(Item: TCollectionItem);
begin
  inherited;
end;

end.
