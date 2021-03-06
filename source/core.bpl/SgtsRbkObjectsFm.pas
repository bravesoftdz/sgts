unit SgtsRbkObjectsFm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, Menus, ImgList, ExtCtrls, ComCtrls, ToolWin,
  SgtsDataGridFm, SgtsDataFm, SgtsFm, SgtsCDS,
  SgtsCoreIntf, StdCtrls, DBCtrls, Grids, DBGrids;

type
  TSgtsRbkObjectsForm = class(TSgtsDataGridForm)
    PanelInfo: TPanel;
    GroupBoxInfo: TGroupBox;
    PanelNote: TPanel;
    DBMemoDescription: TDBMemo;
    Splitter: TSplitter;
    GroupBoxPath: TGroupBox;
    PanelPath: TPanel;
    SplitterDescription: TSplitter;
    MemoPaths: TMemo;
  private
    { Private declarations }
  public
    constructor Create(ACoreIntf: ISgtsCore); override;
  end;

  TSgtsRbkObjectsIface=class(TSgtsDataGridIface)
  private
    FOldObjectId: Variant;
    function GetForm: TSgtsRbkObjectsForm;
  protected
    procedure DataSetAfterScroll(DataSet: TDataSet); override;
  public
    procedure Init; override;
    procedure OpenData; override;

    property Form: TSgtsRbkObjectsForm read GetForm;
  end;

var
  SgtsRbkObjectsForm: TSgtsRbkObjectsForm;

implementation

uses SgtsProviderConsts, SgtsIface, SgtsConsts, SgtsRbkObjectEditFm,
     SgtsSelectDefs, SgtsDatabaseCDS;

{$R *.dfm}

{ TSgtsRbkObjectsIface }

procedure TSgtsRbkObjectsIface.Init;
begin
  inherited Init;
  FormClass:=TSgtsRbkObjectsForm;
  InterfaceName:=SInterfaceObjects;
  InsertClass:=TSgtsRbkObjectInsertIface;
  UpdateClass:=TSgtsRbkObjectUpdateIface;
  DeleteClass:=TSgtsRbkObjectDeleteIface;
  with DataSet do begin
    ProviderName:=SProviderSelectObjects;
    with SelectDefs do begin
      AddKey('OBJECT_ID');
      Add('NAME','Наименование');
      Add('SHORT_NAME','Краткое');
      AddInvisible('DESCRIPTION');
    end;
  end;
end;

function TSgtsRbkObjectsIface.GetForm: TSgtsRbkObjectsForm;
begin
  Result:=TSgtsRbkObjectsForm(inherited Form);
end;

procedure TSgtsRbkObjectsIface.OpenData;
begin
  FOldObjectId:=Null;
  inherited OpenData;
end;

procedure TSgtsRbkObjectsIface.DataSetAfterScroll(DataSet: TDataSet);
var
  OldCursor: TCursor;
  NewObjectId: Variant;
  DS: TSgtsDatabaseCDS;
begin
  inherited DataSetAfterScroll(DataSet);
  if Assigned(Form) and
     DataSet.Active and not DataSet.IsEmpty then begin
    Form.MemoPaths.Clear;
    NewObjectId:=DataSet.FieldByName('OBJECT_ID').Value;
    if (FOldObjectId<>NewObjectId) then begin
      OldCursor:=Screen.Cursor;
      Screen.Cursor:=crHourGlass;
      DS:=TSgtsDatabaseCDS.Create(CoreIntf);
      try
        DS.StopException:=true;
        DS.ProviderName:=SProviderGetObjectPaths;
        with DS.ExecuteDefs do begin
          AddInvisible('OBJECT_ID').Value:=NewObjectId;
          AddInvisible('PATHS',ptOutput);
          AddInvisible('NAME',ptOutput);
        end;
        DS.Execute;
        Form.MemoPaths.Lines.Text:=Trim(VarToStrDef(DS.ExecuteDefs.Find('PATHS').Value,''));
        FOldObjectId:=NewObjectId;
      finally
        DS.Free;
        Screen.Cursor:=OldCursor;
      end;
    end; 
  end;
end;

{ TSgtsRbkObjectsForm }

constructor TSgtsRbkObjectsForm.Create(ACoreIntf: ISgtsCore);
begin
  inherited Create(ACoreIntf);
end;


end.
