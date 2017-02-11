unit SgtsKgesGraphGmoRefreshFm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, CheckLst, Menus,
  SgtsKgesGraphPeriodRefreshFm, SgtsCoreIntf;

type
  TSgtsKgesGraphGmoRefreshForm = class(TSgtsKgesGraphPeriodRefreshForm)
  public
    constructor Create(ACoreIntf: ISgtsCore); override;
  end;

  TSgtsKgesGraphGmoRefreshIface=class(TSgtsKgesGraphPeriodRefreshIface)
  public
    procedure Init; override;
  end;

var
  SgtsKgesGraphGmoRefreshForm: TSgtsKgesGraphGmoRefreshForm;

implementation

uses SgtsConsts, SgtsGraphFm, SgtsKgesGraphsConsts, SgtsProviderConsts,
     SgtsKgesGraphRefreshFm;

{$R *.dfm}

{ TSgtsKgesGraphGmoRefreshIface }

procedure TSgtsKgesGraphGmoRefreshIface.Init;
var
  MetrGroup: Integer;
  TemperatureGroup: Integer;
  ExpenseVolumeGroup: Integer;
begin
  inherited Init;
  FormClass:=TSgtsKgesGraphGmoRefreshForm;
  Caption:='������� �������� �� �����������������';
  GraphName:='���������������������� ������ �� ������������ ���';

  MetrGroup:=0;
  TemperatureGroup:=1;
  ExpenseVolumeGroup:=2;

  with LeftAxisParams do begin
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
    Add('����','CYCLE_NUM').XMerging:=false;
    CopyFrom(LeftAxisParams,false,false);
  end;

  RightAxisParams.CopyFrom(LeftAxisParams);
end;

{ TSgtsKgesGraphGmoRefreshForm }

constructor TSgtsKgesGraphGmoRefreshForm.Create(ACoreIntf: ISgtsCore);
begin
  inherited Create(ACoreIntf);

end;

end.
