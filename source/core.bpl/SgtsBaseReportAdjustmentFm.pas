unit SgtsBaseReportAdjustmentFm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBClient, ImgList, Grids, DBGrids,
  ExtCtrls, StdCtrls, CheckLst, Buttons, ComCtrls,
  SgtsDataGridAdjustmentFm, SgtsFm, SgtsCoreIntf, SgtsBaseReportComponents;

type
  TSgtsBaseReportAdjustmentForm = class(TSgtsDataGridAdjustmentForm)
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  TSgtsBaseReportAdjustmentIface=class(TSgtsDataGridAdjustmentIface)
  private
    FVisibleColumns: Boolean;
    FVisibleOrders: Boolean;
    FVisibleFilters: Boolean;
  protected
    function GetFormClass: TSgtsFormClass; override;
  public
    constructor Create(ACoreIntf: ISgtsCore); override;
    procedure AfterCreateForm(AForm: TSgtsForm); override;
    function Select(Columns: TSgtsColumns): Boolean;

    property VisibleColumns: Boolean read FVisibleColumns write FVisibleColumns;
    property VisibleOrders: Boolean read FVisibleOrders write FVisibleOrders;
    property VisibleFilters: Boolean read FVisibleFilters write FVisibleFilters;
  end;

var
  SgtsBaseReportAdjustmentForm: TSgtsBaseReportAdjustmentForm;

implementation

{$R *.dfm}

{ TSgtsBaseReportAdjustmentIface }

constructor TSgtsBaseReportAdjustmentIface.Create(ACoreIntf: ISgtsCore); 
begin
  inherited Create(ACoreIntf);
end;

function TSgtsBaseReportAdjustmentIface.GetFormClass: TSgtsFormClass; 
begin
  Result:=TSgtsBaseReportAdjustmentForm;
end;

procedure TSgtsBaseReportAdjustmentIface.AfterCreateForm(AForm: TSgtsForm);
begin
  inherited AfterCreateForm(AForm);
  if Assigned(Form) then begin
    with Form do begin
      TabSheetColumns.TabVisible:=FVisibleColumns;
      TabSheetOrders.TabVisible:=FVisibleOrders;
      TabSheetFilters.TabVisible:=FVisibleFilters;
      PageControl.Visible:=TabSheetColumns.TabVisible or TabSheetOrders.TabVisible or TabSheetFilters.TabVisible;
    end;
  end;
end;

function TSgtsBaseReportAdjustmentIface.Select(Columns: TSgtsColumns): Boolean;
begin
  Result:=true;
  try
    Init;
    ReadParams;
    FVisibleColumns:=Assigned(Columns);
    if ShowModal=mrOk then begin

    end;

{      AIface.Columns:=Form.Grid.Columns;
      AIface.SelectDefs:=DataSet.SelectDefs;
      AIface.Orders:=DataSet.Orders;
      AIface.DefaultOrders:=FDefaultOrders;
      AIface.AutoFitColumns:=Form.Grid.AutoFit;
      AIface.FilterGroups:=DataSet.FilterGroups;
      AIface.DefaultFilterGroups:=FDefaultFilterGroups;}
//      if Iface.ShowModal=mrOk then begin
{        with Form do begin
          Grid.AutoFit:=false;
          CopyGridColumns(AIface.Columns,Grid.Columns);
          Grid.AutoFit:=AIface.AutoFitColumns;
          if Grid.AutoFit then
            Grid.AutoFitColumns;
          FColumns:=Grid.GetColumnsStr;
          FAutoFit:=Grid.AutoFit;
        end;
        DataSet.Orders.CopyFrom(AIface.Orders);
        FOrders:=DataSet.Orders.GetOrdersStr;

        DataSet.FilterGroups.CopyFrom(AIface.FilterGroups);
        FFilters:=DataSet.FilterGroups.GetFiltersStr;

        Refresh;}
//      end;

  finally
    WriteParams;
    Done;
  end;  
end;

end.
