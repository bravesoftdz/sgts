unit SgtsExecuteDefs;

interface

uses Classes, Contnrs, Controls, StdCtrls, DB,
     rxToolEdit, ComCtrls, CheckLst,
     SgtsIntegerEdit, SgtsFloatEdit, SgtsDateEdit,
     SgtsCoreIntf, SgtsControls, SgtsGetRecordsConfig;

type
  TSgtsControl=class(TControl)
  end;

  TSgtsExecuteDefs=class;

  TSgtsExecuteDefControls=class(TObjectList)
  private
    function GetItems(Index: Integer): TControl;
    procedure SetItems(Index: Integer; Value: TControl);
  public
    constructor Create; reintroduce;
    function Add(Control: TControl): Integer;

    property Items[Index: Integer]: TControl read GetItems write SetItems;
  end;

  TSgtsExecuteDef=class;

  TSgtsExecuteDefOnLinkControlsEvent=procedure (Parent: TWinControl) of object;
  TSgtsExecuteDefOnCheckValueEvent=procedure (Def: TSgtsExecuteDef; var NewValue: Variant; var CanSet: Boolean) of object;

  TSgtsExecuteDef=class(TObject)
  private
    FControls: TSgtsExecuteDefControls;
    FCoreIntf: ISgtsCore;
    FName: String;
    FFieldName: String;
    FCaption: String;
    FRequired: Boolean;
    FDefaultValue: Variant;
    FDataType: TFieldType;
    FParamType: TParamType;
    FIsKey: Boolean;
    FSize: Integer;
    FStoredValue: Variant;
    FExecuteDefs: TSgtsExecuteDefs;
    FKeys: TStringList;
    FTwins: TStringList;
    FOnLinkControls: TSgtsExecuteDefOnLinkControlsEvent;
    FControlsLinked: Boolean;
    FFirstValue: Boolean;
    FOnCheckValue: TSgtsExecuteDefOnCheckValueEvent;
    FFilterGroups: TSgtsGetRecordsConfigFilterGroups;

    function GetControl: TWinControl;
    procedure SetName(Value: String);
  protected
    function GetValue: Variant; virtual;
    procedure SetValue(AValue: Variant); virtual;
    procedure SetDefaultValue(Value: Variant); virtual;
    function GetEmpty: Boolean; virtual;
    function GetSize: Integer; virtual;
    procedure SetSize(Value: Integer); virtual;
    procedure SetExecuteDefs(Value: TSgtsExecuteDefs); virtual;
    function GetKeyValue: Variant; virtual;
    procedure SetKeyValue(Value: Variant); virtual;

    procedure DoCheckValue(var NewValue: Variant; var CanSet: Boolean);

    property ExecuteDefs: TSgtsExecuteDefs read FExecuteDefs write SetExecuteDefs;
    property OnLinkControls: TSgtsExecuteDefOnLinkControlsEvent read FOnLinkControls write FOnLinkControls;
    property ControlsLinked: Boolean read FControlsLinked;
    property FirstValue: Boolean read FFirstValue write FFirstValue;
  public
    constructor Create(ACoreIntf: ISgtsCore); reintroduce; virtual;
    destructor Destroy; override;
    procedure LinkControls(Parent: TWinControl); virtual;
    procedure SetDefault; virtual;
    procedure LoadValueFromStream(Stream: TStream); virtual;
    procedure SaveValueToStream(Stream: TStream); virtual;
    procedure LoadValueFromFile(const FileName: String); virtual;
    procedure SaveValueToFile(const FileName: String); virtual;
    procedure Change(Sender: TObject); virtual;
    procedure FirstState; virtual;

    property CoreIntf: ISgtsCore read FCoreIntf;
    property Name: String read FName write SetName;
    property FieldName: String read FFieldName write FFieldName;
    property Caption: String read FCaption write FCaption;
    property Value: Variant read GetValue write SetValue;
    property DefaultValue: Variant read FDefaultValue write SetDefaultValue;
    property Required: Boolean read FRequired write FRequired;
    property Empty: Boolean read GetEmpty;
    property DataType: TFieldType read FDataType write FDataType;
    property ParamType: TParamType read FParamType write FParamType;
    property IsKey: Boolean read FIsKey write FIsKey;
    property Size: Integer read GetSize write SetSize;
    property StoredValue: Variant read FStoredValue write FStoredValue;
    property KeyValue: Variant read GetKeyValue write SetKeyValue;

    property Control: TWinControl read GetControl;
    property Controls: TSgtsExecuteDefControls read FControls;
    property Keys: TStringList read FKeys;
    property Twins: TStringList read FTwins;
    property FilterGroups: TSgtsGetRecordsConfigFilterGroups read FFilterGroups;

    property OnCheckValue: TSgtsExecuteDefOnCheckValueEvent read FOnCheckValue write FOnCheckValue;
  end;

  TSgtsExecuteDefClass=class of TSgtsExecuteDef;

  TSgtsExecuteDefKey=class(TSgtsExecuteDef)
  private
    FProviderName: String;
    FValue: Variant;
  protected
    function GetValue: Variant; override;
  public
    property ProviderName: String read FProviderName write FProviderName;
  end;

  TSgtsExecuteDefInvisible=class(TSgtsExecuteDef)
  private
    FValue: Variant;
  protected
    function GetValue: Variant; override;
    procedure SetValue(AValue: Variant); override;
  public
    constructor Create(ACoreIntf: ISgtsCore); override;
  end;

  TSgtsExecuteDefValue=class(TSgtsExecuteDefInvisible)
  end;

  TSgtsExecuteDefCalc=class;

  TSgtsExecuteDefCalcProc=function (Def: TSgtsExecuteDefCalc): Variant of object;

  TSgtsExecuteDefCalc=class(TSgtsExecuteDefInvisible)
  private
    FCalcProc: TSgtsExecuteDefCalcProc;
  protected
    function GetValue: Variant; override;
  public
    property CalcProc: TSgtsExecuteDefCalcProc read FCalcProc write FCalcProc;
  end;

  TSgtsExecuteDefKeyLink=class(TSgtsExecuteDefInvisible)
  private
    FKeyValue: Variant;
  protected
    function GetKeyValue: Variant; override;
    procedure SetValue(AValue: Variant); override;
  public
    constructor Create(ACoreIntf: ISgtsCore); override;
  end;

  TSgtsExecuteDefEdit=class(TSgtsExecuteDef)
  private
    FEdit: TEdit;
    FLabelEdit: TLabel;
    FEditName: String;
    FLabelName: String;
    FOldEditChange: TNotifyEvent;

    procedure EditChange(Sender: TObject);
  protected
    function GetValue: Variant; override;
    procedure SetValue(AValue: Variant); override;
    function GetEmpty: Boolean; override;
    function GetSize: Integer; override;
    procedure SetSize(ASize: Integer); override;

    property EditName: String read FEditName write FEditName;
    property LabelName: String read FLabelName write FLabelName;
  public
    procedure LinkControls(Parent: TWinControl); override;

    property Edit: TEdit read FEdit write FEdit;
    property LabelEdit: TLabel read FLabelEdit;
  end;

  TSgtsExecuteDefEditLink=class;

  TSgtsExecuteDefEditLinkOnSelectEvent=procedure (Def: TSgtsExecuteDefEditLink) of object;

  TSgtsExecuteDefEditLink=class(TSgtsExecuteDefInvisible)
  private
    FButton: TButton;
    FButtonName: String;
    FOldButtonClick: TNotifyEvent;
    FOldEditKeyDown: TKeyEvent;
    FLink: TSgtsExecuteDefEdit;
    FRbkClass: TComponentClass;
    FLinkAlias: String;
    FAlias: String;
    FKeyValue: Variant;
    FOnSelect: TSgtsExecuteDefEditLinkOnSelectEvent;

    procedure ButtonClick(Sender: TObject);
    procedure EditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure LinkOnLinkControls(Parent: TWinControl);
  protected
    function GetKeyValue: Variant; override;
    procedure SetValue(AValue: Variant); override;

    property ButtonName: String read FButtonName write FButtonName;
    property LinkAlias: String read FLinkAlias write FLinkAlias;
    property Alias: String read FAlias write FAlias;
    property RbkClass: TComponentClass read FRbkClass write FRbkClass;
  public
    constructor Create(ACoreIntf: ISgtsCore); override;
    destructor Destroy; override;
    procedure LinkControls(Parent: TWinControl); override;
    function Select: Boolean;

    property Button: TButton read FButton;
    property Link: TSgtsExecuteDefEdit read FLink write FLink;
    property FilterGroups;
    property OnSelect: TSgtsExecuteDefEditLinkOnSelectEvent read FOnSelect write FOnSelect;
  end;

  TSgtsExecuteDefMemo=class(TSgtsExecuteDef)
  private
    FMemo: TMemo;
    FLabelMemo: TSgtsControl;
    FMemoName: String;
    FLabelName: String;
    FOldMemoChange: TNotifyEvent;

    procedure MemoChange(Sender: TObject);
  protected
    function GetValue: Variant; override;
    procedure SetValue(AValue: Variant); override;
    function GetEmpty: Boolean; override;
    function GetSize: Integer; override;
    procedure SetSize(ASize: Integer); override;

    property MemoName: String read FMemoName write FMemoName;
    property LabelName: String read FLabelName write FLabelName;
  public
    procedure LinkControls(Parent: TWinControl); override;

    property Memo: TMemo read FMemo;
    property LabelMemo: TSgtsControl read FLabelMemo;
  end;

  TSgtsExecuteDefMemoLink=class;

  TSgtsExecuteDefMemoLinkOnSelectEvent=procedure (Def: TSgtsExecuteDefMemoLink) of object;

  TSgtsExecuteDefMemoLink=class(TSgtsExecuteDefInvisible)
  private
    FButton: TButton;
    FButtonName: String;
    FOldButtonClick: TNotifyEvent;
    FOldMemoKeyDown: TKeyEvent;
    FLink: TSgtsExecuteDefMemo;
    FRbkClass: TComponentClass;
    FLinkAlias: String;
    FAlias: String;
    FKeyValue: Variant;
    FOnSelect: TSgtsExecuteDefMemoLinkOnSelectEvent;

    procedure ButtonClick(Sender: TObject);
    procedure MemoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure LinkOnLinkControls(Parent: TWinControl);
  protected
    function GetKeyValue: Variant; override;
    procedure SetValue(AValue: Variant); override;

    property ButtonName: String read FButtonName write FButtonName;
    property LinkAlias: String read FLinkAlias write FLinkAlias;
    property Alias: String read FAlias write FAlias;
    property RbkClass: TComponentClass read FRbkClass write FRbkClass;
  public
    constructor Create(ACoreIntf: ISgtsCore); override;
    destructor Destroy; override;
    procedure LinkControls(Parent: TWinControl); override;
    function Select: Boolean;

    property Button: TButton read FButton;
    property Link: TSgtsExecuteDefMemo read FLink write FLink;
    property FilterGroups;
    property OnSelect: TSgtsExecuteDefMemoLinkOnSelectEvent read FOnSelect write FOnSelect;
  end;

  TSgtsExecuteDefComboMode=(cmTextByIndex,cmText,cmItemIndex,cmProc);
  TSgtsExecuteDefComboOnSetValueProc=procedure (Sender: TObject; NewValue: Variant) of object;
  TSgtsExecuteDefComboOnGetValueProc=function (Sender: TObject; OldValue: Variant): Variant of object;
  TSgtsExecuteDefComboOnGetEmptyProc=function (Sender: TObject): Boolean of object;

  TSgtsExecuteDefCombo=class(TSgtsExecuteDef)
    FCombo: TComboBox;
    FLabelCombo: TLabel;
    FComboName: String;
    FLabelName: String;
    FMode: TSgtsExecuteDefComboMode;
    FOldComboChange: TNotifyEvent;
    FOnSetValueProc: TSgtsExecuteDefComboOnSetValueProc;
    FOnGetValueProc: TSgtsExecuteDefComboOnGetValueProc;
    FOnGetEmptyProc: TSgtsExecuteDefComboOnGetEmptyProc;

    procedure ComboChange(Sender: TObject);
  protected
    function GetValue: Variant; override;
    procedure SetValue(AValue: Variant); override;
    function GetEmpty: Boolean; override;
    function GetSize: Integer; override;
    procedure SetSize(ASize: Integer); override;

    property ComboName: String read FComboName write FComboName;
    property LabelName: String read FLabelName write FLabelName;
    property OnSetValueProc: TSgtsExecuteDefComboOnSetValueProc read FOnSetValueProc write FOnSetValueProc;
    property OnGetValueProc: TSgtsExecuteDefComboOnGetValueProc read FOnGetValueProc write FOnGetValueProc;
    property OnGetEmptyProc: TSgtsExecuteDefComboOnGetEmptyProc read FOnGetEmptyProc write FOnGetEmptyProc;  
  public
    procedure LinkControls(Parent: TWinControl); override;

    property Combo: TComboBox read FCombo;
    property LabelCombo: TLabel read FLabelCombo;
    property Mode: TSgtsExecuteDefComboMode read FMode write FMode;
  end;

  TSgtsExecuteDefComboLinkValue=class(TObject)
  private
    FNameValue: Variant;
    FKeyValue: Variant;
  public
    property NameValue: Variant read FNameValue write FNameValue;
    property KeyValue: Variant read FKeyValue write FKeyValue;
  end;

  TSgtsExecuteDefComboLinkValues=class(TObjectList)
  private
    function GetItems(Index: Integer): TSgtsExecuteDefComboLinkValue;
    procedure SetItems(Index: Integer; Value: TSgtsExecuteDefComboLinkValue);
  public
    function Add(NameValue,KeyValue: Variant): TSgtsExecuteDefComboLinkValue;
    function Find(KeyValue: Variant): TSgtsExecuteDefComboLinkValue;
    property Items[Index: Integer]: TSgtsExecuteDefComboLinkValue read GetItems write SetItems;
  end;

  TSgtsExecuteDefComboLink=class(TSgtsExecuteDefInvisible)
  private
    FButton: TButton;
    FButtonName: String;
    FOldButtonClick: TNotifyEvent;
    FOldComboChange: TNotifyEvent;
    FLink: TSgtsExecuteDefCombo;
    FRbkClass: TComponentClass;
    FLinkAlias: String;
    FAlias: String;
    FKeyValue: Variant;
    FLinkValues: TSgtsExecuteDefComboLinkValues;
    FEmptyItem: String;
    FAutoFill: Boolean;

    procedure ButtonClick(Sender: TObject);
    procedure ComboChange(Sender: TObject);
    procedure ComboSetValueProc(Sender: TObject; NewValue: Variant);
    function ComboGetValueProc(Sender: TObject; OldValue: Variant): Variant;
    function ComboGetEmptyProc(Sender: TObject): Boolean;
    procedure LinkOnLinkControls(Parent: TWinControl);

  protected
    function GetKeyValue: Variant; override;
    procedure SetValue(AValue: Variant); override;

    property ButtonName: String read FButtonName write FButtonName;
    property LinkAlias: String read FLinkAlias write FLinkAlias;
    property Alias: String read FAlias write FAlias;
    property RbkClass: TComponentClass read FRbkClass write FRbkClass;
  public
    constructor Create(ACoreIntf: ISgtsCore); override;
    destructor Destroy; override;
    procedure LinkControls(Parent: TWinControl); override;
    procedure FillCombo;

    property Button: TButton read FButton;
    property Link: TSgtsExecuteDefCombo read FLink write FLink;
    property AutoFill: Boolean read FAutoFill write FAutoFill;
  end;

  TSgtsExecuteDefDate=class(TSgtsExecuteDef)
  private
    FDateEdit: TSgtsDateEdit;
    FLabelDate: TLabel;
    FDateName: String;
    FLabelName: String;
    FOldDateChange: TNotifyEvent;

    procedure DateChange(Sender: TObject);
    function ReplaceDateTimePicker(DateTimePicker: TDateTimePicker): TSgtsDateEdit;
  protected
    function GetValue: Variant; override;
    procedure SetValue(AValue: Variant); override;
    function GetEmpty: Boolean; override;
    function GetSize: Integer; override;
    procedure SetSize(ASize: Integer); override;

    property DateName: String read FDateName write FDateName;
    property LabelName: String read FLabelName write FLabelName;
  public
    procedure LinkControls(Parent: TWinControl); override;

    property DateEdit: TSgtsDateEdit read FDateEdit;
    property LabelDate: TLabel read FLabelDate;
  end;

  TSgtsExecuteDefEditInteger=class(TSgtsExecuteDefEdit)
  private
    FIntegerEdit: TSgtsIntegerEdit;
    function ReplaceEdit(Edit: TEdit): TSgtsIntegerEdit;
    property Edit;
  public
    procedure LinkControls(Parent: TWinControl); override;

    property IntegerEdit: TSgtsIntegerEdit read FIntegerEdit;
  end;

  TSgtsExecuteDefEditFloat=class(TSgtsExecuteDefEdit)
  private
    FFloatEdit: TSgtsFloatEdit;
    function ReplaceEdit(Edit: TEdit): TSgtsFloatEdit;
    property Edit;
  public
    procedure LinkControls(Parent: TWinControl); override;

    property FloatEdit: TSgtsFloatEdit read FFloatEdit;
  end;

  TSgtsExecuteDefCheck=class(TSgtsExecuteDef)
  private
    FCheckBox: TCheckBox;
    FCheckName: String;
    FOldCheckClick: TNotifyEvent;

    procedure CheckClick(Sender: TObject);
  protected
    function GetValue: Variant; override;
    procedure SetValue(AValue: Variant); override;

    property CheckName: String read FCheckName write FCheckName;
  public
    procedure LinkControls(Parent: TWinControl); override;

    property CheckBox: TCheckBox read FCheckBox;
  end;

  TSgtsExecuteDefComboInteger=class(TSgtsExecuteDefCombo)
  end;

  TSgtsExecuteDefFileName=class(TSgtsExecuteDefEdit)
  private
    FButton: TButton;
    FButtonName: String;
    FOldButtonClick: TNotifyEvent;
    FOldEditKeyDown: TKeyEvent;
    FFilter: String;
    FInitialDir: String;

    procedure ButtonClick(Sender: TObject);
    procedure EditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  protected

    property ButtonName: String read FButtonName write FButtonName;
  public
    procedure LinkControls(Parent: TWinControl); override;

    property Button: TButton read FButton;
    property Filter: String read FFilter write FFilter;
    property InitialDir: String read FInitialDir write FInitialDir;
  end;

  TSgtsExecuteDefButton=class(TSgtsExecuteDefInvisible)
  private
    FButtonName: String;
  protected
    function GetValue: Variant; override;
    procedure SetValue(AValue: Variant); override;

    property ButtonName: String read FButtonName write FButtonName;
  public
    constructor Create(ACoreIntf: ISgtsCore); override;
  end;

  TSgtsExecuteDefs=class(TObjectList)
  private
    FCoreIntf: ISgtsCore;
    FProviderName: String;
    FReturnValue: Variant;
    FOnChange: TNotifyEvent;
    function GetItems(Index: Integer): TSgtsExecuteDef;
    procedure SetItems(Index: Integer; Value: TSgtsExecuteDef);
  protected
    procedure DoChange(Sender: TObject);
  public
    constructor Create(ACoreIntf: ISgtsCore); reintroduce; virtual;
    function Find(const Name: String): TSgtsExecuteDef;
    function FindByFieldName(const FieldName: String): TSgtsExecuteDef;
    function Add(const Name, Caption: String; ExecuteDefClass: TSgtsExecuteDefClass=nil): TSgtsExecuteDef;
    function AddValue(const Name: String; Value: Variant): TSgtsExecuteDefValue;
    function AddKey(const Name: String; ParamType: TParamType=ptInput): TSgtsExecuteDefKey;
    function AddInvisible(const Name: String; ParamType: TParamType=ptInput): TSgtsExecuteDefInvisible;
    function AddCalc(const Name: String; CalcProc: TSgtsExecuteDefCalcProc; ParamType: TParamType=ptInput): TSgtsExecuteDefCalc;
    function AddKeyLink(const Name: String; ParamType: TParamType=ptInput): TSgtsExecuteDefKeyLink;
    function AddEdit(const Name, EditName, LabelName: String; Required: Boolean=false): TSgtsExecuteDefEdit;
    function AddEditLink(const Name, EditName, LabelName, ButtonName: String;
                         ARbkClass: TComponentClass; const LinkName: String;
                         const LinkAlias: String=''; const Alias: String='';
                         Required: Boolean=false; IsKey: Boolean=false): TSgtsExecuteDefEditLink;
    function AddMemo(const Name, MemoName, LabelName: String; Required: Boolean=false): TSgtsExecuteDefMemo;
    function AddMemoLink(const Name, MemoName, LabelName, ButtonName: String;
                         ARbkClass: TComponentClass; const LinkName: String;
                         const LinkAlias: String=''; const Alias: String='';
                         Required: Boolean=false; IsKey: Boolean=false): TSgtsExecuteDefMemoLink;
    function AddCombo(const Name, ComboName, LabelName: String; Required: Boolean=false): TSgtsExecuteDefCombo;
    function AddComboLink(const Name, ComboName, LabelName, ButtonName: String;
                          ARbkClass: TComponentClass; const LinkName: String;
                          const LinkAlias: String=''; const Alias: String='';
                          Required: Boolean=false; IsKey: Boolean=false): TSgtsExecuteDefComboLink;
    function AddDate(const Name, DateName, LabelName: String; Required: Boolean=false): TSgtsExecuteDefDate;
    function AddEditInteger(const Name, EditName, LabelName: String; Required: Boolean=false): TSgtsExecuteDefEditInteger;
    function AddEditFloat(const Name, EditName, LabelName: String; Required: Boolean=false): TSgtsExecuteDefEditFloat;
    function AddCheck(const Name, CheckName: String): TSgtsExecuteDefCheck;
    function AddComboInteger(const Name, ComboName, LabelName: String; Required: Boolean=false): TSgtsExecuteDefComboInteger;
    function AddFileName(const Name, EditName, LabelName, ButtonName, Filter: String;
                         Required: Boolean=false): TSgtsExecuteDefFileName;
    function AddButton(const Name, ButtonName: String): TSgtsExecuteDefButton;

    procedure FirstState;

    property Items[Index: Integer]: TSgtsExecuteDef read GetItems write SetItems;
    property ProviderName: String read FProviderName write FProviderName;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property CoreIntf: ISgtsCore read FCoreIntf write FCoreIntf;

    property ReturnValue: Variant read FReturnValue write FReturnValue;
  end;

