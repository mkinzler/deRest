unit deREST.restcollections;

interface
uses
  deREST.restobject;

type
  IRESTCollection = interface
    ['{AB9B8FEF-6C6E-468C-A4DC-E9303309450F}']
    function getCount: uint32;
    function getItem( idx: uint32 ): IRESTObject;
    function addItem( aRestObject: IRESTObject ): uint32;
    procedure RemoveItem( idx: uint32 ); overload;
    procedure RemoveItem( aRestObject: IRESTObject ); overload;
    function Deserialize( JSONString: string ): boolean;
    function Serialize( var JSONString: string ): boolean;

    //- Pascal Onky, properties -//
    property Count: uint32 read getCount;
    property Items[ idx: uint32 ]: IRESTObject read getItem;
  end;

implementation

end.
