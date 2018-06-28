unit deREST.restobject.standard;

interface
uses
  classes,
  deREST.restobject;

type
  TRESTObject = class( TInterfacedObject, IRESTObject )
  private
    fValues: TStringList;
  private //- IRESTObject -//
    function getCount: uint32;
    function getNameByIndex( idx: uint32 ): string;
    function getValueByIndex( idx: uint32 ): string;
    function getValueByName( aname: string ): string;
    procedure setNameByIndex( idx: uint32; aname: string );
    procedure setValueByIndex( idx: uint32; avalue: string );
    procedure setValueByName( aname: string; avalue: string );
    procedure AddValue( aname: string; avalue: string );
    procedure RemoveValue( aname: string ); overload;
    procedure RemoveValue( idx: uint32 ); overload;
  public
    constructor Create; reintroduce;
    destructor Destroy; override;
  end;

implementation

{ TRESTObject }

procedure TRESTObject.AddValue(aname, avalue: string);
begin
  fValues.Add(aName+'='+aValue);
end;

constructor TRESTObject.Create;
begin
  inherited Create;
  fValues := TStringList.Create;
end;

destructor TRESTObject.Destroy;
begin
  fValues.DisposeOf;
  inherited Destroy;
end;

function TRESTObject.getCount: uint32;
begin
  Result := fValues.Count;
end;

function TRESTObject.getNameByIndex(idx: uint32): string;
begin
  Result := fValues.Names[idx];
end;

function TRESTObject.getValueByIndex(idx: uint32): string;
begin
  Result := fValues.ValueFromIndex[idx];
end;

function TRESTObject.getValueByName(aname: string): string;
begin
  Result := fValues.Values[aname];
end;

procedure TRESTObject.RemoveValue(aname: string);
begin
  fValues.Delete( fValues.IndexOf(aname) );
end;

procedure TRESTObject.RemoveValue(idx: uint32);
begin
  fValues.Delete(idx);
end;

procedure TRESTObject.setNameByIndex(idx: uint32; aname: string);
var
  NewString: string;
begin
  NewString := aName + '=' + fValues.ValueFromIndex[idx];
  fValues.Add(NewString);
  fValues.Delete(idx);
end;

procedure TRESTObject.setValueByIndex(idx: uint32; avalue: string);
begin
  fValues.ValueFromIndex[idx] := aValue;
end;

procedure TRESTObject.setValueByName(aname, avalue: string);
begin
  fValues.Values[aname] := aValue;
end;

end.
