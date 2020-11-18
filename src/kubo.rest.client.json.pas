unit kubo.rest.client.json;

interface

uses
  system.sysutils,
  system.generics.collections,
  system.json,
  system.jsonconsts,
  rest.json,
  rest.json.types,
  rest.jsonreflect,
  kubo.json.objects,
  kubo.rest.client.interfaces;

type

  Tkubo_rest_client_json_object_array<T: Class> = Class(TInterfacedObject, ikubo_rest_client_json_object_array<T>)
  private
    {private declarations}
    FOptions: TJsonOptions;

    [JSONName('Items')]
    FItemsArray: TArray<T>;

    [GenericListReflect]
    FItems: TObjectList<T>;

    function GetItems: TObjectList<T>;
    function GetAsJson: String;
    procedure SetAsJson(aValue: String);
  protected
    {protected declarations}
     property AsJson: string read GetAsJson write SetAsJson;
  published
    {published delcarations}
    constructor Create;
    destructor Destroy; override;

    property Items: TObjectList<T> read GetItems;
  end;

  Tkubo_rest_client_json_object<T: Class, Constructor> = Class(TInterfacedObject, ikubo_rest_client_json_object<T>)
  private
    {private delcarations}
    FOptions: TJsonOptions;
    FValue: T;

    function GetValue: T;
    function GetAsJson: String;
    procedure SetAsJson(aValue: String);
  protected
    {protected declarations}
     property AsJson: string read GetAsJson write SetAsJson;
  public
    {public declarations}
    constructor Create;
    destructor Destroy; override;

    property Value: T read GetValue;
  end;

implementation



{ Tkubo_rest_client_json_array<T> }

constructor Tkubo_rest_client_json_object_array<T>.create;
begin
  foptions := [jodateisutc, jodateformatiso8601];
end;

destructor Tkubo_rest_client_json_object_array<T>.destroy;
begin
  getitems.free;
  inherited;
end;

function Tkubo_rest_client_json_object_array<T>.getasjson: string;
begin
  result := rest.json.tjson.objecttojsonstring(self, foptions);
end;

function Tkubo_rest_client_json_object_array<T>.getitems: tobjectlist<T>;
begin
  if not assigned(fitems) then
  begin
    fitems := tobjectlist<T>.create;
    fitems.addrange(fitemsarray);
  end;

  result := fitems;
end;

procedure Tkubo_rest_client_json_object_array<T>.setasjson(aValue: string);
var
  JsonValue: TJSONValue;
  JsonObject: TJSONObject;
begin
  JsonValue := TJSONObject.ParseJSONValue(aValue);
  try
    if not Assigned(JsonValue) then
      Exit;

    if (JsonValue is TJSONArray) then
    begin
      with TJSONUnMarshal.Create do
        try
          SetFieldArray(Self, 'Items', (JsonValue as TJSONArray));
        finally
          Free;
        end;

      exit;
    end;

    if (JsonValue is TJSONObject) then
      JsonObject := JsonValue as TJSONObject
    else
    begin
      aValue := aValue.Trim;
      if (aValue = '') and not Assigned(JsonValue) or (aValue <> '') and Assigned(JsonValue) and JsonValue.Null then
        Exit
      else
        raise EConversionError.Create(SCannotCreateObject);
    end;

    Rest.Json.TJson.JsonToObject(Self, JsonObject, FOptions);
  finally
    JsonValue.Free;
  end;
end;

{ Tkubo_rest_client_json_object<T> }

constructor Tkubo_rest_client_json_object<T>.Create;
begin
  foptions := [jodateisutc, jodateformatiso8601];
end;

destructor Tkubo_rest_client_json_object<T>.Destroy;
begin
  GetValue.Free;
  inherited;
end;

function Tkubo_rest_client_json_object<T>.GetAsJson: String;
begin
  result := Rest.Json.TJson.ObjectToJsonString(Self, FOptions);
end;

function Tkubo_rest_client_json_object<T>.GetValue: T;
begin
  Result := FValue;
end;

procedure Tkubo_rest_client_json_object<T>.SetAsJson(aValue: String);
var
  JsonValue: TJSONValue;
  JsonObject: TJSONObject;
begin
  JsonValue := TJSONObject.ParseJSONValue(aValue);
  try
    if not Assigned(JsonValue) then
      Exit;

    if (JsonValue is TJSONArray) then
    begin
      with TJSONUnMarshal.Create do
        try
          SetFieldArray(Self, 'Items', (JsonValue as TJSONArray));
        finally
          Free;
        end;

      exit;
    end;

    if (JsonValue is TJSONObject) then
      JsonObject := JsonValue as TJSONObject
    else
    begin
      aValue := aValue.Trim;
      if (aValue = '') and not Assigned(JsonValue) or (aValue <> '') and Assigned(JsonValue) and JsonValue.Null then
        Exit
      else
        raise EConversionError.Create(SCannotCreateObject);
    end;

    if FValue = nil then
      FValue := T.Create;

    TObject(FValue).AssignFromJSON(aValue);
  finally
    JsonValue.Free;
  end;
end;

end.