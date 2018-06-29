unit deREST;

interface
uses
  Web.HTTPApp,
  deREST.datasets,
  classes;

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

type
  ///  <summary>
  ///    Describes the type of constraint applied to the filter.
  ///    For example, opGreaterThan means that the value of items selected
  ///    by the filter, should be greater than the value of the filter it's
  ///    self.
  ///  </summary>
  TConstraint = (
    csUnknown,
    csGreaterThan,
    csLessThan,
    csGreaterOrEqual,
    csLessOrEqual,
    csEqual,
    csNotEqual
  );

  ///  <summary>
  ///    Defines the logical operation used to combine the children of an
  ///    IRESTFilteGroup (group of filters).
  ///  </summary>
  TGroupOperator = (
    opGroup,
    opAND,
    opOR
  );

  IRESTFilter = interface; // forward declaration.
  IRESTFilterGroup = interface; // forward declaration.

  ///  <summary>
  ///    IRESTFilterItem is a common base interface for IRESTFilter and
  ///    IRESTFilterGroup. It's only use is to provide a consistent type
  ///    for handling filters and groups as children of other groups.
  ///    You should not need to work with this interface directly.
  ///  </summary>
  IRESTFilterItem = interface

    ///  <summary>
    ///    Returns the filter, or group of filters as a string.
    ///    The returned string should match the input string.
    ///  </summary>
    function ToFilterString: string;

    ///  <summary>
    ///    Returns this item cast as an IRESTFilter.
    ///    If the item implements only IRESTFilterGroup this method will
    ///    return nil.
    ///  </summary>
    function AsFilter: IRESTFilter;

    ///  <summary>
    ///    Returns this item cast as an IRESTFilterGroup.
    ///    If the item implements only IRESTFilter, this method will return
    ///    nil.
    ///  </summary>
    function ASGroup: IRESTFilterGroup;

    ///  <summary>
    ///    Returns true if this item implements IRESTFilter.
    ///  </summary>
    function IsFilter: boolean;

    ///  <summary>
    ///    Returns true if this item implements IRESTFilterGroup.
    ///  </summary>
    function IsGroup: boolean;
  end;

  ///  <summary>
  ///    Represents a selection filter with an identifier (field name), a
  ///    value, and a constraint.
  ///  </summary>
  IRESTFilter = interface( IRESTFilterItem )
    ['{C0F63FF2-F3A3-4672-B110-35280A488C4E}']
    function getIdentifier: string;
    procedure setIdentifier( value: string );
    function getConstraint: TConstraint;
    procedure setConstraint( value: TConstraint );
    function getValueAsString: string;
    procedure setValueAsString( value: string );
    function getValueAsInteger: int32;
    procedure setValueAsInteger( value: int32 );
    function getValueAsFloat: double;
    procedure setValueAsFloat( value: double );
    function getValueAsBoolean: boolean;
    procedure setValueAsBoolean( value: boolean );
    function getValueAsDateTime: TDateTime;
    procedure setValueAsDateTime( value: TDateTime );

    //- Pascal Only, properties -//
    property Identifier: string read getIdentifier write setIdentifier;
    property Constraint: TConstraint read getConstraint write setConstraint;
    property AsString: string read getValueAsString write setValueAsString;
    property AsInteger: int32 read getValueAsInteger write setValueAsInteger;
    property AsFloat: double read getValueAsFloat write setValueAsFloat;
    property AsBoolean: boolean read getValueAsBoolean write setValueAsBoolean;
    property AsDateTime: TDateTime read getValueAsDateTime write setValueAsDateTime;
  end;

  ///  <summary>
  ///    Represents a group of filters and a logical operator which binds them.
  ///    For example, the logical operator may be opAND meaning the child
  ///    filters of this group must be appllied using an AND operation.
  ///  </summary>
  IRESTFilterGroup = interface( IRESTFilterItem )
    ['{549F2AFC-E753-4165-ABA9-9E031A287224}']

    ///  <summary>
    ///    Returns the number of child items contained by this group.
    ///  </summary>
    function getCount: uint32;

    ///  <summary>
    ///    Returns a child item of this group as specified by index.
    ///  </summary>
    function getItem( Index: uint32 ): IRESTFilterItem;

    ///  <summary>
    ///    Returns the group operator used to logically combine the group
    ///    of filters.
    ///  </summary>
    function getGroupOperator: TGroupOperator;

    ///  <summary>
    ///    Sets the group operator used to logically combine the group of
    ///    filters.
    ///  </summary>
    procedure setGroupOperator( value: TGroupOperator );

    ///  <summary>
    ///    Adds a new filter to this group. (as a child)
    ///  </summary>
    function AddFilter( Identifier: string; Constraint: TConstraint; Value: string ): IRESTFilter;

    ///  <summary>
    ///    Adds a new group of filters as a child.
    ///  </summary>
    function AddGroup( GroupOperator: TGroupOperator ): IRESTFilterGroup;

    ///  <summary>
    ///    Adds either a group or filter.
    ///  </summary>
    function AddItem( Item: IRESTFilterItem ): IRestFilterItem;

    //- Pascal Only, properties -//
    property Count: uint32 read getCount;
    property Items[ index: uint32 ]: IRESTFilterItem read getItem;
    property GroupOperator: TGroupOperator read getGroupOperator write setGroupOperator;
  end;

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

