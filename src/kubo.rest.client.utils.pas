unit kubo.rest.client.utils;

interface

uses
  system.sysutils;

  function iif(condition: boolean; const ptruevalue: variant; const pfalsevalue: variant): variant;
  function unquoted(const pstr_value: string): string;

implementation

  function iif(condition: boolean; const ptruevalue: variant; const pfalsevalue: variant): variant;
  begin
   if condition then
      result := ptruevalue
   else
      result := pfalsevalue;
  end;

  function unquoted(const pstr_value: string): string;
  var
    lstr_result : string;
  begin
    lstr_result :=  pstr_value;
    if trim(lstr_result) <> '' then
    begin
      {$IFDEF IOS}
        if lstr_result[1] = '"' then
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

end.
