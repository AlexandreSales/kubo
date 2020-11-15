unit xcloud.client.rest.auth;

interface

uses
  System.Classes, System.SysUtils, System.JSON, REST.Client, REST.Types,
  XSuperObject, xcloud.client.rest, xcloud.client.rest.auth.consts, xcloud.client.rest.api.classes;

type

  txcloud_rest_client_auth = class(txcloud_rest_client)
  private
    { private declarations }
    const
      cstr_uri_class = '/auth';

  public
    { public declarations }
    constructor create; overload;

    function connect: Boolean;
    function authorize(papp_Key, papp_Securyt_Key: String; var ptokenResult: String): boolean;
    function authenticate(const app_token, user_token: string): tjsonstringvalue;
    function login(const app_token, user, password, authorize_key: String; var tokenresult: String): boolean;
    function registeruser(const app_token, user: string): boolean;
    function activate(const app_token, user, password, authorization_key: string): boolean;

    function requestpassword(const app_token, user: string): boolean;
    function redefinepassword(const app_token, user, newpassword, authorization_key: string; var tokenresult: String): boolean;
    function authorizationcode<t>(const token: string; user: string =''; password: string =''): ixcloud_rest_result<t>;
    function authorizationkey(const token, authorization_code: string; user: string = ''; password: string =''): tjsonstringvalue;
    function user(const user_token: string): tjsonstringvalue;
    function photo(const user_token, files: string): boolean;
    function user_update(const user_token: string; const name: string): tjsonstringvalue;
    function singupcode(const user_token: string; const code: string): boolean;

    function recovery<t>(const app_token, doc: string): ixcloud_rest_result<t>;
    function update_valide<t>(const user_token: string): ixcloud_rest_result<t>;


    function deletephoto(const user_token: string): boolean;
  end;

implementation

uses
  xcloud.client.rest.consts,  REST.HttpClient;

{ txcloud_rest_client_auth }

function txcloud_rest_client_auth.activate(const app_token, user, password, authorization_key: string): boolean;
var
  lxJson : TSuperObject;
  lxcloud_rest_parameter_metadata: txcloud_rest_parameter_metadata;
begin
  lxJson := nil;

  try
    try
      FRestRequest.Method     := TRESTRequestMethod.rmPOST;
      FRestRequest.Resource   := '/activate';

      for lxcloud_rest_parameter_metadata in fxcloud_rest_client_auth_activate do
        case lxcloud_rest_parameter_metadata.index of
        0: prepareResquest(lxcloud_rest_parameter_metadata, app_token);
        1: prepareResquest(lxcloud_rest_parameter_metadata, user);
        2: prepareResquest(lxcloud_rest_parameter_metadata, password);
        3: prepareResquest(lxcloud_rest_parameter_metadata, authorization_key);
        end;

      FRestRequest.Execute;

      lxJson := TSuperObject.Create(FRestResponse.JSONText);
      result := validateResponse(lxJson, ttype_app);
    except
      on  E: Exception do
        raise;
    end;
  finally
    FRestClient.Disconnect;

    if lxJson <> nil then
      freeandnil(lxJson);
  end;
end;

function txcloud_rest_client_auth.authorize(papp_Key, papp_Securyt_Key: String; var ptokenResult: String): Boolean;
var
  lxJson: TSuperObject;
  lxcloud_rest_parameter_metadata: txcloud_rest_parameter_metadata;
begin
  lxJson := nil;

  try
    try
      ptokenResult    := '';

      FRestRequest.Method := TRESTRequestMethod.rmGET;
      FRestRequest.Resource := '/authorize';

      for lxcloud_rest_parameter_metadata in fxcloud_rest_client_auth_authorize do
        case lxcloud_rest_parameter_metadata.index of
        0: prepareResquest(lxcloud_rest_parameter_metadata, papp_Key);
        1: prepareResquest(lxcloud_rest_parameter_metadata, papp_Securyt_Key);
        end;

      FRestRequest.Execute;
      lxJson := TSuperObject.Create(FRestResponse.JSONText);

      Result := validateResponse(lxJson);
      if Result then
        ptokenResult := lxJson['result."data"."token"'].AsString;
    except
      on E: Exception do
        raise;
    end;
  finally
    FRestClient.Disconnect;

    if lxJson <> nil then
      freeandnil(lxJson);
  end;
