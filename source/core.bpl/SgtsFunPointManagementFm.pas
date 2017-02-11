unit SgtsFunPointManagementFm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, Menus, ImgList, ExtCtrls, ComCtrls, ToolWin, Grids, DBGrids, ActiveX,
  StdCtrls, DBCtrls, Mask, VirtualTrees, VirtualDBTree, SgtsRbkPointManagementFm,
  SgtsDataTreeFm, SgtsFm, SgtsDbTree, SgtsFunPointDocumentsFrm,
  SgtsControls, SgtsExecuteDefs, SgtsSelectDefs, SgtsFunPointInstrumentsFrm,
  SgtsFunMeasureTypeParamsFrm, SgtsFunMeasureTypeAlgorithmsFrm,
  SgtsCoreIntf, SgtsDataGridFrm, SgtsDataIfaceIntf, SgtsFunPointManagementIfaceIntf,
  SgtsGetRecordsConfig;

type
  TSgtsFunPointManagementIface=class;

  TSgtsFunPointManagementForm = class(TSgtsRbkPointManagementForm)
    Splitter: TSplitter;
    PanelInfo: TPanel;
    PageControlInfo: TPageControl;
    TabSheetMeasureType: TTabSheet;
    TabSheetRoute: TTabSheet;
    TabSheetPoint: TTabSheet;                                      
    PanelTop: TPanel;
    PanelCaption: TPanel;
    LabelCaption: TLabel;
    PageControlMeasureType: TPageControl;
    TabSheetMeasureTypeGeneral: TTabSheet;
    TabSheetMeasureTypeParams: TTabSheet;
    TabSheetMeasureTypeAlgorithms: TTabSheet;
    TabSheetMeasureTypeGraphs: TTabSheet;
    PageControlRoute: TPageControl;
    TabSheetRouteGeneral: TTabSheet;
    TabSheetRoutePoints: TTabSheet;
    TabSheetRoutePersonnels: TTabSheet;                         
    PageControlPoint: TPageControl;
    TabSheetPointGeneral: TTabSheet;
    TabSheetPointDocuments: TTabSheet;
    LabelMeasureTypeName: TLabel;
    DBEditMeasureTypeName: TDBEdit;
    LabelMeasureTypeDesc: TLabel;
    DBMemoMeasureTypeDesc: TDBMemo;
    LabelMeasureTypeDate: TLabel;
    CheckBoxMeasureTypeIsActive: TCheckBox;
    EditMeasureTypeDate: TEdit;
    LabelRouteName: TLabel;
    LabelRouteDesc: TLabel;
    DBEditRouteName: TDBEdit;
    DBMemoRouteDesc: TDBMemo;
    Label1: TLabel;
    EditRouteDate: TEdit;
    CheckBoxRouteIsActive: TCheckBox;
    LabelPointName: TLabel;
    LabelPointDesc: TLabel;
    DBEditPointName: TDBEdit;
    DBMemoPointDesc: TDBMemo;
    LabelPointType: TLabel;
    EditPointType: TEdit;
    LabelPointObject: TLabel;
    LabelPointCoordinateX: TLabel;
    LabelPointCoordinateY: TLabel;
    LabelPointCoordinateZ: TLabel;
    EditPointCoordinateX: TEdit;
    EditPointCoordinateY: TEdit;
    EditPointCoordinateZ: TEdit;
    TabSheetConverter: TTabSheet;
    PageControlConverter: TPageControl;
    TabSheetConverterGeneral: TTabSheet;
    LabelConverterName: TLabel;
    LabelConverterDesc: TLabel;
    DBEditConverterName: TDBEdit;
    DBMemoConverterDesc: TDBMemo;
    LabelConverterDate: TLabel;
    EditConverterDate: TEdit;
    TabSheetConverterComponents: TTabSheet;
    TabSheetConverterPassports: TTabSheet;
    CheckBoxJanuary: TCheckBox;
    CheckBoxFebruary: TCheckBox;
    CheckBoxMarch: TCheckBox;
    CheckBoxApril: TCheckBox;
    CheckBoxMay: TCheckBox;
    CheckBoxJune: TCheckBox;
    CheckBoxJuly: TCheckBox;
    CheckBoxAugust: TCheckBox;
    CheckBoxSeptember: TCheckBox;
    CheckBoxOctober: TCheckBox;
    CheckBoxNovember: TCheckBox;
    CheckBoxDecember: TCheckBox;
    CheckBoxConverterNotOperation: TCheckBox;
    LabelPointDateEnter: TLabel;
    EditPointDateEnter: TEdit;
    ButtonPointObject: TButton;
    TabSheetPointPassports: TTabSheet;
    CheckBoxMeasureTypeIsVisual: TCheckBox;
    TabSheetPointInstruments: TTabSheet;
    CheckBoxMeasureTypeIsBase: TCheckBox;
    MemoPointObject: TMemo;
    procedure CheckBoxJanuaryClick(Sender: TObject);
    procedure ButtonPointObjectClick(Sender: TObject);
  private
    FrameMeasureTypeParams: TSgtsFunMeasureTypeParamsFrame;
    FrameMeasureTypeAlgorithms: TSgtsFunMeasureTypeAlgorithmsFrame;
    FrameRoutePersonnels: TSgtsDataGridFrame;
    FramePointInstruments: TSgtsFunPointInstrumentsFrame;
    FramePointDocuments: TSgtsFunPointDocumentsFrame;
    FramePointPassports: TSgtsDataGridFrame;
    FrameConverterComponents: TSgtsDataGridFrame;
    FrameConverterPassports: TSgtsDataGridFrame;

    FMeasureTypeGraphsExists: Boolean;
    FMeasureTypeGraphsFill: Boolean;

    FPointObjectId: Variant;

    FDragPointId: Variant;
    FDragNode: PVirtualNode;
    FOldCaption: String;

    procedure ActivateSheet;
    procedure ActivateMeasureType;
    procedure ActivateRoute;
    procedure ActivatePoint;
    procedure ActivateConverter;
    function GetIface: TSgtsFunPointManagementIface;
  protected
    function GetIfaceIntf: ISgtsDataIface; override;
    procedure TreeDragAllowed(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: Integer; var Allowed: Boolean); override;
    function TreeCanWriteToDataSet(Node: PSgtsTreeDBNode): Boolean; override;
    procedure TreeWritingDataSet(Node: PSgtsTreeDBNode; var Allow: Boolean); override;
    function TreeGetAttachMode(Node: PSgtsTreeDBNode): TVTNodeAttachMode; override;
  public
    constructor Create(ACoreIntf: ISgtsCore); override;
    procedure InitByIface(AIface: TSgtsFormIface); override;

    property Iface: TSgtsFunPointManagementIface read GetIface;
    property OldCaption: String read FOldCaption write FOldCaption;
  end;

  TSgtsFunPointManagementIface=class(TSgtsRbkPointManagementIface,ISgtsFunPointManagementIface)
  private
    FOldFilterGroups: TSgtsGetRecordsConfigFilterGroups;
    FApplyFilter: Boolean;
    FOldTreeId: Variant;
    FFlagCheck: Boolean;
    FFilterOnShow: Boolean;
    FMeasureTypePath: String;
    FMeasureTypeId: Variant;
    FCoordinateZFrom: Variant;
    FCoordinateZTo: Variant;
    FObjectPaths: Variant;
    FEnabledFilterByMeasureType: Boolean;
    procedure RefreshFormCaption;
    function GetForm: TSgtsFunPointManagementForm;
    function ChildExists(TreeParentId: Variant; UnionType: TSgtsRbkPointManagementIfaceUnionType): Boolean;
    function _GetMeasureTypeIsVisual: Boolean;
  protected
    procedure AfterCreateForm(AForm: TSgtsForm); override;
    procedure BeforeNeedShow(AForm: TSgtsForm); override;
    procedure DataSetAfterScroll(DataSet: TDataSet); override;
  public
    constructor Create(ACoreIntf: ISgtsCore); override;
    destructor Destroy; override;
    procedure Init; override;
    procedure UpdateButtons; override;
    procedure Update; override;
    procedure UpdateByDefs(ExecuteDefs: Pointer); override;
    function CanCopy: Boolean; override;
    procedure Show; override;
    function CanShow: Boolean; override;
    procedure Refresh; override;
    function NeedShow: Boolean; override;
    function SelectVisible(Fields: String; Values: Variant; var Data: String;
                           FilterGroups: TSgtsGetRecordsConfigFilterGroups=nil; MultiSelect: Boolean=false): Boolean; override;
    function SelectInvisible(var Data: String; FilterGroups: TSgtsGetRecordsConfigFilterGroups=nil): Boolean; override;

    property Form: TSgtsFunPointManagementForm read GetForm;

    property FilterOnShow: Boolean read FFilterOnShow write FFilterOnShow;
    property EnabledFilterByMeasureType: Boolean read FEnabledFilterByMeasureType write FEnabledFilterByMeasureType;

    property MeasureTypePath: String read FMeasureTypePath write FMeasureTypePath;
    property MeasureTypeId: Variant read FMeasureTypeId write FMeasureTypeId;
    property CoordinateZFrom: Variant read FCoordinateZFrom write FCoordinateZFrom;
    property CoordinateZTo: Variant read FCoordinateZTo write FCoordinateZTo;
  end;

