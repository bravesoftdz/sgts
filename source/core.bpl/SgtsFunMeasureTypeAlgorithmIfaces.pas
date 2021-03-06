unit SgtsFunMeasureTypeAlgorithmIfaces;

interface

uses Classes, DB,
     SgtsRbkAlgorithmEditFm, SgtsRbkMeasureTypeAlgorithmEditFm,
     SgtsDataInsertBySelect, SgtsExecuteDefs, SgtsFm;

type

  TSgtsFunMeasureTypeAlgorithmInsertIface=class(TSgtsRbkMeasureTypeAlgorithmInsertIface)
  private
    FSelected: Boolean;
    FAlgorithmIdDef: TSgtsExecuteDefEditLink;
    FPriorityDef: TSgtsExecuteDefEditInteger;
    function GetPriority(Def: TSgtsExecuteDef): Variant;
  protected
    procedure AfterCreateForm(AForm: TSgtsForm); override;
    function NeedShow: Boolean; override;
  public
    procedure Init; override;
    procedure SetDefValues; override;
  end;

  TSgtsFunMeasureTypeAlgorithmUpdateIface=class(TSgtsRbkMeasureTypeAlgorithmUpdateIface)
  protected
    procedure AfterCreateForm(AForm: TSgtsForm); override;
  public
    procedure Init; override;
    procedure SetDefValues; override;
  end;

  TSgtsFunMeasureTypeAlgorithmDeleteIface=class(TSgtsRbkMeasureTypeAlgorithmDeleteIface)
  end;

implementation

uses SgtsConsts, SgtsProviderConsts, SgtsCDS,
     SgtsIface, SgtsDataEditFm, SgtsDatabaseCDS, SgtsRbkAlgorithmsFm;

{ TSgtsFunMeasureTypeAlgorithmInsertIface }

procedure TSgtsFunMeasureTypeAlgorithmInsertIface.Init;
begin
  inherited Init;
  with DataSet do begin
    with ExecuteDefs do begin
      FAlgorithmIdDef:=TSgtsExecuteDefEditLink(Find('ALGORITHM_ID'));
      FPriorityDef:=TSgtsExecuteDefEditInteger(Find('PRIORITY'));
    end;
  end;
end;

procedure TSgtsFunMeasureTypeAlgorithmInsertIface.AfterCreateForm(AForm: TSgtsForm);
begin
  inherited AfterCreateForm(AForm);
  if Assigned(Form) then begin
    with TSgtsRbkMeasureTypeAlgorithmEditForm(Form) do begin
      EditMeasureType.Enabled:=false;
      LabelMeasureType.Enabled:=false;
      ButtonMeasureType.Enabled:=false;
      FSelected:=FAlgorithmIdDef.Select;
    end;
  end;
end;

function TSgtsFunMeasureTypeAlgorithmInsertIface.NeedShow: Boolean;
begin
  Result:=inherited NeedShow and FSelected;
end;

function TSgtsFunMeasureTypeAlgorithmInsertIface.GetPriority(Def: TSgtsExecuteDef): Variant;
var
  DS: TSgtsCDS;
begin
  Result:=Def.DefaultValue;
  if Assigned(IfaceIntf) then begin
    DS:=TSgtsCDS.Create(nil);
    try
      DS.AddIndexDef(Def.FieldName,tsAsc);
      DS.Data:=IfaceIntf.DataSet.Data;
      if DS.Active then begin
        DS.SetIndexBySort(Def.FieldName,tsAsc);
        DS.Last;
        Result:=DS.FieldByName(Def.FieldName).AsInteger+1;
      end;
    finally
      DS.Free;
    end;
  end;
end;

procedure TSgtsFunMeasureTypeAlgorithmInsertIface.SetDefValues;
begin
  inherited SetDefValues;
  if Assigned(IfaceIntf) then begin
    FPriorityDef.DefaultValue:=GetPriority(FPriorityDef);
    FPriorityDef.SetDefault;
  end;
end;

{ TSgtsFunMeasureTypeAlgorithmUpdateIface }

procedure TSgtsFunMeasureTypeAlgorithmUpdateIface.Init;
begin
  inherited Init;
end;

procedure TSgtsFunMeasureTypeAlgorithmUpdateIface.AfterCreateForm(AForm: TSgtsForm);
begin
  inherited AfterCreateForm(AForm);
  if Assigned(Form) then begin
    with TSgtsRbkMeasureTypeAlgorithmEditForm(Form) do begin
      EditMeasureType.Enabled:=false;
      LabelMeasureType.Enabled:=false;
      ButtonMeasureType.Enabled:=false;
    end;
  end;
end;

procedure TSgtsFunMeasureTypeAlgorithmUpdateIface.SetDefValues;
begin
  inherited SetDefValues;
end;

end.
