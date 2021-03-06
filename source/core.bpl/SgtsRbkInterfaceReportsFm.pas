unit SgtsRbkInterfaceReportsFm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ImgList, Grids, DBGrids, ExtCtrls, ComCtrls, ToolWin, DB,
  SgtsDataGridFm, SgtsDataFm, SgtsFm, 
  SgtsCoreIntf, StdCtrls;

type
  TSgtsRbkInterfaceReportsForm = class(TSgtsDataGridForm)
  private
    { Private declarations }
  public
    constructor Create(ACoreIntf: ISgtsCore); override;
  end;

  TSgtsRbkInterfaceReportsIface=class(TSgtsDataGridIface)
  public
    procedure Init; override;
    procedure Refresh; override;
  end;

var
  SgtsRbkInterfaceReportsForm: TSgtsRbkInterfaceReportsForm;

implementation

uses DBClient,
     SgtsDbGrid, SgtsCDS, SgtsProviderConsts, SgtsDatabaseCDS,
     SgtsSelectDefs, SgtsRbkInterfaceReportEditFm, SgtsConsts;

{$R *.dfm}

{ TSgtsRbkInterfaceReportsIface }

procedure TSgtsRbkInterfaceReportsIface.Init;
begin
  inherited Init;
  FormClass:=TSgtsRbkInterfaceReportsForm;
  InterfaceName:=SInterfaceInterfaceReports;
  InsertClass:=TSgtsRbkInterfaceReportInsertIface;
  UpdateClass:=TSgtsRbkInterfaceReportUpdateIface;
  DeleteClass:=TSgtsRbkInterfaceReportDeleteIface;
  with DataSet do begin
    ProviderName:=SProviderSelectInterfaceReports;
    with SelectDefs do begin
      AddKey('INTERFACE_REPORT_ID');
      Add('BASE_REPORT_NAME','�����',150);
      Add('INTERFACE','���������',200);
      Add('PRIORITY','������� � ����',40);
      AddInvisible('BASE_REPORT_ID');
    end;
  end;
end;

procedure TSgtsRbkInterfaceReportsIface.Refresh;
begin
  inherited Refresh;
end;

{ TSgtsRbkInterfaceReportForm }

constructor TSgtsRbkInterfaceReportsForm.Create(ACoreIntf: ISgtsCore);
begin
  inherited Create(ACoreIntf);
end;


end.