function ReplaceEditInteger(Edit: TEdit): TSgtsIntegerEdit;
function ReplaceEditFloat(Edit: TEdit): TSgtsFloatEdit;

implementation

uses Windows, SysUtils, Math, Variants, DateUtils, rxDateUtil, DBClient,
     Dialogs,
     SgtsUtils, SgtsDialogs, SgtsDataFm, SgtsCDS;

function ReplaceEditInteger(Edit: TEdit): TSgtsIntegerEdit;
var
  IntegerEdit: TSgtsIntegerEdit;
  AName: String;
begin
  Result:=nil;
  if Assigned(Edit) then begin
    AName:=Edit.Name;
    IntegerEdit:=TSgtsIntegerEdit.Create(Edit.Owner);
    IntegerEdit.Parent:=Edit.Parent;
    IntegerEdit.Anchors:=Edit.Anchors;
    IntegerEdit.SetBounds(Edit.Left,Edit.Top,Edit.Width,Edit.Height);
    IntegerEdit.TabOrder:=Edit.TabOrder;
    IntegerEdit.Enabled:=Edit.Enabled;
    Edit.Name:='';
    IntegerEdit.Name:=AName;
    IntegerEdit.Text:=Edit.Text;
    IntegerEdit.OnChange:=Edit.OnChange;
    IntegerEdit.MaxLength:=Edit.MaxLength;
    Result:=IntegerEdit;
    Edit.Free;
  end;
