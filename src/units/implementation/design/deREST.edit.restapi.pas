unit deREST.edit.restapi;

interface
uses
  DesignIntf,
  DesignEditors,
  Classes;

type
  TRESTAPIEditor=class(TComponentEditor)
    function GetVerbCount: Integer; override;
    function GetVerb(Index: Integer): string; override;
    procedure ExecuteVerb(Index: Integer); override;
  end;

  procedure Register;

implementation
uses
  vcl.Dialogs,
  sysutils,
  deREST.restapi;

// Called when component of this type is right-clicked. It's where
// you actually perform the action. The component editor is passed a reference
// to the component as "Component", which you need to cast to your specific
// component type
procedure TRESTAPIEditor.ExecuteVerb(Index: Integer);
begin
  inherited;
  case Index of
    0: begin
      (Component as TRESTAPI).AddDatasetFields;
      Designer.Modified;
    end;
  end;
end;

// Called the number of times you've stated you need in GetVerbCount.
// This is where you add your pop-up menu items
function TRESTAPIEditor.GetVerb(Index: Integer): string;
begin
  case Index of
    0: Result := '&Add All Fields';
  end;
end;

// Called when the IDE needs to populate the menu. Return the number
// of items you intend to add to the menu.
function TRESTAPIEditor.GetVerbCount: Integer;
begin
  Result := 1;
end;

procedure Register;
begin
  RegisterComponentEditor(TRESTAPI, TRESTAPIEditor);
end;

end.
