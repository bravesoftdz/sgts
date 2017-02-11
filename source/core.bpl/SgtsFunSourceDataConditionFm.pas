unit SgtsFunSourceDataConditionFm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, CheckLst, Grids, DBGrids, DB, Menus, ComCtrls,
  SgtsFm, SgtsDialogFm, SgtsCoreIntf, SgtsGetRecordsConfig, SgtsDbGrid, SgtsCDS,
  SgtsSelectDefs, SgtsDatabaseCDS, SgtsControls, SgtsDateEdit;

type
  TSgtsCycleInfo=class(TObject)
  private
    FCycleId: Variant;
    FCycleNum: Integer;
    FCycleMonth: Integer;
    FCycleYear: Integer;
    FCycleIsClose: Boolean;
  public
    property CycleId: Variant read FCycleId write FCycleId;
    property CycleNum: Integer read FCycleNum write FCycleNum;
    property CycleMonth: Integer read FCycleMonth write FCycleMonth;
    property CycleYear: Integer read FCycleYear write FCycleYear;
    property CycleIsClose: Boolean read FCycleIsClose write FCycleIsClose;
  end;

  TSgtsRouteInfo=class(TObject)
  private
    FRouteId: Variant;
    FRouteName: String;
  public
    property RouteId: Variant read FRouteId write FRouteId;
    property RouteName: String read FRouteName write FRouteName;
  end;

  TSgtsObjectInfo=class(TObject)
  private
    FObjectId: Variant;
    FObjectName: String;
    FObjectPaths: String;
  public
    property ObjectId: Variant read FObjectId write FObjectId;
    property ObjectName: String read FObjectName write FObjectName;
    property ObjectPaths: String read FObjectPaths write FObjectPaths;
  end;

  TSgtsInstrumentInfo=class(TObject)
  private
    FInstrumentId: Variant;
    FInstrumentName: String;
  public
    property InstrumentId: Variant read FInstrumentId write FInstrumentId;
    property InstrumentName: String read FInstrumentName write FInstrumentName;
  end;

  TSgtsMeasureUnitInfo=class(TObject)
  private
    FMeasureUnitId: Variant;
    FMeasureUnitName: String;
  public
    property MeasureUnitId: Variant read FMeasureUnitId write FMeasureUnitId;
    property MeasureUnitName: String read FMeasureUnitName write FMeasureUnitName;
  end;

  TSgtsPointInfo=class(TObject)
  private
    FPointId: Variant;
    FPointName: String;
  public
    property PointId: Variant read FPointId write FPointId;
    property PointName: String read FPointName write FPointName;
  end;

  TSgtsFunSourceDataConditionIface=class;

  TSgtsFunSourceDataConditionForm = class(TSgtsDialogForm)
    GroupBoxCycles: TGroupBox;
    PanelCycles: TPanel;
    CheckListBoxCycles: TCheckListBox;
    GroupBoxMeasureType: TGroupBox;
    EditMeasureType: TEdit;
    ButtonMeasureType: TButton;
    GroupBoxParams: TGroupBox;
    PanelParams: TPanel;
    GridPattern: TDBGrid;
    DataSource: TDataSource;
    GroupBoxViewType: TGroupBox;
    RadioButtonViewOnly: TRadioButton;
    RadioButtonViewEdit: TRadioButton;
    PopupMenuParams: TPopupMenu;
    MenuItemCheckAll: TMenuItem;
    MenuItemUncheckAll: TMenuItem;
    GroupBoxAdditional: TGroupBox;
    LabelPresent: TLabel;
    ComboBoxPresent: TComboBox;
    LabelJournalNum: TLabel;
    EditJournalNum: TEdit;
    GroupBoxDate: TGroupBox;
    LabelDateBegin: TLabel;
    DateTimePickerBegin: TDateTimePicker;
    DateTimePickerEnd: TDateTimePicker;
    ButtonDate: TButton;
    CheckBoxDateEnd: TCheckBox;
    CheckBoxRestrictIsBase: TCheckBox;
    PopupMenuRoutes: TPopupMenu;
    MenuItemRoutesCheckAll: TMenuItem;
    MenuItemRoutesUnCheckAll: TMenuItem;
    GridPanelRoutesObjects: TGridPanel;
    GroupBoxRoutes: TGroupBox;
    PanelRoutes: TPanel;
    CheckListBoxRoutes: TCheckListBox;
    GroupBoxObject: TGroupBox;
    ButtonObject: TButton;
    ComboBoxObjects: TComboBox;
    procedure ButtonMeasureTypeClick(Sender: TObject);
    procedure EditMeasureTypeChange(Sender: TObject);
    procedure CheckListBoxCyclesClickCheck(Sender: TObject);
    procedure CheckListBoxRoutesClickCheck(Sender: TObject);
    procedure ButtonObjectClick(Sender: TObject);
    procedure ComboBoxObjectsChange(Sender: TObject);
    procedure RadioButtonViewOnlyClick(Sender: TObject);
    procedure MenuItemCheckAllClick(Sender: TObject);
    procedure MenuItemUncheckAllClick(Sender: TObject);
    procedure ButtonDateClick(Sender: TObject);
    procedure ButtonOkClick(Sender: TObject);
    procedure CheckBoxDateEndClick(Sender: TObject);
    procedure MenuItemRoutesCheckAllClick(Sender: TObject);
    procedure MenuItemRoutesUnCheckAllClick(Sender: TObject);
  private
    FGrid: TSgtsDbGrid;
    FDataSet: TSgtsCDS;
    FSelectDefs: TSgtsSelectDefs;
    FIsCheckDef: TSgtsSelectDef;
    FParamNameDef: TSgtsSelectDef;
    FInstrumentNameDef: TSgtsSelectDef;
    FMeasureUnitNameDef: TSgtsSelectDef;
    FDefaultValueDef: TSgtsSelectDef;
    FDataSetInstruments: TSgtsDatabaseCDS;
    FDataSetMeasureUnits: TSgtsDatabaseCDS;
    FDateEditBegin: TSgtsDateEdit;
    FDateEditEnd: TSgtsDateEdit;
    function ChangeArePresent: Boolean;
    procedure CheckChanges;
    function GetCycleInfo(CycleId: Variant; var Index: Integer): TSgtsCycleInfo;
    function GetRouteInfo(RouteId: Variant; var Index: Integer): TSgtsRouteInfo;
    function GetObjectInfo(ObjectId: Variant; var Index: Integer): TSgtsObjectInfo;
    function ObjectExists(ObjectId: Variant): Boolean;
    function GetIface: TSgtsFunSourceDataConditionIface;
    procedure GridCellClick(Column: TColumn);
    procedure GridKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure GridColEnter(Sender: TObject);
    procedure FillInstruments(Strings: TStrings);
    procedure FillMeasureUnits(Strings: TStrings);
    procedure InstrumentNameSetText(Sender: TField; const Text: string);
    procedure MeasureUnitNameSetText(Sender: TField; const Text: string);
    procedure DataSetAfterScroll(DataSet: TDataSet);
    procedure DataSetNewRecord(DataSet: TDataSet);
    procedure UncheckWithOutFirst(CheckListBox: TCheckListBox);
    procedure UncheckWithOutCurrent(CheckListBox: TCheckListBox);
    procedure CheckAllParams(FlagCheck: Boolean);
    procedure CheckAllRoutes(FlagCheck: Boolean);
    function GetFirstCheckedCycle: TSgtsCycleInfo;
    function GetLastCheckedCycle: TSgtsCycleInfo;
    procedure SetDateByCycle;
    procedure DateEditOnChange(Sender: TObject);
    procedure EnableDateAdjustment(AEnabled: Boolean);
    procedure ParamDefaultValueFieldSetText(Sender: TField; const Text: string);
  protected
    property DataSet: TSgtsCDS read FDataSet;
    property DateEditBegin: TSgtsDateEdit read FDateEditBegin;
    property DateEditEnd: TSgtsDateEdit read FDateEditEnd;
  public
    constructor Create(ACoreIntf: ISgtsCore); override;
    destructor Destroy; override;
    procedure DisableEvents;
    procedure EnableEvents;
    procedure FillCycles(CheckFirstNotClosed: Boolean);
    procedure SetFirstMeasureType(AMeasureTypeId: Variant);
    procedure FillRoutes(CheckAll: Boolean);
    procedure FillObjects;
    procedure FillParams;
    procedure FillPresents;

    property Iface: TSgtsFunSourceDataConditionIface read GetIface;
  end;

  TSgtsFunSourceDataConditionIface=class(TSgtsDialogIface)
  private
    FCycleNum: String;
    FMeasureTypePath: String;
    FMeasureTypeIsVisual: Boolean;
    FMeasureTypeId: Variant;
    FRouteName: String;
    FObjectPaths: String;
    FFilterGroups: TSgtsGetRecordsConfigFilterGroups;
    FPresentation: Integer;
    FJournalNum: String;
    FRestrictIsBase: Boolean;
    function GetForm: TSgtsFunSourceDataConditionForm;
  protected
    procedure AfterCreateForm(AForm: TSgtsForm); override;
  public
    constructor Create(ACoreIntf: ISgtsCore); override;
    destructor Destroy; override;
    procedure Init; override;
    procedure BeforeShowModal; override;
    procedure AfterShowModal(ModalResult: TModalResult); override;

    property Form: TSgtsFunSourceDataConditionForm read GetForm;
    property FilterGroups: TSgtsGetRecordsConfigFilterGroups read FFilterGroups;
    property CycleNum: String read FCycleNum write FCycleNum;
    property MeasureTypePath: String read FMeasureTypePath write FMeasureTypePath;
    property MeasureTypeIsVisual: Boolean read FMeasureTypeIsVisual write FMeasureTypeIsVisual;
    property MeasureTypeId: Variant read FMeasureTypeId write FMeasureTypeId;
    property RouteName: String read FRouteName write FRouteName;
    property ObjectPaths: String read FObjectPaths write FObjectPaths;
    property Presentation: Integer read FPresentation write FPresentation;
    property JournalNum: String read FJournalNum write FJournalNum;
    property RestrictIsBase: Boolean read FRestrictIsBase write FRestrictIsBase;
  end;