var
  SgtsFunPointManagementForm: TSgtsFunPointManagementForm;

implementation

uses DBClient,
     SgtsDbGrid, SgtsCDS, SgtsProviderConsts, SgtsDatabaseCDS,
     SgtsConsts, SgtsDataEditFm, SgtsDataFm,
     SgtsIface, SgtsUtils,
     SgtsFunMeasureTypeIfaces, SgtsFunMeasureTypePlanIfaces,
     SgtsFunPointConverterIfaces,
     SgtsFunMeasureTypeRouteIfaces, SgtsFunRoutePointIfaces,
     SgtsFunConverterComponentIfaces,
     SgtsFunRoutePersonnelIfaces, SgtsFunConverterPassportIfaces,
     SgtsRbkObjectsFm, SgtsFunPointPassportIfaces, SgtsRbkObjectTreesFm,
     SgtsFunPointInstrumentIfaces, SgtsFunPointManagementFilterFm;

{$R *.dfm}

{ TSgtsFunPointManagementIface }

constructor TSgtsFunPointManagementIface.Create(ACoreIntf: ISgtsCore);
begin
  inherited Create(ACoreIntf);
  FFilterOnShow:=true;
  FMeasureTypePath:='';
  FMeasureTypeId:=Null;
  FCoordinateZFrom:=Null;
  FCoordinateZTo:=Null;
  FObjectPaths:=Null;

  FOldFilterGroups:=TSgtsGetRecordsConfigFilterGroups.Create;

  FEnabledFilterByMeasureType:=true;

end;

destructor TSgtsFunPointManagementIface.Destroy;
begin
  FOldFilterGroups.Free;
  inherited Destroy;
end;

procedure TSgtsFunPointManagementIface.Init;
begin
  inherited Init;
  FormClass:=TSgtsFunPointManagementForm;
  InterfaceName:=SInterfaceFunPointManagement;
  with InsertClasses do begin
    Add(TSgtsFunMeasureTypeInsertIface);
    Add(TSgtsFunMeasureTypeInsertChildIface);
    Add(TSgtsFunMeasureTypeRouteInsertIface);
    Add(TSgtsFunRoutePointInsertIface);
    Add(TSgtsFunPointConverterInsertIface);
  end;
  UpdateClass:=TSgtsFunMeasureTypeUpdateIface;
  DeleteClass:=TSgtsFunMeasureTypeDeleteIface;
end;

function TSgtsFunPointManagementIface.GetForm: TSgtsFunPointManagementForm;
begin
  Result:=TSgtsFunPointManagementForm(inherited Form);
end;

procedure TSgtsFunPointManagementIface.AfterCreateForm(AForm: TSgtsForm);
begin
  inherited AfterCreateForm(AForm);
end;

procedure TSgtsFunPointManagementIface.DataSetAfterScroll(DataSet: TDataSet);
var
  NewTreeId: Variant;
begin
  if DataSet.Active and not DataSet.IsEmpty then begin
    if Assigned(Form) then begin
      with Form do begin
        PageControlInfo.Visible:=true;
        NewTreeId:=DataSet.FieldByName('TREE_ID').AsInteger;
        if (FOldTreeId<>NewTreeId) or FFlagCheck then begin
          PageControlInfo.ActivePageIndex:=DataSet.FieldByName('UNION_TYPE').AsInteger;
          LabelCaption.Caption:=PageControlInfo.ActivePage.Caption;
          ActivateSheet;
          FOldTreeId:=NewTreeId;
        end;
      end;
    end;
  end else
    if Assigned(Form) then begin
      Form.PageControlInfo.Visible:=false;
      Form.LabelCaption.Caption:=Form.PanelInfo.Caption;
    end;
  UpdateButtons;
end;

procedure TSgtsFunPointManagementIface.UpdateButtons;
var
  UnionType: TSgtsRbkPointManagementIfaceUnionType;
begin
  if DataSet.Active and not DataSet.IsEmpty then begin
    UnionType:=TSgtsRbkPointManagementIfaceUnionType(DataSet.FieldByName('UNION_TYPE').AsInteger);
    case UnionType of
      utMeasureType: begin
        UpdateClass:=TSgtsFunMeasureTypeUpdateIface;
        DeleteClass:=TSgtsFunMeasureTypeDeleteIface;
      end;
      utRoute: begin
        UpdateClass:=TSgtsFunMeasureTypeRouteUpdateIface;
        DeleteClass:=TSgtsFunMeasureTypeRouteDeleteIface;
      end;
      utPoint: begin
        UpdateClass:=TSgtsFunRoutePointUpdateIface;
        DeleteClass:=TSgtsFunRoutePointDeleteIface;
      end;
      utConverter: begin
        UpdateClass:=TSgtsFunPointConverterUpdateIface;
        DeleteClass:=TSgtsFunPointConverterDeleteIface;
      end;
    end;
  end;
  inherited UpdateButtons;
