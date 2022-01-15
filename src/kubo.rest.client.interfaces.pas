unit kubo.rest.client.interfaces;

interface

uses
  system.generics.collections,
  system.json,
  kubo.rest.client.types;

type
  ikuboRequest<t: class> = interface;
  ikuboAuthentication<t: class> = interface;
  ikuboParams<t: class> = interface;
  ikuboJsonArray<t: class> = interface;
  ikuboJsonObject<t: class> = interface;

  ikubo<t: class> = interface
    ['{D0E551E3-1CEC-4614-A77A-8EAD07A04A8A}']
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
    function get(var objecrResponse: ikuboJsonObject<t>): ikubo<t>; overload;
    function get(var jsonValue: tjsonValue): ikubo<t>; overload;

    function post: ikubo<t>; overload;
    function post(var arrayResponse: ikuboJsonArray<t>): ikubo<t>; overload;
    function post(var objectResponse: ikuboJsonObject<t>): ikubo<t>; overload;

    function put: ikubo<t>; overload;
    function put(var objectResponse: ikuboJsonObject<t>): ikubo<t>; overload;

    function delete: boolean; overload;
    function delete(var objectResponse: ikuboJsonObject<t>): ikubo<t>; overload;
  end;

  ikuboAuthentication<t: class> = interface
     ['{83779F78-B7FA-4980-8E0C-5A59200F0328}']
     function types(const ptype: tkuboAuthenticationType): ikuboAuthentication<t>; overload;
     function bearer(const ptoken: string): ikuboAuthentication<t>; overload;
     function basic(const plogin, ppassword: string): ikuboAuthentication<t>;
     function types: tkuboAuthenticationType; overload;
     function token: string;
     function login: string;
     function password: string;
     function &end: ikubo<t>;
   end;

  ikuboRequest<t: class> = interface
    ['{B5EF8ADD-EAD7-4A27-81F6-14316A7E3E6E}']
    function uri(const puri: string): ikuboRequest<t>; overload;
    function resource(const presource: string): ikuboRequest<t>; overload;
    function accept(const paccept: string): ikuboRequest<t>; overload;
    function charset(const pcharset: string): ikuboRequest<t>; overload;
    function uri: string; overload;
    function resource: string; overload;
    function accept: string; overload;
    function charset: string; overload;
    function &end: ikubo<t>;
   end;

   ikuboParam = interface
     ['{FF5675B5-4540-46CD-B2DA-CA5C75BD9FD1}']
     procedure setname(const value: string);
     procedure setresource(const value: string);
     procedure setvalue(const value: variant);
     procedure setkind(const value: tkuboParamKind);

     function getname: string;
     function getresource: string;
     function getvalue: variant;
     function getkind: tkuboParamKind;

     property name: string read getname write setname;
     property resource: string read getresource write setresource;
     property value: variant read getvalue write setvalue;
     property kind: tkuboParamKind read getkind write setkind;
   end;

   ikuboParams<t: class> = interface
     ['{33FE100B-30BB-45AF-9A7A-5EBDBA3D8BBB}']
     function add(const pname, presource: string; const pvalue: variant; const pkind: tkuboParamKind): ikuboParams<t>;
     function &end: ikubo<t>;

     function items(const pindex: integer): ikuboParam;
     function count: integer;
   end;

   ikuboJsonObject<t: class> = interface
     ['{686DF6FA-2A5A-4FB4-B367-7AD50AA3B71D}']
     function GetValue: T;
     function GetAsJson: String;
     procedure SetAsJson(aValue: String);
     procedure FreeValue;

     property AsJson: String read GetAsJson write SetAsJson;
     property value: T read GetValue;
   end;

   ikuboJsonArray<t: class> = Interface
    ['{2837FF80-EC33-48E7-8E81-AFFF61E7F6A0}']
    function GetAsJson: String;
    function GetItems: TObjectList<T>;
    procedure SetAsJson(aValue: String);

    property AsJson: String read GetAsJson write SetAsJson;
    property Items: TObjectList<T> read GetItems;
  end;

implementation

end.
