unit SgtsTestFm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DB, Grids, DBGrids,
  SgtsFm, SgtsChildFm, SgtsCoreIntf, SgtsDatabaseCDS, SgtsProviders;

type
  TSgtsTestForm = class(TSgtsChildForm)
    ButtonOpen: TButton;
    ButtonInsert: TButton;
    DataSource: TDataSource;
    DBGrid1: TDBGrid;
    ButtonIface: TButton;
    procedure ButtonOpenClick(Sender: TObject);
    procedure ButtonInsertClick(Sender: TObject);
    procedure ButtonIfaceClick(Sender: TObject);
  private
    FDataSet: TSgtsDatabaseCDS;
    FTestId: Variant;
  public
    constructor Create(ACoreIntf: ISgtsCore); override;
    destructor Destroy; override;
  end;

  TSgtsTestIface=class(TSgtsChildIface)
  public
    procedure Init; override;
    function CanShow: Boolean; override;
  end;

var
  SgtsTestForm: TSgtsTestForm;

implementation

uses SgtsConsts, SgtsDatabaseIntf,
     SgtsDialogs, SgtsCDS, SgtsRbkTestFm, SgtsGetRecordsConfig;

{$R *.dfm}

{ TSgtsTestIface }

procedure TSgtsTestIface.Init;
begin
  inherited Init;
  FormClass:=TSgtsTestForm;
  InterfaceName:='�������� ���������';
  MenuPath:=Format(SFunctionsMenu,['�������� ���������']);
  MenuIndex:=1001;
  with Permissions do begin
    AddDefault(SPermissionNameShow);
  end;
end;

function TSgtsTestIface.CanShow: Boolean;
begin
  Result:=PermissionExists(SPermissionNameShow);
end;

{ TSgtsTestForm }

constructor TSgtsTestForm.Create(ACoreIntf: ISgtsCore);
begin
  inherited Create(ACoreIntf);
  FDataSet:=TSgtsDatabaseCDS.Create(ACoreIntf);
  FDataSet.ProviderName:='S_TEST';
  with FDataSet.SelectDefs do begin
    AddInvisible('TEST_ID');
    AddInvisible('NAME');
    AddInvisible('DESCRIPTION');
  end;
  FDataSet.CheckProvider:=false;
  DataSource.DataSet:=FDataSet;
  FTestId:=Null;
end;

destructor TSgtsTestForm.Destroy;
begin
  FDataSet.Free;
  inherited Destroy;
end;

procedure TSgtsTestForm.ButtonOpenClick(Sender: TObject);
begin
  FDataSet.Close;
  FDataSet.Open;
  ShowInfo('Record count = '+IntToStr(FDataSet.RecordCount));
end;

procedure TSgtsTestForm.ButtonInsertClick(Sender: TObject);
var
  DS: TSgtsDatabaseCDS;
  ID: Integer;
begin
  DS:=TSgtsDatabaseCDS.Create(CoreIntf);
  try
    DS.ProviderName:='I_TEST';
    DS.CheckProvider:=false;
    ID:=Random(10);
    // ID:=CoreIntf.DatabaseModules.Current.Database.GetNewId(DS.ProviderName);
    with DS.ExecuteDefs do begin
      AddValue('TEST_ID',ID);
      AddValue('NAME','Test'+IntToStr(ID));
      AddValue('DESCRIPTION',IntToStr(ID));
    end;
    DS.Execute;
    if DS.ExecuteSuccess then begin
      ShowInfo('Execute success');
      ButtonOpen.Click;
    end;
  finally
    DS.Free;
  end;
end;

procedure TSgtsTestForm.ButtonIfaceClick(Sender: TObject);
var
  AIface: TSgtsRbkTestsIface;
  Buffer: String;
  DS: TSgtsCDS;
  FG: TSgtsGetRecordsConfigFilterGroups;
begin
  AIface:=TSgtsRbkTestsIface.Create(CoreIntf);
  FG:=TSgtsGetRecordsConfigFilterGroups.Create;
  try
    FG.Add.Filters.Add('TEST_ID',fcEqualLess,10);  
    if AIface.SelectVisible('TEST_ID',FTestId,Buffer,FG,true) then begin
      DS:=TSgtsCDS.Create(nil);
      try
        DS.XMLData:=Buffer;
        if DS.Active and not DS.IsEmpty then begin
          DS.First;
          while not DS.Eof do begin
            ShowInfo('Name is '+DS.FieldByName('NAME').AsString);
            DS.Next;
          end;
        end;
      finally
        DS.Free;
      end;
    end;
  finally
    FG.Free;
    AIface.Free;
  end;
end;



end.
