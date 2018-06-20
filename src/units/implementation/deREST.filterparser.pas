unit deREST.filterparser;

interface
uses
  deREST.restfilters;

type
  TRESTFilterParser = class
  private
    fFilterString: string;
    fCursor: uint32;
    fEOFPos: uint32;
  private
    function Peek: char;
    function Poke: char;
    function EOF: boolean;
  public
    class function Parse( FilterString: string; Filters: IRESTFilters ): boolean;
  end;

implementation

{ TRESTFilterParser }

function TRESTFilterParser.EOF: boolean;
begin
  Result := fCursor = fEOFPos;
end;

class function TRESTFilterParser.Parse(FilterString: string; Filters: IRESTFilters): boolean;
begin
  Result := False;
  //- Initialize string cursor and EOFPos
  fFilterString := FilterString;
  {$ifdef nextgen}
  fCursor := 0;
  fEOFPos := pred(Length(FilterString));
  {$else}
  fCursor := 1;
  fEOFPos := Length(FilterString);
  {$endif}
  // If there is nothing to parse, bail out with successful empty filters.
  if EOF then begin
    Result := True;
    exit;
  end;
  // Attempt to parse a filter.
  repeat
    ParseFilter( Filters );
  until EOF;
end;

function TRESTFilterParser.Peek: char;
begin
  Result := fFilterString[fCursor];
end;

function TRESTFilterParser.Poke: char;
begin
  Result := Peek;
  inc(fCursor);
end;

end.
