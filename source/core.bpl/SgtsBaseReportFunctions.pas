unit SgtsBaseReportFunctions;

interface

implementation

uses SysUtils, Classes, DB, DBClient, Variants, Controls, ComCtrls, Math, Dialogs,
     fs_iinterpreter,
     SgtsUtils, SgtsConsts, SgtsDataFm, SgtsCDS, SgtsCoreIntf,
     SgtsBaseReportClasses, SgtsPeriodFm, SgtsConfigIntf, SgtsDialogs,
     SgtsDatabaseModulesIntf, SgtsDatabaseIntf, SgtsBaseReportAdjustmentFm,
     SgtsBaseReportComponents;

type
  TFunctions=class(TfsRTTIModule)
  private
    FCatOther: String;
    function GetCoreIntf: ISgtsCore;
  public
    constructor Create(AScript: TfsScript); override;
    function SelectDataValues(Instance: TObject; ClassType: TClass; const MethodName: String; Caller: TfsMethodHelper): Variant;
    function SelectPeriod(Instance: TObject; ClassType: TClass; const MethodName: String; Caller: TfsMethodHelper): Variant;
    function WriteParam(Instance: TObject; ClassType: TClass; const MethodName: String; Caller: TfsMethodHelper): Variant;
    function ReadParam(Instance: TObject; ClassType: TClass; const MethodName: String; Caller: TfsMethodHelper): Variant;
    function ShowError(Instance: TObject; ClassType: TClass; const MethodName: String; Caller: TfsMethodHelper): Variant;
    function ShowInfo(Instance: TObject; ClassType: TClass; const MethodName: String; Caller: TfsMethodHelper): Variant;
    function ShowQuestion(Instance: TObject; ClassType: TClass; const MethodName: String; Caller: TfsMethodHelper): Variant;
    function RandomRange(Instance: TObject; ClassType: TClass; const MethodName: String; Caller: TfsMethodHelper): Variant;
    function StrToIntDef(Instance: TObject; ClassType: TClass; const MethodName: String; Caller: TfsMethodHelper): Variant;
    function TryStrToInt(Instance: TObject; ClassType: TClass; const MethodName: String; Caller: TfsMethodHelper): Variant;
    function TryStrToDate(Instance: TObject; ClassType: TClass; const MethodName: String; Caller: TfsMethodHelper): Variant;
    function GetPersonnel(Instance: TObject; ClassType: TClass; const MethodName: String; Caller: TfsMethodHelper): Variant;
    function GetPersonnelId(Instance: TObject; ClassType: TClass; const MethodName: String; Caller: TfsMethodHelper): Variant;
//    function SelectAdjustment(Instance: TObject; ClassType: TClass; const MethodName: String; Caller: TfsMethodHelper): Variant;
    function QuotedStr(Instance: TObject; ClassType: TClass; const MethodName: String; Caller: TfsMethodHelper): Variant;
  end;

{ TFunctions }

