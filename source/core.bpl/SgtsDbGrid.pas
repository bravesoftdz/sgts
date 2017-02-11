unit SgtsDbGrid;

interface

uses Windows, SysUtils, Messages, Classes, Controls, Forms, StdCtrls,
     Graphics, Grids, DBCtrls, DbGrids, Db, Menus, ImgList, Themes,
     SgtsSelectDefs;

type

  TSgtsDbGrid=class;

  TSgtsGridColumn=class(TColumn)
  private
    FDef: TSgtsSelectDef;
  public
    destructor Destroy; override;

    property Def: TSgtsSelectDef read FDef write FDef;
  end;

  TRowSelected=class(TPersistent)
    private
      FFont: TFont;
      FBrush: TBrush;
      FPen: TPen;
      FGrid: TSgtsDbGrid;
      FVisible: Boolean;
      FUnSelectedBrushColor: TColor;
      FUnSelectedFontColor: TColor;
      FSearchColor: TColor;
      procedure SetFont(Value: TFont);
      procedure SetBrush(Value: TBrush);
      procedure SetPen(Value: TPen);
      procedure SetVisible(Value: Boolean);
    public
      constructor Create(AOwner: TSgtsDbGrid);
      destructor Destroy;override;
    published
      property Font: TFont read FFont write SetFont;
      property Brush: TBrush read FBrush write SetBrush;
      property Pen: Tpen read Fpen write SetPen;
      property Visible: Boolean read FVisible write SetVisible;
      property UnSelectedBrushColor: TColor read FUnSelectedBrushColor write FUnSelectedBrushColor;
      property UnSelectedFontColor: TColor read FUnSelectedFontColor write FUnSelectedFontColor;
      property SearchColor: Tcolor read FSearchColor write FSearchColor;
  end;


  TSelectedCell=class(TCollectionItem)
   private
    FFont: TFont;
    FBrush: TBrush;
    FPen: TPen;
    FFieldValues: TStringList;
    FFieldNames:TStringList;
    FVisible: Boolean;
    procedure SetFont(Value: TFont);
    procedure SetBrush(Value: TBrush);
    procedure SetPen(Value: TPen);
    procedure SetFieldValues(Value: TStringList);
    procedure SetFieldNames(Value: TStringList);
    procedure SetVisible(Value: Boolean);
   public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
   published
    property Font: TFont read FFont write SetFont;
    property Brush: TBrush read FBrush write SetBrush;
    property Pen: Tpen read FPen write SetPen;
    property FieldValues: TStringList read FFieldValues write SetFieldValues;
    property FieldNames: TStringList read FFieldNames write SetFieldNames;
    property Visible: Boolean read FVisible write SetVisible;
  end;

  TSelCellClass=class of TSelectedCell;

  TSelectedCells=class(TCollection)
  private
    FGrid: TSgtsDbGrid;
    function GetSelCell(Index: Integer): TSelectedCell;
    procedure SetSelCell(Index: Integer; Value: TSelectedCell);
  protected
    function GetOwner: TPersistent; override;
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(Grid: TSgtsDbGrid; SelCellClass: TSelCellClass);
    function  Add: TSelectedCell;
    property Grid: TSgtsDbGrid read FGrid;
    property Items[Index: Integer]: TSelectedCell read GetSelCell write SetSelCell; default;
  end;

  TSgtsDbGridDataLink = class(TGridDataLink)
  private
    FOnDataSetScrolled: TNotifyEvent;
  protected
    procedure DataSetScrolled(Distance: Integer); override;
  public
    property OnDataSetScrolled: TNotifyEvent read FOnDataSetScrolled write FOnDataSetScrolled;
  end;

  TTypeColumnSort=(tcsNone,tcsAsc,tcsDesc);
  TOnTitleClickWithSort=procedure(Column: TColumn; TypeSort: TTypeColumnSort)of object;
  TOnGetBrushColor=function(Sender: TObject; Column: TColumn): TColor of object;
  TOnGetFontColor=function(Sender: TObject; Column: TColumn; var FontStyles: TFontStyles): TColor of object;


  TSgtsDbGrid=class(TCustomDBGrid)
  private
    FColumnSortEnabled: Boolean;
    NotSetLocalWidth: Boolean;
    FMultiSelect: Boolean;
    FOldGridState: TGridState;
    OldCell: TGridCoord;
    FTitleX,FTitleY: Integer;
    FTitleMouseDown: Boolean;
    FRowSelected: TRowSelected;
    FTitleCellMouseDown: TRowSelected;
    FCellSelected: TRowSelected;
    FSelectedCells: TSelectedCells;
    FRowSizing: Boolean;
    FRowHeight: Integer;
    FColumnSort: TColumn;
    FListColumnSort: TList;
    FOnTitleClickWithSort: TOnTitleClickWithSort;
    FImageList: TImageList;
    FTitleClickInUse: Boolean;
    FVisibleRowNumber: Boolean;
    FNewDefaultRowHeight : Integer;
    FColumnSortColor: TColor;
    FOldColumnSortColor: TColor;
    FLocateEnabled: Boolean;
    FLocateValue: string;
    FLocateVisible: Boolean;
    FColumnLocate: TColumn;
    FOnGetBrushColor: TOnGetBrushColor;
    FOnGetFontColor: TOnGetFontColor;
    FInplaceEdit: TInplaceEditList;
//    FOnCreateEditor: TNotifyEvent;
    FAutoFit: Boolean;
    FStopAutoFitColumns: Boolean;
    FStopSetWidthRowNumber: Boolean;
    FLock: TRTLCriticalSection;
    procedure ClearListColumnSort;
    procedure SetColumnSort(Column: TColumn);
    procedure SetRowSelected(Value: TRowSelected);
    procedure SetCellSelected(Value: TRowSelected);
    procedure SetSelectedCells(Value: TSelectedCells);
    procedure SetTitleCellMouseDown(Value: TRowSelected);
    procedure SetRowSizing(Value: Boolean);
    procedure SetRowHeight(Value: Integer);
    procedure SetMultiSelect(Value: Boolean);
    procedure SetColumnSortEnabled(Value: Boolean);
    procedure SetVisibleRowNumber(Value: Boolean);
    procedure SetWidthRowNumber(NewRow: Integer);
    function GetRealTopRow(NewRow: Integer): Integer;
    procedure SetDefaultRowHeight(Value: Integer);
    function GetMinRowHeight: Integer;
    function GetDefaultRowHeight: Integer;
    function GetTypeColumnSortEx: TTypeColumnSort;
    procedure SetTypeColumnSortEx(Value: TTypeColumnSort);
    procedure GetColumnsDefsWidth(var ColumnsWidth,DefsWidth: Integer);
    procedure SetColMoving(Value: Boolean);
    function GetColMoving: Boolean;
    function GetOptions: TDBGridOptions;
    procedure SetOptions(Value: TDBGridOptions);
    procedure DataSetScrolled(Sender: TObject);
  protected
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    function GetFontColor(Column: TColumn; var FontStyles: TFontStyles): TColor;
    function GetBrushColor(Column: TColumn): TColor;
    function  CreateEditor: TInplaceEdit; override;
    procedure Resize; override;
    function CreateDataLink: TGridDataLink; override;

  public
    DrawRow,CurrentRow: Integer;
    constructor Create(AOwner: TComponent);override;
    destructor Destroy;override;
    procedure DrawCell(ACol, ARow: Longint; ARect: TRect; AState: TGridDrawState); override;
    procedure DrawDataCell(const Rect: TRect; Field: TField;
      State: TGridDrawState); override;
    procedure DrawColumnCell(const Rect: TRect; DataCol: Integer;
      Column: TColumn; State: TGridDrawState); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    property Canvas;
    property SelectedRows;
    procedure WMMouseWheel(var Message: TWMMouseWheel);message WM_MOUSEWHEEL;
    procedure WMSetFocus(var Msg: TWMSetFocus); message WM_SETFOCUS;
    procedure WMVScroll(var Message: TWMVScroll); message WM_VSCROLL;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    function GetShortString(w: integer; str,text: string): string;
    procedure WriteTextEx(ARow,ACol: Integer; rt: Trect; Alignment: TAlignment; Text: String ; DX,DY: Integer;
                          var TextW: Integer; TextWidthMinus: Integer=0);
    procedure TitleClick(Column: TColumn); override;
    procedure DblClick;override;
    procedure CalcSizingState(X, Y: Integer;
                              var State: TGridState; var Index, SizingPos, SizingOfs: Integer;
                               var FixedInfo: TGridDrawInfo);override;
    function GetTypeColumnSort(Column: TColumn): TTypeColumnSort;
    procedure SetTypeColumnSort(Column: TColumn; TypeSort: TTypeColumnSort);
    procedure DrawSort(Canvas: TCanvas; ARect: TRect; TypeSort: TTypeColumnSort);
    procedure ClearColumnSort;
    procedure SetColumnAttributes; override;
    procedure Scroll(Distance: Integer); override;
    procedure TopLeftChanged; override;
    procedure SetEditText(ACol, ARow: Longint; const Value: string);override;
    function GetEditText(ACol, ARow: Longint): string;override;
    function SelectCell(ACol, ARow: Longint): Boolean;override;
    procedure TimedScroll(Direction: TGridScrollDirection);override;
    procedure RowHeightsChanged; override;
    procedure LayoutChanged; override;
    procedure ColumnMoved(FromIndex, ToIndex: Longint); override;
    procedure DefaultDrawRowCellSelected(const Rect: TRect; DataCol: Integer;
                                               Column: TColumn; State: TGridDrawState);
    procedure UpdateRowNumber;
    procedure DoTitleClickWithSort(Column: TColumn; TypeSort: TTypeColumnSort); virtual;
    function FindColumn(const FieldName: string): TColumn;
    procedure AutoFitColumns;
    procedure AutoSizeColumn(Column: TColumn);
    procedure AutoSizeColumns;
    function GetColumnsStr: String;
    procedure SetColumnsStr(Value: String);

    property ColumnSort: TColumn read FColumnSort write SetColumnSort;
    property ColumnSortEnabled: Boolean read FColumnSortEnabled write SetColumnSortEnabled;
    property ColumnSortType: TTypeColumnSort read GetTypeColumnSortEx write SetTypeColumnSortEx;
    property ColumnSortColor: TColor read FColumnSortColor write FColumnSortColor;
    property ColumnLocate: TColumn read FColumnLocate write FColumnLocate;
    property LocateEnabled: Boolean read FLocateEnabled write FLocateEnabled;
    property LocateValue: string read FLocateValue write FLocateValue;
    property InplaceEdit: TInplaceEditList read FInplaceEdit;

  published
    property Align;
    property AutoFit: Boolean read FAutoFit write FAutoFit;
    property Anchors;
    property BiDiMode;
    property BorderStyle;
    property Color;
    property Columns stored False; //StoreColumns;
    property Constraints;
    property Ctl3D;
    property DataSource;
    property DefaultDrawing;
    property DefaultRowHeight: Integer read GetDefaultRowHeight write SetDefaultRowHeight;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property FixedColor;
    property FixedCols;
    property Font;
    property ImeMode;
    property ImeName;
    property Options: TDBGridOptions read GetOptions write SetOptions;
    property MultiSelect: Boolean read FMultiSelect write SetMultiSelect;
    property ParentBiDiMode;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly;
    property RowSelected: TRowSelected read FRowSelected write SetRowSelected;
    property CellSelected: TRowSelected read FCellSelected write SetCellSelected;
    property ColMoving: Boolean read GetColMoving write SetColMoving;
    property TitleCellMouseDown: TRowSelected read FTitleCellMouseDown write SetTitleCellMouseDown;
    property TitleMouseDown: Boolean read FTitleMouseDown;
    property RowSizing: Boolean read FRowSizing write SetRowSizing;
    property RowHeight: Integer read FRowHeight write SetRowHeight;
    property ShowHint;
    property SelectedCells: TSelectedCells read FSelectedCells write SetSelectedCells;
    property TabOrder;
    property TabStop;
    property TitleFont;
    property Visible;
    property VisibleRowNumber: Boolean read FVisibleRowNumber write SetVisibleRowNumber;
    property OnCellClick;
    property OnColEnter;
    property OnColExit;
    property OnColumnMoved;
    property OnDrawDataCell;  { obsolete }
    property OnDrawColumnCell;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEditButtonClick;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
    property OnTitleClick;
    property OnTitleClickWithSort: TOnTitleClickWithSort read FOnTitleClickWithSort write FOnTitleClickWithSort;
    property OnGetBrushColor: TOnGetBrushColor read FOnGetBrushColor write FOnGetBrushColor;
    property OnGetFontColor: TOnGetFontColor read FOnGetFontColor write FOnGetFontColor;
