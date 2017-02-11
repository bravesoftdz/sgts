unit SgtsKgesGraphPzmGmoRefreshFm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, CheckLst, Menus,
  SgtsKgesGraphPeriodPointsRefreshFm, SgtsCoreIntf;

type
  TSgtsKgesGraphPzmGmoRefreshForm = class(TSgtsKgesGraphPeriodPointsRefreshForm)
  end;

  TSgtsKgesGraphPzmGmoRefreshIface=class(TSgtsKgesGraphPeriodPointsRefreshIface)
  public
    procedure Init; override;
  end;

var
  SgtsKgesGraphPzmGmoRefreshForm: TSgtsKgesGraphPzmGmoRefreshForm;

implementation

uses SgtsConsts, SgtsGraphFm, SgtsKgesGraphsConsts, SgtsProviderConsts,
     SgtsKgesGraphRefreshFm;

{$R *.dfm}

{ TSgtsKgesGraphPzmGmoRefreshIface }

procedure TSgtsKgesGraphPzmGmoRefreshIface.Init;
var
  MetrGroup: Integer;
  TemperatureGroup: Integer;
  ExpenseVolumeGroup: Integer;
  Pressure: Integer;
begin
  inherited Init;
  FormClass:=TSgtsKgesGraphPzmGmoRefreshForm;
  Caption:='������� �������� �� �����������';
  GraphName:='���������� ���������� �� ������������';

  MeasureTypes.Add(2561);
  MeasureTypes.Add(2562);
  MeasureTypes.Add(2563);

  MetrGroup:=0;
  TemperatureGroup:=1;
  ExpenseVolumeGroup:=2;
  Pressure:=3;

  with LeftAxisParams do begin
    Add('������� ������ ���� � ����������','MARK_WATER',-1,true);
    Add('����������� �����','PRESSURE_ACTIVE',Pressure,true);
    Add('�������������� ���������������','PRESSURE_OPPOSE',Pressure,true);
    Add('����������� �����','PRESSURE_BROUGHT',-1,true);
    Add('������� �������� �����','UVB',MetrGroup);
    Add('������� ������� �����','UNB',MetrGroup);
    Add('���������� ���','UVB_INC');
    Add('����������� �������','T_AIR',TemperatureGroup);
    Add('����������� ������� �� 10 �����','T_AIR_10',TemperatureGroup);
    Add('����������� ������� �� 30 �����','T_AIR_30',TemperatureGroup);
    Add('����������� ����','T_WATER',TemperatureGroup);
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

{ TSgtsKgesGraphPzmGmoRefreshForm }

end.
