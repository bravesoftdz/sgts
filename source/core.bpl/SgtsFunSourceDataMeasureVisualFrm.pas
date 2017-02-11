unit SgtsFunSourceDataMeasureVisualFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Grids, DBGrids, DB, ImgList, ComCtrls, ToolWin, StdCtrls,
  DBCtrls, Mask, OleCtnrs, Menus, ShellApi,
  SgtsDbGrid, SgtsSelectDefs, SgtsCDS, SgtsDatabaseCDS,
  SgtsGetRecordsConfig,
  SgtsCoreIntf, SgtsControls, SgtsMenus, SgtsFunSourceDataFrm;

type
  TOleContainer=class(OleCtnrs.TOleContainer)
  end;

  TSgtsFunSourceDataMeasureVisualColumnType=(ctUnknown,ctPointName,ctDate,ctObjectPaths,ctCoordinateZ,ctDefectView,
                                             ctInclination,ctWidthDefect,ctHeightDefect,ctLengthDefect,ctConfirm,
                                             ctDocDate,ctDocName,ctDocDescription);
  TSgtsFunSourceDataMeasureVisualColumnTypes=set of TSgtsFunSourceDataMeasureVisualColumnType;
  TSgtsFunSourceDataMeasureVisualNewRecordMode=(rmCancel,rmFill,rmInput,rmFillEmpty);

  TSgtsFunSourceDataMeasureVisualFrame = class(TSgtsFunSourceDataFrame)
    PanelGrid: TPanel;
    GridPattern: TDBGrid;
    DataSource: TDataSource;
    DataSourceDocs: TDataSource;
    ImageList: TImageList;
    PanelInfo: TPanel;
    GroupBoxInfo: TGroupBox;
    PanelDocs: TGridPanel;
    PanelDocPreview: TPanel;
    PanelInfo2: TPanel;
    LabelJournalNum: TLabel;
    DBEditJournalNum: TDBEdit;
    LabelNote: TLabel;
    DBMemoNote: TDBMemo;
    LabelPointCoordinateZ: TLabel;
    EditPointCoordinateZ: TEdit;
    LabelDocs: TLabel;
    BevelDocs: TBevel;
    PopupMenuConfirm: TPopupMenu;
    MenuItemConfirmCheckAll: TMenuItem;
    MenuItemConfirmUncheckAll: TMenuItem;
    N1: TMenuItem;
    MenuItemConfirmCancel: TMenuItem;
    PanelAllDocs: TPanel;
    GridDocsPattern: TDBGrid;
    ToolBarDocs: TToolBar;
    ToolButtonDocRefresh: TToolButton;
    ToolButtonDocInsert: TToolButton;
    ToolButtonDocUpdate: TToolButton;
    ToolButtonDocDelete: TToolButton;
    ToolButton3: TToolButton;
    ToolButtonDocLoad: TToolButton;
    ToolButtonDocSave: TToolButton;
    ToolButtonDocView: TToolButton;
    ToolButton1: TToolButton;
    PopupMenuDocs: TPopupMenu;
    OpenDialogDoc: TOpenDialog;
    SaveDialogDoc: TSaveDialog;
    OleContainer: TOleContainer;
    CheckBoxDocPreview: TCheckBox;
    ShapeDoc: TShape;
    Splitter: TSplitter;
    ImagDoc: TImage;
    procedure ToolButtonDocRefreshClick(Sender: TObject);
    procedure ToolButtonDocInsertClick(Sender: TObject);
    procedure ToolButtonDocUpdateClick(Sender: TObject);
    procedure ToolButtonDocDeleteClick(Sender: TObject);
    procedure ToolButtonDocLoadClick(Sender: TObject);
    procedure ToolButtonDocSaveClick(Sender: TObject);
    procedure ToolButtonDocViewClick(Sender: TObject);
    procedure PopupMenuDocsPopup(Sender: TObject);
    procedure CheckBoxDocPreviewClick(Sender: TObject);
    procedure DBMemoNoteKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure DBMemoNoteExit(Sender: TObject);
  private
    FChangePresent: Boolean;
    FNewRecordMode: TSgtsFunSourceDataMeasureVisualNewRecordMode;
    FSelectDefs: TSgtsSelectDefs;
    FSelectDefsDocs: TSgtsSelectDefs;
    FGrid: TSgtsFunSourceDbGrid;
    FGridDocs: TSgtsFunSourceDbGrid;
    FDataSetPoints: TSgtsDatabaseCDS;
    FDataSetCycles: TSgtsDatabaseCDS;
    FDataSetRoutes: TSgtsDatabaseCDS;
    FDataSetDefectViews: TSgtsDatabaseCDS;
    FDataSetJournal: TSgtsDatabaseCDS;
    FDataSetDocCheckups: TSgtsDatabaseCDS;

    FDataSet: TSgtsFunSourceDataCDS;
    FDataSetDocs: TSgtsFunSourceDataCDS;

    FTempFiles: TStringList;
    FFlagNewDocRecord: Boolean;

    procedure GridKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure GridColEnter(Sender: TObject);
    procedure GridCellClick(Column: TColumn);
    procedure GridDblClick(Sender: TObject);
    function GridGetFontColor(Sender: TObject; Column: TColumn; var FontStyles: TFontStyles): TColor;
    procedure GridEnter(Sender: TObject);
    procedure DataSetAfterScroll(DataSet: TDataSet);
    procedure DataSetNewRecord(DataSet: TDataSet);
    procedure DataSetAfterPost(DataSet: TDataSet);
    procedure DataSetDocsAfterScroll(DataSet: TDataSet);
    procedure DataSetDocsNewRecord(DataSet: TDataSet);
    procedure DataSetDocsBeforePost(DataSet: TDataSet);
    function GetCurrentColumn(AGrid: TSgtsFunSourceDbGrid): TColumn;
    procedure GoBrowse(AGrid: TSgtsFunSourceDbGrid; ChangeMode: Boolean);
    procedure PointNameFieldSetText(Sender: TField; const Text: string);
    procedure DateObservationFieldSetText(Sender: TField; const Text: string);
    procedure DefectViewNameFieldSetText(Sender: TField; const Text: string);
    procedure DefectFieldSetText(Sender: TField; const Text: string);
    procedure DateDocFieldSetText(Sender: TField; const Text: string);
    function GetConfirmProc(Def: TSgtsSelectDef): Variant;
    function GetColumnType(Column: TColumn): TSgtsFunSourceDataMeasureVisualColumnType;
    procedure SetColumnProperty(Column: TColumn);
    procedure FillPoints(Strings: TStrings);
    procedure FillDefectViews(Strings: TStrings);
    function GetIsConfirm: Boolean;
    function GetMeasureTypeIdByFilter: Variant;
    function GetObjectIdByFilter: Variant;
    procedure ViewPointInfo;
    procedure ViewObjectTreeInfo;
    procedure ViewDefectInfo;
    function NextPresent(AGrid: TSgtsFunSourceDbGrid; Index: Integer; ColumnTypes: TSgtsFunSourceDataMeasureVisualColumnTypes): Boolean;
    function CheckRecord(CheckChanges: Boolean; WithMessage: Boolean=true; WithDefectView: Boolean=false): Boolean;
    function SaveRecord: Boolean;
    procedure GoEdit(AGrid: TSgtsFunSourceDbGrid; WithEditor: Boolean; WithDataSet: Boolean; EditorMode: Boolean=true);
    procedure GoDropDown(AGrid: TSgtsFunSourceDbGrid);
    procedure SetAdditionalInfo;
    procedure GoSelect(AGrid: TSgtsFunSourceDbGrid; ReadOnly: Boolean);
    function GetAdditionalInfo(PointId: Variant; var ObjectPaths, CoordinateZ: Variant; ObjectDelim: String=''): Boolean;

    procedure GridDocsKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure GridDocsDblClick(Sender: TObject);
    procedure LocalDeleteDocsByID(ID: Variant);

    function CanRefreshDoc: Boolean;
    procedure RefreshDoc;
    function CanInsertDoc: Boolean;
    procedure InsertDoc;
    function CanUpdateDoc: Boolean;
    procedure UpdateDoc;
    function CanDeleteDoc: Boolean;
    procedure DeleteDoc;
    function CanSaveDoc: Boolean;
    procedure SaveDoc;
    function CanLoadDoc: Boolean;
    procedure LoadDoc;
    function CanViewDoc: Boolean;
    procedure ViewDoc;

    function GetNewTempFileName(Extension: String): String;
    procedure UpdatePreview;
    procedure DeleteTempFiles;

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
    procedure UpdateButtons; override;

  end;

var
  SgtsFunSourceDataMeasureVisualFrame: TSgtsFunSourceDataMeasureVisualFrame;

implementation

{$R *.dfm}

uses DBClient, DateUtils, StrUtils,
     SgtsConsts, SgtsProviderConsts,
     SgtsUtils, SgtsExecuteDefs, SgtsProviders, SgtsDialogs, SgtsRbkCyclesFm,
     SgtsFunSourceDataConditionFm, SgtsFunPointManagementFm, SgtsRbkPointManagementFm,
     SgtsFunSourceDataObjectTreesIface;

const
  ReturnColumnTypes=[ctPointName,ctDate,ctObjectPaths,ctCoordinateZ,ctDefectView,
                     ctInclination,ctWidthDefect,ctHeightDefect,ctLengthDefect,
                     ctDocDate,ctDocName,ctDocDescription];
  PickListColumnTypes=[ctPointName,ctDefectView];
  EditColumnTypes=[ctPointName,ctDate,ctDefectView,ctInclination,ctWidthDefect,ctHeightDefect,ctLengthDefect,
                   ctDocDate,ctDocName,ctDocDescription];
  InfoColumnTypes=[ctPointName,ctDefectView];

type
  TSgtsDefectViewInfo=class(TObject)
  private
    FDefectViewId: Variant;
    FDefectViewName: String;
  public
    property DefectViewId: Variant read FDefectViewId write FDefectViewId;
    property DefectViewName: String read FDefectViewName write FDefectViewName;
  end;

{ TSgtsFunSourceDataMeasureVisualFrame }