var
  SgtsFunSourceDataConditionForm: TSgtsFunSourceDataConditionForm;

implementation

uses SgtsUtils, DateUtils, Contnrs,
     SgtsRbkCyclesFm, SgtsProviderConsts,
     SgtsRbkMeasureTypesFm, SgtsConsts, SgtsDialogs,
     SgtsRbkObjectTreesFm, SgtsPeriodFm, SgtsRbkParamEditFm;

{$R *.dfm}

{ TSgtsFunSourceDataConditionIface }

constructor TSgtsFunSourceDataConditionIface.Create(ACoreIntf: ISgtsCore);
begin
  inherited Create(ACoreIntf);
  StoredInConfig:=true;
  FFilterGroups:=TSgtsGetRecordsConfigFilterGroups.Create;
  FMeasureTypeId:=Null;
end;

destructor TSgtsFunSourceDataConditionIface.Destroy;
begin
  FFilterGroups.Free;
  inherited Destroy;
end;

procedure TSgtsFunSourceDataConditionIface.Init;
begin
  inherited Init;
  FormClass:=TSgtsFunSourceDataConditionForm;
end;

function TSgtsFunSourceDataConditionIface.GetForm: TSgtsFunSourceDataConditionForm;
begin
  Result:=TSgtsFunSourceDataConditionForm(inherited Form);
end;

procedure TSgtsFunSourceDataConditionIface.AfterCreateForm(AForm: TSgtsForm);
begin
  inherited AfterCreateForm(AForm);
end;

procedure TSgtsFunSourceDataConditionIface.BeforeShowModal;
var
  i: Integer;
  Index: Integer;
  Flag: Boolean;
  AFilterGroup: TSgtsGetRecordsConfigFilterGroup;
  AFilter: TSgtsGetRecordsConfigFilter;
begin
  inherited BeforeShowModal;
  if Assigned(Form) and (FFilterGroups.Count>0) then begin
    AFilterGroup:=FFilterGroups.Items[0];
    with Form do begin
      DisableEvents;
      try

        for i:=0 to AFilterGroup.Filters.Count-1 do begin
          AFilter:=AFilterGroup.Filters.Items[i];
          if AnsiSameText(AFilter.FieldName,'VIEW_EDIT') then begin
            RadioButtonViewEdit.Checked:=Boolean(AFilter.Value);
            RadioButtonViewOnly.Checked:=not RadioButtonViewEdit.Checked;
            break;
          end;
        end;

        for i:=0 to AFilterGroup.Filters.Count-1 do begin
          AFilter:=AFilterGroup.Filters.Items[i];
          if AnsiSameText(AFilter.FieldName,'CHECK_DATE_END') then begin
            CheckBoxDateEnd.Checked:=Boolean(AFilter.Value);
            CheckBoxDateEndClick(CheckBoxDateEnd);
            break;
          end;
        end;

        for i:=0 to AFilterGroup.Filters.Count-1 do begin
          AFilter:=AFilterGroup.Filters.Items[i];
          if AnsiSameText(AFilter.FieldName,'MEASURE_TYPE_ID') then begin
            SetFirstMeasureType(AFilter.Value);
            break;
          end;
        end;

        FillCycles(false);

        Flag:=false;
        for i:=0 to AFilterGroup.Filters.Count-1 do begin
          AFilter:=AFilterGroup.Filters.Items[i];
          if AnsiSameText(AFilter.FieldName,'CYCLE_ID') then begin
            if Assigned(GetCycleInfo(AFilter.Value,Index)) then begin
              CheckListBoxCycles.Checked[Index]:=true;
              if not Flag then
                CheckListBoxCycles.Selected[Index]:=true;
              Flag:=true;
            end;
          end;
        end;

        for i:=0 to AFilterGroup.Filters.Count-1 do begin
          AFilter:=AFilterGroup.Filters.Items[i];
          if AnsiSameText(AFilter.FieldName,'DATE_BEGIN') then begin
            DateEditBegin.Date:=AFilter.Value;
          end;
          if AnsiSameText(AFilter.FieldName,'DATE_END') then begin
            if CheckBoxDateEnd.Checked then
              DateEditEnd.Date:=AFilter.Value;
          end;
          if AnsiSameText(AFilter.FieldName,'DATE_END2') then begin
            if not CheckBoxDateEnd.Checked then
              DateEditEnd.Date:=AFilter.Value;
          end;
        end;

        FillRoutes(false);

        for i:=0 to AFilterGroup.Filters.Count-1 do begin
          AFilter:=AFilterGroup.Filters.Items[i];
          if AnsiSameText(AFilter.FieldName,'ROUTE_ID') then begin
            if Assigned(GetRouteInfo(AFilter.Value,Index)) then
              CheckListBoxRoutes.Checked[Index]:=true;
          end;
        end;

        FillObjects;

        for i:=0 to AFilterGroup.Filters.Count-1 do begin
          AFilter:=AFilterGroup.Filters.Items[i];
          if AnsiSameText(AFilter.FieldName,'OBJECT_ID') then begin
            if Assigned(GetObjectInfo(AFilter.Value,Index)) then begin
              ComboBoxObjects.ItemIndex:=Index;
              break;
            end;  
          end;
        end;

        FillParams;

        DataSet.BeginUpdate;
        try
          for i:=0 to AFilterGroup.Filters.Count-1 do begin
            AFilter:=AFilterGroup.Filters.Items[i];
            if AnsiSameText(AFilter.FieldName,'PARAM_ID') then begin
              Flag:=false;
              if DataSet.Locate('PARAM_ID',AFilter.Value,[loCaseInsensitive]) then begin
                Flag:=true;
                DataSet.Edit;
                DataSet.FieldByName('IS_CHECK').AsInteger:=1;
                DataSet.Post;
              end;
            end else begin
              if Flag and
                 (AnsiSameText(AFilter.FieldName,'INSTRUMENT_ID') or
                  AnsiSameText(AFilter.FieldName,'INSTRUMENT_NAME') or
                  AnsiSameText(AFilter.FieldName,'MEASURE_UNIT_ID') or
                  AnsiSameText(AFilter.FieldName,'MEASURE_UNIT_NAME') or
                  AnsiSameText(AFilter.FieldName,'DEFAULT_VALUE')) then begin

                DataSet.Edit;
                DataSet.FieldByName(AFilter.FieldName).Value:=AFilter.Value;
                DataSet.Post;
              end;
            end;
          end;
        finally
          DataSet.EndUpdate;
        end;

        FillPresents;
        ComboBoxPresent.ItemIndex:=FPresentation;

        EditJournalNum.Text:=FJournalNum;
        CheckBoxRestrictIsBase.Checked:=FRestrictIsBase;

        FGrid.Enabled:=not FMeasureTypeIsVisual;
        FGrid.Color:=iff(FGrid.Enabled,clWindow,clBtnFace);
        ComboBoxPresent.Color:=iff(ComboBoxPresent.Enabled,clWindow,clBtnFace);
        CheckBoxRestrictIsBase.Visible:=not FMeasureTypeIsVisual;

        CheckChanges;

      finally
        EnableEvents;
      end;
    end;
  end;
