unit kubo.rest.client.arrays;

interface

uses
  system.generics.collections,
  kubo.rest.client.interfaces;

type

  tkubo_rest_client_array_<t: class> = class(tinterfacedobject, ikubo_rest_client_array_<t>)
  private
    { private declarations }
    fitems: tarray<t>;

    procedure setitems(const value: tarray<t>);
    function getitems: tarray<t>;
  public
    { public declarations }
    constructor create;
    destructor destroy; override;

    property items: tarray<t> read getitems write setitems;
  end;

implementation

{ tkubo_rest_client_array_<t> }

constructor tkubo_rest_client_array_<t>.create;
begin
  setlength(fitems, 0);
end;

destructor tkubo_rest_client_array_<t>.destroy;
begin
  if length(fitems) > 0 then
  begin
    for var lint_count_ := high(fitems) downto low(fitems) do
      delete(fitems, lint_count_, 1);

    setlength(fitems, 0);
  end;

  inherited;
end;

function tkubo_rest_client_array_<t>.getitems: tarray<t>;
begin
  result := fitems;
end;

procedure tkubo_rest_client_array_<t>.setitems(const value: tarray<t>);
begin
  fitems := value;
end;

end.