//    property OnCreateEditor: TNotifyEvent read FOnCreateEditor write FOnCreateEditor;
  end;

{$R *.res}

procedure CreateColumnsBySelectDefs(Columns: TDBGridColumns; SelectDefs: TSgtsSelectDefs);
procedure UpdateColumnsBySelectDefs(Columns: TDBGridColumns; SelectDefs: TSgtsSelectDefs);
procedure CreateGridColumnsBySelectDefs(Grid: TSgtsDbGrid; SelectDefs: TSgtsSelectDefs);
procedure UpdateGridColumnsBySelectDefs(Grid: TSgtsDbGrid; SelectDefs: TSgtsSelectDefs);
procedure CopyGridColumns(InColumns, OutColumns: TDBGridColumns);

implementation

uses SgtsUtils, Variants;

procedure CreateColumnsBySelectDefs(Columns: TDBGridColumns; SelectDefs: TSgtsSelectDefs);
var
  i: Integer;
  Column: TSgtsGridColumn;
  ADef: TSgtsSelectDef;
begin
  Columns.Clear;
  with SelectDefs do
    for i:=0 to Count-1 do begin
      ADef:=Items[i];
      if Trim(ADef.Caption)<>'' then begin
        Column:=TSgtsGridColumn.Create(Columns);
        with Column do begin
          Def:=ADef;
          Title.Caption:=ADef.Caption;
          FieldName:=ADef.Name;
          Visible:=ADef.Visible;
          case ADef.FieldKind of
            fkCalculated: FieldName:=ADef.Name;
          end;
          case ADef.Alignment of
            daLeft: Alignment:=taLeftJustify;
            daRight: Alignment:=taRightJustify;
            daCenter: Alignment:=taCenter;
          end;
          if ADef.Width>0 then
            Width:=ADef.Width
          else
            if ADef.Width=0 then begin
              Width:=50;
              ADef.Width:=50;
            end;
        end;
      end;
    end;
end;

procedure UpdateColumnsBySelectDefs(Columns: TDBGridColumns; SelectDefs: TSgtsSelectDefs);
var
  i: Integer;
  ADef: TSgtsSelectDef;
  AColumns: TDbGridColumns;
  Column: TSgtsGridColumn;
begin
  Columns.BeginUpdate;
  AColumns:=TDbGridColumns.Create(nil,TColumn);
  try
    AColumns.Assign(Columns);
    Columns.Clear;
    for i:=0 to AColumns.Count-1 do begin
      ADef:=SelectDefs.Find(AColumns[i].FieldName);
      if Assigned(ADef) then begin
        Column:=TSgtsGridColumn.Create(Columns);
        Column.Assign(AColumns[i]);
        Column.Def:=ADef;
      end;
    end;
  finally
    AColumns.Free;
    Columns.EndUpdate;
  end;
end;

procedure CreateGridColumnsBySelectDefs(Grid: TSgtsDbGrid; SelectDefs: TSgtsSelectDefs);
begin
  CreateColumnsBySelectDefs(Grid.Columns,SelectDefs);
end;

procedure UpdateGridColumnsBySelectDefs(Grid: TSgtsDbGrid; SelectDefs: TSgtsSelectDefs);
begin
  UpdateColumnsBySelectDefs(Grid.Columns,SelectDefs);
end;

procedure CopyGridColumns(InColumns, OutColumns: TDBGridColumns);
var
  i: Integer;
  InColumn: TColumn;
  OutColumn: TColumn;
begin
  if Assigned(InColumns) and
     Assigned(OutColumns) then begin
    OutColumns.BeginUpdate;
    try
      OutColumns.Clear;
      for i:=0 to InColumns.Count-1 do begin
        InColumn:=InColumns[i];
        if InColumn is TSgtsGridColumn then begin
          OutColumn:=TSgtsGridColumn.Create(OutColumns);
          OutColumn.Assign(InColumn);
          TSgtsGridColumn(OutColumn).Def:=TSgtsGridColumn(InColumn).Def;
          TSgtsGridColumn(OutColumn).Def:=TSgtsGridColumn(OutColumn).Def;
        end else begin
          if InColumn is TColumn then begin
            OutColumn:=TColumn.Create(OutColumns);
            OutColumn.Assign(InColumn);
          end;
        end;
      end;
    finally
      OutColumns.EndUpdate;
    end;
  end;
end;

const
   DefaultVisibleRowNumber=60;
   DefaultVisibleRowNumberCaption='�';

type
  TTempGrid=class(TCustomGrid)
    public
      property Options;
  end;

  PInfoColumnSort=^TInfoColumnSort;
  TInfoColumnSort=packed record
    Column: TColumn;
    TypeColumnSort: TTypeColumnSort;
  end;

{ TSgtsGridColumn }

destructor TSgtsGridColumn.Destroy;
begin
  FDef:=nil;
  inherited Destroy;
end;
  
{ TRowSelected }

constructor TRowSelected.Create(AOwner: TSgtsDbGrid);
begin
  FGrid:=AOwner;
  FFont:=TFont.Create;
  FBrush:=TBrush.Create;
  FPen:=Tpen.Create;
  FVisible:=false;
end;

destructor TRowSelected.Destroy;
begin
  FFont.Free;
  FBrush.Free;
  FPen.Free;
end;

procedure TRowSelected.SetFont(Value: TFont);
begin
  if Value<>FFont then begin
    FFont.Assign(Value);
    FGrid.DefaultDrawing:=true;
    FGrid.InvalidateRow(FGrid.row);
  end;
end;