end;

procedure TSgtsFunPointManagementIface.Update; 
begin
  FFlagCheck:=true;
  inherited Update;
end;

procedure TSgtsFunPointManagementIface.UpdateByDefs(ExecuteDefs: Pointer);
begin
  inherited UpdateByDefs(ExecuteDefs);
  FFlagCheck:=false;
end;

function TSgtsFunPointManagementIface.CanCopy: Boolean;
var
  UnionType: TSgtsRbkPointManagementIfaceUnionType;
begin
  Result:=inherited CanCopy;
  if Result then begin
    if DataSet.Active and not DataSet.IsEmpty then begin
      UnionType:=TSgtsRbkPointManagementIfaceUnionType(DataSet.FieldByName('UNION_TYPE').AsInteger);
      Result:=Result and (UnionType in [utMeasureType]);
    end else
      Result:=false
  end;
end;

function TSgtsFunPointManagementIface.ChildExists(TreeParentId: Variant;
                                                  UnionType: TSgtsRbkPointManagementIfaceUnionType): Boolean;
var
  DS: TSgtsCDS;
begin
  Result:=false;
  DS:=TSgtsCDS.Create(nil);
  try
    DS.Data:=DataSet.Data;
    if DS.Active then begin
      DS.BeginUpdate(false);
      try
        DS.Filter:=Format('TREE_PARENT_ID=%s AND UNION_TYPE=%d',[QuotedStr(VarToStrDef(TreeParentId,'')),Integer(UnionType)]);
        DS.Filtered:=true;
        Result:=DS.RecordCount>0;
      finally
        DS.EndUpdate(false);
      end;
    end;
  finally
    DS.Free;
  end;
end;

function TSgtsFunPointManagementIface._GetMeasureTypeIsVisual: Boolean;
var
  UnionType: TSgtsRbkPointManagementIfaceUnionType;
begin
  Result:=false;
  if Assigned(Form) then begin
    with DataSet do begin
      if Active and not IsEmpty then begin
        UnionType:=TSgtsRbkPointManagementIfaceUnionType(FieldByName('UNION_TYPE').AsInteger);
        case UnionType of
          utMeasureType: Result:=Form.CheckBoxMeasureTypeIsVisual.Checked;
        end;
      end;
    end;
  end;
end;

function TSgtsFunPointManagementIface.CanShow: Boolean;
begin
  Result:=inherited CanShow and
          PermissionExists(SPermissionNameShow);
end;

procedure TSgtsFunPointManagementIface.Refresh;
begin
  if Assigned(Form) then
    Form.PageControlInfo.Visible:=false;
  try
    inherited Refresh;
  finally
    if Assigned(Form) then
      Form.PageControlInfo.Visible:=true;
  end;
end;

procedure TSgtsFunPointManagementIface.RefreshFormCaption;
begin
  if Assigned(Form) then begin
    Form.Caption:=Form.OldCaption;
    if Trim(FMeasureTypePath)<>'' then
      Form.Caption:=Format('%s: %s',[Form.OldCaption,FMeasureTypePath]);
  end;
end;

function TSgtsFunPointManagementIface.SelectInvisible(var Data: String; FilterGroups: TSgtsGetRecordsConfigFilterGroups): Boolean;
begin
  FOldFilterGroups.Clear;
  if Assigned(FilterGroups) then
    FOldFilterGroups.CopyFrom(FilterGroups);
  
  Result:=inherited SelectInvisible(Data,FilterGroups);
end;

function TSgtsFunPointManagementIface.SelectVisible(Fields: String; Values: Variant; var Data: String;
                                                    FilterGroups: TSgtsGetRecordsConfigFilterGroups;
                                                    MultiSelect: Boolean): Boolean;
begin
  FOldFilterGroups.Clear;
  if Assigned(FilterGroups) then
    FOldFilterGroups.CopyFrom(FilterGroups);
  Result:=inherited SelectVisible(Fields,Values,Data,FilterGroups,MultiSelect);
end;

procedure TSgtsFunPointManagementIface.Show;
begin
  inherited Show;
end;

function TSgtsFunPointManagementIface.NeedShow: Boolean;
begin
  Result:=inherited NeedShow and FApplyFilter;
end;

procedure TSgtsFunPointManagementIface.BeforeNeedShow(AForm: TSgtsForm);
var
  Iface: TSgtsFunPointManagementFilterFormIface;
  Group: TSgtsGetRecordsConfigFilterGroup;
begin
  inherited BeforeNeedShow(AForm);
  if FFilterOnShow then begin
    FApplyFilter:=false;
    Iface:=TSgtsFunPointManagementFilterFormIface.Create(CoreIntf);
    try
      Iface.Init;
      Iface.ReadParams;
      Iface.MeasureTypePath:=FMeasureTypePath;
      Iface.MeasureTypeId:=FMeasureTypeId;
      Iface.CoordinateZFrom:=FCoordinateZFrom;
      Iface.CoordinateZTo:=FCoordinateZTo;
      Iface.ObjectPaths:=FObjectPaths;
      Iface.FilterGroups.CopyFrom(DataSet.FilterGroups);
      Iface.EnabledFilterByMeasureType:=FEnabledFilterByMeasureType;
      if Iface.ShowModal=mrOk then begin
        FMeasureTypePath:=Iface.MeasureTypePath;
        FMeasureTypeId:=Iface.MeasureTypeId;
        FCoordinateZFrom:=Iface.CoordinateZFrom;
        FCoordinateZTo:=Iface.CoordinateZTo;
        FObjectPaths:=Iface.ObjectPaths;
        with DataSet.FilterGroups do begin
          Clear;
          CopyFrom(FOldFilterGroups);
          Group:=DataSet.FilterGroups.Add;
          with Group.Filters do begin
            Add('MEASURE_TYPE_ID',fcEqual,FMeasureTypeId);
            Add('COORDINATE_Z',fcEqualGreater,FCoordinateZFrom);
            Add('COORDINATE_Z',fcEqualLess,FCoordinateZTo);
            Add('OBJECT_PATHS',fcLike,FObjectPaths).LeftSide:=true;
          end;
          DataSet.FilterGroups.CopyFrom(Iface.FilterGroups,false);
        end;
        FApplyFilter:=true;
      end;
    finally
      Iface.WriteParams;
      Iface.Free;
    end;
  end else
    FApplyFilter:=true;
  RefreshFormCaption;    
end;


{ TSgtsFunPointManagementForm }

