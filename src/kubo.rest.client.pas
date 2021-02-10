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
  fmx.dialogs,
  rest.client,
  rest.types,
  rest.json,
  rest.authenticator.basic,
  kubo.rest.client.interfaces,
  kubo.rest.client.types,
  kubo.rest.client.utils,
  kubo.rest.client.json;

type

  tkuboRestClient<t: class, constructor> = class(tinterfacedobject, ikuboRestClient<t>)
  private
    {private declarations}
    frequest: ikuboRequest<t>;
    fcontenttype: string;
    fauthentication: ikuboAuthentication<t>;
    fparams: ikuboParams<t>;

    frestClient: trestclient;
    frestRequest: trestrequest;
    frestResponse: trestresponse;
    fhttpBasicAuthentication: thttpbasicauthenticator;

    frestRequestJsonBody: tjsonobject;

    function doprepare: boolean;
    function dorequest(const prest_eequest_method: trestrequestmethod): string;
  public
    {public declarations}
    constructor create(const puri: string = ''; const presource: string = '');
    destructor destroy; override;

    class function new(const pbase_url: string = ''; const presource: string = ''): ikuboRestClient<t>;

    function request: ikuboRequest<t>;
    function contenttype(const pcontenttype: string): ikuboRestClient<t>;
    function authentication(ptype: tkuboAuthenticationType = taNone): ikuboAuthentication<t>;
    function params: ikuboParams<t>;

    function get: string; overload;
    function get(var akubo_object_array: ikuboJsonArray<t>): ikuboRestClient<t>; overload;
    function get(var akubo_object: ikuboJsonObject<t>): ikuboRestClient<t>; overload;

    function post: ikuboRestClient<t>; overload;
    function put: ikuboRestClient<t>; overload;
    function delete: boolean;
  end;

implementation

{ tkuboRestClient<t> }

uses
  kubo.json.objects,
  kubo.rest.client.request,
  kubo.rest.client.authenticatoin,
  kubo.rest.client.params;

function tkuboRestClient<t>.authentication(ptype: tkuboAuthenticationType = taNone): ikuboAuthentication<t>;
begin
  result := fauthentication.types(ptype);
end;

function tkuboRestClient<t>.contenttype(const pcontenttype: string): ikuboRestClient<t>;
begin
  result := self;
  fcontenttype := pcontenttype;
end;

constructor tkuboRestClient<t>.create(const puri: string = ''; const presource: string = '');
begin
  frequest := tkuboRequest<t>.new(self);

  //set default values rest json client application
    frequest.uri(puri);
    frequest.resource(presource);
    frequest.accept('application/json, text/plain; q=0.9, text/html;q=0.8');
    frequest.charset('utf-8, *;q=0.8');

  //contenttype
    fcontenttype := 'application/json';

  //authentication
    fauthentication := tkuboAuthentication<t>.create(self);

  //params
    fparams := tkuboParams<t>.create(self);

  frestClient := nil;
  frestRequest:= nil;
  frestResponse:= nil;
  fhttpBasicAuthentication := nil;
end;

function tkuboRestClient<t>.delete: boolean;
begin
  result := true;
  self.dorequest(trestrequestmethod.rmput);
end;

destructor tkuboRestClient<t>.destroy;
begin
  if frestResponse <> nil then
    freeandnil(frestResponse);

  if frestRequest <> nil then
    freeandnil(frestRequest);

  if fhttpBasicAuthentication <> nil then
    freeandnil(fhttpBasicAuthentication);

  if frestClient <> nil then
    freeandnil(frestClient);

  if frestRequestJsonBody <> nil then
    freeandnil(frestRequestJsonBody);

  inherited;
end;

function tkuboRestClient<t>.doprepare: boolean;
var
  lint_count_: integer;
  li_str_strem_body: tstringstream;
