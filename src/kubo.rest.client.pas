unit kubo.rest.client;

interface

uses
  system.sysutils,
  system.classes,
  system.math,
  system.variants,
  system.json,
  system.netencoding,
  system.generics.collections,
  rest.client,
  rest.types,
  rest.json,
  kubo.rest.client.interfaces,
  kubo.rest.client.types, kubo.rest.client.utils;

type

  tkubo_rest_client<t: class, constructor> = class(tinterfacedobject, ikubo_rest_client<t>)
  private
    {private declarations}
    frequest: ikubo_rest_client_request<t>;
    fcontenttype: string;
    fauthentication: ikubo_rest_client_authentication<t>;
    fparams: ikubo_rest_client_params<t>;

    frest_client_: trestclient;
    frest_request_: trestrequest;
    frest_response_: trestresponse;

    frest_request_json_body_itens: tjsonobject;

    procedure doprepare;
    function dorequest(const prest_eequest_method: trestrequestmethod): string;
  public
    {public declarations}
    constructor create(const puri: string = ''; const presource: string = '');
    destructor destroy; override;

    class function new(const pbase_url: string = ''; const presource: string = ''): ikubo_rest_client<t>;

    function request: ikubo_rest_client_request<t>;
    function contenttype(const pcontenttype: string): ikubo_rest_client<t>;
    function authentication(ptype: tkupo_rest_client_authentication_type = taNone): ikubo_rest_client_authentication<t>;
    function params: ikubo_rest_client_params<t>;

    function get: string; overload;
    function get(var alist: tobjectlist<t>): ikubo_rest_client<t>; overload;
    function get(var obj: t): ikubo_rest_client<t>; overload;

    function post(const content: string): string;
    function put(const content: string): string;
    function delete: string;
  end;

implementation

{ tkubo_rest_client<t> }

uses
  kubo.rest.client.request,
  kubo.rest.client.authenticatoin,
  kubo.rest.client.params;

function tkubo_rest_client<t>.authentication(ptype: tkupo_rest_client_authentication_type = taNone): ikubo_rest_client_authentication<t>;
begin
  result := fauthentication.types(ptype);
end;

function tkubo_rest_client<t>.contenttype(const pcontenttype: string): ikubo_rest_client<t>;
begin
  result := self;
  fcontenttype := pcontenttype;
end;

constructor tkubo_rest_client<t>.create(const puri: string = ''; const presource: string = '');
begin
  frequest := tkubo_rest_client_request<t>.new(self);

  //set default values rest json client application
    frequest.uri(puri);
    frequest.resource(presource);
    frequest.accept('application/json, text/plain; q=0.9, text/html;q=0.8');
    frequest.charset('utf-8, *;q=0.8');

  //contenttype
    fcontenttype := 'application/json';

  //authentication
    fauthentication := tkubo_rest_client_authentication<t>.create(self);

  //params
    fparams := tkubo_rest_client_params<t>.create(self);

  frest_client_ := nil;
  frest_request_:= nil;
  frest_response_:= nil;
end;

function tkubo_rest_client<t>.delete: string;
begin

end;

destructor tkubo_rest_client<t>.destroy;
begin
  if frest_response_ <> nil then
    freeandnil(frest_response_);

  if frest_request_ <> nil then
    freeandnil(frest_request_);

  if frest_client_ <> nil then
    freeandnil(frest_client_);

  inherited;
end;

procedure tkubo_rest_client<t>.doprepare;
var
  lint_count_: integer;
