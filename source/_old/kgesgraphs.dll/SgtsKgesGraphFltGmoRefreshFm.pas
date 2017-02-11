unit SgtsKgesGraphFltGmoRefreshFm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, CheckLst, Menus,
  SgtsKgesGraphPeriodPointsRefreshFm, SgtsCoreIntf;

type
  TSgtsKgesGraphFltGmoRefreshForm = class(TSgtsKgesGraphPeriodPointsRefreshForm)
  end;

  TSgtsKgesGraphFltGmoRefreshIface=class(TSgtsKgesGraphPeriodPointsRefreshIface)
  public
    procedure Init; override;
  end;

var
  SgtsKgesGraphFltGmoRefreshForm: TSgtsKgesGraphFltGmoRefreshForm;

implementation

uses SgtsConsts, SgtsGraphFm, SgtsKgesGraphsConsts, SgtsProviderConsts,
     SgtsKgesGraphRefreshFm;

{$R *.dfm}

{ TSgtsKgesGraphFltGmoRefreshIface }

procedure TSgtsKgesGraphFltGmoRefreshIface.Init;
var
  MetrGroup: Integer;
  TemperatureGroup: Integer;
  ExpenseVolumeGroup: Integer;
begin
  inherited Init;
  FormClass:=TSgtsKgesGraphFltGmoRefreshForm;
  Caption:='������� �������� �� ����������';
  GraphName:='���������� ���������� �� ��������������� ���������';

  MeasureTypes.Add(2581);
  MeasureTypes.Add(2582);
  MeasureTypes.Add(2583);
  MeasureTypes.Add(2584);
  MeasureTypes.Add(2585);
  MeasureTypes.Add(2626);

  MetrGroup:=0;
  TemperatureGroup:=1;
  ExpenseVolumeGroup:=2;

  with LeftAxisParams do begin
    Add('���������� �����','VOLUME',-1,true);
    Add('����� ������','TIME',-1,true);
    Add('������','EXPENSE',-1,true);
    Add('����������� ����','T_WATER',-1,true);

    Add('������� �������� �����','UVB',MetrGroup);
    Add('������� ������� �����','UNB',MetrGroup);
    Add('���������� ���','UVB_INC');
    Add('����������� �������','T_AIR',TemperatureGroup);
    Add('����������� ������� �� 10 �����','T_AIR_10',TemperatureGroup);
    Add('����������� ������� �� 30 �����','T_AIR_30',TemperatureGroup);
    Add('����������� ���� � ������ �����','GMO_T_WATER',TemperatureGroup);
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

{ TSgtsKgesGraphFltGmoRefreshForm }

end.