end;

function ReplaceEditFloat(Edit: TEdit): TSgtsFloatEdit;
var
  FloatEdit: TSgtsFloatEdit;
  AName: String;
begin
  Result:=nil;
  if Assigned(Edit) then begin
    AName:=Edit.Name;
    FloatEdit:=TSgtsFloatEdit.Create(Edit.Owner);
    FloatEdit.Parent:=Edit.Parent;
    FloatEdit.Anchors:=Edit.Anchors;
    FloatEdit.SetBounds(Edit.Left,Edit.Top,Edit.Width,Edit.Height);
    FloatEdit.TabOrder:=Edit.TabOrder;
    FloatEdit.Enabled:=Edit.Enabled;
    Edit.Name:='';
    FloatEdit.Name:=AName;
    FloatEdit.Text:=Edit.Text;
    FloatEdit.OnChange:=Edit.OnChange;
    FloatEdit.MaxLength:=Edit.MaxLength;
    Result:=FloatEdit;
    Edit.Free;
  end;
end;

{ TSgtsExecuteDefControls }

constructor TSgtsExecuteDefControls.Create;
begin
  inherited Create(false);
end;

function TSgtsExecuteDefControls.Add(Control: TControl): Integer;
begin
  Result:=-1;
  if Assigned(Control) then
    Result:=inherited Add(Control);
end;

function TSgtsExecuteDefControls.GetItems(Index: Integer): TControl;
begin
  Result:=TControl(inherited Items[Index]);
end;

procedure TSgtsExecuteDefControls.SetItems(Index: Integer; Value: TControl);
begin
  inherited Items[Index]:=Value;
end;

{ TSgtsExecuteDef }

constructor TSgtsExecuteDef.Create(ACoreIntf: ISgtsCore);
begin
  inherited Create;
  FCoreIntf:=ACoreIntf;
  FControls:=TSgtsExecuteDefControls.Create;
  FFilterGroups:=TSgtsGetRecordsConfigFilterGroups.Create;
  FDefaultValue:=Null;
  FParamType:=ptInput;
  FKeys:=TStringList.Create;
  FTwins:=TStringList.Create;

  FirstState;
end;

destructor TSgtsExecuteDef.Destroy;
begin
  FTwins.Free;
  FKeys.Free;
  FFilterGroups.Free;
  FControls.Free;
  inherited Destroy;
end;

procedure TSgtsExecuteDef.FirstState;
begin
  FFirstValue:=true;
  FControlsLinked:=false;
end;

function TSgtsExecuteDef.GetValue: Variant;
begin
  Result:=Null;
end;

procedure TSgtsExecuteDef.SetValue(AValue: Variant);
begin
end;

procedure TSgtsExecuteDef.DoCheckValue(var NewValue: Variant; var CanSet: Boolean);
begin
  if Assigned(FOnCheckValue) then
    FOnCheckValue(Self,NewValue,CanSet);
end;

procedure TSgtsExecuteDef.Change(Sender: TObject);
begin
  FExecuteDefs.DoChange(Sender);
end;

procedure TSgtsExecuteDef.LinkControls(Parent: TWinControl); 
begin
  FDefaultValue:=Value;
  FControlsLinked:=true;
  if Assigned(FOnLinkControls) then
    FOnLinkControls(Parent);
end;

function TSgtsExecuteDef.GetEmpty: Boolean;
var
  V: Variant;
begin
  V:=Value;
  Result:=not (VarToStrDef(V,'')<>'');
end;

function TSgtsExecuteDef.GetControl: TWinControl;
begin
  Result:=nil;
  if FControls.Count>0 then
    if FControls.Items[0] is TWinControl then
      Result:=TWinControl(FControls.Items[0]);
end;

procedure TSgtsExecuteDef.SetName(Value: String);
begin
  if FName<>Value then begin
    FName:=Value;
    FFieldName:=Value;
  end;
end;

function TSgtsExecuteDef.GetSize: Integer;
begin
  Result:=FSize;
end;

procedure TSgtsExecuteDef.SetSize(Value: Integer);
begin
  FSize:=Value;
end;

procedure TSgtsExecuteDef.SetDefaultValue(Value: Variant);
begin
  FDefaultValue:=Value;
end;

procedure TSgtsExecuteDef.SetDefault;
begin
  if Value<>DefaultValue then begin
    Value:=DefaultValue;
  end;
end;

procedure TSgtsExecuteDef.SetExecuteDefs(Value: TSgtsExecuteDefs);
begin
  FExecuteDefs:=Value;
end;

function TSgtsExecuteDef.GetKeyValue: Variant;
begin
  Result:=Null;
end;

procedure TSgtsExecuteDef.SetKeyValue(Value: Variant);
begin
end;

procedure TSgtsExecuteDef.LoadValueFromStream(Stream: TStream);
var
  Buffer: String;
begin
  SetLength(Buffer,Stream.Size);
  Stream.Read(Pointer(Buffer)^,Stream.Size);
  Value:=Buffer;
end;

procedure TSgtsExecuteDef.SaveValueToStream(Stream: TStream);
var
  Buffer: String;