constructor TSgtsFunSourceDataMeasureVisualFrame.Create(ACoreIntf: ISgtsCore);
begin
  inherited Create(ACoreIntf);

  FNewRecordMode:=rmCancel;
  DBMemoNote.Anchors:=[akLeft, akTop, akRight, akBottom];
  BevelDocs.Anchors:=[akLeft, akTop, akRight];

  OleContainer.OnClick:=GridDocsDblClick;
  ImagDoc.OnClick:=GridDocsDblClick;

  FSelectDefs:=TSgtsSelectDefs.Create;
  FSelectDefsDocs:=TSgtsSelectDefs.Create;

  FGrid:=TSgtsFunSourceDbGrid.Create(Self);
  with FGrid do begin
    Parent:=GridPattern.Parent;
    Align:=GridPattern.Align;
    AlignWithMargins:=GridPattern.AlignWithMargins;
    Margins.Assign(GridPattern.Margins);
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
    OnKeyDown:=GridKeyDown;
    OnDblClick:=GridDblClick;
    OnColEnter:=GridColEnter;
    OnGetFontColor:=GridGetFontColor;
    OnCellClick:=GridCellClick;
    OnEnter:=GridEnter;
  end;

  GridPattern.Free;
  GridPattern:=nil;

  FGridDocs:=TSgtsFunSourceDbGrid.Create(Self);
  with FGridDocs do begin
    Parent:=GridDocsPattern.Parent;
    Align:=GridDocsPattern.Align;
    AlignWithMargins:=GridDocsPattern.AlignWithMargins;
    Margins.Assign(GridDocsPattern.Margins);
    Font.Assign(GridDocsPattern.Font);
    Font.Style:=GridDocsPattern.Font.Style;
    LocateEnabled:=false;
    ColumnSortEnabled:=false;
    Options:=Options-[dgEditing,dgTabs];
    ColMoving:=false;
    AutoFit:=true;
    VisibleRowNumber:=true;
    DataSource:=GridDocsPattern.DataSource;
    PopupMenu:=GridDocsPattern.PopupMenu;
    TabOrder:=1;
    Visible:=false;
    ReadOnly:=false;
    OnKeyDown:=GridDocsKeyDown;
    OnColEnter:=GridColEnter;
    OnEnter:=GridEnter;
    OnDblClick:=GridDocsDblClick;
  end;

  GridDocsPattern.Free;
  GridDocsPattern:=nil;

  FDataSetPoints:=TSgtsDatabaseCDS.Create(ACoreIntf);
  with FDataSetPoints do begin
    ProviderName:=SProviderSelectRouteConverters;
    with SelectDefs do begin
      AddInvisible('POINT_ID');
      AddInvisible('POINT_NAME');
      AddInvisible('ROUTE_ID');
      AddInvisible('ROUTE_NAME');
      AddInvisible('PRIORITY');
      AddInvisible('COORDINATE_Z');
      AddInvisible('OBJECT_ID');
      AddInvisible('OBJECT_PATHS');
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

  FDataSetDefectViews:=TSgtsDatabaseCDS.Create(ACoreIntf);
  with FDataSetDefectViews do begin
    ProviderName:=SProviderSelectDefectViews;
    with SelectDefs do begin
      AddInvisible('DEFECT_VIEW_ID');
      AddInvisible('NAME');
    end;
    Orders.Add('PRIORITY',otAsc)
  end;

  FDataSetJournal:=TSgtsDatabaseCDS.Create(ACoreIntf);
  with FDataSetJournal do begin
    ProviderName:=SProviderSelectJournalCheckups;
    with SelectDefs do begin
      AddInvisible('JOURNAL_CHECKUP_ID');
      AddInvisible('JOURNAL_NUM');
      AddInvisible('NOTE');
      AddInvisible('DATE_OBSERVATION');
      AddInvisible('CYCLE_ID');
      AddInvisible('CYCLE_NUM');
      AddInvisible('POINT_ID');
      AddInvisible('POINT_NAME');
      AddInvisible('DEFECT_VIEW_ID');
      AddInvisible('DEFECT_VIEW_NAME');
      AddInvisible('WHO_ENTER');
      AddInvisible('DATE_ENTER');
      AddInvisible('WHO_CONFIRM');
      AddInvisible('DATE_CONFIRM');
      AddInvisible('INCLINATION');
      AddInvisible('WIDTH_DEFECT');
      AddInvisible('HEIGHT_DEFECT');
      AddInvisible('LENGTH_DEFECT');
    end;
    Orders.Add('DATE_OBSERVATION',otAsc);
  end;

  FDataSetDocCheckups:=TSgtsDatabaseCDS.Create(ACoreIntf);
  with FDataSetDocCheckups do begin
    ProviderName:=SProviderSelectDocCheckups;
    with SelectDefs do begin
      AddInvisible('DOC_CHECKUP_ID');
      AddInvisible('JOURNAL_CHECKUP_ID');
      AddInvisible('DATE_DOC');
      AddInvisible('NAME');
      AddInvisible('DESCRIPTION');
      AddInvisible('DOC');
      AddInvisible('EXTENSION');
    end;
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

  FDataSetDocs:=TSgtsFunSourceDataCDS.Create(nil);
  with FDataSetDocs do begin
    AfterScroll:=DataSetDocsAfterScroll;
    OnNewRecord:=DataSetDocsNewRecord;
    BeforePost:=DataSetDocsBeforePost;
    AfterPost:=DataSetAfterPost;
  end;
  FDataSetDocs.SelectDefs:=FSelectDefsDocs;
  DataSourceDocs.DataSet:=FDataSetDocs;

  FTempFiles:=TStringList.Create;
end;

destructor TSgtsFunSourceDataMeasureVisualFrame.Destroy;
begin
  DeleteTempFiles;
  FTempFiles.Free;
  FDataSetDocs.Free;
  FDataSet.Free;
  FDataSetDocCheckups.Free;
  FDataSetJournal.Free;
  FDataSetDefectViews.Free;
  FDataSetRoutes.Free;
  FDataSetCycles.Free;
  FDataSetPoints.Free;
  FSelectDefsDocs.Free;
  FSelectDefs.Free;
  inherited Destroy;
end;

function TSgtsFunSourceDataMeasureVisualFrame.GetDataSet: TSgtsCDS;
begin
  Result:=FDataSet;
end;