constructor TSgtsFunPointManagementForm.Create(ACoreIntf: ISgtsCore);
var
  i: Integer;
begin
  inherited Create(ACoreIntf);
  for i:=0 to PageControlInfo.PageCount-1 do begin
    PageControlInfo.Pages[i].TabVisible:=false;
    PageControlInfo.Pages[i].Visible:=true;
  end;
  PageControlInfo.Visible:=false;

  FrameMeasureTypeParams:=TSgtsFunMeasureTypeParamsFrame.Create(Self);
  with FrameMeasureTypeParams do begin
    Name:='FrameMeasureTypeParams';
    Parent:=TabSheetMeasureTypeParams;
  end;
  FrameMeasureTypeParams.InitByCore(CoreIntf);

  FrameMeasureTypeAlgorithms:=TSgtsFunMeasureTypeAlgorithmsFrame.Create(Self);
  with FrameMeasureTypeAlgorithms do begin
    Parent:=TabSheetMeasureTypeAlgorithms;
    Name:='FrameMeasureTypeAlgorithms';
  end;
  FrameMeasureTypeAlgorithms.InitByCore(CoreIntf);

  FrameRoutePersonnels:=TSgtsDataGridFrame.Create(Self);
  with FrameRoutePersonnels do begin
    Name:='FrameRoutePersonnels';
    Parent:=TabSheetRoutePersonnels;
    InsertClass:=TSgtsFunRoutePersonnelInsertIface;
    UpdateClass:=TSgtsFunRoutePersonnelUpdateIface;
    DeleteClass:=TSgtsFunRoutePersonnelDeleteIface;
    with DataSet do begin
      ProviderName:=SProviderSelectPersonnelRoutes;
      with SelectDefs do begin
        Add('PERSONNEL_NAME','�����������',150);
        Add('DATE_PURPOSE','���� ����������',70);
        AddInvisible('PERSONNEL_ID');
        AddInvisible('DEPUTY_ID');
        AddInvisible('DEPUTY_NAME');
        AddInvisible('ROUTE_ID');
        AddInvisible('ROUTE_NAME');
      end;
    end;
  end;
  FrameRoutePersonnels.InitByCore(CoreIntf);

  FramePointInstruments:=TSgtsFunPointInstrumentsFrame.Create(Self);
  with FramePointInstruments do begin
    Name:='FramePointInstruments';
    Parent:=TabSheetPointInstruments;
  end;
  FramePointInstruments.InitByCore(CoreIntf);

  FramePointDocuments:=TSgtsFunPointDocumentsFrame.Create(Self);
  with FramePointDocuments do begin
    Name:='FramePointDocuments';
    Parent:=TabSheetPointDocuments;
  end;
  FramePointDocuments.InitByCore(CoreIntf);

  FramePointPassports:=TSgtsDataGridFrame.Create(Self);
  with FramePointPassports do begin
    Name:='FramePointPassports';
    Parent:=TabSheetPointPassports;
    InsertClass:=TSgtsFunPointPassportInsertIface;
    UpdateClass:=TSgtsFunPointPassportUpdateIface;
    DeleteClass:=TSgtsFunPointPassportDeleteIface;
    with DataSet do begin
      ProviderName:=SProviderSelectPointPassports;
      with SelectDefs do begin
        AddInvisible('POINT_NAME');
        Add('DATE_CHECKUP','���� �������',60);
        Add('DESCRIPTION','��������',150);
        AddInvisible('POINT_PASSPORT_ID');
        AddInvisible('POINT_ID');

      end;
    end;
  end;
  FramePointPassports.InitByCore(CoreIntf);

  FrameConverterComponents:=TSgtsDataGridFrame.Create(Self);
  with FrameConverterComponents do begin
    Name:='FrameConverterComponents';
    Parent:=TabSheetConverterComponents;
    InsertClass:=TSgtsFunConverterComponentInsertIface;
    UpdateClass:=TSgtsFunConverterComponentUpdateIface;
    DeleteClass:=TSgtsFunConverterComponentDeleteIface;
    with DataSet do begin
      ProviderName:=SProviderSelectComponents;
      with SelectDefs do begin
        Add('NAME','���������',70);
        AddInvisible('COMPONENT_ID');
        AddInvisible('CONVERTER_ID');
        AddInvisible('PARAM_ID');
        AddInvisible('DESCRIPTION');
        AddInvisible('CONVERTER_NAME');
        AddInvisible('PARAM_NAME');
      end;
    end;
  end;
  FrameConverterComponents.InitByCore(CoreIntf);

  FrameConverterPassports:=TSgtsDataGridFrame.Create(Self);
  with FrameConverterPassports do begin
    Name:='FrameConverterPassports';
    Parent:=TabSheetConverterPassports;
    InsertClass:=TSgtsFunConverterPassportInsertIface;
    UpdateClass:=TSgtsFunConverterPassportUpdateIface;
    DeleteClass:=TSgtsFunConverterPassportDeleteIface;
    with DataSet do begin
      ProviderName:=SProviderSelectConverterPassports;
      with SelectDefs do begin
        Add('COMPONENT_NAME','���������',110);
        Add('DATE_BEGIN','���� ������',60);
        Add('DATE_END','���� ���������',60);
        Add('VALUE','��������',40);
        AddInvisible('CONVERTER_PASSPORT_ID');
        AddInvisible('COMPONENT_ID');
        AddInvisible('CONVERTER_ID');
        AddInvisible('INSTRUMENT_ID');
        AddInvisible('INSTRUMENT_NAME');
        AddInvisible('MEASURE_UNIT_ID');
        AddInvisible('MEASURE_UNIT_NAME');
        AddInvisible('DESCRIPTION');
      end;
    end;
  end;
  FrameConverterPassports.InitByCore(CoreIntf);

  PageControlInfo.ActivePage:=TabSheetMeasureType;
  PageControlMeasureType.ActivePage:=TabSheetMeasureTypeGeneral;
  PageControlRoute.ActivePage:=TabSheetRouteGeneral;
  PageControlPoint.ActivePage:=TabSheetPointGeneral;
  PageControlConverter.ActivePage:=TabSheetConverterGeneral;

  FOldCaption:=Caption;
end;

procedure TSgtsFunPointManagementForm.InitByIface(AIface: TSgtsFormIface);
begin
  inherited InitByIface(AIface);
  FrameMeasureTypeParams.InitByIface(Iface);
  FrameMeasureTypeAlgorithms.InitByIface(Iface);
  FrameRoutePersonnels.InitByIface(Iface);
  FramePointInstruments.InitByIface(Iface);
  FramePointDocuments.InitByIface(Iface);
  FramePointPassports.InitByIface(Iface);
  FrameConverterComponents.InitByIface(Iface);
  FrameConverterPassports.InitByIface(Iface);
end;

