unit SgtsInterfaceModules;

interface

uses SgtsModules,
     SgtsInterfaceModulesIntf, SgtsCoreIntf, SgtsInterfaceIntf;

type

  TSgtsInterfaceModule=class(TSgtsModule,ISgtsInterfaceModule)
  private
    FInterfaceIntf: ISgtsInterface;
    procedure InitByInterface(AInterfaceIntf: ISgtsInterface);
    function _GetInterface: ISgtsInterface;
  protected
    procedure DoInitProc(AProc: TSgtsInitProc); override;
  public
    constructor Create(ACoreIntf: ISgtsCore); override;
    procedure Init; override;
    procedure BeforeStart; override;
  end;
     
  TSgtsInterfaceModules=class(TSgtsModules,ISgtsInterfaceModules)
  private
    function GetItems(Index: Integer): TSgtsInterfaceModule;
    procedure SetItems(Index: Integer; Value: TSgtsInterfaceModule);
  protected
    function GetModuleClass: TSgtsModuleClass; override;
  public
    property Items[Index: Integer]: TSgtsInterfaceModule read GetItems write SetItems;
  end;

implementation

uses Windows, SysUtils,
     SgtsObj, SgtsConsts, SgtsDialogs;

{ TSgtsInterfaceModule }

constructor TSgtsInterfaceModule.Create(ACoreIntf: ISgtsCore);
begin
  inherited Create(ACoreIntf);
  FInterfaceIntf:=nil;
  InitProcName:=SInitInterfaceProcName;
end;

procedure TSgtsInterfaceModule.Init;
begin
  inherited Init;
  with CoreIntf.Config do begin
  end;
end;

procedure TSgtsInterfaceModule.InitByInterface(AInterfaceIntf: ISgtsInterface);
begin
  FInterfaceIntf:=AInterfaceIntf;
end;

function TSgtsInterfaceModule._GetInterface: ISgtsInterface;
begin
  Result:=FInterfaceIntf;
end;

procedure TSgtsInterfaceModule.DoInitProc(AProc: TSgtsInitProc);
begin
  AProc(CoreIntf,Self as ISgtsInterfaceModule);
end;

procedure TSgtsInterfaceModule.BeforeStart;
begin
  inherited BeforeStart;
  if Assigned(FInterfaceIntf) then begin
    FInterfaceIntf.Start;
  end;
end;

{ TSgtsInterfaceModules }

function TSgtsInterfaceModules.GetItems(Index: Integer): TSgtsInterfaceModule;
begin
  Result:=TSgtsInterfaceModule(inherited Items[Index]);
end;

procedure TSgtsInterfaceModules.SetItems(Index: Integer; Value: TSgtsInterfaceModule);
begin
  inherited Items[Index]:=Value;
end;

function TSgtsInterfaceModules.GetModuleClass: TSgtsModuleClass;
begin
  Result:=TSgtsInterfaceModule;
end;

end.
