unit SgtsFunSourceDataMeasureGeneralFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, DBGrids, DB, StdCtrls, ExtCtrls,  Menus, Mask, DBCtrls,
  SgtsFunSourceDataFrm, SgtsCoreIntf, SgtsDbGrid, SgtsCDS, SgtsDatabaseCDS,
  SgtsGetRecordsConfig, SgtsSelectDefs, SgtsRbkParamEditFm, SgtsControls;

type
  TSgtsFunSourceDataMeasureGeneralColumnType=(ctUnknown,ctPointName,ctDate,ctConverter,ctObjectPaths,ctCoordinateZ,
                                              ctParamValue,ctParamUnit,ctParamInstrument,ctBase,ctConfirm);
  TSgtsFunSourceDataMeasureGeneralColumnTypes=set of TSgtsFunSourceDataMeasureGeneralColumnType;

  TSgtsFunSourceDataMeasureGeneralNewRecordMode=(rmCancel,rmFill,rmInput,rmFillEmpty);

  TSgtsFunSourceDataMeasureGeneralFrame = class(TSgtsFunSourceDataFrame)
    DataSource: TDataSource;
    PopupMenuConfirm: TPopupMenu;
    MenuItemConfirmCheckAll: TMenuItem;
    MenuItemConfirmUncheckAll: TMenuItem;
    N1: TMenuItem;
    MenuItemConfirmCancel: TMenuItem;
    PanelInfo: TPanel;
    GroupBoxInfo: TGroupBox;
    LabelJournalNum: TLabel;
    DBEditJournalNum: TDBEdit;
    LabelNote: TLabel;
    DBMemoNote: TDBMemo;
    PanelGrid: TPanel;
    GridPattern: TDBGrid;
    LabelPointCoordinateZ: TLabel;
    EditPointCoordinateZ: TEdit;
    LabelConverter: TLabel;
    EditConverter: TEdit;
    LabelPointObject: TLabel;
    MemoPointObject: TMemo;
    LabelColumn: TLabel;
    EditColumn: TEdit;
    procedure MenuItemConfirmCheckAllClick(Sender: TObject);
    procedure MenuItemConfirmUncheckAllClick(Sender: TObject);
    procedure PopupMenuConfirmPopup(Sender: TObject);
    procedure DBMemoNoteKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure DBMemoNoteExit(Sender: TObject);
  private
    FChangePresent: Boolean;
    FNewRecordMode: TSgtsFunSourceDataMeasureGeneralNewRecordMode;
    FGrid: TSgtsFunSourceDbGrid;
    FDataSet: TSgtsFunSourceDataCDS;
    FDataSetParams: TSgtsDatabaseCDS;
    FTempDSParams: TSgtsCDS;
    FDataSetPoints: TSgtsDatabaseCDS;
    FDataSetCycles: TSgtsDatabaseCDS;
    FDataSetRoutes: TSgtsDatabaseCDS;
    FDataSetPointInstruments: TSgtsDatabaseCDS;
    FDataSetInstrumentUnits: TSgtsDatabaseCDS;
    FDataSetJournal: TSgtsDatabaseCDS;
    FSelectDefs: TSgtsSelectDefs;
    function GetFieldByCounter(const FieldName: String; Counter: Integer): String;
    function GetColumnType(Column: TColumn): TSgtsFunSourceDataMeasureGeneralColumnType;
    procedure SetIsBase;
    procedure GridDblClick(Sender: TObject);
    procedure GridCellClick(Column: TColumn);
    function GetIsConfirm: Boolean;
    procedure GoEdit(WithEditor: Boolean; WithDataSet: Boolean; EditorMode: Boolean=true);
    procedure GoBrowse(ChangeMode: Boolean);
    procedure GoSelect(ReadOnly: Boolean);
    procedure GoDropDown;
    function NextPresent(Index: Integer; ColumnTypes: TSgtsFunSourceDataMeasureGeneralColumnTypes): Boolean;
    function DataSetParamsLocate(Counter: Integer): Boolean;
    function GetCounterByField(FieldName: String; ColumnType: TSgtsFunSourceDataMeasureGeneralColumnType): Integer;
    function ParamIsConfirm(Column: TColumn): Boolean;
    function GetFieldNameByType(ColumnType: TSgtsFunSourceDataMeasureGeneralColumnType): String;
    function GetParamTypeByColumn(Column: TColumn): TSgtsRbkParamType;
    function GetParamType: TSgtsRbkParamType;
    function GetParamId: Variant;
    procedure GridKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SetColumnProperty(Column: TColumn);
    function GetCurrentColumn: TColumn;
    procedure GridColEnter(Sender: TObject);
    procedure DataSetAfterScroll(DataSet: TDataSet);
    procedure DataSetAfterPost(DataSet: TDataSet);
    procedure DataSetNewRecord(DataSet: TDataSet);
    function GetFirstCycleIdByFilter: Variant;
    function GetMeasureTypeIdByFilter: Variant;
    function GetObjectIdByFilter: Variant;
    function GetInstrumentIdByFilter(Counter: Integer): Variant;
    function GetMeasureUnitIdByFilter(Counter: Integer): Variant;
    procedure PointNameFieldSetText(Sender: TField; const Text: string);
    procedure DateObservationFieldSetText(Sender: TField; const Text: string);
    procedure ParamValueFieldSetText(Sender: TField; const Text: string);
    procedure InstrumentNameFieldSetText(Sender: TField; const Text: string);
    procedure MeasureNameFieldSetText(Sender: TField; const Text: string);
    function GetConfirmProc(Def: TSgtsSelectDef): Variant;
    procedure FillValues(Strings: TStrings);
    procedure FillPoints(Strings: TStrings);
    procedure FillInstruments(Strings: TStrings);
    procedure FillMeasureUnits(Strings: TStrings; ByInstrumentId: Boolean; InstrumentId: Variant);
    procedure Calculate;
    function CheckRecord(CheckChanges: Boolean; WithMessage: Boolean=true; WithParam: Boolean=false; WithChecking: Boolean=true): Boolean;
    function SaveRecord: Boolean;
    procedure ViewPointInfo(AsPoint: Boolean);
    procedure ViewObjectTreeInfo;
    procedure ViewInstrumentInfo;
    procedure ViewMeasureUnitInfo;
    procedure ConfirmAll(Checked: Boolean);
    function GridGetFontColor(Sender: TObject; Column: TColumn; var FontStyles: TFontStyles): TColor;
    function Checking(var Value: Variant; AVisible: Boolean=true): Boolean;
    procedure SetAdditionalInfo;
    function GetAdditionalInfo(PointId: Variant; var Converter, ObjectPaths, CoordinateZ: Variant; ObjectDelim: String=''): Boolean;
    procedure FillDefaultInstruments(PointId: Variant; WithCheck: Boolean);
    procedure GridValueEditButtonClick(Sender: TObject);
    procedure SetColumnName;
  protected
    function GetChangeArePresent: Boolean; override;
    procedure SetChangeArePresent(Value: Boolean); override;
    function GetCycleNum: String; override;
    function GetRouteName: String; override;
  public
    constructor Create(ACoreIntf: ISgtsCore); override;
    destructor Destroy; override;
    function GetDataSet: TSgtsCDS; override;
    procedure Refresh; override;
    function CanRefresh: Boolean; override;
    procedure BeforeRefresh; override;
    procedure AfterRefresh; override;
    function Save: Boolean; override;
    function CanSave: Boolean; override;
    function GetActiveControl: TWinControl; override;
    procedure Insert; override;
    function CanInsert: Boolean; override;
    procedure Update; override;
    function CanUpdate: Boolean; override;
    procedure Delete; override;
    function CanDelete: Boolean; override;
    procedure Confirm; override;
    function CanConfirm: Boolean; override;
    procedure Detail; override;
    function CanDetail: Boolean; override;
    procedure Recalculation; override;
    function CanRecalculation: Boolean; override;
  end;

var
  SgtsFunSourceDataMeasureGeneralFrame: TSgtsFunSourceDataMeasureGeneralFrame;

implementation

uses DBClient, DateUtils, StrUtils,
     SgtsConsts, SgtsProviderConsts, SgtsFunSourceDataConditionFm,
     SgtsUtils, SgtsExecuteDefs, SgtsProviders, SgtsDialogs,
     SgtsFunSourceDataPointsIface, SgtsFunSourceDataInstrumentsIface,
     SgtsFunSourceDataMeasureUnitsIface, SgtsRbkCyclesFm, SgtsCheckingFm,
     SgtsFunPointManagementFm, SgtsDataFm, SgtsRbkPointManagementFm, SgtsConfig,
     SgtsVariants, SgtsFunSourceDataObjectTreesIface;

{$R *.dfm}

const
  PickListColumnTypes=[ctPointName,ctParamUnit,ctParamInstrument];
  EditColumnTypes=[ctPointName,ctDate,ctParamValue,ctParamUnit,ctParamInstrument];
  CheckColumnTypes=[ctBase,ctConfirm];
  ReturnColumnTypes=[ctPointName,ctDate,ctConverter,ctObjectPaths,ctCoordinateZ,ctParamValue,ctParamUnit,ctParamInstrument];
  ParamColumnTypes=[ctParamValue,ctParamUnit,ctParamInstrument];

{ TSgtsFunSourceDataMeasureGeneralFrame }

constructor TSgtsFunSourceDataMeasureGeneralFrame.Create(ACoreIntf: ISgtsCore);
begin
  inherited Create(ACoreIntf);
  FNewRecordMode:=rmCancel;
  EditColumn.Anchors:=[akLeft, akTop, akRight];
  MemoPointObject.Anchors:=[akLeft, akTop, akRight];
  DBMemoNote.Anchors:=[akLeft, akTop, akRight, akBottom];
  
  FSelectDefs:=TSgtsSelectDefs.Create;

  FGrid:=TSgtsFunSourceDbGrid.Create(Self);
  with FGrid do begin
    Parent:=GridPattern.Parent;
    Align:=GridPattern.Align;
    Font.Assign(GridPattern.Font);
    Font.Style:=GridPattern.Font.Style;
    LocateEnabled:=false;
    ColumnSortEnabled:=false;
    Options:=Options-[dgEditing,dgTabs];
    ColMoving:=false;
    AutoFit:=false;
    VisibleRowNumber:=true;
    DataSource:=GridPattern.DataSource;
    TabOrder:=1;
    Visible:=false;
    ReadOnly:=false;
    OnCellClick:=GridCellClick;
    OnDblClick:=GridDblClick;
    OnKeyDown:=GridKeyDown;
    OnColEnter:=GridColEnter;
    OnGetFontColor:=GridGetFontColor;
  end;

  GridPattern.Free;
  GridPattern:=nil;

  FDataSetParams:=TSgtsDatabaseCDS.Create(ACoreIntf);
  with FDataSetParams do begin
    ProviderName:=SProviderSelectMeasureTypeParams;
    with SelectDefs do begin
      AddInvisible('PARAM_ID');
      AddInvisible('PARAM_NAME');
      AddInvisible('PARAM_DESCRIPTION');
      AddInvisible('PARAM_TYPE');
      AddInvisible('PARAM_FORMAT');
      AddInvisible('ALGORITHM_PROC_NAME');
      AddInvisible('PARAM_DETERMINATION');
      AddInvisible('PARAM_IS_NOT_CONFIRM');
    end;
  end;

  FDataSetPoints:=TSgtsDatabaseCDS.Create(ACoreIntf);
  with FDataSetPoints do begin
    ProviderName:=SProviderSelectRouteConverters;
    with SelectDefs do begin
      AddInvisible('POINT_ID');
      AddInvisible('POINT_NAME');
      AddInvisible('ROUTE_ID');
      AddInvisible('ROUTE_NAME');
      AddInvisible('PRIORITY');
      AddInvisible('CONVERTER_NAME');
      AddInvisible('CONVERTER_ID');
      AddInvisible('COORDINATE_Z');
      AddInvisible('OBJECT_ID');
      AddInvisible('OBJECT_PATHS');
      AddInvisible('CONVERTER_NOT_OPERATION');
    end;
    Orders.Add('PRIORITY',otAsc);
  end;

  FDataSetCycles:=TSgtsDatabaseCDS.Create(ACoreIntf);
  with FDataSetCycles do begin
    ProviderName:=SProviderSelectCycles;
    with SelectDefs do begin
      AddInvisible('CYCLE_ID');
      AddInvisible('CYCLE_NUM');
      AddInvisible('CYCLE_YEAR');
      AddInvisible('CYCLE_MONTH');
      AddInvisible('DESCRIPTION');
      AddInvisible('IS_CLOSE');
    end;
  end;

  FDataSetRoutes:=TSgtsDatabaseCDS.Create(ACoreIntf);
  with FDataSetRoutes do begin
    ProviderName:=SProviderSelectMeasureTypeRoutes;
    with SelectDefs do begin
      AddInvisible('MEASURE_TYPE_ID');
      AddInvisible('ROUTE_ID');
      AddInvisible('ROUTE_NAME');
      AddInvisible('PRIORITY');
      AddInvisible('IS_BASE');
    end;
  end;

  FDataSetPointInstruments:=TSgtsDatabaseCDS.Create(ACoreIntf);
  with FDataSetPointInstruments do begin
    ProviderName:=SProviderSelectPointInstruments;
    with SelectDefs do begin
      AddInvisible('POINT_ID');
      AddInvisible('INSTRUMENT_ID');
      AddInvisible('PARAM_ID');
      AddInvisible('INSTRUMENT_NAME');
      AddInvisible('POINT_NAME');
      AddInvisible('PARAM_NAME');
    end;
    Orders.Add('PRIORITY',otAsc);
  end;

  FDataSetInstrumentUnits:=TSgtsDatabaseCDS.Create(ACoreIntf);
  with FDataSetInstrumentUnits do begin
    ProviderName:=SProviderSelectInstrumentUnits;
    with SelectDefs do begin
      AddInvisible('INSTRUMENT_ID');
      AddInvisible('MEASURE_UNIT_ID');
      AddInvisible('INSTRUMENT_NAME');
      AddInvisible('MEASURE_UNIT_NAME');
    end;
    Orders.Add('PRIORITY',otAsc);
  end;

  FDataSetJournal:=TSgtsDatabaseCDS.Create(ACoreIntf);
  with FDataSetJournal do begin
    ProviderName:=SProviderSelectJournalFields;
    with SelectDefs do begin
      AddInvisible('JOURNAL_FIELD_ID');
      AddInvisible('JOURNAL_NUM');
      AddInvisible('NOTE');
      AddInvisible('DATE_OBSERVATION');
      AddInvisible('CYCLE_ID');
      AddInvisible('CYCLE_NUM');
      AddInvisible('POINT_ID');
      AddInvisible('POINT_NAME');
      AddInvisible('PARAM_ID');
      AddInvisible('PARAM_NAME');
      AddInvisible('INSTRUMENT_ID');
      AddInvisible('INSTRUMENT_NAME');
      AddInvisible('MEASURE_UNIT_ID');
      AddInvisible('MEASURE_UNIT_NAME');
      AddInvisible('VALUE');
      AddInvisible('WHO_ENTER');
      AddInvisible('DATE_ENTER');
      AddInvisible('WHO_CONFIRM');
      AddInvisible('DATE_CONFIRM');
      AddInvisible('GROUP_ID');
      AddInvisible('IS_BASE');
      AddInvisible('IS_CHECK');
    end;
    Orders.Add('DATE_OBSERVATION',otAsc);
    Orders.Add('GROUP_ID',otAsc);
    Orders.Add('PRIORITY',otAsc);
  end;

  FDataSet:=TSgtsFunSourceDataCDS.Create(nil);
  with FDataSet do begin
    IndexDefs.Add('IDX_CYCLE_DATE_ROUTE_POINT','CYCLE_ID;DATE_OBSERVATION;ROUTE_PRIORITY;POINT_PRIORITY',[]);
    IndexDefs.Add('IDX_CYCLE_DATE_POINT','CYCLE_ID;DATE_OBSERVATION;POINT_ID',[]);
    AfterScroll:=DataSetAfterScroll;
    OnNewRecord:=DataSetNewRecord;
    AfterPost:=DataSetAfterPost;
    IndexName:='IDX_CYCLE_DATE_ROUTE_POINT';
  end;
  FDataSet.SelectDefs:=FSelectDefs;

  DataSource.DataSet:=FDataSet;

  FTempDSParams:=TSgtsCDS.Create(nil);