type
  ///  <summary>
  ///    Callback type for events fired after each CRUD event.
  ///  </summary>
  TRESTEvent = procedure( Response: IRESTResponse ) of object;

  ///  <summary>
  ///    Event called before a filtered request (READ/UPDATE/DELETE) is
  ///    processed. If the processed parameter is set true during the event
  ///    handler, then processing of this request is considered complete, and
  ///    no action will be performed on the dataset.
  ///    If objects are added to the Response collection, then execution will
  ///    proceed with the event handler for AFTER the request. Otherwise the
  ///    response will be processed and sent.
  ///  </summary>
  TRESTFilteredEvent = procedure( RequestFilters: IRESTFilterGroup; Response: IRESTResponse; var Processed: boolean ) of object;

  ///  <summary>
  ///    Represents a REST API (collection of endpoitns).
  ///  </summary>
  TRESTAPI = class(TCustomContentProducer)
  private
    fDatasets: TRESTDatasets;
    fOnBeforeRESTDelete: TRESTFilteredEvent;
    fOnBeforeRESTUpdate: TRESTFilteredEvent;
    fOnBeforeRESTRead: TRESTFilteredEvent;
    fOnBeforeRESTCreate: TRESTEvent;
    fOnAfterRESTDelete: TRESTEvent;
    fOnAfterRESTUpdate: TRESTEvent;
    fOnAfterRESTRead: TRESTEvent;
    fOnAfterRESTCreate: TRESTEvent;
  private
    procedure ProcessDeleteRequest(Dispatcher: IWebDispatcherAccess);
    procedure ProcessGetRequest(Dispatcher: IWebDispatcherAccess);
    procedure ProcessPostRequest(Dispatcher: IWebDispatcherAccess);
    procedure ProcessPutRequest(Dispatcher: IWebDispatcherAccess);
    function ParseFilters(FilterURL: string): IRESTFilterGroup;
  protected
    procedure SetDatasets(Value: TRESTDatasets);
  protected
    procedure Notification(AnObject: TComponent; Operation: TOperation); override;
  public
    function Content: string; override;
    constructor Create( aOwner: TComponent ); override;
    destructor Destroy; override;
  published
    property OnBeforeRESTCreate: TRESTEvent read fOnBeforeRESTCreate write fOnBeforeRESTCreate;
    property OnAfterRESTCreate: TRESTEvent read fOnAfterRESTCreate write fOnAfterRESTCreate;
    property OnBeforeRESTRead: TRESTFilteredEvent read fOnBeforeRESTRead write fOnBeforeRESTRead;
    property OnAfterRESTRead: TRESTEvent read fOnAfterRESTRead write fOnAfterRESTRead;
    property OnBeforeRESTUpdate: TRESTFilteredEvent read fOnBeforeRESTUpdate write fOnBeforeRESTUpdate;
    property OnAfterRESTUpdate: TRESTEvent read fOnAfterRESTUpdate write fOnAfterRESTUpdate;
    property OnBeforeRESTDelete: TRESTFilteredEvent read fOnBeforeRESTDelete write fOnBeforeRESTDelete;
    property OnAfterRESTDelete: TRESTEvent read fOnAfterRESTDelete write fOnAfterRESTDelete;

    property Datasets: TRESTDatasets read fDatasets write setDatasets;
  end;




procedure Register;

implementation
uses
  sysutils,
  deREST.filterparser,
  deREST.restfilter.standard,
  deREST.restresponse.standard;

procedure Register;
begin
  RegisterComponents('deREST', [TRESTAPI]);
end;


function TRESTAPI.ParseFilters( FilterURL: string ): IRESTFilterGroup;
var
  aRestFilterGroup: IRestFilterGroup;
  FilterParser: TRESTFilterParser;
