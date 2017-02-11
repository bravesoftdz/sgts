unit SgtsRbkCutsFm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ImgList, Grids, DBGrids, ExtCtrls, ComCtrls, ToolWin, DB,
  StdCtrls, DBCtrls, 
  SgtsDataGridFm, SgtsDataFm, SgtsFm, SgtsSelectDefs,
  SgtsCoreIntf;

type
  TSgtsRbkCutsForm = class(TSgtsDataGridForm)
    PanelInfo: TPanel;
    GroupBoxInfo: TGroupBox;
    PanelNote: TPanel;
    DBMemoDescription: TDBMemo;
    Splitter: TSplitter;
  private
    { Private declarations }
  public
    constructor Create(ACoreIntf: ISgtsCore); override;
  end;

  TSgtsRbkCutsIface=class(TSgtsDataGridIface)
  private
    function GetCutType(Def: TSgtsSelectDef): Variant;
  public
    procedure Init; override;
    procedure BeforeReadParams; override;
  end;

var
  SgtsRbkCutsForm: TSgtsRbkCutsForm;

function GetCutTypeNameByIndex(Index: Integer): String;

implementation

uses DBClient,
     SgtsDbGrid, SgtsCDS, SgtsProviderConsts, SgtsDatabaseCDS,
     SgtsRbkCutEditFm, SgtsConsts, SgtsIface;

{$R *.dfm}

function GetCutTypeNameByIndex(Index: Integer): String;
begin
  case Index of
    0: Result:='������� ������';
    1: Result:='������ ����������';
  else
    Result:='';  
  end;
end;

{ TSgtsRbkCutsIface }

procedure TSgtsRbkCutsIface.Init;
begin
  inherited Init;
  FormClass:=TSgtsRbkCutsForm;
  InterfaceName:=SInterfaceCuts;
  InsertClass:=TSgtsRbkCutInsertIface;
  UpdateClass:=TSgtsRbkCutUpdateIface;
  DeleteClass:=TSgtsRbkCutDeleteIface;
  with DataSet do begin
    ProviderName:=SProviderSelectCuts;
    with SelectDefs do begin
      AddKey('CUT_ID');
      AddInvisible('MEASURE_TYPE_ID');
      AddInvisible('OBJECT_ID');
      Add('NAME','������������',100);
      AddCalc('CUT_TYPE_EX','��� �����','CUT_TYPE',GetCutType,ftString,50,100);
      Add('MEASURE_TYPE_NAME','��� ���������',100);
      Add('VIEW_NAME','������� ���������',100);
      Add('PROC_NAME','��������� ����������',100);
      Add('PRIORITY','�������',40);
      AddInvisible('OBJECT_NAME');
      AddInvisible('DESCRIPTION');
      AddInvisible('DETERMINATION');
      AddInvisible('CONDITION');
    end;
  end;
end;

function TSgtsRbkCutsIface.GetCutType(Def: TSgtsSelectDef): Variant;
var
  S: String;
begin
  Result:=Null;
  S:=GetCutTypeNameByIndex(DataSet.FieldByName(Def.CalcName).AsInteger);
  if Trim(S)<>'' then
    Result:=S;
end;

procedure TSgtsRbkCutsIface.BeforeReadParams; 
begin
  inherited BeforeReadParams;
end;

{ TSgtsRbkCutsForm }

constructor TSgtsRbkCutsForm.Create(ACoreIntf: ISgtsCore);
begin
  inherited Create(ACoreIntf);
end;


end.