function TSgtsFunPointManagementForm.GetIface: TSgtsFunPointManagementIface;
begin
  Result:=TSgtsFunPointManagementIface(inherited Iface);
end;

function TSgtsFunPointManagementForm.GetIfaceIntf: ISgtsDataIface;
begin
  Result:=inherited GetIfaceIntf;
  case PageControlInfo.ActivePageIndex of
    0: begin
      case PageControlMeasureType.ActivePageIndex of
        1: if ActiveControl=FrameMeasureTypeParams.Grid then Result:=FrameMeasureTypeParams;
        2: if ActiveControl=FrameMeasureTypeAlgorithms.Grid then Result:=FrameMeasureTypeAlgorithms;
      end;
    end;
    1: begin
      case PageControlRoute.ActivePageIndex of
        2: if ActiveControl=FrameRoutePersonnels.Grid then Result:=FrameRoutePersonnels;
      end;
    end;
    2: begin
      case PageControlPoint.ActivePageIndex of
        1: if ActiveControl=FramePointInstruments.Grid then Result:=FramePointInstruments;
        2: if ActiveControl=FramePointDocuments.Grid then Result:=FramePointDocuments;
        3: if ActiveControl=FramePointPassports.Grid then Result:=FramePointPassports;
      end;
    end;
    3: begin
      case PageControlConverter.ActivePageIndex of
        1: if ActiveControl=FrameConverterComponents.Grid then Result:=FrameConverterComponents;
        2: if ActiveControl=FrameConverterPassports.Grid then Result:=FrameConverterPassports; 
      end;
    end;
  end;
end;

procedure TSgtsFunPointManagementForm.ActivateSheet;
begin
  case PageControlInfo.ActivePageIndex of
    0: ActivateMeasureType;
    1: ActivateRoute;
    2: ActivatePoint;
    3: ActivateConverter;    
  end;
end;

procedure TSgtsFunPointManagementForm.ActivateMeasureType;
var
  AMeasureTypeId: Variant;
  AParentId: Variant;
  AIsVisual: Boolean;

  procedure FillGeneral;
  var
    DS: TSgtsDatabaseCDS;
  begin
    DS:=TSgtsDatabaseCDS.Create(CoreIntf);
    try
      DS.ProviderName:=SProviderSelectMeasureTypes;
      with DS.SelectDefs do begin
        AddInvisible('DATE_BEGIN');
        AddInvisible('IS_ACTIVE');
        AddInvisible('IS_BASE');
        AddInvisible('IS_VISUAL');
      end;
      DS.FilterGroups.Add.Filters.Add('MEASURE_TYPE_ID',fcEqual,AMeasureTypeId);
      DS.Open;
      if DS.Active and not DS.IsEmpty then begin
        EditMeasureTypeDate.Text:=DS.FieldByName('DATE_BEGIN').AsString;
        CheckBoxMeasureTypeIsActive.Checked:=Boolean(DS.FieldByName('IS_ACTIVE').AsInteger);
        CheckBoxMeasureTypeIsVisual.Checked:=Boolean(DS.FieldByName('IS_VISUAL').AsInteger);
        CheckBoxMeasureTypeIsBase.Checked:=Boolean(DS.FieldByName('IS_BASE').AsInteger);
        TabSheetMeasureTypeGeneral.Visible:=true;
      end;
      AIsVisual:=CheckBoxMeasureTypeIsVisual.Checked;
    finally
      DS.Free;
    end;
  end;

  procedure FillParams;
  begin
    with FrameMeasureTypeParams do begin
      CloseData;
      with DataSet do begin
        FilterGroups.Clear;
        FilterGroups.Add.Filters.Add('MEASURE_TYPE_ID',fcEqual,AMeasureTypeId);
        ExecuteDefs.Clear;
        ExecuteDefs.AddValue('MEASURE_TYPE_ID',AMeasureTypeId);
        ExecuteDefs.AddValue('MEASURE_TYPE_NAME',Iface.DataSet.FieldByName('NAME').Value);
      end;
      OpenData;
      UpdateButtons;
    end;
  end;

  procedure FillAlgorithms;
  begin
    with FrameMeasureTypeAlgorithms do begin
      CloseData;
      with DataSet do begin
        FilterGroups.Clear;
        FilterGroups.Add.Filters.Add('MEASURE_TYPE_ID',fcEqual,AMeasureTypeId);
        ExecuteDefs.Clear;
        ExecuteDefs.AddValue('MEASURE_TYPE_ID',AMeasureTypeId);
        ExecuteDefs.AddValue('MEASURE_TYPE_NAME',Iface.DataSet.FieldByName('NAME').Value);
      end;
      OpenData;
      UpdateButtons;
    end;
  end;

  procedure FillGraphs;
  var
    DS: TSgtsDatabaseCDS;
  begin
    DS:=TSgtsDatabaseCDS.Create(CoreIntf);
    try
      DS.ProviderName:=SProviderSelectGraphs;
      with DS.SelectDefs do begin
        AddInvisible('JANUARY');
        AddInvisible('FEBRUARY');
        AddInvisible('MARCH');
        AddInvisible('APRIL');
        AddInvisible('MAY');
        AddInvisible('JUNE');
        AddInvisible('JULY');
        AddInvisible('AUGUST');
        AddInvisible('SEPTEMBER');
        AddInvisible('OCTOBER');
        AddInvisible('NOVEMBER');
        AddInvisible('DECEMBER');
      end;
      DS.FilterGroups.Add.Filters.Add('GRAPH_ID',fcEqual,AMeasureTypeId);
      DS.Open;
      if DS.Active then begin
        FMeasureTypeGraphsExists:=not DS.IsEmpty;
        FMeasureTypeGraphsFill:=true;
        try
          CheckBoxJanuary.Checked:=Boolean(DS.FieldByName('JANUARY').AsInteger);
          CheckBoxFebruary.Checked:=Boolean(DS.FieldByName('FEBRUARY').AsInteger);
          CheckBoxMarch.Checked:=Boolean(DS.FieldByName('MARCH').AsInteger);
          CheckBoxApril.Checked:=Boolean(DS.FieldByName('APRIL').AsInteger);
          CheckBoxMay.Checked:=Boolean(DS.FieldByName('MAY').AsInteger);
          CheckBoxJune.Checked:=Boolean(DS.FieldByName('JUNE').AsInteger);
          CheckBoxJuly.Checked:=Boolean(DS.FieldByName('JULY').AsInteger);
          CheckBoxAugust.Checked:=Boolean(DS.FieldByName('AUGUST').AsInteger);
          CheckBoxSeptember.Checked:=Boolean(DS.FieldByName('SEPTEMBER').AsInteger);
          CheckBoxOctober.Checked:=Boolean(DS.FieldByName('OCTOBER').AsInteger);
          CheckBoxNovember.Checked:=Boolean(DS.FieldByName('NOVEMBER').AsInteger);
          CheckBoxDecember.Checked:=Boolean(DS.FieldByName('DECEMBER').AsInteger);
        finally
          FMeasureTypeGraphsFill:=false;
        end;  
      end;
    finally
      DS.Free;
    end;
  end;