procedure TRowSelected.SetBrush(Value: TBrush);
begin
  if Value<>FBrush then begin
    FBrush.Assign(Value);
    FGrid.DefaultDrawing:=true;
    FGrid.InvalidateRow(FGrid.row);
  end;
end;

procedure TRowSelected.SetPen(Value: TPen);
begin
  if Value<>Fpen then begin
    FPen.Assign(Value);
    FGrid.DefaultDrawing:=true;
    FGrid.InvalidateRow(FGrid.row);
  end;
end;

procedure TRowSelected.SetVisible(Value: Boolean);
begin
  if Value<>FVisible then begin
    FVisible:=Value;
    FGrid.DefaultDrawing:=true;
    FGrid.InvalidateRow(FGrid.row);
  end;
end;

{ TSelectedCell }


constructor TSelectedCell.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FFont := TFont.Create;
  FBrush:= TBrush.Create;
  Fpen:=TPen.Create;
  FFieldValues:=TStringList.Create;
  FFieldNames:=TStringList.Create;
  FVisible:=true;
end;

destructor TSelectedCell.Destroy;
begin
  FFont.Free;
  FBrush.Free;
  FPen.Free;
  FFieldValues.Free;
  FFieldNames.Free;
  inherited Destroy;
end;

procedure TSelectedCell.SetBrush(Value: TBrush);
begin
  FBrush.Assign(Value);
end;

procedure TSelectedCell.SetPen(Value: TPen);
begin
  Fpen.Assign(value);
end;

procedure TSelectedCell.SetFont(Value: TFont);
begin
  if Value<>FFont then
   FFont.Assign(Value);
end;

procedure TSelectedCell.SetFieldValues(Value: TStringList);
begin
   FFieldValues.Assign(Value);
end;

procedure TSelectedCell.SetFieldNames(Value: TStringList);
begin
   FFieldNames.Assign(Value);
end;

procedure TSelectedCell.SetVisible(Value: Boolean);
begin
  if Value<>FVisible then
   FVisible:=Value;
end;


{ TSelectedCells }

constructor TSelectedCells.Create(Grid: TSgtsDbGrid; SelCellClass: TSelCellClass);
begin
  inherited Create(SelCellClass);
  FGrid := Grid;
end;

function TSelectedCells.GetSelCell(Index: Integer): TSelectedCell;
begin
  Result := TSelectedCell(inherited Items[Index]);
end;

procedure TSelectedCells.SetSelCell(Index: Integer; Value: TSelectedCell);
begin
  Items[Index].Assign(Value);
end;

function TSelectedCells.GetOwner: TPersistent;
begin
  Result := FGrid;
end;

procedure TSelectedCells.Update(Item: TCollectionItem);
begin
  if (FGrid = nil) or (csLoading in FGrid.ComponentState) then Exit;
end;

function TSelectedCells.Add: TSelectedCell;
begin
  Result := TSelectedCell(inherited Add);
end;

{ TSgtsDbGridDataLink }

procedure TSgtsDbGridDataLink.DataSetScrolled(Distance: Integer);
begin
  inherited DataSetScrolled(Distance);
  if Assigned(FOnDataSetScrolled) then
    FOnDataSetScrolled(Self);               
end;

{ TSgtsDbGrid }

constructor TSgtsDbGrid.Create(AOwner: TComponent);
var
  bmp,AndMask: TBitmap;
begin

  FColumnSortEnabled:=true;

  FRowSelected:=TRowSelected.Create(Self);
  FCellSelected:=TRowSelected.Create(Self);
  FSelectedCells:=TSelectedCells.Create(self,TSelectedCell);
  FTitleCellMouseDown:=TRowSelected.Create(Self);


  FTitleCellMouseDown.Visible:=true;
  FTitleCellMouseDown.Brush.Color:=clBtnface;
  FRowSelected.Visible:=true;
  FRowSelected.Brush.Style:=bsSolid;
  FRowSelected.Brush.Color:=clInfoBk;
  FRowSelected.Font.Color:=clBlack;
  FRowSelected.Pen.Style:=psClear;
  FRowSelected.UnSelectedBrushColor:=clInfoBk;
  FRowSelected.UnSelectedFontColor:=clWindowText;
  FCellSelected.Visible:=true;
  FCellSelected.Brush.Color:=clHighlight;
  FCellSelected.Font.Color:=clHighlightText;
  FCellSelected.Pen.Style:=psClear;
  FCellSelected.UnSelectedBrushColor:=clBtnShadow;
  FCellSelected.UnSelectedFontColor:=clHighlightText;
  FCellSelected.SearchColor:=clRed;


  FColumnSort:=nil;
  FListColumnSort:=TList.Create;
  FImageList:=TImageList.Create(nil);

  bmp:=TBitmap.Create;
  AndMask:=TBitmap.Create;
  try
    bmp.LoadFromResourceName(HINSTANCE,'SORTDESC');
    AndMask.Assign(bmp);
    AndMask.Mask(clTeal);
    FImageList.Width:=bmp.Width;
    FImageList.Height:=bmp.Height;
    FImageList.Add(bmp,AndMask);
    bmp.LoadFromResourceName(HINSTANCE,'SORTASC');
    AndMask.Assign(bmp);
    AndMask.Mask(clTeal);
    FImageList.Add(bmp,AndMask);
  finally
    AndMask.Free;
    bmp.free;
  end;


  Options:=Options-[dgEditing]-[dgTabs];

  ReadOnly:=true;

  inherited Create(AOwner);

  ParentFont:=true;

  InitializeCriticalSection(FLock);

  colwidths[0]:=IndicatorWidth;

  FRowSelected.Visible:=true;
  FVisibleRowNumber:=false;
  FRowSelected.Font.Assign(Font);
  FRowSelected.Brush.Style:=bsClear;
  FRowSelected.Brush.Color:=clInfoBk;
  FRowSelected.Font.Color:=clBlack;
  FRowSelected.Pen.Style:=psClear;
  FCellSelected.Font.Assign(Font);
  FCellSelected.Visible:=true;
  FCellSelected.Brush.Color:=clHighlight;
  FCellSelected.Font.Color:=clWindow;
  FTitleCellMouseDown.Font.Assign(Font);
  FColumnSortColor:=clInfoBk;
  RowSizing:=true;
  ReadOnly:=true;
  ColMoving:=true;

  TSgtsDbGridDataLink(DataLink).OnDataSetScrolled:=DataSetScrolled;

end;

destructor TSgtsDbGrid.Destroy;
begin

  ClearListColumnSort;
  FreeAndNil(FListColumnSort);
  FreeAndNil(FImageList);
  FreeAndNil(FSelectedCells);
  FreeAndNil(FCellSelected);
  FreeAndNil(FRowSelected);
  FreeAndNil(FTitleCellMouseDown);

  DeleteCriticalSection(FLock);

  inherited;
end;

procedure TSgtsDbGrid.SetRowSelected(Value: TRowSelected);
begin
  FRowSelected.Assign(Value);
end;

procedure TSgtsDbGrid.SetCellSelected(Value: TRowSelected);
begin
  FCellSelected.Assign(Value);
end;

procedure TSgtsDbGrid.SetSelectedCells(Value: TSelectedCells);
begin
  FSelectedCells.Assign(Value);
end;

procedure TSgtsDbGrid.SetTitleCellMouseDown(Value: TRowSelected);
begin
  FTitleCellMouseDown.Assign(Value);
end;

function TSgtsDbGrid.GetShortString(w: integer; str,text: string): string;
   var
     i: Integer;
     tmps: string;
     neww: Integer;
   begin
    result:=text;
    for i:=1 to Length(text) do begin
      tmps:=tmps+text[i];
      neww:=Canvas.TextWidth(tmps+str);
      if neww>=(w-Canvas.TextWidth(str)) then begin
       result:=tmps+str;
       exit;
      end;
    end;
end;

procedure TSgtsDbGrid.WriteTextEx(ARow,ACol: Integer; rt: Trect; Alignment: TAlignment; Text: String ; DX,DY: Integer;
                                 var TextW: Integer; TextWidthMinus: Integer=0);
var
     Left_: INteger;
     newstr: string;
     strx: integer;
   begin
     with Canvas do begin
        Brush.Style:=bsClear;
        case Alignment of
          taLeftJustify:
            Left_ := rt.Left + DX;
           taRightJustify:
            Left_ := rt.Right - TextWidth(Text) -3;
           else
            Left_ := rt.Left + (rt.Right - rt.Left) shr 1 - (TextWidth(Text) shr 1);
         end;
         newstr:=Text;
       //  if ARow<>Row then begin
          strx:=TextWidth(text);
          if strx>=ColWidths[ACol]-TextWidthMinus-1 then begin
            newstr:=GetShortString(ColWidths[ACol]-TextWidthMinus,'...',text);
          end;
       //  end;

         TextRect(rt, Left_, rt.Top + DY, newstr);
         TextW:=TextWidth(newstr);
     end;
end;

procedure TSgtsDbGrid.DrawSort(Canvas: TCanvas; ARect: TRect; TypeSort: TTypeColumnSort);
var
//  w,h: Integer;
  x,y: Integer;