begin
  Result := nil;
  aRESTFilterGroup := TRestFilterGroup.Create;
  FilterParser := TRESTFilterParser.Create;
  try
    if not FilterParser.Parse( FilterURL, aRestFilterGroup ) then begin
      exit;
    end;
  finally
    FilterParser.DisposeOf;
  end;
  Result := aRESTFilterGroup;
end;

procedure TRESTAPI.ProcessGetRequest( Dispatcher: IWebDispatcherAccess );
var
  Str: string;
  Filters: IRESTFilterGroup;
  Response: IRESTResponse;
  Processed: boolean;
begin
  //- Get the URL filters.
  Filters := ParseFilters( Dispatcher.Request.Query );
  if not assigned(Filters) then begin
    Dispatcher.Response.StatusCode := 500;
    Dispatcher.Response.Content := 'Invalid filters';
    Dispatcher.Response.SendResponse;
    exit;
  end;
  Processed := False;
  Response := TRESTResponse.Create;
  try
    Dispatcher.Response.StatusCode := 200;
     Dispatcher.Response.Content := Filters.ToFilterString;
    Dispatcher.Response.SendResponse;
    exit;

    //- If before event is assigned, call it.
    if assigned(fOnBeforeRESTRead) then begin
      fOnBeforeRESTRead( Filters, Response, Processed );
    end;
    //- if after event is assigned, call it.
    if assigned(fOnAfterRESTRead) then begin
      fOnAfterRESTRead( Response );
    end;
    //- Process result.
    Dispatcher.Response.StatusCode := uint32(Response.ResponseCode);
    Dispatcher.Response.ContentEncoding := 'plain/text';
    if Dispatcher.Response.StatusCode=200 then begin
      if not Response.ResponseCollection.Serialize(Str) then begin
        Dispatcher.Response.StatusCode := 500;
        Dispatcher.Response.Content := 'Failed to serialize response.';
        Dispatcher.Response.SendResponse;
        exit;
      end;
      Dispatcher.Response.Content := Str;
    end else begin
      Dispatcher.Response.Content := Response.ResponseMessage;
    end;
    //- Send the response.
    Dispatcher.Response.SendResponse;
  finally
    Response := nil;
  end;
end;

procedure TRESTAPI.ProcessPostRequest( Dispatcher: IWebDispatcherAccess );
var
  Str: string;
  Filters: IRESTFilterGroup;
  Response: IRESTResponse;
  Processed: boolean;
begin
  //- Get the URL filters.
  Filters := ParseFilters( Dispatcher.Request.URL );
  if not assigned(Filters) then begin
    Dispatcher.Response.StatusCode := 500;
    Dispatcher.Response.Content := 'Invalid filters';
    Dispatcher.Response.SendResponse;
    exit;
  end;
  Processed := False;
  //- If before event is assigned, call it.
  if assigned(fOnBeforeRESTRead) then begin
    fOnBeforeRESTRead( Filters, Response, Processed );
  end;
  //- if after event is assigned, call it.
  if assigned(fOnAfterRESTRead) then begin
    fOnAfterRESTRead( Response );
  end;
  //- Process result.
  Dispatcher.Response.StatusCode := uint32(Response.ResponseCode);
  Dispatcher.Response.ContentEncoding := 'plain/text';
  if Dispatcher.Response.StatusCode=200 then begin
    if not Response.ResponseCollection.Serialize(Str) then begin
      Dispatcher.Response.StatusCode := 500;
      Dispatcher.Response.Content := 'Failed to serialize response.';
      Dispatcher.Response.SendResponse;
      exit;
    end;
    Dispatcher.Response.Content := Str;
  end else begin
    Dispatcher.Response.Content := Response.ResponseMessage;
  end;
  //- Send the response.
  Dispatcher.Response.SendResponse;
end;


procedure TRESTAPI.ProcessPutRequest( Dispatcher: IWebDispatcherAccess );
var
  Str: string;
  Filters: IRESTFilterGroup;
  Response: IRESTResponse;
  Processed: boolean;