var
  OldCursor: TCursor;
  AVisible: Boolean;
  ATreeId: Variant;
begin
  OldCursor:=Screen.Cursor;
  Screen.Cursor:=crHourGlass;
  try
    with Iface.DataSet do begin
      ATreeId:=FieldByName('TREE_ID').Value;
      AMeasureTypeId:=FieldByName('UNION_ID').Value;
      AParentId:=FieldByName('UNION_PARENT_ID').Value;
    end;
    FillGeneral;

    AVisible:=not Iface.ChildExists(ATreeId,utMeasureType);
    TabSheetMeasureTypeParams.TabVisible:=AVisible and not AIsVisual;
    TabSheetMeasureTypeAlgorithms.TabVisible:=AVisible;
//    TabSheetMeasureTypeGraphs.TabVisible:=AVisible;

    if AVisible then begin
      FillParams;
      FillAlgorithms;
//      FillGraphs;
    end;
  finally
    Screen.Cursor:=OldCursor;
  end;
end;

procedure TSgtsFunPointManagementForm.ActivateRoute;
var
  ARouteId: Variant;

  procedure FillGeneral;
  var
    DS: TSgtsDatabaseCDS;
  begin
    DS:=TSgtsDatabaseCDS.Create(CoreIntf);
    try
      DS.ProviderName:=SProviderSelectRoutes;
      DS.SelectDefs.AddInvisible('DATE_ROUTE');
      DS.SelectDefs.AddInvisible('IS_ACTIVE');
      DS.FilterGroups.Add.Filters.Add('ROUTE_ID',fcEqual,ARouteId);
      DS.Open;
      if DS.Active and not DS.IsEmpty then begin
        EditRouteDate.Text:=DS.FieldByName('DATE_ROUTE').AsString;
        CheckBoxRouteIsActive.Checked:=Boolean(DS.FieldByName('IS_ACTIVE').AsInteger);
      end;
    finally
      DS.Free;
    end;
  end;

  procedure FillPersonnels;
  begin
    with FrameRoutePersonnels do begin
      CloseData;
      with DataSet do begin
        FilterGroups.Clear;
        FilterGroups.Add.Filters.Add('ROUTE_ID',fcEqual,ARouteId);
        ExecuteDefs.Clear;
        ExecuteDefs.AddValue('ROUTE_ID',ARouteId);
        ExecuteDefs.AddValue('ROUTE_NAME',Iface.DataSet.FieldByName('NAME').Value);
      end;
      OpenData;
      UpdateButtons;
    end;
  end;

var
  OldCursor: TCursor;
begin
  OldCursor:=Screen.Cursor;
  Screen.Cursor:=crHourGlass;
  try
    ARouteId:=Iface.DataSet.FieldByName('UNION_ID').Value;
    FillGeneral;
    FillPersonnels;
  finally
    Screen.Cursor:=OldCursor;
  end;
end;

procedure TSgtsFunPointManagementForm.ActivatePoint;
var
  APointId: Variant;

  procedure FillGeneral;
  var
    DS: TSgtsDatabaseCDS;
  begin
    DS:=TSgtsDatabaseCDS.Create(CoreIntf);
    try
      DS.ProviderName:=SProviderSelectPoints;
      with DS.SelectDefs do begin
        AddInvisible('OBJECT_ID');
        AddInvisible('POINT_TYPE_NAME');
        AddInvisible('OBJECT_NAME');
        AddInvisible('COORDINATE_X');
        AddInvisible('COORDINATE_Y');
        AddInvisible('COORDINATE_Z');
        AddInvisible('DATE_ENTER');
        AddInvisible('OBJECT_PATHS');
      end;
      DS.FilterGroups.Add.Filters.Add('POINT_ID',fcEqual,APointId);
      DS.Open;
      if DS.Active and not DS.IsEmpty then begin
        FPointObjectId:=DS.FieldByName('OBJECT_ID').Value;
        EditPointType.Text:=DS.FieldByName('POINT_TYPE_NAME').AsString;
        MemoPointObject.Lines.Text:=DS.FieldByName('OBJECT_PATHS').AsString;
        EditPointCoordinateX.Text:=DS.FieldByName('COORDINATE_X').AsString;
        EditPointCoordinateY.Text:=DS.FieldByName('COORDINATE_Y').AsString;
        EditPointCoordinateZ.Text:=DS.FieldByName('COORDINATE_Z').AsString;
        EditPointDateEnter.Text:=DS.FieldByName('DATE_ENTER').AsString;
      end else
        FPointObjectId:=Null;
    finally
      DS.Free;
    end;
  end;

  procedure FillInstruments;
  begin
    with FramePointInstruments do begin
      CloseData;
      with DataSet do begin
        FilterGroups.Clear;
        FilterGroups.Add.Filters.Add('POINT_ID',fcEqual,APointId);
        ExecuteDefs.Clear;
        ExecuteDefs.AddValue('POINT_ID',APointId);
        ExecuteDefs.AddValue('POINT_NAME',Iface.DataSet.FieldByName('NAME').Value);
      end;
      OpenData;
      UpdateButtons;
    end;
  end;

  procedure FillDocuments;
  begin
    with FramePointDocuments do begin
      CloseData;
      with DataSet do begin
        FilterGroups.Clear;
        FilterGroups.Add.Filters.Add('POINT_ID',fcEqual,APointId);
        ExecuteDefs.Clear;
        ExecuteDefs.AddValue('POINT_ID',APointId);
        ExecuteDefs.AddValue('POINT_NAME',Iface.DataSet.FieldByName('NAME').Value);
      end;
      OpenData;
      UpdateButtons;
    end;
  end;

  procedure FillPassports;
  begin
    with FramePointPassports do begin
      CloseData;
      with DataSet do begin
        FilterGroups.Clear;
        FilterGroups.Add.Filters.Add('POINT_ID',fcEqual,APointId);
        ExecuteDefs.Clear;
        ExecuteDefs.AddValue('POINT_ID',APointId);
        ExecuteDefs.AddValue('POINT_NAME',Iface.DataSet.FieldByName('NAME').Value);
      end;
      OpenData;
      UpdateButtons;
    end;
  end;

var
  OldCursor: TCursor;
begin
  OldCursor:=Screen.Cursor;
  Screen.Cursor:=crHourGlass;
  try
    APointId:=Iface.DataSet.FieldByName('UNION_ID').Value;
    FillGeneral;
    FillInstruments;
    FillDocuments;
    FillPassports;
  finally
    Screen.Cursor:=OldCursor;
  end;
end;

