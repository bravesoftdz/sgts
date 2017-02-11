unit SgtsGraphTestIface;

interface

uses SgtsGraphChartFm;

type

  TSgtsGraphTestIface=class(TSgtsGraphChartIface)
  public
    procedure Init; override;
  end;

implementation

uses SysUtils,
     SgtsConsts, SgtsGraphFm, SgtsGraphTestRefreshFm;

{ TSgtsGraphTestIface }

procedure TSgtsGraphTestIface.Init; 
begin
  inherited Init;
  InterfaceName:='���� �������';
  MenuPath:=Format(SGraphsMenu,[InterfaceName]);
  RefreshClass:=TSgtsGraphTestRefreshIface;
end;

end.