end;

function txcloud_rest_client_auth.connect: Boolean;
var
  lxJson: TSuperObject;
begin
  lxJson := nil;

  try
    try
      Result := False;

      FRestRequest.Method := TRESTRequestMethod.rmGET;
      FRestRequest.Resource := '/connect';

      FRestRequest.Execute;
      lxJson := TSuperObject.Create(FRestResponse.JSONText);

      if lxJson['result."status"'].ToString = '"success"' then
        Result := lxJson['result."data"."status"'].ToString = '"connected"';
    except
      on E: Exception do
        raise;
    end;
  finally
    FRestClient.Disconnect;

    if lxJson <> nil then
      freeandnil(lxJson);
  end;
end;

function txcloud_rest_client_auth.authenticate(const app_token, user_token: string): TJSONStringValue;
var
  lxJson: TSuperObject;
  lxcloud_rest_parameter_metadata: txcloud_rest_parameter_metadata;
begin
  result := '';
  lxJson := nil;

  try
    try
      FRestRequest.Method     := TRESTRequestMethod.rmGET;
      FRestRequest.Resource   := '/authenticate';

      for lxcloud_rest_parameter_metadata in fxcloud_rest_client_auth_authenticate do
        case lxcloud_rest_parameter_metadata.index of
        0: prepareResquest(lxcloud_rest_parameter_metadata, app_token);
        1: prepareResquest(lxcloud_rest_parameter_metadata, user_token);
        end;

      FRestRequest.Execute;
      lxJson := TSuperObject.Create(FRestResponse.JSONText);

      if validateResponse(lxJson, ttype_user) then
        result := lxJson['result."data"."token"'].AsString;;
    except
      on  E: Exception do
        raise;
    end;
  finally
    FRestClient.Disconnect;

    if lxJson <> nil then
      freeandnil(lxJson);
  end;
end;

function txcloud_rest_client_auth.authorizationcode<t>(const token: string; user: string =''; password: string =''): ixcloud_rest_result<t>;
var
  lxJson: TSuperObject;
  lxcloud_rest_parameter_metadata: txcloud_rest_parameter_metadata;
begin
  result := txcloud_rest_result<t>.create;
  lxJson := nil;

  try
    try
      FRestRequest.Method     := TRESTRequestMethod.rmGET;
      FRestRequest.Resource   := '/authorizationcode';

      for lxcloud_rest_parameter_metadata in fxcloud_rest_client_auth_authorizationcode do
        case lxcloud_rest_parameter_metadata.index of
        0: prepareResquest(lxcloud_rest_parameter_metadata, token);
        1: prepareResquest(lxcloud_rest_parameter_metadata, user);
        2: prepareResquest(lxcloud_rest_parameter_metadata, password);
        end;

      try
        FRestRequest.Execute;
      except
        on E: Exception do
          if pos('HTTP/1.1 500', E.Message) > 0 then
          begin
            lxJson := TSuperObject.Create(FRestResponse.JSONText);
            if (lxJson['result."status"'].asstring = 'erro') or (lxJson['result."status"'].asstring = 'warning') then
              raise Exception.Create(lxJson.asjson)
            else
              raise;
          end
          else
            raise;
      end;

      lxJson := TSuperObject.create(FRestResponse.JSONText);
      if validateResponse(lxJson, ttype_user) then
        txcloud_rest_result<t>(result).assignfromjson(lxJson['result'].tostring);
    except
      on  E: Exception do
        raise;
    end;
  finally
    FRestClient.Disconnect;

    if lxJson <> nil then
      FreeAndNil(lxJson);
  end;
end;