begin
  with Canvas do begin
{    w:=(Arect.Right-Arect.Left) div 2;
    h:=(Arect.Bottom-Arect.Top) div 3;}
    x:=Arect.Left;
    y:=Arect.Top;
    Brush.Style:=bsSolid;
    Pen.Style:=psSolid;
    Pen.Color:=clBlack;
    case TypeSort of
      tcsNone:;
      tcsAsc: begin
{        MoveTo(x+w div 2,y+h);
        LineTo(x+w+w div 2,y+h);
        LineTo(x+w,y+2*h);
        LineTo(x+w div 2,y+h);}
        FImageList.Draw(Canvas,x,y,0);
      end;
      tcsDesc: begin
{        MoveTo(x+w,y+h);
        LineTo(x+w+w div 2,y+2*h);
        LineTo(x+w div 2,y+2*h);
        LineTo(x+w,y+h);}
        FImageList.Draw(Canvas,x,y,1);
      end;
    end;
  end;
end;

procedure TSgtsDbGrid.DefaultDrawRowCellSelected(const Rect: TRect; DataCol: Integer;
                                               Column: TColumn; State: TGridDrawState);
{var
  Rect: TRect;}


   procedure DrawRowCellSelected;
   var
    OldBrush: TBrush;
    OldFont: TFont;
    OldPen: Tpen;