procedure TSgtsFunSourceDataMeasureVisualFrame.Refresh;

  function CreateData: Boolean;
  begin
    Result:=false;

    FDataSetPoints.Close;
    FDataSetCycles.Close;
    FDataSetRoutes.Close;
    FDataSetDefectViews.Close;
    FDataSetJournal.Close;
    FDataSetDocCheckups.Close;
    FDataSet.Close;
    FDataSet.Fields.Clear;
    FDataSet.FieldDefs.Clear;
    FDataSetDocs.Close;
    FDataSetDocs.Fields.Clear;
    FDataSetDocs.FieldDefs.Clear;

    with FDataSetPoints do begin
      FilterGroups.Clear;
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

    FDataSetDefectViews.Open;

    with FDataSetJournal do begin
      FilterGroups.Clear;
      SetFilterGroupsTo(FilterGroups,'CYCLE_ID',foOr);
      SetDataSetTo(FDataSetPoints,FilterGroups,'POINT_ID',foOr);
      FilterGroups.Add.Filters.Add('DATE_OBSERVATION',fcEqualGreater,GetDateBegin);
      FilterGroups.Add.Filters.Add('DATE_OBSERVATION',fcEqualLess,GetDateEnd);
    end;
    FDataSetJournal.Open;

    with FDataSetDocCheckups do begin
      FilterGroups.Clear;
      PacketRecords:=0;
    end;
    FDataSetDocCheckups.Open;

    if FDataSetPoints.Active and
       FDataSetCycles.Active and
       FDataSetRoutes.Active and
       FDataSetDefectViews.Active and
       FDataSetJournal.Active and
       FDataSetDocCheckups.Active then begin

      with FDataSet do begin
        CreateField('IS_CHANGE',ftInteger);
        CreateField('IS_LOAD',ftInteger);
        CreateField('ID',ftString,Length(CreateUniqueId));
        CreateFieldBySource('JOURNAL_CHECKUP_ID',FDataSetJournal);
        CreateFieldBySource('JOURNAL_NUM',FDataSetJournal);
        CreateFieldBySource('NOTE',FDataSetJournal);
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
        CreateFieldBySource('DEFECT_VIEW_ID',FDataSetJournal);
        CreateFieldBySource('DEFECT_VIEW_NAME',FDataSetJournal).OnSetText:=DefectViewNameFieldSetText;
        CreateFieldBySource('WHO_ENTER',FDataSetJournal);
        CreateFieldBySource('DATE_ENTER',FDataSetJournal);
        CreateFieldBySource('WHO_CONFIRM',FDataSetJournal);
        CreateFieldBySource('DATE_CONFIRM',FDataSetJournal);
        CreateFieldBySource('OBJECT_PATHS',FDataSetPoints);
        CreateFieldBySource('COORDINATE_Z',FDataSetPoints);
        CreateFieldBySource('INCLINATION',FDataSetJournal).OnSetText:=DefectFieldSetText;
        CreateFieldBySource('WIDTH_DEFECT',FDataSetJournal).OnSetText:=DefectFieldSetText;
        CreateFieldBySource('HEIGHT_DEFECT',FDataSetJournal).OnSetText:=DefectFieldSetText;
        CreateFieldBySource('LENGTH_DEFECT',FDataSetJournal).OnSetText:=DefectFieldSetText;

        FSelectDefs.Add('POINT_NAME','������������� �����',50);
        FSelectDefs.Add('DATE_OBSERVATION','���� ���������',70);
        FSelectDefs.Add('OBJECT_PATHS','������������ �������',80);
        FSelectDefs.Add('COORDINATE_Z','������� ��',50);
        FSelectDefs.Add('DEFECT_VIEW_NAME','��� �������',150);
        FSelectDefs.Add('INCLINATION','��������',150);
        FSelectDefs.Add('WIDTH_DEFECT','������ �������',50);
        FSelectDefs.Add('HEIGHT_DEFECT','������ �������',50);
        FSelectDefs.Add('LENGTH_DEFECT','����� �������',50);

        CreateField('IS_CONFIRM',ftInteger).FieldKind:=fkCalculated;
        FSelectDefs.AddCalcInvisible('IS_CONFIRM',GetConfirmProc,ftInteger).Field:=FindField('IS_CONFIRM');
        FSelectDefs.AddDrawCheck('IS_CONFIRM_EX','����������','IS_CONFIRM',30);

        CreateDataSet;
      end;

      with FDataSetDocs do begin
        CreateFieldBySource('ID',FDataSet);
        CreateFieldBySource('DOC_CHECKUP_ID',FDataSetDocCheckups);
        CreateFieldBySource('JOURNAL_CHECKUP_ID',FDataSetDocCheckups);
        with CreateFieldBySource('DATE_DOC',FDataSetDocCheckups) do begin
          EditMask:=SDateMask;
          ValidChars:=CDateValidChars;
          OnSetText:=DateDocFieldSetText;
        end;
        CreateFieldBySource('NAME',FDataSetDocCheckups);
        CreateFieldBySource('DESCRIPTION',FDataSetDocCheckups);
        CreateFieldBySource('DOC',FDataSetDocCheckups);
        CreateFieldBySource('EXTENSION',FDataSetDocCheckups);

        FSelectDefsDocs.Add('DATE_DOC','����',70);
        FSelectDefsDocs.Add('NAME','������������',150);
        FSelectDefsDocs.Add('DESCRIPTION','��������',200);

        CreateDataSet;
      end;

      Result:=FDataSet.Active and FDataSetDocs.Active;
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
    ObjectPaths,CoordinateZ: Variant;
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
                    if not FDataSet.FindKey([CycleId,TempDate,PointId]) then begin
                      FDataSet.Append;
                      FDataSet.FieldByName('CYCLE_ID').Value:=CycleId;
                      FDataSet.FieldByName('POINT_ID').Value:=PointId;
                      FDataSet.FieldByName('POINT_PRIORITY').Value:=FDataSetPoints.FieldByName('PRIORITY').Value;
                      if FDataSetRoutes.Locate('ROUTE_ID',FDataSetPoints.FieldByName('ROUTE_ID').Value) then
                        FDataSet.FieldByName('ROUTE_PRIORITY').Value:=FDataSetRoutes.FieldByName('PRIORITY').Value;
                      FDataSet.FieldByName('POINT_NAME').Value:=FDataSetPoints.FieldByName('POINT_NAME').Value;
                      FDataSet.FieldByName('DATE_OBSERVATION').Value:=TempDate;
                      if GetAdditionalInfo(PointId,ObjectPaths,CoordinateZ,';') then begin
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
    Position: Integer;
    CycleId: Variant;
    PointId: Variant;
    ObjectPaths,CoordinateZ: Variant;
  begin
    Position:=0;
    CoreIntf.MainForm.Progress(0,FDataSetJournal.RecordCount,0);
    try
      FDataSetJournal.First;
      while not FDataSetJournal.Eof do begin
        CycleId:=FDataSetJournal.FieldByName('CYCLE_ID').Value;
        PointId:=FDataSetJournal.FieldByName('POINT_ID').Value;

        FDataSet.Append;
        FDataSet.FieldByName('ID').Value:=CreateUniqueId;
        FDataSet.FieldByName('IS_CHANGE').Value:=Boolean(false);
        FDataSet.FieldByName('IS_LOAD').Value:=Boolean(false);
        FDataSet.FieldByName('JOURNAL_CHECKUP_ID').Value:=FDataSetJournal.FieldByName('JOURNAL_CHECKUP_ID').Value;
        FDataSet.FieldByName('JOURNAL_NUM').Value:=FDataSetJournal.FieldByName('JOURNAL_NUM').Value;
        FDataSet.FieldByName('NOTE').Value:=FDataSetJournal.FieldByName('NOTE').Value;
        FDataSet.FieldByName('CYCLE_ID').Value:=CycleId;
        FDataSet.FieldByName('POINT_ID').Value:=PointId;
        if FDataSetPoints.Locate('POINT_ID',PointId) then begin
          FDataSet.FieldByName('POINT_PRIORITY').Value:=FDataSetPoints.FieldByName('PRIORITY').Value;
          if FDataSetRoutes.Locate('ROUTE_ID',FDataSetPoints.FieldByName('ROUTE_ID').Value) then
            FDataSet.FieldByName('ROUTE_PRIORITY').Value:=FDataSetRoutes.FieldByName('PRIORITY').Value;
        end;
        FDataSet.FieldByName('POINT_NAME').Value:=FDataSetJournal.FieldByName('POINT_NAME').Value;
        FDataSet.FieldByName('DATE_OBSERVATION').Value:=FDataSetJournal.FieldByName('DATE_OBSERVATION').Value;
        FDataSet.FieldByName('DEFECT_VIEW_ID').Value:=FDataSetJournal.FieldByName('DEFECT_VIEW_ID').Value;
        FDataSet.FieldByName('DEFECT_VIEW_NAME').Value:=FDataSetJournal.FieldByName('DEFECT_VIEW_NAME').Value;
        FDataSet.FieldByName('WHO_ENTER').Value:=FDataSetJournal.FieldByName('WHO_ENTER').Value;
        FDataSet.FieldByName('DATE_ENTER').Value:=FDataSetJournal.FieldByName('DATE_ENTER').Value;
        FDataSet.FieldByName('WHO_CONFIRM').Value:=FDataSetJournal.FieldByName('WHO_CONFIRM').Value;
        FDataSet.FieldByName('DATE_CONFIRM').Value:=FDataSetJournal.FieldByName('DATE_CONFIRM').Value;
        FDataSet.FieldByName('INCLINATION').Value:=FDataSetJournal.FieldByName('INCLINATION').Value;
        FDataSet.FieldByName('WIDTH_DEFECT').Value:=FDataSetJournal.FieldByName('WIDTH_DEFECT').Value;
        FDataSet.FieldByName('HEIGHT_DEFECT').Value:=FDataSetJournal.FieldByName('HEIGHT_DEFECT').Value;
        FDataSet.FieldByName('LENGTH_DEFECT').Value:=FDataSetJournal.FieldByName('LENGTH_DEFECT').Value;

        if GetAdditionalInfo(PointId,ObjectPaths,CoordinateZ,';') then begin
          FDataSet.FieldByName('OBJECT_PATHS').Value:=ObjectPaths;
          FDataSet.FieldByName('COORDINATE_Z').Value:=CoordinateZ;
        end;

        FDataSet.Post;

        Inc(Position);
        CoreIntf.MainForm.Progress(0,FDataSetJournal.RecordCount,Position);
        FDataSetJournal.Next;
      end;
    finally
      CoreIntf.MainForm.Progress(0,0,0);
    end;
  end;

var
  OldIndexName: String;
begin
  if CanRefresh then begin
    FDataSet.BeginUpdate;
    OldIndexName:=FDataSet.IndexName;
    FDataSet.IndexName:='IDX_CYCLE_DATE_POINT';
    FNewRecordMode:=rmFill;
    try
      FGrid.Columns.Clear;
      FGridDocs.Columns.Clear;
      FSelectDefs.Clear;
      FSelectDefsDocs.Clear;
      if CreateData then begin
        CreateGridColumnsBySelectDefs(FGrid,FSelectDefs);
        CreateGridColumnsBySelectDefs(FGridDocs,FSelectDefsDocs);
        LoadRealData;
        if IsEdit then
          LoadEmptyData;
        FGrid.AutoSizeColumns;
        FGrid.Hint:='�������� ������: '+MeasureTypeName+'  (������)';
        FGridDocs.AutoSizeColumns;
        SetColumnProperty(GetCurrentColumn(FGrid));
      end;
    finally
      GoBrowse(FGrid,false);
      GoBrowse(FGridDocs,false);
      FNewRecordMode:=rmInput;
      FDataSet.IndexName:=OldIndexName;
      FDataSet.EndUpdate;
      FDataSet.First;
      FDataSetDocs.First;
      FGrid.UpdateRowNumber;
      FGridDocs.UpdateRowNumber;
    end;
  end;
end;

procedure TSgtsFunSourceDataMeasureVisualFrame.BeforeRefresh;
begin
  FGrid.Visible:=false;
  FGridDocs.Visible:=false;
  
  PanelGrid.Visible:=false;
  Splitter.Visible:=false;
  PanelInfo.Visible:=false;
  PanelStatus.Update;
end;

procedure TSgtsFunSourceDataMeasureVisualFrame.AfterRefresh;
begin
  FGrid.Visible:=true;
  FGridDocs.Visible:=true;

  PanelInfo.Visible:=true;
  Splitter.Visible:=true;
  Splitter.Top:=PanelInfo.Top-1;
  PanelGrid.Visible:=true;

  if FGrid.CanFocus then
    FGrid.SetFocus;
end;

function TSgtsFunSourceDataMeasureVisualFrame.GetColumnType(
  Column: TColumn): TSgtsFunSourceDataMeasureVisualColumnType;
begin
  Result:=ctUnknown;
  if Assigned(Column) then begin
    if Pos('POINT_NAME',Column.FieldName)>0 then Result:=ctPointName;
    if Pos('DATE_OBSERVATION',Column.FieldName)>0 then Result:=ctDate;
    if Pos('OBJECT_PATHS',Column.FieldName)>0 then Result:=ctObjectPaths;
    if Pos('COORDINATE_Z',Column.FieldName)>0 then Result:=ctCoordinateZ;
    if Pos('DEFECT_VIEW_NAME',Column.FieldName)>0 then Result:=ctDefectView;
    if Pos('INCLINATION',Column.FieldName)>0 then Result:=ctInclination;
    if Pos('WIDTH_DEFECT',Column.FieldName)>0 then Result:=ctWidthDefect;
    if Pos('HEIGHT_DEFECT',Column.FieldName)>0 then Result:=ctHeightDefect;
    if Pos('LENGTH_DEFECT',Column.FieldName)>0 then Result:=ctLengthDefect;
    if Pos('IS_CONFIRM_EX',Column.FieldName)>0 then Result:=ctConfirm;

    if Result=ctUnknown then begin
      if Pos('DATE_DOC',Column.FieldName)>0 then Result:=ctDocDate;
      if Pos('NAME',Column.FieldName)>0 then Result:=ctDocName;
      if Pos('DESCRIPTION',Column.FieldName)>0 then Result:=ctDocDescription;
    end;

  end;
end;

procedure TSgtsFunSourceDataMeasureVisualFrame.FillPoints(Strings: TStrings);
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

procedure TSgtsFunSourceDataMeasureVisualFrame.FillDefectViews(
  Strings: TStrings);
var
  Obj: TSgtsDefectViewInfo;
begin
  if FDataSetDefectViews.Active then begin
    Strings.BeginUpdate;
    try
      FDataSetDefectViews.First;
      while not FDataSetDefectViews.Eof do begin
        Obj:=TSgtsDefectViewInfo.Create;
        Obj.DefectViewId:=FDataSetDefectViews.FieldByName('DEFECT_VIEW_ID').Value;
        Obj.DefectViewName:=FDataSetDefectViews.FieldByName('NAME').AsString;
        Strings.AddObject(Obj.FDefectViewName,Obj);
        FDataSetDefectViews.Next;
      end;
    finally
      Strings.EndUpdate;
    end;
  end;
end;

procedure TSgtsFunSourceDataMeasureVisualFrame.SetColumnProperty(
  Column: TColumn);
var
  ColumnType: TSgtsFunSourceDataMeasureVisualColumnType;
