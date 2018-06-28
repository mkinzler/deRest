unit deREST.restfilter;

interface

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

implementation

end.
