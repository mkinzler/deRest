unit deREST.restresponse.standard;

interface
uses
  deREST;

type
  TRESTResponse = class( TInterfacedObject, IRESTResponse )
  private
    fResponseCode: THTTPResponseCode;
    fResponseMessage: string;
    fResponseCollection: IRESTCollection;
  private //- IRESTResponse -//
    function getResponseCollection: IRestCollection;
    function getResponseCode: THTTPResponseCode;
    procedure setResponseCode( Code: THTTPResponseCode );
    function getResponseMessage: string;
    procedure setResponseMessage( value: string );
  public
    constructor Create; reintroduce;
    destructor Destroy; override;
  end;

implementation
uses
  deREST.restcollection.standard;

{ TRESTResponse }

constructor TRESTResponse.Create;
begin
  inherited Create;
  fResponseCollection := TRestCollection.Create;
end;

destructor TRESTResponse.Destroy;
begin
  fResponseCollection := nil;
  inherited Destroy;
end;

function TRESTResponse.getResponseCode: THTTPResponseCode;
begin
  Result := fResponseCode;
end;

function TRESTResponse.getResponseCollection: IRestCollection;
begin
  Result := fResponseCollection;
end;

function TRESTResponse.getResponseMessage: string;
begin
  Result := fResponseMessage;
end;

procedure TRESTResponse.setResponseCode(Code: THTTPResponseCode);
begin
  fResponseCode := Code;
end;

procedure TRESTResponse.setResponseMessage(value: string);
begin
  fResponseMessage := Value;
end;

end.