end;

destructor TSgtsFunSourceDataMeasureGeneralFrame.Destroy;
begin
  FTempDSParams.Free;
  FDataSet.Free;
  FDataSetJournal.Free;
  FDataSetInstrumentUnits.Free;
  FDataSetPointInstruments.Free;
  FDataSetCycles.Free;
  FDataSetPoints.Free;
  FDataSetParams.Free;
  FSelectDefs.Free;
  inherited Destroy;
end;

function TSgtsFunSourceDataMeasureGeneralFrame.GetFieldByCounter(const FieldName: String; Counter: Integer): String;
begin
  Result:=Format(SSourceDataFieldFormat,[FieldName,Counter]);
end;

procedure TSgtsFunSourceDataMeasureGeneralFrame.FillDefaultInstruments(PointId: Variant; WithCheck: Boolean);
var
  Counter: Integer;
  ParamType: TSgtsRbkParamType;
  InstrumentId: Variant;
  ParamId: Variant;
begin
  if FDataSetPointInstruments.Active and
     FDataSetInstrumentUnits.Active then begin
    Counter:=0;
    FDataSetParams.First;
    while not FDataSetParams.Eof do begin
      ParamType:=TSgtsRbkParamType(FDataSetParams.FieldByName('PARAM_TYPE').AsInteger);
      ParamId:=FDataSetParams.FieldByName('PARAM_ID').Value;
      if (ParamType=ptIntroduced) then begin
        FDataSetPointInstruments.First;
        if FDataSetPointInstruments.Locate('POINT_ID;PARAM_ID',VarArrayOf([PointId,ParamId])) then begin
          InstrumentId:=FDataSetPointInstruments.FieldByName('INSTRUMENT_ID').Value;
          if Assigned(FDataSet.FindField(GetFieldByCounter('INSTRUMENT_ID',Counter))) then begin
            FDataSet.FieldByName(GetFieldByCounter('INSTRUMENT_ID',Counter)).Value:=InstrumentId;
            FDataSet.FieldByName(GetFieldByCounter('INSTRUMENT_NAME',Counter)).Value:=FDataSetPointInstruments.FieldByName('INSTRUMENT_NAME').Value;
            FDataSetInstrumentUnits.First;
            if FDataSetInstrumentUnits.Locate('INSTRUMENT_ID',InstrumentId) then begin
              FDataSet.FieldByName(GetFieldByCounter('MEASURE_UNIT_ID',Counter)).Value:=FDataSetInstrumentUnits.FieldByName('MEASURE_UNIT_ID').Value;
              FDataSet.FieldByName(GetFieldByCounter('MEASURE_UNIT_NAME',Counter)).Value:=FDataSetInstrumentUnits.FieldByName('MEASURE_UNIT_NAME').Value;
            end;
          end;  
        end else begin
          InstrumentId:=GetInstrumentIdByFilter(Counter);
          if not VarIsNull(InstrumentId) then begin
            FDataSet.FieldByName(GetFieldByCounter('INSTRUMENT_ID',Counter)).Value:=InstrumentId;
            FDataSet.FieldByName(GetFieldByCounter('INSTRUMENT_NAME',Counter)).Value:=GetValueByCounter('INSTRUMENT_NAME',Counter);
            FDataSet.FieldByName(GetFieldByCounter('MEASURE_UNIT_ID',Counter)).Value:=GetValueByCounter('MEASURE_UNIT_ID',Counter);
            FDataSet.FieldByName(GetFieldByCounter('MEASURE_UNIT_NAME',Counter)).Value:=GetValueByCounter('MEASURE_UNIT_NAME',Counter);
          end;
        end;
      end;
      if WithCheck then
        FDataSet.FieldByName(GetFieldByCounter('IS_CHECK',Counter)).Value:=Integer(true);
      Inc(Counter);
      FDataSetParams.Next;
    end;
  end;
end;

procedure TSgtsFunSourceDataMeasureGeneralFrame.Refresh;
var
  DSRestrictIsBase: TSgtsDatabaseCDS;

  function CreateData: Boolean;
  var
    FilterInstrumentId: Variant;
    Field: TField;
    Counter: Integer;
    ParamType: TSgtsRbkParamType;
  begin
    Result:=false;
    FDataSetParams.Close;
    FDataSetPoints.Close;
    FDataSetCycles.Close;
    FDataSetRoutes.Close;
    FDataSetPointInstruments.Close;
    FDataSetInstrumentUnits.Close;
    FDataSetJournal.Close;
    FDataSet.Close;
    FDataSet.Fields.Clear;
    FDataSet.FieldDefs.Clear;

    with FDataSetParams do begin
      FilterGroups.Clear;
      SetFilterGroupsTo(FilterGroups,'MEASURE_TYPE_ID',foOr);
      SetFilterGroupsTo(FilterGroups,'PARAM_ID',foOr);
    end;
    FDataSetParams.Open;

    with FDataSetPoints do begin
      FilterGroups.Clear;
      FilterGroups.Add.Filters.Add('CONVERTER_NOT_OPERATION',fcEqual,0);
      SetFilterGroupsTo(FilterGroups,'ROUTE_ID',foOr);
      SetFilterGroupsTo(FilterGroups,'OBJECT_ID',foOr);
    end;
    FDataSetPoints.Open;

    with FDataSetCycles do begin
      FilterGroups.Clear;
      SetFilterGroupsTo(FilterGroups,'CYCLE_ID',foOr);
    end;
    FDataSetCycles.Open;

    with FDataSetRoutes do begin
      FilterGroups.Clear;
      SetFilterGroupsTo(FilterGroups,'MEASURE_TYPE_ID',foOr);
      SetFilterGroupsTo(FilterGroups,'ROUTE_ID',foOr);
    end;
    FDataSetRoutes.Open;

    with FDataSetPointInstruments do begin
      FilterGroups.Clear;
      SetDataSetTo(FDataSetParams,FilterGroups,'PARAM_ID',foOr);
      SetDataSetTo(FDataSetPoints,FilterGroups,'POINT_ID',foOr);
    end;
    FDataSetPointInstruments.Open;

    with FDataSetInstrumentUnits do begin
      FilterGroups.Clear;
    end;
    FDataSetInstrumentUnits.Open;

    with FDataSetJournal do begin
      FilterGroups.Clear;
      SetFilterGroupsTo(FilterGroups,'CYCLE_ID',foOr);
      SetDataSetTo(FDataSetParams,FilterGroups,'PARAM_ID',foOr);
      SetDataSetTo(FDataSetPoints,FilterGroups,'POINT_ID',foOr);
      FilterGroups.Add.Filters.Add('DATE_OBSERVATION',fcEqualGreater,GetDateBegin);
      FilterGroups.Add.Filters.Add('DATE_OBSERVATION',fcEqualLess,GetDateEnd);
      FilterGroups.Add.Filters.Add('PARENT_ID',fcIsNull,NULL);
    end;
    FDataSetJournal.Open;

    if FDataSetParams.Active and
       FDataSetPoints.Active and
       FDataSetCycles.Active and
       FDataSetRoutes.Active and
       FDataSetPointInstruments.Active and
       FDataSetInstrumentUnits.Active and
       FDataSetJournal.Active then begin

      FTempDSParams.CreateDataSetBySource(FDataSetParams,true,true);

      Counter:=0;
      with FDataSet do begin
        CreateField('IS_CHANGE',ftInteger);
        CreateFieldBySource('JOURNAL_NUM',FDataSetJournal);
        CreateFieldBySource('NOTE',FDataSetJournal);
        CreateFieldBySource('GROUP_ID',FDataSetJournal);
        CreateFieldBySource('CYCLE_ID',FDataSetJournal);
        CreateFieldBySource('POINT_ID',FDataSetJournal);
        CreateFieldBySource('POINT_PRIORITY',FDataSetPoints,false,'PRIORITY');
        CreateFieldBySource('ROUTE_PRIORITY',FDataSetRoutes,false,'PRIORITY');
        CreateFieldBySource('POINT_NAME',FDataSetJournal).OnSetText:=PointNameFieldSetText;
        with CreateFieldBySource('DATE_OBSERVATION',FDataSetJournal) do begin
          EditMask:=SDateMask;
          ValidChars:=CDateValidChars;
          OnSetText:=DateObservationFieldSetText;
        end;
        CreateFieldBySource('CONVERTER_NAME',FDataSetPoints);
        CreateFieldBySource('OBJECT_PATHS',FDataSetPoints);
        CreateFieldBySource('COORDINATE_Z',FDataSetPoints);

        CreateFieldBySource('WHO_ENTER',FDataSetJournal);
        CreateFieldBySource('DATE_ENTER',FDataSetJournal);
        CreateFieldBySource('WHO_CONFIRM',FDataSetJournal);
        CreateFieldBySource('DATE_CONFIRM',FDataSetJournal);

        FSelectDefs.Add('POINT_NAME','������������� �����',50);
        FSelectDefs.Add('DATE_OBSERVATION','���� ���������',70);
        FSelectDefs.Add('CONVERTER_NAME','���������������',50);
        FSelectDefs.Add('OBJECT_PATHS','������������ �������',80);
        FSelectDefs.Add('COORDINATE_Z','������� ��',50);

        FDataSetParams.First;
        while not FDataSetParams.Eof do begin            
          ParamType:=TSgtsRbkParamType(FDataSetParams.FieldByName('PARAM_TYPE').AsInteger);
          CreateFieldBySource(GetFieldByCounter('JOURNAL_FIELD_ID',Counter),FDataSetJournal,false,'JOURNAL_FIELD_ID');

          Field:=CreateFieldBySource(GetFieldByCounter('VALUE',Counter),FDataSetJournal,false,'VALUE');
          with Field do begin
            if DecimalSeparator<>'.' then
               ValidChars:=ValidChars+['.']
            else ValidChars:=ValidChars+[','];
            OnSetText:=ParamValueFieldSetText;
          end;
          SetDisplayFormat(Field,FDataSetParams.FieldByName('PARAM_FORMAT').AsString);

          FilterInstrumentId:=GetInstrumentIdByFilter(Counter);
          if (ParamType in [ptIntroduced]) and not VarIsNull(FilterInstrumentId) then begin
            CreateFieldBySource(GetFieldByCounter('INSTRUMENT_ID',Counter),FDataSetJournal,false,'INSTRUMENT_ID');
            CreateFieldBySource(GetFieldByCounter('INSTRUMENT_NAME',Counter),FDataSetJournal,false,'INSTRUMENT_NAME').OnSetText:=InstrumentNameFieldSetText;
            FSelectDefs.Add(GetFieldByCounter('INSTRUMENT_NAME',Counter),'������',70);
            CreateFieldBySource(GetFieldByCounter('MEASURE_UNIT_ID',Counter),FDataSetJournal,false,'MEASURE_UNIT_ID');
            CreateFieldBySource(GetFieldByCounter('MEASURE_UNIT_NAME',Counter),FDataSetJournal,false,'MEASURE_UNIT_NAME').OnSetText:=MeasureNameFieldSetText;
            FSelectDefs.Add(GetFieldByCounter('MEASURE_UNIT_NAME',Counter),'������� ���������',30);
          end;

          if ParamType<>ptIntegralInvisible then
            FSelectDefs.Add(GetFieldByCounter('VALUE',Counter),FDataSetParams.FieldByName('PARAM_NAME').AsString,50);

          CreateFieldBySource(GetFieldByCounter('IS_CHECK',Counter),FDataSetJournal,false,'IS_CHECK');
          inc(Counter);
          FDataSetParams.Next;
        end;

        CreateFieldBySource('IS_BASE',FDataSetJournal);
        FSelectDefs.AddDrawRadio('IS_BASE_EX','�������','IS_BASE',30,true);
        FSelectDefs.Find('IS_BASE').Field:=FindField('IS_BASE');

        CreateField('IS_CONFIRM',ftInteger).FieldKind:=fkCalculated;
        FSelectDefs.AddCalcInvisible('IS_CONFIRM',GetConfirmProc,ftInteger).Field:=FindField('IS_CONFIRM');
        FSelectDefs.AddDrawCheck('IS_CONFIRM_EX','����������','IS_CONFIRM',30);

        CreateDataSet;
      end;

      Result:=FDataSet.Active;
    end;
  end;

  function CheckRestrictIsBase(CycleId,PointId: Variant): Boolean;
  var
    Str: TStringList;
    ValueIsNull: Boolean;
    NotIsBase: Boolean;
    GroupId: Variant;
    OldGroupId: Variant;
    Counter: Integer;
    FlagFirst: Boolean;
  begin
    Result:=true;
    if DSRestrictIsBase.Active then begin
      Str:=TStringList.Create;
      DSRestrictIsBase.BeginUpdate(false);
      try
        ValueIsNull:=true;
        NotIsBase:=true;
        OldGroupId:=Null;
        Counter:=0;
        FlagFirst:=true;
        Str.Add(Format('CYCLE_ID=%s',[QuotedStr(VarToStrDef(CycleId,''))]));
        Str.Add(Format('POINT_ID=%s',[QuotedStr(VarToStrDef(PointId,''))]));
        DSRestrictIsBase.Filter:=GetFilterString(Str,'AND');
        DSRestrictIsBase.Filtered:=true;
        DSRestrictIsBase.First;
        while not DSRestrictIsBase.Eof do begin
          GroupId:=DSRestrictIsBase.FieldByName('GROUP_ID').Value;
          if FlagFirst or (OldGroupId=GroupId) then begin
            Inc(Counter);
            FlagFirst:=false;
          end else begin
            if Counter<>FDataSetParams.RecordCount then begin
              Result:=true;
              Break;
            end else begin
              Result:=ValueIsNull and NotIsBase;
              if not Result then
                Break;
            end;
          end;
          ValueIsNull:=ValueIsNull and VarIsNull(DSRestrictIsBase.FieldByName('VALUE').Value);
          NotIsBase:=NotIsBase and not Boolean(DSRestrictIsBase.FieldByName('IS_BASE').AsInteger);
          OldGroupId:=GroupId;
          DSRestrictIsBase.Next;
        end;
        if Counter<>FDataSetParams.RecordCount then begin
          Result:=true;
        end else begin
          Result:=ValueIsNull and NotIsBase;
        end;
      finally
        DSRestrictIsBase.EndUpdate(false);
        Str.Free;
      end;
    end;
  end;

  procedure LoadEmptyData;
  var
    CycleId: Variant;
    PointId: Variant;
    Group: TSgtsGetRecordsConfigFilterGroup;
    Filter: TSgtsGetRecordsConfigFilter;
    i,j: Integer;
    Year,Month: Word;
    Day,DayCount: Word;
    TempDate: Variant;
    D1, D2: TDate;
    Converter,ObjectPaths,CoordinateZ: Variant;
  begin
    FNewRecordMode:=rmFillEmpty;
    D1:=GetDateBegin;
    D2:=GetDateEnd;
    for i:=0 to FilterGroups.Count-1 do begin
      Group:=FilterGroups.Items[i];
      for j:=0 to Group.Filters.Count-1 do begin
        Filter:=Group.Filters.Items[j];
        if AnsiSameText(Filter.FieldName,'CYCLE_ID') then begin
          CycleId:=Filter.Value;
          if FDataSetCycles.Locate('CYCLE_ID',CycleId) then begin
            Year:=FDataSetCycles.FieldByName('CYCLE_YEAR').Value;
            Month:=FDataSetCycles.FieldByName('CYCLE_MONTH').Value+1;
            DayCount:=DaysInAMonth(Year,Month);
            CoreIntf.MainForm.Progress(0,DayCount,0);
            try
              for Day:=1 to DayCount do begin
                TempDate:=EncodeDate(Year,Month,Day);
                if (D1<=TempDate) and (TempDate<=D2) then begin
                  FDataSetPoints.First;
                  while not FDataSetPoints.Eof do begin
                    PointId:=FDataSetPoints.FieldByName('POINT_ID').Value;
                    if CheckRestrictIsBase(CycleId,PointId) and
                       not FDataSet.FindKey([CycleId,TempDate,PointId]) then begin
                      FDataSet.Append;
                      FDataSet.FieldByName('CYCLE_ID').Value:=CycleId;
                      FDataSet.FieldByName('POINT_ID').Value:=PointId;
                      FDataSet.FieldByName('POINT_PRIORITY').Value:=FDataSetPoints.FieldByName('PRIORITY').Value;
                      if FDataSetRoutes.Locate('ROUTE_ID',FDataSetPoints.FieldByName('ROUTE_ID').Value) then
                        FDataSet.FieldByName('ROUTE_PRIORITY').Value:=FDataSetRoutes.FieldByName('PRIORITY').Value;
                      FDataSet.FieldByName('POINT_NAME').Value:=FDataSetPoints.FieldByName('POINT_NAME').Value;
                      FDataSet.FieldByName('DATE_OBSERVATION').Value:=TempDate;
                      if RestrictIsBase then
                        FDataSet.FieldByName('IS_BASE').AsInteger:=1;
                      FillDefaultInstruments(PointId,true);
                      if GetAdditionalInfo(PointId,Converter,ObjectPaths,CoordinateZ,';') then begin
                        FDataSet.FieldByName('CONVERTER_NAME').Value:=Converter;
                        FDataSet.FieldByName('OBJECT_PATHS').Value:=ObjectPaths;
                        FDataSet.FieldByName('COORDINATE_Z').Value:=CoordinateZ;
                      end;
                      FDataSet.Post;
                    end;
                    FDataSetPoints.Next;
                  end;
                end else
                  Sleep(10);
                CoreIntf.MainForm.Progress(0,DayCount,Day);
              end;
            finally
              CoreIntf.MainForm.Progress(0,0,0);
            end;
          end;
        end;
      end;
    end;
  end;

  procedure LoadRealData;
  var
    GroupId: Variant;
    Counter: Integer;

    procedure SetOtherFields;
    var
      Field: TField;
    begin
      with FDataSet do begin
        Field:=FindField(GetFieldByCounter('JOURNAL_FIELD_ID',Counter));
        if Assigned(Field) then
          Field.Value:=FDataSetJournal.FieldByName('JOURNAL_FIELD_ID').Value;

        Field:=FindField(GetFieldByCounter('VALUE',Counter));
        if Assigned(Field) then
          Field.Value:=FDataSetJournal.FieldByName('VALUE').Value;

        Field:=FindField(GetFieldByCounter('INSTRUMENT_ID',Counter));
        if Assigned(Field) then
          Field.Value:=FDataSetJournal.FieldByName('INSTRUMENT_ID').Value;

        Field:=FindField(GetFieldByCounter('INSTRUMENT_NAME',Counter));
        if Assigned(Field) then
          Field.Value:=FDataSetJournal.FieldByName('INSTRUMENT_NAME').Value;

        Field:=FindField(GetFieldByCounter('MEASURE_UNIT_ID',Counter));
        if Assigned(Field) then
          Field.Value:=FDataSetJournal.FieldByName('MEASURE_UNIT_ID').Value;

        Field:=FindField(GetFieldByCounter('MEASURE_UNIT_NAME',Counter));
        if Assigned(Field) then
          Field.Value:=FDataSetJournal.FieldByName('MEASURE_UNIT_NAME').Value;

        Field:=FindField(GetFieldByCounter('IS_CHECK',Counter));
        if Assigned(Field) then begin
          Field.Value:=FDataSetJournal.FieldByName('IS_CHECK').Value;
        end;
      end;
    end;

    procedure SetGeneralFields;
    var
      Converter,ObjectPaths,CoordinateZ: Variant;
    begin
      with FDataSet do begin
        FieldByName('IS_CHANGE').Value:=Integer(False);
        FieldByName('GROUP_ID').Value:=GroupId;
        FieldByName('JOURNAL_NUM').Value:=FDataSetJournal.FieldByName('JOURNAL_NUM').Value;
        FieldByName('NOTE').Value:=FDataSetJournal.FieldByName('NOTE').Value;
        FieldByName('CYCLE_ID').Value:=FDataSetJournal.FieldByName('CYCLE_ID').Value;
        FieldByName('POINT_ID').Value:=FDataSetJournal.FieldByName('POINT_ID').Value;
        if FDataSetPoints.Locate('POINT_ID',FieldByName('POINT_ID').Value) then begin
          FieldByName('POINT_PRIORITY').Value:=FDataSetPoints.FieldByName('PRIORITY').Value;
          if FDataSetRoutes.Locate('ROUTE_ID',FDataSetPoints.FieldByName('ROUTE_ID').Value) then
            FieldByName('ROUTE_PRIORITY').Value:=FDataSetRoutes.FieldByName('PRIORITY').Value;
        end;
        FieldByName('POINT_NAME').Value:=FDataSetJournal.FieldByName('POINT_NAME').Value;
        FieldByName('DATE_OBSERVATION').Value:=FDataSetJournal.FieldByName('DATE_OBSERVATION').Value;
        FieldByName('WHO_ENTER').Value:=FDataSetJournal.FieldByName('WHO_ENTER').Value;
        FieldByName('WHO_CONFIRM').Value:=FDataSetJournal.FieldByName('WHO_CONFIRM').Value;
        FieldByName('DATE_ENTER').Value:=FDataSetJournal.FieldByName('DATE_ENTER').Value;
        FieldByName('DATE_CONFIRM').Value:=FDataSetJournal.FieldByName('DATE_CONFIRM').Value;
        FieldByName('IS_BASE').Value:=FDataSetJournal.FieldByName('IS_BASE').Value;
        if GetAdditionalInfo(FDataSetJournal.FieldByName('POINT_ID').Value,Converter,ObjectPaths,CoordinateZ,';') then begin
          FieldByName('CONVERTER_NAME').Value:=Converter;
          FieldByName('OBJECT_PATHS').Value:=ObjectPaths;
          FieldByName('COORDINATE_Z').Value:=CoordinateZ;
        end;
      end;
    end;

  var
    ParamId: Variant;
    PointId: Variant;
    CycleId: Variant;
  begin
    Counter:=0;
    CoreIntf.MainForm.Progress(0,FDataSetParams.RecordCount,0);
    try
      FDataSetParams.First;
      while not FDataSetParams.Eof do begin
        ParamId:=FDataSetParams.FieldByName('PARAM_ID').Value;
        FDataSetJournal.BeginUpdate(false);
        try
          FDataSetJournal.Filter:=Format('PARAM_ID=%s',[QuotedStr(VarToStrDef(ParamId,''))]);
          FDataSetJournal.Filtered:=true;
          FDataSetJournal.First;
          if (FDataSetJournal.RecordCount>0) then begin
            while not FDataSetJournal.Eof do begin
              GroupId:=FDataSetJournal.FieldByName('GROUP_ID').Value;
              PointId:=FDataSetJournal.FieldByName('POINT_ID').Value;
              CycleId:=FDataSetJournal.FieldByName('CYCLE_ID').Value;
              if CheckRestrictIsBase(CycleId,PointId) then begin
                with FDataSet do begin
                  if Counter=0 then begin
                    Append;
                    SetGeneralFields;
                    SetOtherFields;
                    Post;
                  end else begin
                    First;
                    if Locate('GROUP_ID',GroupId,[loCaseInsensitive]) then begin
                      Edit;
                      SetOtherFields;
                      Post;
                    end else begin
                      Append;
                      SetGeneralFields;
                      SetOtherFields;
                      Post;
                    end;
                  end;
                end;
              end;
              FDataSetJournal.Next;
            end;
          end;
        finally
          FDataSetJournal.EndUpdate(false);
        end;
        Inc(Counter);
        CoreIntf.MainForm.Progress(0,FDataSetParams.RecordCount,Counter);
        FDataSetParams.Next;
      end;
    finally
      CoreIntf.MainForm.Progress(0,0,0);
    end;
  end;