begin
  Buffer:=VarToStrDef(Value,'');
  Stream.Write(Pointer(Buffer)^,Length(Buffer));
end;

procedure TSgtsExecuteDef.LoadValueFromFile(const FileName: String);
var
  Stream: TFileStream;
begin
  Stream:=TFileStream.Create(FileName,fmOpenRead or fmShareDenyWrite);
  try
    LoadValueFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TSgtsExecuteDef.SaveValueToFile(const FileName: String);
var
  Stream: TFileStream;
begin
  Stream:=TFileStream.Create(FileName,fmCreate);
  try
    SaveValueToStream(Stream);
  finally
    Stream.Free;
  end;
end;

{ TSgtsExecuteDefKey }

function TSgtsExecuteDefKey.GetValue: Variant;
begin
  Result:=inherited GetValue;
  if FirstValue then begin
    if Assigned(CoreIntf.DatabaseModules.Current) then begin
      with CoreIntf.DatabaseModules.Current do begin
        if Assigned(Database) then
          if Database.Connected then begin
            Result:=Database.GetNewId(FProviderName);
            DefaultValue:=Result;
            FValue:=Result;
            FirstValue:=false;
          end;
      end;
    end;
  end else
    Result:=FValue;
end;

{ TSgtsExecuteDefInvisible }

constructor TSgtsExecuteDefInvisible.Create(ACoreIntf: ISgtsCore);
begin
  inherited Create(ACoreIntf);
  FValue:=Null;
end;

function TSgtsExecuteDefInvisible.GetValue: Variant;
begin
  Result:=FValue;
end;

procedure TSgtsExecuteDefInvisible.SetValue(AValue: Variant);
begin
  FValue:=AValue;
end;

{ TSgtsExecuteDefCalc }

function TSgtsExecuteDefCalc.GetValue: Variant;
begin
  if ControlsLinked then begin
    if Assigned(FCalcProc) then
      Result:=FCalcProc(Self)
    else
      Result:=inherited GetValue;
  end else
    Result:=inherited GetValue;    
end;

{ TSgtsExecuteDefKeyLink }

constructor TSgtsExecuteDefKeyLink.Create(ACoreIntf: ISgtsCore);
begin
  inherited Create(ACoreIntf);
end;

function TSgtsExecuteDefKeyLink.GetKeyValue: Variant;
begin
  Result:=FKeyValue;
end;

procedure TSgtsExecuteDefKeyLink.SetValue(AValue: Variant);
begin
  inherited SetValue(AValue);
  if FirstValue then begin
    FKeyValue:=AValue;
    FirstValue:=false;
  end;
end;

{ TSgtsExecuteDefEdit }

procedure TSgtsExecuteDefEdit.LinkControls(Parent: TWinControl);
begin
  if Assigned(Parent) then begin
    FEdit:=TEdit(Parent.FindComponent(FEditName));
    if Assigned(FEdit) then begin
      if VarIsNull(DefaultValue) then begin
        DefaultValue:=Value;
      end else begin
        SetDefault;
      end;
      FOldEditChange:=FEdit.OnChange;
      FEdit.OnChange:=EditChange;
      FEdit.MaxLength:=inherited GetSize;
      Controls.Add(FEdit);
      FLabelEdit:=TLabel(Parent.FindComponent(FLabelName));
      if Assigned(FLabelEdit) then begin
        Caption:=FLabelEdit.Caption;
        Controls.Add(FLabelEdit);
      end;
    end;
  end;
  inherited LinkControls(Parent);
  if Assigned(FEdit) then begin
  end;
end;

function TSgtsExecuteDefEdit.GetValue: Variant;
begin
  Result:=inherited GetValue;
  if Assigned(FEdit) then
    Result:=iff(FEdit.Text<>'',FEdit.Text,Result);
end;

procedure TSgtsExecuteDefEdit.SetValue(AValue: Variant);
begin
  if Value<>AValue then
    if Assigned(FEdit) then
      FEdit.Text:=VarToStrDef(AValue,'')
    else
      inherited SetValue(Value);
end;

function TSgtsExecuteDefEdit.GetEmpty: Boolean;
begin
  Result:=true;
  if Assigned(FEdit) then
    Result:=FEdit.Text='';
end;

function TSgtsExecuteDefEdit.GetSize: Integer;
begin
  Result:=inherited GetSize;
  if Assigned(FEdit) then
    Result:=FEdit.MaxLength;
end;

procedure TSgtsExecuteDefEdit.SetSize(ASize: Integer);
begin
  if Size<>ASize then
    if Assigned(FEdit) then
      FEdit.MaxLength:=ASize
    else
      inherited SetSize(ASize);
end;

procedure TSgtsExecuteDefEdit.EditChange(Sender: TObject);
begin
  ExecuteDefs.DoChange(Sender);
  if Assigned(FOldEditChange) then
    FOldEditChange(Sender);
end;

{ TSgtsExecuteDefEditLink }

constructor TSgtsExecuteDefEditLink.Create(ACoreIntf: ISgtsCore);
begin
  inherited Create(ACoreIntf);
  FKeyValue:=Null;
end;

destructor TSgtsExecuteDefEditLink.Destroy;
begin
  inherited Destroy;
end;

procedure TSgtsExecuteDefEditLink.LinkControls(Parent: TWinControl);
begin
  if Assigned(Parent) then begin
    if VarIsNull(DefaultValue) then begin
      DefaultValue:=Value;
    end else begin
      SetDefault;
    end;
    FButton:=TButton(Parent.FindComponent(FButtonName));
    if Assigned(FButton) then begin
      FOldButtonClick:=FButton.OnClick;
      FButton.OnClick:=ButtonClick;
      Controls.Add(FButton);
    end;
  end;
  inherited LinkControls(Parent);
  if Assigned(FButton) then begin
  end;
end;

procedure TSgtsExecuteDefEditLink.LinkOnLinkControls(Parent: TWinControl);
begin
  if Assigned(Link) then
    if Assigned(Link.Edit) then begin
      FOldEditKeyDown:=Link.Edit.OnKeyDown;
      Link.Edit.OnKeyDown:=EditKeyDown;
    end;
end;

function TSgtsExecuteDefEditLink.Select: Boolean;
var
  Iface: TSgtsDataIface;
  Buffer: String;
  DataSet: TSgtsCDS;
  Field: TField;
  CanSet: Boolean;
  NewValue: Variant;
begin
  Result:=false;
  if Assigned(FRbkClass) then begin
    if IsClassParent(FRbkClass,TSgtsDataIface) then begin
      Iface:=TSgtsDataIfaceClass(FRbkClass).Create(CoreIntf);
      try
        if Iface.SelectVisible(Alias,Value,Buffer,FilterGroups) then begin
          DataSet:=TSgtsCDS.Create(nil);
          try
            DataSet.XMLData:=Buffer;
            if DataSet.Active then begin
              Field:=DataSet.FindField(Alias);
              if Assigned(Field) then begin
                CanSet:=true;
                NewValue:=Field.Value;
                DoCheckValue(NewValue,CanSet);
                if CanSet then begin
                  Value:=NewValue;
                  if Assigned(Link) then begin
                    Field:=DataSet.FindField(LinkAlias);
                    if Assigned(Field) then
                      Link.Value:=Field.Value;
                  end;
                  Result:=true;
                  if Assigned(FOnSelect) then
                    FOnSelect(Self);
                end;
              end;
            end;
          finally
            DataSet.Free;
          end;
        end;
      finally
        Iface.Free;
      end;
    end;
  end;
end;

procedure TSgtsExecuteDefEditLink.ButtonClick(Sender: TObject);
begin
  Select;
  if Assigned(FOldButtonClick) then
    FOldButtonClick(Sender);
end;

function TSgtsExecuteDefEditLink.GetKeyValue: Variant;
begin
  Result:=FKeyValue;
end;

procedure TSgtsExecuteDefEditLink.SetValue(AValue: Variant);
begin
  inherited SetValue(AValue);
  if FirstValue then begin
    FKeyValue:=AValue;
    FirstValue:=false;
  end;
end;

procedure TSgtsExecuteDefEditLink.EditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Assigned(Link) and Assigned(Link.Edit) then begin
    case Key of
      VK_DELETE, VK_BACK: begin
        if (Shift=[]) and (Link.Edit.SelLength=Length(Link.Edit.Text)) then begin
          if not Required then begin
            Value:=Null;
            Link.Value:=Null;
          end;
        end;
      end;
      VK_UP: begin
        if (Shift=[ssAlt]) then
          if Assigned(FButton) and FButton.Enabled then
            FButton.Click;
      end;
    end;
  end;

  if Assigned(FOldEditKeyDown) then
    FOldEditKeyDown(Sender,Key,Shift);
end;

{ TSgtsExecuteDefMemo }

procedure TSgtsExecuteDefMemo.LinkControls(Parent: TWinControl);
begin
  if Assigned(Parent) then begin
    FMemo:=TMemo(Parent.FindComponent(FMemoName));
    if Assigned(FMemo) then begin
      if VarIsNull(DefaultValue) then begin
        DefaultValue:=Value;
      end else begin
        SetDefault;
      end;
      FOldMemoChange:=FMemo.OnChange;
      FMemo.OnChange:=MemoChange;
      FMemo.MaxLength:=inherited GetSize;
      Controls.Add(FMemo);
      FLabelMemo:=TSgtsControl(Parent.FindComponent(FLabelName));
      if Assigned(FLabelMemo) then begin
        Caption:=FLabelMemo.Caption;
        Controls.Add(FLabelMemo);
      end;
    end;
  end;
  inherited LinkControls(Parent);
  if Assigned(FMemo) then begin
  end;
end;

function TSgtsExecuteDefMemo.GetValue: Variant;
begin
  Result:=inherited GetValue;
  if Assigned(FMemo) then
    Result:=iff(FMemo.Lines.Text<>'',FMemo.Lines.Text,Result);