constructor TFunctions.Create(AScript: TfsScript);
begin
  inherited Create(AScript);
  FCatOther := 'ctOther';
  with AScript do begin
    AddMethod('function SelectDataValues(InterfaceName: String; InFields, OutFields: String; InValues: Variant; var OutValues: Variant): Boolean',
              SelectDataValues,FCatOther);
    AddType('TSgtsPeriodType',fvtInt);
    AddConst('ptYear','TSgtsPeriodType',ptYear);
    AddConst('ptQuarter','TSgtsPeriodType',ptQuarter);
    AddConst('ptMonth','TSgtsPeriodType',ptMonth);
    AddConst('ptDay','TSgtsPeriodType',ptDay);
    AddConst('ptInterval','TSgtsPeriodType',ptInterval);
    AddMethod('function SelectPeriod(var PeriodType: TSgtsPeriodType; var DateBegin, DateEnd: TDate): Boolean',SelectPeriod,FCatOther);
    AddType('TSgtsConfigMode',fvtInt);
    AddConst('cmDefault','TSgtsConfigMode',cmDefault);
    AddConst('cmBase64','TSgtsConfigMode',cmBase64);
    AddMethod('procedure WriteParam(const Section,Param: String; Value: Variant; Mode: TSgtsConfigMode=cmDefault)',WriteParam,FCatOther);
    AddMethod('function ReadParam(const Section,Param: String; Default: Variant; Mode: TSgtsConfigMode=cmDefault): Variant',ReadParam,FCatOther);

    AddType('TMsgDlgBtn',fvtInt);
    AddConst('mbYes','TMsgDlgBtn',mbYes);
    AddConst('mbNo','TMsgDlgBtn',mbNo);
    AddConst('mbOK','TMsgDlgBtn',mbOK);
    AddConst('mbCancel','TMsgDlgBtn',mbCancel);
    AddConst('mbAbort','TMsgDlgBtn',mbAbort);
    AddConst('mbRetry','TMsgDlgBtn',mbRetry);
    AddConst('mbIgnore','TMsgDlgBtn',mbIgnore);
    AddConst('mbAll','TMsgDlgBtn',mbAll);
    AddConst('mbNoToAll','TMsgDlgBtn',mbNoToAll);
    AddConst('mbYesToAll','TMsgDlgBtn',mbYesToAll);
    AddConst('mbHelp','TMsgDlgBtn',mbHelp);

    AddType('TModalResult',fvtInt);
    AddConst('mrNone','TModalResult',mrNone);
    AddConst('mrOk','TModalResult',mrOk);
    AddConst('mrCancel','TModalResult',mrCancel);
    AddConst('mrAbort','TModalResult',mrAbort);
    AddConst('mrRetry','TModalResult',mrRetry);
    AddConst('mrIgnore','TModalResult',mrIgnore);
    AddConst('mrYes','TModalResult',mrYes);
    AddConst('mrNo','TModalResult',mrNo);
    AddConst('mrAll','TModalResult',mrAll);
    AddConst('mrNoToAll','TModalResult',mrNoToAll);
    AddConst('mrYesToAll','TModalResult',mrYesToAll);

    AddMethod('function ShowError(Mess: String; UseTimer: Boolean=true): TModalResult',ShowError,FCatOther);
    AddMethod('function ShowInfo(Mess: String; UseTimer: Boolean=true): TModalResult',ShowInfo,FCatOther);
    AddMethod('function ShowQuestion(Mess: String; DefaultButton: TMsgDlgBtn=mbYes; UseTimer: Boolean=true): TModalResult',ShowQuestion,FCatOther);
    AddMethod('function RandomRange(const AFrom, ATo: Integer): Integer',RandomRange,FCatOther);
    AddMethod('function StrToIntDef(S: String; Default: Integer): Integer',StrToIntDef,FCatOther);
    AddMethod('function TryStrToInt(S: String; var Value: Integer): Boolean',TryStrToInt,FCatOther);
    AddMethod('function TryStrToDate(S: String; var Value: TDateTime): Boolean',TryStrToDate,FCatOther);
    AddMethod('function GetPersonnel(var FirstName: String; var SecondName: String; var LastName: String): String',GetPersonnel,FCatOther);
    AddMethod('function GetPersonnelId: Integer',GetPersonnelId,FCatOther);
    AddMethod('function QuotedStr(const S: string): string;',QuotedStr,FCatOther);

{    AddMethod('function SelectAdjustment(Columns: TSgtsColumns; DefaultColumns: TSgtsColumns; '+
                                        'Orders: TSgtsOrders; DefaultOrders: TSgtsOrders; '+
                                        'FilterGroups: TSgtsFilterGroups; DefaultFilterGroups: TSgtsFilterGroups): Boolean',SelectAdjustment,FCatOther);}
  end;
end;

function TFunctions.GetCoreIntf: ISgtsCore;
begin
  Result:=nil;
  if Assigned(Script.Report) then
    Result:=TSgtsBaseReport(Script.Report).CoreIntf;
end;

function TFunctions.SelectDataValues(Instance: TObject; ClassType: TClass;
                                     const MethodName: String; Caller: TfsMethodHelper): Variant;