var
  OldIndexName: String;
begin
  if CanRefresh then begin
    DSRestrictIsBase:=TSgtsDatabaseCDS.Create(CoreIntf);
    OldIndexName:=FDataSet.IndexName;

    FDataSet.BeginUpdate;
    FDataSet.IndexName:='IDX_CYCLE_DATE_POINT';
    FNewRecordMode:=rmFill;
    try
      FGrid.Columns.Clear;
      FSelectDefs.Clear;
      if CreateData then begin
        CreateGridColumnsBySelectDefs(FGrid,FSelectDefs);
        if IsEdit and RestrictIsBase then begin
          DSRestrictIsBase.ProviderName:=SProviderSelectJournalFields;
          with DSRestrictIsBase do begin
            with SelectDefs do begin
              AddInvisible('CYCLE_ID');
              AddInvisible('POINT_ID');
              AddInvisible('PARAM_ID');
              AddInvisible('GROUP_ID');
              AddInvisible('VALUE');
              AddInvisible('IS_BASE');
            end;
            SetFilterGroupsTo(FilterGroups,'CYCLE_ID',foOr);
            SetDataSetTo(FDataSetParams,FilterGroups,'PARAM_ID',foOr);
            SetDataSetTo(FDataSetPoints,FilterGroups,'POINT_ID',foOr);
            FilterGroups.Add.Filters.Add('PARENT_ID',fcIsNull,NULL);
            Orders.CopyFrom(FDataSetJournal.Orders);
            Open;
          end;
        end;
        LoadRealData;
        if IsEdit then
          LoadEmptyData;
        FGrid.AutoSizeColumns;
        FGrid.Hint:='�������� ������: '+MeasureTypeName+'  (�������� �������������)';
        SetColumnProperty(GetCurrentColumn);
      end;
    finally
      GoBrowse(false);
      FNewRecordMode:=rmInput;
      FDataSet.IndexName:=OldIndexName;
      FDataSet.EndUpdate(true);
      FDataSet.First;
      FGrid.UpdateRowNumber;
      DSRestrictIsBase.Free;
    end;
  end;
end;

function TSgtsFunSourceDataMeasureGeneralFrame.CanRefresh: Boolean;
begin
  Result:=inherited CanRefresh;
end;

function TSgtsFunSourceDataMeasureGeneralFrame.GetColumnType(Column: TColumn): TSgtsFunSourceDataMeasureGeneralColumnType;
begin
  Result:=ctUnknown;
  if Assigned(Column) then begin
    if Pos('POINT_NAME',Column.FieldName)>0 then Result:=ctPointName;
    if Pos('DATE_OBSERVATION',Column.FieldName)>0 then Result:=ctDate;
    if Pos('CONVERTER_NAME',Column.FieldName)>0 then Result:=ctConverter;
    if Pos('OBJECT_PATHS',Column.FieldName)>0 then Result:=ctObjectPaths;
    if Pos('COORDINATE_Z',Column.FieldName)>0 then Result:=ctCoordinateZ;
    if Pos('VALUE',Column.FieldName)>0 then Result:=ctParamValue;
    if Pos('INSTRUMENT_NAME',Column.FieldName)>0 then Result:=ctParamInstrument;
    if Pos('MEASURE_UNIT_NAME',Column.FieldName)>0 then Result:=ctParamUnit;
    if Pos('IS_BASE_EX',Column.FieldName)>0 then Result:=ctBase;
    if Pos('IS_CONFIRM_EX',Column.FieldName)>0 then Result:=ctConfirm;
  end;
end;

procedure TSgtsFunSourceDataMeasureGeneralFrame.GridCellClick(Column: TColumn);
var
  ColumnType: TSgtsFunSourceDataMeasureGeneralColumnType;
begin
  ColumnType:=GetColumnType(Column);
  case ColumnType of
    ctBase: SetIsBase;
    ctConfirm: Confirm;
  end;
end;

function TSgtsFunSourceDataMeasureGeneralFrame.GetIsConfirm: Boolean;
begin
  Result:=false;
  if FDataSet.Active and not FDataSet.IsEmpty then
    Result:=Boolean(FDataSet.FieldByName('IS_CONFIRM').AsInteger);
end;

procedure TSgtsFunSourceDataMeasureGeneralFrame.GoEdit(WithEditor: Boolean; WithDataSet: Boolean; EditorMode: Boolean=true);
begin
  if IsEdit then begin
    if not (dgEditing in FGrid.Options) then begin
      FGrid.Options:=FGrid.Options+[dgEditing];
    end;
    FGrid.TopLeftChanged;
    DBEditJournalNum.ReadOnly:=false;
    DBMemoNote.ReadOnly:=false;
    if WithDataSet then
      with FDataSet do begin
        if IsEmpty and (State<>dsInsert) then Insert
        else if (State<>dsEdit) then Edit;
      end;
    if WithEditor then begin
      FGrid.EditorMode:=EditorMode;
    end;
  end;
end;

procedure TSgtsFunSourceDataMeasureGeneralFrame.GoBrowse(ChangeMode: Boolean);
begin
  if ChangeMode then
    with FDataSet do begin
      if State in [dsInsert,dsEdit] then
        Post;
    end;
  FGrid.Options:=FGrid.Options-[dgEditing];
  FGrid.EditorMode:=false;
  DBEditJournalNum.ReadOnly:=true;
  DBMemoNote.ReadOnly:=true;
