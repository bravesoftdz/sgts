unit SgtsKgesGraphGmoIface;

interface

uses SysUtils,
     SgtsKgesGraphFm, SgtsKgesGraphGmoRefreshFm, SgtsDatabaseCDS, SgtsFm,
     SgtsCoreIntf, SgtsKgesGraphRefreshFm;

type

  TSgtsKgesGraphGmoIface=class(TSgtsKgesGraphIface)
  public
    procedure Init; override;
  end;


implementation

uses SgtsConsts, SgtsGraphFm, SgtsKgesGraphsConsts, SgtsProviderConsts,
     SgtsSelectDefs, SgtsGraphChartFm, SgtsGraphChartSeriesDefs, SgtsObj,
     SgtsIface;

{ TSgtsKgesGraphGmoIface }

procedure TSgtsKgesGraphGmoIface.Init;
begin
  inherited Init;
  InterfaceName:=SInterfaceGraphGmo;
  Caption:='�����������������';
  MenuPath:=Format(SGraphMenu,[Caption]);
  MenuHint:='���������������������� ������ �� ������������ ���1';
  RefreshClass:=TSgtsKgesGraphGmoRefreshIface;
  DataSet.ProviderName:=SProviderSelectGmoJournalObservations;
end;

end.

