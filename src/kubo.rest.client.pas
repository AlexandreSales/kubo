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
  kubo.rest.client.consts,
  kubo.rest.client.utils,
  kubo.rest.client.json;

type

  tkubo<t: class, constructor> = class(tinterfacedobject, ikubo<t>)
  private
    {private declarations}
    frequest: ikuboRequest<t>;
    fstatusCode: integer;
    fcontenttype: string;
    fconnectTimeOut: integer;
    freadTimeOut: integer;
    fusrAgent: string;

    fauthentication: ikuboAuthentication<t>;
    fparams: ikuboParams<t>;
    fobjectResponseError: tjsonObject;

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

    class function new(const pbase_url: string = ''; const presource: string = ''): ikubo<t>;

    function request: ikuboRequest<t>;
    function contenttype(const pcontenttype: string): ikubo<t>;
    function connectTimeOut(const ptimeOut: integer): ikubo<t>;
    function readTimeOut(const ptimeOut: integer): ikubo<t>;
    function usrAgent(const pstrUsrAgent: string): ikubo<t>;
    function authentication(ptype: tkuboAuthenticationType = taNone): ikuboAuthentication<t>;
    function params: ikuboParams<t>;
    function responseError(var objectResponseError: tjsonObject): ikubo<t>;
    function statusCode: integer;

    function get: string; overload;
    function get(var arrayResponse: ikuboJsonArray<t>): ikubo<t>; overload;
    function get(var objectResponse: ikuboJsonObject<t>): ikubo<t>; overload;
    function get(var jsonValue: tjsonValue): ikubo<t>; overload;

    function post: ikubo<t>; overload;
    function post(var arrayResponse: ikuboJsonArray<t>): ikubo<t>; overload;
    function post(var objectResponse: ikuboJsonObject<t>): ikubo<t>; overload;

    function put: ikubo<t>; overload;
    function put(var objectResponse: ikuboJsonObject<t>): ikubo<t>; overload;

    function delete: boolean; overload;
    function delete(var objectResponse: ikuboJsonObject<t>): ikubo<t>; overload;
  end;

implementation

{ tkubo<t> }

uses
  kubo.json.objects,
  kubo.rest.client.request,
  kubo.rest.client.authenticatoin,
  kubo.rest.client.params;

function tkubo<t>.authentication(ptype: tkuboAuthenticationType = taNone): ikuboAuthentication<t>;
begin
  result := fauthentication.types(ptype);
end;

function tkubo<t>.connectTimeOut(const ptimeOut: integer): ikubo<t>;
begin
  result := self;
  fconnectTimeOut := ptimeOut;
end;

function tkubo<t>.contenttype(const pcontenttype: string): ikubo<t>;
begin
  result := self;
  fcontenttype := pcontenttype;
end;

constructor tkubo<t>.create(const puri: string = ''; const presource: string = '');
begin
  fusrAgent := 'Kubo RestClient';
  frequest := tkuboRequest<t>.new(self);

  //set default values rest json client application
    frequest.uri(puri);
    frequest.resource(presource);
    frequest.accept('application/json, text/plain; q=0.9, text/html;q=0.8');
    frequest.charset('utf-8, *;q=0.8');

  //contenttype
    fcontenttype := 'application/json';

  //timeOut
    fconnectTimeOut := cConnectTimeOut;
    freadTimeOut := cReadTimeOut;

  //authentication
    fauthentication := tkuboAuthentication<t>.create(self);

  //params
    fparams := tkuboParams<t>.create(self);

  fobjectResponseError := nil;
  frestClient := nil;
  frestRequest:= nil;
  frestResponse:= nil;
  fhttpBasicAuthentication := nil;

  fstatusCode := 0;
end;

function tkubo<t>.delete: boolean;
begin
  result := true;
  self.dorequest(trestrequestmethod.rmput);
end;

function tkubo<t>.delete(var objectResponse: ikuboJsonObject<t>): ikubo<t>;
var
  lstrResponse: string;
begin
  result := self;
  lstrResponse := self.dorequest(trestrequestmethod.rmDELETE);

  if (lstrResponse.trim <> '') and (lstrResponse.trim <> '{}') then
  begin
    if objectResponse = nil then
      objectResponse := tkuboJsonObject<t>.create;

    objectResponse.asJson := lstrResponse;
  end;
end;

destructor tkubo<t>.destroy;
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

  if fobjectResponseError <> nil then
    freeandnil(fobjectResponseError);

  inherited;
end;

function tkubo<t>.doprepare: boolean;
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
            var li_rest_json_value: tjsonvalue;
            try
              li_rest_json_value := tjsonobject.parsejsonvalue(tencoding.utf8.getbytes({$ifdef mswindows}
                                                                       unquoted(vartostr(params.items(lint_count_).value))
                                                                    {$else}
                                                                      vartostr(params.items(lint_count_).value)
                                                                    {$endif})
                                                              , 0);


              if li_rest_json_value is tjsonobject then
                li_rest_request_json_body_iten := li_rest_json_value as tjsonobject;

              if li_rest_json_value is tjsonarray then
                li_rest_request_json_body_iten := tjsonobject(li_rest_json_value as tjsonarray);
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
              frestRequestJsonBody.addpair(params.items(lint_count_).name, vartostr(params.items(lint_count_).value));

            {cria o body data para adicionar o valor no bory request}
             li_str_strem_body := tstringstream.create(
                                            unquoted(frestRequestJsonBody.tojson),
                                            tencoding.utf8);
          end
          else
          begin
            {cria o body data para adicionar o valor no bory request}
            if li_rest_request_json_body_iten <> nil then
              li_str_strem_body := tstringstream.create(
                                                        {$ifdef mswindows}
                                                          unquoted(li_rest_request_json_body_iten.tojson)
                                                        {$else}
                                                          li_rest_request_json_body_iten.tojson
                                                        {$endif}
                                                        ,
                                              tencoding.utf8);
          end;

          if li_rest_request_json_body_iten <> nil then
            freeandnil(li_rest_request_json_body_iten);

          {adiconar o bodydata no bory request}
            frestRequest.clearbody;
            if li_str_strem_body <> nil then
            begin
              frestRequest.addbody(li_str_strem_body, trestcontenttype.ctapplication_json);
              freeandnil(li_str_strem_body);
            end;
        end;
      end;

    result := true;
  finally

  end;