function txcloud_rest_client_auth.authorizationkey(const token, authorization_code: string; user: string = ''; password: string =''): string;
var
  lxJson: TSuperObject;
  lxcloud_rest_parameter_metadata: txcloud_rest_parameter_metadata;
begin
  result := '';
  lxJson := nil;

  try
    try
      FRestRequest.Method     := TRESTRequestMethod.rmGET;
      FRestRequest.Resource   := '/authorizationkey';

      for lxcloud_rest_parameter_metadata in fxcloud_rest_client_auth_authorizationkey do
        case lxcloud_rest_parameter_metadata.index of
        0: prepareResquest(lxcloud_rest_parameter_metadata, token);
        1: prepareResquest(lxcloud_rest_parameter_metadata, authorization_code);
        2: prepareResquest(lxcloud_rest_parameter_metadata, user);
        3: prepareResquest(lxcloud_rest_parameter_metadata, password);
        end;

      FRestRequest.Execute;

      lxJson := TSuperObject.Create(FRestResponse.JSONText);

      if validateResponse(lxJson, ttype_user) then
        result := lxJson['result."data"."key"'].AsString;;
    except
      on  E: Exception do
        raise;
    end;
  finally
    FRestClient.Disconnect;

    if lxJson <> nil then
      FreeAndNil(lxJson);
  end;
end;

constructor txcloud_rest_client_auth.create;
begin
  inherited create(curi_end_point_auth + cstr_uri_class);
end;

function txcloud_rest_client_auth.deletephoto(const user_token: string): boolean;
var
  lxJson: TSuperObject;
  lxcloud_rest_parameter_metadata: txcloud_rest_parameter_metadata;
  lbooResult: boolean;
begin
  lxJson    := nil;
  result    := false;

  try
    try
      FRestRequest.Method     := TRESTRequestMethod.rmDELETE;
      FRestRequest.Resource   := '/photo';

      for lxcloud_rest_parameter_metadata in fxcloud_rest_client_auth_photo do
        case lxcloud_rest_parameter_metadata.index of
        0: prepareResquest(lxcloud_rest_parameter_metadata, user_token);
        end;

      FRestRequest.Execute;
      lxJson := TSuperObject.Create(FRestResponse.JSONText);

      lbooResult := validateResponse(lxJson, ttype_app);
      if lbooResult then
        result := lxJson['result."status"'].AsString = 'success';
    except
      on  E: Exception do
        raise;
    end;
  finally
    FRestClient.Disconnect;
    FreeAndNil(lxJson);
  end;
end;

function txcloud_rest_client_auth.login(const app_token, user, password, authorize_key: String; var tokenresult: String): Boolean;
var
  lxJson      : TSuperObject;
  lbooResult  : Boolean;
  lxcloud_rest_parameter_metadata: txcloud_rest_parameter_metadata;
begin
  result := false;
  lxJson := nil;

  try
    try
      FRestRequest.Method   := TRESTRequestMethod.rmGET;
      FRestRequest.Resource := '/login';

      for lxcloud_rest_parameter_metadata in fxcloud_rest_client_auth_login do
        case lxcloud_rest_parameter_metadata.index of
        0: prepareResquest(lxcloud_rest_parameter_metadata, app_token);
        1: prepareResquest(lxcloud_rest_parameter_metadata, user);
        2: prepareResquest(lxcloud_rest_parameter_metadata, password);
        3: prepareResquest(lxcloud_rest_parameter_metadata, authorize_key);
        end;

      rest_request_execute(lxJson);
      lxJson := TSuperObject.Create(FRestResponse.JSONText);

      lbooResult := validateResponse(lxJson, ttype_app);
      if lbooResult then
      begin
        tokenresult := lxJson['result."data"."token"'].AsString;
        result := true;
      end

    except
      on E: Exception do
        raise;
    end;
  finally
    FRestClient.Disconnect;

    if lxJson <> nil then
      FreeAndNil(lxJson);
  end;
end;

function txcloud_rest_client_auth.photo(const user_token, files: string): boolean;
var
  lxJson: TSuperObject;
  lxcloud_rest_parameter_metadata: txcloud_rest_parameter_metadata;
  lbooResult: Boolean;

  ljs_objet : tjsonobject;