end;

procedure TSgtsFunSourceDataConditionIface.AfterShowModal(ModalResult: TModalResult);
var
  i: Integer;
  CycleI: TSgtsCycleInfo;
  RouteI: TSgtsRouteInfo;
  ObjectI: TSgtsObjectInfo;
  FlagFirst: Boolean;
  AFilterGroup: TSgtsGetRecordsConfigFilterGroup;
begin
  inherited AfterShowModal(ModalResult);
  if ModalResult=mrOk then begin
    FFilterGroups.Clear;
    AFilterGroup:=FFilterGroups.Add;

    with Form do begin

      AFilterGroup.Filters.Add('VIEW_EDIT',fcEqual,Integer(RadioButtonViewEdit.Checked));
      AFilterGroup.Filters.Add('CHECK_DATE_END',fcEqual,Integer(CheckBoxDateEnd.Checked));

      FlagFirst:=false;
      FCycleNum:='';
      for i:=0 to CheckListBoxCycles.Items.Count-1 do begin
        if CheckListBoxCycles.Checked[i] then begin
          CycleI:=TSgtsCycleInfo(CheckListBoxCycles.Items.Objects[i]);
          AFilterGroup.Filters.Add('CYCLE_ID',fcEqual,CycleI.CycleId);
          if not FlagFirst then begin
            FCycleNum:=CheckListBoxCycles.Items.Strings[i];
            FlagFirst:=true;
          end;
        end;
      end;

      if ButtonDate.Enabled then begin
        AFilterGroup.Filters.Add('DATE_BEGIN',fcEqual,DateEditBegin.Date2);
        if CheckBoxDateEnd.Checked then begin
          AFilterGroup.Filters.Add('DATE_END',fcEqual,DateEditEnd.Date2);
        end else begin
          AFilterGroup.Filters.Add('DATE_END',fcEqual,DateEditBegin.Date2);
          AFilterGroup.Filters.Add('DATE_END2',fcEqual,DateEditEnd.Date2);
        end;
      end;  

      FMeasureTypePath:='';
      if not VarIsNull(FMeasureTypeId) then begin
        AFilterGroup.Filters.Add('MEASURE_TYPE_ID',fcEqual,FMeasureTypeId);
        FMeasureTypePath:=EditMeasureType.Text;
      end;

      FlagFirst:=false;
      FRouteName:='';
      for i:=0 to CheckListBoxRoutes.Items.Count-1 do begin
        if CheckListBoxRoutes.Checked[i] then begin
          RouteI:=TSgtsRouteInfo(CheckListBoxRoutes.Items.Objects[i]);
          AFilterGroup.Filters.Add('ROUTE_ID',fcEqual,RouteI.RouteId);
          if not FlagFirst then begin
            FRouteName:=CheckListBoxRoutes.Items.Strings[i];
            FlagFirst:=true;
          end;
        end;
      end;

      FObjectPaths:='';
      if ComboBoxObjects.ItemIndex>0 then begin
        ObjectI:=TSgtsObjectInfo(ComboBoxObjects.Items.Objects[ComboBoxObjects.ItemIndex]);
        AFilterGroup.Filters.Add('OBJECT_ID',fcEqual,ObjectI.ObjectId);
        FObjectPaths:=ComboBoxObjects.Items.Strings[ComboBoxObjects.ItemIndex];
      end;

      DataSet.BeginUpdate;
      try
        DataSet.First;
        while not DataSet.Eof do begin
          if Boolean(DataSet.FieldByName('IS_CHECK').AsInteger) then begin
            AFilterGroup.Filters.Add('PARAM_ID',fcEqual,DataSet.FieldByName('PARAM_ID').Value);
            AFilterGroup.Filters.Add('INSTRUMENT_ID',fcEqual,DataSet.FieldByName('INSTRUMENT_ID').Value);
            AFilterGroup.Filters.Add('INSTRUMENT_NAME',fcEqual,DataSet.FieldByName('INSTRUMENT_NAME').Value);
            AFilterGroup.Filters.Add('MEASURE_UNIT_ID',fcEqual,DataSet.FieldByName('MEASURE_UNIT_ID').Value);
            AFilterGroup.Filters.Add('MEASURE_UNIT_NAME',fcEqual,DataSet.FieldByName('MEASURE_UNIT_NAME').Value);
            AFilterGroup.Filters.Add('DEFAULT_VALUE',fcEqual,DataSet.FieldByName('DEFAULT_VALUE').Value);
          end;
          DataSet.Next;
        end;
      finally
        DataSet.EndUpdate;
      end;

      FPresentation:=ComboBoxPresent.ItemIndex;
      
      FJournalNum:=EditJournalNum.Text;
      FRestrictIsBase:=CheckBoxRestrictIsBase.Checked;

    end;
  end;
end;

{ TSgtsFunSourceDataConditionForm }

