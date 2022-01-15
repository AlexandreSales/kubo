unit kubo.rest.client.authenticatoin;

interface

uses
  kubo.rest.client.interfaces,
  kubo.rest.client.types;

type

  tkuboAuthentication<t: class> = class(tinterfacedobject, ikuboAuthentication<t>)
  private
    {private declarations}
    [weak]
    fparent: ikubo<t>;

    ftype: tkuboAuthenticationType;
    flogin: string;
    fpassword: string;
    ftoken: string;
  public
    {public declarations}
    constructor create(pparent: ikubo<t>; pauthentication_type: tkuboAuthenticationType = taNone);
    destructor destroy; override;

    class function new(pparent: ikubo<t>; pauthentication_type: tkuboAuthenticationType = taNone): ikuboAuthentication<t>;

    function types(const ptype: tkuboAuthenticationType): ikuboAuthentication<t>; overload;
    function bearer(const ptoken: string): ikuboAuthentication<t>;
    function basic(const plogin, ppassword: string): ikuboAuthentication<t>;
    function types: tkuboAuthenticationType; overload;
    function token: string;
    function login: string;
    function password: string;
    function &end: ikubo<t>;
  end;

implementation


{ tkuboAuthentication<t> }

function tkuboAuthentication<t>.basic(const plogin, ppassword: string): ikuboAuthentication<t>;
begin
  result := self;
  flogin := plogin;
  fpassword := ppassword;
end;

function tkuboAuthentication<t>.bearer(const ptoken: string): ikuboAuthentication<t>;
begin
  result := self;
  ftoken := ptoken;
end;

constructor tkuboAuthentication<t>.create(pparent: ikubo<t>; pauthentication_type: tkuboAuthenticationType = taNone);
begin
  ftype := pauthentication_type;
  fparent := pparent;
end;

destructor tkuboAuthentication<t>.destroy;
begin

  inherited;
end;

function tkuboAuthentication<t>.&end: ikubo<t>;
begin
  result := fparent;
end;

function tkuboAuthentication<t>.login: string;
begin
  result := flogin;
end;

class function tkuboAuthentication<t>.new(pparent: ikubo<t>; pauthentication_type: tkuboAuthenticationType = taNone): ikuboAuthentication<t>;
begin
  result := self.create(pparent, pauthentication_type);
end;

function tkuboAuthentication<t>.password: string;
begin
  result := fpassword;
end;

function tkuboAuthentication<t>.types: tkuboAuthenticationType;
begin
  result := ftype;
end;

function tkuboAuthentication<t>.types(const ptype: tkuboAuthenticationType): ikuboAuthentication<t>;
begin
  result := self;
  ftype := ptype;
end;

function tkuboAuthentication<t>.token: string;
begin
  result := ftoken;
end;

end.