end;

procedure TSgtsFunSourceDataMeasureGeneralFrame.GoSelect(ReadOnly: Boolean);
begin
  if Assigned(FGrid.InplaceEdit) then begin
//    FGrid.InplaceEdit.SelStart:=0;
    FGrid.InplaceEdit.SelectAll;
    TSgtsFunSourceEditList(FGrid.InplaceEdit).ReadOnly:=ReadOnly;
  end;
end;

procedure TSgtsFunSourceDataMeasureGeneralFrame.GoDropDown;
var
  Column: TColumn;
begin
  if IsEdit then begin
    Column:=GetCurrentColumn;
    if Assigned(FGrid.InplaceEdit) and Assigned(Column) then begin
      TSgtsFunSourceEditList(FGrid.InplaceEdit).CloseUp(true);
      if (Column.PickList.Count>0) and not FGrid.InplaceEdit.ListVisible then
        TSgtsFunSourceEditList(FGrid.InplaceEdit).DropDown;
    end;
  end;
end;

function TSgtsFunSourceDataMeasureGeneralFrame.NextPresent(Index: Integer; ColumnTypes: TSgtsFunSourceDataMeasureGeneralColumnTypes): Boolean;
var
  ColumnType: TSgtsFunSourceDataMeasureGeneralColumnType;
  i: Integer;
begin
  Result:=false;
  if Index in [0..FGrid.Columns.Count-1] then
    for i:=Index to FGrid.Columns.Count-1 do begin
      ColumnType:=GetColumnType(FGrid.Columns[i]);
      if ColumnType in ColumnTypes then begin
        Result:=true;
        exit;
      end;
    end;
end;

function TSgtsFunSourceDataMeasureGeneralFrame.DataSetParamsLocate(Counter: Integer): Boolean;
var
  i: Integer;
begin
  Result:=false;
  if FDataSetParams.Active then begin
    i:=0;
    FDataSetParams.First;
    while not FDataSetParams.Eof do begin
      if i=Counter then begin
        Result:=true;
        exit;
      end;
      Inc(i);
      FDataSetParams.Next;
    end;
  end;
end;

function TSgtsFunSourceDataMeasureGeneralFrame.GetFieldNameByType(ColumnType: TSgtsFunSourceDataMeasureGeneralColumnType): String;
begin
  Result:='';
  case ColumnType of
    ctParamValue: Result:='VALUE_';
    ctParamUnit: Result:='MEASURE_UNIT_NAME_';
    ctParamInstrument: Result:='INSTRUMENT_NAME_';
  end;
end;

function TSgtsFunSourceDataMeasureGeneralFrame.GetCounterByField(FieldName: String; ColumnType: TSgtsFunSourceDataMeasureGeneralColumnType): Integer;
var
  S: String;
begin
  S:=GetFieldNameByType(ColumnType);
  S:=Copy(FieldName,Length(S)+1,Length(FieldName));
  Result:=StrToIntDef(S,FDataSetParams.RecordCount);
end;

function TSgtsFunSourceDataMeasureGeneralFrame.ParamIsConfirm(Column: TColumn): Boolean; 
var
  ColumnType: TSgtsFunSourceDataMeasureGeneralColumnType;
begin
  Result:=true;
  ColumnType:=GetColumnType(Column);
  if ColumnType in [ctParamValue,ctParamUnit,ctParamInstrument] then begin
    if DataSetParamsLocate(GetCounterByField(Column.FieldName,ColumnType)) then begin
      Result:=not Boolean(FDataSetParams.FieldByName('PARAM_IS_NOT_CONFIRM').AsInteger);
    end;
  end;
end;

function TSgtsFunSourceDataMeasureGeneralFrame.GetParamTypeByColumn(Column: TColumn): TSgtsRbkParamType;
var
  ColumnType: TSgtsFunSourceDataMeasureGeneralColumnType;
begin
  Result:=ptIntegral;
  ColumnType:=GetColumnType(Column);
  if ColumnType in [ctParamValue,ctParamUnit,ctParamInstrument] then begin
    if DataSetParamsLocate(GetCounterByField(Column.FieldName,ColumnType)) then begin
      Result:=TSgtsRbkParamType(FDataSetParams.FieldByName('PARAM_TYPE').AsInteger);
    end;
  end;
end;

function TSgtsFunSourceDataMeasureGeneralFrame.GetParamType: TSgtsRbkParamType;
begin
  Result:=GetParamTypeByColumn(GetCurrentColumn);
end;

function TSgtsFunSourceDataMeasureGeneralFrame.GetParamId: Variant;
var
  Column: TColumn;
  ColumnType: TSgtsFunSourceDataMeasureGeneralColumnType;
begin
  Result:=Null;
  Column:=GetCurrentColumn;
  ColumnType:=GetColumnType(Column);
  if ColumnType in [ctParamValue,ctParamUnit,ctParamInstrument] then begin
    if DataSetParamsLocate(GetCounterByField(Column.FieldName,ColumnType)) then begin
      Result:=FDataSetParams.FieldByName('PARAM_ID').AsInteger;
    end;
  end;
end;

procedure TSgtsFunSourceDataMeasureGeneralFrame.GridKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  ColumnType: TSgtsFunSourceDataMeasureGeneralColumnType;
  Index: Integer;
  Field: TField;
begin
  FNewRecordMode:=rmInput;
  ColumnType:=GetColumnType(GetCurrentColumn);
  case Key of
    VK_DELETE: begin
      if ssCtrl in Shift then begin
        Key:=0;
        exit;
      end;
    end;
    VK_F2: begin
      if not CanUpdate then
        GoBrowse(false)
      else Key:=0;  
    end;
    VK_F3: begin
      if not CanDetail then
        if IsCanInfo then
          ShowInfo(FDataSet.GetInfo);
    end;
    VK_SPACE: begin
      if (ColumnType=ctBase) then begin
        SetIsBase;
        Key:=0;
      end;
      if ColumnType=ctConfirm then begin
        Confirm;
        Key:=0;
      end;
    end;
    VK_RETURN: begin
      if ColumnType in ReturnColumnTypes then begin
        if GetCurrentColumn.PickList.Count>0 then
          GoBrowse(true)
        else begin
          if ColumnType=ctParamValue then begin
            if not (FDataSet.State in [dsEdit,dsInsert]) then begin
              Field:=GetCurrentColumn.Field;
              if Assigned(Field) then begin
                if VarIsNull(Field.Value) then begin
                  FDataSet.Edit;
                  ParamValueFieldSetText(Field,'');
                  FDataSet.Post;
                end;
              end;
            end;  
          end;
          GoBrowse(false);
        end;
        Index:=FGrid.SelectedIndex+1;
        if NextPresent(Index,ReturnColumnTypes) then
          FGrid.SelectedIndex:=Index
        else begin
          if CheckRecord(false) then begin
            if FDataSet.State in [dsEdit,dsInsert] then
              ParamValueFieldSetText(GetCurrentColumn.Field,FGrid.InplaceEdit.Text);
            if SaveRecord then begin
              if IsCanInsert and IsEdit then begin
                if FDataSet.RecNo=FDataSet.RecordCount then
                  FDataSet.Append
                else FDataSet.Next;
              end;
              FGrid.SelectedIndex:=0;
            end;  
          end;
        end;
        Key:=0;
        exit;
      end;
    end;
    VK_DOWN: begin
      if (ssAlt in Shift) and
         (ColumnType in PickListColumnTypes) and
         (GetCurrentColumn.PickList.Count>0) and
         IsCanUpdate and
         not GetIsConfirm then begin
        GoEdit(true,true);
        GoDropDown;
        Key:=0;
      end else
        FNewRecordMode:=rmCancel;
    end;
    VK_INSERT: begin
      Key:=0;
    end;

    else begin
      case ColumnType of
        ctDate: begin
          if IsCanUpdate and
             not GetIsConfirm then
            GoEdit(false,false);
        end;
        ctParamValue: begin
          if IsCanUpdate and
             (GetParamType=ptIntroduced) and
             not GetIsConfirm then begin
            GoEdit(false,false);
          end;
        end;
      end;
    end;
  end;
end;

procedure TSgtsFunSourceDataMeasureGeneralFrame.FillValues(Strings: TStrings);
var
  Config: TSgtsConfig;
  Str: TStringList;
  ParamId: Variant;
  i: Integer;
  V: Extended;
  S: String;
  Obj: TSgtsVariant;
begin
  if FDataSet.Active and
     not FDataSet.IsEmpty then begin
    ParamId:=GetParamId;
    if not VarIsNull(ParamId) then begin
      Strings.BeginUpdate;
      Config:=TSgtsConfig.Create(CoreIntf);
      Str:=TStringList.Create;
      try
        Config.LoadFromString(FDataSetParams.FieldByName('PARAM_DETERMINATION').AsString);
        Config.ReadSection(SParamDeterminationList,Str);
        if Str.Count>0 then begin
          for i:=0 to Str.Count-1 do begin
            V:=0.0;
            S:=Config.Read(SParamDeterminationList,Str[i],'');
            if TryStrToFloat(S,V) then begin
              Obj:=TSgtsVariant.Create;
              Obj.Value:=V;
              Strings.AddObject(Str[i],Obj);
            end;  
          end;
        end;
      finally
        Str.Free;
        Config.Free;
        Strings.EndUpdate;
      end;
    end;  
  end;
end;

procedure TSgtsFunSourceDataMeasureGeneralFrame.GridValueEditButtonClick(Sender: TObject);
begin
end;

procedure TSgtsFunSourceDataMeasureGeneralFrame.SetColumnProperty(Column: TColumn);
var
  ColumnType: TSgtsFunSourceDataMeasureGeneralColumnType;
begin
  if Assigned(Column) then begin
    FGrid.PopupMenu:=DefaultPopupMenu;
    FGrid.OnEditButtonClick:=nil;
    ClearStrings(Column.PickList);
    Column.ButtonStyle:=cbsNone;
    GoBrowse(true);
    ColumnType:=GetColumnType(Column);
    case ColumnType of
      ctPointName: begin
        Column.ButtonStyle:=cbsAuto;
        FillPoints(Column.PickList);
      end;
      ctParamInstrument: begin
        Column.ButtonStyle:=cbsAuto;
        FillInstruments(Column.PickList);
      end;
      ctParamUnit: begin
        Column.ButtonStyle:=cbsAuto;
        FillMeasureUnits(Column.PickList,false,Null);
      end;
      ctParamValue: begin
        Column.ButtonStyle:=cbsAuto;
        FGrid.OnEditButtonClick:=GridValueEditButtonClick;
        FillValues(Column.PickList);
      end;
      ctConfirm: begin
        FGrid.PopupMenu:=PopupMenuConfirm;
      end; 
    end;
  end;
end;

function TSgtsFunSourceDataMeasureGeneralFrame.GetCurrentColumn: TColumn;
var
  Index: Integer;
begin
  Result:=nil;
  Index:=FGrid.SelectedIndex;
  if Index in [0..FGrid.Columns.Count-1] then
    Result:=FGrid.Columns[Index];
end;

procedure TSgtsFunSourceDataMeasureGeneralFrame.GridColEnter(Sender: TObject);
{var
  ColumnType: TSgtsFunSourceDataMeasureGeneralColumnType;}
begin
//  ColumnType:=GetColumnType(GetCurrentColumn);
  SetColumnProperty(GetCurrentColumn);
//  GoSelect((ColumnType in PickListColumnTypes));
  SetColumnName;
  UpdateButtons;
end;

procedure TSgtsFunSourceDataMeasureGeneralFrame.GridDblClick(Sender: TObject);
begin
  Update;
end;

procedure TSgtsFunSourceDataMeasureGeneralFrame.DataSetAfterScroll(DataSet: TDataSet);
begin
  SetColumnProperty(GetCurrentColumn);
  SetColumnName;
  SetAdditionalInfo;
  UpdateButtons;
end;

procedure TSgtsFunSourceDataMeasureGeneralFrame.DataSetAfterPost(DataSet: TDataSet);
begin
  GoBrowse(false);
end;

procedure TSgtsFunSourceDataMeasureGeneralFrame.DataSetNewRecord(DataSet: TDataSet);

  function GetIsBaseDefault: Integer;
  var
    MeasureTypeId: Variant;
  begin
    Result:=Integer(false);
    MeasureTypeId:=GetMeasureTypeIdByFilter;
    if not VarIsNull(MeasureTypeId) and
       FDataSetRoutes.Active and
       not FDataSetRoutes.IsEmpty then begin
      if FDataSetRoutes.Locate('MEASURE_TYPE_ID',MeasureTypeId) then begin
        Result:=FDataSetRoutes.FieldByName('IS_BASE').AsInteger;
      end;
    end;
  end;

  procedure FillChecks;
  var
    Counter: Integer;
    ParamType: TSgtsRbkParamType;
  begin
    Counter:=0;
    FTempDSParams.First;
    while not FTempDSParams.Eof do begin
      ParamType:=TSgtsRbkParamType(FTempDSParams.FieldByName('PARAM_TYPE').AsInteger);
      if (ParamType=ptIntroduced) then
        FDataSet.FieldByName(GetFieldByCounter('IS_CHECK',Counter)).Value:=Integer(false)
      else
        FDataSet.FieldByName(GetFieldByCounter('IS_CHECK',Counter)).Value:=Integer(true);
      Inc(Counter);
      FTempDSParams.Next;
    end;
  end;

begin
  case FNewRecordMode of
    rmCancel: FDataSet.Cancel;
    rmInput: begin
      FChangePresent:=true;
      FDataSet.FieldByName('IS_CHANGE').Value:=Integer(True);
      FDataSet.FieldByName('JOURNAL_NUM').Value:=JournalNum;
      FDataSet.FieldByName('GROUP_ID').Value:=CreateUniqueId;
      FDataSet.FieldByName('CYCLE_ID').Value:=GetFirstCycleIdByFilter;
      FDataSet.FieldByName('DATE_OBSERVATION').Value:=DateOf(Date);
      FDataSet.FieldByName('WHO_ENTER').Value:=Database.PersonnelId;
      FDataSet.FieldByName('DATE_ENTER').Value:=DateOf(Date);
      FDataSet.FieldByName('IS_BASE').Value:=GetIsBaseDefault;
      FillChecks;
    end;
    rmFill: begin
      FillChecks;
    end;
    rmFillEmpty: begin
      FDataSet.FieldByName('IS_CHANGE').Value:=Integer(False);
      FDataSet.FieldByName('JOURNAL_NUM').Value:=JournalNum;
      FDataSet.FieldByName('GROUP_ID').Value:=CreateUniqueId;
      FDataSet.FieldByName('WHO_ENTER').Value:=Database.PersonnelId;
      FDataSet.FieldByName('DATE_ENTER').Value:=DateOf(Date);
      FDataSet.FieldByName('IS_BASE').Value:=GetIsBaseDefault;
      FillChecks;
    end;
  end;
end;

function TSgtsFunSourceDataMeasureGeneralFrame.GetFirstCycleIdByFilter: Variant;
begin
  Result:=GetValueByCounter('CYCLE_ID',0);
