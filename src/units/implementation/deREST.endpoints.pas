unit deREST.endpoints;

interface
uses
  classes,
  FireDAC.Comp.Dataset;

type
  ///  <summary>
  ///    TRestField is a class representing a database field but using an
  ///    alias as the public name for that field. When a rest call is made
  ///    the call is mapped to genuine field names using a collection of
  ///    TRestField.
  ///  </summary>
  TRestField = class(TCollectionItem)
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
    property Field: string read fField;
    property PublicName: string read fPublicName write setPublicName;
  end;

  ///  <summary>
  ///    A simple collection class, representing TRestField aliases for
  ///    database fields.
  ///  </summary>
  TRestFields = class(TCollection)
  private
    fOwner: TComponent;
  private
    function GetItem(Index: Integer): TRestField;
  public
    constructor Create(Owner: TComponent); reintroduce;
    destructor Destroy; override;
    function GetOwner: TPersistent; override;
    procedure Update(Item: TCollectionItem); override;
  public
    function Add: TRestField; reintroduce;
    property Item[Index: Integer]: TRestField read GetItem;
  end;

  ///  <summary>
  ///    TEndpoint represents an endpoint within the REST API.
  ///    The endpoint may be used to connect a path with a particular
  ///    rest collection (or database table).
  ///  </summary>
  TEndpoint = class(TCollectionItem)
  private
    fName: string;
    fFields: TRestFields;
    fDataset: TFDDataset;
    procedure setName(const Value: string);
    procedure setFields(const Value: TRestFields);
    procedure setDataset(const Value: TFDDataset);
  public
    procedure Assign( Source: TPersistent ); override;
  public
    constructor Create( aOwner: TCollection ); override;
    destructor Destroy; override;
  published

    ///  <summary>
    ///    Get/Set the dataset which this end-point represents.
    ///  </summary>
    property Datset: TFDDataset read fDataset write setDataset;

    ///  <summary>
    ///    Provides a collection of TRestField, which act as aliases between
    ///    the database field names and the public names of the fields for
    ///    the API.
    ///  </summary>
    property Fields: TRestFields read fFields write setFields;

    ///  <summary>
    ///    Used to specify the name of the endpoint.
    ///    This name must be unique among the other endpoint names under
    ///    the REST api.
    ///  </summary>
    property Name: string read fName write setName;
  end;


  ///  <summary>
  ///    A simple collection class, representing the collection of REST
  ///    endpoints managed by the API.
  ///  </summary>
  TEndpoints = class(TCollection)
  private
    fOwner: TComponent;
  private
    function GetItem(Index: Integer): TEndpoint;
  protected
    function GetOwnerComponent: TComponent;
  public
    constructor Create(Owner: TComponent); reintroduce;
    function GetOwner: TPersistent; override;
    procedure Update(Item: TCollectionItem); override;
  public
    function Add: TEndpoint; reintroduce;
    property Item[Index: Integer]: TEndpoint read GetItem;
  end;


implementation

{ TEndpoint }

procedure TEndpoint.Assign(Source: TPersistent);
var
  SourceEndpoint: TEndpoint;
begin
  if not (Source is TEndpoint) then begin
    exit;
  end;
  SourceEndpoint := (Source as TEndpoint);
  Self.Name := SourceEndpoint.Name;
end;

constructor TEndpoint.Create(aOwner: TCollection);
begin
  inherited Create(aOwner);
  fDataset := nil;
  fFields := TRestFields.Create((aOwner as TEndpoints).GetOwnerComponent);
end;

destructor TEndpoint.Destroy;
begin
  fFields.DisposeOf;
  inherited Destroy;
end;

procedure TEndpoint.setDataset(const Value: TFDDataset);
var
  idx: int32;
begin
  fDataset := Value;
  if fDataset.Fields.Count=0 then begin
    exit;
  end;
  for idx := 0 to pred(fDataset.Fields.Count) do begin
    Self.Fields.Add.SetField( fDataset.Fields[idx].FieldName );
  end;
end;

procedure TEndpoint.setFields(const Value: TRestFields);
begin
  fFields.Assign(Value);
end;

procedure TEndpoint.setName(const Value: string);
begin
  fName := Value;
end;

{ TEndpoints }

function TEndpoints.Add: TEndpoint;
begin
  Result := (inherited Add) as TEndpoint;
end;

constructor TEndpoints.Create(Owner: TComponent);
begin
  inherited Create(TEndpoint);
  fOwner := Owner;
end;

function TEndpoints.GetItem(Index: Integer): TEndpoint;
begin
  Result := (self.Items[index] as TEndpoint);
end;

function TEndpoints.GetOwner: TPersistent;
begin
  Result := fOwner;
end;

function TEndpoints.GetOwnerComponent: TComponent;
begin
  Result := fOwner;
end;

procedure TEndpoints.Update(Item: TCollectionItem);
begin
  inherited;
end;


{ TRestField }

procedure TRestField.Assign(Source: TPersistent);
var
  SourceField: TRestField;
begin
  if not (Source is TRestField) then begin
    exit;
  end;
  SourceField := (Source as TRestField);
  SetField(SourceField.Field);
  Self.PublicName := SourceField.PublicName;
end;

constructor TRestField.Create(aOwner: TCollection);
begin
  inherited Create(aOwner);
end;

destructor TRestField.Destroy;
begin
  inherited Destroy;
end;

procedure TRestField.setField(const Value: string);
begin
  fField := Value;
end;

procedure TRestField.setPublicName(const Value: string);
begin
  fPublicName := Value;
end;

{ TRestFields }

function TRestFields.Add: TRestField;
begin
  Result := (inherited Add) as TRestField;
end;

constructor TRestFields.Create(Owner: TComponent);
begin
  inherited Create(TRestField);
  fOwner := Owner;
end;

destructor TRestFields.Destroy;
begin
  inherited Destroy;
end;

function TRestFields.GetItem(Index: Integer): TRestField;
begin
  Result := (self.Items[index] as TRestField);
end;

function TRestFields.GetOwner: TPersistent;
begin
  Result := fOwner;
end;

procedure TRestFields.Update(Item: TCollectionItem);
begin
  inherited;
end;

end.
