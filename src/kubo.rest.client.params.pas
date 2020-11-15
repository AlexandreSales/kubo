unit kubo.rest.client.params;

interface

uses
  system.sysutils,
  system.generics.collections,
  kubo.rest.client.interfaces,
  kubo.rest.client.types;

type

  tkubo_rest_client_param = class(tinterfacedobject, ikubo_rest_client_param)
  private
    {private declarations}
    fname: string;
    fresource: string;
    fvalue: variant;
    fkind: tkupo_rest_client_param_kind;

    function getname: string;
    procedure setname(const Value: string);
    function getvalue: variant;
    procedure setvalue(const Value: variant);
    function getkind: tkupo_rest_client_param_kind;
    procedure setkind(const Value: tkupo_rest_client_param_kind);
    function getresource: string;
    procedure setresource(const Value: string);
  public
    {public delcarations}
    constructor create(const pname, presource: string; const pvalue: variant; const pkind: tkupo_rest_client_param_kind);
    destructor destroy; override;

    class function new(const pname, presource: string; const pvalue: variant; const pkind: tkupo_rest_client_param_kind): ikubo_rest_client_param;

    property name: string read getname write setname;
    property resource: string read getresource write setresource;
    property value: variant read getvalue write setvalue;
    property kind: tkupo_rest_client_param_kind read getkind write setkind;
  end;


  tkubo_rest_client_params<t: class> = class(tinterfacedobject, ikubo_rest_client_params<t>)
  private
    {private declarations}
    [weak]
    fparent: ikubo_rest_client<t>;
    flist: TList<ikubo_rest_client_param>;
  public
    {public declarations}
    constructor create(pparent: ikubo_rest_client<t>);
    destructor destroy; override;

    class function new(pparent: ikubo_rest_client<t>): ikubo_rest_client_params<t>;

    function add(const pname, presource: string; const pvalue: variant; const pkind: tkupo_rest_client_param_kind): ikubo_rest_client_params<t>;
    function items(const pindex: integer): ikubo_rest_client_param;
    function count: integer;

    function &end: ikubo_rest_client<t>;
  end;

implementation

{ tkubo_rest_client_params<t> }

function tkubo_rest_client_params<t>.add(const pname, presource: string; const pvalue: variant; const pkind: tkupo_rest_client_param_kind): ikubo_rest_client_params<t>;
begin
  result := self;
  flist.add(
            tkubo_rest_client_param.new(
                                        pname,
                                        presource,
                                        pvalue,
                                        pkind
                                        )
           );
end;

function tkubo_rest_client_params<t>.count: integer;
begin
  result := flist.count;
end;

constructor tkubo_rest_client_params<t>.create(pparent: ikubo_rest_client<t>);
begin
  fparent := pparent;
  flist := tlist<ikubo_rest_client_param>.create;
end;

destructor tkubo_rest_client_params<t>.destroy;
begin
  if flist <> nil then
    freeandnil(flist);

  inherited;
end;

function tkubo_rest_client_params<t>.&end: ikubo_rest_client<t>;
begin
  result := fparent;
end;

function tkubo_rest_client_params<t>.items(const pindex: integer): ikubo_rest_client_param;
begin
  if (pindex >= 0) and (pindex < flist.count) then
    result := flist[pindex];
end;

class function tkubo_rest_client_params<t>.new(pparent: ikubo_rest_client<t>): ikubo_rest_client_params<t>;
begin
  result := self.create(pparent);
end;

{ tkubo_rest_client_param }

constructor tkubo_rest_client_param.create(const pname, presource: string; const pvalue: variant; const pkind: tkupo_rest_client_param_kind);
begin
  fname := pname;
  fresource := presource;
  fvalue :=  pvalue;
  fkind := pkind;
end;

destructor tkubo_rest_client_param.destroy;
begin
  fname := '';
  fresource := '';
  fvalue :=  '';

  inherited;
end;

function tkubo_rest_client_param.getkind: tkupo_rest_client_param_kind;
begin
  result := fkind;
end;

function tkubo_rest_client_param.getname: string;
begin
  result := fname;
end;

function tkubo_rest_client_param.getresource: string;
begin
  result := fresource;
end;

function tkubo_rest_client_param.getvalue: variant;
begin
  result := fvalue;
end;

class function tkubo_rest_client_param.new(const pname, presource: string; const pvalue: variant; const pkind: tkupo_rest_client_param_kind): ikubo_rest_client_param;
begin
  result := self.create(pname, presource, pvalue, pkind);
end;

procedure tkubo_rest_client_param.setkind(const Value: tkupo_rest_client_param_kind);
begin
  fkind := value;
end;

procedure tkubo_rest_client_param.setname(const Value: string);
begin
  fname := value;
end;

procedure tkubo_rest_client_param.setresource(const Value: string);
begin
  fresource := value;
end;

procedure tkubo_rest_client_param.setvalue(const Value: variant);
begin
  fvalue := value;
end;

end.
