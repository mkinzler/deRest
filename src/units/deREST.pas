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
                 rcOkay = 200,
       rcPartialContent = 206,
                rcError = 500
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
  ///    Represents a REST API (collection of endpoints) as a component to be
  ///    inserted into a web module.
  ///  </summary>
  TRESTCollection = class(TCustomContentProducer)
  private
    fConnection: TFDConnection;
    fTableName: string;
    fOnBeforeRESTDelete: TRESTDeleteEvent;
    fOnBeforeRESTUpdate: TRESTUpdateEvent;
    fOnBeforeRESTRead: TRESTReadEvent;
    fOnAfterRESTDelete: TRESTDeleteEvent;
    fOnAfterRESTUpdate: TRESTUpdateEvent;
    fOnAfterRESTRead: TRESTReadEvent;
    fOnBeforeRESTCreate: TRESTCreateEvent;
    fOnAfterRESTCreate: TRESTCreateEvent;
  private
    procedure ProcessCreate( Request: IRESTArray; Response: IRESTResponse );
    procedure ProcessRead( Filters: IRESTFilterGroup; Response: IRESTResponse );
    procedure ProcessUpdate( Request: IRESTArray; Filters: IRESTFilterGroup; Response: IRESTResponse );
    procedure ProcessDelete( Filters: IRESTFilterGroup; Response: IRESTResponse );
    function ParseFilters(FilterURL: string): IRESTFilterGroup;
    procedure SendResponse(Dispatcher: IWebDispatcherAccess; Response: IRESTResponse);
    function VerifyDatabase(Response: IRESTResponse): boolean;
    function VerifyTable(Response: IRESTResponse): boolean;
    function ApplyWhereClause(qry: TFDQuery; Filters: IRESTFilterGroup; Response: IRESTResponse): boolean;
    function ExecuteQuery(qry: TFDQuery; Response: IRESTResponse): boolean;
    function ExecuteSQL(qry: TFDQuery): boolean;
  protected
    procedure Notification(AnObject: TComponent; Operation: TOperation); override;
  public
    ///  <summary>
    ///    Called by the TWebModule/TWebAction with a HTTP request in order to
    ///    obtain the HTTP response. You should not need to call this directly.
    ///  </summary>
    function Content: string; override;

    ///  <exclude/>
    constructor Create( aOwner: TComponent ); override;

    ///  <exclude/>
    destructor Destroy; override;
  published
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
    ///  <summary>
    ///    The FireDAC connection which provides access to the table which backs this REST collection.
    ///  </summary>
    property Connection: TFDConnection read fConnection write fConnection;
    ///  <summary>
    ///    Get or Set the name of the database table which backs this REST collection.
    ///  </summary>
    property TableName: string read fTableName write fTableName;
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
  RegisterComponents('deREST', [TRESTCollection]);
end;

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
    Response.ResponseCode := THTTPResponseCode.rcError;
    Response.ResponseMessage := 'Connection to database failed.';
    Response.Complete := True;
    exit;
  end;
  //- Can we connect to the database?
  fConnection.Connected := True;
  if not fConnection.Connected then begin
    Response.ResponseCode := THTTPResponseCode.rcError;
    Response.ResponseMessage := 'Connection to database failed.';
    Response.Complete := True;
    exit;
  end;
  //- We made it, we're good.
  Result := True;
end;

function TRESTcollection.VerifyTable( Response: IRESTResponse ): boolean;
begin
  Result := False;
  //- Do we have a table name.
  if Trim(fTableName)='' then begin
    Response.ResponseCode := THTTPResponseCode.rcError;
    Response.ResponseMessage := 'Database table not set.';
    Response.Complete := True;
    exit;
  end;
  //- We're done
  Result := True;
end;

function TRestCollection.ApplyWhereClause( qry: TFDQuery; Filters: IRESTFilterGroup; Response: IRESTResponse ): boolean;
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
        Response.ResponseCode := THTTPResponseCode.rcError;
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
      Response.ResponseCode := THTTPResponseCode.rcError;
      Response.ResponseMessage := E.Message;
      Response.Complete := True;
      exit;
    end;
  end;
  //- Check that the query went active.
  if not qry.Active then begin
    Response.ResponseCode := THTTPResponseCode.rcError;
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

procedure TRESTCollection.ProcessRead( Filters: IRESTFilterGroup; Response: IRESTResponse );
var
  idx: uint32;
  AnObject: IRESTObject;
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
        AnObject := Response.ResponseArray.addItem;
        if qry.Fields.Count>0 then begin
          for idx := 0 to pred(qry.Fields.Count) do begin
            AnObject.AddValue(qry.Fields[idx].FieldName,qry.Fields[idx].AsString);
          end;
        end;
        qry.Next;
      end;
    end;

  finally
    qry.DisposeOf;
  end;
  Response.ResponseCode := THTTPResponseCode.rcOkay;
  Response.Complete := True;
end;

procedure TRESTCollection.ProcessCreate( Request: IRESTArray; Response: IRESTResponse );
var
  idx,idy: uint32;
  AnObject: IRESTObject;
  qry: TFDQuery;
