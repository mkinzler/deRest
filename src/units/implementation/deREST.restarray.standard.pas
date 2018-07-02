//------------------------------------------------------------------------------
// MIT License
//
//  Copyright (c) 2018 Craig Chapman
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//------------------------------------------------------------------------------
unit deREST.restarray.standard;

interface
uses
  system.generics.collections,
  deREST;

type
  TRESTArray = class( TInterfacedObject, IRESTArray )
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

function TRESTArray.addItem: IRESTObject;
var
  NewObject: IRESTObject;
begin
  NewObject := TRESTObject.Create;
  fObjects.Add(NewObject);
  Result := NewObject;
end;

constructor TRESTArray.Create;
begin
  inherited Create;
  fObjects := TList<IRESTObject>.Create;
end;

function TRESTArray.Deserialize(JSONString: string): boolean;
var
  a: TJSONArray;
begin
  a := TJSONObject.ParseJSONValue(JSONString) as TJSONArray;
end;

destructor TRESTArray.Destroy;
begin
  fObjects.Clear;
  fObjects.DisposeOf;
  inherited Destroy;
end;

function TRESTArray.getCount: uint32;
begin
  Result := fObjects.Count;
end;

function TRESTArray.getItem(idx: uint32): IRESTObject;
begin
  Result := fObjects.Items[idx];
end;

procedure TRESTArray.RemoveItem(aRestObject: IRESTObject);
begin
  fObjects.Remove(aRestObject);
end;

procedure TRESTArray.RemoveItem(idx: uint32);
begin
  fObjects.Delete(idx);
end;

function TRESTArray.Serialize(var JSONString: string): boolean;
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