begin
  if Assigned(Column) then begin
    FGrid.PopupMenu:=DefaultPopupMenu;
    ClearStrings(Column.PickList);
    Column.ButtonStyle:=cbsNone;
    GoBrowse(FGrid,true);
    ColumnType:=GetColumnType(Column);
    case ColumnType of
      ctPointName: begin
        Column.ButtonStyle:=cbsAuto;
        FillPoints(Column.PickList);
      end;
      ctDefectView: begin
        Column.ButtonStyle:=cbsAuto;
        FillDefectViews(Column.PickList);
      end;
      ctConfirm: begin
        FGrid.PopupMenu:=PopupMenuConfirm;
      end;
    end;
  end;
end;

function TSgtsFunSourceDataMeasureVisualFrame.GetIsConfirm: Boolean;
begin
  Result:=false;
  if FDataSet.Active and not FDataSet.IsEmpty then
    Result:=Boolean(FDataSet.FieldByName('IS_CONFIRM').AsInteger);
end;

function TSgtsFunSourceDataMeasureVisualFrame.GetMeasureTypeIdByFilter: Variant;
begin
  Result:=GetValueByCounter('MEASURE_TYPE_ID',0);
end;

function TSgtsFunSourceDataMeasureVisualFrame.GetObjectIdByFilter: Variant;
begin
  Result:=GetValueByCounter('OBJECT_ID',0);
end;

procedure TSgtsFunSourceDataMeasureVisualFrame.GridCellClick(Column: TColumn);
var
  ColumnType: TSgtsFunSourceDataMeasureVisualColumnType;
begin
  ColumnType:=GetColumnType(Column);
  case ColumnType of
    ctConfirm: Confirm;
  end;
end;

procedure TSgtsFunSourceDataMeasureVisualFrame.GridColEnter(Sender: TObject);
begin
  if Sender is TSgtsFunSourceDbGrid then
    SetColumnProperty(GetCurrentColumn(TSgtsFunSourceDbGrid(Sender)));
  UpdateButtons;
end;

procedure TSgtsFunSourceDataMeasureVisualFrame.GridEnter(Sender: TObject);
begin
  SetColumnProperty(GetCurrentColumn(FGrid));
  UpdateButtons;
end;

function TSgtsFunSourceDataMeasureVisualFrame.GridGetFontColor(Sender: TObject;
  Column: TColumn; var FontStyles: TFontStyles): TColor;
var
  IsChange: Boolean;
begin
  Result:=Column.Font.Color;
  if FDataSet.Active and not FDataSet.IsEmpty then begin
    IsChange:=Boolean(FDataSet.FieldByName('IS_CHANGE').AsInteger);
    if isChange then
      Result:=clGreen;
  end;
end;

function TSgtsFunSourceDataMeasureVisualFrame.NextPresent(AGrid: TSgtsFunSourceDbGrid; Index: Integer;
                                                          ColumnTypes: TSgtsFunSourceDataMeasureVisualColumnTypes): Boolean;
var
  ColumnType: TSgtsFunSourceDataMeasureVisualColumnType;
  i: Integer;
begin
  Result:=false;
  if Index in [0..AGrid.Columns.Count-1] then
    for i:=Index to AGrid.Columns.Count-1 do begin
      ColumnType:=GetColumnType(AGrid.Columns[i]);
      if ColumnType in ColumnTypes then begin
        Result:=true;
        exit;
      end;
    end;
end;

function TSgtsFunSourceDataMeasureVisualFrame.CheckRecord(CheckChanges: Boolean; WithMessage: Boolean=true; WithDefectView: Boolean=false): Boolean;
var
  Column: TColumn;
  ColumnType: TSgtsFunSourceDataMeasureVisualColumnType;

  procedure ResultFalse(AGrid: TSgtsFunSourceDbGrid);
  begin
    if WithMessage then begin
      ShowError(Format(SNeedElementValue,[Column.Title.Caption]));
      AGrid.SetFocus;
      AGrid.SelectedIndex:=Column.Index;
    end;
    Result:=false;
  end;

  procedure CheckRecordLocal;
  var
    i: Integer;
  begin
    for i:=0 to FGridDocs.Columns.Count-1 do begin
      Column:=FGridDocs.Columns[i];
      ColumnType:=GetColumnType(Column);
      case ColumnType of
        ctDocDate: begin
          if VarIsNull(FDataSetDocs.FieldByName('DATE_DOC').Value) then begin
            ResultFalse(FGridDocs);
            break;
          end;
        end;
        ctDocName: begin
          if VarIsNull(FDataSetDocs.FieldByName('NAME').Value) or
             (Trim(FDataSetDocs.FieldByName('NAME').AsString)='') then begin
            ResultFalse(FGridDocs);
            break;
          end;
        end;
      end;
    end;
  end;

var
  i: Integer;
  Flag: Boolean;
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
              ResultFalse(FGrid);
              exit;
            end;
          end;
          ctDate: begin
            if VarIsNull(FDataSet.FieldByName('DATE_OBSERVATION').Value) then begin
              ResultFalse(FGrid);
              exit;
            end;
          end;
          ctDefectView: begin
            if WithDefectView then
              if VarIsNull(FDataSet.FieldByName('DEFECT_VIEW_ID').Value) or
                 (Trim(FDataSet.FieldByName('DEFECT_VIEW_NAME').AsString)='') then begin
                ResultFalse(FGrid);
                exit;
              end;
          end;
        end;
      end;

      if FDataSetDocs.Active and
         not FDataSetDocs.IsEmpty then begin

        FDataSetDocs.First;
        while not FDataSetDocs.Eof do begin
          CheckRecordLocal;
          if not Result then begin
            break;
          end;
          FDataSetDocs.Next;
        end;
      end;
      
    end;
  end;
end;

function TSgtsFunSourceDataMeasureVisualFrame.SaveRecord: Boolean;
var
  JournalNum: Variant;
  Note: Variant;
  CycleId: Variant;
  PointId: Variant;
  DefectViewId: Variant;
  WhoEnter: Variant;
  DateEnter: Variant;
  DateObservation: Variant;
  WhoConfirm: Variant;
  DateConfirm: Variant;
  Inclination: Variant;
  WidthDefect: Variant;
  HeightDefect: Variant;
  LengthDefect: Variant;


  procedure SaveLocal;
  var
    JournalCheckupId: Variant;

    procedure InsertLocal;
    var
      DS: TSgtsDatabaseCDS;
      AKey: TSgtsExecuteDefKey;
    begin
      DS:=TSgtsDatabaseCDS.Create(CoreIntf);
      try
        DS.ProviderName:=SProviderInsertJournalCheckup;
        DS.StopException:=true;
        with DS.ExecuteDefs do begin
          AKey:=AddKey('JOURNAL_CHECKUP_ID');
          AddInvisible('JOURNAL_NUM').Value:=iff(Trim(VarToStrDef(JournalNum,''))<>'',JournalNum,Null);
          AddInvisible('NOTE').Value:=iff(Trim(VarToStrDef(Note,''))<>'',Note,Null);
          AddInvisible('CYCLE_ID').Value:=CycleId;
          AddInvisible('POINT_ID').Value:=PointId;
          AddInvisible('DEFECT_VIEW_ID').Value:=DefectViewId;
          AddInvisible('DATE_OBSERVATION').Value:=DateObservation;
          AddInvisible('WHO_ENTER').Value:=WhoEnter;
          AddInvisible('DATE_ENTER').Value:=DateEnter;
          AddInvisible('WHO_CONFIRM').Value:=WhoConfirm;
          AddInvisible('DATE_CONFIRM').Value:=DateConfirm;
          AddInvisible('INCLINATION').Value:=Inclination;
          AddInvisible('WIDTH_DEFECT').Value:=WidthDefect;
          AddInvisible('HEIGHT_DEFECT').Value:=HeightDefect;
          AddInvisible('LENGTH_DEFECT').Value:=LengthDefect;
          AddInvisible('MEASURE_TYPE_ID').Value:=GetMeasureTypeIdByFilter;
        end;
        DS.Execute;
        Result:=Result and DS.ExecuteSuccess;

        if Result then begin
          JournalCheckupId:=AKey.Value;
          FDataSet.Edit;
          FDataSet.FieldByName('JOURNAL_CHECKUP_ID').Value:=JournalCheckupId;
          FDataSet.Post;
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
        DS.ProviderName:=SProviderUpdateJournalCheckup;
        DS.StopException:=true;
        with DS.ExecuteDefs do begin
          AddKeyLink('JOURNAL_CHECKUP_ID').Value:=JournalCheckupId;
          AddInvisible('JOURNAL_NUM').Value:=iff(Trim(VarToStrDef(JournalNum,''))<>'',JournalNum,Null);
          AddInvisible('NOTE').Value:=iff(Trim(VarToStrDef(Note,''))<>'',Note,Null);
          AddInvisible('CYCLE_ID').Value:=CycleId;
          AddInvisible('POINT_ID').Value:=PointId;
          AddInvisible('DEFECT_VIEW_ID').Value:=DefectViewId;
          AddInvisible('DATE_OBSERVATION').Value:=DateObservation;
          AddInvisible('WHO_ENTER').Value:=WhoEnter;
          AddInvisible('DATE_ENTER').Value:=DateEnter;
          AddInvisible('WHO_CONFIRM').Value:=WhoConfirm;
          AddInvisible('DATE_CONFIRM').Value:=DateConfirm;
          AddInvisible('INCLINATION').Value:=Inclination;
          AddInvisible('WIDTH_DEFECT').Value:=WidthDefect;
          AddInvisible('HEIGHT_DEFECT').Value:=HeightDefect;
          AddInvisible('LENGTH_DEFECT').Value:=LengthDefect;
          AddInvisible('MEASURE_TYPE_ID').Value:=GetMeasureTypeIdByFilter;
        end;
        DS.Execute;
        Result:=Result and DS.ExecuteSuccess;
      finally
        DS.Free;
      end;
    end;

    procedure DeleteLocalDocsByJournalCheckupId;
    var
      DS: TSgtsDatabaseCDS;
    begin
      DS:=TSgtsDatabaseCDS.Create(CoreIntf);
      try
        DS.ProviderName:=SProviderDeleteDocCheckupJournal;
        DS.StopException:=true;
        with DS.ExecuteDefs do begin
          AddKeyLink('JOURNAL_CHECKUP_ID').Value:=JournalCheckupId;
        end;
        DS.Execute;
      finally
        DS.Free;
      end;
    end;

    procedure InsertLocalDoc;
    var
      DS: TSgtsDatabaseCDS;
      AKey: TSgtsExecuteDefKey;
    begin
      DS:=TSgtsDatabaseCDS.Create(CoreIntf);
      try
        DS.ProviderName:=SProviderInsertDocCheckup;
        DS.StopException:=true;
        with DS.ExecuteDefs do begin
          AKey:=AddKey('DOC_CHECKUP_ID');
          AddInvisible('JOURNAL_CHECKUP_ID').Value:=JournalCheckupId;
          AddInvisible('DATE_DOC').Value:=FDataSetDocs.FieldByName('DATE_DOC').Value;
          AddInvisible('NAME').Value:=FDataSetDocs.FieldByName('NAME').Value;
          AddInvisible('DESCRIPTION').Value:=FDataSetDocs.FieldByName('DESCRIPTION').Value;
          with AddInvisible('DOC') do begin
            Value:=FDataSetDocs.FieldByName('DOC').Value;
        //    DataType:=ftBlob;
          end;
          AddInvisible('EXTENSION').Value:=FDataSetDocs.FieldByName('EXTENSION').Value;
        end;
        DS.Execute;

        if DS.ExecuteSuccess then begin
          FDataSetDocs.Edit;
          FDataSetDocs.FieldByName('DOC_CHECKUP_ID').Value:=AKey.Value;
          FDataSetDocs.Post;
        end;
      finally
        DS.Free;
      end;
    end;
    
  var
    RecordExists: Boolean;
    FOldAfterScroll: TDataSetNotifyEvent;
    Position: Integer;
    OldChecked: Boolean;
  begin
    if not VarIsNull(DefectViewId) then begin
      JournalCheckupId:=FDataSet.FieldByName('JOURNAL_CHECKUP_ID').Value;
      RecordExists:=not VarIsNull(JournalCheckupId);
      if not RecordExists then
        InsertLocal
      else UpdateLocal;

      if Result and not VarIsNull(JournalCheckupId) then begin

        DeleteLocalDocsByJournalCheckupId;
         
        CoreIntf.MainForm.Progress2(0,FDataSetDocs.RecordCount,0);
        FOldAfterScroll:=FDataSetDocs.AfterScroll;
        FDataSetDocs.AfterScroll:=nil;
        OldChecked:=CheckBoxDocPreview.Checked;
        CheckBoxDocPreview.Checked:=false;
        try
          Position:=0;
          FDataSetDocs.First;
          while not FDataSetDocs.Eof do begin
            InsertLocalDoc;
            Inc(Position);
            CoreIntf.MainForm.Progress2(0,FDataSetDocs.RecordCount,Position);
            FDataSetDocs.Next;
          end;
        finally
          CheckBoxDocPreview.Checked:=OldChecked;
          FDataSetDocs.AfterScroll:=FOldAfterScroll;
          CoreIntf.MainForm.Progress2(0,0,0);
        end;
      end;
    end;
  end;