var
  CoreIntf: ISgtsCore;

  function GetInterfaceClass(InterfaceName: String): TSgtsDataIfaceClass;
  var
    Str: TStringList;
    i: Integer;
  begin
    Result:=nil;
    Str:=TStringList.Create;
    try
      if Assigned(CoreIntf) then begin
        CoreIntf.GetInterfaceNames(Str,TSgtsDataIface);
        for i:=0 to Str.Count-1 do begin
          if AnsiSameText(Str.Strings[i],InterfaceName) then begin
            Result:=TSgtsDataIfaceClass(Str.Objects[i].ClassType);
            break;
          end;
        end;
      end;
    finally
      Str.Free;
    end;
  end;

var
  Iface: TSgtsDataIface;
  AClass: TSgtsDataIfaceClass;
  InFields: String;
  OutFields: String;
  InValues: Variant;
  OutValues: Variant;
  Buffer: String;
  DataSet: TSgtsCDS;
  Str: TStringList;
  i: Integer;
  Field: TField;
begin
  Result:=false;
  if AnsiSameText(MethodName,'SelectDataValues') then begin
    CoreIntf:=GetCoreIntf;
    AClass:=GetInterfaceClass(VarToStrDef(Caller.Params[0],''));
    if Assigned(AClass) then begin
      if IsClassParent(AClass,TSgtsDataIface) then begin
        Iface:=TSgtsDataIfaceClass(AClass).Create(CoreIntf);
        try
          InFields:=VarToStrDef(Caller.Params[1],'');
          OutFields:=VarToStrDef(Caller.Params[2],'');
          InValues:=Caller.Params[3];
          if Iface.SelectVisible(InFields,InValues,Buffer,nil) then begin
            DataSet:=TSgtsCDS.Create(nil);
            try
              DataSet.XMLData:=Buffer;
              if DataSet.Active then begin
                Str:=TStringList.Create;
                try
                  GetStringsByString(OutFields,';',Str);
                  for i:=Str.Count-1 downto 0 do begin
                    Field:=DataSet.FindField(Str.Strings[i]);
                    if not Assigned(Field) then
                      Str.Delete(i);
                  end;
                  if Str.Count>1 then begin
                    OutValues:=VarArrayCreate([0,Str.Count-1],varVariant);
                    for i:=0 to Str.Count-1 do begin
                      OutValues[i]:=DataSet.FieldByName(Str.Strings[i]).Value;
                    end;
                  end else begin
                    OutValues:=DataSet.FieldByName(Str.Strings[0]).Value;
                  end;
                  Caller.Params[4]:=OutValues;
                  Result:=true;
                finally
                  Str.Free;
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
end;

function TFunctions.SelectPeriod(Instance: TObject; ClassType: TClass;
                                 const MethodName: String; Caller: TfsMethodHelper): Variant;
var
  Iface: TSgtsPeriodIface;
  PeriodType: TSgtsPeriodType;
  DateBegin: TDate;
  DateEnd: TDate;
begin
  Result:=false;
  if AnsiSameText(MethodName,'SelectPeriod') then begin
    Iface:=TSgtsPeriodIface.Create(GetCoreIntf);
    try
      PeriodType:=TSgtsPeriodType(VarToIntDef(Caller.Params[0],Integer(ptYear)));
      DateBegin:=VarToDateDef(Caller.Params[1],Date);
      DateEnd:=VarToDateDef(Caller.Params[2],Date);
      if Iface.Select(PeriodType,DateBegin,DateEnd) then begin
        Caller.Params[0]:=PeriodType;
        Caller.Params[1]:=DateBegin;
        Caller.Params[2]:=DateEnd;
        Result:=true;
      end;
    finally
      Iface.Free;
    end;
  end;
end;

function TFunctions.WriteParam(Instance: TObject; ClassType: TClass; const MethodName: String; Caller: TfsMethodHelper): Variant;
var
  CoreIntf: ISgtsCore;
  Section, Param: String;
  Value: Variant;
  Mode: TSgtsConfigMode;