procedure TSgtsFunPointManagementForm.ActivateConverter;
var
  AConverterId: Variant;

  procedure FillGeneral;
  var
    DS: TSgtsDatabaseCDS;
  begin
    DS:=TSgtsDatabaseCDS.Create(CoreIntf);
    try
      DS.ProviderName:=SProviderSelectConverters;
      with DS.SelectDefs do begin
        AddInvisible('DATE_ENTER');
        AddInvisible('NOT_OPERATION');
      end;
      DS.FilterGroups.Add.Filters.Add('CONVERTER_ID',fcEqual,AConverterId);
      DS.Open;
      if DS.Active and not DS.IsEmpty then begin
        EditConverterDate.Text:=DS.FieldByName('DATE_ENTER').AsString;
        CheckBoxConverterNotOperation.Checked:=Boolean(DS.FieldByName('NOT_OPERATION').AsInteger);
      end;
    finally
      DS.Free;
    end;
  end;

  procedure FillComponents;
  begin
    with FrameConverterComponents do begin
      CloseData;
      with DataSet do begin
        FilterGroups.Clear;
        FilterGroups.Add.Filters.Add('CONVERTER_ID',fcEqual,AConverterId);
        ExecuteDefs.Clear;
        ExecuteDefs.AddValue('CONVERTER_ID',AConverterId);
        ExecuteDefs.AddValue('CONVERTER_NAME',Iface.DataSet.FieldByName('NAME').Value);
      end;
      OpenData;
      UpdateButtons;
    end;
  end;

  procedure FillPassports;
  begin
    with FrameConverterPassports do begin
      CloseData;
      with DataSet do begin
        FilterGroups.Clear;
        FilterGroups.Add.Filters.Add('CONVERTER_ID',fcEqual,AConverterId);
        ExecuteDefs.Clear;
        ExecuteDefs.AddValue('CONVERTER_ID',AConverterId);
      end;
      OpenData;
      UpdateButtons;
    end;
  end;

var
  OldCursor: TCursor;
begin
  OldCursor:=Screen.Cursor;
  Screen.Cursor:=crHourGlass;
  try
    AConverterId:=Iface.DataSet.FieldByName('UNION_ID').Value;
    FillGeneral;
    FillComponents;
    FillPassports;
  finally
    Screen.Cursor:=OldCursor;
  end;
end;

procedure TSgtsFunPointManagementForm.CheckBoxJanuaryClick(
  Sender: TObject);
{var
  AMeasureTypeId: Variant;
  CheckBox: TCheckBox;
  FlagInsert: Boolean;
  DS: TSgtsDatabaseCDS;
  OldCursor: TCursor;}
begin
{  CheckBox:=nil;
  if Sender is TCheckBox then
    CheckBox:=TCheckBox(Sender);
  if Assigned(CheckBox) and
     not FMeasureTypeGraphsFill then begin
    AMeasureTypeId:=Iface.DataSet.FieldByName('UNION_ID').Value;
    if CheckBox.Checked then begin
      FlagInsert:=not FMeasureTypeGraphsExists;
    end else FlagInsert:=false;
    OldCursor:=Screen.Cursor;
    Screen.Cursor:=crHourGlass;
    DS:=TSgtsDatabaseCDS.Create(CoreIntf);
    try
      if FlagInsert then begin
        DS.ProviderName:=SProviderInsertGraph;
      end else begin
        DS.ProviderName:=SProviderUpdateGraph;
      end;
      with DS.ExecuteDefs do begin
        AddKeyLink('GRAPH_ID').Value:=AMeasureTypeId;
        AddInvisible('JANUARY').Value:=Integer(CheckBoxJanuary.Checked);
        AddInvisible('FEBRUARY').Value:=Integer(CheckBoxFebruary.Checked);
        AddInvisible('MARCH').Value:=Integer(CheckBoxMarch.Checked);
        AddInvisible('APRIL').Value:=Integer(CheckBoxApril.Checked);
        AddInvisible('MAY').Value:=Integer(CheckBoxMay.Checked);
        AddInvisible('JUNE').Value:=Integer(CheckBoxJune.Checked);
        AddInvisible('JULY').Value:=Integer(CheckBoxJuly.Checked);
        AddInvisible('AUGUST').Value:=Integer(CheckBoxAugust.Checked);
        AddInvisible('SEPTEMBER').Value:=Integer(CheckBoxSeptember.Checked);
        AddInvisible('OCTOBER').Value:=Integer(CheckBoxOctober.Checked);
        AddInvisible('NOVEMBER').Value:=Integer(CheckBoxNovember.Checked);
        AddInvisible('DECEMBER').Value:=Integer(CheckBoxDecember.Checked);
      end;
      DS.Execute;
      FMeasureTypeGraphsExists:=true;
    finally
      DS.Free;
      Screen.Cursor:=OldCursor;
    end;
  end;                }
end;

procedure TSgtsFunPointManagementForm.ButtonPointObjectClick(
  Sender: TObject);
var
  AIface: TSgtsRbkObjectTreesIface;
  Buffer: String;
begin
  AIface:=TSgtsRbkObjectTreesIface.Create(CoreIntf);
  try
    AIface.IsCanSelect:=false;
    AIface.SelectVisible('OBJECT_ID',FPointObjectId,Buffer,nil,false);
  finally
    AIface.Free;
  end;
end;

procedure TSgtsFunPointManagementForm.TreeDragAllowed(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: Integer; var Allowed: Boolean); 
var
  AUnionType: TSgtsRbkPointManagementIfaceUnionType;
begin
  with Iface do begin
    if DataSet.Active and not DataSet.IsEmpty then begin
      AUnionType:=TSgtsRbkPointManagementIfaceUnionType(DataSet.FieldByName('UNION_TYPE').AsInteger);
      if AUnionType=utPoint then begin
        FDragNode:=Node;
        FDragPointId:=DataSet.FieldByName('UNION_ID').Value;
        Allowed:=Iface.PermissionExists(SPermissionNameUpdate);
      end;
    end;
  end;
end;

function TSgtsFunPointManagementForm.TreeCanWriteToDataSet(Node: PSgtsTreeDBNode): Boolean;
var
  AUnionType: TSgtsRbkPointManagementIfaceUnionType;
begin
  Result:=inherited TreeCanWriteToDataSet(Node);
  if Assigned(Node) then begin
    AUnionType:=TSgtsRbkPointManagementIfaceUnionType(Node.Data);
    Result:=AUnionType in [utRoute,utPoint];
  end;
end;