constructor TSgtsFunSourceDataConditionForm.Create(ACoreIntf: ISgtsCore);
begin
  inherited Create(ACoreIntf);

  FGrid:=TSgtsDbGrid.Create(Self);
  with FGrid do begin
    Parent:=GridPattern.Parent;
    Align:=GridPattern.Align;
    Font.Assign(GridPattern.Font);
    LocateEnabled:=false;
    ColumnSortEnabled:=false;
    Options:=Options-[dgEditing,dgTabs];
    ColMoving:=false;
    AutoFit:=true;
    VisibleRowNumber:=true;
    DataSource:=GridPattern.DataSource;
    ReadOnly:=true;
    PopupMenu:=GridPattern.PopupMenu;
    OnCellClick:=GridCellClick;
    OnKeyDown:=GridKeyDown;
    OnColEnter:=GridColEnter;
  end;

  GridPattern.Free;
  GridPattern:=nil;

  FDataSetInstruments:=TSgtsDatabaseCDS.Create(ACoreIntf);
  with FDataSetInstruments do begin
    ProviderName:=SProviderSelectParamInstruments;
    with SelectDefs do begin
      AddInvisible('INSTRUMENT_ID');
      AddInvisible('INSTRUMENT_NAME');
    end;
    Orders.Add('PRIORITY',otAsc);
  end;

  FDataSetMeasureUnits:=TSgtsDatabaseCDS.Create(ACoreIntf);
  with FDataSetMeasureUnits do begin
    ProviderName:=SProviderSelectInstrumentUnits;
    with SelectDefs do begin
      AddInvisible('MEASURE_UNIT_ID');
      AddInvisible('MEASURE_UNIT_NAME');
    end;
    Orders.Add('PRIORITY',otAsc);
  end;

  FDataSet:=TSgtsCDS.Create(nil);
  FDataSet.AfterScroll:=DataSetAfterScroll;
  FDataSet.OnNewRecord:=DataSetNewRecord;
  with FDataSet.FieldDefs do begin
    Add('IS_CHECK',ftInteger);
    Add('PARAM_ID',ftInteger);
    Add('PARAM_NAME',ftString,100);
    Add('INSTRUMENT_ID',ftInteger);
    Add('INSTRUMENT_NAME',ftString,100);
    Add('MEASURE_UNIT_ID',ftInteger);
    Add('MEASURE_UNIT_NAME',ftString,100);
    Add('DEFAULT_VALUE',ftFloat);
  end;
  FDataSet.CreateDataSet;

  FDataSet.FindField('INSTRUMENT_NAME').OnSetText:=InstrumentNameSetText;
  FDataSet.FindField('MEASURE_UNIT_NAME').OnSetText:=MeasureUnitNameSetText;

  with FDataSet.FindField('DEFAULT_VALUE') do begin
    if DecimalSeparator<>'.' then
       ValidChars:=ValidChars+['.']
    else ValidChars:=ValidChars+[','];
    OnSetText:=ParamDefaultValueFieldSetText;
  end;

  DataSource.DataSet:=FDataSet;

  FSelectDefs:=TSgtsSelectDefs.Create;
  FIsCheckDef:=FSelectDefs.AddDrawCheck('IS_CHECK_EX','�������','IS_CHECK',30,true);
  FSelectDefs.Find('IS_CHECK').Field:=FDataSet.FieldByName('IS_CHECK');
  FParamNameDef:=FSelectDefs.Add('PARAM_NAME','��������',150);
  FInstrumentNameDef:=FSelectDefs.Add('INSTRUMENT_NAME','������',130);
  FMeasureUnitNameDef:=FSelectDefs.Add('MEASURE_UNIT_NAME','������� ���������',50);
  FDefaultValueDef:=FSelectDefs.Add('DEFAULT_VALUE','�������� �� ���������',50);

  CreateGridColumnsBySelectDefs(FGrid,FSelectDefs);

  FDateEditBegin:=TSgtsDateEdit.Create(Self);
  FDateEditBegin.Parent:=DateTimePickerBegin.Parent;
  FDateEditBegin.SetBounds(DateTimePickerBegin.Left,DateTimePickerBegin.Top,DateTimePickerBegin.Width,DateTimePickerBegin.Height);
  FDateEditBegin.TabOrder:=DateTimePickerBegin.TabOrder;
  FDateEditBegin.OnChange:=DateEditOnChange;
  FDateEditBegin.Enabled:=DateTimePickerBegin.Enabled;
  FDateEditBegin.Color:=DateTimePickerBegin.Color;
  LabelDateBegin.FocusControl:=FDateEditBegin;
  DateTimePickerBegin.Free;

  FDateEditEnd:=TSgtsDateEdit.Create(Self);
  FDateEditEnd.Parent:=DateTimePickerEnd.Parent;
  FDateEditEnd.SetBounds(DateTimePickerEnd.Left,DateTimePickerEnd.Top,DateTimePickerEnd.Width,DateTimePickerEnd.Height);
  FDateEditEnd.TabOrder:=DateTimePickerEnd.TabOrder;
  FDateEditEnd.OnChange:=DateEditOnChange;
  FDateEditEnd.Enabled:=DateTimePickerEnd.Enabled;
  FDateEditEnd.Color:=DateTimePickerEnd.Color;
  DateTimePickerEnd.Free;
end;

destructor TSgtsFunSourceDataConditionForm.Destroy;
begin
  FDateEditEnd.Free;
  FDateEditBegin.Free;
  FSelectDefs.Free;
  FDataSet.Free;
  FDataSetMeasureUnits.Free;
  FDataSetInstruments.Free;
  inherited Destroy;
end;

function TSgtsFunSourceDataConditionForm.GetIface: TSgtsFunSourceDataConditionIface;
begin
  Result:=TSgtsFunSourceDataConditionIface(inherited Iface);
end;

procedure TSgtsFunSourceDataConditionForm.DisableEvents;
begin
  CheckListBoxCycles.OnClickCheck:=nil;
  EditMeasureType.OnChange:=nil;
  CheckListBoxRoutes.OnClickCheck:=nil;
  ComboBoxObjects.OnChange:=nil;
end;

procedure TSgtsFunSourceDataConditionForm.EnableEvents;
begin
  CheckListBoxCycles.OnClickCheck:=CheckListBoxCyclesClickCheck;
  EditMeasureType.OnChange:=EditMeasureTypeChange;
  CheckListBoxRoutes.OnClickCheck:=CheckListBoxRoutesClickCheck;
  ComboBoxObjects.OnChange:=ComboBoxObjectsChange;
end;

function TSgtsFunSourceDataConditionForm.GetFirstCheckedCycle: TSgtsCycleInfo;
var
  i: Integer;
begin
  Result:=nil;
  for i:=0 to CheckListBoxCycles.Items.Count-1 do begin
    if CheckListBoxCycles.Checked[i] then begin
      Result:=TSgtsCycleInfo(CheckListBoxCycles.Items.Objects[i]);
      exit;
    end;
  end;
end;

function TSgtsFunSourceDataConditionForm.GetLastCheckedCycle: TSgtsCycleInfo;
var
  i: Integer;
begin
  Result:=nil;
  for i:=CheckListBoxCycles.Items.Count-1 downto 0 do begin
    if CheckListBoxCycles.Checked[i] then begin
      Result:=TSgtsCycleInfo(CheckListBoxCycles.Items.Objects[i]);
      exit;
    end;
  end;
end;

procedure TSgtsFunSourceDataConditionForm.FillCycles(CheckFirstNotClosed: Boolean);
var
  DS: TSgtsDatabaseCDS;
  FilterGroup: TSgtsGetRecordsConfigFilterGroup;
  Obj: TSgtsCycleInfo;
  S: String;
  Index: Integer;
  Flag: Boolean;
  IsEdit: Boolean;
  OldObj: TSgtsCycleInfo;
  NewIndex: Integer;
  OldCycleId: Variant;
begin
  IsEdit:=RadioButtonViewEdit.Checked;
  OldObj:=GetFirstCheckedCycle;
  if Assigned(OldObj) then
    OldCycleId:=OldObj.CycleId;
  ClearStrings(CheckListBoxCycles.Items);
  DS:=TSgtsDatabaseCDS.Create(CoreIntf);
  try
    DS.ProviderName:=SProviderSelectCycles;
    with DS.SelectDefs do begin
      AddInvisible('CYCLE_ID');
      AddInvisible('CYCLE_NUM');
      AddInvisible('CYCLE_MONTH');
      AddInvisible('CYCLE_YEAR');
      AddInvisible('IS_CLOSE');
    end;
    if IsEdit then begin
      FilterGroup:=DS.FilterGroups.Add;
      FilterGroup.Filters.Add('IS_CLOSE',fcEqual,0);
    end;
    DS.Orders.Add('CYCLE_YEAR',otAsc);
    DS.Orders.Add('CYCLE_MONTH',otAsc);
    DS.Open;
    if DS.Active and not DS.IsEmpty then begin
      CheckListBoxCycles.Items.BeginUpdate;
      try
        Flag:=false;
        NewIndex:=-1;
        DS.First;
        while not DS.Eof do begin
          Obj:=TSgtsCycleInfo.Create;
          Obj.CycleId:=DS.Fields[0].Value;
          Obj.CycleNum:=DS.Fields[1].AsInteger;
          Obj.CycleMonth:=DS.Fields[2].AsInteger;
          Obj.CycleYear:=DS.Fields[3].AsInteger;
          Obj.CycleIsClose:=Boolean(DS.Fields[4].AsInteger);
          S:=Format(SCycleFormat,[Obj.CycleNum,GetMonthNameByIndex(Obj.CycleMonth),Obj.CycleYear]);
          Index:=CheckListBoxCycles.Items.AddObject(S,Obj);
          if CheckFirstNotClosed and not Obj.CycleIsClose and not Flag then begin
            CheckListBoxCycles.Checked[Index]:=true;
            CheckListBoxCycles.Selected[Index]:=true;
            SetDateByCycle;
            Flag:=true;
          end else
            if Assigned(OldObj) and (OldCycleId=Obj.CycleId) then
              NewIndex:=Index;
          DS.Next;
        end;
        if not Flag and (NewIndex<>-1) then begin
          CheckListBoxCycles.Checked[NewIndex]:=true;
          CheckListBoxCycles.Selected[NewIndex]:=true;
          SetDateByCycle;
        end;
      finally
        CheckListBoxCycles.Items.EndUpdate;
      end;
    end;
  finally
    DS.Free;
  end;
end;