//    cl: TColumn;
//    fl: TField;
    i: Integer;
    ACol: Integer;
    Rect1: TRect;
   begin
     OldBrush:=TBrush.Create;
     OldFont:=TFont.Create;
     OldPen:=Tpen.Create;
     try
      OldBrush.Assign(Canvas.Brush);
      OldFont.Assign(Canvas.Font);
      OldPen.Assign(Canvas.Pen);
       with Canvas do begin
        if FRowSelected.Visible then begin
          Font.Assign(FRowSelected.Font);
          Brush.Assign(FRowSelected.Brush);
          Pen.Assign(FRowSelected.Pen);
          for i:=IndicatorOffset to ColCount-1 do begin
            ACol:=i;
            Rect1:=CellRect(ACol,Row);
            Brush.Color:=clBlack;
            Fillrect(Rect1);
{            if (Columns.Count>=ACol)and(ACol>=IndicatorOffset) then begin
            cl:=Columns.Items[ACol-IndicatorOffset];
             if cl<>nil then begin
              Font.Name:=cl.Font.Name;
              fl:=cl.Field;
              if fl<>nil then
                WriteTextEx(Row,ACol,Rect1,cl.Alignment,fl.DisplayText,2,2);
             end;
            end;}
          end;
{          Pen.Assign(FRowSelected.Pen);
          Rectangle(rect);
          DefaultDrawing:=False;}
        end; // end of FRowSelected.Visible
{        if FCellSelected.Visible then begin
         for i:=0 to ColCount-1 do begin
           ACol:=i;
           if ACol=Col then begin
            Font.Assign(FCellSelected.Font);
            Brush.Assign(FCellSelected.Brush);
            Pen.Assign(FCellSelected.Pen);
            Fillrect(Rect);
            if (Columns.Count>=Col)and(Col>=IndicatorOffset) then begin
             cl:=Columns.Items[Col-IndicatorOffset];
             if cl<>nil then begin
              Font.Name:=cl.Font.Name;
              fl:=cl.Field;
              if fl<>nil then
               WriteTextEx(Row,Col,Rect,cl.Alignment,fl.DisplayText,2,2);
             end;
            end;
            Pen.Assign(FCellSelected.Pen);
            Rectangle(rect);
            if Focused then  Windows.DrawFocusRect(Handle, Rect);
            DefaultDrawing:=False;
            exit;
           end;
         end;
        end;// end of FCellSelected.Visible}
       end; // end of with canvas
      finally
       Canvas.Brush.Assign(OldBrush);
       OldBrush.Free;
       Canvas.Font.Assign(OldFont);
       OldFont.Free;
       Canvas.Pen.Assign(OldPen);
       OldPen.Free;
      end;
   end;

begin
//  Rect:=BoxRect(IndicatorOffset,Row,ColCount,Row);
 // DrawRowCellSelected;
end;

procedure TSgtsDbGrid.DrawCell(ACol, ARow: Longint; ARect: TRect; AState: TGridDrawState);

   procedure DrawRowCellSelected;
   var
    OldBrush: TBrush;
    OldBrushColor: TColor;
    OldFont: TFont;
    OldPen: Tpen;
    cl: TColumn;
    fl: TField;
    TextW: Integer;
    w: Integer;
    s: string;
    NewRect: TRect;
     ADef: Boolean;
     OldActive: Integer;
     ABrushColor: Tcolor;
     AFontColor: TColor;
     AFontStyles: TFontStyles;
   begin
     OldBrush:=TBrush.Create;
     OldFont:=TFont.Create;
     OldPen:=Tpen.Create;
     try
      OldBrush.Assign(Canvas.Brush);
      OldFont.Assign(Canvas.Font);
      OldPen.Assign(Canvas.Pen);
      if (Arow=Row) then begin
       with Canvas do begin
        if FRowSelected.Visible then begin
         Font.Assign(FRowSelected.Font);
         Brush.Assign(FRowSelected.Brush);
         Pen.Assign(FRowSelected.Pen);
         if not Focused then begin
           Brush.Color:=FRowSelected.UnSelectedBrushColor;
           Font.Color:=FRowSelected.UnSelectedFontColor;
         end;
         Fillrect(ARect);
         if (Columns.Count>=ACol)and(ACol>=IndicatorOffset) then begin
          cl:=Columns.Items[ACol-IndicatorOffset];
          if cl<>nil then begin
           Font.Name:=cl.Font.Name;
           Font.Style:=cl.Font.Style;
           fl:=cl.Field;
           if (Trim(FLocateValue)<>'') and FLocateVisible and
             Assigned(fl) and
             Assigned(FColumnLocate) and
             (FColumnLocate.Field=fl) then begin
            OldBrushColor:=Brush.Color;
            try
              AFontStyles:=Canvas.Font.Style;
              GetFontColor(cl,AFontStyles);
              Canvas.Font.Style:=AFontStyles;
              Brush.Color:=FRowSelected.SearchColor;
              s:=Copy(fl.DisplayText,1,Length(FLocateValue));
              w:=Canvas.TextWidth(s);
              if w>0 then begin
                NewRect:=ARect;
                case cl.Alignment of
                  taLeftJustify: NewRect.Right:=NewRect.Left+w+2;
                  taRightJustify: begin
                    NewRect.Left:=NewRect.Right-Canvas.TextWidth(fl.DisplayText)-3;
                    NewRect.Right:=NewRect.Left+w+2;
                  end;
                end;

                FillRect(NewRect);
              end;
            finally
              Brush.Color:=OldBrushColor;
            end;
           end;
           if fl<>nil then begin
             AFontStyles:=Canvas.Font.Style;
             GetFontColor(cl,AFontStyles);
             Canvas.Font.Style:=AFontStyles;
             WriteTextEx(ARow,ACol,ARect,cl.Alignment,fl.DisplayText,2,2,TextW);
           end;  
          end;
         end;
         Pen.Assign(FRowSelected.Pen);
         Rectangle(Arect);
         DefaultDrawing:=False;
        end; // end of FRowSelected.Visible
        if FCellSelected.Visible then begin
         if ACol=Col then begin
          Font.Assign(FCellSelected.Font);
          Brush.Assign(FCellSelected.Brush);
          Pen.Assign(FCellSelected.Pen);
          if not Focused then begin
            Brush.Color:=FCellSelected.UnSelectedBrushColor;
            Font.Color:=FCellSelected.UnSelectedFontColor;
          end;
          Fillrect(ARect);
          if (Columns.Count>=ACol)and(ACol>=IndicatorOffset) then begin
           cl:=Columns.Items[ACol-IndicatorOffset];
           if cl<>nil then begin
            Font.Name:=cl.Font.Name;
            Font.Style:=cl.Font.Style;
            fl:=cl.Field;
            if (Trim(FLocateValue)<>'') and FLocateVisible and 
               Assigned(fl) and
               Assigned(FColumnLocate) and
               (FColumnLocate.Field=fl) then begin
              OldBrushColor:=Brush.Color;
              try
                Brush.Color:=FCellSelected.SearchColor;
                AFontStyles:=Canvas.Font.Style;
                GetFontColor(cl,AFontStyles);
                Canvas.Font.Style:=AFontStyles;
                s:=Copy(fl.DisplayText,1,Length(FLocateValue));
                w:=Canvas.TextWidth(s);
                if w>0 then begin
                  NewRect:=ARect;
                  case cl.Alignment of
                    taLeftJustify: NewRect.Right:=NewRect.Left+w+2;
                    taRightJustify: begin
                      NewRect.Left:=NewRect.Right-Canvas.TextWidth(fl.DisplayText)-3;
                      NewRect.Right:=NewRect.Left+w+2;
                    end;
                  end;
                  FillRect(NewRect);
                end;
              finally
                Brush.Color:=OldBrushColor;
              end;
            end;
            if fl<>nil then begin
              AFontStyles:=Canvas.Font.Style;
              GetFontColor(cl,AFontStyles);
              Canvas.Font.Style:=AFontStyles;
              WriteTextEx(ARow,ACol,ARect,cl.Alignment,fl.DisplayText,2,2,TextW);
            end;  
           end;
          end;
          Pen.Assign(FCellSelected.Pen);
          Rectangle(Arect);
          if Focused then begin
            Windows.DrawFocusRect(Handle, ARect);
          end;
          DefaultDrawing:=False;
         end;
        end;// end of FCellSelected.Visible
       end; // end of with canvas
      end else begin
        ADef:=true;
        OldActive := DataLink.ActiveRecord;
        try
          if not (gdFixed in AState) and
                 (Columns.Count>=ACol) and
                 (Acol>=IndicatorOffset) and
                 (ARow>0) then begin
            DataLink.ActiveRecord := ARow-1;
            cl:=Columns.Items[ACol-IndicatorOffset];
            if Assigned(cl) then begin
              if not cl.Showing then Exit;
              fl:=cl.Field;
              if Assigned(Fl) then begin
                ABrushColor:=GetBrushColor(cl);
                AFontStyles:=Canvas.Font.Style;
                AFontColor:=GetFontColor(cl,AFontStyles);
                Canvas.Font:=Cl.Font;
                Canvas.Font.Style:=AFontStyles;
                Canvas.Brush.Color:=Cl.Color;
                Canvas.FillRect(ARect);
                Canvas.Brush.Color:=ABrushColor;
                Canvas.FillRect(ARect);
                Canvas.Font.Color:=AFontColor;
                WriteTextEx(ARow,ACol,ARect,cl.Alignment,fl.DisplayText,2,2,TextW);
                ADef:=false;
              end;
            end;
          end;
        finally
          DataLink.ActiveRecord := OldActive;
        end;
        DefaultDrawing:=ADef;
      end;
      finally
       Canvas.Brush.Assign(OldBrush);
       OldBrush.Free;
       Canvas.Font.Assign(OldFont);
       OldFont.Free;
       Canvas.Pen.Assign(OldPen);
       OldPen.Free;
      end;
   end;

   procedure DrawRowCellSelectedNoRecord;
   var
    OldBrush: TBrush;
    OldFont: TFont;
    OldPen: Tpen;
   begin
     OldBrush:=TBrush.Create;
     OldFont:=TFont.Create;
     OldPen:=Tpen.Create;
     try
      OldBrush.Assign(Canvas.Brush);
      OldFont.Assign(Canvas.Font);
      OldPen.Assign(Canvas.Pen);
      if (Arow=Row) then begin
       with Canvas do begin
        if FRowSelected.Visible then begin
{         Font.Assign(FRowSelected.Font);
         Brush.Assign(FRowSelected.Brush);
         Pen.Assign(FRowSelected.Pen);}
         Fillrect(ARect);
{         Pen.Assign(FRowSelected.Pen);
         Rectangle(Arect);}
         DefaultDrawing:=False;
        end; // end of FRowSelected.Visible}
        if FCellSelected.Visible then begin
         if ACol=Col then begin
          Font.Assign(FCellSelected.Font);
          Brush.Assign(FCellSelected.Brush);
          Pen.Assign(FCellSelected.Pen);
          if not Focused then begin
            Brush.Color:=FCellSelected.UnSelectedBrushColor;
            Font.Color:=FCellSelected.UnSelectedFontColor;
          end;
          Fillrect(ARect);
          Pen.Assign(FCellSelected.Pen);
          Rectangle(Arect);
          if Focused then  Windows.DrawFocusRect(Handle, ARect);
          DefaultDrawing:=False;
          exit;
         end;
        end;// end of FCellSelected.Visible
       end; // end of with canvas
      end else begin
       DefaultDrawing:=true;
      end;
      finally
       Canvas.Brush.Assign(OldBrush);
       OldBrush.Free;
       Canvas.Font.Assign(OldFont);
       OldFont.Free;
       Canvas.Pen.Assign(OldPen);
       OldPen.Free;
      end;
   end;

   procedure DrawMouseDown;
   var
//     TitleRect: TRect;
     OldBrush: TBrush;
     OldFont: TFont;
     OldPen: Tpen;
     TextW: Integer;
     cl: TColumn;
     rt: Trect;
     dx: Integer;
     x,y: Integer;
     TCS: TTypeColumnSort;
   begin
    if FTitleCellMouseDown.Visible then begin
     OldBrush:=TBrush.Create;
     OldFont:=TFont.Create;
     OldPen:=Tpen.Create;
     try
      if FTitleMouseDown then begin
       OldBrush.Assign(Canvas.Brush);
       OldFont.Assign(Canvas.Font);
       OldPen.Assign(Canvas.Pen);
       if (ACol>=IndicatorOffset) and(ARow<1) then begin
        with Canvas do begin
         Font.Assign(FTitleCellMouseDown.Font);
         Brush.Assign(FTitleCellMouseDown.Brush);
         Pen.Assign(FTitleCellMouseDown.Pen);
         FillRect(ARect);
         cl:=Columns.Items[ACol-IndicatorOffset];
         if cl<>nil then begin
           CopyMemory(@rt,@ARect,Sizeof(TRect));
           dx:=0;
           rt.Left:=rt.Left+1;
           rt.Top:=rt.Top+1;
           TCS:=GetTypeColumnSort(cl);
           if TCS<>tcsNone then
             dx:=FImageList.Width+2;
           WriteTextEx(ARow,ACol,rt,cl.Title.Alignment,cl.Title.Caption,2,2,TextW,dx);
           x:=rt.Left+TextW+6;
           y:=rt.Top+(rt.Bottom-rt.Top)div 2-FImageList.Height div 2 +1;
           case TCS of
             tcsAsc: FImageList.draw(Canvas,x,y,0);
             tcsDesc: FImageList.draw(Canvas,x,y,1);
           end;

         end;
        // DrawEdge(Canvas.Handle,TitleRect,BDR_SUNKENOUTER,BF_TOPLEFT);
       //  DrawEdge(Canvas.Handle,TitleRect,BDR_RAISEDINNER,BF_BOTTOMRIGHT);
         Pen.Assign(FTitleCellMouseDown.Pen);
         CopyMemory(@rt,@ARect,Sizeof(TRect));
         rt.Right:=rt.Right+1;
         rt.Bottom:=rt.Bottom+1;
         Rectangle(rt);
        end;
        DefaultDrawing:=false;
       end;
      end;
     finally
       Canvas.Brush.Assign(OldBrush);
       OldBrush.Free;
       Canvas.Font.Assign(OldFont);
       OldFont.Free;
       Canvas.Pen.Assign(OldPen);
       OldPen.Free;
     end;
    end;
   end;

   procedure DrawColumns;
   var
     OldBrush: TBrush;
     OldFont: TFont;
     OldPen: Tpen;
     cl: TColumn;
     rt: Trect;
     dx: Integer;
     dy: Integer;
     x,y: Integer;
     TextW: Integer;
     Curr: Integer;
     TCS: TTypeColumnSort;
   begin
     OldBrush:=TBrush.Create;
     OldFont:=TFont.Create;
     OldPen:=Tpen.Create;
     try
      if not FTitleMouseDown then begin
       OldBrush.Assign(Canvas.Brush);
       OldFont.Assign(Canvas.Font);
       OldPen.Assign(Canvas.Pen);
       Canvas.Font.Assign(Font);
       TextW:=0;
       if (ACol>=IndicatorOffset)and (Arow=0)then begin
        with Canvas do begin
         brush.Color:=FixedColor;
         Pen.Style:=psClear;
         FillRect(ARect);
         cl:=Columns.Items[ACol-IndicatorOffset];
         if cl<>nil then begin
           CopyMemory(@rt,@ARect,Sizeof(TRect));
           dx:=0;
           rt.Left:=rt.Left+1;
           rt.Top:=rt.Top+1;
           TCS:=GetTypeColumnSort(cl);
           if TCS<>tcsNone then
             dx:=FImageList.Width+2;
           WriteTextEx(ARow,ACol,rt,cl.Title.Alignment,cl.Title.Caption,1,1,TextW,dx);
           x:=rt.Left+TextW+5;
           y:=rt.Top+(rt.Bottom-rt.Top)div 2-FImageList.Height div 2;
           case TCS of
             tcsAsc: FImageList.draw(Canvas,x,y,0);
             tcsDesc: FImageList.draw(Canvas,x,y,1);
           end;
         end;
         DrawEdge(Canvas.Handle,ARect,BDR_RAISEDINNER, BF_BOTTOMRIGHT);
         DrawEdge(Canvas.Handle,ARect,BDR_RAISEDINNER, BF_TOPLEFT);
        end;
        DefaultDrawing:=false;
       end;
       if FVisibleRowNumber then begin
        if (ACol<IndicatorOffset)then begin
         Canvas.Brush.Color:=FixedColor;
         Canvas.Pen.Style:=psClear;
         dx:=0;
         CopyMemory(@rt,@ARect,Sizeof(TRect));
         rt.Left:=rt.Left+1+dx;
         rt.Top:=rt.Top+1;
         if (Arow=0) then begin
           WriteTextEx(ARow,ACol,rt,taLeftJustify,DefaultVisibleRowNumberCaption,1,1,TextW,dx);
         end else begin
          Curr:=0;
          dy:=rt.Bottom-rt.Top-2;
          dy:=dy div 2 - Canvas.TextHeight('W') div 2;
          if (DataLink.DataSet<>nil) then
           if (DataLink.DataSet.active) and
              (DataLink.DataSet.RecordCount>0) and
              (DataLink.DataSet.State=dsBrowse) then
            Curr:=GetRealTopRow(Row)+ARow
           else Curr:=0;
          if Curr<>0 then begin
            WriteTextEx(ARow,ACol,rt,taLeftJustify,inttostr(Curr),1,dy,dx,TextW);
          end;
         end;
         DefaultDrawing:=false;
        end;
       end;

      end;
     finally
       Canvas.Brush.Assign(OldBrush);
       OldBrush.Free;
       Canvas.Font.Assign(OldFont);
       OldFont.Free;
       Canvas.Pen.Assign(OldPen);
       OldPen.Free;
     end;
   end;

begin
  DrawRow:=ARow;
  CurrentRow:=Row;

  if not Assigned(FRowSelected) or
     not Assigned(FTitleCellMouseDown) or
     not Assigned(FCellSelected) then exit;

  if Assigned(DataLink) and DataLink.Active  then begin
     if DataLink.RecordCount>0 then
       DrawRowCellSelected
     else DrawRowCellSelectedNoRecord;
  end else DrawRowCellSelectedNoRecord;

  inherited;

  DrawColumns;

  DrawMouseDown;

end;


procedure TSgtsDbGrid.DrawDataCell(const Rect: TRect; Field: TField; State: TGridDrawState);
begin
  inherited;
end;

procedure TSgtsDbGrid.DrawColumnCell(const Rect: TRect; DataCol: Integer;
                                     Column: TColumn; State: TGridDrawState);
var
  NewColumn: TSgtsGridColumn;
  Def: TSgtsSelectDef;
begin
  if Column is TSgtsGridColumn then begin
    NewColumn:=TSgtsGridColumn(Column);
    if Assigned(NewColumn) and Assigned(NewColumn.Def) then begin
      Def:=NewColumn.Def;
      if Assigned(Def.DrawProc) then begin
        Def.DrawProc(Def,Canvas,Rect);
        with Canvas do begin
{          Pen.Assign(FCellSelected.Pen);
          Rectangle(Rect);}
        end;
      end;  
    end;
  end;
  inherited;
end;

procedure TSgtsDbGrid.WMSetFocus(var Msg: TWMSetFocus);
begin
  inherited;
end;

procedure TSgtsDbGrid.MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer);
var
  Cell: TGridCoord;
  fm: TCustomForm;
