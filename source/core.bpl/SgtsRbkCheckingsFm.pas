unit SgtsRbkCheckingsFm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ImgList, Grids, DBGrids, ExtCtrls, ComCtrls, ToolWin, DB,
  StdCtrls, Mask, DBCtrls,
  SgtsDataGridFm, SgtsDataFm, SgtsFm, SgtsSelectDefs,
  SgtsCoreIntf;

type
  TSgtsRbkCheckingsForm = class(TSgtsDataGridForm)
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

  TSgtsRbkCheckingsIface=class(TSgtsDataGridIface)
  public
    procedure Init; override;
  end;

var
  SgtsRbkCheckingsForm: TSgtsRbkCheckingsForm;

implementation

uses DBClient,
     SgtsDbGrid, SgtsCDS, SgtsProviderConsts, SgtsDatabaseCDS,
     SgtsRbkCheckingEditFm, SgtsConsts, SgtsGetRecordsConfig;

{$R *.dfm}

{ TSgtsRbkCheckingsIface }

procedure TSgtsRbkCheckingsIface.Init;
begin
  inherited Init;
  FormClass:=TSgtsRbkCheckingsForm;
  InterfaceName:=SInterfaceCheckings;
  InsertClass:=TSgtsRbkCheckingInsertIface;
  UpdateClass:=TSgtsRbkCheckingUpdateIface;
  DeleteClass:=TSgtsRbkCheckingDeleteIface;
  with DataSet do begin
    ProviderName:=SProviderSelectCheckings;
    with SelectDefs do begin
      AddKey('CHECKING_ID');
      Add('MEASURE_TYPE_PATH','��� ���������',100);
      Add('POINT_NAME','������������� �����',60);
      Add('PARAM_NAME','��������',100);
      Add('NAME','������������',120);
      Add('PRIORITY','�������',40);
      AddInvisible('MEASURE_TYPE_ID');
      AddInvisible('POINT_ID');
      AddInvisible('PARAM_ID');
      AddInvisible('DESCRIPTION');
      AddInvisible('ALGORITHM_ID');
      AddInvisible('ALGORITHM_NAME');
      AddInvisible('ENABLED');
    end;
    Orders.Add('MEASURE_TYPE_PATH',otAsc);
    Orders.Add('PRIORITY',otAsc);
  end;
end;

{ TSgtsRbkCheckingsForm }

constructor TSgtsRbkCheckingsForm.Create(ACoreIntf: ISgtsCore);
begin
  inherited Create(ACoreIntf);
end;


end.