var
  OldCursor: TCursor;
  IsChange: Boolean;
begin
  Result:=true;
  if FDataSet.Active and
     not FDataSet.IsEmpty and
     FDataSetDocs.Active and
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
        DefectViewId:=FDataSet.FieldByName('DEFECT_VIEW_ID').Value;
        WhoEnter:=FDataSet.FieldByName('WHO_ENTER').Value;
        DateEnter:=FDataSet.FieldByName('DATE_ENTER').Value;
        DateObservation:=FDataSet.FieldByName('DATE_OBSERVATION').Value;
        WhoConfirm:=FDataSet.FieldByName('WHO_CONFIRM').Value;
        DateConfirm:=FDataSet.FieldByName('DATE_CONFIRM').Value;
        Inclination:=FDataSet.FieldByName('INCLINATION').Value;
        WidthDefect:=FDataSet.FieldByName('WIDTH_DEFECT').Value;
        HeightDefect:=FDataSet.FieldByName('HEIGHT_DEFECT').Value;
        LengthDefect:=FDataSet.FieldByName('LENGTH_DEFECT').Value;

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

procedure TSgtsFunSourceDataMeasureVisualFrame.GoEdit(AGrid: TSgtsFunSourceDbGrid; WithEditor: Boolean; WithDataSet: Boolean; EditorMode: Boolean=true);
begin
  if IsEdit then begin
    if not (dgEditing in AGrid.Options) then begin
      AGrid.Options:=AGrid.Options+[dgEditing];
    end;
    AGrid.TopLeftChanged;
    if WithDataSet then begin
      if AGrid=FGrid then begin
        with FDataSet do begin
          if IsEmpty and (State<>dsInsert) then Insert
          else if (State<>dsEdit) then Edit;
        end;
      end else begin
        with FDataSetDocs do begin
          if IsEmpty and (State<>dsInsert) then Insert
          else if (State<>dsEdit) then Edit;
        end;
      end;
    end;
    if WithEditor then begin
      AGrid.EditorMode:=EditorMode;
    end;
  end;
end;

procedure TSgtsFunSourceDataMeasureVisualFrame.GoDropDown(AGrid: TSgtsFunSourceDbGrid);
var
  Column: TColumn;
begin
  if IsEdit then begin
    Column:=GetCurrentColumn(AGrid);
    if Assigned(AGrid.InplaceEdit) and Assigned(Column) then begin
      TSgtsFunSourceEditList(AGrid.InplaceEdit).CloseUp(true);
      if (Column.PickList.Count>0) and not AGrid.InplaceEdit.ListVisible then begin
        TSgtsFunSourceEditList(AGrid.InplaceEdit).DropDown;
      end;
    end;
  end;
end;

procedure TSgtsFunSourceDataMeasureVisualFrame.SetAdditionalInfo;
var
  PointId: Variant;
  ObjectPaths, CoordinateZ: Variant;
begin
  DBEditJournalNum.Color:=iff(IsCanUpdate and IsEdit and not GetIsConfirm,clWindow,clBtnFace);
  DBMemoNote.Color:=DBEditJournalNum.Color;
  if FDataSet.Active and
     not FDataSet.IsEmpty and
     FDataSetPoints.Active and
     not FDataSetPoints.IsEmpty then begin
    PointId:=FDataSet.FieldByName('POINT_ID').Value;
    if GetAdditionalInfo(PointId,ObjectPaths,CoordinateZ) then begin
      EditPointCoordinateZ.Text:=VarToStrDef(CoordinateZ,'');
    end else begin
      EditPointCoordinateZ.Text:='';
    end;
  end;
end;

