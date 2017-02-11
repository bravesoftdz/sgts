unit SgtsGrpJournalFm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ExtDlgs, ImgList, TeeProcs, TeEngine,
  Chart, DbChart, ExtCtrls, ComCtrls, ToolWin, DbGrids,
  SgtsFm, SgtsDatabaseCDS,
  SgtsCoreIntf,
  SgtsBaseGraphRefreshFm, SgtsBaseGraphFm;

type
  TSgtsGrpJournalForm = class(TSgtsBaseGraphForm)
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  TSgtsGrpJournalIface=class(TSgtsBaseGraphIface)
  private
    FCutId: Integer;
    FCutDescription: String;
    function GetForm: TSgtsGrpJournalForm;
  protected
    procedure AutoChartTitles; override;
    procedure CreateDataSetFilters; override;
  public
    constructor Create(ACoreIntf: ISgtsCore); override;
    destructor Destroy; override;
    procedure Init; override;
    procedure Show(ACutId: Integer;
                   ACutDescription: String; ADataSet: TSgtsDatabaseCDS;
                   AColumns: String); reintroduce;

    property CutId: Integer read FCutId;
    property Form: TSgtsGrpJournalForm read GetForm;
  end;

var
  SgtsGrpJournalForm: TSgtsGrpJournalForm;

implementation

uses DBClient,
     SgtsIface, SgtsGraphFm, SgtsGetRecordsConfig, SgtsConsts, SgtsObj, SgtsUtils,
     SgtsGrpJournalRefreshFm, SgtsGraphChartFm;

{$R *.dfm}

{ TSgtsGrpJournalIface }

constructor TSgtsGrpJournalIface.Create(ACoreIntf: ISgtsCore);
begin
  inherited Create(ACoreIntf);
  Permissions.Enabled:=false;
end;

destructor TSgtsGrpJournalIface.Destroy;
begin
  inherited Destroy;
end;

procedure TSgtsGrpJournalIface.Init;
begin
  inherited Init;
  InterfaceName:=SInterfaceGrpJournal;
  FormClass:=TSgtsGrpJournalForm;
  Caption:=iff(Trim(FCutDescription)<>'',FCutDescription,Caption);
  RefreshClass:=TSgtsGrpJournalRefreshIface;
end;

function TSgtsGrpJournalIface.GetForm: TSgtsGrpJournalForm;
begin
  Result:=TSgtsGrpJournalForm(inherited Form);
end;

procedure TSgtsGrpJournalIface.Show(ACutId: Integer;
                                    ACutDescription: String; ADataSet: TSgtsDatabaseCDS;
                                    AColumns: String);
begin
  SectionName:=Name+InttoStr(ACutId);
  FCutId:=ACutId;
  FCutDescription:=ACutDescription;
  with DefaultDataSet do begin
    FieldDefs.Assign(ADataSet.FieldDefs);
    ProviderName:=ADataSet.ProviderName;
    FilterGroups.CopyFrom(ADataSet.FilterGroups);
    Orders.CopyFrom(ADataSet.Orders);
  end;
  Columns:=AColumns;
  Init;
  BeforeReadParams;
  ReadParams;
  DatabaseLink;
  inherited Show;
end;

procedure TSgtsGrpJournalIface.AutoChartTitles;
var
  S: String;
begin
  inherited AutoChartTitles;
  if Assigned(RefreshIface) then begin
    ChartTitle.Clear;
    ChartTitle.Add(RefreshIface.GraphName);
    S:=DefaultDataSet.FilterGroups.GetUserFilter;
    if Trim(S)<>'' then
      ChartTitle.Add(S);
  end;
end;

procedure TSgtsGrpJournalIface.CreateDataSetFilters;
{var
  i: Integer;
  DataSet: TSgtsDatabaseCDS;}
begin
  inherited CreateDataSetFilters;
{  for i:=0 to OtherDataSets.Count-1 do begin
    DataSet:=OtherDataSets.Items[i];
    DataSet.FilterGroups.Clear;
    DataSet.FilterGroups.CopyFrom(DefaultDataSet.FilterGroups);
  end;}
end;

{ TSgtsGrpJournalForm }

procedure TSgtsGrpJournalForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if CanClose then begin
    Iface.BeforeWriteParams;
    Iface.WriteParams;
  end;
  inherited;
end;

end.
