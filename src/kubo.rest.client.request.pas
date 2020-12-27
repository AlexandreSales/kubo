unit kubo.rest.client.request;

interface

uses
  system.sysutils,
  kubo.rest.client.interfaces,
  kubo.rest.client.utils;

type
  tkuboRequest<t: class> = class(tinterfacedobject, ikuboRequest<t>)
  private
    {private declarations}
    [weak]
    fparent: ikuboRestClient<t>;

    furi: string;
    fresource: string;
    faccept: string;
    fcharset: string;
  public
    {private declarations}
    constructor create(pparent: ikuboRestClient<t>);
    destructor destroy; override;

    class function new(pparent: ikuboRestClient<t>): ikuboRequest<t>;

    function uri(const puri: string): ikuboRequest<t>; overload;
    function resource(const presource: string): ikuboRequest<t>; overload;
    function accept(const paccept: string): ikuboRequest<t>; overload;
    function charset(const pcharset: string): ikuboRequest<t>; overload;
    function uri: string; overload;
    function resource: string; overload;
    function accept: string; overload;
    function charset: string; overload;
    function &end: ikuboRestClient<t>;
  end;

implementation

uses
  System.Math;

{ tkuboRequest<t> }

function tkuboRequest<t>.accept(const paccept: string): ikuboRequest<t>;
begin
  result := self;
  faccept := faccept + iif(faccept <> emptystr, ',', '') + paccept;
end;

function tkuboRequest<t>.accept: string;
begin
  result := faccept;
end;

function tkuboRequest<t>.charset(const pcharset: string): ikuboRequest<t>;
begin
  result := self;
  fcharset := fcharset + iif(fcharset <> emptystr, ',', '') + pcharset;
end;

function tkuboRequest<t>.charset: string;
begin
  result := fcharset;
end;

constructor tkuboRequest<t>.create(pparent: ikuboRestClient<t>);
begin
  fparent := pparent;
end;

destructor tkuboRequest<t>.destroy;
begin

  inherited;
end;

function tkuboRequest<t>.&end: ikuboRestClient<t>;
begin
  result := fparent;
end;

class function tkuboRequest<t>.new(pparent: ikuboRestClient<t>): ikuboRequest<t>;
begin
  result := self.create(pparent);
end;

function tkuboRequest<t>.resource: string;
begin
  result := fresource;
end;

function tkuboRequest<t>.resource(const presource: string): ikuboRequest<t>;
begin
  result := self;
  fresource := presource;
end;

function tkuboRequest<t>.uri: string;
begin
  result := furi;
end;

function tkuboRequest<t>.uri(const puri: string): ikuboRequest<t>;
begin
  result := self;
  furi := puri;
end;

end.