end;

function TSgtsFunSourceDataMeasureGeneralFrame.GetMeasureTypeIdByFilter: Variant;
begin
  Result:=GetValueByCounter('MEASURE_TYPE_ID',0);
end;

function TSgtsFunSourceDataMeasureGeneralFrame.GetObjectIdByFilter: Variant;
begin
  Result:=GetValueByCounter('OBJECT_ID',0);
end;

function TSgtsFunSourceDataMeasureGeneralFrame.GetInstrumentIdByFilter(Counter: Integer): Variant;
begin
  Result:=GetValueByCounter('INSTRUMENT_ID',Counter);
end;

function TSgtsFunSourceDataMeasureGeneralFrame.GetMeasureUnitIdByFilter(Counter: Integer): Variant;
begin
  Result:=GetValueByCounter('MEASURE_UNIT_ID',Counter);
end;

procedure TSgtsFunSourceDataMeasureGeneralFrame.PointNameFieldSetText(Sender: TField; const Text: string);
var
  Column: TColumn;
  Index: Integer;
  Obj: TSgtsPointInfo;
  Converter,ObjectPaths,CoordinateZ: Variant;
begin
  Column:=GetCurrentColumn;
  if Assigned(Column) and
     Assigned(FGrid.InplaceEdit) then begin
    Index:=FGrid.InplaceEdit.PickList.ItemIndex;
    if Index in [0..Column.PickList.Count-1] then begin
      Obj:=TSgtsPointInfo(Column.PickList.Objects[Index]);
      Sender.Value:=Obj.PointName;
      FDataSet.FieldByName('POINT_ID').Value:=Obj.PointId;
      if FDataSetPoints.Locate('POINT_ID',Obj.PointId) then begin
        FDataSet.FieldByName('POINT_PRIORITY').Value:=FDataSetPoints.FieldByName('PRIORITY').Value;
        if FDataSetRoutes.Locate('ROUTE_ID',FDataSetPoints.FieldByName('ROUTE_ID').Value) then
          FDataSet.FieldByName('ROUTE_PRIORITY').Value:=FDataSetRoutes.FieldByName('PRIORITY').Value;
      end;
      FillDefaultInstruments(Obj.PointId,false);
      FDataSet.FieldByName('IS_CHANGE').Value:=Integer(true);
      if GetAdditionalInfo(Obj.PointId,Converter,ObjectPaths,CoordinateZ,';') then begin
        FDataSet.FieldByName('CONVERTER_NAME').Value:=Converter;
        FDataSet.FieldByName('OBJECT_PATHS').Value:=ObjectPaths;
        FDataSet.FieldByName('COORDINATE_Z').Value:=CoordinateZ;
      end;
      FChangePresent:=true;
      GoBrowse(false);
    end;
  end;
end;

procedure TSgtsFunSourceDataMeasureGeneralFrame.DateObservationFieldSetText(Sender: TField; const Text: string);
var
  NewDate: TDate;
begin
  NewDate:=StrToDateDef(Text,0.0);
  if NewDate<>0.0 then begin
    try
      Sender.Value:=NewDate;
      FDataSet.FieldByName('IS_CHANGE').Value:=Integer(true);
      FChangePresent:=true;
      GoBrowse(false);
    except
      On E: Exception do
        ShowError(E.Message);
    end;  
  end;
end;

procedure TSgtsFunSourceDataMeasureGeneralFrame.InstrumentNameFieldSetText(Sender: TField; const Text: string);
var
  Column: TColumn;
  Index: Integer;
  Obj: TSgtsInstrumentInfo;
  FieldId: String;
  Units: TStringList;
  ObjUnit: TSgtsMeasureUnitInfo;
begin
  Column:=GetCurrentColumn;
  if Assigned(Column) and
     Assigned(FGrid.InplaceEdit) then begin
    Index:=FGrid.InplaceEdit.PickList.ItemIndex;
    if Index in [0..Column.PickList.Count-1] then begin
      Obj:=TSgtsInstrumentInfo(Column.PickList.Objects[Index]);
      Sender.Value:=Obj.InstrumentName;
      FieldId:=GetFieldByCounter('INSTRUMENT_ID',GetCounterByField(Sender.FieldName,ctParamInstrument));
      FDataSet.FieldByName(FieldId).Value:=Obj.InstrumentId;

      Units:=TStringList.Create;
      try
        FillMeasureUnits(Units,true,Obj.InstrumentId);
        if Units.Count>0 then begin
          ObjUnit:=TSgtsMeasureUnitInfo(Units.Objects[0]);
          FDataSet.FieldByName(GetFieldByCounter('MEASURE_UNIT_ID',GetCounterByField(Sender.FieldName,ctParamInstrument))).Value:=ObjUnit.MeasureUnitId;
          FDataSet.FieldByName(GetFieldByCounter('MEASURE_UNIT_NAME',GetCounterByField(Sender.FieldName,ctParamInstrument))).Value:=ObjUnit.MeasureUnitName;
        end else begin
          FDataSet.FieldByName(GetFieldByCounter('MEASURE_UNIT_ID',GetCounterByField(Sender.FieldName,ctParamInstrument))).Value:=Null;
          FDataSet.FieldByName(GetFieldByCounter('MEASURE_UNIT_NAME',GetCounterByField(Sender.FieldName,ctParamInstrument))).Value:=Null;
        end;
      finally
        Units.Free;
      end;

      FDataSet.FieldByName('IS_CHANGE').Value:=Integer(true);
      FChangePresent:=true;
      GoBrowse(false);
    end;
  end;
end;

procedure TSgtsFunSourceDataMeasureGeneralFrame.MeasureNameFieldSetText(Sender: TField; const Text: string);
var
  Column: TColumn;
  Index: Integer;
  Obj: TSgtsMeasureUnitInfo;
  FieldId: String;
begin
  Column:=GetCurrentColumn;
  if Assigned(Column) and
     Assigned(FGrid.InplaceEdit) then begin
    Index:=FGrid.InplaceEdit.PickList.ItemIndex;
    if Index in [0..Column.PickList.Count-1] then begin
      Obj:=TSgtsMeasureUnitInfo(Column.PickList.Objects[Index]);
      Sender.Value:=Obj.MeasureUnitName;
      FieldId:=GetFieldByCounter('MEASURE_UNIT_ID',GetCounterByField(Sender.FieldName,ctParamUnit));
      FDataSet.FieldByName(FieldId).Value:=Obj.MeasureUnitId;
      FDataSet.FieldByName('IS_CHANGE').Value:=Integer(true);
      FChangePresent:=true;
      GoBrowse(false);
    end;
  end;
end;

{function FindValueInStrings(Value: String; Strings: TStrings): Boolean;
var
  i: Integer;
  Obj: TSgtsVariant;
  S: String;
begin
  Result:=false;
  for i:=0 to Strings.Count-1 do begin
    Obj:=TSgtsVariant(Strings.Objects[i]);
    if Assigned(Obj) then begin
      S:=VarToStrDef(Obj.Value,'');
      if AnsiSameText(S,Value) then begin
        Result:=true;
        exit;
      end;
    end;
  end;
end;}

procedure TSgtsFunSourceDataMeasureGeneralFrame.ParamValueFieldSetText(Sender: TField; const Text: string);
var
  ParamType: TSgtsRbkParamType;
  NewText: String;
  Value: Variant;
  Counter: Integer;
  Column: TColumn;
  Index: Integer;
  Obj: TSgtsVariant;
begin
  Sender.OnSetText:=nil;
  try
    if DecimalSeparator<>'.' then
      NewText:=ChangeChar(Text,'.',DecimalSeparator)
    else NewText:=ChangeChar(Text,',',DecimalSeparator);
    NewText:=DeleteDuplicate(NewText,DecimalSeparator);
    NewText:=DeleteToOne(NewText,DecimalSeparator);
    Column:=GetCurrentColumn;
    if Assigned(Column) then begin
      if Column.PickList.Count>0 then begin
        Index:=Column.PickList.IndexOf(Text);
        if Index<>-1 then begin
          Obj:=TSgtsVariant(Column.PickList.Objects[Index]);
          if Assigned(Obj) then
            NewText:=VarToStrDef(Obj.Value,'');
        end;
      end;
      Sender.AsString:=NewText;
      ParamType:=GetParamType;
      Counter:=GetCounterByField(Sender.FieldName,ctParamValue);
      if ParamType=ptIntroduced then begin
        Calculate;
        Value:=Sender.Value;
        if Checking(Value,True) then begin
          Sender.Value:=Value;
          FDataSet.FieldByName(GetFieldByCounter('IS_CHECK',Counter)).Value:=Integer(true);
          FDataSet.FieldByName('IS_CHANGE').Value:=Integer(true);
          FChangePresent:=true;
        end else begin
          Sender.Value:=Value;
          FDataSet.FieldByName(GetFieldByCounter('IS_CHECK',Counter)).Value:=Integer(false);
          FDataSet.FieldByName('IS_CHANGE').Value:=Integer(true);
          FChangePresent:=true;
        end;
        Calculate;
      end;
      GoBrowse(false);
    end;  
  finally
    Sender.OnSetText:=ParamValueFieldSetText;
  end;
end;

function TSgtsFunSourceDataMeasureGeneralFrame.GetConfirmProc(Def: TSgtsSelectDef): Variant;
begin
  Result:=0;
  if not VarIsNull(FDataSet.FieldByName('WHO_CONFIRM').Value) then
    Result:=1;
end;

procedure TSgtsFunSourceDataMeasureGeneralFrame.FillPoints(Strings: TStrings);
var
  Obj: TSgtsPointInfo;
begin
  if FDataSetPoints.Active then begin
    Strings.BeginUpdate;
    try
      FDataSetPoints.First;
      while not FDataSetPoints.Eof do begin
        Obj:=TSgtsPointInfo.Create;
        Obj.PointId:=FDataSetPoints.FieldByName('POINT_ID').Value;
        Obj.PointName:=FDataSetPoints.FieldByName('POINT_NAME').AsString;
        Strings.AddObject(Obj.PointName,Obj);
        FDataSetPoints.Next;
      end;
    finally
      Strings.EndUpdate;
    end;
  end;
end;

procedure TSgtsFunSourceDataMeasureGeneralFrame.FillInstruments(Strings: TStrings);

  function InstrumentFind(AInstrumentId: Variant): Boolean;
  var
    i: Integer;
    Obj: TSgtsInstrumentInfo;
  begin
    Result:=false;
    for i:=0 to Strings.Count-1 do begin
      Obj:=TSgtsInstrumentInfo(Strings.Objects[i]);
      if Obj.InstrumentId=AInstrumentId then begin
        Result:=true;
        exit;
      end;
    end;
  end;
  
var
  DS: TSgtsDatabaseCDS;
  Obj: TSgtsInstrumentInfo;
  ParamId: Variant;
  PointId: Variant;
begin
  if FDataSet.Active and
     not FDataSet.IsEmpty then begin
    ParamId:=GetParamId;
    PointId:=FDataSet.FieldByName('POINT_ID').Value;
    if not VarIsNull(ParamId) and
       not VarIsNull(PointId) then begin

      DS:=TSgtsDatabaseCDS.Create(CoreIntf);
      Strings.BeginUpdate;
      try

        DS.ProviderName:=SProviderSelectPointInstruments;
        with DS.SelectDefs do begin
          Clear;
          AddInvisible('INSTRUMENT_ID');
          AddInvisible('INSTRUMENT_NAME');
        end;
        DS.FilterGroups.Clear;
        DS.FilterGroups.Add.Filters.Add('POINT_ID',fcEqual,PointId);
        DS.FilterGroups.Add.Filters.Add('PARAM_ID',fcEqual,ParamId);
        DS.Orders.Clear;
        DS.Orders.Add('PRIORITY',otAsc);
        DS.Open;
        if DS.Active and not DS.IsEmpty then begin
          DS.First;
          while not DS.Eof do begin
            if not InstrumentFind(DS.FieldByName('INSTRUMENT_ID').Value) then begin
              Obj:=TSgtsInstrumentInfo.Create;
              Obj.InstrumentId:=DS.FieldByName('INSTRUMENT_ID').Value;
              Obj.InstrumentName:=DS.FieldByName('INSTRUMENT_NAME').AsString;
              Strings.AddObject(Obj.InstrumentName,Obj);
            end;  
            DS.Next;
          end;
        end;

        DS.Close;
        
        DS.ProviderName:=SProviderSelectParamInstruments;
        with DS.SelectDefs do begin
          Clear;
          AddInvisible('INSTRUMENT_ID');
          AddInvisible('INSTRUMENT_NAME');
        end;
        DS.FilterGroups.Clear;
        DS.FilterGroups.Add.Filters.Add('PARAM_ID',fcEqual,ParamId);
        DS.Orders.Clear;
        DS.Orders.Add('PRIORITY',otAsc);
        DS.Open;
        if DS.Active and not DS.IsEmpty then begin
          DS.First;
          while not DS.Eof do begin
            Obj:=TSgtsInstrumentInfo.Create;
            Obj.InstrumentId:=DS.FieldByName('INSTRUMENT_ID').Value;
            Obj.InstrumentName:=DS.FieldByName('INSTRUMENT_NAME').AsString;
            Strings.AddObject(Obj.InstrumentName,Obj);
            DS.Next;
          end;
        end;

      finally
        Strings.EndUpdate;
        DS.Free;
      end;
    end;
  end;
end;

procedure TSgtsFunSourceDataMeasureGeneralFrame.FillMeasureUnits(Strings: TStrings; ByInstrumentId: Boolean; InstrumentId: Variant);
var
  DS: TSgtsDatabaseCDS;
  Obj: TSgtsMeasureUnitInfo;
  Column: TColumn;
  S: String;
  AInstrumentId: Variant;
begin
  if FDataSet.Active and
     not FDataSet.IsEmpty then begin
    if ByInstrumentId then begin
      AInstrumentId:=InstrumentId;
    end else begin
      Column:=GetCurrentColumn;
      S:=GetFieldByCounter('INSTRUMENT_ID',GetCounterByField(Column.FieldName,ctParamUnit));
      AInstrumentId:=FDataSet.FieldByName(S).Value;
    end;
    if not VarIsNull(AInstrumentId) then begin
      DS:=TSgtsDatabaseCDS.Create(CoreIntf);
      Strings.BeginUpdate;
      try
        DS.ProviderName:=SProviderSelectInstrumentUnits;
        with DS.SelectDefs do begin
          AddInvisible('MEASURE_UNIT_ID');
          AddInvisible('MEASURE_UNIT_NAME');
        end;
        DS.FilterGroups.Add.Filters.Add('INSTRUMENT_ID',fcEqual,AInstrumentId);
        DS.Orders.Add('PRIORITY',otAsc);
        DS.Open;
        if DS.Active and not DS.IsEmpty then begin
          DS.First;
          while not DS.Eof do begin
            Obj:=TSgtsMeasureUnitInfo.Create;
            Obj.MeasureUnitId:=DS.FieldByName('MEASURE_UNIT_ID').Value;
            Obj.MeasureUnitName:=DS.FieldByName('MEASURE_UNIT_NAME').AsString;
            Strings.AddObject(Obj.MeasureUnitName,Obj);
            DS.Next;
          end;
        end;
      finally
        Strings.EndUpdate;
        DS.Free;
      end;
    end;  
  end;