procedure TSgtsFunSourceDataConditionForm.SetFirstMeasureType(AMeasureTypeId: Variant);
var
  DS: TSgtsDatabaseCDS;
  FilterGroup: TSgtsGetRecordsConfigFilterGroup;
begin
  if not VarIsNull(AMeasureTypeId) then begin
    DS:=TSgtsDatabaseCDS.Create(CoreIntf);
    try
      DS.ProviderName:=SProviderSelectMeasureTypes;
      with DS.SelectDefs do begin
        AddInvisible('MEASURE_TYPE_ID');
        AddInvisible('PATH');
        AddInvisible('IS_VISUAL');
      end;
      FilterGroup:=DS.FilterGroups.Add;
      FilterGroup.Filters.Add('MEASURE_TYPE_ID',fcEqual,AMeasureTypeId);
      DS.Open;
      if DS.Active and not DS.IsEmpty then begin
        Iface.MeasureTypeId:=DS.Fields[0].Value;
        EditMeasureType.Text:=DS.Fields[1].AsString;
        Iface.MeasureTypeIsVisual:=Boolean(DS.Fields[2].AsInteger);
      end else begin
        Iface.MeasureTypeId:=Null;
        Iface.MeasureTypeIsVisual:=false;
        EditMeasureType.Text:='';
      end;
    finally
      DS.Free;
    end;
  end else begin
    Iface.MeasureTypeId:=Null;
    EditMeasureType.Text:='';
  end;
end;

procedure TSgtsFunSourceDataConditionForm.FillRoutes(CheckAll: Boolean);
var
  DS: TSgtsDatabaseCDS;
  FilterGroup: TSgtsGetRecordsConfigFilterGroup;
  Obj: TSgtsRouteInfo;
  Index: Integer;
  S: String;
begin
  ClearStrings(CheckListBoxRoutes.Items);
  if not VarIsNull(Iface.MeasureTypeId) then begin
    DS:=TSgtsDatabaseCDS.Create(CoreIntf);
    try
      DS.ProviderName:=SProviderSelectMeasureTypePersonnels;
      DS.SelectDefs.AddInvisible('ROUTE_ID');
      DS.SelectDefs.AddInvisible('ROUTE_NAME');
      FilterGroup:=DS.FilterGroups.Add;
      FilterGroup.Filters.Add('MEASURE_TYPE_ID',fcEqual,Iface.MeasureTypeId);
      FilterGroup:=DS.FilterGroups.Add;
      FilterGroup.Filters.Add('PERSONNEL_ID',fcEqual,CoreIntf.DatabaseModules.Current.Database.PersonnelId);
      FilterGroup.Filters.Add('DEPUTY_ID',fcEqual,CoreIntf.DatabaseModules.Current.Database.PersonnelId).Operator:=foOr;
      DS.Open;
      if DS.Active and not DS.IsEmpty then begin
        CheckListBoxRoutes.Items.BeginUpdate;
        try
          DS.First;
          while not DS.Eof do begin
            Obj:=TSgtsRouteInfo.Create;
            Obj.RouteId:=DS.Fields[0].Value;
            Obj.RouteName:=DS.Fields[1].AsString;
            S:=Obj.RouteName;
            Index:=CheckListBoxRoutes.Items.AddObject(S,Obj);
            if CheckAll then
              CheckListBoxRoutes.Checked[Index]:=true;
            DS.Next;
          end;
        finally
          CheckListBoxRoutes.Items.EndUpdate;
        end;
      end;
    finally
      DS.Free;
    end;
  end;
end;

function TSgtsFunSourceDataConditionForm.GetCycleInfo(CycleId: Variant; var Index: Integer): TSgtsCycleInfo;
var
  i: Integer;
  Obj: TSgtsCycleInfo;
begin
  Result:=nil;
  Index:=-1;
  for i:=0 to CheckListBoxCycles.Items.Count-1 do begin
    Obj:=TSgtsCycleInfo(CheckListBoxCycles.Items.Objects[i]);
    if Obj.CycleId=CycleId then begin
      Result:=Obj;
      Index:=i;
      exit;
    end;
  end;
end;

function TSgtsFunSourceDataConditionForm.GetRouteInfo(RouteId: Variant; var Index: Integer): TSgtsRouteInfo;
var
  i: Integer;
  Obj: TSgtsRouteInfo;
begin
  Result:=nil;
  Index:=-1;
  for i:=0 to CheckListBoxRoutes.Items.Count-1 do begin
    Obj:=TSgtsRouteInfo(CheckListBoxRoutes.Items.Objects[i]);
    if Obj.RouteId=RouteId then begin
      Result:=Obj;
      Index:=i;
      exit;
    end;
  end;
end;

function TSgtsFunSourceDataConditionForm.GetObjectInfo(ObjectId: Variant; var Index: Integer): TSgtsObjectInfo;
var
  i: Integer;
  Obj: TSgtsObjectInfo;
begin
  Result:=nil;
  Index:=-1;
  for i:=0 to ComboBoxObjects.Items.Count-1 do begin
    Obj:=TSgtsObjectInfo(ComboBoxObjects.Items.Objects[i]);
    if Assigned(Obj) then
      if Obj.ObjectId=ObjectId then begin
        Result:=Obj;
        Index:=i;
        exit;
      end;
  end;
end;

function TSgtsFunSourceDataConditionForm.ObjectExists(ObjectId: Variant): Boolean;
var
  Index: Integer;
begin
  Result:=Assigned(GetObjectInfo(ObjectId,Index));
end;

procedure TSgtsFunSourceDataConditionForm.FillObjects;
var
  i: Integer;
  Route: TSgtsRouteInfo;
  Obj: TSgtsObjectInfo;
  DS: TSgtsDatabaseCDS;
  Group: TSgtsGetRecordsConfigFilterGroup;
begin
  ClearStrings(ComboBoxObjects.Items);
  DS:=TSgtsDatabaseCDS.Create(CoreIntf);
  try
    DS.ProviderName:=SProviderSelectRouteObjects;
    with DS.SelectDefs do begin
      AddInvisible('OBJECT_ID');
      AddInvisible('OBJECT_NAME');
      AddInvisible('OBJECT_PATHS');
    end;
    Group:=DS.FilterGroups.Add;
    for i:=0 to CheckListBoxRoutes.Items.Count-1 do begin
      if CheckListBoxRoutes.Checked[i] then begin
        Route:=TSgtsRouteInfo(CheckListBoxRoutes.Items.Objects[i]);
        Group.Filters.Add('ROUTE_ID',fcEqual,Route.RouteId).Operator:=foOr;
      end;
    end;
    if Group.Filters.Count>0 then
      DS.Open;
    if DS.Active and not DS.IsEmpty then begin
      ComboBoxObjects.Items.BeginUpdate;
      try
        ComboBoxObjects.Items.Add(' ');
        DS.First;
        while not DS.Eof do begin
          if not ObjectExists(DS.Fields[0].Value) then begin
            Obj:=TSgtsObjectInfo.Create;
            Obj.ObjectId:=DS.Fields[0].Value;
            Obj.ObjectName:=DS.Fields[1].AsString;
            Obj.ObjectPaths:=DS.Fields[2].AsString;
            ComboBoxObjects.Items.AddObject(Obj.ObjectPaths,Obj);
          end;
          DS.Next;
        end;
      finally
        ComboBoxObjects.Items.EndUpdate;
      end;  
    end;
  finally
    DS.Free;
  end;
end;

procedure TSgtsFunSourceDataConditionForm.ButtonMeasureTypeClick(
  Sender: TObject);
var
  Iface: TSgtsRbkMeasureTypesIface;
  DS: TSgtsCDS;
  Buffer: String;
