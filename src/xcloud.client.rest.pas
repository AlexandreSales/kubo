unit xcloud.client.rest;

interface

uses
  System.Classes, System.SysUtils, System.JSON, System.Variants, REST.Client, REST.Types,
  IPPeerClient, XSuperObject, FMX.Dialogs;

type

  TJSONStringValue = String;
  ttoken_type = (ttype_none, ttype_app, ttype_user);

  tprocedure_onupdate_local_token = procedure(const pstr_token: string; ptoken_type: ttoken_type) of object;

  txcloud_rest_parameter_metadata = record
    Index: Integer;
    Name: String;
    Value: String;
    Resource: String;
    Kind: TRESTRequestParameterKind;
  end;

  txcloud_rest_client = class(TObject)
  private
    { private declarations }
    fonupdate_local_token: tprocedure_onupdate_local_token;
    frest_request_json_body_itens: tjsonobject;

    procedure rest_request_on_after_execute(sender: tcustomrestrequest);
  protected
    {Protected declarations}
    FRestClient   : TRestClient;
    FRestRequest  : TRESTRequest;
    FRestResponse : TRESTResponse;

    function  unQuotedStr(const pstr_value: string): string;
    function  validateResponse(const pJSONResponse: TSuperObject; const pttoken_type: ttoken_type = ttype_none): Boolean;
    procedure prepareResquest(ptxcloud_rest_parameter_metadata: txcloud_rest_parameter_metadata; pvar_value: variant); overload;
    procedure setPostValue(const pstr_param, pstr_param_value: string; pboo_jason_value: boolean = false; pint_index_param : integer = 0);

    procedure rest_request_execute(pso_result: tsuperobject);
  public
    { public declarations }
    constructor Create(const cURI: String);
    destructor  Destroy; override;

    property onupdate_local_token: tprocedure_onupdate_local_token read fonupdate_local_token write fonupdate_local_token;
  end;

implementation

{ TXCAuth }

function iif(Condicao: Boolean; SeVerdadeiro, SeFalso: Variant): Variant;
begin
  if Condicao then
    Result := SeVerdadeiro
  else
    Result := SeFalso;
end;

constructor txcloud_rest_client.Create(const cURI: String);
begin
  frest_request_json_body_itens := nil;

  frestclient               := trestclient.create(nil);
  frestclient.baseurl       := cURI;

  frestresponse               := trestresponse.create(FRestClient);
  frestresponse.contenttype   := 'application/json';

  frestrequest                := trestrequest.create(frestclient);
  frestrequest.timeout        := 40000;
  frestrequest.client         := frestclient;
  frestrequest.response       := frestresponse;
  frestrequest.onafterexecute := rest_request_on_after_execute;
end;

destructor txcloud_rest_client.Destroy;
begin
  if FRestRequest <> nil then
    FRestRequest.DisposeOf;

  if FRestResponse <> nil then
    FRestResponse.DisposeOf;

  if FRestClient <> nil then
  begin
    FRestClient.Disconnect;
    FRestClient.DisposeOf;
  end;

  //if frest_request_json_body_itens <> nil then
  //  FreeAndNil(frest_request_json_body_itens);

  inherited;
end;

procedure txcloud_rest_client.setPostValue(const pstr_param, pstr_param_value: string; pboo_jason_value: boolean = false; pint_index_param : integer = 0);
begin
  if pboo_jason_value then
    FRestRequest.Params[pint_index_param].Value := StringReplace(FRestRequest.Params[pint_index_param].Value, '"' +  pstr_param + '"', pstr_param_value, [rfReplaceAll])
  else
    FRestRequest.Params[pint_index_param].Value := StringReplace(FRestRequest.Params[pint_index_param].Value, pstr_param, pstr_param_value, [rfReplaceAll]);
end;

function txcloud_rest_client.unQuotedStr(const pstr_value: string): string;
var
  lstr_result : string;
begin
  lstr_result :=  pstr_value;
  if trim(lstr_result) <> '' then
  begin
    {$IFDEF IOS}
      if lstr_result[0] = '"' then
        lstr_result := copy(lstr_result, 2, length(lstr_result) - 1);
    {$ELSE}
      {$IFDEF ANDROID}
        if lstr_result[1] = '"' then
          lstr_result := copy(lstr_result, 1, length(lstr_result));
      {$ELSE}
        if lstr_result[1] = '"' then
          lstr_result := copy(lstr_result, 2, length(lstr_result) - 1);
      {$ENDIF}
    {$ENDIF}

    {$IFDEF IOS}
      if lstr_result[length(lstr_result) - 1] = '"' then
        lstr_result := copy(lstr_result, 1, length(lstr_result) - 1);
    {$ELSE}
      if lstr_result[length(lstr_result)] = '"' then
        lstr_result := copy(lstr_result, 1, length(lstr_result) - 1);
    {$ENDIF}
  end;
  result := lstr_result;
end;

function txcloud_rest_client.validateResponse(const pJSONResponse: TSuperObject; const pttoken_type: ttoken_type = ttype_none): Boolean;
begin
  if (pJSONResponse['result."status"'].AsString = 'erro') or (pJSONResponse['result."status"'].AsString = 'warning') then
    raise Exception.Create(pJSONResponse.AsJSON)
  else
  begin
    result := True;

    if (pttoken_type <> ttype_none) and (trim(pJSONResponse['result."token"'].AsString) <> '')  then
    begin
      if Assigned(fonupdate_local_token) then
        fonupdate_local_token(pJSONResponse['result."token"'].AsString, pttoken_type);
    end;
  end;
