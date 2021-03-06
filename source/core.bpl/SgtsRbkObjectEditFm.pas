unit SgtsRbkObjectEditFm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ToolWin, ImgList, Menus, ExtCtrls, StdCtrls, DB,
  SgtsDataEditFm, SgtsDataInsertFm, SgtsDataUpdateFm, SgtsDataDelete,
  SgtsFm, SgtsControls;

type
  TSgtsRbkObjectEditForm = class(TSgtsDataEditForm)
    LabelName: TLabel;
    EditName: TEdit;
    MemoNote: TMemo;
    LabelNote: TLabel;
    LabelShortName: TLabel;
    EditShortName: TEdit;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  TSgtsRbkObjectInsertIface=class(TSgtsDataInsertIface)
  public
    procedure Init; override;
  end;

  TSgtsRbkObjectUpdateIface=class(TSgtsDataUpdateIface)
  public
    procedure Init; override;
  end;

  TSgtsRbkObjectDeleteIface=class(TSgtsDataDeleteIface)
  public
    procedure Init; override;
  end;
  
var
  SgtsRbkObjectEditForm: TSgtsRbkObjectEditForm;

implementation

uses DBClient,
     SgtsIface, SgtsConsts, SgtsProviderConsts,
     SgtsDatabaseCDS, SgtsDialogs, SgtsExecuteDefs;

{$R *.dfm}

{ TSgtsRbkObjectInsertIface }

procedure TSgtsRbkObjectInsertIface.Init;
begin
  inherited Init;
  FormClass:=TSgtsRbkObjectEditForm;
  InterfaceName:=SInterfaceObjectInsert;
  with DataSet do begin
    ProviderName:=SProviderInsertObject;
    with ExecuteDefs do begin
      AddKey('OBJECT_ID');
      AddEdit('NAME','EditName','LabelName',true);
      AddEdit('SHORT_NAME','EditShortName','LabelShortName',false);
      AddMemo('DESCRIPTION','MemoNote','LabelNote',false);
    end;
  end;
end;

{ TSgtsRbkObjectUpdateIface }

procedure TSgtsRbkObjectUpdateIface.Init;
begin
  inherited Init;
  FormClass:=TSgtsRbkObjectEditForm;
  InterfaceName:=SInterfaceObjectUpdate;
  with DataSet do begin
    ProviderName:=SProviderUpdateObject;
    with ExecuteDefs do begin
      AddKeyLink('OBJECT_ID');
      AddEdit('NAME','EditName','LabelName',true);
      AddEdit('SHORT_NAME','EditShortName','LabelShortName',false);
      AddMemo('DESCRIPTION','MemoNote','LabelNote',false);
    end;
  end;
end;

{ TSgtsRbkObjectDeleteIface }

procedure TSgtsRbkObjectDeleteIface.Init;
begin
  inherited Init;
  InterfaceName:=SInterfaceObjectDelete;
  DeleteQuestion:='������� ������ %NAME?';
  with DataSet do begin
    ProviderName:=SProviderDeleteObject;
    with ExecuteDefs do begin
      AddKeyLink('OBJECT_ID');
      AddInvisible('NAME').ParamType:=ptUnknown;
    end;
  end;
end;

{ TSgtsRbkInsertObjectForm }

end.
