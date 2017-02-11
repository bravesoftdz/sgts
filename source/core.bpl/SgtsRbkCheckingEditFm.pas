unit SgtsRbkCheckingEditFm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ToolWin, ImgList, Menus, ExtCtrls, StdCtrls,
  SgtsDataEditFm, SgtsDataInsertFm, SgtsDataUpdateFm, SgtsDataDelete,
  SgtsFm, SgtsControls, SgtsExecuteDefs;

type

  TSgtsRbkCheckingEditForm = class(TSgtsDataEditForm)
    LabelName: TLabel;
    EditName: TEdit;
    LabelDescription: TLabel;
    MemoDescription: TMemo;
    LabelMeasureType: TLabel;
    LabelParam: TLabel;
    EditMeasureType: TEdit;
    ButtonMeasureType: TButton;
    EditParam: TEdit;
    ButtonParam: TButton;
    LabelPoint: TLabel;
    EditPoint: TEdit;
    ButtonPoint: TButton;
    LabelPriority: TLabel;
    EditPriority: TEdit;
    LabelAlgorithm: TLabel;
    EditAlgorithm: TEdit;
    ButtonAlgorithm: TButton;
    CheckBoxEnabled: TCheckBox;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  TSgtsRbkCheckingInsertIface=class(TSgtsDataInsertIface)
  public
    procedure Init; override;
  end;

  TSgtsRbkCheckingUpdateIface=class(TSgtsDataUpdateIface)
  public
    procedure Init; override;
  end;

  TSgtsRbkCheckingDeleteIface=class(TSgtsDataDeleteIface)
  public
    procedure Init; override;
  end;

var
  SgtsRbkCheckingEditForm: TSgtsRbkCheckingEditForm;

implementation

uses DBClient,
     SgtsIface, SgtsConsts, SgtsProviderConsts,
     SgtsDatabaseCDS, SgtsDialogs, SgtsGetRecordsConfig,
     SgtsRbkParamsFm, SgtsRbkMeasureTypesFm, SgtsRbkPointsFm, SgtsRbkAlgorithmsFm,
     SgtsRbkParamEditFm;

{$R *.dfm}

{ TSgtsRbkCheckingInsertIface }

procedure TSgtsRbkCheckingInsertIface.Init;
begin
  inherited Init;
  FormClass:=TSgtsRbkCheckingEditForm;
  InterfaceName:=SInterfaceCheckingInsert;
  with DataSet do begin
    ProviderName:=SProviderInsertChecking;
    with ExecuteDefs do begin
      AddKey('CHECKING_ID');
      AddEdit('NAME','EditName','LabelName',true);
      AddMemo('DESCRIPTION','MemoDescription','LabelDescription',false);
      AddEditLink('ALGORITHM_ID','EditAlgorithm','LabelAlgorithm','ButtonAlgorithm',
                  TSgtsRbkAlgorithmsIface,'ALGORITHM_NAME','NAME','ALGORITHM_ID',true);
      AddEditLink('MEASURE_TYPE_ID','EditMeasureType','LabelMeasureType','ButtonMeasureType',
                  TSgtsRbkMeasureTypesIface,'MEASURE_TYPE_PATH','PATH','MEASURE_TYPE_ID',true);
      AddEditLink('POINT_ID','EditPoint','LabelPoint','ButtonPoint',
                  TSgtsRbkPointsIface,'POINT_NAME','NAME','POINT_ID');
      with AddEditLink('PARAM_ID','EditParam','LabelParam','ButtonParam',
                       TSgtsRbkParamsIface,'PARAM_NAME','NAME','PARAM_ID',true) do begin
        FilterGroups.Add.Filters.Add('PARAM_TYPE',fcEqual,ptIntroduced);
      end;
      AddEditInteger('PRIORITY','EditPriority','LabelPriority',true);
      AddCheck('ENABLED','CheckBoxEnabled');
    end;
  end;
end;

{ TSgtsRbkCheckingUpdateIface }

procedure TSgtsRbkCheckingUpdateIface.Init;
begin
  inherited Init;
  FormClass:=TSgtsRbkCheckingEditForm;
  InterfaceName:=SInterfaceCheckingUpdate;
  with DataSet do begin
    ProviderName:=SProviderUpdateChecking;
    with ExecuteDefs do begin
      AddKeyLink('CHECKING_ID');
      AddEdit('NAME','EditName','LabelName',true);
      AddMemo('DESCRIPTION','MemoDescription','LabelDescription',false);
      AddEditLink('ALGORITHM_ID','EditAlgorithm','LabelAlgorithm','ButtonAlgorithm',
                  TSgtsRbkAlgorithmsIface,'ALGORITHM_NAME','NAME','ALGORITHM_ID',true);
      AddEditLink('MEASURE_TYPE_ID','EditMeasureType','LabelMeasureType','ButtonMeasureType',
                  TSgtsRbkMeasureTypesIface,'MEASURE_TYPE_PATH','PATH','MEASURE_TYPE_ID',true);
      AddEditLink('POINT_ID','EditPoint','LabelPoint','ButtonPoint',
                  TSgtsRbkPointsIface,'POINT_NAME','NAME','POINT_ID');
      with AddEditLink('PARAM_ID','EditParam','LabelParam','ButtonParam',
                       TSgtsRbkParamsIface,'PARAM_NAME','NAME','PARAM_ID',true) do begin
        FilterGroups.Add.Filters.Add('PARAM_TYPE',fcEqual,ptIntroduced);
      end;
      AddEditInteger('PRIORITY','EditPriority','LabelPriority',true);
      AddCheck('ENABLED','CheckBoxEnabled');
    end;
  end;
end;

{ TSgtsRbkCheckingDeleteIface }

procedure TSgtsRbkCheckingDeleteIface.Init;
begin
  inherited Init;
  InterfaceName:=SInterfaceCheckingDelete;
  DeleteQuestion:='������� �������� %NAME?';
  with DataSet do begin
    ProviderName:=SProviderDeleteChecking;
    with ExecuteDefs do begin
      AddKeyLink('CHECKING_ID');
      AddInvisible('NAME');
    end;
  end;
end;

{ TSgtsRbkInsertCheckingForm }

end.
