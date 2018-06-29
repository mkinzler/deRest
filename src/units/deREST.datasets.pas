unit deREST.datasets;

interface
uses
  classes,
  Data.DB,
  FireDAC.Comp.Dataset;

type
  ///  <summary>
  ///  </summary>
  TRESTDataset = class(TCollectionItem)
  private
    fDataset: TFDDataset;
    fPublicName: string;
    procedure setPublicName(const Value: string);
  public
    procedure Assign( Source: TPersistent ); override;
  public
    constructor Create( aOwner: TCollection ); override;
    destructor Destroy; override;
  published
    property Dataset: TFDDataset read fDataset write fDataset;
    property PublicName: string read fPublicName write setPublicName;
  end;

  ///  <summary>
  ///  </summary>
  TRESTDatasets = class(TCollection)
  private
    fOwner: TComponent;
  private
    function GetItem(Index: Integer): TRESTDataset;
  public
    constructor Create(Owner: TComponent); reintroduce;
    destructor Destroy; override;
    function GetOwner: TPersistent; override;
    procedure Update(Item: TCollectionItem); override;
  public
    function Add: TRESTDataset; reintroduce;
    property Items[Index: Integer]: TRESTDataset read GetItem;
  end;


implementation
uses
  sysutils;

procedure TRESTDataset.Assign(Source: TPersistent);
var
  SourceDataset: TRESTDataset;
begin
  if not (Source is TRESTDataset) then begin
    exit;
  end;
  SourceDataset := (Source as TRESTDataset);
  Dataset := SourceDataset.Dataset;
  Self.PublicName := SourceDataset.PublicName;
end;

constructor TRESTDataset.Create(aOwner: TCollection);
begin
  inherited Create(aOwner);
end;

destructor TRESTDataset.Destroy;
begin
  inherited Destroy;
end;

procedure TRESTDataset.setPublicName(const Value: string);
begin
  fPublicName := Value;
end;

{ TRESTDatasets }

function TRESTDatasets.Add: TRESTDataset;
begin
  Result := (inherited Add) as TRESTDataset;
end;

constructor TRESTDatasets.Create(Owner: TComponent);
begin
  inherited Create(TRESTDataset);
  fOwner := Owner;
end;

destructor TRESTDatasets.Destroy;
begin
  inherited Destroy;
end;

function TRESTDatasets.GetItem(Index: Integer): TRESTDataset;
begin
  Result := ((inherited Items[index]) as TRESTDataset);
end;

function TRESTDatasets.GetOwner: TPersistent;
begin
  Result := fOwner;
end;

procedure TRESTDatasets.Update(Item: TCollectionItem);
begin
  inherited;
end;

end.
