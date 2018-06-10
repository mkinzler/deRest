unit deREST.restapi;

interface
uses
  System.SysUtils,
  System.Classes,
  Web.HTTPApp,
  FireDAC.Comp.Dataset,
  deREST.restobject,
  deREST.restfielddefs;

type
  ///  <summary>
  ///    Callback type for events fired before and after the CRUD operations
  ///    on any rest object within the endpoint collection.
  ///  </summary>
  TRESTEvent = procedure( RESTObject: IRESTObject ) of object;

  ///  <summary>
  ///    Represents a REST API (collection of endpoitns).
  ///  </summary>
  TRESTAPI = class(TCustomContentProducer)
  private
    fFields: TRESTFieldDefs;
    fDataset: TFDDataset;
    fOnBeforeRESTDelete: TRESTEvent;
    fOnBeforeRESTUpdate: TRESTEvent;
    fOnBeforeRESTRead: TRESTEvent;
    fOnBeforeRESTCreate: TRESTEvent;
    fOnAfterRESTDelete: TRESTEvent;
    fOnAfterRESTUpdate: TRESTEvent;
    fOnAfterRESTRead: TRESTEvent;
    fOnAfterRESTCreate: TRESTEvent;
    procedure SetDataset(const Value: TFDDataset);
  protected
    procedure SetFields(Value: TRESTFieldDefs);
  protected
    function Content: string; override;
    procedure Notification(AnObject: TComponent; Operation: TOperation); override;
  public
    procedure AddDatasetFields;
  public
    constructor Create( aOwner: TComponent ); override;
    destructor Destroy; override;
  published
    property OnBeforeRESTCreate: TRESTEvent read fOnBeforeRESTCreate write fOnBeforeRESTCreate;
    property OnAfterRESTCreate: TRESTEvent read fOnAfterRESTCreate write fOnAfterRESTCreate;
    property OnBeforeRESTRead: TRESTEvent read fOnBeforeRESTRead write fOnAfterRESTRead;
    property OnAfterRESTRead: TRESTEvent read fOnAfterRESTRead write fOnAfterRESTRead;
    property OnBeforeRESTUpdate: TRESTEvent read fOnBeforeRESTUpdate write fOnBeforeRESTUpdate;
    property OnAfterRESTUpdate: TRESTEvent read fOnAfterRESTUpdate write fOnAfterRESTUpdate;
    property OnBeforeRESTDelete: TRESTEvent read fOnBeforeRESTDelete write fOnBeforeRESTDelete;
    property OnAfterRESTDelete: TRESTEvent read fOnAfterRESTDelete write fOnAfterRESTDelete;

    property Dataset: TFDDataset read fDataset write SetDataset;
    property Fields: TRESTFieldDefs read fFields write setFields;
  end;

implementation

procedure TRESTAPI.AddDatasetFields;
var
  idx: uint32;
  utFieldName: string;
begin
  if not assigned(Dataset) then begin
    exit;
  end;
  if (Dataset.FieldDefs.Count=0) and
     (Dataset.Fields.Count=0) then begin
    exit;
  end;
  for idx := 0 to pred(Dataset.FieldDefs.Count) do begin
    if not assigned( fFields.FieldByName[Trim(Dataset.FieldDefs.Items[idx].Name)] ) then begin
      fFields.Add.Field := Trim(Dataset.FieldDefs.Items[idx].Name);
    end;
  end;
  if (Dataset.Fields.Count=0) then begin
    exit;
  end;
  for idx := 0 to pred(Dataset.Fields.Count) do begin
    if not assigned( fFields.FieldByName[Trim(Dataset.Fields[idx].FieldName)]) then begin
      fFields.Add.Field := Trim(Dataset.Fields[idx].FieldName);
    end;
  end;
end;

function TRESTAPI.Content: string;
begin
  AddDatasetFields;
  Result := Dispatcher.Request.Method;
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
  fFields := TRestFieldDefs.Create(Self);
end;

destructor TRESTAPI.Destroy;
begin
  fFields := nil;
  inherited Destroy;
end;

procedure TRESTAPI.Notification(AnObject: TComponent; Operation: TOperation);
begin
  inherited;
  if (Operation = TOperation.opRemove) then begin
    if AnObject=fDataset then begin
      fDataset := nil;
    end;
  end;
end;

procedure TRESTAPI.SetDataset(const Value: TFDDataset);
begin
  fDataset := Value;
end;

procedure TRESTAPI.SetFields(Value: TRestFieldDefs);
begin
  fFields.Assign(Value);
end;

end.
