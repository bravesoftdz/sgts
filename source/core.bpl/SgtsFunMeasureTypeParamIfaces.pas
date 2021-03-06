unit SgtsFunMeasureTypeParamIfaces;

interface

uses Classes, DB,
     SgtsRbkParamEditFm, SgtsRbkMeasureTypeParamEditFm,
     SgtsDataInsertBySelect, SgtsExecuteDefs;

type

  TSgtsFunMeasureTypeParamInsertIface=class(TSgtsDataInsertBySelectIface)
  private
    FPriorityDef: TSgtsExecuteDefCalc;
    FParamNameDef: TSgtsExecuteDefInvisible;
    FParamDescDef: TSgtsExecuteDefInvisible;
    function GetPriority(Def: TSgtsExecuteDefCalc): Variant;
  public
    procedure Init; override;
    procedure SetDefValues; override;
  end;

  TSgtsFunMeasureTypeParamUpdateIface=class(TSgtsRbkParamUpdateIface)
  private
    FParamNameDef: TSgtsExecuteDefEdit;
    FParamDescDef: TSgtsExecuteDefMemo;
  public
    procedure Init; override;
    procedure SetDefValues; override;
  end;

  TSgtsFunMeasureTypeParamDeleteIface=class(TSgtsRbkMeasureTypeParamDeleteIface)
  end;

implementation

uses SgtsConsts, SgtsProviderConsts, SgtsCDS,
     SgtsIface, SgtsDataEditFm, SgtsDatabaseCDS, SgtsRbkParamsFm;

{ TSgtsFunMeasureTypeParamInsertIface }

procedure TSgtsFunMeasureTypeParamInsertIface.Init;
begin
  inherited Init;
  SelectClass:=TSgtsRbkParamsIface;
  SelectMultiselect:=true;
  with DataSet do begin
    ProviderName:=SProviderInsertMeasureTypeParam;
    with ExecuteDefs do begin
      AddInvisible('MEASURE_TYPE_ID');
      AddInvisible('PARAM_ID');
      FPriorityDef:=AddCalc('PRIORITY',GetPriority);
      FParamNameDef:=AddInvisible('PARAM_NAME',ptUnknown);
      FParamNameDef.Twins.Add('NAME');
      FParamDescDef:=AddInvisible('PARAM_DESCRIPTION',ptUnknown);
      FParamDescDef.Twins.Add('DESCRIPTION');
      AddInvisible('ALGORITHM_NAME',ptUnknown);
      AddInvisible('ALGORITHM_ID',ptUnknown);
      AddInvisible('PARAM_TYPE',ptUnknown);
      AddInvisible('MEASURE_TYPE_NAME',ptUnknown);
      AddInvisible('PARAM_FORMAT',ptUnknown).Twins.Add('FORMAT');
    end;
  end;
end;

function TSgtsFunMeasureTypeParamInsertIface.GetPriority(Def: TSgtsExecuteDefCalc): Variant;
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

procedure TSgtsFunMeasureTypeParamInsertIface.SetDefValues; 
begin
  inherited SetDefValues;
  if Assigned(IfaceIntf) then begin
    FPriorityDef.DefaultValue:=GetPriority(FPriorityDef);
    FPriorityDef.SetDefault;
  end;
end;

{ TSgtsFunMeasureTypeParamUpdateIface }

procedure TSgtsFunMeasureTypeParamUpdateIface.Init;
begin
  inherited Init;
  with DataSet do begin
    with ExecuteDefs do begin
      FParamNameDef:=TSgtsExecuteDefEdit(Find('NAME'));
      FParamNameDef.Twins.Add('PARAM_NAME');
      FParamDescDef:=TSgtsExecuteDefMemo(Find('DESCRIPTION'));
      FParamDescDef.Twins.Add('PARAM_DESCRIPTION');
      Find('FORMAT').Twins.Add('PARAM_FORMAT');
    end;
  end;
end;

procedure TSgtsFunMeasureTypeParamUpdateIface.SetDefValues;
begin
  inherited SetDefValues;
end;

end.