end;

procedure TSgtsExecuteDefMemo.SetValue(AValue: Variant);
begin
  if Value<>AValue then
    if Assigned(FMemo) then
      FMemo.Lines.Text:=VarToStrDef(AValue,'')
    else
      inherited SetValue(Value);
end;

function TSgtsExecuteDefMemo.GetEmpty: Boolean;
begin
  Result:=true;
  if Assigned(FMemo) then
    Result:=FMemo.Lines.Text='';
end;

function TSgtsExecuteDefMemo.GetSize: Integer;
begin
  Result:=inherited GetSize;
  if Assigned(FMemo) then
    Result:=FMemo.MaxLength;
end;

procedure TSgtsExecuteDefMemo.SetSize(ASize: Integer);
begin
  if Size<>ASize then
    if Assigned(FMemo) then
      FMemo.MaxLength:=ASize
    else
      inherited SetSize(ASize);
end;

procedure TSgtsExecuteDefMemo.MemoChange(Sender: TObject);
begin
  ExecuteDefs.DoChange(Sender);
  if Assigned(FOldMemoChange) then
    FOldMemoChange(Sender);
end;

{ TSgtsExecuteDefMemoLink }

constructor TSgtsExecuteDefMemoLink.Create(ACoreIntf: ISgtsCore);
begin
  inherited Create(ACoreIntf);
  FKeyValue:=Null;
end;

destructor TSgtsExecuteDefMemoLink.Destroy;
begin
  inherited Destroy;
end;

procedure TSgtsExecuteDefMemoLink.LinkControls(Parent: TWinControl);
begin
  if Assigned(Parent) then begin
    if VarIsNull(DefaultValue) then begin
      DefaultValue:=Value;
    end else begin
      SetDefault;
    end;
    FButton:=TButton(Parent.FindComponent(FButtonName));
    if Assigned(FButton) then begin
      FOldButtonClick:=FButton.OnClick;
      FButton.OnClick:=ButtonClick;
      Controls.Add(FButton);
    end;
  end;
  inherited LinkControls(Parent);
  if Assigned(FButton) then begin
  end;
end;

procedure TSgtsExecuteDefMemoLink.LinkOnLinkControls(Parent: TWinControl);
begin
  if Assigned(Link) then
    if Assigned(Link.Memo) then begin
      FOldMemoKeyDown:=Link.Memo.OnKeyDown;
      Link.Memo.OnKeyDown:=MemoKeyDown;
    end;
end;

function TSgtsExecuteDefMemoLink.Select: Boolean;
var
  Iface: TSgtsDataIface;
  Buffer: String;
  DataSet: TSgtsCDS;
  Field: TField;
  CanSet: Boolean;
  NewValue: Variant;
begin
  Result:=false;
  if Assigned(FRbkClass) then begin
    if IsClassParent(FRbkClass,TSgtsDataIface) then begin
      Iface:=TSgtsDataIfaceClass(FRbkClass).Create(CoreIntf);
      try
        if Iface.SelectVisible(Alias,Value,Buffer,FilterGroups) then begin
          DataSet:=TSgtsCDS.Create(nil);
          try
            DataSet.XMLData:=Buffer;
            if DataSet.Active then begin
              Field:=DataSet.FindField(Alias);
              if Assigned(Field) then begin
                CanSet:=true;
                NewValue:=Field.Value;
                DoCheckValue(NewValue,CanSet);
                if CanSet then begin
                  Value:=NewValue;
                  if Assigned(Link) then begin
                    Field:=DataSet.FindField(LinkAlias);
                    if Assigned(Field) then
                      Link.Value:=Field.Value;
                  end;
                  Result:=true;
                  if Assigned(FOnSelect) then
                    FOnSelect(Self);
                end;
              end;
            end;
          finally
            DataSet.Free;
          end;
        end;
      finally
        Iface.Free;
      end;
    end;
  end;
end;

procedure TSgtsExecuteDefMemoLink.ButtonClick(Sender: TObject);
begin
  Select;
  if Assigned(FOldButtonClick) then
    FOldButtonClick(Sender);
end;

function TSgtsExecuteDefMemoLink.GetKeyValue: Variant;
begin
  Result:=FKeyValue;
end;

procedure TSgtsExecuteDefMemoLink.SetValue(AValue: Variant);
begin
  inherited SetValue(AValue);
  if FirstValue then begin
    FKeyValue:=AValue;
    FirstValue:=false;
  end;
end;

procedure TSgtsExecuteDefMemoLink.MemoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Assigned(Link) and Assigned(Link.Memo) then begin
    case Key of
      VK_DELETE, VK_BACK: begin
        if (Shift=[]) and (Link.Memo.SelLength=Length(Link.Memo.Text)) then begin
          if not Required then begin
            Value:=Null;
            Link.Value:=Null;
          end;
        end;
      end;
      VK_UP: begin
        if (Shift=[ssAlt]) then
          if Assigned(FButton) and FButton.Enabled then
            FButton.Click;
      end;
    end;
  end;

  if Assigned(FOldMemoKeyDown) then
    FOldMemoKeyDown(Sender,Key,Shift);
end;

{ TSgtsExecuteDefCombo }

procedure TSgtsExecuteDefCombo.LinkControls(Parent: TWinControl);
begin
  if Assigned(Parent) then begin
    FCombo:=TComboBox(Parent.FindComponent(FComboName));
    if Assigned(FCombo) then begin
      if VarIsNull(DefaultValue) then begin
        DefaultValue:=Value;
      end else begin
        SetDefault;
      end;
      FOldComboChange:=FCombo.OnChange;
      FCombo.OnChange:=ComboChange;
      FCombo.MaxLength:=inherited GetSize;
      Controls.Add(FCombo);
      FLabelCombo:=TLabel(Parent.FindComponent(FLabelName));
      if Assigned(FLabelCombo) then begin
        Caption:=FLabelCombo.Caption;
        Controls.Add(FLabelCombo);             
      end;
    end;
  end;
  inherited LinkControls(Parent);
  if Assigned(FCombo) then begin
  end;
end;

function TSgtsExecuteDefCombo.GetValue: Variant;
begin
  Result:=inherited GetValue;
  if Assigned(FCombo) then
    case FMode of
      cmTextByIndex: Result:=iff(FCombo.ItemIndex<>-1,FCombo.Text,Result);
      cmText: Result:=iff(FCombo.Text<>'',FCombo.Text,Result);
      cmItemIndex: Result:=iff(FCombo.ItemIndex<>-1,FCombo.ItemIndex,Result);
      cmProc: begin
         if Assigned(FOnGetValueProc) then
           Result:=FOnGetValueProc(Self,Result);
      end;

    end;
end;

procedure TSgtsExecuteDefCombo.SetValue(AValue: Variant);
begin
  if Assigned(FCombo) then begin
    case FMode of
      cmTextByIndex: begin
        FCombo.ItemIndex:=FCombo.Items.IndexOf(VarToStrDef(AValue,''));
        ComboChange(FCombo);
      end;
      cmText: FCombo.Text:=VarToStrDef(AValue,'');
      cmItemIndex: begin
        FCombo.ItemIndex:=VarToIntDef(AValue,-1);
        ComboChange(FCombo);
      end;
      cmProc: begin
        if Assigned(FOnSetValueProc) then begin
          FOnSetValueProc(Self,AValue);
          ComboChange(FCombo);
        end;  
      end;
    end;
  end else
    inherited SetValue(Value);
end;

function TSgtsExecuteDefCombo.GetEmpty: Boolean;
begin
  Result:=true;
  if Assigned(FCombo) then
    case FMode of
      cmTextByIndex: Result:=FCombo.ItemIndex=-1;
      cmText: Result:=FCombo.Text='';
      cmItemIndex: Result:=FCombo.ItemIndex=-1;
      cmProc: begin
        if Assigned(FOnGetEmptyProc) then
          Result:=FOnGetEmptyProc(Self);
      end;
    end;
end;

function TSgtsExecuteDefCombo.GetSize: Integer;
begin
  Result:=inherited GetSize;
  if Assigned(FCombo) then
    Result:=FCombo.MaxLength;
end;

procedure TSgtsExecuteDefCombo.SetSize(ASize: Integer);
begin
  if Size<>ASize then
    if Assigned(FCombo) then
      FCombo.MaxLength:=ASize
    else
      inherited SetSize(ASize);
end;

procedure TSgtsExecuteDefCombo.ComboChange(Sender: TObject);
begin
  ExecuteDefs.DoChange(Sender);
  if Assigned(FOldComboChange) then
    FOldComboChange(Sender);
end;

{ TSgtsExecuteDefComboLinkValues }

function TSgtsExecuteDefComboLinkValues.GetItems(Index: Integer): TSgtsExecuteDefComboLinkValue;
begin
  Result:=TSgtsExecuteDefComboLinkValue(inherited Items[Index]);
end;

procedure TSgtsExecuteDefComboLinkValues.SetItems(Index: Integer; Value: TSgtsExecuteDefComboLinkValue);
begin
  inherited Items[Index]:=Value;
end;

function TSgtsExecuteDefComboLinkValues.Add(NameValue,KeyValue: Variant): TSgtsExecuteDefComboLinkValue;
begin
  Result:=TSgtsExecuteDefComboLinkValue.Create;
  Result.NameValue:=NameValue;
  Result.KeyValue:=KeyValue;
  inherited Add(Result);
end;

function TSgtsExecuteDefComboLinkValues.Find(KeyValue: Variant): TSgtsExecuteDefComboLinkValue;
var
  i: Integer;
  Item: TSgtsExecuteDefComboLinkValue;
begin
  Result:=nil;
  for i:=0 to Count-1 do begin
    Item:=Items[i];
    if Item.KeyValue=KeyValue then begin
      Result:=Item;
      exit;
    end;
  end;
