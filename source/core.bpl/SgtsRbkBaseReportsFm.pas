unit SgtsRbkBaseReportsFm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, Menus, ImgList, ExtCtrls, ComCtrls, ToolWin,
  SgtsDataGridFm, SgtsDataFm, SgtsFm, SgtsCDS,
  SgtsCoreIntf, StdCtrls, DBCtrls, Grids, DBGrids;

type
  TSgtsRbkBaseReportsForm = class(TSgtsDataGridForm)
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

  TSgtsRbkBaseReportsIface=class(TSgtsDataGridIface)
  public
    procedure Init; override;
  end;

var
  SgtsRbkBaseReportsForm: TSgtsRbkBaseReportsForm;

implementation

uses SgtsProviderConsts, SgtsIface, SgtsConsts, SgtsRbkBaseReportEditFm,
     SgtsSelectDefs, SgtsDatabaseCDS, SgtsGetRecordsConfig;

{$R *.dfm}

{ TSgtsRbkBaseReportsIface }

procedure TSgtsRbkBaseReportsIface.Init;
begin
  inherited Init;
  FormClass:=TSgtsRbkBaseReportsForm;
  InterfaceName:=SInterfaceBaseReports;
  InsertClass:=TSgtsRbkBaseReportInsertIface;
  UpdateClass:=TSgtsRbkBaseReportUpdateIface;
  DeleteClass:=TSgtsRbkBaseReportDeleteIface;
  with DataSet do begin
    ProviderName:=SProviderSelectBaseReports;
    with SelectDefs do begin
      AddKey('BASE_REPORT_ID');
      Add('NAME','������������',100);
      Add('MENU','����',100);
      Add('PRIORITY','������� � ����',30);
      AddInvisible('DESCRIPTION');
      AddInvisible('REPORT');
    end;
    Orders.Add('NAME',otAsc);
  end;
end;

{ TSgtsRbkBaseReportsForm }

constructor TSgtsRbkBaseReportsForm.Create(ACoreIntf: ISgtsCore);
begin
  inherited Create(ACoreIntf);
end;


end.
