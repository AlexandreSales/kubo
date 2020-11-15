unit kubo.rest.client.authenticatoin;

interface

uses
  kubo.rest.client.interfaces,
  kubo.rest.client.types;

type

  tkubo_rest_client_authentication<t: class> = class(tinterfacedobject, ikubo_rest_client_authentication<t>)
  private
    {private declarations}
    [weak]
    fparent: ikubo_rest_client<t>;

    ftype: tkupo_rest_client_authentication_type;
    flogin: string;
    fpassword: string;
    ftoken: string;
  public
    {public declarations}
    constructor create(pparent: ikubo_rest_client<t>; pauthentication_type: tkupo_rest_client_authentication_type = taNone);
    destructor destroy; override;

    class function new(pparent: ikubo_rest_client<t>; pauthentication_type: tkupo_rest_client_authentication_type = taNone): ikubo_rest_client_authentication<t>;

    function types(const ptype: tkupo_rest_client_authentication_type): ikubo_rest_client_authentication<t>; overload;
    function bearer(const ptoken: string): ikubo_rest_client_authentication<t>;
    function basic(const plogin, ppassword: string): ikubo_rest_client_authentication<t>;
    function types: tkupo_rest_client_authentication_type; overload;
    function token: string;
    function login: string;
    function password: string;
    function &end: ikubo_rest_client<t>;
  end;

implementation


{ tkubo_rest_client_authentication<t> }

function tkubo_rest_client_authentication<t>.basic(const plogin, ppassword: string): ikubo_rest_client_authentication<t>;
begin
  result := self;
  flogin := plogin;
  fpassword := ppassword;
end;

function tkubo_rest_client_authentication<t>.bearer(const ptoken: string): ikubo_rest_client_authentication<t>;
begin
  result := self;
  ftoken := ptoken;
end;

constructor tkubo_rest_client_authentication<t>.create(pparent: ikubo_rest_client<t>; pauthentication_type: tkupo_rest_client_authentication_type = taNone);
begin
  ftype := pauthentication_type;
  fparent := pparent;
end;

destructor tkubo_rest_client_authentication<t>.destroy;
begin

  inherited;
end;

function tkubo_rest_client_authentication<t>.&end: ikubo_rest_client<t>;
begin
  result := fparent;
end;

function tkubo_rest_client_authentication<t>.login: string;
begin
  result := flogin;
end;

class function tkubo_rest_client_authentication<t>.new(pparent: ikubo_rest_client<t>; pauthentication_type: tkupo_rest_client_authentication_type = taNone): ikubo_rest_client_authentication<t>;
begin
  result := self.create(pparent, pauthentication_type);
end;

function tkubo_rest_client_authentication<t>.password: string;
begin
  result := fpassword;
end;

function tkubo_rest_client_authentication<t>.types: tkupo_rest_client_authentication_type;
begin
  result := ftype;
end;

function tkubo_rest_client_authentication<t>.types(const ptype: tkupo_rest_client_authentication_type): ikubo_rest_client_authentication<t>;
begin
  result := self;
  ftype := ptype;
end;

function tkubo_rest_client_authentication<t>.token: string;
begin
  result := ftoken;
end;

end.