procedure TSgtsFunPointManagementForm.TreeWritingDataSet(Node: PSgtsTreeDBNode; var Allow: Boolean);

  function GetRouteIdByRouteNode(var Priority: Integer): Variant;
  var
    DS: TSgtsCDS;
  begin
    Result:=NULL;
    DS:=TSgtsCDS.Create(nil);
    try
      DS.AddIndexDef('PRIORITY',tsDesc);
      DS.Data:=Iface.DataSet.Data;
      if DS.Active and not DS.IsEmpty then begin
        DS.SetIndexBySort('PRIORITY',tsDesc);
        if DS.Locate('TREE_ID',Node.Value,[loCaseInsensitive]) then begin
          Result:=DS.FieldByName('UNION_ID').Value;
          DS.Filter:=Format('TREE_PARENT_ID=%s',[QuotedStr(VarToStrDef(Node.Value,''))]);
          DS.Filtered:=true;
          if not DS.IsEmpty then begin
            DS.First;
            Priority:=DS.FieldByName('PRIORITY').AsInteger+1;
          end;
        end;
      end;
    finally
      DS.Free;
    end;
  end;

  function GetRouteIdByPointId(PointId: Variant): Variant;
  var
    DS: TSgtsCDS;
  begin
    Result:=NULL;
    DS:=TSgtsCDS.Create(nil);
    try
      DS.Data:=Iface.DataSet.Data;
      if DS.Active and not DS.IsEmpty then begin
        if DS.Locate('UNION_ID;UNION_TYPE',VarArrayOf([QuotedStr(VarToStrDef(PointId,'')),Integer(utPoint)]),[loCaseInsensitive]) then begin
          Result:=DS.FieldByName('UNION_PARENT_ID').Value;
        end;
      end;
    finally
      DS.Free;
    end;
  end;

  function GetRouteIdByPointNode(var Priority: Integer): Variant;
  var
    DS: TSgtsCDS;
  begin
    Result:=NULL;
    DS:=TSgtsCDS.Create(nil);
    try
      DS.Data:=Iface.DataSet.Data;
      if DS.Active and not DS.IsEmpty then begin
        if DS.Locate('TREE_ID',Node.Value,[loCaseInsensitive]) then begin
          Result:=DS.FieldByName('UNION_PARENT_ID').Value;
          Priority:=DS.FieldByName('PRIORITY').AsInteger;
        end;
      end;
    finally
      DS.Free;
    end;
  end;

var
  AUnionType: TSgtsRbkPointManagementIfaceUnionType;
  DS: TSgtsDatabaseCDS;
  NewRouteId, OldRouteId: Variant;
  ANode: PVirtualNode;
  DBNode: PSgtsTreeDBNode;
  Priority: Integer;
  Progress: Integer;
  Max: Integer;
  OldNode: PVirtualNode;
  F1,F2: String;
begin
  inherited TreeWritingDataSet(Node,Allow);
  if Assigned(Node) and
     Assigned(FDragNode) and
     (Node.Node<>FDragNode) then begin
    AUnionType:=TSgtsRbkPointManagementIfaceUnionType(Node.Data);
    case AUnionType of
      utRoute, utPoint: begin
        if Allow then begin
          DS:=TSgtsDatabaseCDS.Create(CoreIntf);
          F1:=DBEditPointName.DataField;
          F2:=DBMemoPointDesc.DataField;
          try
            DBEditPointName.DataField:='';
            DBMemoPointDesc.DataField:='';
            DS.WaitCursorEnabled:=true;
            DS.ProviderName:=SProviderUpdateRoutePoint;

            Priority:=1;

            if AUnionType=utRoute then
              NewRouteId:=GetRouteIdByRouteNode(Priority)
            else
              NewRouteId:=GetRouteIdByPointNode(Priority);
            OldRouteId:=GetRouteIdByPointId(FDragPointId);

            Iface.DataSet.BeginUpdate(true);
            try
              if AUnionType=utRoute then
                ANode:=Tree.GetFirstChild(Node.Node)
              else begin
                ANode:=Node.Node;
              end;

              with DS.ExecuteDefs do begin
                with AddKeyLink('ROUTE_ID') do begin
                  Value:=OldRouteId;
                  Value:=NewRouteId;
                end;
                AddKeyLink('POINT_ID').Value:=FDragPointId;
                AddInvisible('PRIORITY').Value:=Priority;
              end;
              DS.Execute;

              if DS.ExecuteSuccess then begin
                if Iface.DataSet.Locate('UNION_ID;UNION_TYPE',VarArrayOf([QuotedStr(VarToStrDef(FDragPointId,'')),Integer(utPoint)])) then begin
                  with Iface.DataSet do begin
                    Edit;
                    FieldByName('UNION_PARENT_ID').Value:=NewRouteId;
                    FieldByName('PRIORITY').Value:=Priority;
                    Post;
                  end;
                end;
              end;

              if Assigned(ANode) and
                 DS.ExecuteSuccess and
                 (AUnionType=utPoint) then begin

                OldNode:=ANode;
                Max:=0;
                while Assigned(ANode) do begin
                  if (ANode<>FDragNode) then
                    Inc(Max);
                  ANode:=Tree.GetNextSibling(ANode);
                end;
                ANode:=OldNode;
                
                Progress:=1;
                CoreIntf.MainForm.Progress(0,Max,0);
                try
                  Inc(Priority);
                  while Assigned(ANode) do begin
                    if (ANode<>FDragNode) then begin
                      DBNode:=PSgtsTreeDBNode(Tree.GetDBNodeData(ANode));
                      if Assigned(DBNode) then begin
                        if Iface.DataSet.Locate('TREE_ID',QuotedStr(VarToStrDef(DBNode.Value,''))) then begin
                          with DS.ExecuteDefs do begin
                            FirstState;
                            Find('POINT_ID').Value:=Iface.DataSet.FieldByName('UNION_ID').Value;
                            Find('PRIORITY').Value:=Priority;
                          end;
                          DS.Execute;

                          if DS.ExecuteSuccess then begin
                            with Iface.DataSet do begin
                              Edit;
                              FieldByName('UNION_PARENT_ID').Value:=NewRouteId;
                              FieldByName('PRIORITY').Value:=Priority;
                              Post;
                            end;
                          end;

                        end;
                        Inc(Priority);
                        CoreIntf.MainForm.Progress(0,Max,Progress);
                        Inc(Progress);
                      end;
                    end;
                    ANode:=Tree.GetNextSibling(ANode);
                  end;
                finally
                  CoreIntf.MainForm.Progress(0,0,0);
                end;
              end;
            finally
              Iface.DataSet.EndUpdate(false);
            end;

            Allow:=DS.ExecuteSuccess;
          finally
            DBEditPointName.DataField:=F1;
            DBMemoPointDesc.DataField:=F2;
            DS.Free;
          end;
        end;
      end;
    end;
  end;
end;

function TSgtsFunPointManagementForm.TreeGetAttachMode(Node: PSgtsTreeDBNode): TVTNodeAttachMode;
var
  AUnionType: TSgtsRbkPointManagementIfaceUnionType;
begin
  Result:=inherited TreeGetAttachMode(Node);
  if Assigned(Node) then begin
    AUnionType:=TSgtsRbkPointManagementIfaceUnionType(Node.Data);
    case AUnionType of
      utRoute: Result:=amAddChildLast;
      utPoint: Result:=amInsertBefore;
    end;
  end;
end;

end.


