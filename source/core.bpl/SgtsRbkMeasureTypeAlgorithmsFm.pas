unit SgtsRbkMeasureTypeAlgorithmsFm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ImgList, Grids, DBGrids, ExtCtrls, ComCtrls, ToolWin, DB,
  SgtsDataGridFm, SgtsDataFm, SgtsFm, 
  SgtsCoreIntf, StdCtrls;

type
  TSgtsRbkMeasureTypeAlgorithmsForm = class(TSgtsDataGridForm)
  private
    { Private declarations }
  public
    constructor Create(ACoreIntf: ISgtsCore); override;
  end;

  TSgtsRbkMeasureTypeAlgorithmsIface=class(TSgtsDataGridIface)
  public
    procedure Init; override;
  end;

var
  SgtsRbkMeasureTypeAlgorithmsForm: TSgtsRbkMeasureTypeAlgorithmsForm;

implementation

uses DBClient,
     SgtsDbGrid, SgtsCDS, SgtsProviderConsts, SgtsDatabaseCDS,
     SgtsSelectDefs, SgtsRbkMeasureTypeAlgorithmEditFm, SgtsConsts;

{$R *.dfm}

{ TSgtsRbkMeasureTypeAlgorithmsIface }

procedure TSgtsRbkMeasureTypeAlgorithmsIface.Init;
begin
  inherited Init;
  FormClass:=TSgtsRbkMeasureTypeAlgorithmsForm;
  InterfaceName:=SInterfaceMeasureTypeAlgorithms;
  InsertClass:=TSgtsRbkMeasureTypeAlgorithmInsertIface;
  UpdateClass:=TSgtsRbkMeasureTypeAlgorithmUpdateIface;
  DeleteClass:=TSgtsRbkMeasureTypeAlgorithmDeleteIface;
  with DataSet do begin
    ProviderName:=SProviderSelectMeasureTypeAlgorithms;
    with SelectDefs do begin
      AddInvisible('MEASURE_TYPE_ID');
      AddInvisible('ALGORITHM_ID');
      Add('MEASURE_TYPE_NAME','��� ���������',150);
      Add('ALGORITHM_NAME','��������',100);
      Add('PRIORITY','�������',40);
      Add('DATE_BEGIN','���� ������',60);
      Add('DATE_END','���� ���������',60);
    end;
  end;
end;

{ TSgtsRbkMeasureTypeAlgorithmsForm }

constructor TSgtsRbkMeasureTypeAlgorithmsForm.Create(ACoreIntf: ISgtsCore);
begin
  inherited Create(ACoreIntf);
end;


end.
