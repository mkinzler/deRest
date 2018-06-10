unit deREST.restapi;

interface
uses
  System.SysUtils,
  System.Classes,
  Web.HTTPApp,
  deREST.endpoints;

type
  ///  <summary>
  ///    Represents a REST API (collection of endpoitns).
  ///  </summary>
  TRESTAPI = class(TComponent)
  private
    fActionsRef: TWebActionItems;
    fDefaultAction: TWebActionItem;
    fEndpoints: TEndpoints;
    procedure HandleDefaultAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    function getName: string;
    procedure setName(const Value: string); reintroduce;
  protected
    procedure SetEndpoints(Value: TEndpoints);
    procedure RemoveAction;
    procedure AddAction;
  public
    constructor Create( aOwner: TComponent ); override;
    destructor Destroy; override;
  published
    property Endpoints: TEndpoints read fEndpoints write setEndpoints;
    property Name: string read getName write setName;
  end;

implementation

procedure TRESTAPI.HandleDefaultAction(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
  //-
  Sleep(1);
end;

procedure TRESTAPI.AddAction;
begin
  fDefaultAction := fActionsRef.Add;
  fDefaultAction.PathInfo := '/'+Self.Name;
  fDefaultAction.Default := True;
  fDefaultAction.OnAction := HandleDefaultAction;
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
  // Take a reference to the actions list.
  fActionsRef := TWebModule(Owner).Actions;
   // set the default path value
  fDefaultAction := nil;
  AddAction;
  // Create endpoints
  fEndpoints := TEndpoints.Create(Self);
end;

destructor TRESTAPI.Destroy;
begin
  RemoveAction;
  fActionsRef := nil;
  fEndpoints.DisposeOf;
  fEndpoints := nil;
  inherited Destroy;
end;

function TRESTAPI.getName: string;
begin
  Result := inherited name;
end;

procedure TRESTAPI.RemoveAction;
begin
  if assigned(fDefaultAction) then begin
    fDefaultAction.DisposeOf;
    fDefaultAction := nil;
  end;
end;


procedure TRESTAPI.SetEndpoints(Value: TEndpoints);
begin
  fEndpoints.Assign(Value);
end;

procedure TRESTAPI.setName(const Value: string);
begin
  inherited name := value;
  RemoveAction;
  AddAction;
end;

end.
