unit SgtsRbkAccountsFm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ImgList, Grids, DBGrids, ExtCtrls, ComCtrls, ToolWin, DB, StdCtrls,
  SgtsDataGridFm, SgtsDataFm, SgtsFm,
  SgtsCoreIntf;

type
  TSgtsRbkAccountsForm = class(TSgtsDataGridForm)
  private
    { Private declarations }
  public
    constructor Create(ACoreIntf: ISgtsCore); override;
  end;

  TSgtsRbkAccountsIface=class(TSgtsDataGridIface)
  public
    procedure Init; override;
  end;

var
  SgtsRbkAccountsForm: TSgtsRbkAccountsForm;

implementation

uses DBClient,
     SgtsDbGrid, SgtsCDS, SgtsProviderConsts, SgtsDatabaseCDS,
     SgtsSelectDefs, SgtsRbkAccountEditFm, SgtsConsts, SgtsGetRecordsConfig;

{$R *.dfm}

{ TSgtsRbkAccountsIface }

procedure TSgtsRbkAccountsIface.Init;
begin
  inherited Init;
  FormClass:=TSgtsRbkAccountsForm;
  InterfaceName:=SInterfaceAccounts;
  InsertClass:=TSgtsRbkAccountInsertIface;
  UpdateClass:=TSgtsRbkAccountUpdateIface;
  DeleteClass:=TSgtsRbkAccountDeleteIface;
  with DataSet do begin
    ProviderName:=SProviderSelectAccounts;
    with SelectDefs do begin
      AddKey('ACCOUNT_ID');
      Add('NAME','Наименование',150);
      Add('PERSONNEL_NAME','Персона',200);
      AddInvisible('IS_ROLE');
      AddInvisible('PERSONNEL_ID');
      AddInvisible('PASS');
      AddInvisible('ADJUSTMENT');
    end;
    Orders.Add('NAME',otAsc);
  end;
end;

{ TSgtsRbkAccountsForm }

constructor TSgtsRbkAccountsForm.Create(ACoreIntf: ISgtsCore);
begin
  inherited Create(ACoreIntf);
end;


end.
