unit SgtsRbkDefectViewEditFm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ToolWin, ImgList, Menus, ExtCtrls, StdCtrls, DB,
  SgtsDataEditFm, SgtsDataInsertFm, SgtsDataUpdateFm, SgtsDataDelete,
  SgtsFm, SgtsControls;

type
  TSgtsRbkDefectViewEditForm = class(TSgtsDataEditForm)
    LabelName: TLabel;
    EditName: TEdit;
    MemoNote: TMemo;
    LabelNote: TLabel;
    LabelPriority: TLabel;
    EditPriority: TEdit;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  TSgtsRbkDefectViewInsertIface=class(TSgtsDataInsertIface)
  public
    procedure Init; override;
  end;

  TSgtsRbkDefectViewUpdateIface=class(TSgtsDataUpdateIface)
  public
    procedure Init; override;
  end;

  TSgtsRbkDefectViewDeleteIface=class(TSgtsDataDeleteIface)
  public
    procedure Init; override;
  end;
  
var
  SgtsRbkDefectViewEditForm: TSgtsRbkDefectViewEditForm;

implementation

uses DBClient,
     SgtsIface, SgtsConsts, SgtsProviderConsts,
     SgtsDatabaseCDS, SgtsDialogs, SgtsExecuteDefs;

{$R *.dfm}

{ TSgtsRbkDefectViewInsertIface }

procedure TSgtsRbkDefectViewInsertIface.Init;
begin
  inherited Init;
  FormClass:=TSgtsRbkDefectViewEditForm;
  InterfaceName:=SInterfaceDefectViewInsert;
  with DataSet do begin
    ProviderName:=SProviderInsertDefectView;
    with ExecuteDefs do begin
      AddKey('DEFECT_VIEW_ID');
      AddEdit('NAME','EditName','LabelName',true);
      AddEditInteger('PRIORITY','EditPriority','LabelPriority',true);
      AddMemo('DESCRIPTION','MemoNote','LabelNote',false);
    end;
  end;
end;

{ TSgtsRbkDefectViewUpdateIface }

procedure TSgtsRbkDefectViewUpdateIface.Init;
begin
  inherited Init;
  FormClass:=TSgtsRbkDefectViewEditForm;
  InterfaceName:=SInterfaceDefectViewUpdate;
  with DataSet do begin
    ProviderName:=SProviderUpdateDefectView;
    with ExecuteDefs do begin
      AddKeyLink('DEFECT_VIEW_ID');
      AddEdit('NAME','EditName','LabelName',true);
      AddEditInteger('PRIORITY','EditPriority','LabelPriority',true);
      AddMemo('DESCRIPTION','MemoNote','LabelNote',false);
    end;
  end;
end;

{ TSgtsRbkDefectViewDeleteIface }

procedure TSgtsRbkDefectViewDeleteIface.Init;
begin
  inherited Init;
  InterfaceName:=SInterfaceDefectViewDelete;
  DeleteQuestion:='������� ��� ������� %NAME?';
  with DataSet do begin
    ProviderName:=SProviderDeleteDefectView;
    with ExecuteDefs do begin
      AddKeyLink('DEFECT_VIEW_ID');
      AddInvisible('NAME').ParamType:=ptUnknown;
    end;
  end;
end;

end.
