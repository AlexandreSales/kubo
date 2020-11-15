unit kubo.rest.client.interfaces;

interface

uses
  system.generics.collections,
  kubo.rest.client.types;

type
  ikubo_rest_client_request<t: class> = interface;
  ikubo_rest_client_authentication<t: class> = interface;
  ikubo_rest_client_params<t: class> = interface;

  ikubo_rest_client<t: class> = interface
    ['{D0E551E3-1CEC-4614-A77A-8EAD07A04A8A}']
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

  ikubo_rest_client_authentication<t: class> = interface
     ['{83779F78-B7FA-4980-8E0C-5A59200F0328}']
     function types(const ptype: tkupo_rest_client_authentication_type): ikubo_rest_client_authentication<t>; overload;
     function bearer(const ptoken: string): ikubo_rest_client_authentication<t>; overload;
     function basic(const plogin, ppassword: string): ikubo_rest_client_authentication<t>;
     function types: tkupo_rest_client_authentication_type; overload;
     function token: string;
     function login: string;
     function password: string;
     function &end: ikubo_rest_client<t>;
   end;

  ikubo_rest_client_request<t: class> = interface
    ['{B5EF8ADD-EAD7-4A27-81F6-14316A7E3E6E}']
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

   ikubo_rest_client_param = interface
     ['{FF5675B5-4540-46CD-B2DA-CA5C75BD9FD1}']
     procedure setname(const value: string);
     procedure setresource(const value: string);
     procedure setvalue(const value: variant);
     procedure setkind(const value: tkupo_rest_client_param_kind);

     function getname: string;
     function getresource: string;
     function getvalue: variant;
     function getkind: tkupo_rest_client_param_kind;

     property name: string read getname write setname;
     property resource: string read getresource write setresource;
     property value: variant read getvalue write setvalue;
     property kind: tkupo_rest_client_param_kind read getkind write setkind;
   end;

   ikubo_rest_client_params<t: class> = interface
     ['{33FE100B-30BB-45AF-9A7A-5EBDBA3D8BBB}']
     function add(const pname, presource: string; const pvalue: variant; const pkind: tkupo_rest_client_param_kind): ikubo_rest_client_params<t>;
     function &end: ikubo_rest_client<t>;

     function items(const pindex: integer): ikubo_rest_client_param;
     function count: integer;
   end;

implementation

end.