begin
  //- Get the URL filters.
  Filters := ParseFilters( Dispatcher.Request.URL );
  if not assigned(Filters) then begin
    Dispatcher.Response.StatusCode := 500;
    Dispatcher.Response.Content := 'Invalid filters';
    Dispatcher.Response.SendResponse;
    exit;
  end;
  Processed := False;
  //- If before event is assigned, call it.
  if assigned(fOnBeforeRESTRead) then begin
    fOnBeforeRESTRead( Filters, Response, Processed );
  end;
  //- if after event is assigned, call it.
  if assigned(fOnAfterRESTRead) then begin
    fOnAfterRESTRead( Response );
  end;
  //- Process result.
  Dispatcher.Response.StatusCode := uint32(Response.ResponseCode);
  Dispatcher.Response.ContentEncoding := 'plain/text';
  if Dispatcher.Response.StatusCode=200 then begin
    if not Response.ResponseCollection.Serialize(Str) then begin
      Dispatcher.Response.StatusCode := 500;
      Dispatcher.Response.Content := 'Failed to serialize response.';
      Dispatcher.Response.SendResponse;
      exit;
    end;
    Dispatcher.Response.Content := Str;
  end else begin
    Dispatcher.Response.Content := Response.ResponseMessage;
  end;
  //- Send the response.
  Dispatcher.Response.SendResponse;
end;

procedure TRESTAPI.ProcessDeleteRequest( Dispatcher: IWebDispatcherAccess );
var
  Str: string;
  Filters: IRESTFilterGroup;
  Response: IRESTResponse;
  Processed: boolean;
begin
  //- Get the URL filters.
  Filters := ParseFilters( Dispatcher.Request.URL );
  if not assigned(Filters) then begin
    Dispatcher.Response.StatusCode := 500;
    Dispatcher.Response.Content := 'Invalid filters';
    Dispatcher.Response.SendResponse;
    exit;
  end;
  Processed := False;
  //- If before event is assigned, call it.
  if assigned(fOnBeforeRESTRead) then begin
    fOnBeforeRESTRead( Filters, Response, Processed );
  end;
  //- if after event is assigned, call it.
  if assigned(fOnAfterRESTRead) then begin
    fOnAfterRESTRead( Response );
  end;
  //- Process result.
  Dispatcher.Response.StatusCode := uint32(Response.ResponseCode);
  Dispatcher.Response.ContentEncoding := 'plain/text';
  if Dispatcher.Response.StatusCode=200 then begin
    if not Response.ResponseCollection.Serialize(Str) then begin
      Dispatcher.Response.StatusCode := 500;
      Dispatcher.Response.Content := 'Failed to serialize response.';
      Dispatcher.Response.SendResponse;
      exit;
    end;
    Dispatcher.Response.Content := Str;
  end else begin
    Dispatcher.Response.Content := Response.ResponseMessage;
  end;
  //- Send the response.
  Dispatcher.Response.SendResponse;
end;

function TRESTAPI.Content: string;
var
  utMethod: string;
begin
  Result := Dispatcher.Request.URL;
  //- Determine the HTTP method.
  utMethod := Uppercase(Trim(Dispatcher.Request.Method));
  if utMethod='GET' then begin
    ProcessGetRequest(Dispatcher);
  end else if utMethod='POST' then begin
    ProcessPostRequest(Dispatcher);
  end else if utMethod='PUT' then begin
    ProcessPutRequest(Dispatcher);
  end else if utMethod='DELETE' then begin
    ProcessDeleteRequest(Dispatcher);
  end else begin
    Dispatcher.Response.StatusCode := 500;
    Dispatcher.Response.ContentEncoding := 'plain/text';
    Dispatcher.Response.Content := 'Method not implemented: '+Dispatcher.Request.Method;
    Dispatcher.Response.SendResponse;
  end;
end;

constructor TRESTAPI.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  // Ensure the rest manager component is installed on a web module,
  // we need access to the actions list.
  if not (aOwner is TWebModule) then begin
    raise
      Exception.Create('TRESTManager component must be placed on a TWebModule.');
  end;
  // Create endpoints
  fDatasets := TRestDatasets.Create(Self);
end;

destructor TRESTAPI.Destroy;
begin
  fDatasets := nil;
  inherited Destroy;
end;

procedure TRESTAPI.Notification(AnObject: TComponent; Operation: TOperation);
var
  idx: Integer;
begin
  if (Operation<>TOperation.opRemove) then begin
    exit;
  end;
  if AnObject=nil then begin
    exit;
  end;
  for idx := 0 to pred(fDatasets.Count) do begin
    if (fDatasets.Items[idx].Dataset) = AnObject then begin
      fDatasets.Items[idx].Dataset := nil;
    end;
  end;
end;

procedure TRESTAPI.SetDatasets(Value: TRESTDatasets);
begin
  fDatasets.Assign(Value);
end;

end.
