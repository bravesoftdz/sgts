unit SgtsRbkPointInstrumentsFm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ImgList, Grids, DBGrids, ExtCtrls, ComCtrls, ToolWin, DB,
  SgtsDataGridFm, SgtsDataFm, SgtsFm,
  SgtsCoreIntf, StdCtrls;

type
  TSgtsRbkPointInstrumentsForm = class(TSgtsDataGridForm)
  private
    { Private declarations }
  public
    constructor Create(ACoreIntf: ISgtsCore); override;
  end;

  TSgtsRbkPointInstrumentsIface=class(TSgtsDataGridIface)
  public
    procedure Init; override;
  end;

var
  SgtsRbkPointInstrumentsForm: TSgtsRbkPointInstrumentsForm;

implementation

uses DBClient,
     SgtsDbGrid, SgtsCDS, SgtsProviderConsts, SgtsDatabaseCDS,
     SgtsSelectDefs, SgtsRbkPointInstrumentEditFm, SgtsConsts;

{$R *.dfm}

{ TSgtsRbkPointInstrumentsIface }

procedure TSgtsRbkPointInstrumentsIface.Init;
begin
  inherited Init;
  FormClass:=TSgtsRbkPointInstrumentsForm;
  InterfaceName:=SInterfacePointInstruments;
  InsertClass:=TSgtsRbkPointInstrumentInsertIface;
  UpdateClass:=TSgtsRbkPointInstrumentUpdateIface;
  DeleteClass:=TSgtsRbkPointInstrumentDeleteIface;
  with DataSet do begin
    ProviderName:=SProviderSelectPointInstruments;
    with SelectDefs do begin
      AddInvisible('POINT_ID');
      AddInvisible('PARAM_ID');
      AddInvisible('INSTRUMENT_ID');
      Add('POINT_NAME','������������� �����',100);
      Add('PARAM_NAME','��������',150);
      Add('INSTRUMENT_NAME','������',150);
      Add('PRIORITY','�������',30);
    end;
  end;
end;

{ TSgtsRbkPointInstrumentsForm }

constructor TSgtsRbkPointInstrumentsForm.Create(ACoreIntf: ISgtsCore);
begin
  inherited Create(ACoreIntf);
end;


end.