begin
  result := false;
  li_str_strem_body := nil;

  try
    case fauthentication.types of
    taBasic:
      begin
        fhttpBasicAuthentication := THTTPBasicAuthenticator.create(nil);
        fhttpBasicAuthentication.username := fauthentication.login;
        fhttpBasicAuthentication.password := fauthentication.password;

        frestClient.Authenticator := fhttpBasicAuthentication;
      end;
    taBearer: params.add('Authorization', '', 'Bearer ' + fauthentication.token, kpkHTTPHeader);
    end;

    for lint_count_ := 0 to params.count - 1 do
      case params.items(lint_count_).kind of
      kpkHTTPHeader:
        begin
          if trim(vartostr(params.items(lint_count_).value)) = '' then
            exit;
          frestClient.addparameter(params.items(lint_count_).name, vartostr(params.items(lint_count_).value), pkHTTPHEADER, [TRESTRequestParameterOption.poDoNotEncode]);
        end;
      kpkURLSegment:
        begin
          if vartostr(params.items(lint_count_).value).trim <> '' then
            frestRequest.addparameter(params.items(lint_count_).name, vartostr(params.items(lint_count_).value), pkURLSEGMENT);
        end;
      kpkQuery:
        begin
          if trim(vartostr(params.items(lint_count_).value)) = '' then
            exit;

          frestRequest.resource := frestRequest.resource +
                                     iif(
                                          params.items(lint_count_).resource.trim <> '',
                                          iif(
                                              pos('/' + params.items(lint_count_).resource.trim, frestRequest.resource) > 0,
                                              '',
                                              '/'  + params.items(lint_count_).resource.trim
                                             ),
                                          iif(
                                             vartostr(params.items(lint_count_).value).trim = '',
                                              params.items(lint_count_).name,
                                              iif(
                                                  pos('?', frestRequest.resource) > 0,
                                                  '',
                                                  '?'
                                                  )
                                              +
                                              iif(
                                                  pos('}', frestRequest.resource) > 0,
                                                  '&',
                                                  ''
                                                 )
                                              +
                                              params.items(lint_count_).name + '=' + '{' +  params.items(lint_count_).name + '}'
                                             )
                                          );

          frestRequest.addparameter(params.items(lint_count_).name, vartostr(params.items(lint_count_).value), pkURLSEGMENT);
        end;
      kpkGetPost:
        begin
          if vartostr(params.items(lint_count_).value).trim <> '' then
            frestRequest.addparameter(params.items(lint_count_).name, vartostr(params.items(lint_count_).value), pkGETorPOST);
        end;
      kpkRequestBody:
        begin
          if trim(vartostr(params.items(lint_count_).value)) = '' then
            exit;

          {cria o json body se ainda não estiver criado}
            if frestRequestJsonBody = nil then
              frestRequestJsonBody := system.json.tjsonobject.create;

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

          if params.items(lint_count_).name.trim <> '' then
          begin
            {se a variavel "li_rest_request_json_body_iten" for difernete de nil quer diser que o valor passado
            no parametro era um json string assim deve adicionar o json item direto, se não adiciona o valor}
            if li_rest_request_json_body_iten  <> nil then
              frestRequestJsonBody.addpair(params.items(lint_count_).name, li_rest_request_json_body_iten)
            else
              frestRequestJsonBody.addpair(params.items(lint_count_).name, params.items(lint_count_).value);

            {cria o body data para adicionar o valor no bory request}
             li_str_strem_body := tstringstream.create(
                                            stringreplace(unquoted(frestRequestJsonBody.tojson), '\', '', [rfReplaceAll]),
                                            tencoding.utf8);
          end
          else
            {cria o body data para adicionar o valor no bory request}
            li_str_strem_body := tstringstream.create(
                                            stringreplace(unquoted(li_rest_request_json_body_iten.tojson), '\', '', [rfReplaceAll]),
                                            tencoding.utf8);


          if li_rest_request_json_body_iten <> nil then
            freeandnil(li_rest_request_json_body_iten);

          {adiconar o bodydata no bory request}
            frestRequest.clearbody;
            frestRequest.addbody(li_str_strem_body, trestcontenttype.ctapplication_json);
            freeandnil(li_str_strem_body);
        end;
      end;

    result := true;
  finally

  end;
end;

function tkuboRestClient<t>.dorequest(const prest_eequest_method: trestrequestmethod): string;
var
  lint_count_: integer;
begin
  result := '';
  frestClient := nil;
  frestResponse := nil;
  frestRequest := nil;

  try
    try
      frestClient := trestclient.create(frequest.uri);
      frestClient.accept := frequest.accept;
      frestClient.acceptcharset := frequest.charset;

      frestResponse := trestresponse.create(frestClient);
      frestResponse.contenttype   := fcontenttype;

      frestRequest := trestrequest.create(frestClient);
      frestRequest.client := frestClient;
      frestRequest.response := frestResponse;
      frestRequest.synchronizedevents := false;

      frestRequest.method := prest_eequest_method;
      frestRequest.resource := frequest.resource;

      if doprepare then
      begin
        try
          frestRequest.execute;
        except
          on e: exception do
          begin
            if pos('HTTP/1.1 500', e.message) > 0 then
              result := frestResponse.jsontext
            else
              raise;
          end
        end;

        if result.trim = '' then
          result := frestResponse.jsontext;
      end;
    except
      on E: Exception do
        raise;
    end;
  finally
    frestClient.disconnect;

    if frestResponse <> nil then
      freeandnil(frestResponse);

    if frestRequest <> nil then
      freeandnil(frestRequest);

    if frestClient <> nil then
      freeandnil(frestClient);
  end;
end;

function tkuboRestClient<t>.get(var akubo_object: ikuboJsonObject<t>): ikuboRestClient<t>;
var
  lstr_response: string;
begin
  result := self;
  lstr_response := self.get;
  if lstr_response.trim <> '' then
  begin
    if not(pos('error', lstr_response) > 0) then
    begin
      if akubo_object = nil then
        akubo_object := tkuboJsonObject<t>.create;

      akubo_object.asjson := lstr_response;
    end;
  end;
end;

function tkuboRestClient<T>.get(var akubo_object_array: ikuboJsonArray<T>): ikuboRestClient<t>;
var
  lstr_response: string;
begin
  Result := Self;

  lstr_response := Self.get;
  if lstr_response.trim <> '' then
  begin
    if not(pos('error', lstr_response) > 0) then
    begin
      if akubo_object_array = nil then
        akubo_object_array := tkuboJsonArray<t>.create;

      akubo_object_array.asjson := lstr_response;
    end;
  end;
end;

function tkuboRestClient<t>.get: string;
begin
  result := self.dorequest(trestrequestmethod.rmget);
end;

class function tkuboRestClient<t>.new(const pbase_url: string; const presource: string): ikuboRestClient<t>;
begin
  result := self.create(pbase_url, presource);
end;

function tkuboRestClient<t>.params: ikuboParams<t>;
begin
  result := fparams;
end;

function tkuboRestClient<t>.post: ikuboRestClient<t>;
begin
  result := self;
  self.dorequest(trestrequestmethod.rmpost);
end;

function tkuboRestClient<t>.put: ikuboRestClient<t>;
begin
  result := self;
  self.dorequest(trestrequestmethod.rmput);
end;

function tkuboRestClient<t>.request: ikuboRequest<t>;
begin
  result := frequest;
end;

end.
