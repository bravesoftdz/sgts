unit SgtsRbkCriteriasFm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ImgList, Grids, DBGrids, ExtCtrls, ComCtrls, ToolWin, DB,
  StdCtrls, Mask, DBCtrls,
  SgtsDataGridFm, SgtsDataFm, SgtsFm, SgtsSelectDefs,
  SgtsCoreIntf;

type
  TSgtsRbkCriteriasForm = class(TSgtsDataGridForm)
    PanelInfo: TPanel;
    GroupBoxInfo: TGroupBox;
    PanelNote: TPanel;
    DBMemoNote: TDBMemo;
    Splitter: TSplitter;
  private
    { Private declarations }
  public
    constructor Create(ACoreIntf: ISgtsCore); override;
  end;

  TSgtsRbkCriteriasIface=class(TSgtsDataGridIface)
  public
    procedure Init; override;
  end;

var
  SgtsRbkCriteriasForm: TSgtsRbkCriteriasForm;

implementation

uses DBClient,
     SgtsDbGrid, SgtsCDS, SgtsProviderConsts, SgtsDatabaseCDS,
     SgtsRbkCriteriaEditFm, SgtsConsts, SgtsGetRecordsConfig;

{$R *.dfm}

{ TSgtsRbkCriteriasIface }

procedure TSgtsRbkCriteriasIface.Init;
begin
  inherited Init;
  FormClass:=TSgtsRbkCriteriasForm;
  InterfaceName:=SInterfaceCriterias;
  InsertClass:=TSgtsRbkCriteriaInsertIface;
  UpdateClass:=TSgtsRbkCriteriaUpdateIface;
  DeleteClass:=TSgtsRbkCriteriaDeleteIface;
  with DataSet do begin
    ProviderName:=SProviderSelectCriterias;
    with SelectDefs do begin
      AddKey('CRITERIA_ID');
      Add('NAME','������������',150);
      Add('FIRST_MIN_VALUE','�1 �����������',30);
      Add('SECOND_MIN_VALUE','K2 �����������',30);
      Add('MEASURE_UNIT_NAME','������� ���������',30);
      Add('PRIORITY','�������',30);
      AddInvisible('FIRST_MAX_VALUE');
      AddInvisible('SECOND_MAX_VALUE');
      AddInvisible('DESCRIPTION');
      AddInvisible('ALGORITHM_ID');
      AddInvisible('ALGORITHM_NAME');
      AddInvisible('MEASURE_UNIT_ID');
      AddInvisible('FIRST_MODULO');
      AddInvisible('SECOND_MODULO');
      AddInvisible('ENABLED');
    end;
    Orders.Add('PRIORITY',otAsc);
  end;
end;

{ TSgtsRbkCriteriasForm }

constructor TSgtsRbkCriteriasForm.Create(ACoreIntf: ISgtsCore);
begin
  inherited Create(ACoreIntf);
end;


end.
