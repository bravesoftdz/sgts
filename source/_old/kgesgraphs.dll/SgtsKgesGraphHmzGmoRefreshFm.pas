unit SgtsKgesGraphHmzGmoRefreshFm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, CheckLst, Menus,
  SgtsKgesGraphPeriodPointsRefreshFm, SgtsCoreIntf;

type
  TSgtsKgesGraphHmzGmoRefreshForm = class(TSgtsKgesGraphPeriodPointsRefreshForm)
  end;

  TSgtsKgesGraphHmzGmoRefreshIface=class(TSgtsKgesGraphPeriodPointsRefreshIface)
  public
    procedure Init; override;
  end;

var
  SgtsKgesGraphHmzGmoRefreshForm: TSgtsKgesGraphHmzGmoRefreshForm;

implementation

uses SgtsConsts, SgtsGraphFm, SgtsKgesGraphsConsts, SgtsProviderConsts,
     SgtsKgesGraphRefreshFm;

{$R *.dfm}

{ TSgtsKgesGraphHmzGmoRefreshIface }

procedure TSgtsKgesGraphHmzGmoRefreshIface.Init;
var
  MetrGroup: Integer;
  TemperatureGroup: Integer;
  ExpenseVolumeGroup: Integer;
begin
  inherited Init;
  FormClass:=TSgtsKgesGraphHmzGmoRefreshForm;
  Caption:='������� �������� �� ����������';
  GraphName:='���������� ���������� �� ����������� ����������';

  MeasureTypes.Add(2602);
  MeasureTypes.Add(2601);
  MeasureTypes.Add(2603);
  MeasureTypes.Add(2604);
  MeasureTypes.Add(2607);

  MetrGroup:=0;
  TemperatureGroup:=1;
  ExpenseVolumeGroup:=2;

  with LeftAxisParams do begin
    Add('pH','PH',-1,true);
    Add('CO2 ��','CO2SV',-1,true);
    Add('CO3(-2)','CO3_2',-1,true);
    Add('CO2 ���','CO2AGG',-1,true);
    Add('����������','ALKALI',-1,true);
    Add('���������','ACERBITY',-1,true);
    Add('Ca(+)','CA',-1,true);
    Add('Mg(+)','MG',-1,true);
    Add('Cl(-)','CL',-1,true);
    Add('SO4(-2)','SO4_2',-1,true);
    Add('HCO3(-)','HCO3',-1,true);
    Add('Na(+)+K(+)','NA_K',-1,true);
    Add('�������������','AGGRESSIV',-1,true);

    Add('������� �������� �����','UVB',MetrGroup);
    Add('������� ������� �����','UNB',MetrGroup);
    Add('���������� ���','UVB_INC');
    Add('����������� �������','T_AIR',TemperatureGroup);
    Add('����������� ������� �� 10 �����','T_AIR_10',TemperatureGroup);
    Add('����������� ������� �� 30 �����','T_AIR_30',TemperatureGroup);
    Add('����������� ���� � ������ �����','T_WATER',TemperatureGroup);
    Add('������� �� �����','RAIN_DAY');
    Add('������� � ������ ����','RAIN_YEAR');
    Add('������� �� ������','RAIN_PERIOD');
    Add('�����','UNSET',ExpenseVolumeGroup);
    Add('������','INFLUX',ExpenseVolumeGroup);
    Add('����� �������������','V_VAULT');
  end;

  with BottomAxisParams do begin
    Add('���� ����������','DATE_OBSERVATION');
    Add('����','CYCLE_NUM');
    CopyFrom(LeftAxisParams,false,false);
  end;

  with RightAxisParams do begin
    CopyFrom(LeftAxisParams);
  end;
end;

{ TSgtsKgesGraphHmzGmoRefreshForm }

end.
