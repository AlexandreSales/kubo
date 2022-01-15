unit kubo.rest.client.params;

interface

uses
  system.sysutils,
  system.generics.collections,
  kubo.rest.client.interfaces,
  kubo.rest.client.types;

type

  tkuboParam = class(tinterfacedobject, ikuboParam)
  private
    {private declarations}
    fname: string;
    fresource: string;
    fvalue: variant;
    fkind: tkuboParamKind;

    function getname: string;
    procedure setname(const Value: string);
    function getvalue: variant;
    procedure setvalue(const Value: variant);
    function getkind: tkuboParamKind;
    procedure setkind(const Value: tkuboParamKind);
    function getresource: string;
    procedure setresource(const Value: string);
  public
    {public delcarations}
    constructor create(const pname, presource: string; const pvalue: variant; const pkind: tkuboParamKind);
    destructor destroy; override;

    class function new(const pname, presource: string; const pvalue: variant; const pkind: tkuboParamKind): ikuboParam;

    property name: string read getname write setname;
    property resource: string read getresource write setresource;
    property value: variant read getvalue write setvalue;
    property kind: tkuboParamKind read getkind write setkind;
  end;


  tkuboParams<t: class> = class(tinterfacedobject, ikuboParams<t>)
  private
    {private declarations}
    [weak]
    fparent: ikubo<t>;
    flist: TList<ikuboParam>;
  public
    {public declarations}
    constructor create(pparent: ikubo<t>);
    destructor destroy; override;

    class function new(pparent: ikubo<t>): ikuboParams<t>;

    function add(const pname, presource: string; const pvalue: variant; const pkind: tkuboParamKind): ikuboParams<t>;
    function items(const pindex: integer): ikuboParam;
    function count: integer;

    function &end: ikubo<t>;
  end;

implementation

{ tkuboParams<t> }

function tkuboParams<t>.add(const pname, presource: string; const pvalue: variant; const pkind: tkuboParamKind): ikuboParams<t>;
begin
  result := self;
  flist.add(
            tkuboParam.new(
                                        pname,
                                        presource,
                                        pvalue,
                                        pkind
                                        )
           );
end;

function tkuboParams<t>.count: integer;
begin
  result := flist.count;
end;

constructor tkuboParams<t>.create(pparent: ikubo<t>);
begin
  fparent := pparent;
  flist := tlist<ikuboParam>.create;
end;

destructor tkuboParams<t>.destroy;
begin
  if flist <> nil then
    freeandnil(flist);

  inherited;
end;

function tkuboParams<t>.&end: ikubo<t>;
begin
  result := fparent;
end;

function tkuboParams<t>.items(const pindex: integer): ikuboParam;
begin
  if (pindex >= 0) and (pindex < flist.count) then
    result := flist[pindex];
end;

class function tkuboParams<t>.new(pparent: ikubo<t>): ikuboParams<t>;
begin
  result := self.create(pparent);
end;

{ tkuboParam }

constructor tkuboParam.create(const pname, presource: string; const pvalue: variant; const pkind: tkuboParamKind);
begin
  fname := pname;
  fresource := presource;
  fvalue :=  pvalue;
  fkind := pkind;
end;

destructor tkuboParam.destroy;
begin
  fname := '';
  fresource := '';
  fvalue :=  '';

  inherited;
end;

function tkuboParam.getkind: tkuboParamKind;
begin
  result := fkind;
end;

function tkuboParam.getname: string;
begin
  result := fname;
end;

function tkuboParam.getresource: string;
begin
  result := fresource;
end;

function tkuboParam.getvalue: variant;
begin
  result := fvalue;
end;

class function tkuboParam.new(const pname, presource: string; const pvalue: variant; const pkind: tkuboParamKind): ikuboParam;
begin
  result := self.create(pname, presource, pvalue, pkind);
end;

procedure tkuboParam.setkind(const Value: tkuboParamKind);
begin
  fkind := value;
end;

procedure tkuboParam.setname(const Value: string);
begin
  fname := value;
end;

procedure tkuboParam.setresource(const Value: string);
begin
  fresource := value;
end;

procedure tkuboParam.setvalue(const Value: variant);
begin
  fvalue := value;
end;

end.