begin
  Iface:=TSgtsRbkMeasureTypesIface.Create(CoreIntf);
  try
    if Iface.SelectOnlyLastNode('MEASURE_TYPE_ID',Self.Iface.MeasureTypeId,Buffer) then begin
      DS:=TSgtsCDS.Create(nil);
      try
        DS.XMLData:=Buffer;
        if DS.Active and not DS.IsEmpty then begin
          Self.Iface.MeasureTypeId:=DS.FieldByName('MEASURE_TYPE_ID').Value;
          Self.Iface.MeasureTypeIsVisual:=Boolean(DS.FieldByName('IS_VISUAL').AsInteger);
          EditMeasureType.Text:=DS.FieldByName('PATH').AsString;

          Screen.Cursor:=crHourGlass;
          DisableEvents;
          try
            FillCycles(RadioButtonViewEdit.Checked);
            FillRoutes(true);
            FillObjects;
            FillParams;
            FillPresents;
            EditJournalNum.Text:='';

            FGrid.Enabled:=not Self.Iface.MeasureTypeIsVisual;
            FGrid.Color:=iff(FGrid.Enabled,clWindow,clBtnFace);
            ComboBoxPresent.Color:=iff(ComboBoxPresent.Enabled,clWindow,clBtnFace);
            CheckBoxRestrictIsBase.Visible:=not Self.Iface.MeasureTypeIsVisual;

            CheckChanges;
          finally
            EnableEvents;
            Screen.Cursor:=crDefault;
          end;
        end;
      finally
        DS.Free;
      end;
    end;
  finally
    Iface.Free;
  end;
end;

procedure TSgtsFunSourceDataConditionForm.ButtonObjectClick(
  Sender: TObject);
var
  Iface: TSgtsRbkObjectTreesIface;
  DS: TSgtsCDS;
  Buffer: String;
  AObjectId: Variant;
  Index: Integer;
begin
  Iface:=TSgtsRbkObjectTreesIface.Create(CoreIntf);
  try
    if ComboBoxObjects.ItemIndex>0 then begin
      AObjectId:=TSgtsObjectInfo(ComboBoxObjects.Items.Objects[ComboBoxObjects.ItemIndex]).ObjectId;
    end;
    if Iface.SelectVisible('OBJECT_ID',AObjectId,Buffer) then begin
      DS:=TSgtsCDS.Create(nil);
      try
        DS.XMLData:=Buffer;
        if DS.Active and not DS.IsEmpty then begin
          AObjectId:=DS.FieldByName('OBJECT_ID').Value;
          GetObjectInfo(AObjectId,Index);
          ComboBoxObjects.ItemIndex:=Index;
        end;
      finally
        DS.Free;
      end;
    end;
  finally
    Iface.Free;
  end;
end;

function TSgtsFunSourceDataConditionForm.ChangeArePresent: Boolean;
var
  i: Integer;
  MeasureTypeSelect: Boolean;
  CycleSelect: Boolean;
  DateSelect: Boolean;
  RouteSelect: Boolean;
  ParamSelect: Boolean;
  DS: TSgtsCDS;
const
  NullDate: TDate=0.0;  
begin

  MeasureTypeSelect:=false;
  if not VarIsNull(Iface.MeasureTypeId) then begin
    MeasureTypeSelect:=true;
  end;

  CycleSelect:=false;
  for i:=0 to CheckListBoxCycles.Items.Count-1 do begin
    if CheckListBoxCycles.Checked[i] then begin
      CycleSelect:=true;
      break;
    end;
  end;

  DateSelect:=true;
  if ButtonDate.Enabled then
    DateSelect:=(FDateEditBegin.Date<>NullDate) and
                (FDateEditEnd.Date<>NullDate); 

  RouteSelect:=false;
  for i:=0 to CheckListBoxRoutes.Items.Count-1 do begin
    if CheckListBoxRoutes.Checked[i] then begin
      RouteSelect:=true;
      break;
    end;
  end;

  if not Iface.MeasureTypeIsVisual then begin
    ParamSelect:=false;
    DS:=TSgtsCDS.Create(nil);
    try
      DS.Data:=FDataSet.Data;
      DS.First;
      while not DS.Eof do begin
        if Boolean(DS.FieldByName('IS_CHECK').AsInteger) then begin
          if not VarIsNull(DS.FieldByName('PARAM_ID').Value) then begin
            ParamSelect:=true;
            break;
          end;
        end;
        DS.Next;
      end;
    finally
      DS.Free;
    end;
  end else begin
    ParamSelect:=true;
  end;  

  Result:=MeasureTypeSelect and CycleSelect and DateSelect and RouteSelect and ParamSelect;
end;


procedure TSgtsFunSourceDataConditionForm.CheckChanges;
begin
  ButtonOk.Enabled:=ChangeArePresent;
  ButtonObject.Enabled:=ComboBoxObjects.Items.Count>0;
end;

procedure TSgtsFunSourceDataConditionForm.UncheckWithOutCurrent(CheckListBox: TCheckListBox);
var
  i: Integer;
  Index: Integer;
begin
  DisableEvents;
  try
    Index:=CheckListBox.ItemIndex;
    for i:=0 to CheckListBox.Items.Count-1 do begin
      if Index<>i then
        CheckListBox.Checked[i]:=false;
    end;
  finally
    EnableEvents;
  end;
end;

procedure TSgtsFunSourceDataConditionForm.CheckListBoxCyclesClickCheck(
  Sender: TObject);
begin
  if RadioButtonViewEdit.Checked then
    UncheckWithOutCurrent(CheckListBoxCycles);

  SetDateByCycle;
    
  CheckChanges;  
end;

procedure TSgtsFunSourceDataConditionForm.EditMeasureTypeChange(
  Sender: TObject);
begin
  CheckChanges;
end;

procedure TSgtsFunSourceDataConditionForm.CheckListBoxRoutesClickCheck(
  Sender: TObject);
var
  FOldCursor: TCursor;
begin
  FOldCursor:=Screen.Cursor;
  Screen.Cursor:=crHourGlass;
  DisableEvents;
  try
    FillObjects;
    CheckChanges;
  finally
    EnableEvents;
    Screen.Cursor:=FOldCursor;
  end;
end;

procedure TSgtsFunSourceDataConditionForm.ComboBoxObjectsChange(
  Sender: TObject);
begin
  CheckChanges;
end;

procedure TSgtsFunSourceDataConditionForm.GridCellClick(Column: TColumn);
var
  Flag: Boolean;
begin
  if FDataSet.Active and
     not FDataSet.IsEmpty and
     (Column.Index=0) and
     RadioButtonViewOnly.Checked then begin
    Flag:=Boolean(FDataSet.FieldByName('IS_CHECK').AsInteger);
    FDataSet.Edit;
    FDataSet.FieldByName('IS_CHECK').AsInteger:=Integer(not Flag);
    FDataSet.Post;
    CheckChanges;
  end;
end;

procedure TSgtsFunSourceDataConditionForm.GridKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key=VK_SPACE then
    GridCellClick(FGrid.Columns[0]);
end;

procedure TSgtsFunSourceDataConditionForm.FillParams;
var
  DS: TSgtsDatabaseCDS;
  ParamId,OldParamId: Variant;
begin
  FDataSet.EmptyDataSet;
  DataSetAfterScroll(nil);
  if not VarIsNull(Iface.MeasureTypeId) then begin
    DS:=TSgtsDatabaseCDS.Create(CoreIntf);
    FDataSet.AfterScroll:=nil;
    FDataSet.OnNewRecord:=nil;
    try
      DS.ProviderName:=SProviderSelectMeasureTypeUnits;
      with DS.SelectDefs do begin
        AddInvisible('PARAM_ID');
        AddInvisible('PARAM_NAME');
        AddInvisible('INSTRUMENT_ID');
        AddInvisible('INSTRUMENT_NAME');
        AddInvisible('MEASURE_UNIT_ID');
        AddInvisible('MEASURE_UNIT_NAME');
      end;
      DS.FilterGroups.Add.Filters.Add('MEASURE_TYPE_ID',fcEqual,Iface.MeasureTypeId);
      DS.Open;
      if DS.Active and not DS.IsEmpty then begin
        OldParamId:=Null;
        DS.First;
        while not DS.Eof do begin
          ParamId:=DS.FieldByName('PARAM_ID').Value;
          if ParamId<>OldParamId then begin
            FDataSet.Append;
            FDataSet.FieldValuesBySource(DS,false,false);
            FDataSet.FieldByName('IS_CHECK').AsInteger:=iff(RadioButtonViewEdit.Checked,1,0);
            FDataSet.Post;
          end;
          OldParamId:=ParamId;
          DS.Next;
        end;
        FDataSet.First;
        DataSetAfterScroll(nil);
      end;
    finally
      FDataSet.AfterScroll:=DataSetAfterScroll;
      FDataSet.OnNewRecord:=DataSetNewRecord;
      DS.Free;
    end;
  end;