begin
  lxJson    := nil;
  result    := false;
  ljs_objet := nil;

  try
    try
      FRestRequest.Method     := TRESTRequestMethod.rmPOST;
      FRestRequest.Resource   := '/photo';

      for lxcloud_rest_parameter_metadata in fxcloud_rest_client_auth_photo do
        case lxcloud_rest_parameter_metadata.index of
        0: prepareResquest(lxcloud_rest_parameter_metadata, user_token);
        1: prepareResquest(lxcloud_rest_parameter_metadata, files);
        end;

      try
        frestrequest.execute;
        lxJson := tsuperobject.create(frestresponse.jsontext);
      except
        if frestresponse.jsontext.trim <> '' then
          lxJson := tsuperobject.create(frestresponse.jsontext)
        else
          raise;
      end;

      lbooResult := validateResponse(lxJson, ttype_app);
      if lbooResult then
        result := lxJson['result."status"'].AsString = 'success';
    except
      on  E: Exception do
        raise;
    end;
  finally
    FRestClient.Disconnect;

    FreeAndNil(lxJson);
    FreeAndNil(ljs_objet);
  end;
end;

function txcloud_rest_client_auth.recovery<t>(const app_token, doc: string): ixcloud_rest_result<t>;
var
  lxjson: tsuperobject;
  lxcloud_rest_parameter_metadata: txcloud_rest_parameter_metadata;
begin
  result := txcloud_rest_result<t>.create;
  lxJson := nil;

  try
    try
      frestrequest.method := trestrequestmethod.rmGET;
      frestrequest.resource := '/recovery';

      for lxcloud_rest_parameter_metadata in fxcloud_rest_client_auth_recovery do
        case lxcloud_rest_parameter_metadata.index of
        0: prepareResquest(lxcloud_rest_parameter_metadata, app_token);
        1: prepareResquest(lxcloud_rest_parameter_metadata, doc);
        end;

      try
        FRestRequest.Execute;
      except
        on E: Exception do
          if pos('HTTP/1.1 500', E.Message) > 0 then
          begin
            lxJson := TSuperObject.Create(FRestResponse.JSONText);
            if (lxJson['result."status"'].asstring = 'erro') or (lxJson['result."status"'].asstring = 'warning') then
              raise Exception.Create(lxJson.asjson)
            else
              raise;
          end
          else
            raise;
      end;

      lxJson := TSuperObject.create(FRestResponse.JSONText);
      if validateResponse(lxJson, ttype_user) then
        txcloud_rest_result<t>(result).assignfromjson(lxJson['result'].tostring);
    except
      on E: Exception do
        raise;
    end;
  finally
    FRestClient.Disconnect;

    if lxJson <> nil then
      FreeAndNil(lxJson);
  end;
end;

function txcloud_rest_client_auth.redefinepassword(const app_token, user, newpassword, authorization_key: string; var tokenresult: String): boolean;
var
  lxJson: TSuperObject;
  lxcloud_rest_parameter_metadata: txcloud_rest_parameter_metadata;
  lbooResult: Boolean;
begin
  lxJson := nil;
  result := false;

  try
    try
      FRestRequest.Method     := TRESTRequestMethod.rmPOST;
      FRestRequest.Resource   := '/redefinepassword';

      for lxcloud_rest_parameter_metadata in fxcloud_rest_client_auth_redefinepassword do
        case lxcloud_rest_parameter_metadata.index of
        0: prepareResquest(lxcloud_rest_parameter_metadata, app_token);
        1: prepareResquest(lxcloud_rest_parameter_metadata, user);
        2: prepareResquest(lxcloud_rest_parameter_metadata, newpassword);
        3: prepareResquest(lxcloud_rest_parameter_metadata, authorization_key);
        end;

      FRestRequest.Execute;
      lxJson := TSuperObject.Create(FRestResponse.JSONText);

      lbooResult := validateResponse(lxJson, ttype_app);
      if lbooResult then
      begin
        tokenresult := lxJson['result."data"."token"'].AsString;
        result := true;
      end;

    except
      on  E: Exception do
        raise;
    end;
  finally
    FRestClient.Disconnect;

    if lxJson <> nil then
      FreeAndNil(lxJson);
  end;
