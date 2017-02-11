unit SgtsRbkParamInstrumentsFm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ImgList, Grids, DBGrids, ExtCtrls, ComCtrls, ToolWin, DB,
  SgtsDataGridFm, SgtsDataFm, SgtsFm,
  SgtsCoreIntf, StdCtrls;

type
  TSgtsRbkParamInstrumentsForm = class(TSgtsDataGridForm)
  private
    { Private declarations }
  public
    constructor Create(ACoreIntf: ISgtsCore); override;
  end;

  TSgtsRbkParamInstrumentsIface=class(TSgtsDataGridIface)
  public
    procedure Init; override;
  end;

var
  SgtsRbkParamInstrumentsForm: TSgtsRbkParamInstrumentsForm;

implementation

uses DBClient,
     SgtsDbGrid, SgtsCDS, SgtsProviderConsts, SgtsDatabaseCDS,
     SgtsSelectDefs, SgtsRbkParamInstrumentEditFm, SgtsConsts;

{$R *.dfm}

{ TSgtsRbkParamInstrumentsIface }

procedure TSgtsRbkParamInstrumentsIface.Init;
begin
  inherited Init;
  FormClass:=TSgtsRbkParamInstrumentsForm;
  InterfaceName:=SInterfaceParamInstruments;
  InsertClass:=TSgtsRbkParamInstrumentInsertIface;
  UpdateClass:=TSgtsRbkParamInstrumentUpdateIface;
  DeleteClass:=TSgtsRbkParamInstrumentDeleteIface;
  with DataSet do begin
    ProviderName:=SProviderSelectParamInstruments;
    with SelectDefs do begin
      AddInvisible('PARAM_ID');
      AddInvisible('INSTRUMENT_ID');
      Add('PARAM_NAME','��������',150);
      Add('INSTRUMENT_NAME','������',150);
      Add('PRIORITY','�������',30);
    end;
  end;
end;

{ TSgtsRbkParamInstrumentsForm }

constructor TSgtsRbkParamInstrumentsForm.Create(ACoreIntf: ISgtsCore);
begin
  inherited Create(ACoreIntf);
end;


end.