begin
  try

    case fauthentication.types of
    taBasic: params.add('Authorization', '', 'Basic ' +  tnetencoding.base64.encode(fauthentication.login + ':' + fauthentication.password), kpkHTTPHeader);
    taBearer: params.add('Authorization', '', 'Bearer ' + fauthentication.token, kpkHTTPHeader);
    end;

    for lint_count_ := 0 to params.count - 1 do
      case params.items(lint_count_).kind of
      kpkHTTPHeader:
        begin
          if trim(vartostr(params.items(lint_count_).value)) = '' then
            exit;
          frest_client_.addparameter(params.items(lint_count_).name, vartostr(params.items(lint_count_).value), pkHTTPHEADER);
        end;
      kpkURLSegment:
        begin
          if trim(vartostr(params.items(lint_count_).value)) = '' then
            exit;

          frest_request_.resource := frest_request_.resource +
                                     iif(
                                          params.items(lint_count_).resource.trim <> '',
                                          iif(
                                              pos('/' + params.items(lint_count_).resource.trim, frest_request_.resource) > 0,
                                              '',
                                              '/'  + params.items(lint_count_).resource.trim
                                             ),
                                          iif(
                                             vartostr(params.items(lint_count_).value).trim = '',
                                              params.items(lint_count_).name,
                                              iif(
                                                  pos('?', frest_request_.resource) > 0,
                                                  '',
                                                  '?'
                                                  )
                                              +
                                              iif(
                                                  pos('}', frest_request_.resource) > 0,
                                                  '&',
                                                  ''
                                                 )
                                              +
                                              params.items(lint_count_).name + '=' + '{' +  params.items(lint_count_).name + '}'
                                             )
                                          );

          frest_request_.addparameter(params.items(lint_count_).name, vartostr(params.items(lint_count_).value), pkURLSEGMENT);
        end;
      kpkGetPost:
        begin
          if vartostr(params.items(lint_count_).value).trim <> '' then
            frest_request_.addparameter(params.items(lint_count_).name, vartostr(params.items(lint_count_).value), pkGETorPOST);
        end;
      kpkRequestBody:
        begin
          if trim(vartostr(params.items(lint_count_).value)) = '' then
            exit;

          {cria o json body se ainda não estiver criado}
            if frest_request_json_body_itens = nil then
              frest_request_json_body_itens := system.json.tjsonobject.create;

          {verifica se o parametro passado ja não é oum json string}
            var li_rest_request_json_body_iten: tjsonobject;
            try
              li_rest_request_json_body_iten := tjsonobject.parsejsonvalue(
                                                              tencoding.ascii.getbytes(vartostr(params.items(lint_count_).value))
                                                              , 0) as tjsonobject;

            except
              if li_rest_request_json_body_iten <> nil then
                freeandnil(li_rest_request_json_body_iten);
            end;

          {se a variavel "li_rest_request_json_body_iten" for difernete de nil quer diser que o valor passado
          no parametro era um json string assim deve adicionar o json item direto, se não adiciona o valor}
            if li_rest_request_json_body_iten  <> nil then
              frest_request_json_body_itens.addpair(params.items(lint_count_).name, li_rest_request_json_body_iten)
            else
              frest_request_json_body_itens.addpair(params.items(lint_count_).name, params.items(lint_count_).value);

          {cria o body data para adicionar o valor no bory request}
            var li_str_strem_body := tstringstream.create(
                                            stringreplace(unquoted(frest_request_json_body_itens.tojson), '\', '', [rfReplaceAll]),
                                            tencoding.utf8);

            if li_rest_request_json_body_iten <> nil then
              freeandnil(li_rest_request_json_body_iten);

          {adiconar o bodydata no bory request}
            frest_request_.clearbody;
            frest_request_.addbody(li_str_strem_body, trestcontenttype.ctapplication_json);
            freeandnil(li_str_strem_body);
        end;
      end;
  finally
  end;
end;

function tkubo_rest_client<t>.dorequest(const prest_eequest_method: trestrequestmethod): string;
begin
  result := '';
  frest_client_ := nil;
  frest_response_ := nil;
  frest_request_ := nil;

  try
    try
      frest_client_ := trestclient.create(frequest.uri);
      frest_client_.accept := frequest.accept;
      frest_client_.acceptcharset := frequest.charset;
      //frest_client_.raiseexceptionon500 := false;

      frest_response_ := trestresponse.create(frest_client_);
      frest_response_.contenttype   := fcontenttype;

      frest_request_ := trestrequest.create(frest_client_);
      frest_request_.client := frest_client_;
      frest_request_.response := frest_response_;

      frest_request_.method := prest_eequest_method;
      frest_request_.resource := frequest.resource;

      doprepare;

      try
        frest_request_.execute;
      except
        on e: exception do
        begin
          if pos('HTTP/1.1 500', e.message) > 0 then
            result := frest_response_.jsontext
          else
            raise;
        end
      end;

      if result.trim = '' then
        result := frest_response_.jsontext;
    except
      on E: Exception do
        raise;
    end;
  finally
    frest_client_.disconnect;

    if frest_response_ <> nil then
      freeandnil(frest_response_);

    if frest_request_ <> nil then
      freeandnil(frest_request_);

    if frest_client_ <> nil then
      freeandnil(frest_client_);
  end;
end;

function tkubo_rest_client<t>.get(var obj: t): ikubo_rest_client<t>;
var
  lstr_response: string;
begin
  lstr_response := self.get;
  if lstr_response.trim <> '' then
    obj := rest.json.tjson.jsontoobject<t>(lstr_response, [joDateFormatISO8601, joIgnoreEmptyStrings, joIgnoreEmptyArrays])
  else
    obj := nil;
end;

function tkubo_rest_client<t>.get(var alist: tobjectlist<t>): ikubo_rest_client<t>;
var
  lstr_response: string;
begin
  lstr_response := self.get;
  if lstr_response.trim <> '' then
  begin
    alist := rest.json.tjson.jsontoobject<tobjectlist<t>>(lstr_response, [joDateFormatISO8601, joIgnoreEmptyStrings, joIgnoreEmptyArrays])
  end
  else
    alist := nil;
end;

function tkubo_rest_client<t>.get: string;
begin
  result := self.dorequest(trestrequestmethod.rmget);
end;

class function tkubo_rest_client<t>.new(const pbase_url: string; const presource: string): ikubo_rest_client<t>;
begin
  result := self.create(pbase_url, presource);
end;

function tkubo_rest_client<t>.params: ikubo_rest_client_params<t>;
begin
  result := fparams;
end;

function tkubo_rest_client<t>.post(const content: string): string;
begin

end;

function tkubo_rest_client<t>.put(const content: string): string;
begin

end;

function tkubo_rest_client<t>.request: ikubo_rest_client_request<t>;
begin
  result := frequest;
end;

end.