end;

procedure TSgtsFunSourceDataMeasureGeneralFrame.Calculate;

  procedure CalculateLocal(ProcName: String);
  var
    DS: TSgtsDatabaseCDS;

    function AddExecuteValue(FieldName: String): TSgtsExecuteDefValue;
    begin
      Result:=DS.ExecuteDefs.AddValue(FieldName,FDataSet.FieldByName(FieldName).Value);
    end;

  var
    ParamType: TSgtsRbkParamType;
    Provider: TSgtsExecuteProvider;
    Counter: Integer;
    Def: TSgtsExecuteDef;
    Field: TField;
    i: Integer;
    FilterInstrumentId: Variant;
  begin
    DS:=TSgtsDatabaseCDS.Create(CoreIntf);
    Provider:=Database.ExecuteProviders.AddDefault(ProcName);
    FDataSetParams.BeginUpdate(true);
    try
      if Assigned(Provider) then begin
        DS.ProviderName:=ProcName;
        DS.StopException:=true;
        with DS.ExecuteDefs do begin
          AddValue('DATE_OBSERVATION',FDataSet.FieldByName('DATE_OBSERVATION').Value);
          AddValue('CYCLE_ID',FDataSet.FieldByName('CYCLE_ID').Value);
          AddValue('POINT_ID',FDataSet.FieldByName('POINT_ID').Value);
        end;
        Counter:=0;
        FDataSetParams.First;
        while not FDataSetParams.Eof do begin
          ParamType:=TSgtsRbkParamType(FDataSetParams.FieldByName('PARAM_TYPE').AsInteger);
          DS.ExecuteDefs.AddValue(GetFieldByCounter('PARAM_ID',Counter),FDataSetParams.FieldByName('PARAM_ID').Value);
          FilterInstrumentId:=GetInstrumentIdByFilter(Counter);
          if (ParamType=ptIntroduced) and not VarIsNull(FilterInstrumentId) then begin
            AddExecuteValue(GetFieldByCounter('INSTRUMENT_ID',Counter));
            AddExecuteValue(GetFieldByCounter('MEASURE_UNIT_ID',Counter));
          end;
          AddExecuteValue(GetFieldByCounter('VALUE',Counter)).ParamType:=ptInputOutput;
          Inc(Counter);
          FDataSetParams.Next;
        end;
        DS.Execute;
        for i:=0 to DS.ExecuteDefs.Count-1 do begin
          Def:=DS.ExecuteDefs.Items[i];
          if Def.ParamType in [ptOutput, ptInputOutput] then begin
            Field:=FDataSet.FindField(Def.FieldName);
            if Assigned(Field) then begin
              Field.Value:=Def.Value;
            end;
          end;
        end;
      end;
    finally
      FDataSetParams.EndUpdate;
      Database.ExecuteProviders.Remove(Provider);
      DS.Free;
    end;
  end;

var
  OldCursor: TCursor;
  ProcName: String;
  Counter1,Counter2: Integer;
  ColumnType: TSgtsFunSourceDataMeasureGeneralColumnType;
  DefaultValue: Variant;
  Field: TField;
begin
  if FDataSet.Active and
     not FDataSet.IsEmpty and
     IsEdit then begin
    OldCursor:=Screen.Cursor;
    Screen.Cursor:=crHourGlass;
    try
      ColumnType:=GetColumnType(GetCurrentColumn);
      if ColumnType=ctParamValue then begin
        Counter1:=GetCounterByField(GetCurrentColumn.FieldName,ColumnType);
        Counter2:=0;
        FDataSetParams.First;
        while not FDataSetParams.Eof do begin
          Field:=FDataSet.FieldByName(GetFieldByCounter('VALUE',Counter2));
          DefaultValue:=GetValueByCounter('DEFAULT_VALUE',Counter2);
          if VarIsNull(Field.Value) then
            Field.Value:=DefaultValue;

          ProcName:=FDataSetParams.FieldByName('ALGORITHM_PROC_NAME').AsString;
          if (Counter1=Counter2) and
             (Trim(ProcName)<>'') then begin
            CalculateLocal(ProcName);
            break;
          end;
          Inc(Counter2);
          FDataSetParams.Next;
        end;
      end;
    finally
      Screen.Cursor:=OldCursor;
    end;
  end;
end;

function TSgtsFunSourceDataMeasureGeneralFrame.CheckRecord(CheckChanges: Boolean; WithMessage: Boolean=true;
                                                           WithParam: Boolean=false; WithChecking: Boolean=true): Boolean;
var
  Column: TColumn;

  procedure ResultFalse;
  begin
    if WithMessage then begin
      ShowError(Format(SNeedElementValue,[Column.Title.Caption]));
      FGrid.SelectedIndex:=Column.Index;
    end;  
    Result:=false;
  end;

  procedure ResultFalseEx;
  var
    Ret: Integer;
  begin
    if WithMessage then begin
      Ret:=ShowQuestion(Format(SFieldValueNotChecking,[Column.Title.Caption]),mbNo);
      Result:=Ret<>mrNo;
      if not Result then
        FGrid.SelectedIndex:=Column.Index;
    end else
      Result:=false;
  end;

var
  i: Integer;
  Flag: Boolean;
  ColumnType: TSgtsFunSourceDataMeasureGeneralColumnType;
  Counter: Integer;
  FilterInstrumentId: Variant;
  FilterMeasureUnitId: Variant;
begin
  Result:=true;
  if FDataSet.Active and
     not FDataSet.IsEmpty then begin
    Flag:=true;
    if CheckChanges then
      Flag:=Boolean(FDataSet.FieldByName('IS_CHANGE').AsInteger);
    if Flag then begin
      for i:=0 to FGrid.Columns.Count-1 do begin
        Column:=FGrid.Columns[i];
        ColumnType:=GetColumnType(Column);
        case ColumnType of
          ctPointName: begin
            if VarIsNull(FDataSet.FieldByName('POINT_ID').Value) or
               (Trim(FDataSet.FieldByName('POINT_NAME').AsString)='') then begin
              ResultFalse;
              break;
            end;
          end;
          ctDate: begin
            if VarIsNull(FDataSet.FieldByName('DATE_OBSERVATION').Value) then begin
              ResultFalse;
              break;
            end;
          end;
          ctParamInstrument: begin
            Counter:=GetCounterByField(Column.FieldName,ColumnType);
            FilterInstrumentId:=GetInstrumentIdByFilter(Counter);
            if not VarIsNull(FilterInstrumentId) then
              if VarIsNull(FDataSet.FieldByName(GetFieldByCounter('INSTRUMENT_ID',Counter)).Value) or
                 (Trim(FDataSet.FieldByName(GetFieldByCounter('INSTRUMENT_NAME',Counter)).AsString)='') then begin
                ResultFalse;
                break;
              end;
          end;
          ctParamUnit: begin
            Counter:=GetCounterByField(Column.FieldName,ColumnType);
            FilterMeasureUnitId:=GetMeasureUnitIdByFilter(Counter);
            if not VarIsNull(FilterMeasureUnitId) then
              if VarIsNull(FDataSet.FieldByName(GetFieldByCounter('MEASURE_UNIT_ID',Counter)).Value) or
                 (Trim(FDataSet.FieldByName(GetFieldByCounter('MEASURE_UNIT_NAME',Counter)).AsString)='') then begin
                ResultFalse;
                break;
              end;
          end;
          ctParamValue: begin
            if WithParam then begin
              if ParamIsConfirm(Column) then begin
                if (GetParamTypeByColumn(Column)=ptIntroduced) and
                    VarIsNull(FDataSet.FieldByName(GetFieldByCounter('VALUE',GetCounterByField(Column.FieldName,ColumnType))).Value) then begin
                  ResultFalse;
                  break;
                end;
              end;
            end;
          end;
        end;
      end;

      if Result and WithChecking then
        for i:=0 to FGrid.Columns.Count-1 do begin
          Column:=FGrid.Columns[i];
          ColumnType:=GetColumnType(Column);
          case ColumnType of
            ctParamValue: begin
              if WithParam then begin
                if ParamIsConfirm(Column) then begin
                  if (VarToIntDef(FDataSet.FieldByName(GetFieldByCounter('IS_CHECK',GetCounterByField(Column.FieldName,ColumnType))).Value,0)=0) then begin
                    ResultFalseEx;
                    break;
                  end;
                end;
              end;
            end;
          end;
        end;

    end;
  end;
end;

function TSgtsFunSourceDataMeasureGeneralFrame.SaveRecord: Boolean;
var
  JournalNum: Variant;
  Note: Variant;
  CycleId: Variant;
  PointId: Variant;
  GroupId: Variant;
  IsBase: Variant;
  Priority: Variant;
  WhoEnter: Variant;
  DateEnter: Variant;
  WhoConfirm: Variant;
  DateConfirm: Variant;
  DateObservation: Variant;

  procedure SaveLocal;
  var
    Counter: Integer;
    JournalFieldId: Variant;
    ParamId: Variant;
    ParamValue: Variant;
    InstrumentId: Variant;
    MeasureUnitId: Variant;
    IsCheck: Variant;

    procedure InsertLocal;
    var
      DS: TSgtsDatabaseCDS;
      AKey: TSgtsExecuteDefKey;
      Field: TField;
    begin
      DS:=TSgtsDatabaseCDS.Create(CoreIntf);
      try
        DS.ProviderName:=SProviderInsertJournalField;
        DS.StopException:=true;
        with DS.ExecuteDefs do begin
          AKey:=AddKey('JOURNAL_FIELD_ID');
          AddInvisible('JOURNAL_NUM').Value:=JournalNum;
          AddInvisible('NOTE').Value:=Note;
          AddInvisible('CYCLE_ID').Value:=CycleId;
          AddInvisible('POINT_ID').Value:=PointId;
          AddInvisible('PARAM_ID').Value:=ParamId;
          AddInvisible('INSTRUMENT_ID').Value:=InstrumentId;
          AddInvisible('MEASURE_UNIT_ID').Value:=MeasureUnitId;
          AddInvisible('VALUE').Value:=ParamValue;
          AddInvisible('DATE_OBSERVATION').Value:=DateObservation;
          AddInvisible('WHO_ENTER').Value:=WhoEnter;
          AddInvisible('DATE_ENTER').Value:=DateEnter;
          AddInvisible('WHO_CONFIRM').Value:=WhoConfirm;
          AddInvisible('DATE_CONFIRM').Value:=DateConfirm;
          AddInvisible('GROUP_ID').Value:=GroupId;
          AddInvisible('PRIORITY').Value:=Priority;
          AddInvisible('IS_BASE').Value:=IsBase;
          AddInvisible('IS_CHECK').Value:=IsCheck;
          AddInvisible('MEASURE_TYPE_ID').Value:=GetMeasureTypeIdByFilter;
        end;
        DS.Execute;
        Result:=Result and DS.ExecuteSuccess;

        if Result then begin
          Field:=FDataSet.FindField(GetFieldByCounter('JOURNAL_FIELD_ID',Counter));
          if Assigned(Field) then begin
            FDataSet.Edit;
            Field.Value:=AKey.Value;
            FDataSet.Post;
          end;
        end;  
      finally
        DS.Free;
      end;
    end;

    procedure UpdateLocal;
    var
      DS: TSgtsDatabaseCDS;
    begin
      DS:=TSgtsDatabaseCDS.Create(CoreIntf);
      try
        DS.ProviderName:=SProviderUpdateJournalField;
        DS.StopException:=true;
        with DS.ExecuteDefs do begin
          AddKeyLink('JOURNAL_FIELD_ID').Value:=JournalFieldId;
          AddInvisible('JOURNAL_NUM').Value:=JournalNum;
          AddInvisible('NOTE').Value:=Note;
          AddInvisible('CYCLE_ID').Value:=CycleId;
          AddInvisible('POINT_ID').Value:=PointId;
          AddInvisible('PARAM_ID').Value:=ParamId;
          AddInvisible('INSTRUMENT_ID').Value:=InstrumentId;
          AddInvisible('MEASURE_UNIT_ID').Value:=MeasureUnitId;
          AddInvisible('VALUE').Value:=ParamValue;
          AddInvisible('DATE_OBSERVATION').Value:=DateObservation;
          AddInvisible('WHO_ENTER').Value:=WhoEnter;
          AddInvisible('DATE_ENTER').Value:=DateEnter;
          AddInvisible('WHO_CONFIRM').Value:=WhoConfirm;
          AddInvisible('DATE_CONFIRM').Value:=DateConfirm;
          AddInvisible('GROUP_ID').Value:=GroupId;
          AddInvisible('PRIORITY').Value:=Priority;
          AddInvisible('IS_BASE').Value:=IsBase;
          AddInvisible('IS_CHECK').Value:=IsCheck;
          AddInvisible('MEASURE_TYPE_ID').Value:=GetMeasureTypeIdByFilter;
        end;
        DS.Execute;
        Result:=Result and DS.ExecuteSuccess;
      finally
        DS.Free;
      end;
    end;

    procedure DeleteLocal;
    var
      DS: TSgtsDatabaseCDS;
    begin
      DS:=TSgtsDatabaseCDS.Create(CoreIntf);
      try
        DS.ProviderName:=SProviderDeleteJournalField;
        DS.StopException:=true;
        DS.ExecuteDefs.AddKeyLink('JOURNAL_FIELD_ID').Value:=JournalFieldId;
        DS.Execute;
        Result:=Result and DS.ExecuteSuccess;
      finally
        DS.Free;
      end;
    end;

  var
    Field: TField;
    RecordExists: Boolean;
  begin
    CoreIntf.MainForm.Progress2(0,FDataSetParams.RecordCount,0);
    try
      Counter:=0;
      FDataSetParams.First;
      while not FDataSetParams.Eof do begin
        JournalFieldId:=Null;
        Field:=FDataSet.FindField(GetFieldByCounter('JOURNAL_FIELD_ID',Counter));
        if Assigned(Field) then
          JournalFieldId:=Field.Value;

        ParamId:=FDataSetParams.FieldByName('PARAM_ID').Value;

        ParamValue:=Null;
        Field:=FDataSet.FindField(GetFieldByCounter('VALUE',Counter));
        if Assigned(Field) then
          ParamValue:=Field.Value;

        InstrumentId:=Null;
        Field:=FDataSet.FindField(GetFieldByCounter('INSTRUMENT_ID',Counter));
        if Assigned(Field) then
          InstrumentId:=Field.Value;

        MeasureUnitId:=Null;
        Field:=FDataSet.FindField(GetFieldByCounter('MEASURE_UNIT_ID',Counter));
        if Assigned(Field) then
          MeasureUnitId:=Field.Value;

        IsCheck:=Null;
        Field:=FDataSet.FindField(GetFieldByCounter('IS_CHECK',Counter));
        if Assigned(Field) then
          IsCheck:=Field.Value;

        if not VarIsNull(ParamValue) then begin
          RecordExists:=not VarIsNull(JournalFieldId);
          if not RecordExists then
            InsertLocal
          else UpdateLocal;
        end else
          if not VarIsNull(JournalFieldId) then
            DeleteLocal;

        Inc(Counter);
        CoreIntf.MainForm.Progress2(0,FDataSetParams.RecordCount,Counter);
        FDataSetParams.Next;
      end;
    finally
     CoreIntf.MainForm.Progress2(0,0,0);
    end;
  end;