begin
  if not (csDesigning in ComponentState) and CanFocus then begin
    fm:=Screen.ActiveCustomForm;
    if fm<>nil then
      Windows.SetFocus(fm.Handle);
  end;
  inherited MouseDown(Button,Shift,X,Y);

  if (FOldGridState<>gsColSizing) then
    NotSetLocalWidth:=true;

  FLocateValue:='';
      
  FOldGridState:=FGridState;
  Cell := MouseCoord(X, Y);
  OldCell:=MouseCoord(X, Y);
  if (FGridState<>gsNormal)and
     (FGridState<>gsColSizing)and
     (Cell.X >= IndicatorOffset) and
     (Cell.Y < 1) then
  begin
   FTitleClickInUse:=true;
   if (Button=mbLeft)then begin
    FTitleMouseDown:=true;
    FTitleX:=Cell.X;
    FTitleY:=Cell.Y;
    InvalidateCell(Cell.X,Cell.Y);
   end;
  end else begin
   FTitleClickInUse:=false;
   FTitleMouseDown:=false;
   InvalidateCell(Cell.X,Cell.Y);
  end;
end;

procedure TSgtsDbGrid.MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer);
var
  Cell: TGridCoord;
  Column: TColumn;
begin
  inherited MouseUp(Button, Shift, X, Y);
  if FTitleMouseDown then begin
    if FGridState<>gsColMoving then begin
      Cell := MouseCoord(X,Y);
      Column:=Columns[RawToDataColumn(Cell.X)];
      if FColumnSortEnabled then begin
        SetColumnSort(Column);
      end;
      DoTitleClickWithSort(Column,GetTypeColumnSort(Column));
    end;
  end;
  FTitleMouseDown:=false;
  InvalidateCell(FTitleX,FTitleY);
end;

{procedure TSgtsDbGrid.MouseToCell(X,Y:Integer; var ACol,ARow:Integer);
var
  Coord:TGridCoord;
begin
  Coord:=MouseCoord(X, Y);
  ACol:=Coord.X;
  ARow:=Coord.Y;
end;}

procedure TSgtsDbGrid.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;
end;

procedure TSgtsDbGrid.WMMouseWheel(var Message: TWMMouseWheel);
const
  CountWheel=1;
begin
  FTitleMouseDown:=false;
  if Assigned(DataLink) and DataLink.Active  then begin
   if DataLink.DataSet=nil then exit;
   if Datalink.Active then
    with Message, DataLink.DataSet do begin
       if WheelDelta<0 then
         if not DataLink.DataSet.Eof then
           DataLink.DataSet.Next
         else exit
       else
         if not DataLink.DataSet.Bof then
           DataLink.DataSet.Prior
         else exit;  
       Result:=1;
    end;
  end;
end;

procedure TSgtsDbGrid.SetRowSizing(Value: Boolean);
begin
  if FRowSizing<>Value then begin
    FRowSizing:=Value;
    if FRowSizing then begin
     TTempGrid(self).Options:=TTempGrid(self).Options+[goRowSizing];
    end else begin
     TTempGrid(self).Options:=TTempGrid(self).Options-[goRowSizing];
    end;
  end;
end;

procedure TSgtsDbGrid.CalcSizingState(X, Y: Integer;
  var State: TGridState; var Index, SizingPos, SizingOfs: Integer;
  var FixedInfo: TGridDrawInfo);
begin
  inherited CalcSizingState(X, Y, State, Index, SizingPos, SizingOfs, FixedInfo);
end;

procedure TSgtsDbGrid.SetRowHeight(Value: Integer);
var
  i: Integer;
begin
  if FRowHeight<>Value then begin
    FRowHeight:=Value;
    for i:=0 to TTempGrid(self).RowCount-1 do
     TTempGrid(self).RowHeights[i]:=FRowHeight;
  end;
end;

procedure TSgtsDbGrid.TitleClick(Column: TColumn);
begin
  inherited;
  if (FOldGridState<>gsColSizing)and(NotSetLocalWidth)then begin
    inherited;
  end;
end;

procedure TSgtsDbGrid.AutoSizeColumns;
var
  i: Integer;
begin
  for i:=0 to Columns.Count-1 do
    AutoSizeColumn(Columns.Items[i]);
end;

procedure TSgtsDbGrid.AutoSizeColumn(Column: TColumn);
var
  w: Integer;
  i: Integer;
  l: Integer;
  fl: TField;
  bm: TBookmark;
  OldAfterScroll: TDataSetNotifyEvent;
  tmps: string;
begin
 if Assigned(Column) and
    Assigned(Column.Field) and
    Assigned(DataSource) and
    Assigned(DataSource.DataSet) and
    DataSource.DataSet.active then begin
   try
     with DataSource.DataSet do begin
       DisableControls;
       OldAfterScroll:=AfterScroll;
       AfterScroll:=nil;
       bm:=GetBookmark;
     end;  
     try
       w:=Column.Width;
       DataSource.DataSet.First;
       fl:=Column.Field;
       for i:=0 to DataSource.DataSet.RecordCount-1 do begin
         tmps:='';
         try
          tmps:=fl.DisplayText;
         except
         end;

         case fl.DataType of
          ftSmallint,ftInteger,ftWord,ftBytes,ftLargeint: begin
            tmps:=inttostr(fl.AsInteger);
          end;
          ftString,ftWideString,ftFixedChar: begin
            tmps:=fl.DisplayText;
          end;
         end;
         l:=Canvas.TextWidth(tmps)+Canvas.TextWidth('W');
         if l>w then w:=l;
         DataSource.DataSet.Next;
       end;
       Column.Width:=w;

     finally
       with DataSource.DataSet do begin
         if Assigned(bm) and BookmarkValid(bm) then
           GotoBookmark(bm);
         AfterScroll:=OldAfterScroll;
         EnableControls;
       end;
     end;
   except
   end;
  end;  
end;

procedure TSgtsDbGrid.DblClick;
var
  cl: TColumn;
  tmpcol: Integer;
begin
  if (FOldGridState=gsColSizing)then begin
    NotSetLocalWidth:=false;

    tmpcol:=RawToDataColumn(OldCell.X);
    if ((tmpcol)<0)or
       ((tmpcol)>(Columns.Count-1)) then exit;
    cl:=Columns[tmpcol];
    AutoSizeColumn(cl);
  end else begin
    if not FTitleClickInUse then
      inherited;
    NotSetLocalWidth:=true;
  end;
