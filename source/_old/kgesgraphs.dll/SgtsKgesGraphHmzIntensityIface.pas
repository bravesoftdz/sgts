unit SgtsKgesGraphHmzIntensityIface;

interface

uses SysUtils,
     SgtsKgesGraphPeriodIface;

type

  TSgtsKgesGraphHmzIntensityIface=class(TSgtsKgesGraphPeriodIface)
  public
    procedure Init; override;
  end;


implementation

uses SgtsConsts, SgtsKgesGraphsConsts, SgtsProviderConsts,
     SgtsKgesGraphHmzIntensityRefreshFm;

{ TSgtsKgesGraphHmzIntensityIface }

procedure TSgtsKgesGraphHmzIntensityIface.Init;
begin
  inherited Init;
  InterfaceName:=SInterfaceGraphHmzIntensity;
  RefreshClass:=TSgtsKgesGraphHmzIntensityRefreshIface;
  ProviderName:=SProviderSelectHmzIntensity;
  MenuIndex:=1;
  MenuPath:=Format(SGraphMenu,['���������\������������� ������ �������']);
  Caption:='���������. ������������� ������ �������';
end;

end.

