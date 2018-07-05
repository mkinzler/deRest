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
unit deREST;

interface
uses
  Data.DB,
  Web.HTTPApp,
  FireDAC.Comp.Client,
  deREST.pathinfo,
  classes;

type
  IRESTObject = interface
    ['{01E34F62-FCD3-4333-B224-76AEEE96D59F}']
    procedure Assign( SourceObject: IRESTObject );
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
    csNotEqual,
    csLike
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

  ///  <summary>
  ///    HTTP Response codes
  ///  </summary>
  THTTPResponseCode =
    (

      rc100_Continue = 100,
      rc101_witchingProtocols = 101,
      rc102_Processing = 102,
      rc103_EarlyHints = 103,
      rc200_OK = 200,
      rc201_Created = 201,
      rc202_Accepted = 202,
      rc203_NonAuthInfo = 203,
      rc204_NoContent = 204,
      rc205_ResetContent = 205,
      rc206_PartialContent = 206,
      rc207_MultiStatus = 207,
      rc208_AlreadyReported = 208,
      rc226_IMUsed = 226,
      rc300_MultipleChoices = 300,
      rc301_MovedPermanently = 301,
      rc302_Found = 302,
      rc303_SeeOther = 303,
      rc304_NotModified = 304,
      rc305_UseProxy = 305,
      rc306_SwitchProxy = 306,
      rc307_TemporaryRedirect = 307,
      rc308_PermanentRedirect = 308,
      rc400_BadRequest = 400,
      rc401_Unauthorized = 401,
      rc402_PaymentRequired = 402,
      rc403_Forbidden = 403,
      rc404_NotFound = 404,
      rc405_MethodNotAllowed = 405,
      rc406_NotAcceptable = 406,
      rc407_ProxyAuthRequired = 407,
      rc408_RequestTimeout = 408,
      rc409_Conflict = 409,
      rc410_Gone = 410,
      rc411_LengthRequired = 411,
      rc412_PreconditionFailed = 412,
      rc413_PayloadTooLarge = 413,
      rc414_URITooLong = 414,
      rc415_UnsupportedMediaType = 415,
      rc416_RangeNotSatisfiable = 416,
      rc417_ExpectationFailed = 417,
      rc418_Teapot = 418,
      rc421_MisdirectedRequest = 421,
      rc422_UnprocessableEntity = 422,
      rc423_Locked = 423,
      rc424_FailedDependency = 424,
      rc426_UpgradeRequired = 426,
      rc428_PreconditionRequired = 428,
      rc429_TooManyRequests = 429,
      rc431_RequestHeaderFieldsTooLarge = 431,
      rc451_UnavailableForLegalReasons  = 451,
      rc500_InternalServerError = 500,
      rc501_NotImplemented = 501,
      rc502_BadGateway = 502,
      rc503_ServiceUnavailable = 503,
      rc504_GatewayTimeout = 504,
      rc505_HTTPVersionNotSupported = 505,
      rc506_VariantAlsoNegotiates = 506,
      rc507_InsufficientStorage = 507,
      rc508_LoopDetected = 508,
      rc510_NotExtended = 510,
      rc511_NetworkAuthRequired = 511

    );

  /// <exclude/>
  IRESTFilter = interface; // forward declaration.

  /// <exclude/>
  IRESTFilterGroup = interface; // forward declaration.

  /// <exclude/>
  IRESTResponse = interface; // forward declaration.

  /// <exclude/>
  IRESTArray = interface; // forward declaration.

  ///  <summary>
  ///    Callback type for events fired before and after a CREATE event.
  ///  </summary>
  TRESTCreateEvent = procedure( Request: IRESTArray; Response: IRESTResponse ) of object;

  ///  <summary>
  ///    Event called before and after a READ event
  ///  </summary>
  TRESTReadEvent = procedure( RequestFilters: IRESTFilterGroup; Response: IRESTResponse ) of object;

  ///  <summary>
  ///    Event called before and after an UPDATE event.
  ///  </summary>
  TRESTUpdateEvent = procedure( Request: IRESTArray; RequestFilters: IRESTFilterGroup; Response: IRESTResponse ) of object;

  ///  <summary>
  ///    Event called before and after a DELETE event.
  ///  </summary>
  TRESTDeleteEvent = procedure( RequestFilters: IRESTFilterGroup; Response: IRESTResponse ) of object;


  ///  <summary>
  ///    IRESTFilterItem is a common base interface for IRESTFilter and
  ///    IRESTFilterGroup. It's only use is to provide a consistent type
  ///    for handling filters and groups as children of other groups.
  ///    You should not need to work with this interface directly.
  ///  </summary>
  IRESTFilterItem = interface

    ///  <summary>
    ///    Searches the filters by their parameter names and returns
    ///    the the filter.
    ///  </summary>
    function ParamValue( ParamName: string ): IRestFilterItem;

    ///  <summary>
    ///    Returns the filter, or group of filters as a string.
    ///    The returned string should match the input string.
    ///  </summary>
    function ToWhereClause: string;

    ///  <summary>
    ///    Assigns a unique parameter name to each filter item so that
    ///    the parameter values may be applied to a query string.
    ///  </summary>
    procedure AssignParameterNames( var counter: uint32 );

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

    ///  <summary>
    ///    Returns the identifier of the field that this filter applies to.
    ///  </summary>
    function getIdentifier: string;

    ///  <summary>
    ///    Sets the identifier of the field that this filter applies to.
    ///  </summary>
    procedure setIdentifier( value: string );

    ///  <summary>
    ///    Gets the constraint applied by this filter.
    ///  </summary>
    function getConstraint: TConstraint;

    ///  <summary>
    ///    Sets the constraint applied by this filter.
    ///  </summary>
    procedure setConstraint( value: TConstraint );

    ///  <summary>
    ///    Gets the value of this filter as a string.
    ///  </summary>
    function getValueAsString: string;

    ///  <summary>
    ///    Sets the value of this filter as a string.
    ///  </summary>
    procedure setValueAsString( value: string );

    ///  <summary>
    ///    Gets the value of this filter as an integer (int32).
    ///  </summary>
    function getValueAsInteger: int32;

    ///  <summary>
    ///    Sets the value of this filter as an integer (int32).
    ///  </summary>
    procedure setValueAsInteger( value: int32 );

    ///  <summary>
    ///    Gets the value of this filter as a float (double).
    ///  </summary>
    function getValueAsFloat: double;

    ///  <summary>
    ///    Sets the value of this filter as a float (double).
    ///  </summary>
    procedure setValueAsFloat( value: double );

    ///  <summary>
    ///    Gets the value of this filter as a boolean.
    ///  </summary>
    function getValueAsBoolean: boolean;

    ///  <summary>
    ///    Sets the value of this filter as a boolean.
    ///  </summary>
    procedure setValueAsBoolean( value: boolean );

    ///  <summary>
    ///    Gets the value of this filter as a TDateTime.
    ///  </summary>
    function getValueAsDateTime: TDateTime;

    ///  <summary>
    ///    Sets the value of this filter as a TDateTime.
    ///  </summary>
    procedure setValueAsDateTime( value: TDateTime );

    //- Pascal Only, properties -//

    ///  <summary>
    ///    Get or Set the identifier of the field that this filter applies to.
    ///  </summary>
    property Identifier: string read getIdentifier write setIdentifier;

    ///  <summary>
    ///    Get or Set the constraint applied by this filter.
    ///  </summary>
    property Constraint: TConstraint read getConstraint write setConstraint;

    ///  <summary>
    ///    Get or Set the value of this filter as a string.
    ///  </summary>
    property AsString: string read getValueAsString write setValueAsString;

    ///  <summary>
    ///    Get or Set the value of this filter as an integer (int32).
    ///  </summary>
    property AsInteger: int32 read getValueAsInteger write setValueAsInteger;

    ///  <summary>
    ///    Get or Set the value of this filter as a float (double).
    ///  </summary>
    property AsFloat: double read getValueAsFloat write setValueAsFloat;

    ///  <summary>
    ///    Get or Set the value of this filter as a boolean.
    ///  </summary>
    property AsBoolean: boolean read getValueAsBoolean write setValueAsBoolean;

    ///  <summary>
    ///    Get or Set the value of this filter as a TDateTime.
    ///  </summary>
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

  ///  <summary>
  ///    Represents an array of objects (IRESTObject).
  ///  </summary>
  IRESTArray = interface
    ['{AB9B8FEF-6C6E-468C-A4DC-E9303309450F}']

    ///  <summary>
    ///    Returns the number of objects in this collection.
    ///  </summary>
    function getCount: uint32;

    ///  <summary>
    ///    Gets an object from the collection as specified by index.
    ///  </summary>
    function getItem( idx: uint32 ): IRESTObject;

    ///  <summary>
    ///    Adds an object to this collection and returns a reference to it.
    ///  </summary>
    function addItem: IRESTObject;

    ///  <summary>
    ///    Removes an object from this collection as specified by index.
    ///  </summary>
    procedure RemoveItem( idx: uint32 ); overload;

    ///  <summary>
    ///    Removes an object from this collection as specified by reference.
    ///  </summary>
    procedure RemoveItem( aRestObject: IRESTObject ); overload;

    ///  <summary>
    ///    Deserializes this collection from a JSON string.
    ///  </summary>
    function Deserialize( JSONString: string ): boolean;

    ///  <summary>
    ///    Serializes this collection to a JSON string.
    ///  </summary>
    function Serialize( var JSONString: string ): boolean;

    //- Pascal Onky, properties -//

    ///  <summary>
    ///    Returns the number of objects in this collection.
    ///  </summary>
    property Count: uint32 read getCount;

    ///  <summary>
    ///    Array style access to the objects in this collection.
    ///  </summary>
    property Items[ idx: uint32 ]: IRESTObject read getItem;
  end;

  ///  <summary>
  ///    Contains the response to be returned from a REST API call.
  ///    When the response code is 200-299 the response collection is returned
  ///    in the body of the response. When any other response code is used, the
  ///    ResponseMessage will be returned.
  ///  </summary>
  IRESTResponse = interface
    ['{A437EAA6-C487-4BE7-8C62-1477731F7BCD}']

    ///  <summary>
    ///    Returns true if the request is completed, and ready to be sent
    ///    back to the client. Else returns false.
    ///  </summary>
    function getComplete: boolean;

    ///  <summary>
    ///    Sets the completion status of the REST response. When set TRUE the
    ///    response is ready to be sent back to the client.
    ///  </summary>
    procedure setComplete( value: boolean );

    ///  <summary>
    ///    An array of REST objects to be returned as JSON within the
    ///    body of the HTTP response.
    ///  </summary>
    function getResponseArray: IRESTArray;

    ///  <summary>
    ///    Returns the response code which will be sent from this REST response
    ///    in the HTTP response.
    ///  </summary>
    function getResponseCode: THTTPResponseCode;

    ///  <summary>
    ///    Sets the response code which will be sent from this REST response in
    ///    the HTTP response.
    ///  </summary>
    procedure setResponseCode( Code: THTTPResponseCode );

    ///  <summary>
    ///    Gets the response message which will be returned from this REST
    ///    response in the body of the HTTP response, when an error return
    ///    code is set.
    ///  </summary>
    function getResponseMessage: string;

    ///  <summary>
    ///    Sets the response message which will be returned from this REST
    ///    response in the body of the HTTP response, when an error return
    ///    code is set.
    ///  </summary>
    procedure setResponseMessage( value: string );

    //- Pascal Only, properties -//

    ///  <summary>
    ///    Get/Set the response code for the HTTP response. When this is set
    ///    between 200-299, the ResponseCollection property is returned as the
    ///    body of the HTTP response. Any other response value causes the
    ///    ResponseMessage to be sent in the body of the HTTP response.
    ///  </summary>
    property ResponseCode: THTTPResponseCode read getResponseCode write setResponseCode;

    ///  <summary>
    ///    Get or Set the response message to be sent in the body of the HTTP
    ///    response when the response code is not between 200-299.
    ///  </summary>
    property ResponseMessage: string read getResponseMessage write setResponseMessage;

    ///  <summary>
    ///    Get the response array which will be sent in the body of the
    ///    HTTP response as JSON text when the response code is between 200-299.
    ///  </summary>
    property ResponseArray: IRESTArray read getResponseArray;

    ///
    ///  <summary>
    ///    Get/Set completion status of request.
    ///    Complete may be set to true during an OnBeforeREST event handler,
    ///    to prevent the request from being processed further. The OnAfterREST
    ///    event handler for the request will still be called.
    ///  </summary>
    property Complete: boolean read getComplete write setComplete;
  end;

  ///  <summary>
  ///    Represents a rest collection which is exposed through the TRESTAPI
  ///  </summary>
  TRESTCollection = class(TCollectionItem)
  private
    fConnection: TFDConnection;
    fTableName: string;
    fKeyField: string;
    fEndpoint: string;
    fOnBeforeRESTDelete: TRESTDeleteEvent;
    fOnBeforeRESTUpdate: TRESTUpdateEvent;
    fOnBeforeRESTRead: TRESTReadEvent;
    fOnAfterRESTDelete: TRESTDeleteEvent;
    fOnAfterRESTUpdate: TRESTUpdateEvent;
    fOnAfterRESTRead: TRESTReadEvent;
    fOnBeforeRESTCreate: TRESTCreateEvent;
    fOnAfterRESTCreate: TRESTCreateEvent;
    function GetDisplayName: string; override;
    procedure setConnection(const Value: TFDConnection);
    procedure setEndpoint(const Value: string);
    procedure setKeyField(const Value: string);
    procedure setTableName(const Value: string);
    procedure ProcessCreate( Request: IRESTArray; Response: IRESTResponse );
    procedure ProcessRead( Filters: IRESTFilterGroup; Response: IRESTResponse );
    procedure ProcessUpdate( Request: IRESTArray; Filters: IRESTFilterGroup; Response: IRESTResponse );
    procedure ProcessDelete( Filters: IRESTFilterGroup; Response: IRESTResponse );
    function ParseFilters(FilterURL: string): IRESTFilterGroup;
    procedure SendResponse(Response: TWebResponse; RESTResponse: IRESTResponse);
    function VerifyDatabase(Response: IRESTResponse): boolean;
    function VerifyTable(Response: IRESTResponse): boolean;
    function ApplyWhereClause(qry: TFDQuery; Filters: IRESTFilterGroup; Response: IRESTResponse): boolean;
    function ExecuteQuery(qry: TFDQuery; Response: IRESTResponse): boolean;
    function ExecuteSQL(qry: TFDQuery): boolean;
    function DBObjectToResponse(qry: TFDQuery; Response: IRESTResponse): boolean;
    function ModifyDBObject(qry: TFDQuery; Request: IRESTArray): boolean;
  protected
    procedure ProcessRequest( PathInfo: TPathInfo; Request: TWebRequest; Response: TWebResponse );
  public
    procedure Assign(Source: TPersistent); override;
  published
    property Connection: TFDConnection read fConnection write setConnection;
    property TableName: string read fTableName write setTableName;
    property KeyField: string read fKeyField write setKeyField;
    property Endpoint: string read fEndpoint write setEndpoint;
    ///  <summary>
    ///    Event called before a create operation is performed in order to
    ///    create objects in a REST collection.
    ///  </summary>
    property OnBeforeRESTCreate: TRESTCreateEvent read fOnBeforeRESTCreate write fOnBeforeRESTCreate;
    ///  <summary>
    ///    Event called after a create operation is performed in order to create objects
    ///    in a REST collection.
    ///  </summary>
    property OnAfterRESTCreate: TRESTCreateEvent read fOnAfterRESTCreate write fOnAfterRESTCreate;
    ///  <summary>
    ///    Event called before a read operation to read objects from a REST collection.
    ///  </summary>
    property OnBeforeRESTRead: TRESTReadEvent read fOnBeforeRESTRead write fOnBeforeRESTRead;
    ///  <summary>
    ///    Event called after a read operation to read objects from a REST collection.
    ///  </summary>
    property OnAfterRESTRead: TRESTReadEvent read fOnAfterRESTRead write fOnAfterRESTRead;
    ///  <summary>
    ///    Event called before an update operation is performed to update objects in a REST collection.
    ///  </summary>
    property OnBeforeRESTUpdate: TRESTUpdateEvent read fOnBeforeRESTUpdate write fOnBeforeRESTUpdate;
    ///  <summary>
    ///    Event called after an update operation is performed to update objects in a REST collection.
    ///  </summary>
    property OnAfterRESTUpdate: TRESTUpdateEvent read fOnAfterRESTUpdate write fOnAfterRESTUpdate;
    ///  <summary>
    ///    Event called before a delete operation is performed to delete objects from a REST collection.
    ///  </summary>
    property OnBeforeRESTDelete: TRESTDeleteEvent read fOnBeforeRESTDelete write fOnBeforeRESTDelete;
    ///  <summary>
    ///    Event called after a delete operation is performed to delete objects from a REST collection.
    ///  </summary>
    property OnAfterRESTDelete: TRESTDeleteEvent read fOnAfterRESTDelete write fOnAfterRESTDelete;
  end;

  ///  <summary>
  ///    A collection of TRESTCollection objects (to provide a collection
  ///    property for TRESTAPI.
  ///  </summary>
  TRESTCollections = class( TOwnedCollection )
  public
    constructor Create( aOwner: TComponent );
  private
    function GetItem(idx: integer): TRESTCollection;
    procedure setItem(idx: integer; const Value: TRESTCollection);
  public
    property Items[idx: integer]: TRESTCollection read GetItem write setItem; default;
  end;

  ///  <summary>
  ///    Represents a REST API (collection of endpoints) as a component to be
  ///    inserted into a web module.
  ///  </summary>
  TRESTAPI = class(TComponent)
  private
    fCollections: TRESTCollections;
  private
    procedure WebActionHandler(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    function getCollections: TRESTCollections;
    procedure setCollections(const Value: TRESTCollections);
  protected
//    procedure Notification(AnObject: TComponent; Operation: TOperation); override;
  public
    ///  <exclude/>
    constructor Create( aOwner: TComponent ); override;
  published
    ///  <summary>
    ///    Provides access to the REST collections which are exposed through
    ///    this API.
    ///  </summary>
    property Collections: TRESTCollections read getCollections write setCollections;
  end;

procedure Register;

implementation
uses
  sysutils,
  deREST.restarray.standard,
  deREST.filterparser,
  deREST.restfilter.standard,
  deREST.restresponse.standard;

procedure Register;
begin
  RegisterComponents('deREST', [TRESTAPI]);
end;



constructor TRESTAPI.Create(aOwner: TComponent);
var
  Action: TWebActionItem;
begin
  inherited Create(aOwner);
  // Ensure the rest manager component is installed on a web module,
  // we need access to the actions list.
  if not (aOwner is TWebModule) then begin
    raise
      Exception.Create('TRESTManager component must be placed on a TWebModule.');
  end;
  //- Create collections
  fCollections := TRESTCollections.Create(Self);
  //- Clear out web actions and add our own default.
  (aOwner as TWebModule).Actions.Clear;
  Action := (aOwner as TWebModule).Actions.Add;
  Action.OnAction := WebActionHandler;
  Action.Default := True;
end;

//procedure TRESTAPI.Notification(AnObject: TComponent; Operation: TOperation);
//var
//  idx: uint32;
//begin
//  if (Operation<>TOperation.opRemove) then begin
//    exit;
//  end;
//  if AnObject=nil then begin
//    exit;
//  end;
//  if fCollections.Count=0 then begin
//    exit;
//  end;
//  for idx := 0 to pred(fCollections.Count) do begin
//    if TRESTCollection(fCollections.Items[idx]).Connection = anObject then begin
//      TRESTCollection(fCollections.Items[idx]).Connection := nil;
//      exit;
//    end;
//  end;
//end;

function TRESTAPI.getCollections: TRESTCollections;
begin
  Result := fCollections;
end;

procedure TRESTAPI.setCollections(const Value: TRESTCollections);
begin
  fCollections.Assign(Value);
end;

procedure TRESTAPI.WebActionHandler(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
  utPath: string;
  idx: uint32;
  PathInfo: TPathInfo;
  Collection: TRESTCollection;
begin
  Handled := True;
  if fCollections.Count>0 then begin
    //- Find the REST collection to handle the request.
    PathInfo := PathInfo.ParsePathInfo(Request.PathInfo);
    utPath := Uppercase(Trim(PathInfo.Endpoint));
    for idx := 0 to pred(fCollections.Count) do begin
      Collection := TRESTCollection(fCollections.Items[idx]);
      if Uppercase(Trim(Collection.Endpoint))=utPath then begin
        TRESTCollection(fCollections.Items[idx]).ProcessRequest(PathInfo,Request,Response);
        exit;
      end;
    end;
  end;
  //- If we get here, something went wrong, let the end user know.
  Response.Content := 'Endpoint not found.';
  Response.StatusCode := 500;
  Response.SendResponse;
end;

{ TRESTCollection }

function TRESTCollection.ParseFilters( FilterURL: string ): IRESTFilterGroup;
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

function TRESTCollection.VerifyDatabase( Response: IRESTResponse ): boolean;
begin
  Result := False;
  //- Do we have a database assigned?
  if not assigned(fConnection) then begin
    Response.ResponseCode := THTTPResponseCode.rc500_InternalServerError;
    Response.ResponseMessage := 'Connection to database failed.';
    Response.Complete := True;
    exit;
  end;
  //- Can we connect to the database?
  fConnection.Connected := True;
  if not fConnection.Connected then begin
    Response.ResponseCode := THTTPResponseCode.rc500_InternalServerError;
    Response.ResponseMessage := 'Connection to database failed.';
    Response.Complete := True;
    exit;
  end;
  //- We made it, we're good.
  Result := True;
end;

function TRESTCollection.VerifyTable( Response: IRESTResponse ): boolean;
begin
  Result := False;
  //- Do we have a table name.
  if Trim(fTableName)='' then begin
    Response.ResponseCode := THTTPResponseCode.rc500_InternalServerError;
    Response.ResponseMessage := 'Database table not set.';
    Response.Complete := True;
    exit;
  end;
  //- We're done
  Result := True;
end;

function TRESTCollection.ApplyWhereClause( qry: TFDQuery; Filters: IRESTFilterGroup; Response: IRESTResponse ): boolean;
var
  Filter: IRESTFilterItem;
  ParamCounter: uint32;
  idx: uint32;
begin
  Result := False;
  //- Build the where clause and apply the parameters.
  if Filters.Count=0 then begin
    qry.SQL.Text := qry.SQL.Text + ';';
    Result := True;
    exit;
  end;
  //- Add where clause and assign parameters.
  ParamCounter := 0;
  Filters.AssignParameterNames(ParamCounter);
  qry.SQL.Text := qry.SQL.Text + ' where '+Filters.ToWhereClause+';';
  if qry.ParamCount>0 then begin
    for idx := 0 to pred(qry.Params.Count) do begin
      Filter := Filters.ParamValue(qry.Params[idx].Name);
      if (not assigned(Filter)) or (not Filter.IsFilter) then begin
        Response.ResponseCode := THTTPResponseCode.rc500_InternalServerError;
        Response.ResponseMessage := 'Invalid filters (parameter name not found).';
        Response.Complete := True;
        exit;
      end;
      qry.Params[idx].AsString := Filter.AsFilter.AsString;
    end;
  end;
  //- We made it.
  Result := True;
end;

function TRESTCollection.ExecuteQuery( qry: TFDQuery; Response: IRESTResponse ): boolean;
begin
  Result := False;
  try
    qry.Active := True;
  except
    on E: Exception do begin
      Response.ResponseCode := THTTPResponseCode.rc500_InternalServerError;
      Response.ResponseMessage := E.Message;
      Response.Complete := True;
      exit;
    end;
  end;
  //- Check that the query went active.
  if not qry.Active then begin
    Response.ResponseCode := THTTPResponseCode.rc500_InternalServerError;
    Response.ResponseMessage := 'Invalid filters.';
    Response.Complete := True;
    exit;
  end;
  //- We made it.
  Result := True;
end;

function TRESTCollection.ExecuteSQL( qry: TFDQuery ): boolean;
begin
  Result := False;
  try
    qry.ExecSQL;
  except
    on E: Exception do begin
      exit;
    end;
  end;
  //- We made it.
  Result := True;
end;

function TRESTCollection.GetDisplayName: string;
begin
  Result := fEndpoint;
end;

procedure TRESTCollection.Assign(Source: TPersistent);
var
  src: TRESTCollection;
begin
  Src := TRESTCollection(Source);
  Endpoint := src.Endpoint;
  TableName := src.TableName;
  KeyField := src.KeyField;
  Connection := src.Connection;
  OnBeforeRESTCreate := src.OnBeforeRESTCreate;
  OnAfterRESTCreate := src.OnAfterRESTCreate;
  OnBeforeRESTRead := src.OnBeforeRESTRead;
  OnAfterRESTRead := src.OnAfterRESTRead;
  OnBeforeRESTUpdate := src.OnBeforeRESTUpdate;
  OnAfterRESTUpdate := src.OnAfterRESTUpdate;
  OnBeforeRESTDelete := src.OnBeforeRESTDelete;
  OnAfterRESTDelete := src.OnAfterRESTDelete;
end;

function TRESTCollection.DBObjectToResponse( qry: TFDQuery; Response: IRESTResponse ): boolean;
var
  idx: uint32;
  AnObject: IRESTObject;
begin
  Result := False;
  if qry.Fields.Count=0 then begin
    exit;
  end;
  AnObject := Response.ResponseArray.addItem;
  for idx := 0 to pred(qry.Fields.Count) do begin
    AnObject.AddValue(qry.Fields[idx].FieldName,qry.Fields[idx].AsString);
  end;
  Result := True;
end;

procedure TRESTCollection.ProcessRead( Filters: IRESTFilterGroup; Response: IRESTResponse );
var
  qry: TFDQuery;
begin
  //- Do we have a valid database connection?
  if not VerifyDatabase( Response ) then begin
    exit;
  end;

  //- Do we have a valid table name?
  if not VerifyTable( Response ) then begin
    exit;
  end;

  //- Create a query.
  qry := TFDQuery.Create(nil);
  try
    qry.Connection := fConnection;

    //- Set SQL.
    qry.SQL.Text := 'select * from '+fTableName;
    if not ApplyWhereClause( qry, Filters, Response ) then begin
      exit;
    end;

    //- Execute the query.
    if not ExecuteQuery(qry,Response) then begin
      exit;
    end;

    //- Now begin returning the rows of data.
    if qry.RowsAffected>0 then begin
      qry.First;
      while not qry.EOF do begin
        if not DBObjectToResponse( qry, Response ) then begin
          Response.ResponseCode := THTTPResponseCode.rc400_BadRequest;
          Response.ResponseMessage := 'Unable to serialize object.';
          exit;
        end;
        qry.Next;
      end;
    end;
  finally
    qry.DisposeOf;
  end;
  Response.ResponseCode := THTTPResponseCode.rc200_OK;
  Response.Complete := True;
end;

procedure TRESTCollection.ProcessRequest(PathInfo: TPathInfo; Request: TWebRequest; Response: TWebResponse);
var
  Method: TMethodType;
  Filters: IRESTFilterGroup;
  RESTResponse: IRESTResponse;
  RESTRequest: IRESTArray;
begin
  //- Create request to retrieve request body.
  RESTRequest := TRESTArray.Create;

  //- Create a response to handle the results.
  RESTResponse := TRESTResponse.Create;

  //- Determine the HTTP method.
  Method := Request.MethodType;
  case Method of
    mtAny,
    mtHead,
    mtPatch: begin
      exit;
    end;
  end;

  //- Deserialize request.
  case Method of
    mtPut,
    mtPost: RESTRequest.Deserialize(Request.Content);
  end;

  //- Parse filters.
  case Method of
    mtGet,
    mtPut,
    mtDelete: begin
      Filters := ParseFilters( Request.Query );
      if not assigned(Filters) then begin
        RESTResponse.ResponseCode := THTTPResponseCode.rc500_InternalServerError;
        RESTResponse.ResponseMessage := 'Invalid Filters';
        SendResponse( Response, RESTResponse );
        exit;
      end;
    end;
  end;

  //- Run before event.
  case Method of
    mtGet: begin
      if assigned(fOnBeforeRESTRead) then begin
        fOnBeforeRESTRead(Filters,RESTResponse);
      end;
    end;
    mtPut: begin
      if assigned(fOnBeforeRESTUpdate) then begin
        fOnBeforeRESTUpdate(RESTRequest,Filters,RESTResponse);
      end;
    end;
    mtPost: begin
      if assigned(fOnBeforeRESTCreate) then begin
        fOnBeforeRESTCreate(RESTRequest,RESTResponse);
      end;
    end;
    mtDelete: begin
      if assigned(fOnBeforeRESTDelete) then begin
        fOnBeforeRESTDelete(Filters,RESTResponse);
      end;
    end;
  end;

  //- If not processed, process the event.
  if not RESTResponse.Complete then begin
    case Method of
      mtGet: ProcessRead( Filters, RESTResponse );
      mtPut: ProcessUpdate( RESTRequest, Filters, RESTResponse );
      mtPost: ProcessCreate( RESTRequest, RESTResponse );
      mtDelete: ProcessDelete( Filters, RESTResponse );
    end;
  end;

  //- If we've not processed by this point, there's a problem, send the response
  //- and bail out.
  if not RESTResponse.Complete then begin
    RESTResponse.ResponseCode := THTTPResponseCode.rc500_InternalServerError;
    RESTResponse.ResponseMessage := 'Request not processed.';
    SendResponse( Response, RESTResponse );
    exit;
  end;

  //- If we got here, we need to execute the after event.
  case Method of
    mtGet: begin
      if assigned(fOnAfterRESTRead) then begin
        fOnAfterRESTRead(Filters,RESTResponse);
      end;
    end;
    mtPut: begin
      if assigned(fOnAfterRESTUpdate) then begin
        fOnAfterRESTUpdate(RESTRequest,Filters,RESTResponse);
      end;
    end;
    mtPost: begin
      if assigned(fOnAfterRESTCreate) then begin
        fOnAfterRESTCreate(RESTRequest,RESTResponse);
      end;
    end;
    mtDelete: begin
      if assigned(fOnAfterRESTDelete) then begin
        fOnAfterRESTDelete(Filters,RESTResponse);
      end;
    end;
  end;

  //- Send the response.
  SendResponse( Response, RESTResponse );
end;

procedure TRESTCollection.ProcessCreate( Request: IRESTArray; Response: IRESTResponse );
var
  idx,idy: uint32;
  AnObject: IRESTObject;
  qry: TFDQuery;
begin
  //- If there are no items to create, we return successful creation of zero objects..
  if Request.Count=0 then begin
    Response.ResponseCode := THTTPResponseCode.rc200_OK;
    exit;
  end;

  //- Do we have a valid database connection?
  if not VerifyDatabase( Response ) then begin
    exit;
  end;

  //- Do we have a valid table name?
  if not VerifyTable( Response ) then begin
    exit;
  end;

  //- Create a query.
  qry := TFDQuery.Create(nil);
  try
    qry.Connection := fConnection;

    //- Loop through each item in the request in order to create it.
    Response.ResponseCode := THTTPResponseCode.rc201_Created; //- Assume all objects are created, unless they arent (switch to 202_accepted)
    for idx := 0 to pred(Request.Count) do begin
      if Request.Items[idx].Count>0 then begin
        //- Start a new sql string for each object.
        qry.SQL.Text := 'insert into '+fTableName+'(';
        //- Loop through fields and add their names to the query string.
        for idy := 0 to pred(Request.Items[idx].Count) do begin
          qry.SQL.Text := qry.SQL.Text + Request.Items[idx].Name[idy];
          if idy<pred(Request.Items[idx].Count) then begin
            qry.SQL.Text := qry.SQL.Text + ', ';
          end;
        end;
        //- Values as parameters.
        qry.SQL.Text := qry.SQL.Text + ') VALUES (';
        //- Loop through the fields again and add them as parameters to the query string.
        for idy := 0 to pred(Request.Items[idx].Count) do begin
          qry.SQL.Text := qry.SQL.Text + ':' + Request.Items[idx].Name[idy];
          if idy<pred(Request.Items[idx].Count) then begin
            qry.SQL.Text := qry.SQL.Text + ', ';
          end;
        end;
        qry.SQL.Text := qry.SQL.Text + ');';
        //- Loop through one more time, and set the parameter values.
        for idy := 0 to pred(Request.Items[idx].Count) do begin
          qry.Params.ParamByName(Request.Items[idx].Name[idy]).AsString := Request.Items[idx].ValueByIndex[idy];
        end;
        //- Attempt to execute the query, if successful, add the created object.
        if ExecuteSQL(qry) then begin
          AnObject := Response.ResponseArray.addItem;
          AnObject.Assign(Request.Items[idx]);
        end else begin
          Response.ResponseCode := THTTPResponseCode.rc202_Accepted;
        end;
      end;
    end;

  finally
    qry.DisposeOf;
  end;
  Response.ResponseCode := THTTPResponseCode.rc200_OK;
  Response.Complete := True;
end;

function TRESTCollection.ModifyDBObject( qry: TFDQuery; Request: IRESTArray ): boolean;
var
  idx: uint32;
begin
  Result := False;
  //- Only one object may be used to update records.
  if Request.Count=0 then begin
    exit;
  end;
  if Request.Count>1 then begin
    exit;
  end;
  //- There must be at least one field to modify.
  if Request.Items[0].Count=0 then begin
    exit;
  end;
  //- Loop through the fields of the object and make the changes.
  qry.Edit;
  try
    for idx := 0 to pred(request.Items[0].Count) do begin
      if not assigned(qry.FieldByName(request.Items[0].Name[idx])) then begin
        exit;
      end;
      qry.FieldByName(request.Items[0].Name[idx]).AsString := request.Items[0].ValueByIndex[idx];
    end;
  finally
    qry.Post;
  end;
  Result := True;
end;

procedure TRESTCollection.ProcessUpdate( Request: IRESTArray; Filters: IRESTFilterGroup; Response: IRESTResponse );
var
  qry: TFDQuery;
begin
  //- Do we have a valid database connection?
  if not VerifyDatabase( Response ) then begin
    exit;
  end;

  //- Do we have a valid table name?
  if not VerifyTable( Response ) then begin
    exit;
  end;

  //- Create a query.
  qry := TFDQuery.Create(nil);
  try
    qry.Connection := fConnection;

    //- Set SQL.
    qry.SQL.Text := 'select * from '+fTableName;
    if not ApplyWhereClause( qry, Filters, Response ) then begin
      exit;
    end;

    //- Execute the query.
    if not ExecuteQuery(qry,Response) then begin
      exit;
    end;

    //- Now begin returning the rows of data.
    if qry.RowsAffected>0 then begin
      qry.First;
      while not qry.EOF do begin
        if not ModifyDBObject( qry, Request ) then begin
          Response.ResponseCode := THTTPResponseCode.rc400_BadRequest;
          Response.ResponseMessage := 'Unable to alter record.';
          exit;
        end;
        if not DBObjectToResponse( qry, Response ) then begin
          Response.ResponseCode := THTTPResponseCode.rc400_BadRequest;
          Response.ResponseMessage := 'Unable to serialize object.';
          exit;
        end;
        qry.Next;
      end;
    end;
  finally
    qry.DisposeOf;
  end;
  Response.ResponseCode := THTTPResponseCode.rc200_OK;
  Response.Complete := True;
end;


procedure TRESTCollection.ProcessDelete( Filters: IRESTFilterGroup; Response: IRESTResponse );
var
  qry: TFDQuery;
begin
  //- Do we have a valid database connection?
  if not VerifyDatabase( Response ) then begin
    exit;
  end;

  //- Do we have a valid table name?
  if not VerifyTable( Response ) then begin
    exit;
  end;

  //- Create a query.
  qry := TFDQuery.Create(nil);
  try
    qry.Connection := fConnection;

    //- Set SQL.
    qry.SQL.Text := 'select * from '+fTableName;
    if not ApplyWhereClause( qry, Filters, Response ) then begin
      exit;
    end;

    //- Execute the query.
    if not ExecuteQuery(qry,Response) then begin
      exit;
    end;

    //- Now begin returning the rows of data.
    if qry.RowsAffected>0 then begin
      qry.First;
      while not qry.EOF do begin
        if not DBObjectToResponse( qry, Response ) then begin
          Response.ResponseCode := THTTPResponseCode.rc400_BadRequest;
          Response.ResponseMessage := 'Unable to serialize object.';
          exit;
        end;
        qry.Next;
      end;
    end;

    //- Now we can delete the objects.
    qry.SQL.Text := 'delete from '+fTableName;
    if not ApplyWhereClause(qry, Filters, Response) then begin
      exit;
    end;
    //- Execute the query.
    if not ExecuteSQL(qry) then begin
      exit;
    end;

  finally
    qry.DisposeOf;
  end;
  Response.ResponseCode := THTTPResponseCode.rc200_OK;
  Response.Complete := True;
end;

procedure TRESTCollection.SendResponse( Response: TWebResponse; RESTResponse: IRESTResponse );
var
  Str: string;
begin
  Str := '';
  Response.StatusCode := int32(RESTResponse.ResponseCode);
  if (Response.StatusCode>199) and (Response.StatusCode<300) then begin
    if RESTResponse.ResponseArray.Serialize(Str) then begin
      Response.ContentType := 'application\json';
      Response.Content := Str;
    end else begin
      Response.StatusCode := 500;
      Response.ContentType := 'text\plain';
      Response.Content := 'Failed to serialize response JSON.';
    end;
  end else begin
    Response.ContentType := 'text\plain';
    Response.Content := RESTResponse.ResponseMessage;
  end;
  Response.SendResponse;
end;

procedure TRESTCollection.setConnection(const Value: TFDConnection);
begin
  fConnection := Value;
end;

procedure TRESTCollection.setEndpoint(const Value: string);
begin
  fEndpoint := Value;
end;

procedure TRESTCollection.setKeyField(const Value: string);
begin
  fKeyField := Value;
end;

procedure TRESTCollection.setTableName(const Value: string);
begin
  fTableName := Value;
end;

{ TRESTCollections }

constructor TRESTCollections.Create(aOwner: TComponent);
begin
  inherited Create(aOwner,TRESTCollection);
end;

function TRESTCollections.GetItem(idx: integer): TRESTCollection;
begin
  Result := TRESTCollection(inherited GetItem(idx));
end;

procedure TRESTCollections.setItem(idx: integer; const Value: TRESTCollection);
begin
  inherited SetItem(idx,value);
end;

end.