end;

function txcloud_rest_client_auth.registeruser(const app_token, user: string): boolean;
var
  lxJson    : TSuperObject;
  lbooResult: Boolean;
  lxcloud_rest_parameter_metadata: txcloud_rest_parameter_metadata;
begin
  result      := false;
  lxJson      := nil;

  try
    try
      FRestRequest.Method     := TRESTRequestMethod.rmPOST;
      FRestRequest.Resource   := '/register';

      for lxcloud_rest_parameter_metadata in fxcloud_rest_client_auth_register do
        case lxcloud_rest_parameter_metadata.index of
        0: prepareResquest(lxcloud_rest_parameter_metadata, app_token);
        1: prepareResquest(lxcloud_rest_parameter_metadata, user);
        end;

      FRestRequest.Execute;
      lxJson := TSuperObject.Create(FRestResponse.JSONText);

      lbooResult := validateResponse(lxJson, ttype_app);
      if lbooResult then
        result := true;
    except
      on  E: Exception do
        raise;
    end;
  finally
    FRestClient.Disconnect;

    if lxJson <> nil then
      FreeAndNil(lxJson);
  end;
end;

function txcloud_rest_client_auth.requestpassword(const app_token, user: string): boolean;
var
  lxJson: TSuperObject;
  lxcloud_rest_parameter_metadata: txcloud_rest_parameter_metadata;
begin
  lxJson := nil;

  try
    try
      FRestRequest.Method     := TRESTRequestMethod.rmGET;
      FRestRequest.Resource   := '/requestpassword';

      for lxcloud_rest_parameter_metadata in fxcloud_rest_client_auth_requestpassword do
        case lxcloud_rest_parameter_metadata.index of
        0: prepareResquest(lxcloud_rest_parameter_metadata, app_token);
        1: prepareResquest(lxcloud_rest_parameter_metadata, user);
        end;

      FRestRequest.Execute;

      lxJson := TSuperObject.Create(FRestResponse.JSONText);
      result := validateResponse(lxJson, ttype_app);
    except
      on  E: Exception do
        raise;
    end;
  finally
    FRestClient.Disconnect;

    if lxJson  <> nil then
      FreeAndNil(lxJson);
  end;
end;

function txcloud_rest_client_auth.singupcode(const user_token: string; const code: string): boolean;
var
  lxJson: TSuperObject;
  lxcloud_rest_parameter_metadata: txcloud_rest_parameter_metadata;
  lbooResult: Boolean;
begin
  lxJson := nil;
  result := false;

  try
    try
      FRestRequest.Method     := TRESTRequestMethod.rmPOST;
      FRestRequest.Resource   := '/singupcode';

      for lxcloud_rest_parameter_metadata in fxcloud_rest_client_auth_singupcode do
        case lxcloud_rest_parameter_metadata.index of
        0: prepareResquest(lxcloud_rest_parameter_metadata, user_token);
        1: prepareResquest(lxcloud_rest_parameter_metadata, code);
        end;


      try
        FRestRequest.Execute;
      except
        on E: Exception do
          if pos('HTTP/1.1 500', E.Message) > 0 then
          begin
            lxJson := TSuperObject.Create(FRestResponse.JSONText);
            if (lxJson['result."status"'].asstring = 'erro') or (lxJson['result."status"'].asstring = 'warning') then
              raise Exception.Create(lxJson.asjson)
            else
              raise;
          end
          else
            raise;
      end;

      lxJson := TSuperObject.Create(FRestResponse.JSONText);
      if validateResponse(lxJson, ttype_user) then
        result := lxJson['result."data"."state"'].asstring = 'confirmed';
    except
      on  E: Exception do
        raise;
    end;
  finally
    FRestClient.Disconnect;

    if lxJson <> nil then
      FreeAndNil(lxJson);
  end;
