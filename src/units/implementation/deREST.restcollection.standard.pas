unit deREST.restcollection.standard;

interface
uses
  system.generics.collections,
  deREST;

type
  TRESTCollection = class( TInterfacedObject, IRESTCollection )
  private
    fObjects: TList<IRESTObject>;
  private //- IRESTCollection -//
    function getCount: uint32;
    function getItem( idx: uint32 ): IRESTObject;
    function addItem( aRestObject: IRESTObject ): uint32;
    procedure RemoveItem( idx: uint32 ); overload;
    procedure RemoveItem( aRestObject: IRESTObject ); overload;
    function Deserialize( JSONString: string ): boolean;
    function Serialize( var JSONString: string ): boolean;
  public
    constructor Create; reintroduce;
    destructor Destroy; override;
  end;

implementation
uses
  deREST.restobject.standard;

{ TRESTCollection }

function TRESTCollection.addItem(aRestObject: IRESTObject): uint32;
begin
  Result := fObjects.Add(aRestObject);
end;

constructor TRESTCollection.Create;
begin
  inherited Create;
  fObjects := TList<IRESTObject>.Create;
end;

function TRESTCollection.Deserialize(JSONString: string): boolean;
begin

end;

destructor TRESTCollection.Destroy;
begin
  fObjects.Clear;
  fObjects.DisposeOf;
  inherited Destroy;
end;

function TRESTCollection.getCount: uint32;
begin
  Result := fObjects.Count;
end;

function TRESTCollection.getItem(idx: uint32): IRESTObject;
begin
  Result := fObjects.Items[idx];
end;

procedure TRESTCollection.RemoveItem(aRestObject: IRESTObject);
begin
  fObjects.Remove(aRestObject);
end;

procedure TRESTCollection.RemoveItem(idx: uint32);
begin
  fObjects.Delete(idx);
end;

function TRESTCollection.Serialize(var JSONString: string): boolean;
begin

end;

end.
