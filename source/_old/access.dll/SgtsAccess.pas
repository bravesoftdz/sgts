unit SgtsAccess;

interface

uses
  SgtsDatabaseModulesIntf;

procedure InitByModule(AModuleIntf: ISgtsDatabaseModule); stdcall;

implementation

uses SysUtils, ActiveX,
     SgtsDatabase, SgtsAccessDatabase;

var
  FAccesses: TSgtsDatabases;

procedure InitByModule(AModuleIntf: ISgtsDatabaseModule); stdcall;
begin
  if Assigned(AModuleIntf) then begin
    FAccesses.AddByModule(AModuleIntf,TSgtsAccessDatabase);
  end;
end;

initialization
  CoInitialize(nil);
  FAccesses:=TSgtsDatabases.Create;

finalization
  FreeAndNil(FAccesses);

end.
