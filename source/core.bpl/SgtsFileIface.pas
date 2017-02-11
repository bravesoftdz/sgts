unit SgtsFileIface;

interface

uses Windows,
     SgtsIface;

type

  TSgtsFileIface=class(TSgtsIface)
  private
    FFileName: String;
    function PrepareFileName: String;
  public
    procedure Init; override;
    function CanShow: Boolean; override;
    procedure Show; override;

    property FileName: String read FFileName write FFileName;
  end;

implementation

uses SysUtils, ShellApi;

{ TSgtsFileIface }

procedure TSgtsFileIface.Init;
begin
  inherited Init;
end;

function TSgtsFileIface.PrepareFileName: String;
begin
  Result:=FFileName;
  if not FileExists(Result) and Assigned(CoreIntf) then
    Result:=ExtractFilePath(CoreIntf.CmdLine.FileName)+Result;
end;

function TSgtsFileIface.CanShow: Boolean;
begin
  Result:=inherited CanShow;
  if Result then begin
    Result:=FileExists(PrepareFileName);
  end;
end;

procedure TSgtsFileIface.Show;
var
  S: String;
begin
  if CanShow then begin
    S:=PrepareFileName;
    ShellExecute(0,'open',PChar(S),nil,nil,SW_SHOW);
  end;
end;

end.
