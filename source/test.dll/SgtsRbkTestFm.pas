unit SgtsRbkTestFm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, Menus, ImgList, ExtCtrls, ComCtrls, ToolWin, StdCtrls, DBCtrls,
  Grids, DBGrids,
  SgtsDataGridFm, SgtsDataFm, SgtsFm, SgtsCDS,
  SgtsCoreIntf;

type
  TSgtsRbkTestForm = class(TSgtsDataGridForm)
    PanelInfo: TPanel;
    GroupBoxInfo: TGroupBox;
    PanelNote: TPanel;
    DBMemoNote: TDBMemo;
    Splitter: TSplitter;
  private
    { Private declarations }
  public
  end;

  TSgtsRbkTestsIface=class(TSgtsDataGridIface)
  public
    procedure Init; override;
  end;

var
  SgtsRbkTestForm: TSgtsRbkTestForm;

implementation

uses SgtsIface, SgtsConsts, SgtsRbkTestEditFm,
     SgtsSelectDefs;

{$R *.dfm}

{ TSgtsRbkTestsIface }


procedure TSgtsRbkTestsIface.Init;
begin
  inherited Init;
  FormClass:=TSgtsRbkTestForm;
  InterfaceName:='���������� �������� �������';

  InsertClass:=TSgtsRbkTestInsertIface;
  UpdateClass:=TSgtsRbkTestUpdateIface;
  DeleteClass:=TSgtsRbkTestDeleteIface;

  with DataSet do begin
    ProviderName:='S_TEST';
    with SelectDefs do begin
      AddKey('TEST_ID');
      Add('NAME','������������', 20);
      AddInvisible('DESCRIPTION');
    end;
    CheckProvider:=false;
  end;
  MenuPath:=Format(SHandbooksMenu,['������������\�������� ����������']);
  MenuIndex:=1002;
end;


end.
