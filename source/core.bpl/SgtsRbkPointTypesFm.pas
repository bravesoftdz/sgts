unit SgtsRbkPointTypesFm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, Menus, ImgList, ExtCtrls, ComCtrls, ToolWin,
  SgtsDataGridFm, SgtsDataFm, SgtsFm, SgtsCDS,
  SgtsCoreIntf, StdCtrls, DBCtrls, Grids, DBGrids;

type
  TSgtsRbkPointTypesForm = class(TSgtsDataGridForm)
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

  TSgtsRbkPointTypesIface=class(TSgtsDataGridIface)
  public
    procedure Init; override;
  end;

var
  SgtsRbkPointTypesForm: TSgtsRbkPointTypesForm;

implementation

uses SgtsProviderConsts, SgtsIface, SgtsConsts, SgtsRbkPointTypeEditFm,
     SgtsSelectDefs;

{$R *.dfm}

{ TSgtsRbkPointTypesIface }

procedure TSgtsRbkPointTypesIface.Init;
begin
  inherited Init;
  FormClass:=TSgtsRbkPointTypesForm;
  InterfaceName:=SInterfacePointTypes;
  InsertClass:=TSgtsRbkPointTypeInsertIface;
  UpdateClass:=TSgtsRbkPointTypeUpdateIface;
  DeleteClass:=TSgtsRbkPointTypeDeleteIface;
  with DataSet do begin
    ProviderName:=SProviderSelectPointTypes;
    with SelectDefs do begin
      AddKey('POINT_TYPE_ID');
      Add('NAME','Наименование');
      AddInvisible('DESCRIPTION');
    end;
  end;
end;

{ TSgtsRbkPointTypesForm }

constructor TSgtsRbkPointTypesForm.Create(ACoreIntf: ISgtsCore);
begin
  inherited Create(ACoreIntf);
end;


end.
