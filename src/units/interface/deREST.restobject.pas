unit deREST.restobject;

interface

type
  IRESTObject = interface
    ['{01E34F62-FCD3-4333-B224-76AEEE96D59F}']
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

    //- Pascal Only, properties -//
    property Count: uint32 read getCount;
    property Name[ idx: uint32 ]: string read getNameByIndex write setNameByIndex;
    property Value[ name: string ]: string read getValueByName write setValueByName;
    property ValueByIndex[ idx: uint32 ]: string read getValueByIndex write setValueByIndex;
  end;

implementation

end.