var
  OldCursor: TCursor;
  IsChange: Boolean;
begin
  Result:=true;
  if FDataSet.Active and
     not FDataSet.IsEmpty and
     IsEdit then begin

    OldCursor:=Screen.Cursor;
    Screen.Cursor:=crHourGlass;
    try
      IsChange:=Boolean(FDataSet.FieldByName('IS_CHANGE').AsInteger);
      if IsChange then begin
        JournalNum:=FDataSet.FieldByName('JOURNAL_NUM').Value;
        Note:=FDataSet.FieldByName('NOTE').Value;
        CycleId:=FDataSet.FieldByName('CYCLE_ID').Value;
        PointId:=FDataSet.FieldByName('POINT_ID').Value;
        GroupId:=FDataSet.FieldByName('GROUP_ID').Value;
        IsBase:=FDataSet.FieldByName('IS_BASE').Value;
        Priority:=FDataSet.RecNo;
        WhoEnter:=FDataSet.FieldByName('WHO_ENTER').Value;
        DateEnter:=FDataSet.FieldByName('DATE_ENTER').Value;
        WhoConfirm:=FDataSet.FieldByName('WHO_CONFIRM').Value;
        DateConfirm:=FDataSet.FieldByName('DATE_CONFIRM').Value;
        DateObservation:=FDataSet.FieldByName('DATE_OBSERVATION').Value;

        SaveLocal;

        if Result then begin
          FDataSet.Edit;
          FDataSet.FieldByName('IS_CHANGE').AsInteger:=Integer(false);
          FDataSet.Post;
        end;
      end;
    finally
      Screen.Cursor:=OldCursor;
    end;
  end;
end;

function TSgtsFunSourceDataMeasureGeneralFrame.Save: Boolean;
var
  APosition: Integer;
begin
  Result:=Inherited Save;
  if CanSave then begin
    CoreIntf.MainForm.Progress(0,FDataSet.RecordCount,0);
    GoBrowse(true);
    FGrid.VisibleRowNumber:=false;
//    FDataSet.BeginUpdate(true);
    try
      APosition:=1;
      InProgress:=true;
      CancelProgress:=false;
      FDataSet.First;
      while not FDataSet.Eof do begin
        Application.ProcessMessages;
        if CancelProgress then
          break;
        if CheckRecord(true) then begin
          SaveRecord;
        end else begin
          Result:=false;
          Exit;
        end;
        CoreIntf.MainForm.Progress(0,FDataSet.RecordCount,APosition);
        Inc(APosition);
        FDataSet.Next;
      end;
      if not CancelProgress then begin
        FDataSet.First;
        FChangePresent:=false;
        Result:=True;
      end;
    finally
//      FDataSet.EndUpdate(true);
      InProgress:=false;
      FGrid.VisibleRowNumber:=true;
      FGrid.UpdateRowNumber;
      UpdateButtons;
      CoreIntf.MainForm.Progress(0,0,0);
    end;
  end;
end;

function TSgtsFunSourceDataMeasureGeneralFrame.CanSave: Boolean;
begin
  Result:=FDataSet.Active and
          not FDataSet.IsEmpty and
          FChangePresent;
end;

function TSgtsFunSourceDataMeasureGeneralFrame.GetChangeArePresent: Boolean;
begin
  Result:=FChangePresent;
end;

procedure TSgtsFunSourceDataMeasureGeneralFrame.SetChangeArePresent(Value: Boolean);
begin
  FChangePresent:=Value;
end;

procedure TSgtsFunSourceDataMeasureGeneralFrame.BeforeRefresh;
begin
  FGrid.Visible:=false;
  PanelGrid.Visible:=false;
  PanelInfo.Visible:=false;
  PanelStatus.Update;
end;

procedure TSgtsFunSourceDataMeasureGeneralFrame.AfterRefresh;
begin
  FGrid.Visible:=true;
  PanelGrid.Visible:=true;
  PanelInfo.Visible:=true;
  if FGrid.CanFocus then
    FGrid.SetFocus;
end;

function TSgtsFunSourceDataMeasureGeneralFrame.GetActiveControl: TWinControl;
begin
  Result:=FGrid;
end;

procedure TSgtsFunSourceDataMeasureGeneralFrame.Insert;
begin
  if CanInsert then begin
    FDataSet.Append;
  end;
end;

function TSgtsFunSourceDataMeasureGeneralFrame.CanInsert: Boolean;
begin
  Result:=IsCanInsert and
          FDataSet.Active and
          IsEdit;
end;

procedure TSgtsFunSourceDataMeasureGeneralFrame.Update;
var
  ColumnType: TSgtsFunSourceDataMeasureGeneralColumnType;
begin
  if CanUpdate then begin
    GoEdit(true,true);
    ColumnType:=GetColumnType(GetCurrentColumn);
    GoSelect((ColumnType in PickListColumnTypes));
  end;
end;

function TSgtsFunSourceDataMeasureGeneralFrame.CanUpdate: Boolean;
var
  ColumnType: TSgtsFunSourceDataMeasureGeneralColumnType;
  Flag: Boolean;
begin
  Result:=IsCanUpdate and
          FDataSet.Active and
          IsEdit;
  if Result then begin
    Flag:=false;
    ColumnType:=GetColumnType(GetCurrentColumn);
    if (ColumnType in EditColumnTypes) and
       not GetIsConfirm then begin
      Flag:=true;
      if ColumnType in PickListColumnTypes then
        Flag:=GetCurrentColumn.PickList.Count>0;
      if ColumnType in ParamColumnTypes then
        Flag:=GetParamType=ptIntroduced;
    end;
    Result:=Result and Flag;
  end;
end;

procedure TSgtsFunSourceDataMeasureGeneralFrame.Delete;
var
  Counter: Integer;
  Field: TField;
  DS: TSgtsDatabaseCDS;
begin
  if CanDelete then begin
    FDataSet.BeginUpdate(true);
    CoreIntf.MainForm.Progress(0,FDataSetParams.RecordCount,0);
    try
      Counter:=0;
      FDataSetParams.First;
      while not FDataSetParams.Eof do begin
        Field:=FDataSet.FindField(GetFieldByCounter('JOURNAL_FIELD_ID',Counter));
        if Assigned(Field) and not VarIsNull(Field.Value) then begin
          DS:=TSgtsDatabaseCDS.Create(CoreIntf);
          try
            DS.ProviderName:=SProviderDeleteJournalField;
            DS.StopException:=true;
            DS.ExecuteDefs.AddKeyLink('JOURNAL_FIELD_ID').Value:=Field.Value;
            DS.Execute;
          finally
            DS.Free;
          end;
        end;
        Inc(Counter);
        CoreIntf.MainForm.Progress(0,FDataSetParams.RecordCount,Counter);
        FDataSetParams.Next;
      end;
      FDataSet.Delete;
      UpdateButtons;
    finally
      CoreIntf.MainForm.Progress(0,0,0);
      FDataSet.EndUpdate;
    end;
  end;
end;

function TSgtsFunSourceDataMeasureGeneralFrame.CanDelete: Boolean;
begin
  Result:=IsCanDelete and
          FDataSet.Active and
          not FDataSet.IsEmpty and
          IsEdit and
          not (FDataSet.State in [dsInsert,dsEdit]) and
          not GetIsConfirm;
end;

function TSgtsFunSourceDataMeasureGeneralFrame.GetDataSet: TSgtsCDS;
begin
  Result:=FDataSet;
end;

procedure TSgtsFunSourceDataMeasureGeneralFrame.Confirm;
var
  Flag: Boolean;
  ADate: TDate;
begin
  if CanConfirm then begin
    ADate:=DateOf(Date);
    Flag:=Boolean(FDataSet.FieldByName('IS_CONFIRM').AsInteger);
    if not Flag then begin
      if CheckRecord(false,true,true) then begin
        FDataSet.Edit;
        FDataSet.FieldByName('WHO_CONFIRM').Value:=Database.PersonnelId;
        FDataSet.FieldByName('DATE_CONFIRM').Value:=ADate;
        FDataSet.FieldByName('IS_CHANGE').Value:=Integer(true);
        FChangePresent:=true;
        FDataSet.Post;
      end;
    end else begin
      FDataSet.Edit;
      FDataSet.FieldByName('WHO_CONFIRM').Value:=Null;
      FDataSet.FieldByName('DATE_CONFIRM').Value:=Null;
      FDataSet.FieldByName('IS_CHANGE').Value:=Integer(true);
      FChangePresent:=true;
      FDataSet.Post;
    end;
    SetAdditionalInfo;
    UpdateButtons;
  end;
end;

function TSgtsFunSourceDataMeasureGeneralFrame.CanConfirm: Boolean;
begin
  Result:=IsCanConfirm and
          Assigned(Database) and
          FDataSet.Active and
          not FDataSet.IsEmpty and
          IsEdit;
end;

procedure TSgtsFunSourceDataMeasureGeneralFrame.ViewPointInfo(AsPoint: Boolean);
var
  AIface: TSgtsFunPointManagementIface;
  Data: String;
  AFilterGroups: TSgtsGetRecordsConfigFilterGroups;
  AMeasureTypeId: Variant;
begin
  AIface:=TSgtsFunPointManagementIface.Create(CoreIntf);
  AFilterGroups:=TSgtsGetRecordsConfigFilterGroups.Create;
  try
    AIface.IsCanSelect:=false;
    AIface.FilterOnShow:=false;
    AMeasureTypeId:=GetMeasureTypeIdByFilter;
    AFilterGroups.Add.Filters.Add('MEASURE_TYPE_ID',fcEqual,AMeasureTypeId);
    if AsPoint then begin
      AIface.SelectByUnionType('UNION_ID;UNION_TYPE',VarArrayOf([FDataSet.FieldByName('POINT_ID').Value,utPoint]),Data,utPoint,AFilterGroups,false);
    end else begin
      AIface.SelectByUnionType('UNION_ID;UNION_TYPE',VarArrayOf([FDataSet.FieldByName('POINT_ID').Value,utConverter]),Data,utConverter,AFilterGroups,false);
    end;
  finally
    AFilterGroups.Free;
    AIface.Free;
  end;
end;

procedure TSgtsFunSourceDataMeasureGeneralFrame.ViewObjectTreeInfo;
var
  Column: TColumn;
  ColumnType: TSgtsFunSourceDataMeasureGeneralColumnType;
  AIface: TSgtsFunSourceDataObjectTreesIface;
  Field: TField;
begin
  exit;
  Column:=GetCurrentColumn;
  ColumnType:=GetColumnType(Column);
  Field:=FDataSet.FindField(GetFieldByCounter('OBJECT_ID',GetCounterByField(Column.FieldName,ColumnType)));
  if Assigned(Field) then begin
    AIface:=TSgtsFunSourceDataObjectTreesIface.CreateByObjectId(CoreIntf,Field.Value);
    try
      AIface.Init;
      AIface.AsModal:=true;
      AIface.DatabaseLink;
      AIface.Refresh;
      AIface.Detail;
    finally
      AIface.Free;
    end;
  end;  
end;

procedure TSgtsFunSourceDataMeasureGeneralFrame.ViewInstrumentInfo;
var
  Column: TColumn;
  ColumnType: TSgtsFunSourceDataMeasureGeneralColumnType;
  AIface: TSgtsFunSourceDataInstrumentsIface;
  Field: TField;
begin
  Column:=GetCurrentColumn;
  ColumnType:=GetColumnType(Column);
  Field:=FDataSet.FindField(GetFieldByCounter('INSTRUMENT_ID',GetCounterByField(Column.FieldName,ColumnType)));
  if Assigned(Field) then begin
    AIface:=TSgtsFunSourceDataInstrumentsIface.CreateByInstrumentId(CoreIntf,Field.Value);
    try
      AIface.Init;
      AIface.AsModal:=true;
      AIface.DatabaseLink;
      AIface.Refresh;
      AIface.Detail;
    finally
      AIface.Free;
    end;
  end;  
end;

procedure TSgtsFunSourceDataMeasureGeneralFrame.ViewMeasureUnitInfo;
var
  Column: TColumn;
  ColumnType: TSgtsFunSourceDataMeasureGeneralColumnType;
  AIface: TSgtsFunSourceDataMeasureUnitsIface;
  Field: TField;
begin
  Column:=GetCurrentColumn;
  ColumnType:=GetColumnType(Column);
  Field:=FDataSet.FindField(GetFieldByCounter('MEASURE_UNIT_ID',GetCounterByField(Column.FieldName,ColumnType)));
  if Assigned(Field) then begin
    AIface:=TSgtsFunSourceDataMeasureUnitsIface.CreateByMeasureUnitId(CoreIntf,Field.Value);
    try
      AIface.Init;
      AIface.AsModal:=true;
      AIface.DatabaseLink;
      AIface.Refresh;
      AIface.Detail;
    finally
      AIface.Free;
    end;
  end;
end;

procedure TSgtsFunSourceDataMeasureGeneralFrame.Detail;
var
  ColumnType: TSgtsFunSourceDataMeasureGeneralColumnType;
begin
  if CanDetail then begin
    ColumnType:=GetColumnType(GetCurrentColumn);
    case ColumnType of
      ctPointName, ctConverter, ctCoordinateZ: ViewPointInfo(not (ColumnType=ctConverter));
      ctObjectPaths: ViewObjectTreeInfo;
      ctParamInstrument: ViewInstrumentInfo;
      ctParamUnit: ViewMeasureUnitInfo;
    end;
  end;
end;

function TSgtsFunSourceDataMeasureGeneralFrame.CanDetail: Boolean;
var
  Column: TColumn;
  ColumnType: TSgtsFunSourceDataMeasureGeneralColumnType;
begin
  Result:=IsCanDetail and
          FDataSet.Active and
          not FDataSet.IsEmpty;
  if Result then begin
    Column:=GetCurrentColumn;
    ColumnType:=GetColumnType(Column);
    if Result then begin
      case ColumnType of
        ctPointName,ctConverter,ctCoordinateZ: begin
          Result:=not VarIsNull(FDataSet.FieldByName('POINT_ID').Value) and
                  (Trim(FDataSet.FieldByName('POINT_NAME').AsString)<>'');
        end;
        ctObjectPaths: begin
       {   Result:=not VarIsNull(FDataSet.FieldByName('OBJECT_ID').Value) and
                  (Trim(FDataSet.FieldByName('OBJECT_PATHS').AsString)<>'');}
          Result:=false;        
        end;
        ctParamInstrument: begin
          Result:=not VarIsNull(FDataSet.FieldByName(GetFieldByCounter('INSTRUMENT_ID',GetCounterByField(Column.FieldName,ColumnType))).Value) and
                 (Trim(FDataSet.FieldByName(GetFieldByCounter('INSTRUMENT_NAME',GetCounterByField(Column.FieldName,ColumnType))).AsString)<>'');
        end;
        ctParamUnit: begin
          Result:=not VarIsNull(FDataSet.FieldByName(GetFieldByCounter('MEASURE_UNIT_ID',GetCounterByField(Column.FieldName,ColumnType))).Value) and
                 (Trim(FDataSet.FieldByName(GetFieldByCounter('MEASURE_UNIT_NAME',GetCounterByField(Column.FieldName,ColumnType))).AsString)<>'');
        end;
      else
        Result:=false;
      end;
    end;
  end;
