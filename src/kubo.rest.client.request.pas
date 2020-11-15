unit kubo.rest.client.request;

interface

uses
  system.sysutils,
  kubo.rest.client.interfaces,
  kubo.rest.client.utils;

type
  tkubo_rest_client_request<t: class> = class(tinterfacedobject, ikubo_rest_client_request<t>)
  private
    {private declarations}
    [weak]
    fparent: ikubo_rest_client<t>;

    furi: string;
    fresource: string;
    faccept: string;
    fcharset: string;
  public
    {private declarations}
    constructor create(pparent: ikubo_rest_client<t>);
    destructor destroy; override;

    class function new(pparent: ikubo_rest_client<t>): ikubo_rest_client_request<t>;

    function uri(const puri: string): ikubo_rest_client_request<t>; overload;
    function resource(const presource: string): ikubo_rest_client_request<t>; overload;
    function accept(const paccept: string): ikubo_rest_client_request<t>; overload;
    function charset(const pcharset: string): ikubo_rest_client_request<t>; overload;
    function uri: string; overload;
    function resource: string; overload;
    function accept: string; overload;
    function charset: string; overload;
    function &end: ikubo_rest_client<t>;
  end;

implementation

uses
  System.Math;

{ tkubo_rest_client_request<t> }

function tkubo_rest_client_request<t>.accept(const paccept: string): ikubo_rest_client_request<t>;
begin
  result := self;
  faccept := faccept + iif(faccept <> emptystr, ',', '') + paccept;
end;

function tkubo_rest_client_request<t>.accept: string;
begin
  result := faccept;
end;

function tkubo_rest_client_request<t>.charset(const pcharset: string): ikubo_rest_client_request<t>;
begin
  result := self;
  fcharset := fcharset + iif(fcharset <> emptystr, ',', '') + pcharset;
end;

function tkubo_rest_client_request<t>.charset: string;
begin
  result := fcharset;
end;

constructor tkubo_rest_client_request<t>.create(pparent: ikubo_rest_client<t>);
begin
  fparent := pparent;
end;

destructor tkubo_rest_client_request<t>.destroy;
begin

  inherited;
end;

function tkubo_rest_client_request<t>.&end: ikubo_rest_client<t>;
begin
  result := fparent;
end;

class function tkubo_rest_client_request<t>.new(pparent: ikubo_rest_client<t>): ikubo_rest_client_request<t>;
begin
  result := self.create(pparent);
end;

function tkubo_rest_client_request<t>.resource: string;
begin
  result := fresource;
end;

function tkubo_rest_client_request<t>.resource(const presource: string): ikubo_rest_client_request<t>;
begin
  result := self;
  fresource := presource;
end;

function tkubo_rest_client_request<t>.uri: string;
begin
  result := furi;
end;

function tkubo_rest_client_request<t>.uri(const puri: string): ikubo_rest_client_request<t>;
begin
  result := self;
  furi := puri;
end;

end.
