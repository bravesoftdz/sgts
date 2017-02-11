unit SgtsRbkGraphsFm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ImgList, Grids, DBGrids, ExtCtrls, ComCtrls, ToolWin, DB,
  StdCtrls, DBCtrls, 
  SgtsDataGridFm, SgtsDataFm, SgtsFm, SgtsSelectDefs,
  SgtsCoreIntf;

type
  TSgtsRbkGraphsForm = class(TSgtsDataGridForm)
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

  TSgtsRbkGraphsIface=class(TSgtsDataGridIface)
  private
    function GetGraphType(Def: TSgtsSelectDef): Variant;
  public
    procedure Init; override;
    procedure BeforeReadParams; override;
  end;

var
  SgtsRbkGraphsForm: TSgtsRbkGraphsForm;

function GetGraphTypeNameByIndex(Index: Integer): String;

implementation

uses DBClient,
     SgtsDbGrid, SgtsCDS, SgtsProviderConsts, SgtsDatabaseCDS,
     SgtsRbkGraphEditFm, SgtsConsts, SgtsIface;

{$R *.dfm}

function GetGraphTypeNameByIndex(Index: Integer): String;
begin
  case Index of
    0: Result:='������ �������';
    1: Result:='������ �� ������';
    2: Result:='������ �� ������������� ������';
    3: Result:='������ � ������� ������ ��������';
  else
    Result:='';  
  end;
end;

{ TSgtsRbkGraphsIface }

procedure TSgtsRbkGraphsIface.Init;
begin
  inherited Init;
  FormClass:=TSgtsRbkGraphsForm;
  InterfaceName:=SInterfaceGraphs;
  InsertClass:=TSgtsRbkGraphInsertIface;
  UpdateClass:=TSgtsRbkGraphUpdateIface;
  DeleteClass:=TSgtsRbkGraphDeleteIface;
  with DataSet do begin
    ProviderName:=SProviderSelectGraphs;
    with SelectDefs do begin
      AddKey('GRAPH_ID');
      AddInvisible('CUT_ID');
      Add('NAME','������������',150);
      AddCalc('GRAPH_TYPE_EX','��� �������','GRAPH_TYPE',GetGraphType,ftString,50,150);
      Add('CUT_NAME','����',100).Visible:=false;
      Add('MENU','����',100);
      Add('PRIORITY','�������',30);
      AddInvisible('DESCRIPTION');
      AddInvisible('DETERMINATION');
    end;
  end;
end;

function TSgtsRbkGraphsIface.GetGraphType(Def: TSgtsSelectDef): Variant;
var
  S: String;
begin
  Result:=Null;
  S:=GetGraphTypeNameByIndex(DataSet.FieldByName(Def.CalcName).AsInteger);
  if Trim(S)<>'' then
    Result:=S;
end;

procedure TSgtsRbkGraphsIface.BeforeReadParams; 
begin
  inherited BeforeReadParams;
end;

{ TSgtsRbkGraphsForm }

constructor TSgtsRbkGraphsForm.Create(ACoreIntf: ISgtsCore);
begin
  inherited Create(ACoreIntf);
end;


end.
