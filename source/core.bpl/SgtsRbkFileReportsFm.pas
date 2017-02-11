unit SgtsRbkFileReportsFm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, Menus, ImgList, ExtCtrls, ComCtrls, ToolWin,
  SgtsDataGridFm, SgtsDataFm, SgtsFm, SgtsCDS,
  SgtsCoreIntf, StdCtrls, DBCtrls, Grids, DBGrids;

type
  TSgtsRbkFileReportsForm = class(TSgtsDataGridForm)
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

  TSgtsRbkFileReportsIface=class(TSgtsDataGridIface)
  public
    procedure Init; override;
  end;

var
  SgtsRbkFileReportsForm: TSgtsRbkFileReportsForm;

implementation

uses SgtsProviderConsts, SgtsIface, SgtsConsts, SgtsRbkFileReportEditFm,
     SgtsSelectDefs;

{$R *.dfm}

{ TSgtsRbkFileReportsIface }

procedure TSgtsRbkFileReportsIface.Init;
begin
  inherited Init;
  FormClass:=TSgtsRbkFileReportsForm;
  InterfaceName:=SInterfaceFileReports;
  InsertClass:=TSgtsRbkFileReportInsertIface;
  UpdateClass:=TSgtsRbkFileReportUpdateIface;
  DeleteClass:=TSgtsRbkFileReportDeleteIface;
  with DataSet do begin
    ProviderName:=SProviderSelectFileReports;
    with SelectDefs do begin
      AddKey('FILE_REPORT_ID');
      Add('NAME','������������',100);
      Add('MENU','����',100);
      Add('FILE_NAME','���� ������',250);
      Add('PRIORITY','������� � ����',30);
      AddInvisible('DESCRIPTION');
      AddInvisible('MODULE_NAME');
      AddInvisible('MENU');
    end;
  end;
end;

{ TSgtsRbkFileReportsForm }

constructor TSgtsRbkFileReportsForm.Create(ACoreIntf: ISgtsCore);
begin
  inherited Create(ACoreIntf);
end;


end.