end;

function txcloud_rest_client_auth.update_valide<t>(const user_token: string): ixcloud_rest_result<t>;
var
  lxjson: tsuperobject;
  lxcloud_rest_parameter_metadata: txcloud_rest_parameter_metadata;
begin
  result := txcloud_rest_result<t>.create;
  lxJson := nil;

  try
    try
      frestrequest.method := trestrequestmethod.rmGET;
      frestrequest.resource := '/valid';

      for lxcloud_rest_parameter_metadata in fxcloud_rest_client_auth_valid_post do
        case lxcloud_rest_parameter_metadata.index of
        0: prepareResquest(lxcloud_rest_parameter_metadata, user_token);
        end;

      try
        FRestRequest.Execute;
      except
        on E: Exception do
          if pos('HTTP/1.1 500', E.Message) > 0 then
          begin
            lxJson := TSuperObject.Create(FRestResponse.JSONText);
            if (lxJson['result."status"'].asstring = 'erro') or (lxJson['result."status"'].asstring = 'warning') then
              raise Exception.Create(lxJson.asjson)
            else
              raise;
          end
          else
            raise;
      end;

      lxJson := TSuperObject.create(FRestResponse.JSONText);
      if validateResponse(lxJson, ttype_user) then
        txcloud_rest_result<t>(result).assignfromjson(lxJson['result'].tostring);
    except
      on E: Exception do
        raise;
    end;
  finally
    FRestClient.Disconnect;

    if lxJson <> nil then
      FreeAndNil(lxJson);
  end;
end;

function txcloud_rest_client_auth.user(const user_token: string): string;
var
  lxJson: TSuperObject;
  lxcloud_rest_parameter_metadata: txcloud_rest_parameter_metadata;
begin
  result := '';
  lxJson := nil;

  try
    try
      FRestRequest.Method     := TRESTRequestMethod.rmGET;
      FRestRequest.Resource   := '/user';

      for lxcloud_rest_parameter_metadata in fxcloud_rest_client_auth_user do
        case lxcloud_rest_parameter_metadata.index of
        0: prepareResquest(lxcloud_rest_parameter_metadata, user_token);
        end;

      FRestRequest.Execute;

      lxJson := TSuperObject.Create(FRestResponse.JSONText);
      if validateResponse(lxJson, ttype_user) then
        result := lxJson['result."data"'].ToString;
    except
      on  E: Exception do
        raise;
    end;
  finally
    FRestClient.Disconnect;

    if lxJson <> nil then
      FreeAndNil(lxJson);
  end;

end;

function txcloud_rest_client_auth.user_update(const user_token: string; const name: string): string;
var
  lxcloud_rest_parameter_metadata: txcloud_rest_parameter_metadata;
  lxJson: TSuperObject;
begin
  result := '';
  lxJson := nil;

  try
    try
      FRestRequest.Method := TRESTRequestMethod.rmPUT;
      FRestRequest.Resource := '/user';

      for lxcloud_rest_parameter_metadata in fxcloud_rest_client_auth_user_update do
        case lxcloud_rest_parameter_metadata.index of
        0: prepareResquest(lxcloud_rest_parameter_metadata, user_token);
        1: prepareResquest(lxcloud_rest_parameter_metadata, name);
        2: prepareResquest(lxcloud_rest_parameter_metadata, '');
        end;

      try
        frestrequest.execute;
        lxJson := tsuperobject.create(frestresponse.jsontext);
      except
        if frestresponse.jsontext.trim <> '' then
          lxJson := tsuperobject.create(frestresponse.jsontext)
        else
          raise;
      end;

      if validateResponse(lxJson, ttype_user) then
        result := lxJson['result."data"'].ToString;
    except
      on E: Exception do
        raise;
    end;
  finally
    FRestClient.Disconnect;

    if lxJson <> nil then
      FreeAndNil(lxJson);
  end;
end;

end.
