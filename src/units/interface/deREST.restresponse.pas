unit deREST.restresponse;

interface
uses
  deREST.restcollections,
  deREST.restobject;

type
  THTTPResponseCode =
    (
       rcOkay = 200,
      rcError = 500
    );

  IRESTResponse = interface
    ['{A437EAA6-C487-4BE7-8C62-1477731F7BCD}']
    function getResponseCollection: IRestCollection;
    function getResponseCode: THTTPResponseCode;
    procedure setResponseCode( Code: THTTPResponseCode );
    function getResponseMessage: string;
    procedure setResponseMessage( value: string );

    //- Pascal Only, properties -//
    property ResponseCode: THTTPResponseCode read getResponseCode write setResponseCode;
    property ResponseMessage: string read getResponseMessage write setResponseMessage;
    property ResponseCollection: IRESTCollection read getResponseCollection;
  end;

implementation

end.