end;

procedure txcloud_rest_client.prepareResquest(ptxcloud_rest_parameter_metadata: txcloud_rest_parameter_metadata; pvar_value: variant);
begin
  try
    case ptxcloud_rest_parameter_metadata.Kind of
    pkHTTPHEADER:
      begin

        if trim(VarToStr(pvar_value)) = '' then
          exit;

        if (ptxcloud_rest_parameter_metadata.name = 'user_token') or (ptxcloud_rest_parameter_metadata.name = 'app_token') or (ptxcloud_rest_parameter_metadata.name = 'token') then
          FRestRequest.AddAuthParameter('Authorization', 'Bearer ' + VarToStr(pvar_value), ptxcloud_rest_parameter_metadata.Kind, [poDoNotEncode])
        else
          FRestRequest.AddParameter(ptxcloud_rest_parameter_metadata.name, VarToStr(pvar_value), ptxcloud_rest_parameter_metadata.Kind)
      end;
    pkURLSEGMENT:
      begin
        if VarToStr(pvar_value).Trim <> '' then
        begin
          FRestRequest.Resource := frestrequest.resource +
                                   iif(ptxcloud_rest_parameter_metadata.resource.trim <> '',
                                       iif(Pos('/' + ptxcloud_rest_parameter_metadata.resource.trim, FRestRequest.Resource) > 0,
                                           '',
                                           '/'  + ptxcloud_rest_parameter_metadata.resource.trim
                                       )
                                       ,
                                       iif(
                                           ptxcloud_rest_parameter_metadata.value.trim = '',
                                           ptxcloud_rest_parameter_metadata.name,
                                           iif(Pos('?', FRestRequest.Resource) > 0,
                                               '',
                                               '?'
                                               ) +
                                               iif(Pos('}', FRestRequest.Resource) > 0,
                                                   '&',
                                                   ''
                                               ) +
                                               ptxcloud_rest_parameter_metadata.name + '=' + ptxcloud_rest_parameter_metadata.value
                                           )
                                   );


          FRestRequest.AddParameter(ptxcloud_rest_parameter_metadata.name, VarToStr(pvar_value), ptxcloud_rest_parameter_metadata.kind);
        end;
      end;
    pkGETorPOST:
      begin
        if VarToStr(pvar_value).Trim <> '' then
          FRestRequest.AddParameter(ptxcloud_rest_parameter_metadata.name, vartostr(pvar_value), pkGETorPOST);
      end;
    pkREQUESTBODY:
      begin
        if vartostr(pvar_value).trim <> '' then
        begin
          {cria o json body se ainda não estiver criado}
            if frest_request_json_body_itens = nil then
              frest_request_json_body_itens := system.json.tjsonobject.create;

          {verifica se o parametro passado ja não é oum json string}
            var li_rest_request_json_body_iten: tjsonobject;
            try
              li_rest_request_json_body_iten := tjsonobject.parsejsonvalue(
                                                              tencoding.ascii.getbytes(vartostr(pvar_value))
                                                              , 0) as tjsonobject;

            except
              if li_rest_request_json_body_iten <> nil then
                freeandnil(li_rest_request_json_body_iten);
            end;

          {se a variavel "li_rest_request_json_body_iten" for difernete de nil quer diser que o valor passado
          no parametro era um json string assim deve adicionar o json item direto, se não adiciona o valor}
            if li_rest_request_json_body_iten  <> nil then
              frest_request_json_body_itens.addpair(ptxcloud_rest_parameter_metadata.name, li_rest_request_json_body_iten)
            else
              frest_request_json_body_itens.addpair(ptxcloud_rest_parameter_metadata.name, pvar_value);

          {cria o body data para adicionar o valor no bory request}
            var li_str_strem_body := tstringstream.create(
                                            stringreplace(unQuotedStr(frest_request_json_body_itens.tojson), '\', '', [rfReplaceAll]),
                                            TEncoding.UTF8);

            if li_rest_request_json_body_iten <> nil then
              freeandnil(li_rest_request_json_body_iten);

          {adiconar o bodydata no bory request}
            frestrequest.clearbody;
            frestrequest.addbody(li_str_strem_body, trestcontenttype.ctapplication_json);
            freeandnil(li_str_strem_body);
        end;
      end;
    end;

  finally
  end;
end;

procedure txcloud_rest_client.rest_request_execute(pso_result: tsuperobject);
begin
  try
    frestrequest.execute;
  except
    on e: exception do
      if pos('HTTP/1.1 500', e.message) > 0 then
      begin
        pso_result := tsuperobject.create(frestresponse.jsontext);
        if (pso_result['result."status"'].asstring = 'erro') or (pso_result['result."status"'].asstring = 'warning') then
          raise exception.create(pso_result.asjson)
        else
          raise;
      end
      else
        raise;
  end;
end;

procedure txcloud_rest_client.rest_request_on_after_execute(sender: tcustomrestrequest);
begin
  //if frest_request_json_body_itens <> nil then
  //  freeandnil(frest_request_json_body_itens);
end;

end.