end;

{ TSgtsExecuteDefComboLink }

constructor TSgtsExecuteDefComboLink.Create(ACoreIntf: ISgtsCore);
begin
  inherited Create(ACoreIntf);
  FKeyValue:=Null;
  FLinkValues:=TSgtsExecuteDefComboLinkValues.Create;
  FEmptyItem:=' ';
end;

destructor TSgtsExecuteDefComboLink.Destroy;
begin
  FLinkValues.Free;
  inherited Destroy;
end;

procedure TSgtsExecuteDefComboLink.LinkControls(Parent: TWinControl);
begin
  if Assigned(Parent) then begin
    if VarIsNull(DefaultValue) then begin
      DefaultValue:=Value;
    end else begin
      SetDefault;
    end;
    FButton:=TButton(Parent.FindComponent(FButtonName));
    if Assigned(FButton) then begin
      FOldButtonClick:=FButton.OnClick;
      FButton.OnClick:=ButtonClick;
      Controls.Add(FButton);
    end;
  end;
  inherited LinkControls(Parent);
  if Assigned(Button) then begin
  end;
end;

procedure TSgtsExecuteDefComboLink.LinkOnLinkControls(Parent: TWinControl);
begin
  if Assigned(Link) then
    if Assigned(Link.Combo) then begin
      FOldComboChange:=Link.Combo.OnChange;
      Link.Combo.OnChange:=ComboChange;
      Link.DefaultValue:=Link.Value;
      Link.OnSetValueProc:=ComboSetValueProc;
      Link.OnGetValueProc:=ComboGetValueProc;
      Link.OnGetEmptyProc:=ComboGetEmptyProc;
      if FAutoFill then
        FillCombo;
    end;
end;

procedure TSgtsExecuteDefComboLink.FillCombo;
var
  Iface: TSgtsDataIface;
  Buffer: String;
  DataSet: TSgtsCDS;
  Field1, Field2: TField;
begin
  if Assigned(FLink) and
     Assigned(FLink.Combo) then begin
    FLink.Combo.Items.BeginUpdate;
    try
      FLink.Combo.Clear;
      FLinkValues.Clear;
      if not FLink.Required then
        FLink.Combo.Items.Add(FEmptyItem);
      if Assigned(FRbkClass) then begin
        if IsClassParent(FRbkClass,TSgtsDataIface) then begin
          Iface:=TSgtsDataIfaceClass(FRbkClass).Create(CoreIntf);
          try
            if Iface.SelectInvisible(Buffer,FilterGroups) then begin
              DataSet:=TSgtsCDS.Create(nil);
              try
                DataSet.XMLData:=Buffer;
                if DataSet.Active then begin
                  DataSet.First;
                  while not DataSet.Eof do begin
                    Field1:=DataSet.FindField(Alias);
                    Field2:=DataSet.FindField(LinkAlias);
                    if Assigned(Field1) and
                       Assigned(Field2) then begin
                      FLink.Combo.Items.AddObject(Field2.AsString,FLinkValues.Add(Field2.Value,Field1.Value));
                    end;  
                    DataSet.Next;
                  end;
                end;
              finally
                DataSet.Free;
              end;
            end;
          finally
            Iface.Free;
          end;
        end;
      end;
    finally
      FLink.Combo.Items.EndUpdate;
    end;
  end;  
end;

procedure TSgtsExecuteDefComboLink.ButtonClick(Sender: TObject);
var
  Iface: TSgtsDataIface;
  Buffer: String;
  DataSet: TSgtsCDS;
  Field: TField;
begin
  if Assigned(FRbkClass) then begin
    if IsClassParent(FRbkClass,TSgtsDataIface) then begin
      Iface:=TSgtsDataIfaceClass(FRbkClass).Create(CoreIntf);
      try
        if Iface.SelectVisible(Alias,Value,Buffer,FilterGroups) then begin
          FillCombo;
          DataSet:=TSgtsCDS.Create(nil);
          try
            DataSet.XMLData:=Buffer;
            if DataSet.Active then begin
              Field:=DataSet.FindField(Alias);
              if Assigned(Field) then
                Value:=Field.Value;

              if Assigned(Link) then begin
                Field:=DataSet.FindField(LinkAlias);
                if Assigned(Field) then
                  Link.Value:=Field.Value;
              end;
            end;
          finally
            DataSet.Free;
          end;
        end;
      finally
        Iface.Free;
      end;
    end;
  end;

  if Assigned(FOldButtonClick) then
    FOldButtonClick(Sender);
end;

function TSgtsExecuteDefComboLink.GetKeyValue: Variant;
begin
  Result:=FKeyValue;
end;

procedure TSgtsExecuteDefComboLink.SetValue(AValue: Variant);
var
  Index: Integer;
  Obj: TSgtsExecuteDefComboLinkValue;
begin
  inherited SetValue(AValue);
  if FirstValue then begin
    FKeyValue:=AValue;
    FirstValue:=false;
  end;
  if Assigned(FLink) and
     Assigned(FLink.Combo) then begin
    Obj:=FLinkValues.Find(AValue);
    if not Assigned(Obj) then begin
      if FLink.Required then
        FLink.Combo.ItemIndex:=-1
      else FLink.Combo.ItemIndex:=0;
    end else begin
      Index:=FLink.Combo.Items.IndexOfObject(Obj);
      FLink.Combo.ItemIndex:=Index;
    end;
    if Assigned(FOldComboChange) then
      FOldComboChange(FLink.Combo);
  end;
end;

procedure TSgtsExecuteDefComboLink.ComboChange(Sender: TObject);
var
  Index: Integer;
  Obj: TSgtsExecuteDefComboLinkValue;
  CanSet: Boolean;
  NewValue: Variant;
begin
  if Assigned(FLink) and
     Assigned(FLink.Combo) then begin
    Index:=FLink.Combo.ItemIndex;
    if Index<>-1 then begin
      Obj:=TSgtsExecuteDefComboLinkValue(FLink.Combo.Items.Objects[Index]);
      if Assigned(Obj) then begin
        NewValue:=Obj.KeyValue;
        CanSet:=True;
        DoCheckValue(NewValue,CanSet);
        if CanSet then
          Value:=NewValue;
      end;
    end;
  end;   
  if Assigned(FOldComboChange) then
    FOldComboChange(Sender);
end;

procedure TSgtsExecuteDefComboLink.ComboSetValueProc(Sender: TObject; NewValue: Variant);
var
  Index: Integer;
  Obj: TSgtsExecuteDefComboLinkValue;
begin
  if Assigned(FLink) and
     Assigned(FLink.Combo) then begin
    Obj:=FLinkValues.Find(Value);
    Index:=FLink.Combo.Items.IndexOfObject(Obj);
    FLink.Combo.ItemIndex:=Index;
  end;
end;

function TSgtsExecuteDefComboLink.ComboGetValueProc(Sender: TObject; OldValue: Variant): Variant;
var
  Obj: TSgtsExecuteDefComboLinkValue;
begin
  Result:=OldValue;
  if Assigned(FLink) and
     Assigned(FLink.Combo) then begin
    Obj:=FLinkValues.Find(Value);
    if Assigned(Obj) then
      Result:=Obj.NameValue;
  end;
end;

function TSgtsExecuteDefComboLink.ComboGetEmptyProc(Sender: TObject): Boolean;
begin
  Result:=false;
  if Assigned(FLink) and
     Assigned(FLink.Combo) then begin
    if FLink.Required then
      Result:=FLink.Combo.ItemIndex=-1
    else
      Result:=FLink.Combo.ItemIndex<1;
  end;
end;

{ TSgtsExecuteDefDate }

function TSgtsExecuteDefDate.ReplaceDateTimePicker(DateTimePicker: TDateTimePicker): TSgtsDateEdit;
var
  DateEdit: TSgtsDateEdit;
  AName: String;
begin
  Result:=nil;
  if Assigned(DateTimePicker) then begin
    AName:=DateTimePicker.Name;
    DateEdit:=TSgtsDateEdit.Create(DateTimePicker.Owner);
    DateEdit.Parent:=DateTimePicker.Parent;
    DateEdit.Anchors:=DateTimePicker.Anchors;
    DateEdit.SetBounds(DateTimePicker.Left,DateTimePicker.Top,DateTimePicker.Width,DateTimePicker.Height);
    DateEdit.TabOrder:=DateTimePicker.TabOrder;
    DateEdit.Enabled:=DateTimePicker.Enabled;
    DateEdit.Date:=DateTimePicker.Date;
    DateTimePicker.Name:='';
    DateEdit.Name:=AName;
    DateEdit.OnChange:=DateTimePicker.OnChange;
    Result:=DateEdit;
    Controls.Remove(DateTimePicker);
    DateTimePicker.Free;
    Controls.Insert(0,DateEdit);
  end;
end;

procedure TSgtsExecuteDefDate.LinkControls(Parent: TWinControl);
var
  Component: TComponent;
begin
  if Assigned(Parent) then begin
    Component:=Parent.FindComponent(FDateName);
    if Component is TDateTimePicker then
      FDateEdit:=ReplaceDateTimePicker(TDateTimePicker(Component));
    if Assigned(FDateEdit) then begin
      if VarIsNull(DefaultValue) then begin
        DefaultValue:=Value;
      end else begin
        SetDefault;
      end;  
      FDateEdit.MaxLength:=inherited GetSize;
      Controls.Add(FDateEdit);
      FLabelDate:=TLabel(Parent.FindComponent(FLabelName));
      if Assigned(FLabelDate) then begin
        Caption:=FLabelDate.Caption;
        Controls.Add(FLabelDate);
        FLabelDate.FocusControl:=FDateEdit;
      end;
    end;
  end;
  inherited LinkControls(Parent);
  if Assigned(FDateEdit) then begin
    FOldDateChange:=FDateEdit.OnChange;
    FDateEdit.OnChange:=DateChange;
  end;