begin
  if AnsiSameText(MethodName,'WriteParam') then begin
    CoreIntf:=GetCoreIntf;
    if Assigned(CoreIntf) then begin
      Section:=VarToStrDef(Caller.Params[0],'');
      Param:=VarToStrDef(Caller.Params[1],'');
      Value:=Caller.Params[2];
      Mode:=TSgtsConfigMode(VarToIntDef(Caller.Params[3],0));
      CoreIntf.DatabaseConfig.Write(Section,Param,Value,Mode);
    end;
  end;
end;

function TFunctions.ReadParam(Instance: TObject; ClassType: TClass; const MethodName: String; Caller: TfsMethodHelper): Variant;
var
  CoreIntf: ISgtsCore;
  Section, Param: String;
  Default: Variant;
  Mode: TSgtsConfigMode;
begin
  if AnsiSameText(MethodName,'ReadParam') then begin
    CoreIntf:=GetCoreIntf;
    if Assigned(CoreIntf) then begin
      Section:=VarToStrDef(Caller.Params[0],'');
      Param:=VarToStrDef(Caller.Params[1],'');
      Default:=Caller.Params[2];
      Mode:=TSgtsConfigMode(VarToIntDef(Caller.Params[3],0));
      Result:=CoreIntf.DatabaseConfig.Read(Section,Param,Default,Mode);
    end;
  end;
end;

function TFunctions.ShowError(Instance: TObject; ClassType: TClass; const MethodName: String; Caller: TfsMethodHelper): Variant;
var
  Mess: String;
  UseTimer: Boolean;
begin
  Result:=mrNone;
  if AnsiSameText(MethodName,'ShowError') then begin
    Mess:=VarToStrDef(Caller.Params[0],'');
    UseTimer:=Boolean(VarToIntDef(Caller.Params[1],1));
    Result:=SgtsDialogs.ShowError(Mess,UseTimer);
  end;
end;

function TFunctions.ShowInfo(Instance: TObject; ClassType: TClass; const MethodName: String; Caller: TfsMethodHelper): Variant;
var
  Mess: String;
  UseTimer: Boolean;
begin
  Result:=mrNone;
  if AnsiSameText(MethodName,'ShowInfo') then begin
    Mess:=VarToStrDef(Caller.Params[0],'');
    UseTimer:=Boolean(VarToIntDef(Caller.Params[1],1));
    Result:=SgtsDialogs.ShowInfo(Mess,UseTimer);
  end;
end;

function TFunctions.ShowQuestion(Instance: TObject; ClassType: TClass; const MethodName: String; Caller: TfsMethodHelper): Variant;
var
  Mess: String;
  Button: TMsgDlgBtn;
  UseTimer: Boolean;
begin
  Result:=mrNo;
  if AnsiSameText(MethodName,'ShowQuestion') then begin
    Mess:=VarToStrDef(Caller.Params[0],'');
    Button:=TMsgDlgBtn(VarToIntDef(Caller.Params[1],Integer(mbNo)));
    UseTimer:=Boolean(VarToIntDef(Caller.Params[2],1));
    Result:=SgtsDialogs.ShowQuestion(Mess,Button,UseTimer);
  end;
end;

function TFunctions.RandomRange(Instance: TObject; ClassType: TClass; const MethodName: String; Caller: TfsMethodHelper): Variant;
var
  AFrom, ATo: Integer;
begin
  if AnsiSameText(MethodName,'RandomRange') then begin
    AFrom:=Caller.Params[0];
    ATo:=Caller.Params[1];
    Result:=Math.RandomRange(AFrom,ATo);
  end;
end;

function TFunctions.StrToIntDef(Instance: TObject; ClassType: TClass; const MethodName: String; Caller: TfsMethodHelper): Variant;
var
  S: String;
  Def: Integer;
begin
  Result:=VarToIntDef(Caller.Params[1],0);
  if AnsiSameText(MethodName,'StrToIntDef') then begin
    S:=VarToStrDef(Caller.Params[0],'');
    Def:=VarToIntDef(Caller.Params[1],0);
    Result:=SysUtils.StrToIntDef(S,Def);
  end;
