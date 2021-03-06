unit SgtsRbkCycleEditFm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ToolWin, ImgList, Menus, ExtCtrls, StdCtrls, DB,
  SgtsDataEditFm, SgtsDataInsertFm, SgtsDataUpdateFm, SgtsDataDelete,
  SgtsFm, SgtsControls, SgtsCoreIntf;

type
  TSgtsRbkCycleEditForm = class(TSgtsDataEditForm)
    LabelNum: TLabel;
    EditNum: TEdit;
    MemoDescription: TMemo;
    LabelDescription: TLabel;
    LabelYear: TLabel;
    EditYear: TEdit;
    LabelMonth: TLabel;
    ComboBoxMonth: TComboBox;
    CheckBoxIsClose: TCheckBox;
  private
    { Private declarations }
  public
    constructor Create(ACoreIntf: ISgtsCore); override;
    procedure InitByIface(AIface: TSgtsFormIface); override;
  end;

  TSgtsRbkCycleInsertIface=class(TSgtsDataInsertIface)
  public
    procedure Init; override;
  end;

  TSgtsRbkCycleUpdateIface=class(TSgtsDataUpdateIface)
  public
    procedure Init; override;
  end;

  TSgtsRbkCycleDeleteIface=class(TSgtsDataDeleteIface)
  public
    procedure Init; override;
  end;
  
var
  SgtsRbkCycleEditForm: TSgtsRbkCycleEditForm;

implementation

uses DBClient, DateUtils,
     SgtsIface, SgtsConsts, SgtsProviderConsts,
     SgtsDatabaseCDS, SgtsDialogs, SgtsExecuteDefs;

{$R *.dfm}

{ TSgtsRbkCycleInsertIface }

procedure TSgtsRbkCycleInsertIface.Init;
begin
  inherited Init;
  FormClass:=TSgtsRbkCycleEditForm;
  InterfaceName:=SInterfaceCycleInsert;
  with DataSet do begin
    ProviderName:=SProviderInsertCycle;
    with ExecuteDefs do begin
      AddKey('CYCLE_ID');
      AddEditInteger('CYCLE_NUM','EditNum','LabelNum',true);
      AddEditInteger('CYCLE_YEAR','EditYear','LabelYear',true);
      AddComboInteger('CYCLE_MONTH','ComboBoxMonth','LabelMonth',true);
      AddMemo('DESCRIPTION','MemoDescription','LabelDescription',false);
      AddCheck('IS_CLOSE','CheckBoxIsClose');
    end;
  end;
  with Permissions do begin
    AddDefault(SPermissionNameOpenCloseCycle);
  end; 
end;

{ TSgtsRbkCycleUpdateIface }

procedure TSgtsRbkCycleUpdateIface.Init;
begin
  inherited Init;
  FormClass:=TSgtsRbkCycleEditForm;
  InterfaceName:=SInterfaceCycleUpdate;
  with DataSet do begin
    ProviderName:=SProviderUpdateCycle;
    with ExecuteDefs do begin
      AddKeyLink('CYCLE_ID');
      AddEditInteger('CYCLE_NUM','EditNum','LabelNum',true);
      AddEditInteger('CYCLE_YEAR','EditYear','LabelYear',true);
      AddComboInteger('CYCLE_MONTH','ComboBoxMonth','LabelMonth',true);
      AddMemo('DESCRIPTION','MemoDescription','LabelDescription',false);
      AddCheck('IS_CLOSE','CheckBoxIsClose');
    end;
  end;
  with Permissions do begin
    AddDefault(SPermissionNameOpenCloseCycle);
  end; 
end;

{ TSgtsRbkCycleDeleteIface }

procedure TSgtsRbkCycleDeleteIface.Init;
begin
  inherited Init;
  InterfaceName:=SInterfaceCycleDelete;
  DeleteQuestion:='������� ���� %CYCLE_NUM?';
  with DataSet do begin
    ProviderName:=SProviderDeleteCycle;
    with ExecuteDefs do begin
      AddKeyLink('CYCLE_ID');
      AddInvisible('CYCLE_NUM').ParamType:=ptUnknown;
    end;
  end;
end;

{ TSgtsRbkCycleEditForm }

constructor TSgtsRbkCycleEditForm.Create(ACoreIntf: ISgtsCore); 
begin
  inherited Create(ACoreIntf);
  EditYear.Text:=IntToStr(YearOf(Now));
end;

procedure TSgtsRbkCycleEditForm.InitByIface(AIface: TSgtsFormIface);
begin
  inherited InitByIface(AIface);
  CheckBoxIsClose.Enabled:=AIface.PermissionExists(SPermissionNameOpenCloseCycle);
end;

end.