end;

function TSgtsExecuteDefDate.GetValue: Variant;
begin
  Result:=inherited GetValue;
  if Assigned(FDateEdit) then
    Result:=iff(Empty,Null,DateOf(FDateEdit.Date));
end;

procedure TSgtsExecuteDefDate.SetValue(AValue: Variant);
begin
  if Value<>AValue then
    if Assigned(FDateEdit) then begin
      FDateEdit.Date:=VarToDateDef(AValue,NullDate);
    end else
      inherited SetValue(Value);
end;

function TSgtsExecuteDefDate.GetEmpty: Boolean;
begin
  Result:=true;
  if Assigned(FDateEdit) then
    Result:=DateOf(FDateEdit.Date)=DateOf(NullDate);
end;

function TSgtsExecuteDefDate.GetSize: Integer;
begin
  Result:=inherited GetSize;
  if Assigned(FDateEdit) then
    Result:=FDateEdit.MaxLength;
end;

procedure TSgtsExecuteDefDate.SetSize(ASize: Integer);
begin
  if Size<>ASize then
    if Assigned(FDateEdit) then
      FDateEdit.MaxLength:=ASize
    else
      inherited SetSize(ASize);
end;

procedure TSgtsExecuteDefDate.DateChange(Sender: TObject);
begin
  ExecuteDefs.DoChange(Sender);
  if Assigned(FOldDateChange) then
    FOldDateChange(Sender);
end;

{ TSgtsExecuteDefEditInteger }

function TSgtsExecuteDefEditInteger.ReplaceEdit(Edit: TEdit): TSgtsIntegerEdit;
begin
  Result:=nil;
  if Assigned(Edit) then begin
    Controls.Remove(Edit);
    Result:=ReplaceEditInteger(Edit);
    Controls.Insert(0,Result);
  end;
end;

procedure TSgtsExecuteDefEditInteger.LinkControls(Parent: TWinControl);
begin
  inherited LinkControls(Parent);
  if Assigned(Edit) then begin
    FIntegerEdit:=ReplaceEdit(Edit);
    Edit:=TEdit(FIntegerEdit);
    if Assigned(FLabelEdit) then
      FLabelEdit.FocusControl:=Edit;
  end;  
end;

{ TSgtsExecuteDefEditFloat }

function TSgtsExecuteDefEditFloat.ReplaceEdit(Edit: TEdit): TSgtsFloatEdit;
begin
  Result:=nil;
  if Assigned(Edit) then begin
    Controls.Remove(Edit);
    Result:=ReplaceEditFloat(Edit);
    Controls.Insert(0,Result);
  end;
end;

procedure TSgtsExecuteDefEditFloat.LinkControls(Parent: TWinControl);
begin
  inherited LinkControls(Parent);
  if Assigned(Edit) then begin
    FFloatEdit:=ReplaceEdit(Edit);
    Edit:=TEdit(FFloatEdit);
    if Assigned(FLabelEdit) then
      FLabelEdit.FocusControl:=Edit;
  end;
end;

{ TSgtsExecuteDefCheck }

procedure TSgtsExecuteDefCheck.LinkControls(Parent: TWinControl);
begin
  if Assigned(Parent) then begin
    FCheckBox:=TCheckBox(Parent.FindComponent(FCheckName));
    if Assigned(FCheckBox) then begin
      if VarIsNull(DefaultValue) then begin
        DefaultValue:=Value;
      end else begin
        SetDefault;
      end;
      FOldCheckClick:=FCheckBox.OnClick;
      FCheckBox.OnClick:=CheckClick;
      Controls.Add(FCheckBox);
    end;
  end;
  inherited LinkControls(Parent);
end;

function TSgtsExecuteDefCheck.GetValue: Variant;
begin
  Result:=inherited GetValue;
  if Assigned(FCheckBox) then
    Result:=Integer(FCheckBox.Checked);
end;

procedure TSgtsExecuteDefCheck.SetValue(AValue: Variant);
begin
  if Value<>AValue then
    if Assigned(FCheckBox) then
      FCheckBox.Checked:=Boolean(VarToIntDef(AValue,0))
    else
      inherited SetValue(Value);
end;

procedure TSgtsExecuteDefCheck.CheckClick(Sender: TObject);
begin
  ExecuteDefs.DoChange(Sender);
  if Assigned(FOldCheckClick) then
    FOldCheckClick(Sender);
end;

{ TSgtsExecuteDefFileName }

procedure TSgtsExecuteDefFileName.LinkControls(Parent: TWinControl);
begin
  if Assigned(Parent) then begin
    if VarIsNull(DefaultValue) then begin
      DefaultValue:=Value;
    end else begin
      SetDefault;
    end;
    FButton:=TButton(Parent.FindComponent(FButtonName));
    if Assigned(FButton) then begin
      FOldButtonClick:=FButton.OnClick;
      FButton.OnClick:=ButtonClick;
    end;
  end;
  inherited LinkControls(Parent);
  if Assigned(Edit) then begin
    FOldEditKeyDown:=Edit.OnKeyDown;
    Edit.OnKeyDown:=EditKeyDown;
  end;
  if Assigned(FButton) then begin
    Controls.Add(FButton);
  end;
end;

procedure TSgtsExecuteDefFileName.ButtonClick(Sender: TObject);
var
  OpenDialog: TOpenDialog;
  CanSet: Boolean;
  NewValue: Variant;
begin
  if Assigned(Edit) then begin
    OpenDialog:=TOpenDialog.Create(nil);
    try
      OpenDialog.InitialDir:=FInitialDir;
      OpenDialog.Filter:=FFilter;
      OpenDialog.FileName:=VarToStrDef(Value,'');
      if OpenDialog.Execute then begin
        CanSet:=true;
        NewValue:=OpenDialog.FileName;
        DoCheckValue(NewValue,CanSet);
        if CanSet then
          Value:=NewValue;
      end;
    finally
      OpenDialog.Free;
    end;
  end;
  if Assigned(FOldButtonClick) then
    FOldButtonClick(Sender);
end;

procedure TSgtsExecuteDefFileName.EditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_UP: begin
      if (Shift=[ssAlt]) then
        if Assigned(FButton) and FButton.Enabled then
          FButton.Click;
    end;
  end;

  if Assigned(FOldEditKeyDown) then
    FOldEditKeyDown(Sender,Key,Shift);
end;

{ TSgtsExecuteDefButton }

constructor TSgtsExecuteDefButton.Create(ACoreIntf: ISgtsCore);
begin
  inherited Create(ACoreIntf);
end;

function TSgtsExecuteDefButton.GetValue: Variant;
begin

end;

procedure TSgtsExecuteDefButton.SetValue(AValue: Variant);
begin

end;

{ TSgtsExecuteDefs }

constructor TSgtsExecuteDefs.Create(ACoreIntf: ISgtsCore);
begin
  inherited Create(true);
  FCoreIntf:=ACoreIntf;
end;

function TSgtsExecuteDefs.GetItems(Index: Integer): TSgtsExecuteDef;
begin
  Result:=TSgtsExecuteDef(inherited Items[Index]);
end;

procedure TSgtsExecuteDefs.SetItems(Index: Integer; Value: TSgtsExecuteDef);
begin
  inherited Items[Index]:=Value;
end;

procedure TSgtsExecuteDefs.DoChange(Sender: TObject);
begin
  if Assigned(FOnChange) then
    FOnChange(Sender);
end;

function TSgtsExecuteDefs.Find(const Name: String): TSgtsExecuteDef;
var
  i: Integer;
begin
  Result:=nil;
  for i:=0 to Count-1 do begin
    If AnsiSameText(Items[i].Name,Name) then begin
      Result:=Items[i];
      exit;
    end;
  end;
end;

function TSgtsExecuteDefs.FindByFieldName(const FieldName: String): TSgtsExecuteDef;
var
  i,j: Integer;
  Def: TSgtsExecuteDef;
begin
  Result:=nil;
  for i:=0 to Count-1 do begin
    Def:=Items[i];
    If AnsiSameText(Def.FieldName,FieldName) then begin
      Result:=Def;
      exit;
    end else begin
      for j:=0 to Def.Twins.Count-1 do begin
        if AnsiSameText(Def.Twins[j],FieldName) then begin
          Result:=Def;
          exit;
        end;
      end;
    end;
  end;
end;

function TSgtsExecuteDefs.Add(const Name, Caption: String; ExecuteDefClass: TSgtsExecuteDefClass=nil): TSgtsExecuteDef;
begin
  Result:=nil;
  if not Assigned(Find(Name)) then begin
    if not Assigned(ExecuteDefClass) then
      Result:=TSgtsExecuteDef.Create(FCoreIntf)
    else
      Result:=ExecuteDefClass.Create(FCoreIntf);
    Result.ExecuteDefs:=Self;
    Result.Name:=Name;
    inherited Add(Result);
  end;
end;

function TSgtsExecuteDefs.AddValue(const Name: String; Value: Variant): TSgtsExecuteDefValue;
begin
  Result:=TSgtsExecuteDefValue(Add(Name,'',TSgtsExecuteDefValue));
  if Assigned(Result) then begin
    Result.Value:=Value;
    Result.ParamType:=ptInput;
  end;
end;

function TSgtsExecuteDefs.AddKey(const Name: String; ParamType: TParamType=ptInput): TSgtsExecuteDefKey;
begin
  Result:=TSgtsExecuteDefKey(Add(Name,'',TSgtsExecuteDefKey));
  if Assigned(Result) then begin
    Result.ProviderName:=FProviderName;
    Result.DataType:=ftString;
    Result.ParamType:=ParamType;
  end;
