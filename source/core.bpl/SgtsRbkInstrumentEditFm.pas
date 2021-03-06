unit SgtsRbkInstrumentEditFm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ToolWin, ImgList, Menus, ExtCtrls, StdCtrls,
  SgtsDataEditFm, SgtsDataInsertFm, SgtsDataUpdateFm, SgtsDataDelete,
  SgtsFm, SgtsControls, SgtsCoreIntf;

type
  TSgtsRbkInstrumentEditForm = class(TSgtsDataEditForm)
    LabelName: TLabel;
    EditName: TEdit;
    LabelDescription: TLabel;
    MemoDescription: TMemo;
    LabelType: TLabel;
    ComboBoxType: TComboBox;
    ButtonType: TButton;
    LabelDateEnter: TLabel;
    DateTimePickerEnter: TDateTimePicker;
    LabelSerial: TLabel;
    EditSerial: TEdit;
    LabelInventory: TLabel;
    EditInventory: TEdit;
    LabelFrequencyTest: TLabel;
    EditFrequencyTest: TEdit;
    LabelDateEnd: TLabel;
    DateTimePickerEnd: TDateTimePicker;
    LabelClass: TLabel;
    EditClass: TEdit;
    LabelRange: TLabel;
    EditRange: TEdit;
  private
    { Private declarations }
  public
    constructor Create(ACoreIntf: ISgtsCore); override;
  end;

  TSgtsRbkInstrumentInsertIface=class(TSgtsDataInsertIface)
  public
    procedure Init; override;
  end;

  TSgtsRbkInstrumentUpdateIface=class(TSgtsDataUpdateIface)
  public
    procedure Init; override;
  end;

  TSgtsRbkInstrumentDeleteIface=class(TSgtsDataDeleteIface)
  public
    procedure Init; override;
  end;

var
  SgtsRbkInstrumentEditForm: TSgtsRbkInstrumentEditForm;

implementation

uses DBClient, DateUtils,
     SgtsIface, SgtsConsts, SgtsProviderConsts,
     SgtsDatabaseCDS, SgtsDialogs, SgtsExecuteDefs,
     SgtsRbkObjectsFm, SgtsRbkInstrumentTypesFm;

{$R *.dfm}

{ TSgtsRbkInstrumentInsertIface }

procedure TSgtsRbkInstrumentInsertIface.Init;
begin
  inherited Init;
  FormClass:=TSgtsRbkInstrumentEditForm;
  InterfaceName:=SInterfaceInstrumentInsert;
  with DataSet do begin
    ProviderName:=SProviderInsertInstrument;
    with ExecuteDefs do begin
      AddKey('INSTRUMENT_ID');
      AddEdit('NAME','EditName','LabelName',true);
      AddMemo('DESCRIPTION','MemoDescription','LabelDescription',false);
      AddComboLink('INSTRUMENT_TYPE_ID','ComboBoxType','LabelType','ButtonType',
                   TSgtsRbkInstrumentTypesIface,'INSTRUMENT_TYPE_NAME','NAME','INSTRUMENT_TYPE_ID',true).AutoFill:=true;
      AddDate('DATE_ENTER','DateTimePickerEnter','LabelDateEnter',true);
      AddDate('DATE_END','DateTimePickerEnd','LabelDateEnd',false).DefaultValue:=NullDate;
      AddEdit('SERIAL_NUMBER','EditSerial','LabelSerial',false);
      AddEdit('INVENTORY_NUMBER','EditInventory','LabelInventory',false);
      AddEdit('FREQUENCY_TEST','EditFrequencyTest','LabelFrequencyTest',false);
      AddEditFloat('CLASS_ACCURACY','EditClass','LabelClass',false);
      AddEdit('RANGE_MEASURE','EditRange','LabelRange',false);
    end;
  end;
end;

{ TSgtsRbkInstrumentUpdateIface }

procedure TSgtsRbkInstrumentUpdateIface.Init;
begin
  inherited Init;
  FormClass:=TSgtsRbkInstrumentEditForm;
  InterfaceName:=SInterfaceInstrumentUpdate;
  with DataSet do begin
    ProviderName:=SProviderUpdateInstrument;
    with ExecuteDefs do begin
      AddKeyLink('INSTRUMENT_ID');
      AddEdit('NAME','EditName','LabelName',true);
      AddMemo('DESCRIPTION','MemoDescription','LabelDescription',false);
      AddComboLink('INSTRUMENT_TYPE_ID','ComboBoxType','LabelType','ButtonType',
                   TSgtsRbkInstrumentTypesIface,'INSTRUMENT_TYPE_NAME','NAME','INSTRUMENT_TYPE_ID',true).AutoFill:=true;
      AddDate('DATE_ENTER','DateTimePickerEnter','LabelDateEnter',true);
      AddDate('DATE_END','DateTimePickerEnd','LabelDateEnd',false);
      AddEdit('SERIAL_NUMBER','EditSerial','LabelSerial',false);
      AddEdit('INVENTORY_NUMBER','EditInventory','LabelInventory',false);
      AddEdit('FREQUENCY_TEST','EditFrequencyTest','LabelFrequencyTest',false);
      AddEditFloat('CLASS_ACCURACY','EditClass','LabelClass',false);
      AddEdit('RANGE_MEASURE','EditRange','LabelRange',false);
    end;
  end;
end;

{ TSgtsRbkInstrumentDeleteIface }

procedure TSgtsRbkInstrumentDeleteIface.Init;
begin
  inherited Init;
  InterfaceName:=SInterfaceInstrumentDelete;
  DeleteQuestion:='������� ������ %NAME?';
  with DataSet do begin
    ProviderName:=SProviderDeleteInstrument;
    with ExecuteDefs do begin
      AddKeyLink('INSTRUMENT_ID');
      AddInvisible('NAME');
    end;
  end;
end;

{ TSgtsRbkInstrumentEditForm }

constructor TSgtsRbkInstrumentEditForm.Create(ACoreIntf: ISgtsCore); 
begin
  inherited Create(ACoreIntf);
  DateTimePickerEnter.Date:=DateOf(Date);
end;

end.