end;

function tkubo<t>.dorequest(const prest_eequest_method: trestrequestmethod): string;
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
      frestClient.connectTimeOut := fconnectTimeOut;
      frestClient.readTimeOut := freadTimeOut;

      if fusrAgent.trim <> '' then
        frestClient.userAgent := fusrAgent;

      frestResponse := trestresponse.create(frestClient);
      frestResponse.contenttype := fcontenttype;

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
            raise;
        end;

        fstatusCode := frestResponse.StatusCode;
        if frestResponse.StatusCode = 200 then
          result := frestResponse.Content
        else
          fobjectResponseError := tjsonObject.parseJSONValue(tencoding.utf8.GetBytes(frestResponse.jsontext), 0) as TJSONObject;
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

function tkubo<t>.responseError(var objectResponseError: tjsonObject): ikubo<t>;
begin
  result := self;

  if (fobjectResponseError <> nil) then
  begin
    if objectResponseError <> nil then
      freeandnil(objectResponseError);

    objectResponseError := tjsonObject.parseJSONValue(fobjectResponseError.tojson) as tjsonobject;
  end;
end;

function tkubo<t>.statusCode: integer;
begin
  result := fstatusCode;
end;

function tkubo<t>.usrAgent(const pstrUsrAgent: string): ikubo<t>;
begin
  result := self;
  fusrAgent := pstrUsrAgent;
end;

function tkubo<t>.get(var objectResponse: ikuboJsonObject<t>): ikubo<t>;
var
  lstr_response: string;
begin
  result := self;
  lstr_response := self.get;
  if (lstr_response.trim <> '') and (lstr_response.trim <> '{}') then
  begin
    if not(pos('error', lstr_response) > 0) then
    begin
      if objectResponse = nil then
        objectResponse := tkuboJsonObject<t>.create;

      objectResponse.asjson := lstr_response;
    end;
  end;
end;

function tkubo<t>.get(var arrayResponse: ikuboJsonArray<t>): ikubo<t>;
var
  lstr_response: string;
begin
  Result := Self;

  lstr_response := Self.get;
  if (lstr_response.trim <> '') and (lstr_response.trim <> '[]') then
  begin
    if not(pos('error', lstr_response) > 0) then
    begin
      if arrayResponse = nil then
        arrayResponse := tkuboJsonArray<t>.create;

      arrayResponse.asjson := lstr_response;
    end;
  end;
end;

function tkubo<t>.get: string;
begin
  result := self.dorequest(trestrequestmethod.rmget);
end;

class function tkubo<t>.new(const pbase_url: string; const presource: string): ikubo<t>;
begin
  result := self.create(pbase_url, presource);
end;

function tkubo<t>.params: ikuboParams<t>;
begin
  result := fparams;
end;

function tkubo<t>.post(var objectResponse: ikuboJsonObject<t>): ikubo<t>;
var
  lstrResponse: string;
begin
  result := self;
  lstrResponse := self.dorequest(trestrequestmethod.rmpost);

  if lstrResponse.trim <> '' then
  begin
    if objectResponse = nil then
      objectResponse := tkuboJsonObject<t>.create;

    objectResponse.asJson := lstrResponse;
  end;
end;


function tkubo<t>.put(var objectResponse: ikuboJsonObject<t>): ikubo<t>;
var
  lstrResponse: string;
begin
  result := self;
  lstrResponse := self.dorequest(trestrequestmethod.rmput);

  if (lstrResponse.trim <> '') and (lstrResponse.trim <> '{}') then
  begin
    if objectResponse = nil then
      objectResponse := tkuboJsonObject<t>.create;

    objectResponse.asJson := lstrResponse;
  end;
end;

function tkubo<t>.post(var arrayResponse: ikuboJsonArray<t>): ikubo<t>;
var
  lstrResponse: string;
begin
  result := self;
  lstrResponse := self.dorequest(trestrequestmethod.rmpost);

  if lstrResponse.trim <> '' then
  begin
    if arrayResponse = nil then
      arrayResponse := tkuboJsonArray<t>.create;

    arrayResponse.asJson := lstrResponse;
  end;
end;

function tkubo<t>.post: ikubo<t>;
begin
  result := self;
  self.dorequest(trestrequestmethod.rmpost);
end;

function tkubo<t>.put: ikubo<t>;
begin
  result := self;
  self.dorequest(trestrequestmethod.rmput);
end;

function tkubo<t>.readTimeOut(const ptimeOut: integer): ikubo<t>;
begin
  result := self;
  freadTimeOut := ptimeOut;
end;

function tkubo<t>.request: ikuboRequest<t>;
begin
  result := frequest;
end;


function tkubo<t>.get(var jsonValue: tjsonValue): ikubo<t>;
var
  lstr_response: string;
begin
  result := self;
  lstr_response := self.get;
  if (lstr_response.trim <> '') and (lstr_response.trim <> '{}') then
  begin
    if not(pos('error', lstr_response) > 0) then
      jsonValue := tjsonObject.parseJSONValue(tencoding.utf8.getbytes(lstr_response), 0);
  end;
end;

end.