function TSgtsFunSourceDataMeasureVisualFrame.GetAdditionalInfo(PointId: Variant; var ObjectPaths, CoordinateZ: Variant;
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

procedure TSgtsFunSourceDataMeasureVisualFrame.GridKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
var
  ColumnType: TSgtsFunSourceDataMeasureVisualColumnType;
  Index: Integer;
  AGrid: TSgtsFunSourceDbGrid;
begin
  FNewRecordMode:=rmInput;
  AGrid:=Sender as TSgtsFunSourceDbGrid;

  ColumnType:=GetColumnType(GetCurrentColumn(AGrid));
  case Key of
    VK_DELETE: begin
      if (ssCtrl in Shift) then begin
        Key:=0;
        exit;
      end;
    end;
    VK_F2: begin
      if not CanUpdate then
        GoBrowse(AGrid,false)
      else Key:=0;
    end;
    VK_F3: begin
      if not CanDetail then
        if IsCanInfo then
          ShowInfo(FDataSet.GetInfo)
    end;
    VK_SPACE: begin
      if ColumnType=ctConfirm then begin
        Confirm;
        Key:=0;
      end;
    end;
    VK_RETURN: begin
      if ColumnType in ReturnColumnTypes then begin
        if GetCurrentColumn(AGrid).PickList.Count>0 then
          GoBrowse(AGrid,true)
        else begin
          GoBrowse(AGrid,false);
        end;
        Index:=AGrid.SelectedIndex+1;
        if NextPresent(AGrid,Index,ReturnColumnTypes) then
          AGrid.SelectedIndex:=Index
        else begin
          if CheckRecord(false,true,true) then begin
            if SaveRecord then begin
              if IsCanInsert and IsEdit then begin
                if FDataSet.RecNo=FDataSet.RecordCount then
                  FDataSet.Append
                else FDataSet.Next;
                AGrid.SelectedIndex:=0;
              end;
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
         (GetCurrentColumn(AGrid).PickList.Count>0) and
         IsCanUpdate and
         not GetIsConfirm then begin
        GoEdit(AGrid,true,true);
        GoDropDown(AGrid);
        Key:=0;
      end else begin
        FNewRecordMode:=rmCancel;
      end;
    end;
    VK_UP: begin
    end;
    VK_INSERT: begin
      Key:=0;
    end;

    else begin
      case ColumnType of
        ctDate: begin
          if IsCanUpdate and
             not GetIsConfirm then
            GoEdit(AGrid,false,false);
        end;
        ctInclination,ctWidthDefect,ctHeightDefect,ctLengthDefect: begin
          if IsCanUpdate and
             not GetIsConfirm then begin
            GoEdit(AGrid,false,false);
          end;
        end;
      end;
    end;
    
  end;
end;

function TSgtsFunSourceDataMeasureVisualFrame.GetConfirmProc(
  Def: TSgtsSelectDef): Variant;
begin
  Result:=0;
  if not VarIsNull(FDataSet.FieldByName('WHO_CONFIRM').Value) then
    Result:=1;
end;

function TSgtsFunSourceDataMeasureVisualFrame.GetCurrentColumn(
  AGrid: TSgtsFunSourceDbGrid): TColumn;
var
  Index: Integer;
begin
  Result:=nil;
  Index:=AGrid.SelectedIndex;
  if Index in [0..AGrid.Columns.Count-1] then
    Result:=AGrid.Columns[Index];
end;

procedure TSgtsFunSourceDataMeasureVisualFrame.GoBrowse(AGrid: TSgtsFunSourceDbGrid;
  ChangeMode: Boolean);
begin
  if ChangeMode then begin
    if AGrid=FGrid then begin
      with FDataSet do begin
        if State in [dsInsert,dsEdit] then
          Post;
      end;
    end;
    if AGrid=FGridDocs then
      with FDataSetDocs do begin
        if State in [dsInsert,dsEdit] then
          Post;
      end;
  end;
  AGrid.Options:=AGrid.Options-[dgEditing];
  AGrid.EditorMode:=false;
end;

procedure TSgtsFunSourceDataMeasureVisualFrame.PointNameFieldSetText(
  Sender: TField; const Text: string);
var
  Column: TColumn;
  Index: Integer;
  Obj: TSgtsPointInfo;
  ObjectPaths,CoordinateZ: Variant;
begin
  Column:=GetCurrentColumn(FGrid);
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
      FDataSet.FieldByName('IS_CHANGE').Value:=Integer(true);
      if GetAdditionalInfo(Obj.PointId,ObjectPaths,CoordinateZ,';') then begin
        FDataSet.FieldByName('OBJECT_PATHS').Value:=ObjectPaths;
        FDataSet.FieldByName('COORDINATE_Z').Value:=CoordinateZ;
      end;
      FChangePresent:=true;
      GoBrowse(FGrid,false);
    end;
  end;
end;

procedure TSgtsFunSourceDataMeasureVisualFrame.PopupMenuDocsPopup(
  Sender: TObject);
begin
  PopupMenuDocs.Items.Clear;
  CreateMenuByToolBar(TMenuItem(PopupMenuDocs.Items),ToolBarDocs);
end;

procedure TSgtsFunSourceDataMeasureVisualFrame.DateObservationFieldSetText(
  Sender: TField; const Text: string);
var
  NewDate: TDate;
begin
  NewDate:=StrToDateDef(Text,0.0);
  if NewDate<>0.0 then begin
    try
      Sender.Value:=NewDate;
      FDataSet.FieldByName('IS_CHANGE').Value:=Integer(true);
      FChangePresent:=true;
      GoBrowse(FGrid,false);
    except
      On E: Exception do
        ShowError(E.Message);
    end;
  end;
end;

procedure TSgtsFunSourceDataMeasureVisualFrame.DBMemoNoteExit(Sender: TObject);
begin
  GoBrowse(FGrid,true);
end;

procedure TSgtsFunSourceDataMeasureVisualFrame.DBMemoNoteKeyDown(
  Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if FDataSet.Active and not FDataSet.IsEmpty then begin
    GoEdit(FGrid,False,True,False);
    FDataSet.FieldByName('IS_CHANGE').Value:=Integer(true);
    FChangePresent:=true;
  end;
end;

procedure TSgtsFunSourceDataMeasureVisualFrame.DefectViewNameFieldSetText(
  Sender: TField; const Text: string);
var
  Column: TColumn;
  Index: Integer;
  Obj: TSgtsDefectViewInfo;
begin
  Column:=GetCurrentColumn(FGrid);
  if Assigned(Column) and
     Assigned(FGrid.InplaceEdit) then begin
    Index:=FGrid.InplaceEdit.PickList.ItemIndex;
    if Index in [0..Column.PickList.Count-1] then begin
      Obj:=TSgtsDefectViewInfo(Column.PickList.Objects[Index]);
      Sender.Value:=Obj.DefectViewName;
      FDataSet.FieldByName('DEFECT_VIEW_ID').Value:=Obj.DefectViewId;
      FDataSet.FieldByName('IS_CHANGE').Value:=Integer(true);
      FChangePresent:=true;
      GoBrowse(FGrid,false);
    end;
  end;
end;

procedure TSgtsFunSourceDataMeasureVisualFrame.DefectFieldSetText(
  Sender: TField; const Text: string);
begin
  Sender.Value:=Text;
  FDataSet.FieldByName('IS_CHANGE').Value:=Integer(true);
  FChangePresent:=true;
  GoBrowse(FGrid,false);
end;

procedure TSgtsFunSourceDataMeasureVisualFrame.DateDocFieldSetText(Sender: TField; const Text: string);
var
  NewDate: TDate;
begin
  NewDate:=StrToDateDef(Text,0.0);
  if NewDate<>0.0 then begin
    try
      Sender.Value:=NewDate;
      FDataSet.Edit;
      FDataSet.FieldByName('IS_CHANGE').AsInteger:=Integer(True);
      FDataSet.Post;
      FChangePresent:=true;
      GoBrowse(FGridDocs,false);
    except
      On E: Exception do
        ShowError(E.Message);
    end;
  end;
end;

procedure TSgtsFunSourceDataMeasureVisualFrame.DataSetAfterPost(
  DataSet: TDataSet);
begin
  if DataSet=FDataSet then
    GoBrowse(FGrid,false)
  else begin
    GoBrowse(FGridDocs,false);
  end;
end;

procedure TSgtsFunSourceDataMeasureVisualFrame.DataSetAfterScroll(
  DataSet: TDataSet);
begin
  SetColumnProperty(GetCurrentColumn(FGrid));
  SetAdditionalInfo;
  UpdateButtons;
  RefreshDoc;
end;

procedure TSgtsFunSourceDataMeasureVisualFrame.DataSetDocsAfterScroll(
  DataSet: TDataSet);
begin
  GridColEnter(FGridDocs);
  UpdatePreview;
end;

procedure TSgtsFunSourceDataMeasureVisualFrame.DataSetDocsBeforePost(
  DataSet: TDataSet);
begin
end;

procedure TSgtsFunSourceDataMeasureVisualFrame.DataSetNewRecord(
  DataSet: TDataSet);
var
  FOldAfterScroll: TDataSetNotifyEvent;
begin
  case FNewRecordMode of
    rmCancel: FDataSet.Cancel;
    rmInput: begin
      FOldAfterScroll:=FDataSetDocs.AfterScroll;
      FDataSetDocs.AfterScroll:=nil;
      try
        FChangePresent:=true;
        FDataSet.FieldByName('ID').Value:=CreateUniqueId;
        FDataSet.FieldByName('IS_CHANGE').Value:=Integer(True);
        FDataSet.FieldByName('IS_LOAD').Value:=Integer(False);
        FDataSet.FieldByName('CYCLE_ID').Value:=GetValueByCounter('CYCLE_ID',0);
        FDataSet.FieldByName('DATE_OBSERVATION').Value:=DateOf(Date);
        FDataSet.FieldByName('WHO_ENTER').Value:=Database.PersonnelId;
        FDataSet.FieldByName('DATE_ENTER').Value:=DateOf(Date);
      finally
        FDataSetDocs.AfterScroll:=FOldAfterScroll;
      end;
    end;
    rmFillEmpty: begin
      FOldAfterScroll:=FDataSetDocs.AfterScroll;
      FDataSetDocs.AfterScroll:=nil;
      try
        FDataSet.FieldByName('ID').Value:=CreateUniqueId;
        FDataSet.FieldByName('IS_CHANGE').Value:=Integer(False);
        FDataSet.FieldByName('IS_LOAD').Value:=Integer(False);
        FDataSet.FieldByName('JOURNAL_NUM').Value:=JournalNum;
        FDataSet.FieldByName('WHO_ENTER').Value:=Database.PersonnelId;
        FDataSet.FieldByName('DATE_ENTER').Value:=DateOf(Date);
      finally
        FDataSetDocs.AfterScroll:=FOldAfterScroll;
      end;
    end;
  end;
end;

procedure TSgtsFunSourceDataMeasureVisualFrame.DataSetDocsNewRecord(
  DataSet: TDataSet);
begin
  try
    FFlagNewDocRecord:=true;
    try
      InsertDoc;
    finally
      FFlagNewDocRecord:=false;            
    end;
  except
    FDataSetDocs.Cancel;
  end;
end;

function TSgtsFunSourceDataMeasureVisualFrame.GetChangeArePresent: Boolean;
begin
  Result:=FChangePresent;
end;

procedure TSgtsFunSourceDataMeasureVisualFrame.SetChangeArePresent(
  Value: Boolean);
begin
  FChangePresent:=Value;
end;

function TSgtsFunSourceDataMeasureVisualFrame.GetCycleNum: String;
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

function TSgtsFunSourceDataMeasureVisualFrame.GetRouteName: String;
begin
  Result:='';
  if FDataSet.Active and
     not FDataSet.IsEmpty then begin
    if FDataSetPoints.Locate('POINT_ID',FDataSet.FieldByName('POINT_ID').Value) then begin
      Result:=FDataSetPoints.FieldByName('ROUTE_NAME').AsString;
    end;
  end;
end;

function TSgtsFunSourceDataMeasureVisualFrame.Save: Boolean;
var
  APosition: Integer;
  OldChecked: Boolean;
begin
  Result:=Inherited Save;
  if CanSave then begin
    CoreIntf.MainForm.Progress(0,FDataSet.RecordCount,0);
    OldChecked:=CheckBoxDocPreview.Checked;
    CheckBoxDocPreview.Checked:=false;
    GoBrowse(FGrid,true);
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
        if CheckRecord(true,true,false) then begin
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
      InProgress:=false;
//      FDataSet.EndUpdate(true);
      FGrid.VisibleRowNumber:=true;
      FGrid.UpdateRowNumber;
      CheckBoxDocPreview.Checked:=OldChecked;
      UpdateButtons;
      CoreIntf.MainForm.Progress(0,0,0);
    end;
  end;
end;

function TSgtsFunSourceDataMeasureVisualFrame.CanSave: Boolean;
begin
  Result:=FDataSet.Active and
          not FDataSet.IsEmpty and
          FDataSetDocs.Active and
          FChangePresent;
end;

function TSgtsFunSourceDataMeasureVisualFrame.GetActiveControl: TWinControl;
begin
  Result:=FGrid;
end;

procedure TSgtsFunSourceDataMeasureVisualFrame.Insert;
begin
  if CanInsert then begin
    FGrid.SetFocus;
    FDataSet.Append;
  end;
end;

function TSgtsFunSourceDataMeasureVisualFrame.CanInsert: Boolean;
begin
  Result:=IsCanInsert and
          FDataSet.Active and
          IsEdit;
end;

procedure TSgtsFunSourceDataMeasureVisualFrame.GoSelect(AGrid: TSgtsFunSourceDbGrid; ReadOnly: Boolean);
begin
  if Assigned(AGrid.InplaceEdit) then begin
//    AGrid.InplaceEdit.SelStart:=0;
    AGrid.InplaceEdit.SelectAll;
    TSgtsFunSourceEditList(AGrid.InplaceEdit).ReadOnly:=ReadOnly;
  end;
end;

procedure TSgtsFunSourceDataMeasureVisualFrame.Update;
var
  ColumnType: TSgtsFunSourceDataMeasureVisualColumnType;
begin
  if CanUpdate then begin
    FGrid.SetFocus;
    GoEdit(FGrid,true,true);
    ColumnType:=GetColumnType(GetCurrentColumn(FGrid));
    GoSelect(FGrid,(ColumnType in PickListColumnTypes));
  end;
end;

function TSgtsFunSourceDataMeasureVisualFrame.CanUpdate: Boolean;
var
  ColumnType: TSgtsFunSourceDataMeasureVisualColumnType;
  Flag: Boolean;
begin
  Result:=IsCanUpdate and
          FDataSet.Active and
          IsEdit;
  if Result then begin
    Flag:=false;
    ColumnType:=GetColumnType(GetCurrentColumn(FGrid));
    if (ColumnType in EditColumnTypes) and
       not GetIsConfirm then begin
      Flag:=true;
      if ColumnType in PickListColumnTypes then
        Flag:=GetCurrentColumn(FGrid).PickList.Count>0;
    end;
    Result:=Result and Flag;
  end;
end;

procedure TSgtsFunSourceDataMeasureVisualFrame.Delete;
var
  DS: TSgtsDatabaseCDS;
  JournalCheckupId: Variant;
  Flag: Boolean;
  ID: Variant;
begin
  if CanDelete then begin
    FGrid.SetFocus;
    FDataSet.BeginUpdate(true);
    try
      Flag:=true;
      JournalCheckupId:=FDataSet.FieldByName('JOURNAL_CHECKUP_ID').Value;
      ID:=FDataSet.FieldByName('ID').Value;
      LocalDeleteDocsByID(ID);
      if not VarIsNull(JournalCheckupId) then begin
        DS:=TSgtsDatabaseCDS.Create(CoreIntf);
        try
          DS.ProviderName:=SProviderDeleteJournalCheckup;
          DS.StopException:=true;
          DS.ExecuteDefs.AddKeyLink('JOURNAL_CHECKUP_ID').Value:=JournalCheckupId;
          DS.Execute;
          Flag:=DS.ExecuteSuccess;
        finally
          DS.Free;
        end;
      end;
      if Flag then begin
        FDataSet.Delete;
        RefreshDoc;
      end;
      UpdateButtons;
    finally
      FDataSet.EndUpdate;
    end;
  end;
end;

function TSgtsFunSourceDataMeasureVisualFrame.CanDelete: Boolean;
begin
  Result:=IsCanDelete and
          FDataSet.Active and
          not FDataSet.IsEmpty and
          not (FDataSet.State in [dsInsert,dsEdit]) and
          IsEdit and
          not GetIsConfirm;
end;

procedure TSgtsFunSourceDataMeasureVisualFrame.Confirm;
var
  Flag: Boolean;
  ADate: TDate;
begin
  if CanConfirm then begin
    FGrid.SetFocus;
    try
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
    finally
    end;
  end;
end;

function TSgtsFunSourceDataMeasureVisualFrame.CanConfirm: Boolean;
begin
  Result:=IsCanConfirm and
          Assigned(Database) and
          FDataSet.Active and
          not FDataSet.IsEmpty and
          IsEdit;
end;

procedure TSgtsFunSourceDataMeasureVisualFrame.ViewPointInfo;
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
    AIface.SelectByUnionType('UNION_ID;UNION_TYPE',VarArrayOf([FDataSet.FieldByName('POINT_ID').Value,utPoint]),Data,utPoint,AFilterGroups,false);
  finally
    AFilterGroups.Free;
    AIface.Free;
  end;
end;

procedure TSgtsFunSourceDataMeasureVisualFrame.ViewObjectTreeInfo;
var
  Column: TColumn;
  ColumnType: TSgtsFunSourceDataMeasureVisualColumnType;
  AIface: TSgtsFunSourceDataObjectTreesIface;
begin
  Column:=GetCurrentColumn(FGrid);
  ColumnType:=GetColumnType(Column);
  if ColumnType=ctObjectPaths then begin 
    AIface:=TSgtsFunSourceDataObjectTreesIface.CreateByObjectId(CoreIntf,GetObjectIdByFilter);
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

procedure TSgtsFunSourceDataMeasureVisualFrame.ViewDefectInfo;
begin
  //
end;

procedure TSgtsFunSourceDataMeasureVisualFrame.Detail;
var
  ColumnType: TSgtsFunSourceDataMeasureVisualColumnType;
begin
  if CanDetail then begin
    FGrid.SetFocus;
    ColumnType:=GetColumnType(GetCurrentColumn(FGrid));
    case ColumnType of
      ctPointName, ctCoordinateZ: ViewPointInfo;
      ctObjectPaths: ViewObjectTreeInfo;
      ctDefectView: ViewDefectInfo;
    end;
  end;
end;

function TSgtsFunSourceDataMeasureVisualFrame.CanDetail: Boolean;
var
  Column: TColumn;
  ColumnType: TSgtsFunSourceDataMeasureVisualColumnType;
begin
  Column:=GetCurrentColumn(FGrid);
  Result:=IsCanDetail and
          FDataSet.Active and
          not FDataSet.IsEmpty;
  if Result then begin
    ColumnType:=GetColumnType(Column);
    Result:=ColumnType in InfoColumnTypes;
    if Result then begin
      case ColumnType of
        ctPointName: begin
          Result:=not VarIsNull(FDataSet.FieldByName('POINT_ID').Value) and
                  (Trim(FDataSet.FieldByName('POINT_NAME').AsString)<>'');
        end;
        ctDefectView: begin
          Result:=not VarIsNull(FDataSet.FieldByName('DEFECT_VIEW_ID').Value) and
                 (Trim(FDataSet.FieldByName('DEFECT_VIEW_NAME').AsString)<>'');
        end;
      end;
    end;
  end;
end;

procedure TSgtsFunSourceDataMeasureVisualFrame.ToolButtonDocDeleteClick(
  Sender: TObject);
begin
  DeleteDoc;
end;

procedure TSgtsFunSourceDataMeasureVisualFrame.ToolButtonDocInsertClick(
  Sender: TObject);
begin
  InsertDoc;
end;

procedure TSgtsFunSourceDataMeasureVisualFrame.ToolButtonDocLoadClick(
  Sender: TObject);
begin
  LoadDoc;
end;

procedure TSgtsFunSourceDataMeasureVisualFrame.ToolButtonDocRefreshClick(
  Sender: TObject);
begin
  RefreshDoc;
end;

procedure TSgtsFunSourceDataMeasureVisualFrame.ToolButtonDocSaveClick(
  Sender: TObject);
begin
  SaveDoc;
end;

procedure TSgtsFunSourceDataMeasureVisualFrame.ToolButtonDocUpdateClick(
  Sender: TObject);
begin
  UpdateDoc;
end;

procedure TSgtsFunSourceDataMeasureVisualFrame.ToolButtonDocViewClick(
  Sender: TObject);
begin
  ViewDoc;
end;

procedure TSgtsFunSourceDataMeasureVisualFrame.UpdateButtons;
begin
  inherited UpdateButtons;
  ToolButtonDocRefresh.Enabled:=CanRefreshDoc;
  ToolButtonDocInsert.Enabled:=CanInsertDoc;
  ToolButtonDocUpdate.Enabled:=CanUpdateDoc;
  ToolButtonDocDelete.Enabled:=CanDeleteDoc;
  ToolButtonDocLoad.Enabled:=CanLoadDoc;
  ToolButtonDocSave.Enabled:=CanSaveDoc;
  ToolButtonDocView.Enabled:=CanViewDoc;
  DBEditJournalNum.ReadOnly:=not (FDataSet.Active and not FDataSet.IsEmpty and
                                  IsEdit and not GetIsConfirm);
  DBMemoNote.ReadOnly:=DBEditJournalNum.ReadOnly;
end;

procedure TSgtsFunSourceDataMeasureVisualFrame.GridDocsKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  ColumnType: TSgtsFunSourceDataMeasureVisualColumnType;
  Index: Integer;
  AGrid: TSgtsFunSourceDbGrid;
begin
  AGrid:=Sender as TSgtsFunSourceDbGrid;

  ColumnType:=GetColumnType(GetCurrentColumn(AGrid));
  case Key of
    VK_DELETE: begin
      if CanDeleteDoc then
        DeleteDoc;
      Key:=0;
      exit;
    end;
    VK_F2: begin
      if CanUpdateDoc then
        UpdateDoc;
      exit;
    end;
    VK_F3: begin
      ShowInfo(FDataSetDocs.GetInfo);
      exit;
    end;
    VK_RETURN: begin
      if (ColumnType in ReturnColumnTypes) then begin
        GoBrowse(AGrid,false);
        Index:=AGrid.SelectedIndex+1;
        if NextPresent(AGrid,Index,ReturnColumnTypes) then
          AGrid.SelectedIndex:=Index
        else begin
          FDataSetDocs.Next;
          AGrid.SelectedIndex:=0;
        end;
        Key:=0;
        exit;
      end;
    end;
    VK_INSERT: begin
      if CanInsertDoc then begin
        InsertDoc;
      end;
    end;
    else begin
      case ColumnType of
        ctDocDate,ctDocName,ctDocDescription: begin
          if CanUpdateDoc then
            GoEdit(AGrid,false,false);
        end;
      end;
    end;
  end;
end;

procedure TSgtsFunSourceDataMeasureVisualFrame.LocalDeleteDocsByID(ID: Variant);
begin
  FDataSetDocs.BeginUpdate;
  try
    FDataSetDocs.Filter:=Format('ID=%s',[QuotedStr(VarToStrDef(ID,''))]);
    FDataSetDocs.Filtered:=true;
    while not FDataSetDocs.Eof do begin
      FDataSetDocs.Delete;
    end;
  finally
    FDataSetDocs.EndUpdate;
  end;
end;

function TSgtsFunSourceDataMeasureVisualFrame.CanRefreshDoc: Boolean;
begin
  Result:=FDataSet.Active and not FDataSet.IsEmpty and
          FDataSetDocs.Active;
end;

procedure TSgtsFunSourceDataMeasureVisualFrame.RefreshDoc;
var
  DS: TSgtsDatabaseCDS;
  ID: Variant;
  JournalCheckupId: Variant;
  IsLoad: Boolean;
  OldCursor: TCursor;
begin
  if CanRefreshDoc then begin
    JournalCheckupId:=FDataSet.FieldByName('JOURNAL_CHECKUP_ID').Value;
    ID:=FDataSet.FieldByName('ID').Value;
    if not VarIsNull(JournalCheckupId) then begin
      IsLoad:=Boolean(FDataSet.FieldByName('IS_LOAD').AsInteger);
      if not IsLoad then begin
        OldCursor:=Screen.Cursor;
        Screen.Cursor:=crHourGlass;
        LocalDeleteDocsByID(ID);
        DS:=TSgtsDatabaseCDS.Create(CoreIntf);
        try
          DS.ProviderName:=SProviderSelectDocCheckups;
          DS.FilterGroups.Add.Filters.Add('JOURNAL_CHECKUP_ID',fcEqual,JournalCheckupId);
          DS.Open;
          if DS.Active then begin
            DS.First;
            FDataSetDocs.OnNewRecord:=nil;
            try
              while not DS.Eof do begin
                FDataSetDocs.Append;
                FDataSetDocs.FieldByName('ID').Value:=ID;
                FDataSetDocs.FieldValuesBySource(DS,false,false);
                FDataSetDocs.Post;
                DS.Next;
              end;
              FDataSet.Edit;
              FDataSet.FieldByName('IS_LOAD').AsInteger:=Integer(True);
              FDataSet.Post;
            finally
              FDataSetDocs.OnNewRecord:=DataSetDocsNewRecord;
            end;
          end;
        finally
          DS.Free;
          Screen.Cursor:=OldCursor;
        end;
      end;
      FDataSetDocs.Filter:=Format('ID=%s',[QuotedStr(VarToStrDef(ID,''))]);
      FDataSetDocs.Filtered:=true;
    end else begin
      FDataSetDocs.Filter:=Format('ID=%s',[QuotedStr(VarToStrDef(ID,''))]);
      FDataSetDocs.Filtered:=true;
    end;
    UpdateButtons;
  end;
end;

function TSgtsFunSourceDataMeasureVisualFrame.CanInsertDoc: Boolean;
begin
  Result:=FDataSet.Active and not FDataSet.IsEmpty and
          not VarIsNull(FDataSet.FieldByName('DEFECT_VIEW_ID').Value) and
          FDataSetDocs.Active and
          IsEdit and
          not GetIsConfirm;
end;

procedure TSgtsFunSourceDataMeasureVisualFrame.InsertDoc;
var
  FileDate: TDateTime;
begin
  if CanInsertDoc then begin
    FGridDocs.SetFocus;
    if OpenDialogDoc.Execute then begin
      FDataSetDocs.OnNewRecord:=nil;
      try
        FDataSet.Edit;
        FDataSet.FieldByName('IS_CHANGE').AsInteger:=Integer(True);
        FDataSet.Post;
        if not FFlagNewDocRecord then
          FDataSetDocs.Append;
        FDataSetDocs.FieldByName('ID').Value:=FDataSet.FieldByName('ID').Value;
        FDataSetDocs.FieldByName('DATE_DOC').Value:=DateOf(Date);
        if FileAge(OpenDialogDoc.FileName,FileDate) then
          FDataSetDocs.FieldByName('DATE_DOC').AsDateTime:=DateOf(FileDate);
        FDataSetDocs.FieldByName('NAME').AsString:=ChangeFileExt(ExtractFileName(OpenDialogDoc.FileName),'');
        TBlobField(FDataSetDocs.FieldByName('DOC')).LoadFromFile(OpenDialogDoc.FileName);
        FDataSetDocs.FieldByName('EXTENSION').AsString:=ExtractFileExt(OpenDialogDoc.FileName);
        GoBrowse(FGridDocs,true);
        UpdatePreview;
        FChangePresent:=true;
        UpdateButtons;
      finally
        FDataSetDocs.OnNewRecord:=DataSetDocsNewRecord;
      end;
    end else begin
      if FFlagNewDocRecord then
        raise Exception.Create('');
    end;
  end;
end;

function TSgtsFunSourceDataMeasureVisualFrame.CanUpdateDoc: Boolean;
begin
  Result:=FDataSet.Active and not FDataSet.IsEmpty and
          FDataSetDocs.Active and not FDataSetDocs.IsEmpty and
          IsEdit and
          not GetIsConfirm;
end;

procedure TSgtsFunSourceDataMeasureVisualFrame.UpdateDoc;
begin
  if CanUpdateDoc then begin
    FGridDocs.SetFocus;
    FDataSet.Edit;
    FDataSet.FieldByName('IS_CHANGE').AsInteger:=Integer(True);
    FDataSet.Post;
    GoEdit(FGridDocs,true,true);
    GoSelect(FGridDocs,false);
    FChangePresent:=true;
    UpdateButtons;
  end;
end;

function TSgtsFunSourceDataMeasureVisualFrame.CanDeleteDoc: Boolean;
begin
  Result:=CanUpdateDoc;
end;

procedure TSgtsFunSourceDataMeasureVisualFrame.DeleteDoc;
var
  Flag: Boolean;
  DocCheckupId: Variant;
  DS: TSgtsDatabaseCDS;
begin
  if CanDeleteDoc then begin
    if ShowQuestion(SDeleteCurrentRecord,mbNo)=mrYes then begin
      FGridDocs.SetFocus;
      FDataSet.Edit;
      FDataSet.FieldByName('IS_CHANGE').AsInteger:=Integer(True);
      FDataSet.Post;
      Flag:=true;
      DocCheckupId:=FDataSetDocs.FieldByName('DOC_CHECKUP_ID').Value;
      if not VarIsNull(DocCheckupId) then begin
        DS:=TSgtsDatabaseCDS.Create(CoreIntf);
        try
          DS.ProviderName:=SProviderDeleteDocCheckup;
          DS.StopException:=true;
          DS.ExecuteDefs.AddKeyLink('DOC_CHECKUP_ID').Value:=DocCheckupId;
          DS.Execute;
          Flag:=DS.ExecuteSuccess;
        finally
          DS.Free;
        end;
      end;
      if Flag then
        FDataSetDocs.Delete;
      FChangePresent:=true;
      UpdateButtons;
    end;
  end;
end;

function TSgtsFunSourceDataMeasureVisualFrame.CanSaveDoc: Boolean;
begin
  Result:=FDataSet.Active and not FDataSet.IsEmpty and
          FDataSetDocs.Active and not FDataSetDocs.IsEmpty and
          not VarIsNull(FDataSetDocs.FieldByName('DOC').Value) and
          not VarIsNull(FDataSetDocs.FieldByName('EXTENSION').Value);
end;

procedure TSgtsFunSourceDataMeasureVisualFrame.SaveDoc;
var
  FileName: String;
begin
  if CanSaveDoc then begin
    FGridDocs.SetFocus;
    FileName:=FDataSetDocs.FieldByName('NAME').AsString+FDataSetDocs.FieldByName('EXTENSION').AsString;
    SaveDialogDoc.FileName:=FileName;
    if SaveDialogDoc.Execute then begin
      TBlobField(FDataSetDocs.FieldByName('DOC')).SaveToFile(SaveDialogDoc.FileName);
    end;
  end;
end;

function TSgtsFunSourceDataMeasureVisualFrame.CanLoadDoc: Boolean;
begin
  Result:=FDataSet.Active and not FDataSet.IsEmpty and
          FDataSetDocs.Active and not FDataSetDocs.IsEmpty and
          not GetIsConfirm;
end;

procedure TSgtsFunSourceDataMeasureVisualFrame.LoadDoc;
begin
  if CanLoadDoc then begin
    FGridDocs.SetFocus;
    if OpenDialogDoc.Execute then begin
      FDataSet.Edit;
      FDataSet.FieldByName('IS_CHANGE').AsInteger:=Integer(True);
      FDataSet.Post;
      FDataSetDocs.Edit;
      TBlobField(FDataSetDocs.FieldByName('DOC')).LoadFromFile(OpenDialogDoc.FileName);
      FDataSetDocs.FieldByName('EXTENSION').AsString:=ExtractFileExt(OpenDialogDoc.FileName);
      FDataSetDocs.Post;
      UpdatePreview;
      FChangePresent:=true;
      UpdateButtons;
    end;
  end;
end;

function TSgtsFunSourceDataMeasureVisualFrame.CanViewDoc: Boolean;
begin
  Result:=CanSaveDoc;
end;

procedure TSgtsFunSourceDataMeasureVisualFrame.ViewDoc;
var
  Stream: TMemoryStream;
  FileName: String;
  Extension: String;
begin
  if CanViewDoc then begin
    FGridDocs.SetFocus;
    Stream:=TMemoryStream.Create;
    try
      TBlobField(FDataSetDocs.FieldByName('DOC')).SaveToStream(Stream);
      Stream.Position:=0;
      if Stream.Size>0 then begin
        Extension:=FDataSetDocs.FieldByName('EXTENSION').AsString;
        FileName:=GetNewTempFileName(Extension);
        if Trim(FileName)<>'' then begin
          Stream.SaveToFile(FileName);
          FTempFiles.Add(FileName);
          ShellExecute(0,nil,PChar(FileName),nil,nil,SW_SHOW);
        end;
      end;
    finally
      Stream.Free;
    end;
  end;
end;

function TSgtsFunSourceDataMeasureVisualFrame.GetNewTempFileName(Extension: String): String;
var
  TempDir : array[0..MAX_PATH] of char;
begin
  TempDir[GetTempPath(260, TempDir)] := #0;
  Result:=TempDir;
  Result:=Result+CreateUniqueId+Extension;
end;

procedure TSgtsFunSourceDataMeasureVisualFrame.UpdatePreview;
type
  TSgtsPreviewType=(ptUnknown,ptOle,ptImage);

  function GetPreviewType(Extension: String): TSgtsPreviewType;
  var
    ImageExtensions: TStringList;
  begin
    ImageExtensions:=TStringList.Create;
    try
      ImageExtensions.Add('.bmp');
      ImageExtensions.Add('.jpg');
      ImageExtensions.Add('.jpeg');

      Result:=ptUnknown;
      if ImageExtensions.IndexOf(Extension)<>-1 then
        Result:=ptImage
      else Result:=ptOle;  
      
    finally
      ImageExtensions.Free;
    end;
  end;

var
  Stream: TMemoryStream;
  FileName: String;
  Flag: Boolean;
  OldCursor: TCursor;
  Extension: String;
  PreviewType: TSgtsPreviewType;
begin
  OleContainer.DestroyObject;
  OleContainer.Visible:=false;
  ImagDoc.Visible:=false;
  if CheckBoxDocPreview.Checked and FDataSetDocs.Active and not FDataSetDocs.IsEmpty then begin
    UpdateFrame;
    OldCursor:=Screen.Cursor;
    Screen.Cursor:=crHourGlass;
    Stream:=TMemoryStream.Create;
    try
      TBlobField(FDataSetDocs.FieldByName('DOC')).SaveToStream(Stream);
      Stream.Position:=0;
      Flag:=Stream.Size>0;
      if Flag then begin
        Extension:=FDataSetDocs.FieldByName('EXTENSION').AsString;
        FileName:=GetNewTempFileName(Extension);
        Flag:=Trim(FileName)<>'';
        if Flag then begin
          Stream.SaveToFile(FileName);
          FTempFiles.Add(FileName);
          PreviewType:=GetPreviewType(Extension);
          case PreviewType of
            ptUnknown:;
            ptOle: begin
              OleContainer.CreateObjectFromFile(FileName,false);
              OleContainer.Visible:=true;
            end;
            ptImage: begin
              ImagDoc.Picture.LoadFromFile(FileName);
              ImagDoc.Visible:=true;
            end;
          end;
        end;
      end;
    finally
      Stream.Free;
      Screen.Cursor:=OldCursor;
    end;
  end;
end;

procedure TSgtsFunSourceDataMeasureVisualFrame.CheckBoxDocPreviewClick(
  Sender: TObject);
begin
  UpdatePreview;
end;

procedure TSgtsFunSourceDataMeasureVisualFrame.GridDblClick(Sender: TObject);
begin
  Update;
end;

procedure TSgtsFunSourceDataMeasureVisualFrame.GridDocsDblClick(Sender: TObject);
begin
  ViewDoc;
end;

procedure TSgtsFunSourceDataMeasureVisualFrame.DeleteTempFiles;
var
  i: Integer;
begin
  for i:=0 to FTempFiles.Count-1 do begin
    DeleteFile(FTempFiles.Strings[i]);
  end;
end;

end.