end;

procedure TSgtsDbGrid.SetMultiSelect(Value: Boolean);
begin
  if Value<>FMultiSelect then begin
    if Value then Options:=Options+[dgMultiSelect]
    else Options:=Options-[dgMultiSelect];
    FMultiSelect:=Value;
  end;
end;


procedure TSgtsDbGrid.ClearListColumnSort;
var
  P: PInfoColumnSort;
  i: Integer;
begin
  for i:=0 to FListColumnSort.Count-1 do begin
    P:=FListColumnSort.Items[i];
    Dispose(P);
  end;
  FListColumnSort.Clear;
end;

function TSgtsDbGrid.GetTypeColumnSort(Column: TColumn): TTypeColumnSort;
var
  i: Integer;
  P: PInfoColumnSort;
begin
  Result:=tcsNone;
  for i:=0 to FListColumnSort.Count-1 do begin
    P:=FListColumnSort.Items[i];
    if P.Column=Column then begin
      Result:=P.TypeColumnSort;
      exit;
    end;
  end;
end;

procedure TSgtsDbGrid.SetColumnSort(Column: TColumn);
var
  i: Integer;
  P: PInfoColumnSort;
  cur,next: TTypeColumnSort;
begin
//  EnterCriticalSection(FLock);
  try
    for i:=FListColumnSort.Count-1 downto 0 do begin
      P:=FListColumnSort.Items[i];
      if P.Column=Column then begin
        FColumnSort:=Column;
        cur:=P.TypeColumnSort;
        next:=cur;
        case cur of
          tcsNone: next:=tcsAsc;
          tcsAsc: next:=tcsDesc;
          tcsDesc: next:=tcsNone;
        end;
        if next<>tcsNone then begin
          FColumnSort.Color:=FColumnSortColor;
        end else
          FColumnSort.Color:=FOldColumnSortColor;
        P.TypeColumnSort:=next;
        exit;
      end else begin
        FListColumnSort.Remove(P);
        Dispose(P);
      end;
    end;
    if Assigned(Column) then begin
      New(P);
      P.Column:=Column;
      FColumnSort:=Column;
      P.TypeColumnSort:=tcsAsc;
      FOldColumnSortColor:=FColumnSort.Color;
      FColumnSort.Color:=FColumnSortColor;
      FListColumnSort.Add(P);
      InvalidateTitles;
    end;
  finally
  //  LeaveCriticalSection(FLock);  
  end;  
end;

procedure TSgtsDbGrid.SetTypeColumnSort(Column: TColumn; TypeSort: TTypeColumnSort);
var
  i: Integer;
  P: PInfoColumnSort;
begin
  for i:=0 to FListColumnSort.Count-1 do begin
    P:=FListColumnSort.Items[i];
    if P.Column=Column then begin
      P.TypeColumnSort:=TypeSort;
      exit;
    end;
  end;
end;

procedure TSgtsDbGrid.ClearColumnSort;
begin
  ClearListColumnSort;
end;

procedure TSgtsDbGrid.SetColumnSortEnabled(Value: Boolean);
begin
 if Value<>FColumnSortEnabled then begin
   FColumnSortEnabled:=Value;
   if not FColumnSortEnabled then
     ClearColumnSort;
 end;
end;

procedure TSgtsDbGrid.SetVisibleRowNumber(Value: Boolean);
begin
  if Value<>FVisibleRowNumber then begin
    FVisibleRowNumber:=Value;
    SetWidthRowNumber(Row);
  end;
end;

function ReadOnlyField(Field: TField): Boolean;
var
  MasterField: TField;
begin
  Result := Field.ReadOnly;
  if not Result and (Field.FieldKind = fkLookup) then
  begin
    Result := True;
    if Field.DataSet = nil then Exit;
    MasterField := Field.Dataset.FindField(Field.KeyFields);
    if MasterField = nil then Exit;
    Result := MasterField.ReadOnly;
  end;
end;

procedure TSgtsDbGrid.SetColumnAttributes;
var
  I: Integer;
begin
  for I := 0 to Columns.Count-1 do
  with Columns[I] do
  begin
    TabStops[I + IndicatorOffset] := Showing and not ReadOnly and DataLink.Active and
      Assigned(Field) and not (Field.FieldKind = fkCalculated) and not ReadOnlyField(Field);
    ColWidths[I + IndicatorOffset] := Width;
  end;
  SetWidthRowNumber(Row);
end;

procedure TSgtsDbGrid.Scroll(Distance: Integer);
begin
  inherited Scroll(Distance);
//  SetWidthRowNumber(Row);
end;

procedure TSgtsDbGrid.TopLeftChanged;
begin
  inherited TopLeftChanged;
end;

type
  THackEditList=class(TInplaceEditList)
  end;

procedure TSgtsDbGrid.SetWidthRowNumber(NewRow: Integer);
var
  ARow: Integer;
  w,wmin: Integer;
  Plus: Integer;
begin
  if not FStopSetWidthRowNumber then begin
    FStopSetWidthRowNumber:=true;
    try
      if FVisibleRowNumber then begin
        if Assigned(DataLink.DataSet) and
           not (DataLink.DataSet.State in [dsEdit, dsInsert]) then begin
          ARow:=GetRealTopRow(NewRow)+NewRow;
          Plus:=0;
          if dgIndicator in Options then
            Plus:=IndicatorWidth;
          wmin:=Canvas.TextWidth(inttostr(9))+3+Plus;
          w:=Canvas.TextWidth(inttostr(ARow))+3+Plus;
          if w<wmin then
            w:=wmin;
          try
            colwidths[0]:=w;
          except
          end;
        end;
      end else begin
        colwidths[0]:=IndicatorWidth;
      end;
    finally
      FStopSetWidthRowNumber:=false;
    end;  
  end;
end;

procedure TSgtsDbGrid.SetEditText(ACol, ARow: Longint; const Value: string);
begin
  inherited;
end;

function TSgtsDbGrid.GetEditText(ACol, ARow: Longint): string;
begin
  Result:=inherited GetEditText(ACol, ARow);
end;

function TSgtsDbGrid.SelectCell(ACol, ARow: Longint): Boolean;
begin
//  SetWidthRowNumber(ARow);
  Result:=inherited SelectCell(ACol,ARow);
end;

procedure TSgtsDbGrid.TimedScroll(Direction: TGridScrollDirection);
begin
  inherited TimedScroll(Direction);
//  SetWidthRowNumber(Row);
end;

function TSgtsDbGrid.GetRealTopRow(NewRow: Integer): Integer;
begin
  Result:=0;
  if DataLink.DataSet<>nil then begin
    if not DataLink.DataSet.IsEmpty then
      if DataLink.DataSet.State=dsBrowse then
        Result:=DataLink.DataSet.RecNo-NewRow
      else Result:=0;  
  end;
end;

procedure TSgtsDbGrid.LayoutChanged;
begin
  Inherited;
  SetDefaultRowHeight(FNewDefaultRowHeight);
end;

procedure TSgtsDbGrid.RowHeightsChanged;
var
  i,ThisHasChanged,Def : Integer;
begin
  ThisHasChanged:=-1;
  Def:=DefaultRowHeight;
  For i:=Ord(dgTitles In Options) to RowCount Do begin
    If RowHeights[i]<>Def Then Begin
      ThisHasChanged:=i;
      Break;
    End;
  End;
  If ThisHasChanged<>-1 Then Begin
    SetDefaultRowHeight(RowHeights[ThisHasChanged]);
    RecreateWnd;
  end;
  inherited;
end;

procedure TSgtsDbGrid.SetDefaultRowHeight(Value: Integer);
var
  MinH: Integer;
begin
  if Assigned(Parent)and(Parent.HandleAllocated) then begin
    MinH:=GetMinRowHeight;
    if Value<=MinH then begin
      Value:=MinH;
    end else Value:=MinH;

    inherited DefaultRowHeight:=Value;
    FNewDefaultRowHeight:=Value;
    if dgTitles in Options then begin
      Canvas.Font:=TitleFont;
      RowHeights[0]:=MinH;
    end;
  end;
end;

function TSgtsDbGrid.GetDefaultRowHeight: Integer;
begin
  Result:=inherited DefaultRowHeight;
end;

function TSgtsDbGrid.GetMinRowHeight: Integer;
begin
  Result:=Canvas.TextHeight('W')+4;
end;

procedure TSgtsDbGrid.WMVScroll(var Message: TWMVScroll);
begin
  inherited;
//  SetWidthRowNumber(Row);
end;

procedure TSgtsDbGrid.UpdateRowNumber;
begin
  SetWidthRowNumber(Row);
end;

procedure TSgtsDbGrid.DoTitleClickWithSort(Column: TColumn; TypeSort: TTypeColumnSort); 
begin
  if Assigned(FOnTitleClickWithSort) then
    FOnTitleClickWithSort(Column,TypeSort);
  InvalidateTitles;  
end;

function TSgtsDbGrid.GetTypeColumnSortEx: TTypeColumnSort;
begin
  Result:=tcsNone;
  if Assigned(FColumnSort) then
    Result:=GetTypeColumnSort(FColumnSort);
end;

