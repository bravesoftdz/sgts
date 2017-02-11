unit SgtsBaseGraphPeriodObjectsIface;

interface

uses Classes, Contnrs,
     SgtsCoreIntf, SgtsBaseGraphPeriodIface,
     SgtsBaseGraphPeriodObjectsRefreshFm;

type
  TSgtsBaseGraphPeriodObjectsIface=class;


  TSgtsBaseGraphPeriodObjectsIface=class(TSgtsBaseGraphPeriodIface)
  private
    function GetRefreshIface: TSgtsBaseGraphPeriodObjectsRefreshIface;
  protected
    procedure CreateAllSeriesByAxisParams; override;
    procedure CreateDataSetFilters; override;
  public
    constructor Create(ACoreIntf: ISgtsCore); override;
    destructor Destroy; override;
    procedure Init; override;
    procedure AutoChartTitles; override;

    property RefreshIface: TSgtsBaseGraphPeriodObjectsRefreshIface read GetRefreshIface;
  end;

implementation

uses Sysutils, Variants,
     SgtsConsts, SgtsGraphFm, SgtsGetRecordsConfig, SgtsBaseGraphRefreshFm, SgtsConfig,
     SgtsGraphChartSeriesDefs, SgtsUtils, SgtsBaseGraphPeriodRefreshFm, SgtsDatabaseCDS,
     SgtsBaseGraphFm;

{ TSgtsBaseGraphPeriodObjectsIface }

constructor TSgtsBaseGraphPeriodObjectsIface.Create(ACoreIntf: ISgtsCore);
begin
  inherited Create(ACoreIntf);
end;

destructor TSgtsBaseGraphPeriodObjectsIface.Destroy; 
begin
  inherited Destroy;
end;

procedure TSgtsBaseGraphPeriodObjectsIface.Init;
begin
  inherited Init;
  RefreshClass:=TSgtsBaseGraphPeriodObjectsRefreshIface;
end;

function TSgtsBaseGraphPeriodObjectsIface.GetRefreshIface: TSgtsBaseGraphPeriodObjectsRefreshIface;
begin
  Result:=TSgtsBaseGraphPeriodObjectsRefreshIface(inherited RefreshIface);
end;

procedure TSgtsBaseGraphPeriodObjectsIface.CreateAllSeriesByAxisParams;
begin
  inherited CreateAllSeriesByAxisParams;
end;

procedure TSgtsBaseGraphPeriodObjectsIface.CreateDataSetFilters;
var
  i: Integer;
  Item: TSgtsDatabaseCDS;
begin
  inherited CreateDataSetFilters;
  if Assigned(RefreshIface) then begin
    for i:=0 to DataSets.Count-1 do begin
      Item:=DataSets.Items[i];
      if OtherDataSets.IndexOf(Item)=-1 then begin
        with DataSets.Items[i].FilterGroups.Add do begin
          Filters.Add('GROUP_ID',fcEqual,RefreshIface.GroupId);
        end;
      end;
    end;
  end;
end;

procedure TSgtsBaseGraphPeriodObjectsIface.AutoChartTitles;
var
  S: String;
begin
  inherited AutoChartTitles;
  if Assigned(RefreshIface) then begin
    S:=RefreshIface.GroupName;
    if Trim(S)<>'' then
      ChartTitle.Add(Format('������ ��������: %s',[S]));    
  end;
end;


end.