end;

function TFunctions.TryStrToInt(Instance: TObject; ClassType: TClass; const MethodName: String; Caller: TfsMethodHelper): Variant;
var
  S: String;
  Def: Integer;
begin
  Result:=false;
  if AnsiSameText(MethodName,'TryStrToInt') then begin
    S:=VarToStrDef(Caller.Params[0],'');
    Result:=SysUtils.TryStrToInt(S,Def);
    if Result then begin
      Caller.Params[1]:=Def;
    end;
  end;
end;

function TFunctions.TryStrToDate(Instance: TObject; ClassType: TClass; const MethodName: String; Caller: TfsMethodHelper): Variant;
var
  S: String;
  Def: TDateTime;
begin
  Result:=false;
  if AnsiSameText(MethodName,'TryStrToDate') then begin
    S:=VarToStrDef(Caller.Params[0],'');
    Result:=SysUtils.TryStrToDate(S,Def);
    if Result then begin
      Caller.Params[1]:=Def;
    end;
  end;
end;

function TFunctions.GetPersonnel(Instance: TObject; ClassType: TClass; const MethodName: String; Caller: TfsMethodHelper): Variant;
var
  CoreIntf: ISgtsCore;
  Database: ISgtsDatabase;
begin
  Result:='';
  if AnsiSameText(MethodName,'GetPersonnel') then begin
    CoreIntf:=GetCoreIntf;
    if Assigned(CoreIntf) and
       Assigned(CoreIntf.DatabaseModules.Current) then begin
      Database:=CoreIntf.DatabaseModules.Current.Database;
      if Assigned(Database) then begin
        Result:=Database.Personnel;
        Caller.Params[0]:=Database.PersonnelFirstName;
        Caller.Params[1]:=Database.PersonnelSecondName;
        Caller.Params[2]:=Database.PersonnelLastName;
      end;
    end;
  end;
end;

function TFunctions.GetPersonnelId(Instance: TObject; ClassType: TClass; const MethodName: String; Caller: TfsMethodHelper): Variant;
var
  CoreIntf: ISgtsCore;
  Database: ISgtsDatabase;
begin
  Result:='';
  if AnsiSameText(MethodName,'GetPersonnelId') then begin
    CoreIntf:=GetCoreIntf;
    if Assigned(CoreIntf) and
       Assigned(CoreIntf.DatabaseModules.Current) then begin
      Database:=CoreIntf.DatabaseModules.Current.Database;
      if Assigned(Database) then begin
        Result:=Database.PersonnelId;
      end;
    end;
  end;
end;

function TFunctions.QuotedStr(Instance: TObject; ClassType: TClass; const MethodName: String; Caller: TfsMethodHelper): Variant;
begin
  Result:=Caller.Params[0];
  if AnsiSameText(MethodName,'QuotedStr') then begin
    Result:=SysUtils.QuotedStr(Caller.Params[0]);
  end;
end;

(*function TFunctions.SelectAdjustment(Instance: TObject; ClassType: TClass; const MethodName: String; Caller: TfsMethodHelper): Variant;
var
  Iface: TSgtsBaseReportAdjustmentIface;
  Columns: TSgtsColumns;
{  DefaultColumns: TSgtsColumns;
  Orders: TSgtsOrders;
  DefaultOrders: TSgtsOrders;
  FilterGroups: TSgtsFilterGroups;
  DefaultFilterGroups: TSgtsFilterGroups;}
begin
  Result:=false;
  if AnsiSameText(MethodName,'SelectAdjustment') then begin
    Columns:=TSgtsColumns(VarToIntDef(Caller.Params[0],0));
    Iface:=TSgtsBaseReportAdjustmentIface.Create(GetCoreIntf);
    try
      if Iface.Select(Columns) then begin

      end;
    finally
      Iface.Free;
    end;
  end;
end;*)

initialization
  fsRTTIModules.Add(TFunctions);

finalization
  if fsRTTIModules <> nil then fsRTTIModules.Remove(TFunctions);

end.