end;

function TSgtsExecuteDefs.AddInvisible(const Name: String; ParamType: TParamType=ptInput): TSgtsExecuteDefInvisible;
begin
  Result:=TSgtsExecuteDefInvisible(Add(Name,'',TSgtsExecuteDefInvisible));
  if Assigned(Result) then
    Result.ParamType:=ParamType;
end;

function TSgtsExecuteDefs.AddCalc(const Name: String; CalcProc: TSgtsExecuteDefCalcProc; ParamType: TParamType=ptInput): TSgtsExecuteDefCalc;
begin
  Result:=TSgtsExecuteDefCalc(Add(Name,'',TSgtsExecuteDefCalc));
  if Assigned(Result) then begin
    Result.CalcProc:=CalcProc;
    Result.ParamType:=ParamType;
  end;
end;

function TSgtsExecuteDefs.AddKeyLink(const Name: String; ParamType: TParamType=ptInput): TSgtsExecuteDefKeyLink;
begin
  Result:=TSgtsExecuteDefKeyLink(Add(Name,'',TSgtsExecuteDefKeyLink));
  if Assigned(Result) then begin
    Result.IsKey:=true;
    Result.Keys.Add(Name);
    Result.ParamType:=ParamType;
  end;
end;

function TSgtsExecuteDefs.AddEdit(const Name, EditName, LabelName: String; Required: Boolean): TSgtsExecuteDefEdit;
begin
  Result:=TSgtsExecuteDefEdit(Add(Name,'',TSgtsExecuteDefEdit));
  if Assigned(Result) then begin
    Result.EditName:=EditName;
    Result.LabelName:=LabelName;
    Result.Required:=Required;
    Result.DataType:=ftString;
  end;
end;

function TSgtsExecuteDefs.AddEditLink(const Name, EditName, LabelName, ButtonName: String;
                                      ARbkClass: TComponentClass; const LinkName: String;
                                      const LinkAlias: String=''; const Alias: String='';
                                      Required: Boolean=false; IsKey: Boolean=false): TSgtsExecuteDefEditLink;
begin
  Result:=TSgtsExecuteDefEditLink(Add(Name,'',TSgtsExecuteDefEditLink));
  if Assigned(Result) then begin
    Result.IsKey:=IsKey;
    if IsKey then
      Result.Keys.Add(Name);
    Result.ButtonName:=ButtonName;
    Result.RbkClass:=ARbkClass;
    Result.DataType:=ftString;
    if Trim(LinkAlias)<>'' then
      Result.LinkAlias:=LinkAlias
    else Result.LinkAlias:=LinkName;
    if Trim(Alias)<>'' then
      Result.Alias:=Alias
    else Result.Alias:=Name;

    Result.Link:=AddEdit(LinkName,EditName,LabelName,Required);
    if Assigned(Result.Link) then begin
      Result.Link.ParamType:=ptUnknown;
      Result.Link.OnLinkControls:=Result.LinkOnLinkControls;
    end;
  end;
end;

function TSgtsExecuteDefs.AddMemo(const Name, MemoName, LabelName: String; Required: Boolean): TSgtsExecuteDefMemo;
begin
  Result:=TSgtsExecuteDefMemo(Add(Name,'',TSgtsExecuteDefMemo));
  if Assigned(Result) then begin
    Result.MemoName:=MemoName;
    Result.LabelName:=LabelName;
    Result.Required:=Required;
    Result.DataType:=ftString;
  end;
end;

function TSgtsExecuteDefs.AddMemoLink(const Name, MemoName, LabelName, ButtonName: String;
                                      ARbkClass: TComponentClass; const LinkName: String;
                                      const LinkAlias: String=''; const Alias: String='';
                                      Required: Boolean=false; IsKey: Boolean=false): TSgtsExecuteDefMemoLink;
begin
  Result:=TSgtsExecuteDefMemoLink(Add(Name,'',TSgtsExecuteDefMemoLink));
  if Assigned(Result) then begin
    Result.IsKey:=IsKey;
    if IsKey then
      Result.Keys.Add(Name);
    Result.ButtonName:=ButtonName;
    Result.RbkClass:=ARbkClass;
    Result.DataType:=ftString;
    if Trim(LinkAlias)<>'' then
      Result.LinkAlias:=LinkAlias
    else Result.LinkAlias:=LinkName;
    if Trim(Alias)<>'' then
      Result.Alias:=Alias
    else Result.Alias:=Name;

    Result.Link:=AddMemo(LinkName,MemoName,LabelName,Required);
    if Assigned(Result.Link) then begin
      Result.Link.ParamType:=ptUnknown;
      Result.Link.OnLinkControls:=Result.LinkOnLinkControls;
    end;
  end;
end;

function TSgtsExecuteDefs.AddCombo(const Name, ComboName, LabelName: String; Required: Boolean=false): TSgtsExecuteDefCombo;
begin
  Result:=TSgtsExecuteDefCombo(Add(Name,'',TSgtsExecuteDefCombo));
  if Assigned(Result) then begin
    Result.ComboName:=ComboName;
    Result.LabelName:=LabelName;
    Result.Required:=Required;
    Result.DataType:=ftString;
  end;
end;

function TSgtsExecuteDefs.AddComboLink(const Name, ComboName, LabelName, ButtonName: String;
                                       ARbkClass: TComponentClass; const LinkName: String;
                                       const LinkAlias: String=''; const Alias: String='';
                                       Required: Boolean=false; IsKey: Boolean=false): TSgtsExecuteDefComboLink;
begin
  Result:=TSgtsExecuteDefComboLink(Add(Name,'',TSgtsExecuteDefComboLink));
  if Assigned(Result) then begin
    Result.IsKey:=IsKey;
    if IsKey then
      Result.Keys.Add(Name);
    Result.ButtonName:=ButtonName;
    Result.RbkClass:=ARbkClass;
    Result.DataType:=ftString;
    if Trim(LinkAlias)<>'' then
      Result.LinkAlias:=LinkAlias
    else Result.LinkAlias:=LinkName;
    if Trim(Alias)<>'' then
      Result.Alias:=Alias
    else Result.Alias:=Name;

    Result.Link:=AddCombo(LinkName,ComboName,LabelName,Required);
    if Assigned(Result.Link) then begin
      Result.Link.ParamType:=ptUnknown;
      Result.Link.OnLinkControls:=Result.LinkOnLinkControls;
      Result.Link.Mode:=cmProc;
    end;
  end;
end;

function TSgtsExecuteDefs.AddDate(const Name, DateName, LabelName: String; Required: Boolean=false): TSgtsExecuteDefDate;
begin
  Result:=TSgtsExecuteDefDate(Add(Name,'',TSgtsExecuteDefDate));
  if Assigned(Result) then begin
    Result.DateName:=DateName;
    Result.LabelName:=LabelName;
    Result.Required:=Required;
    Result.DataType:=ftDate;
  end;
end;

function TSgtsExecuteDefs.AddEditInteger(const Name, EditName, LabelName: String; Required: Boolean=false): TSgtsExecuteDefEditInteger;
begin
  Result:=TSgtsExecuteDefEditInteger(Add(Name,'',TSgtsExecuteDefEditInteger));
  if Assigned(Result) then begin
    Result.EditName:=EditName;
    Result.LabelName:=LabelName;
    Result.Required:=Required;
    Result.DataType:=ftInteger;
  end;
end;

function TSgtsExecuteDefs.AddEditFloat(const Name, EditName, LabelName: String; Required: Boolean=false): TSgtsExecuteDefEditFloat;
begin
  Result:=TSgtsExecuteDefEditFloat(Add(Name,'',TSgtsExecuteDefEditFloat));
  if Assigned(Result) then begin
    Result.EditName:=EditName;
    Result.LabelName:=LabelName;
    Result.Required:=Required;
    Result.DataType:=ftFloat;
  end;
end;

function TSgtsExecuteDefs.AddCheck(const Name, CheckName: String): TSgtsExecuteDefCheck;
begin
  Result:=TSgtsExecuteDefCheck(Add(Name,'',TSgtsExecuteDefCheck));
  if Assigned(Result) then begin
    Result.CheckName:=CheckName;
    Result.Required:=true;
    Result.DataType:=ftInteger;
  end;
end;

function TSgtsExecuteDefs.AddComboInteger(const Name, ComboName, LabelName: String; Required: Boolean=false): TSgtsExecuteDefComboInteger;
begin
  Result:=TSgtsExecuteDefComboInteger(Add(Name,'',TSgtsExecuteDefComboInteger));
  if Assigned(Result) then begin
    Result.ComboName:=ComboName;
    Result.LabelName:=LabelName;
    Result.Required:=Required;
    Result.DataType:=ftString;
    Result.Mode:=cmItemIndex;
  end;
end;

function TSgtsExecuteDefs.AddFileName(const Name, EditName, LabelName, ButtonName, Filter: String;
                                      Required: Boolean=false): TSgtsExecuteDefFileName;
begin
  Result:=TSgtsExecuteDefFileName(Add(Name,'',TSgtsExecuteDefFileName));
  if Assigned(Result) then begin
    Result.EditName:=EditName;
    Result.LabelName:=LabelName;
    Result.ButtonName:=ButtonName;
    Result.Filter:=Filter;
    Result.Required:=Required;
  end;
end;

function TSgtsExecuteDefs.AddButton(const Name, ButtonName: String): TSgtsExecuteDefButton;
begin
  Result:=TSgtsExecuteDefButton(Add(Name,'',TSgtsExecuteDefButton));
  if Assigned(Result) then begin
    Result.ButtonName:=ButtonName;
  end;
end;

procedure TSgtsExecuteDefs.FirstState;
var
  i: Integer;
begin
  for i:=0 to Count-1 do begin
    Items[i].FirstState;
  end;
end;

end.