begin
  //- If there are no items to create, we return successful creation of zero objects..
  if Request.Count=0 then begin
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
          Response.ResponseCode := THTTPResponseCode.rcPartialContent;
        end;
      end;
    end;

  finally
    qry.DisposeOf;
  end;
  Response.ResponseCode := THTTPResponseCode.rcOkay;
  Response.Complete := True;
end;

procedure TRESTCollection.ProcessUpdate( Request: IRESTArray; Filters: IRESTFilterGroup; Response: IRESTResponse );
begin

end;

procedure TRESTCollection.ProcessDelete( Filters: IRESTFilterGroup; Response: IRESTResponse );
begin
end;

procedure TRESTCollection.SendResponse( Dispatcher: IWebDispatcherAccess; Response: IRESTResponse );
var
  Str: string;
begin
  Str := '';
  Dispatcher.Response.StatusCode := int32(Response.ResponseCode);
  if (Dispatcher.Response.StatusCode>199) and (Dispatcher.Response.StatusCode<300) then begin
    if Response.ResponseArray.Serialize(Str) then begin
      Dispatcher.Response.ContentType := 'application\json';
      Dispatcher.Response.Content := Str;
    end else begin
      Dispatcher.Response.StatusCode := 500;
      Dispatcher.Response.ContentType := 'text\plain';
      Dispatcher.Response.Content := 'Failed to serialize response JSON.';
    end;
  end else begin
    Dispatcher.Response.ContentType := 'text\plain';
    Dispatcher.Response.Content := Response.ResponseMessage;
  end;
  Dispatcher.Response.SendResponse;
end;

function TRESTCollection.Content: string;
var
  Method: TMethodType;
  Filters: IRESTFilterGroup;
  Response: IRESTResponse;
  Request: IRESTArray;
begin
  Result := '';

  //- Create request to retrieve request body.
  Request := TRESTArray.Create;

  //- Create a response to handle the results.
  Response := TRESTResponse.Create;

  //- Determine the HTTP method.
  Method := Dispatcher.Request.MethodType;
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
    mtPost: Request.Deserialize(Dispatcher.Request.Content);
  end;

  //- Parse filters.
  case Method of
    mtGet,
    mtPut,
    mtDelete: begin
      Filters := ParseFilters( Dispatcher.Request.Query );
      if not assigned(Filters) then begin
        Response.ResponseCode := THTTPResponseCode.rcError;
        Response.ResponseMessage := 'Invalid Filters';
        SendResponse( Dispatcher, Response );
        exit;
      end;
    end;
  end;

  //- Run before event.
  case Method of
    mtGet: begin
      if assigned(fOnBeforeRESTRead) then begin
        fOnBeforeRESTRead(Filters,Response);
      end;
    end;
    mtPut: begin
      if assigned(fOnBeforeRESTUpdate) then begin
        fOnBeforeRESTUpdate(Request,Filters,Response);
      end;
    end;
    mtPost: begin
      if assigned(fOnBeforeRESTCreate) then begin
        fOnBeforeRESTCreate(Request,Response);
      end;
    end;
    mtDelete: begin
      if assigned(fOnBeforeRESTDelete) then begin
        fOnBeforeRESTDelete(Filters,Response);
      end;
    end;
  end;

  //- If not processed, process the event.
  if not Response.Complete then begin
    case Method of
      mtGet: ProcessRead( Filters, Response );
      mtPut: ProcessUpdate( Request, Filters, Response );
      mtPost: ProcessCreate( Request, Response );
      mtDelete: ProcessDelete( Filters, Response );
    end;
  end;

  //- If we've not processed by this point, there's a problem, send the response
  //- and bail out.
  if not Response.Complete then begin
    Response.ResponseCode := THTTPResponseCode.rcError;
    Response.ResponseMessage := 'Request not processed.';
    SendResponse( Dispatcher, Response );
    exit;
  end;

  //- If we got here, we need to execute the after event.
  case Method of
    mtGet: begin
      if assigned(fOnAfterRESTRead) then begin
        fOnAfterRESTRead(Filters,Response);
      end;
    end;
    mtPut: begin
      if assigned(fOnAfterRESTUpdate) then begin
        fOnAfterRESTUpdate(Request,Filters,Response);
      end;
    end;
    mtPost: begin
      if assigned(fOnAfterRESTCreate) then begin
        fOnAfterRESTCreate(Request,Response);
      end;
    end;
    mtDelete: begin
      if assigned(fOnAfterRESTDelete) then begin
        fOnAfterRESTDelete(Filters,Response);
      end;
    end;
  end;

  //- Send the response.
  SendResponse( Dispatcher, Response );
end;

constructor TRESTCollection.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  // Ensure the rest manager component is installed on a web module,
  // we need access to the actions list.
  if not (aOwner is TWebModule) then begin
    raise
      Exception.Create('TRESTManager component must be placed on a TWebModule.');
  end;
  // Initiaize connection to dataset.
  fConnection := nil;
  fTableName := '';
end;

destructor TRESTCollection.Destroy;
begin
  fConnection := nil;
  inherited Destroy;
end;

procedure TRESTCollection.Notification(AnObject: TComponent; Operation: TOperation);
begin
  if (Operation<>TOperation.opRemove) then begin
    exit;
  end;
  if AnObject=nil then begin
    exit;
  end;
  if AnObject = fConnection then begin
    fConnection := nil;
  end;
end;

end.
