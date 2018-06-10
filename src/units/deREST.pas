unit deREST;

interface
uses
  classes,
  deREST.restapi;

type
  TRestAPI = deREST.restapi.TRESTAPI;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('deREST', [TRESTAPI]);
end;



end.