procedure TSgtsDbGrid.SetTypeColumnSortEx(Value: TTypeColumnSort);
begin
  if Assigned(FColumnSort) then
    SetTypeColumnSort(FColumnSort,Value);
end;

procedure TSgtsDbGrid.ColumnMoved(FromIndex, ToIndex: Longint);
begin
  inherited;
  FTitleMouseDown:=false;
end;

procedure TSgtsDbGrid.CMFontChanged(var Message: TMessage);
begin
  try
    inherited;
  finally
  end;
end;

procedure TSgtsDbGrid.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if FLocateEnabled then begin
    case Key of
      VK_BACK: begin
        Delete(FLocateValue,Length(FLocateValue),1);
        InvalidateRow(Row);
      end;
      VK_DELETE, VK_ESCAPE, VK_LEFT, VK_DOWN, VK_UP, VK_RIGHT,
      VK_HOME, VK_END, VK_PRIOR, VK_NEXT: begin
        FLocateValue:='';
        InvalidateRow(Row);
      end;
    end;
  end;
  inherited KeyDown(Key,Shift);
  SetWidthRowNumber(Row);
end;

procedure TSgtsDbGrid.KeyPress(var Key: Char);
var
  OldOptions: TDBGridOptions;
  B: TBookmark;
  DS: TDataSet;
  Flag: Boolean;
  OldCursor: TCursor;
  FNewValue: string;
 // S: String;
begin
  if FLocateEnabled then begin
    if Assigned(DataSource) and
       Assigned(DataSource.DataSet) and
       ((Assigned(SelectedField) and not SelectedField.Calculated) or (Assigned(SelectedField) and Assigned(FColumnLocate))) and
       (((Ord(Key)) >= Ord(' ')) or (Ord(Key)=VK_BACK)) then begin

      DS:=DataSource.DataSet;
      Flag:=false;
      OldCursor:=Screen.Cursor;
      OldOptions:=Options;
      DS.DisableControls;
      B:=DS.GetBookmark;
      try
        FColumnLocate:=Columns[SelectedIndex];
        Options:=Options-[dgEditing]-[dgTabs];
        Screen.Cursor:=crHourGlass;
        FNewValue:=FLocateValue;
        if CharIsPrintable(Key) then
           FNewValue:=FNewValue+Key;
        if Trim(FNewValue)<>'' then begin

          DS.First;
          if DS.Locate(SelectedField.FieldName,FNewValue,[loCaseInsensitive, loPartialKey]) then begin
            FLocateVisible:=true;
            Flag:=true;
            FLocateValue:=FNewValue;
          end else begin
{            S:=VarToStrDef(SelectedField.Value,'');
            FLocateVisible:=AnsiPos(FNewValue,S)=1; }
            FLocateVisible:=false;
            FLocateValue:=FNewValue;
            beep;
          end;
        end else begin
          if Trim(FNewValue)='' then
            FLocateValue:='';
        end;
      finally
        if not Flag then
          if DS.BookmarkValid(B) then
            DS.GotoBookmark(B);
        DS.EnableControls;
        Options:=OldOptions;
        Screen.Cursor:=OldCursor;
      end;
    end else begin
      FLocateValue:='';
      inherited KeyPress(Key);

      SetWidthRowNumber(Row);
    end;
  end else begin
    FLocateValue:='';
    inherited KeyPress(Key);
    SetWidthRowNumber(Row);
  end;
end;

function TSgtsDbGrid.FindColumn(const FieldName: string): TColumn;
var
  i: Integer;
begin
  Result:=nil;
  for i:=0 to Columns.Count-1 do begin
    if AnsiSameText(Columns[i].FieldName,FieldName) then begin
      Result:=Columns[i];
      exit;
    end;
  end;
end;

function TSgtsDbGrid.GetFontColor(Column: TColumn; var FontStyles: TFontStyles): TColor;
begin
  Result:=Font.Color;
  if Assigned(FOnGetFontColor) then
    Result:=FOnGetFontColor(Self,Column,FontStyles);
end;

function TSgtsDbGrid.GetBrushColor(Column: TColumn): TColor;
begin
  Result:=Brush.Color;
  if Assigned(FOnGetBrushColor) then
    Result:=FOnGetBrushColor(Self,Column);
end;

function TSgtsDbGrid.CreateEditor: TInplaceEdit;
begin
  Result:=inherited CreateEditor;
  FInplaceEdit:=TInplaceEditList(Result);
{  if Assigned(FOnCreateEditor) then
    FOnCreateEditor(Self);}
end;

procedure TSgtsDbGrid.Resize;
begin
  inherited Resize;
  if FAutoFit then begin
    AutoFitColumns;
  end;
end;

procedure TSgtsDbGrid.GetColumnsDefsWidth(var ColumnsWidth,DefsWidth: Integer);
var
  i: Integer;
  StartI: Integer;
  Column: TSgtsGridColumn;
begin
  ColumnsWidth:=0;
  DefsWidth:=0;
  StartI:=0;
  for i:=StartI to Columns.Count-1 do begin
    if Columns.Items[i].Visible then begin
      ColumnsWidth:=ColumnsWidth+Columns.Items[i].Width;
      if Columns.Items[i] is TSgtsGridColumn then begin
        Column:=TSgtsGridColumn(Columns.Items[i]);
        if Assigned(Column.Def) then
          DefsWidth:=DefsWidth+Column.Def.Width
        else DefsWidth:=ColumnsWidth;
      end else
        DefsWidth:=ColumnsWidth;
    end;
  end;
end;

procedure TSgtsDbGrid.AutoFitColumns;
var
  ColumnsWidth: Integer;
  DefsWidth: Integer;
  ScrollWidth: Integer;
  IndicatorWidth: Integer;
  Column: TSgtsGridColumn;
  W1,dX: Integer;
  i: Integer;
  StartI: Integer;
begin
  if not FStopAutoFitColumns then  begin
    FStopAutoFitColumns:=true;
    try
      StartI:=0;
      dX:=Columns.Count*1;
      GetColumnsDefsWidth(ColumnsWidth,DefsWidth);
      ScrollWidth:=GetSystemMetrics(SM_CXHSCROLL)+dX;
      IndicatorWidth:=ColWidths[0];
      if FVisibleRowNumber then
        IndicatorWidth:=ColWidths[0];
      for i:=StartI to Columns.Count-1 do begin
        if Columns.Items[i] is TSgtsGridColumn then begin
          Column:=TSgtsGridColumn(Columns.Items[i]);
          W1:=ClientWidth-ScrollWidth-IndicatorWidth-ColumnsWidth;
          if DefsWidth>0 then begin
            if Assigned(Column.Def) then
              Column.Width:=Column.Width+Round(W1*Column.Def.Width/DefsWidth)
            else
              Column.Width:=Column.Width;
          end;  
        end;
      end;
    finally
      FStopAutoFitColumns:=false;
    end;
  end;
end;

type
  TCustomDbGridHack=class(TCustomGrid)
  end;

procedure TSgtsDbGrid.SetColMoving(Value: Boolean);
begin
  if Value then
    TCustomDbGridHack(Self).Options:=TCustomDbGridHack(Self).Options+[goColMoving]
  else
    TCustomDbGridHack(Self).Options:=TCustomDbGridHack(Self).Options-[goColMoving];
end;

function TSgtsDbGrid.GetColMoving: Boolean;
begin
  Result:=goColMoving in TCustomDbGridHack(Self).Options;
end;

function TSgtsDbGrid.GetOptions: TDBGridOptions;
begin
  Result:=inherited Options;
end;

procedure TSgtsDbGrid.SetOptions(Value: TDBGridOptions);
var
  OldColMoving: Boolean;
begin
  OldColMoving:=GetColMoving;
  try
    inherited Options:=Value;
  finally
    SetColMoving(OldColMoving);
  end;  
end;

function TSgtsDbGrid.GetColumnsStr: String;
var
  S: String;
  Stream: TMemoryStream;
begin
  Stream:=TMemoryStream.Create;
  try
    Result:='';
    Columns.SaveToStream(Stream);
    SetLength(S,Stream.Size);
    Move(Stream.Memory^,Pointer(S)^,Stream.Size);
    Result:=S;
  finally
    Stream.Free;
  end;  
end;

procedure TSgtsDbGrid.SetColumnsStr(Value: String);
var
  Stream: TMemoryStream;
  DefStream: TMemoryStream;
begin
  Stream:=TMemoryStream.Create;
  DefStream:=TMemoryStream.Create;
  try
    Columns.SaveToStream(DefStream);
    DefStream.Position:=0;
    Stream.SetSize(Length(Value));
    Move(Pointer(Value)^,Stream.Memory^,Length(Value));
    try
      Columns.LoadFromStream(Stream);
    except
      Columns.LoadFromStream(DefStream);
    end;
  finally
    DefStream.Free;
    Stream.Free;
  end;
end;

function TSgtsDbGrid.CreateDataLink: TGridDataLink; 
begin
  Result:=TSgtsDbGridDataLink.Create(self);
end;

procedure TSgtsDbGrid.DataSetScrolled(Sender: TObject);
begin
 // UpdateRowNumber;
end;

end.