end;

procedure TSgtsFunSourceDataConditionForm.FillInstruments(Strings: TStrings);
var
  Obj: TSgtsInstrumentInfo;
begin
  if Assigned(Strings) and
    FDataSet.Active and
    not FDataSet.IsEmpty then begin

    FDataSetInstruments.Close;
    FDataSetInstruments.FilterGroups.Clear;
    FDataSetInstruments.FilterGroups.Add.Filters.Add('PARAM_ID',fcEqual,FDataSet.FieldByName('PARAM_ID').Value);
    FDataSetInstruments.Open;
    if FDataSetInstruments.Active and not FDataSetInstruments.IsEmpty then begin
      FDataSetInstruments.First;
      while not FDataSetInstruments.Eof do begin
        Obj:=TSgtsInstrumentInfo.Create;
        Obj.InstrumentId:=FDataSetInstruments.FieldByName('INSTRUMENT_ID').Value;
        Obj.InstrumentName:=FDataSetInstruments.FieldByName('INSTRUMENT_NAME').AsString;
        Strings.AddObject(Obj.InstrumentName,Obj);
        FDataSetInstruments.Next;
      end;
    end;
  end;
end;

procedure TSgtsFunSourceDataConditionForm.FillMeasureUnits(Strings: TStrings);
var
  Obj: TSgtsMeasureUnitInfo;
begin
  if Assigned(Strings) and
    FDataSetInstruments.Active and
    not FDataSetInstruments.IsEmpty then begin

    FDataSetMeasureUnits.Close;
    FDataSetMeasureUnits.FilterGroups.Clear;
    FDataSetMeasureUnits.FilterGroups.Add.Filters.Add('INSTRUMENT_ID',fcEqual,FDataSet.FieldByName('INSTRUMENT_ID').Value);
    FDataSetMeasureUnits.Open;
    if FDataSetMeasureUnits.Active and not FDataSetMeasureUnits.IsEmpty then begin
      FDataSetMeasureUnits.First;
      while not FDataSetMeasureUnits.Eof do begin
        Obj:=TSgtsMeasureUnitInfo.Create;
        Obj.MeasureUnitId:=FDataSetMeasureUnits.FieldByName('MEASURE_UNIT_ID').Value;
        Obj.MeasureUnitName:=FDataSetMeasureUnits.FieldByName('MEASURE_UNIT_NAME').AsString;
        Strings.AddObject(Obj.MeasureUnitName,Obj);
        FDataSetMeasureUnits.Next;
      end;
    end;
  end;
end;

procedure TSgtsFunSourceDataConditionForm.GridColEnter(Sender: TObject);
var
  AIndex: Integer;
  ADefIndex: Integer;
begin
  AIndex:=FGrid.SelectedIndex;
  if AIndex=-1 then exit;
  ClearStrings(FGrid.Columns[AIndex].PickList);
  FGrid.Options:=FGrid.Options-[dgEditing];
  FGrid.ReadOnly:=true;
  ADefIndex:=AIndex+1;
  if (ADefIndex in [FInstrumentNameDef.Index,FMeasureUnitNameDef.Index,FDefaultValueDef.Index]) then begin
    if FDataSet.Active and not FDataSet.IsEmpty then begin
      FGrid.Options:=FGrid.Options+[dgEditing];
      FGrid.ReadOnly:=false;
      if (ADefIndex=FInstrumentNameDef.Index) then
        FillInstruments(FGrid.Columns[AIndex].PickList);
      if (ADefIndex=FMeasureUnitNameDef.Index) then begin
        FillInstruments(FGrid.Columns[AIndex-1].PickList);
        FillMeasureUnits(FGrid.Columns[AIndex].PickList);
      end;
    end;
  end;
end;

procedure TSgtsFunSourceDataConditionForm.DataSetAfterScroll(DataSet: TDataSet);
begin
  GridColEnter(nil);
end;

procedure TSgtsFunSourceDataConditionForm.InstrumentNameSetText(Sender: TField; const Text: string);
var
  Index: Integer;
  Obj: TSgtsInstrumentInfo;
  OldIntrumentId,OldInstrumentName: Variant;
  ObjU: TSgtsMeasureUnitInfo;
  Units: TStringList;
begin
  Sender.OnSetText:=nil;
  try
    if FGrid.SelectedIndex=-1 then exit;
    OldIntrumentId:=FDataSet.FieldByName('INSTRUMENT_ID').Value;
    OldInstrumentName:=FDataSet.FieldByName('INSTRUMENT_NAME').Value;
    Index:=FGrid.Columns[FGrid.SelectedIndex].PickList.IndexOf(Text);
    if Index<>-1 then begin
      Obj:=TSgtsInstrumentInfo(FGrid.Columns[FGrid.SelectedIndex].PickList.Objects[Index]);
      FDataSet.FieldByName('INSTRUMENT_ID').Value:=Obj.InstrumentId;
      FDataSet.FieldByName('INSTRUMENT_NAME').Value:=Obj.InstrumentName;
    end else begin
      FDataSet.FieldByName('INSTRUMENT_ID').Value:=OldIntrumentId;
      FDataSet.FieldByName('INSTRUMENT_NAME').Value:=OldInstrumentName;
    end;

    Units:=TStringList.Create;
    try
      FillMeasureUnits(Units);
      if Units.Count>0 then begin
        ObjU:=TSgtsMeasureUnitInfo(Units.Objects[0]);
        FDataSet.FieldByName('MEASURE_UNIT_ID').Value:=ObjU.MeasureUnitId;
        FDataSet.FieldByName('MEASURE_UNIT_NAME').Value:=ObjU.MeasureUnitName;
      end else begin
        FDataSet.FieldByName('MEASURE_UNIT_ID').Value:=Null;
        FDataSet.FieldByName('MEASURE_UNIT_NAME').Value:=Null;
      end;
    finally
      ClearStrings(Units);
      Units.Free;
    end;

    if FDataSet.State in [dsEdit,dsInsert] then
      FDataSet.Post;

    CheckChanges;
  finally
    Sender.OnSetText:=InstrumentNameSetText;
  end;
end;

procedure TSgtsFunSourceDataConditionForm.MeasureUnitNameSetText(Sender: TField; const Text: string);
var
  Index: Integer;
  Obj: TSgtsMeasureUnitInfo;
  OldMeasureUnitId,OldMeasureUnitName: Variant;
begin
  Sender.OnSetText:=nil;
  try
    if FGrid.SelectedIndex=-1 then exit;
    OldMeasureUnitId:=FDataSet.FieldByName('MEASURE_UNIT_ID').Value;
    OldMeasureUnitName:=FDataSet.FieldByName('MEASURE_UNIT_NAME').Value;
    Index:=FGrid.Columns[FGrid.SelectedIndex].PickList.IndexOf(Text);
    if Index<>-1 then begin
      Obj:=TSgtsMeasureUnitInfo(FGrid.Columns[FGrid.SelectedIndex].PickList.Objects[Index]);
      FDataSet.FieldByName('MEASURE_UNIT_ID').Value:=Obj.MeasureUnitId;
      FDataSet.FieldByName('MEASURE_UNIT_NAME').Value:=Obj.MeasureUnitName;
    end else begin
      FDataSet.FieldByName('MEASURE_UNIT_ID').Value:=OldMeasureUnitId;
      FDataSet.FieldByName('MEASURE_UNIT_NAME').Value:=OldMeasureUnitName;
    end;

    if FDataSet.State in [dsEdit,dsInsert] then
      FDataSet.Post;

    CheckChanges;
  finally
    Sender.OnSetText:=MeasureUnitNameSetText;
  end;
end;

procedure TSgtsFunSourceDataConditionForm.DataSetNewRecord(DataSet: TDataSet);
begin
  FDataSet.Cancel;
end;

procedure TSgtsFunSourceDataConditionForm.UncheckWithOutFirst(CheckListBox: TCheckListBox);
var
  i: Integer;
  Flag: Boolean;
