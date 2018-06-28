unit deREST.restapi;

interface
uses
  System.SysUtils,
  System.Classes,
  Web.HTTPApp,
  deREST.restfilter,
  deREST.restobject,
  deREST.datasets,
  deREST.restresponse;

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

implementation
uses
  deREST.filterparser,
  deREST.restfilter.standard,
  deREST.restresponse.standard;

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