end;

function TSgtsFunSourceDataMeasureGeneralFrame.GetCycleNum: String;
begin
  Result:='';
  if FDataSet.Active and
     not FDataSet.IsEmpty then begin
    if FDataSetCycles.Locate('CYCLE_ID',FDataSet.FieldByName('CYCLE_ID').Value) then begin
      Result:=Format(SCycleFormat,[FDataSetCycles.FieldByName('CYCLE_NUM').AsInteger,
                                   GetMonthNameByIndex(FDataSetCycles.FieldByName('CYCLE_MONTH').AsInteger),
                                   FDataSetCycles.FieldByName('CYCLE_YEAR').AsInteger]);
    end;
  end;
end;

function TSgtsFunSourceDataMeasureGeneralFrame.GetRouteName: String;
begin
  Result:='';
  if FDataSet.Active and
     not FDataSet.IsEmpty then begin
    if FDataSetPoints.Locate('POINT_ID',FDataSet.FieldByName('POINT_ID').Value) then begin
      Result:=FDataSetPoints.FieldByName('ROUTE_NAME').AsString;
    end;
  end;
end;

procedure TSgtsFunSourceDataMeasureGeneralFrame.MenuItemConfirmCheckAllClick(
  Sender: TObject);
begin
  ConfirmAll(True);
end;

procedure TSgtsFunSourceDataMeasureGeneralFrame.MenuItemConfirmUncheckAllClick(
  Sender: TObject);
begin
  ConfirmAll(False);
end;

procedure TSgtsFunSourceDataMeasureGeneralFrame.PopupMenuConfirmPopup(
  Sender: TObject);
begin
  MenuItemConfirmCheckAll.Enabled:=CanConfirm;
  MenuItemConfirmUnCheckAll.Enabled:=MenuItemConfirmCheckAll.Enabled;
end;

procedure TSgtsFunSourceDataMeasureGeneralFrame.ConfirmAll(Checked: Boolean);

  function LocalCanConfirm: Boolean;
  var
    i: Integer;
    Column: TColumn;
    ColumnType: TSgtsFunSourceDataMeasureGeneralColumnType;
    Value: Variant;
  begin
    Result:=false;
    if VarIsNull(FDataSet.FieldByName('DATE_CONFIRM').Value) then begin
      for i:=0 to FGrid.Columns.Count-1 do begin
        Column:=FGrid.Columns[i];
        ColumnType:=GetColumnType(Column);
        if (ColumnType=ctParamValue) and ParamIsConfirm(Column) then begin
          Value:=FDataSet.FieldByName(GetFieldByCounter('VALUE',GetCounterByField(Column.FieldName,ColumnType))).Value;
          if VarIsNull(Value) then
            exit;
        end;
      end;
      Result:=true;
    end;
  end;

var
  ADate: TDate;
begin
  if CanConfirm then begin
    FDataSet.BeginUpdate(true);
    try
      ADate:=DateOf(Date);
      FDataSet.First;
      while not FDataSet.Eof do begin
        if Checked then begin
          if LocalCanConfirm then begin
            FDataSet.UpdatePosInControls;
            if CheckRecord(false,true,true) then begin
              FDataSet.Edit;
              FDataSet.FieldByName('WHO_CONFIRM').Value:=Database.PersonnelId;
              FDataSet.FieldByName('DATE_CONFIRM').Value:=ADate;
              FDataSet.FieldByName('IS_CHANGE').Value:=Integer(true);
              FChangePresent:=true;
              FDataSet.Post;
             end else begin
               FDataSet.ThrowBookmark;
               break;
             end;
          end;
        end else begin
          if not VarIsNull(FDataSet.FieldByName('DATE_CONFIRM').Value) then begin
            FDataSet.Edit;
            FDataSet.FieldByName('WHO_CONFIRM').Value:=Null;
            FDataSet.FieldByName('DATE_CONFIRM').Value:=Null;
            FDataSet.FieldByName('IS_CHANGE').Value:=Integer(true);
            FChangePresent:=true;
            FDataSet.Post;
          end;
        end;
        FDataSet.Next;
      end;
    finally
      FDataSet.EndUpdate(true);
    end;
  end;
end;

procedure TSgtsFunSourceDataMeasureGeneralFrame.SetIsBase;
var
  FlagCheck: Boolean;
  FlagEdit: Boolean;
begin
  if IsCanUpdate and
     FDataSet.Active and
     not FDataSet.IsEmpty and
     IsEdit and
     not GetIsConfirm then begin
    FlagEdit:=true;
    FlagCheck:=Boolean(FDataSet.FieldByName('IS_BASE').AsInteger);
    if not FlagCheck then begin
      FDataSet.BeginUpdate(true);
      try
        FDataSet.Filter:=Format('CYCLE_ID=%s AND POINT_ID=%s AND DATE_OBSERVATION=%s',
                                [QuotedStr(FDataSet.FieldByName('CYCLE_ID').AsString),
                                 QuotedStr(FDataSet.FieldByName('POINT_ID').AsString),
                                 QuotedStr(FDataSet.FieldByName('DATE_OBSERVATION').AsString)]);
        FDataSet.Filtered:=true;
        FDataSet.First;
        while not FDataSet.Eof do begin
          if Boolean(FDataSet.FieldByName('IS_BASE').AsInteger) then begin
            if not Boolean(FDataSet.FieldByName('IS_CONFIRM').AsInteger) then begin
              FDataSet.Edit;
              FDataSet.FieldByName('IS_BASE').AsInteger:=Integer(false);
              FDataSet.FieldByName('IS_CHANGE').Value:=Integer(true);
              FChangePresent:=true;
              FDataSet.Post;
            end else
              FlagEdit:=false;  
          end;
          FDataSet.Next;
        end;
      finally
        FDataSet.EndUpdate(true);
      end;
    end;
    if FlagEdit then begin
      FDataSet.Edit;
      FDataSet.FieldByName('IS_BASE').AsInteger:=Integer(not FlagCheck);
      FDataSet.FieldByName('IS_CHANGE').Value:=Integer(true);
      FChangePresent:=true;
      FDataSet.Post;
    end;  
  end;
end;

function TSgtsFunSourceDataMeasureGeneralFrame.GridGetFontColor(Sender: TObject; Column: TColumn; var FontStyles: TFontStyles): TColor;
var
  ColumnType: TSgtsFunSourceDataMeasureGeneralColumnType;
  Counter: Integer;
  IsChange: Boolean;
  IsCheck: Boolean;
begin
  Result:=Column.Font.Color;
  FontStyles:=Column.Font.Style;
  if FDataSet.Active and not FDataSet.IsEmpty then begin
    ColumnType:=GetColumnType(Column);
    IsChange:=Boolean(FDataSet.FieldByName('IS_CHANGE').AsInteger);
    if (ColumnType=ctParamValue) then begin
      Counter:=GetCounterByField(Column.FieldName,ColumnType);
      IsCheck:=Boolean(FDataSet.FieldByName(GetFieldByCounter('IS_CHECK',Counter)).AsInteger);
      if not IsCheck then begin
        Result:=clRed;
        FontStyles:=[fsBold];
      end else
        if isChange then
          Result:=clGreen;
    end else
      if isChange then
        Result:=clGreen;
  end;
end;

procedure TSgtsFunSourceDataMeasureGeneralFrame.DBMemoNoteExit(Sender: TObject);
begin
  GoBrowse(true);
end;

procedure TSgtsFunSourceDataMeasureGeneralFrame.DBMemoNoteKeyDown(
  Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if FDataSet.Active and not FDataSet.IsEmpty then begin
    GoEdit(False,True,False);
    FDataSet.FieldByName('IS_CHANGE').Value:=Integer(true);
    FChangePresent:=true;
  end;
end;

function TSgtsFunSourceDataMeasureGeneralFrame.Checking(var Value: Variant; AVisible: Boolean=true): Boolean;
var
  Column: TColumn;
  ColumnType: TSgtsFunSourceDataMeasureGeneralColumnType;
  AIface: TSgtsCheckingIface;
  Checked: Boolean;
  OldValue: Variant;
begin
  Result:=true;
  if FDataSet.Active and
     not FDataSet.IsEmpty then begin
    Column:=GetCurrentColumn;
    if Assigned(Column) then begin
      ColumnType:=GetColumnType(Column);
      if ColumnType=ctParamValue then begin
        if not VarIsNull(Value) then begin

          OldValue:=Value;
          
          AIface:=TSgtsCheckingIface.Create(CoreIntf);
          try
            AIface.DateObservation:=FDataSet.FieldByName('DATE_OBSERVATION').Value;
            AIface.CycleId:=FDataSet.FieldByName('CYCLE_ID').Value;
            AIface.CycleNum:=GetCycleNum;
            AIface.MeasureTypeId:=GetMeasureTypeIdByFilter;
            AIface.MeasureTypeName:=MeasureTypeName;
            AIface.MeasureTypePath:=MeasureTypePath;
            AIface.ObjectId:=GetObjectIdByFilter;
            AIface.ObjectName:=ObjectName;
            AIface.PointId:=FDataSet.FieldByName('POINT_ID').Value;
            AIface.PointName:=FDataSet.FieldByName('POINT_NAME').AsString;
            AIface.ParamId:=GetParamId;
            AIface.ParamName:=Column.Title.Caption;
            AIface.Value:=Value;

            Checked:=AIface.Checking(AVisible);
            if Checked then begin
              Value:=AIface.Value;
              Checked:=AIface.Checked;
            end else
              Value:=OldValue;

            Result:=Checked;

          finally
            AIface.Free;
          end;
        end;
      end;
    end;
  end;
end;

procedure TSgtsFunSourceDataMeasureGeneralFrame.SetAdditionalInfo;
var
  PointId: Variant;
  Converter, ObjectPaths, CoordinateZ: Variant;
begin
  DBEditJournalNum.Color:=iff(IsCanUpdate and IsEdit and not GetIsConfirm,clWindow,clBtnFace);
  DBMemoNote.Color:=DBEditJournalNum.Color;
  if FDataSet.Active and
     not FDataSet.IsEmpty and
     FDataSetPoints.Active and
     not FDataSetPoints.IsEmpty then begin
    PointId:=FDataSet.FieldByName('POINT_ID').Value;
    if GetAdditionalInfo(PointId,Converter,ObjectPaths,CoordinateZ) then begin
      EditConverter.Text:=VarToStrDef(Converter,'');
      EditPointCoordinateZ.Text:=VarToStrDef(CoordinateZ,'');
      MemoPointObject.Lines.Text:=VarToStrDef(ObjectPaths,'');
    end else begin
      EditConverter.Text:='';
      EditPointCoordinateZ.Text:='';
      MemoPointObject.Clear;
    end;
  end;

end;

function TSgtsFunSourceDataMeasureGeneralFrame.GetAdditionalInfo(PointId: Variant; var Converter, ObjectPaths, CoordinateZ: Variant;
                                                                 ObjectDelim: String=''): Boolean;
var
  S: String;
begin
  Result:=false;
  if FDataSet.Active and
     not FDataSet.IsEmpty and
     FDataSetPoints.Active and
     not FDataSetPoints.IsEmpty then begin
    if FDataSetPoints.Locate('POINT_ID',PointId) then begin
      Converter:=FDataSetPoints.FieldByName('CONVERTER_NAME').Value;
      ObjectPaths:=FDataSetPoints.FieldByName('OBJECT_PATHS').Value;
      CoordinateZ:=FDataSetPoints.FieldByName('COORDINATE_Z').Value;
      if (Trim(ObjectDelim)<>'') and not VarIsNull(ObjectPaths)  then begin
        S:=VarToStrDef(ObjectPaths,'');
        ObjectPaths:=AnsiReplaceStr(S,#13#10,ObjectDelim);
      end;
      Result:=true;
    end;
  end;
end;

procedure TSgtsFunSourceDataMeasureGeneralFrame.SetColumnName;
var
  Column: TColumn;
begin
  EditColumn.Text:='';
  Column:=GetCurrentColumn;
  if Assigned(Column) then begin
    EditColumn.Text:=Column.Title.Caption;
    EditColumn.Update;
  end;
end;

function TSgtsFunSourceDataMeasureGeneralFrame.CanRecalculation: Boolean;
begin
  Result:=IsCanUpdate and
          FDataSet.Active and
          IsEdit;
end;

procedure TSgtsFunSourceDataMeasureGeneralFrame.Recalculation;
var
  APosition: Integer;
  Value: Variant;
  Field: TField;
  i: Integer;
  ColumnType: TSgtsFunSourceDataMeasureGeneralColumnType;
  Counter: Integer;
begin
  if CanRecalculation then begin
    CoreIntf.MainForm.Progress(0,FDataSet.RecordCount,0);
    GoBrowse(true);
    FGrid.VisibleRowNumber:=false;
    try
      APosition:=1;
      InProgress:=true;
      CancelProgress:=false;
      FDataSet.First;
      while not FDataSet.Eof do begin
        Application.ProcessMessages;
        if CancelProgress then
          break;
        if not GetIsConfirm and CheckRecord(false,false,true,false) then begin
          Counter:=0;
          for i:=0 to FGrid.Columns.Count-1 do begin
            ColumnType:=GetColumnType(FGrid.Columns[i]);
            if ColumnType=ctParamValue then begin
              FGrid.SelectedIndex:=i;
              FGrid.Repaint;
              SetColumnName;
              FDataSet.Edit;
              Calculate;
              Field:=FDataSet.FieldByName(GetFieldByCounter('VALUE',Counter));
              Value:=Field.Value;
              if Checking(Value,false) then begin
                Field.Value:=Value;
                FDataSet.FieldByName(GetFieldByCounter('IS_CHECK',Counter)).Value:=Integer(true);
                FDataSet.FieldByName('IS_CHANGE').Value:=Integer(true);
              end else begin
                Field.Value:=Value;
                FDataSet.FieldByName(GetFieldByCounter('IS_CHECK',Counter)).Value:=Integer(false);
                FDataSet.FieldByName('IS_CHANGE').Value:=Integer(true);
              end;
              Inc(Counter);
              FDataSet.Post;
              FChangePresent:=true;
            end;
          end;
        end;
        CoreIntf.MainForm.Progress(0,FDataSet.RecordCount,APosition);
        Inc(APosition);
        FDataSet.Next;
      end;
      if not CancelProgress then
        FDataSet.First;
    finally
      InProgress:=false;
      FGrid.VisibleRowNumber:=true;
      FGrid.UpdateRowNumber;
      UpdateButtons;
      CoreIntf.MainForm.Progress(0,0,0);
    end;
  end;
end;


end.
