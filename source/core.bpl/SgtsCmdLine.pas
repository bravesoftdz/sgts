unit SgtsCmdLine;

interface

uses SgtsCoreObj,
     SgtsCmdLineIntf;

type

  TSgtsCmdLine=class(TSgtsCoreObj,ISgtsCmdLine)
  private
    function _GetFileName: String;
    function GetText: String;
  public
    function ParamExists(const Param: String): Boolean;
    function ValueByParam(const Param: String; Index: Integer=0): String;

    property FileName: String read _GetFileName;
    property Text: String read GetText; 
  end;

implementation

uses SysUtils;

{ TSgtsCmdLine }

function TSgtsCmdLine.ParamExists(const Param: String): Boolean; 
begin
  Result:=FindCmdLineSwitch(Param);
end;

function TSgtsCmdLine.ValueByParam(const Param: String; Index: Integer=0): String;
var
  i: Integer;
  ParamExists: Boolean;
  S: string;
  Chars: TSysCharSet;
  Incr: Integer;  
begin
  ParamExists:=false;
  Chars:=SwitchChars;
  Incr:=1;
  for i:=1 to ParamCount do begin
    S:=ParamStr(i);
    if (Chars = []) or (S[1] in Chars) then begin
      if (AnsiCompareText(Copy(S, 2, Maxint), Param) = 0) then begin
        ParamExists:=True;
      end;
    end else begin
      if ParamExists then begin
        if Incr=(Index+1) then begin
          Result:=S;
          exit;
        end;  
        Inc(Incr);
      end;
    end;  
  end;
end;

function TSgtsCmdLine._GetFileName: String;
begin
  Result:=ParamStr(0);
end;

function TSgtsCmdLine.GetText: String;
begin
  Result:=CmdLine;
end;

end.
