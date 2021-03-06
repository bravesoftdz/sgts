unit SgtsTableEditFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DBCtrls, ExtCtrls, DB, DBGrids, DBClient, ClipBrd,
  SgtsCDS, SgtsDBGrid, SgtsControls, Buttons;

type
  TSgtsTableEditFrame = class(TFrame)
    PanelTop: TPanel;
    ButtonLoad: TButton;
    ButtonSave: TButton;
    ButtonCreate: TButton;
    PanelGrid: TPanel;
    Splitter: TSplitter;
    PanelBottom: TPanel;
    GroupBoxValue: TGroupBox;
    PanelValue: TPanel;
    PanelValueButton: TPanel;
    ButtonGen: TButton;
    DataSource: TDataSource;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    ButtonClear: TButton;
    DBNavigator: TDBNavigator;
    LabelTableName: TLabel;
    EditTableName: TEdit;
    ButtonLoadValue: TButton;
    ButtonSaveValue: TButton;
    btUpColumns: TBitBtn;
    btDownColumns: TBitBtn;
    PanelMemo: TPanel;
    DBMemoValue: TDBMemo;
    LabelFilter: TLabel;
    EditFilter: TEdit;
    ButtonApply: TButton;
    procedure ButtonCreateClick(Sender: TObject);
    procedure ButtonLoadClick(Sender: TObject);
    procedure ButtonSaveClick(Sender: TObject);
    procedure ButtonGenClick(Sender: TObject);
    procedure ButtonClearClick(Sender: TObject);
    procedure ButtonLoadValueClick(Sender: TObject);
    procedure ButtonSaveValueClick(Sender: TObject);
    procedure btUpColumnsClick(Sender: TObject);
    procedure btDownColumnsClick(Sender: TObject);
    procedure ButtonApplyClick(Sender: TObject);
  private
    FDataSet: TSgtsCDS;
    FGrid: TSgtsDbGrid;
    FFileName: String;
    procedure GridCellClick(Column: TColumn);
    procedure GridColEnter(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;

    property DataSet: TSgtsCDS read FDataSet;
    property FileName: String read FFileName write FFileName;
  end;

implementation

{$R *.dfm}

uses SgtsTableNewFm, SgtsUtils, SgtsDialogs;

constructor TSgtsTableEditFrame.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDataSet:=TSgtsCDS.Create(Self);

  DataSource.DataSet:=FDataSet;

  FGrid:=TSgtsDbGrid.Create(Self);
  with FGrid do begin
    Align:=alClient;
    Parent:=PanelGrid;
    ColumnSortEnabled:=false;
    VisibleRowNumber:=true;
    DataSource:=Self.DataSource;
    Options:=Options+[dgEditing];
    ReadOnly:=false;
    OnCellClick:=GridCellClick;
    OnColEnter:=GridColEnter;
  end;
end;

procedure TSgtsTableEditFrame.ButtonCreateClick(Sender: TObject);
var
  Form: TSgtsTableNewForm;
begin
  Form:=TSgtsTableNewForm.Create(FDataSet);
  try
    DBMemoValue.DataField:='';
    if Form.ShowModal=mrOk then begin
      if SaveDialog.Execute then begin
        if FDataSet.Active then begin
          FDataSet.MergeChangeLog;
          FDataSet.SaveToFile(SaveDialog.FileName,dfXMLUTF8);
          DBMemoValue.DataField:=FDataSet.Fields[0].FieldName;
        end;  
      end;
    end;
  finally
    Form.Free;
  end;
end;

procedure TSgtsTableEditFrame.ButtonLoadClick(Sender: TObject);
begin
  if OpenDialog.Execute then begin
    DBMemoValue.DataField:='';
    FDataSet.LoadFromFile(OpenDialog.FileName);
    EditTableName.Text:=FDataSet.TableName;
    DBMemoValue.DataField:=FDataSet.Fields[0].FieldName;
  end;
end;

procedure TSgtsTableEditFrame.ButtonSaveClick(Sender: TObject);
begin
  if SaveDialog.Execute then begin
    if FDataSet.Active then begin
      FDataSet.TableName:=EditTableName.Text;
      FDataSet.MergeChangeLog;
      FDataSet.SaveToFile(SaveDialog.FileName,dfXMLUTF8);
    end;  
  end;
end;

procedure TSgtsTableEditFrame.GridCellClick(Column: TColumn);
begin
  if Assigned(FGrid.SelectedField) then begin
    DBMemoValue.DataField:=Column.FieldName;
    DBMemoValue.LoadMemo;
  end else DBMemoValue.DataField:='';
end;

procedure TSgtsTableEditFrame.GridColEnter(Sender: TObject);
begin
  if Assigned(FGrid.SelectedField) then begin
    DBMemoValue.DataField:=FGrid.SelectedField.FieldName;
    DBMemoValue.LoadMemo;
  end else DBMemoValue.DataField:='';
end;

procedure TSgtsTableEditFrame.ButtonGenClick(Sender: TObject);
var
  S: String;
begin
  S:=CreateUniqueId;
  Clipboard.AsText:=S;
  if ShowQuestion(Format('�������� �������� �� %s?',[S]))=mrYes then
    if FDataSet.Active and (Trim(DBMemoValue.DataField)<>'') then begin
      FDataSet.Edit;
      FDataSet.FieldByName(DBMemoValue.DataField).Value:=S;
      FDataSet.Post;
    end;
end;

procedure TSgtsTableEditFrame.ButtonClearClick(Sender: TObject);
begin
  EditTableName.Text:='';
  FDataSet.EmptyDataSet;
  FDataSet.Close;
  FDataSet.FieldDefs.Clear;
end;

procedure TSgtsTableEditFrame.ButtonLoadValueClick(Sender: TObject);
var
  Stream: TFileStream;
  AValue: String;
begin
  if FDataSet.Active and (Trim(DBMemoValue.DataField)<>'') then begin
    if OpenDialog.Execute then begin
      Stream:=TFileStream.Create(OpenDialog.FileName,fmOpenRead or fmShareDenyWrite);
      try
        SetLength(AValue,Stream.Size);
        Stream.Read(Pointer(AValue)^,Stream.Size);
        FDataSet.Edit;
        FDataSet.FieldByName(DBMemoValue.DataField).Value:=AValue;
        FDataSet.Post;
      finally
        Stream.Free;
      end;
    end;
  end;
end;

procedure TSgtsTableEditFrame.ButtonSaveValueClick(Sender: TObject);
var
  Stream: TFileStream;
  AValue: String;
begin
  if FDataSet.Active and (Trim(DBMemoValue.DataField)<>'') and not FDataSet.IsEmpty then begin
    if SaveDialog.Execute then begin
      Stream:=TFileStream.Create(SaveDialog.FileName,fmCreate);
      try
        AValue:=FDataSet.FieldByName(DBMemoValue.DataField).Value;
        Stream.Write(Pointer(AValue)^,Length(AValue));
      finally
        Stream.Free;
      end;
    end;
  end;
end;

procedure TSgtsTableEditFrame.btUpColumnsClick(Sender: TObject);
begin
  FDataSet.MoveData(true);
end;

procedure TSgtsTableEditFrame.btDownColumnsClick(Sender: TObject);
begin
  FDataSet.MoveData(false);
end;



procedure TSgtsTableEditFrame.ButtonApplyClick(Sender: TObject);
var
  FieldName: String;
begin
  if Trim(EditFilter.Text)<>'' then begin
    if Assigned(FGrid.SelectedField) then begin
      FieldName:=FGrid.SelectedField.FieldName;
      DataSet.Filter:=Format('%s=%s',[FieldName,QuotedStr(EditFilter.Text)]);
      DataSet.Filtered:=true;
    end;  
  end else begin
    DataSet.Filter:='';
    DataSet.Filtered:=false;
  end;  
end;

end.
