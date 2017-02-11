unit SgtsKgesImportInterface;

interface

uses Classes,
     SgtsCoreIntf, SgtsInterfaceModulesIntf,
     SgtsInterface, SgtsMenus,
     SgtsKgesASQImportFm;

type

  TSgtsKgesImportInterface=class(TSgtsInterface)
  private
    FASQImportIface: TSgtsKgesASQImportIface;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure InitByModule(ACoreIntf: ISgtsCore; AModuleIntf: ISgtsInterfaceModule); override;
    procedure Start; override;
  end;


implementation

uses SgtsDialogs, SgtsCoreObj;

{ TSgtsKgesImportInterface }

constructor TSgtsKgesImportInterface.Create;
begin
  inherited Create;
  FASQImportIface:=TSgtsKgesASQImportIface.Create(nil);
end;

destructor TSgtsKgesImportInterface.Destroy;
begin
  FASQImportIface.Free;
  inherited Destroy;
end;

procedure TSgtsKgesImportInterface.InitByModule(ACoreIntf: ISgtsCore; AModuleIntf: ISgtsInterfaceModule);

  procedure InitByModuleLocal(Obj: TSgtsCoreObj);
  begin
    Obj.CoreIntf:=ACoreIntf;
    ACoreIntf.RegisterObj(Obj);
  end;

begin
  inherited InitByModule(ACoreIntf,AModuleIntf);
  if Assigned(ACoreIntf) then begin
    InitByModuleLocal(FASQImportIface);
  end;
end;

procedure TSgtsKgesImportInterface.Start;
begin
  if Assigned(CoreIntf) then begin
    // 
  end;
end;

end.
