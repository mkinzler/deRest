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
    function addItem: IRESTObject;
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
  System.JSON,
  deREST.restobject.standard;

{ TRESTCollection }

function TRESTCollection.addItem: IRESTObject;
var
  NewObject: IRESTObject;
begin
  NewObject := TRESTObject.Create;
  fObjects.Add(NewObject);
  Result := NewObject;
end;

constructor TRESTCollection.Create;
begin
  inherited Create;
  fObjects := TList<IRESTObject>.Create;
end;

function TRESTCollection.Deserialize(JSONString: string): boolean;
var
  a: TJSONArray;
begin
  a := TJSONObject.ParseJSONValue(JSONString) as TJSONArray;
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
var
  idx: uint32;
  idy: uint32;
  item: IRESTObject;
begin
  Result := True;
  if getCount=0 then begin
    JSONString := '[]';
    exit;
  end;
  JSONString := '[';
  for idx := 0 to pred(getCount) do begin
    JSONString := JSONString + '{';
    Item := getItem(idx);
    if item.Count>0 then begin
      for idy := 0 to pred(item.Count) do begin
        JSONString := JSONString + '"' + Item.Name[idy] + '": "';
        JSONString := JSONString + Item.ValueByIndex[idy] +'"';
        if idy<pred(item.Count) then begin
          JSONString := JSONString + ',';
        end;
      end;
    end;
    JSONString := JSONString + '}';
    if idx<pred(getCount) then begin
      JSONString := JSONString + ',';
    end;
  end;
  JSONString := JSONString + ']';
end;

end.
