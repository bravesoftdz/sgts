unit SgtsFunPointInstrumentsFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, DB, ImgList, Grids, DBGrids,
  ExtCtrls, ComCtrls, ToolWin,
  SgtsDataGridMoveFrm;

type
  TSgtsFunPointInstrumentsFrame = class(TSgtsDataGridMoveFrame)
  private
    procedure Reorder;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure MoveUp; override;
    procedure MoveDown; override;
  end;

var
  SgtsFunPointInstrumentsFrame: TSgtsFunPointInstrumentsFrame;

implementation

uses SgtsDialogs, SgtsConsts, SgtsUtils, SgtsProviderConsts,
     SgtsGetRecordsConfig, SgtsFunPointInstrumentIfaces, SgtsDataGridFrm,
     SgtsCoreIntf, SgtsDatabaseCDS, SgtsExecuteDefs;

{$R *.dfm}

{ TSgtsFunPointInstrumentsFrame }

constructor TSgtsFunPointInstrumentsFrame.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  InsertClass:=TSgtsFunPointInstrumentInsertIface;
  UpdateClass:=TSgtsFunPointInstrumentUpdateIface;
  DeleteClass:=TSgtsFunPointInstrumentDeleteIface;
  with DataSet do begin
    ProviderName:=SProviderSelectPointInstruments;
    with SelectDefs do begin
      Add('PARAM_NAME','��������',100);
      Add('INSTRUMENT_NAME','������',100);
      AddInvisible('POINT_ID');
      AddInvisible('INSTRUMENT_ID');
      AddInvisible('PARAM_ID');
      AddInvisible('POINT_NAME');
      AddInvisible('PRIORITY');
    end;
    Orders.Add('PRIORITY',otAsc);
  end;
end;

destructor TSgtsFunPointInstrumentsFrame.Destroy;
begin
  inherited Destroy;
end;

procedure TSgtsFunPointInstrumentsFrame.MoveUp; 
begin
  inherited MoveUp;
  if CanMoveUp then begin
    Reorder;
  end;
end;

procedure TSgtsFunPointInstrumentsFrame.MoveDown;
begin
  inherited MoveDown;
  if CanMoveDown then begin
    Reorder;
  end;
end;

procedure TSgtsFunPointInstrumentsFrame.Reorder;
var
  DS: TSgtsDatabaseCDS;
  NewPriority: Integer;
  OldCursor: TCursor;
begin
  OldCursor:=Screen.Cursor;
  Screen.Cursor:=crHourGlass;
  DS:=TSgtsDatabaseCDS.Create(CoreIntf);
  DataSet.BeginUpdate(true);
  CoreIntf.MainForm.Progress(0,0,0);
  try
    DS.ProviderName:=SProviderUpdatePointInstrument;
    DS.StopException:=true;
    with DS.ExecuteDefs do begin
      AddKeyLink('POINT_ID');
      AddKeyLink('PARAM_ID');
      AddKeyLink('INSTRUMENT_ID');
      AddInvisible('PRIORITY');
    end;

    NewPriority:=1;
    DataSet.First;
    while not DataSet.Eof do begin
      with DS.ExecuteDefs do begin
        FirstState;
        Find('POINT_ID').Value:=DataSet.FieldByName('POINT_ID').Value;
        Find('PARAM_ID').Value:=DataSet.FieldByName('PARAM_ID').Value;
        Find('INSTRUMENT_ID').Value:=DataSet.FieldByName('INSTRUMENT_ID').Value;
        Find('PRIORITY').Value:=NewPriority;
      end;
      DS.Execute;
      if DS.ExecuteSuccess then begin
        DataSet.Edit;
        DataSet.FieldByName('PRIORITY').Value:=NewPriority;
        DataSet.Post;
      end;
      CoreIntf.MainForm.Progress(0,DataSet.RecordCount,NewPriority);
      DataSet.Next;
      Inc(NewPriority);
    end;
    
  finally
    CoreIntf.MainForm.Progress(0,0,0);
    DataSet.EndUpdate(true);
    DS.Free;
    Screen.Cursor:=OldCursor;
  end;
end;

end.
