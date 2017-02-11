unit SgtsRbkPermissionFm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ImgList, Grids, DBGrids, ExtCtrls, ComCtrls, ToolWin, DB,
  SgtsDataGridFm, SgtsDataFm, SgtsFm, 
  SgtsCoreIntf, StdCtrls;

type
  TSgtsRbkPermissionForm = class(TSgtsDataGridForm)
  private
    { Private declarations }
  public
    constructor Create(ACoreIntf: ISgtsCore); override;
  end;

  TSgtsRbkPermissionIface=class(TSgtsDataGridIface)
  public
    procedure Init; override;
  end;

var
  SgtsRbkPermissionForm: TSgtsRbkPermissionForm;

implementation

uses DBClient,
     SgtsDbGrid, SgtsCDS, SgtsProviderConsts, SgtsDatabaseCDS,
     SgtsSelectDefs, SgtsRbkPermissionEditFm, SgtsConsts;

{$R *.dfm}

{ TSgtsRbkPermissionIface }

procedure TSgtsRbkPermissionIface.Init;
begin
  inherited Init;
  FormClass:=TSgtsRbkPermissionForm;
  InterfaceName:=SInterfacePermission;
  InsertClass:=TSgtsRbkPermissionInsertIface;
  UpdateClass:=TSgtsRbkPermissionUpdateIface;
  DeleteClass:=TSgtsRbkPermissionDeleteIface;
  with DataSet do begin
    ProviderName:=SProviderSelectPermissions;
    with SelectDefs do begin
      AddKey('PERMISSION_ID');
      Add('ACCOUNT_NAME','������� ������ (����)',100);
      Add('INTERFACE','���������',230);
      Add('PERMISSION','�����',120);
      Add('PERMISSION_VALUE','��������',70);
      AddInvisible('ACCOUNT_ID');
    end;
  end;
end;

{ TSgtsRbkPermissionForm }

constructor TSgtsRbkPermissionForm.Create(ACoreIntf: ISgtsCore);
begin
  inherited Create(ACoreIntf);
end;


end.