begin
  Flag:=false;
  for i:=0 to CheckListBox.Items.Count-1 do begin
    if CheckListBox.Checked[i] then begin
      if Flag then
        CheckListBox.Checked[i]:=false;
      Flag:=true;
    end;
  end;
end;

procedure TSgtsFunSourceDataConditionForm.EnableDateAdjustment(AEnabled: Boolean);
begin
  LabelDateBegin.Enabled:=AEnabled;
  FDateEditBegin.Enabled:=AEnabled;
  FDateEditBegin.Color:=iff(AEnabled,clWindow,clBtnFace);
  if not AEnabled then
    FDateEditBegin.Text:='';

  CheckBoxDateEnd.Enabled:=AEnabled;
  FDateEditEnd.Enabled:=CheckBoxDateEnd.Checked and AEnabled;
  FDateEditEnd.Color:=iff(CheckBoxDateEnd.Checked and AEnabled,clWindow,clBtnFace);
  if not AEnabled then
    FDateEditEnd.Text:='';

  ButtonDate.Enabled:=AEnabled;
end;

procedure TSgtsFunSourceDataConditionForm.RadioButtonViewOnlyClick(
  Sender: TObject);
var
  FOldCursor: TCursor;
begin
  FOldCursor:=Screen.Cursor;
  Screen.Cursor:=crHourGlass;

  EnableDateAdjustment(RadioButtonViewEdit.Checked);

  DisableEvents;
  try
    FillCycles(RadioButtonViewEdit.Checked);
    if RadioButtonViewEdit.Checked then begin
      UncheckWithOutFirst(CheckListBoxCycles);
    end;
    CheckListBoxCyclesClickCheck(nil);
  finally
    EnableEvents;
    Screen.Cursor:=FOldCursor;
  end;

  if RadioButtonViewEdit.Checked then begin
    FGrid.PopupMenu:=nil;
    CheckAllParams(true);
  end else begin
    EditJournalNum.Text:='';
    FGrid.PopupMenu:=PopupMenu;
  end;
  
  LabelJournalNum.Enabled:=RadioButtonViewEdit.Checked;
  EditJournalNum.Enabled:=LabelJournalNum.Enabled;
  EditJournalNum.Color:=iff(LabelJournalNum.Enabled,clWindow,clBtnFace);
  CheckBoxRestrictIsBase.Enabled:=RadioButtonViewEdit.Checked;
end;

procedure TSgtsFunSourceDataConditionForm.MenuItemCheckAllClick(
  Sender: TObject);
begin
  CheckAllParams(true);
  CheckChanges;
end;

procedure TSgtsFunSourceDataConditionForm.MenuItemRoutesCheckAllClick(
  Sender: TObject);
begin
  CheckAllRoutes(True);
  CheckListBoxRoutesClickCheck(CheckListBoxRoutes);
end;

procedure TSgtsFunSourceDataConditionForm.MenuItemRoutesUnCheckAllClick(
  Sender: TObject);
begin
  CheckAllRoutes(false);
  CheckListBoxRoutesClickCheck(CheckListBoxRoutes);
end;

procedure TSgtsFunSourceDataConditionForm.MenuItemUncheckAllClick(
  Sender: TObject);
begin
  CheckAllParams(false);
  CheckChanges;
end;

procedure TSgtsFunSourceDataConditionForm.CheckAllParams(FlagCheck: Boolean);
begin
  if FDataSet.Active and
     not FDataSet.IsEmpty then begin
    FDataSet.BeginUpdate(true);
    try
      FDataSet.First;
      while not FDataSet.Eof do begin
        FDataSet.Edit;
        FDataSet.FieldByName('IS_CHECK').Value:=Integer(FlagCheck);
        FDataSet.Post;
        FDataSet.Next;
      end;
    finally
      FDataSet.EndUpdate(true);
    end;
  end;
end;

procedure TSgtsFunSourceDataConditionForm.FillPresents;
begin
  if Assigned(Iface) then begin
    ComboBoxPresent.Clear;
    if Iface.MeasureTypeIsVisual then begin
      ComboBoxPresent.Items.Add(SVisualPresent);
      ComboBoxPresent.ItemIndex:=0;
    end else begin
      ComboBoxPresent.Items.Add(SGeneralPresent);
      ComboBoxPresent.Items.Add(SDetailPresent);
      ComboBoxPresent.ItemIndex:=0;
    end;
  end;  
end;

procedure TSgtsFunSourceDataConditionForm.ButtonDateClick(Sender: TObject);
var
  AIface: TSgtsPeriodIface;
  PeriodType: TSgtsPeriodType;
  DateBegin: TDate;
  DateEnd: TDate;
begin
  AIface:=TSgtsPeriodIface.Create(CoreIntf);
  try
    PeriodType:=ptDay;
    DateBegin:=FDateEditBegin.Date;
    DateEnd:=FDateEditEnd.Date;
    if AIface.Select(PeriodType,DateBegin,DateEnd) then begin
      FDateEditBegin.Date:=DateBegin;
      FDateEditEnd.Date:=DateEnd;
      CheckBoxDateEnd.Checked:=true;
    end;
  finally
    AIface.Free;
  end;
end;

procedure TSgtsFunSourceDataConditionForm.SetDateByCycle;
var
  CycleInfo1, CycleInfo2: TSgtsCycleInfo;
  D1, D2: TDate;
begin
  if ButtonDate.Enabled then begin
    CycleInfo1:=GetFirstCheckedCycle;
    CycleInfo2:=GetLastCheckedCycle;
    if Assigned(CycleInfo1) and
       Assigned(CycleInfo2) then begin
      D1:=EncodeDate(CycleInfo1.CycleYear,CycleInfo1.CycleMonth+1,1);
      D2:=EncodeDate(CycleInfo2.CycleYear,CycleInfo2.CycleMonth+1,DaysInAMonth(CycleInfo2.CycleYear,CycleInfo2.CycleMonth+1));
      FDateEditBegin.Date:=D1;
      FDateEditEnd.Date:=D2;
    end;
  end;  
end;

procedure TSgtsFunSourceDataConditionForm.ButtonOkClick(Sender: TObject);
begin
  if FDataSet.State in [dsInsert,dsEdit] then
    FDataSet.Post;

  if CheckBoxDateEnd.Checked then
    if FDateEditEnd.Date<FDateEditBegin.Date then begin
      ShowError(SDateEndCanNotLessDateBegin);
      FDateEditEnd.SetFocus;
      exit;
    end;
  if RadioButtonViewEdit.Checked and
     (Trim(EditJournalNum.Text)='') then begin
    ShowError(SNeedJournalNumber);
    EditJournalNum.SetFocus;
    exit;
  end;   
  ModalResult:=mrOk;
end;

procedure TSgtsFunSourceDataConditionForm.DateEditOnChange(Sender: TObject);
begin
  CheckChanges;
end;

procedure TSgtsFunSourceDataConditionForm.CheckBoxDateEndClick(
  Sender: TObject);
begin
  FDateEditEnd.Enabled:=CheckBoxDateEnd.Checked;
  FDateEditEnd.Color:=iff(FDateEditEnd.Enabled,clWindow,clBtnFace);
end;

procedure TSgtsFunSourceDataConditionForm.CheckAllRoutes(FlagCheck: Boolean);
var
  i: Integer;
begin
  CheckListBoxRoutes.Items.BeginUpdate;
  try
    for i:=0 to CheckListBoxRoutes.Items.Count-1 do begin
      CheckListBoxRoutes.Checked[i]:=FlagCheck;
    end;
  finally
    CheckListBoxRoutes.Items.EndUpdate;
  end;
end;

procedure TSgtsFunSourceDataConditionForm.ParamDefaultValueFieldSetText(
  Sender: TField; const Text: string);
var
  NewText: String;
begin
  if DecimalSeparator<>'.' then
    NewText:=ChangeChar(Text,'.',DecimalSeparator)
  else NewText:=ChangeChar(Text,',',DecimalSeparator);
  NewText:=DeleteDuplicate(NewText,DecimalSeparator);
  NewText:=DeleteToOne(NewText,DecimalSeparator);
  Sender.AsString:=NewText;
end;


end.
