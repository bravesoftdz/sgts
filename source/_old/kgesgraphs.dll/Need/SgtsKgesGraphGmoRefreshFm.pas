unit SgtsKgesGraphGmoRefreshFm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, CheckLst, Menus,
  SgtsKgesGraphPeriodRefreshFm;

type
  TSgtsKgesGraphGmoRefreshForm = class(TSgtsKgesGraphPeriodRefreshForm)
  public
    constructor Create(ACoreIntf: ISgtsCore); override;
  end;

  TSgtsKgesGraphGmoRefreshIface=class(TSgtsKgesGraphRefreshIface)
  private
    FMetrGroup: Integer;
    FTemperatureGroup: Integer;
    FExpenseVolumeGroup: Integer;
  public
    procedure Init; override;
  end;

var
  SgtsKgesGraphGmoRefreshForm: TSgtsKgesGraphGmoRefreshForm;

implementation

uses SgtsConsts, SgtsGraphFm, SgtsKgesGraphsConsts, SgtsProviderConsts,
     SgtsSelectDefs;

{$R *.dfm}

{ TSgtsKgesGraphGmoRefreshIface }

procedure TSgtsKgesGraphGmoRefreshIface.Init;
begin
  inherited Init;
  FormClass:=TSgtsKgesGraphGmoRefreshForm;
  InterfaceName:=SInterfaceGraphGmoRefresh;

  FMetrGroup:=0;
  FTemperatureGroup:=1;
  FExpenseVolumeGroup:=2;

  with LeftAxisParams do begin
    Add('������� �������� �����','UVB',FMetrGroup);
    Add('������� ������� �����','UNB',FMetrGroup);
    Add('���������� ���','UVB_INC');
    Add('����������� �������','T_AIR',FTemperatureGroup);
    Add('����������� ������� �� 10 �����','T_AIR_10',FTemperatureGroup);
    Add('����������� ������� �� 30 �����','T_AIR_30',FTemperatureGroup);
    Add('����������� ����','T_WATER',FTemperatureGroup);
    Add('������� �� �����','RAIN_DAY');
    Add('������� � ������ ����','RAIN_YEAR');
    Add('������� �� ������','RAIN_PERIOD');
    Add('�����','UNSET',FExpenseVolumeGroup);
    Add('������','INFLUX',FExpenseVolumeGroup);
    Add('����� �������������','V_VAULT');
  end;

  with BottomAxisParams do begin
    Add('���� ����������','DATE_OBSERVATION');
    Add('����','CYCLE_NUM');
  end;

  RightAxisParams.CopyFrom(LeftAxisParams);
end;

{ TSgtsKgesGraphGmoRefreshForm }

constructor TSgtsKgesGraphGmoRefreshForm.Create(ACoreIntf: ISgtsCore);
begin
  inherited Create(ACoreIntf);

end;

end.
