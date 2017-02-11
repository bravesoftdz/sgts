unit SgtsOraAdoDatabase;

interface

uses Classes, DB, ADODB, Variants, SysUtils, Contnrs,
     SgtsDatabase, SgtsProviders, SgtsGetRecordsConfig, SgtsExecuteConfig,
     SgtsDatabaseModulesIntf, SgtsDatabaseIntf, SgtsCDS, SgtsCoreIntf, SgtsVariants;

type
  TSgtsADOStoredProc=class;

  TSgtsADOProcedureCache=class(TObject)
  private
    FProc: TSgtsADOStoredProc;
  public
    constructor Create;
    destructor Destroy; override;
    procedure CopyFromParameters(Parameters: TParameters);
    procedure CopyToParameters(Parameters: TParameters);

    property Proc: TSgtsADOStoredProc read FProc write FProc;
  end;

  TSgtsADOProcedureCaches=class(TObjectList)
  private
    function GetItems(Index: Integer): TSgtsADOProcedureCache;
    procedure SetItems(Index: Integer; const Value: TSgtsADOProcedureCache);
  public
    function Find(ProcedureName: String): TSgtsADOProcedureCache;
    function Add(ProcedureName: String): TSgtsADOProcedureCache;

    property Items[Index: Integer]: TSgtsADOProcedureCache read GetItems write SetItems;
  end;

  TSgtsADOConnection=class(TADOConnection)
  end;

  TSgtsADOQuery=class(TADOQuery)
  public
    constructor Create(AOwner: TComponent); override;
    procedure GetFieldDefs(AFieldDefs: TFieldDefs);
  end;

  TSgtsADOTable=class(TADOTable)
  end;

  TSgtsADOCommand=class(TADOCommand)
  end;

  TSgtsADOStoredProc=class(TADOStoredProc)
  public
    procedure RefreshParameters;
  end;

  TSgtsOraAdoDatabaseObjectType=(dotUnknown,dotSequence);

  TSgtsOraAdoDatabase=class(TSgtsDatabase)
  private
    FDefConnection: TSgtsADOConnection;
    FConnection: TSgtsADOConnection;
    FDefConnectionString: String;
    FLogPermissions: Boolean;
    FPermissions: TSgtsCDS;
    FOutPutDir: String;
    FMaxOutputRecords: Integer;
    FFileProviders: String;
    FProviders: TStringList;
    FProcedureCaches: TSgtsADOProcedureCaches;

    procedure SetUserParams(Account: String);
    procedure ClearUserParams;
    procedure SetRoles;
    procedure SetPermissions;

    procedure DefConnectionWillExecute(Connection: TADOConnection;
                                        var CommandText: WideString; var CursorType: TCursorType;
                                        var LockType: TADOLockType; var CommandType: TCommandType;
                                        var ExecuteOptions: TExecuteOptions; var EventStatus: TEventStatus;
                                        const Command: _Command; const Recordset: _Recordset);
//    procedure SaveDebug(ACommand: TADOCommand);

    function ExecSql(SQL: String): Boolean;
    function UploadTable(XMLData: String; ProgressProc: TSgtsDatabaseProgressProc=nil): Boolean;
    function GetExecuteExceptionMessage(E: Exception): String;
    function GetValue(SQL,FieldName: String): Variant;
    function GetOutputPath: String;

    function GetObjectTypeByName(ObjectTypeName: String): TSgtsOraAdoDatabaseObjectType;
    function GetScript(ObjectName: String; ProgressProc: TSgtsDatabaseProgressProc=nil): String;
    function GetTableName(SQL: String; var Where: String): String;
    function GetTable(SQL: String; ProgressProc: TSgtsDatabaseProgressProc=nil): String;
    function GetTableAsScript(SQL: String; ProgressProc: TSgtsDatabaseProgressProc=nil): String;
    function GetTableAsFiles(SQL: String; ProgressProc: TSgtsDatabaseProgressProc=nil): String;

    function NeedAdditionalFields(Alias: String): Boolean;

  protected
    function GetConnected: Boolean; override;
    function GetGetRecordsProvidersClass: TSgtsGetRecordsProvidersClass; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure InitByModule(ACoreIntf: ISgtsCore; AModuleIntf: ISgtsDatabaseModule); override;

    function GetRecordsFilterDateValue(Value: TDateTime): String; override;
    function GetRecordsFieldName(Provider: TSgtsGetRecordsProvider; FieldName: TSgtsGetRecordsConfigFieldName): String; override;
    function GetRecordsFieldNames(Provider: TSgtsGetRecordsProvider; FieldNames: TSgtsGetRecordsConfigFieldNames): String; override;

    function Login(const Account, Password: String): Boolean; override;
    procedure Logout; override;
    function CheckPermission(const InterfaceName, Permission, Value: String): Boolean; override;
    function GetRecords(Provider: TSgtsGetRecordsProvider; Config: TSgtsGetRecordsConfig;
                        ProgressProc: TSgtsDatabaseProgressProc=nil): OleVariant; override;
    function GetNewId(Provider: TSgtsExecuteProvider): Variant; override;
    procedure Execute(Provider: TSgtsExecuteProvider; Config: TSgtsExecuteConfig); override;
    function LoginDefault(Params: String): Boolean; override;
    procedure LogoutDefault; override;
    function Install(Value: String; InstallType: TSgtsDatabaseInstallType; ProgressProc: TSgtsDatabaseProgressProc=nil): Boolean; override;
    function Export(Value: String; ExportType: TSgtsDatabaseExportType; ProgressProc: TSgtsDatabaseProgressProc=nil): String; override;
    procedure RefreshPermissions; override;
    procedure LoadConfig(Stream: TStream); override;
    procedure SaveConfig(Stream: TStream); override;

    property Connection: TSgtsADOConnection read FConnection;
  end;

implementation

uses DBClient, StrUtils, ComObj, OleDB, Dialogs, ADOInt, VarConv, TypInfo,
     SgtsUtils, SgtsConsts, SgtsLogIntf,
     SgtsOraAdoConsts, SgtsProviderConsts, SgtsOraAdoProviders,
     SgtsOraAdoPointManagementProviders, SgtsOraAdoPersonnelManagementProviders,
     SgtsConfigIntf;

{ TSgtsADOProcedureCache }

constructor TSgtsADOProcedureCache.Create;
begin
  inherited Create;
  FProc:=TSgtsADOStoredProc.Create(nil);
end;

destructor TSgtsADOProcedureCache.Destroy;
begin
  FProc.Free;
  inherited Destroy;
end;

procedure TSgtsADOProcedureCache.CopyFromParameters(Parameters: TParameters);
var
  i: Integer;
  Param: TParameter;
  NewParam: TParameter;
begin
  if Assigned(Parameters) then begin
    Proc.Parameters.Clear;
    for i:=0 to Parameters.Count-1 do begin
      Param:=Parameters.Items[i];
      NewParam:=Proc.Parameters.AddParameter;
      NewParam.Name:=Param.Name;
      NewParam.DataType:=Param.DataType;
      NewParam.Size:=Param.Size;
      NewParam.NumericScale:=Param.NumericScale;
      NewParam.Precision:=Param.Precision;
      NewParam.Direction:=Param.Direction;
      NewParam.Attributes:=Param.Attributes;

      NewParam.ParameterObject.Type_:=Param.ParameterObject.Type_;
      NewParam.ParameterObject.Value:=Param.ParameterObject.Value;
    end;
  end;
end;

procedure TSgtsADOProcedureCache.CopyToParameters(Parameters: TParameters);
var
  i: Integer;
  Param: TParameter;
  NewParam: TParameter;
begin
  if Assigned(Parameters) then begin
    Parameters.Clear;
    for i:=0 to Proc.Parameters.Count-1 do begin
      Param:=Proc.Parameters.Items[i];

      NewParam:=Parameters.CreateParameter(Param.Name,Param.DataType,Param.Direction,Param.Size,EmptyParam);
      NewParam.NumericScale:=Param.NumericScale;
      NewParam.Precision:=Param.Precision;
      NewParam.Direction:=Param.Direction;
      NewParam.Attributes:=Param.Attributes;

      NewParam.ParameterObject.Type_:=Param.ParameterObject.Type_;
      NewParam.ParameterObject.Value:=Param.ParameterObject.Value;

    end;
  end;
end;


{ TSgtsADOProcedureCaches }

function TSgtsADOProcedureCaches.GetItems(Index: Integer): TSgtsADOProcedureCache;
begin
  Result:=TSgtsADOProcedureCache(inherited Items[Index]);
end;

procedure TSgtsADOProcedureCaches.SetItems(Index: Integer; const Value: TSgtsADOProcedureCache);
begin
  inherited Items[Index]:=Value;
end;

function TSgtsADOProcedureCaches.Add(ProcedureName: String): TSgtsADOProcedureCache;
begin
  Result:=TSgtsADOProcedureCache.Create;
  Result.Proc.ProcedureName:=ProcedureName;
  inherited Add(Result);
end;

function TSgtsADOProcedureCaches.Find(ProcedureName: String): TSgtsADOProcedureCache;
var
  i: Integer;
begin
  Result:=nil;
  for i:=0 to Count-1 do begin
    if AnsiSameText(Items[i].Proc.ProcedureName,ProcedureName) then begin
      Result:=Items[i];
      Exit;
    end;
  end;
end;


{ TSgtsADOQuery }

constructor TSgtsADOQuery.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  CursorType:=ctStatic;
  LockType:=ltOptimistic;
  EnableBCD:=false;
end;

procedure TSgtsADOQuery.GetFieldDefs(AFieldDefs: TFieldDefs);
var
  i: Integer;
begin
  if Assigned(AFieldDefs) and
     Active then
    for i:=0 to Fields.Count-1 do begin
      with AFieldDefs.AddFieldDef do begin
        Name:=Fields[i].FieldName;
        DataType:=Fields[i].DataType;
        if DataType=ftAutoInc then
          DataType:=ftInteger;
        Size:=Fields[i].Size;
      end;
    end;
end;

{ TSgtsADOStoredProc }

procedure TSgtsADOStoredProc.RefreshParameters;
begin
end;

{ TSgtsOraAdoDatabase }

constructor TSgtsOraAdoDatabase.Create;
begin
  inherited Create;
  FDefConnection:=TSgtsADOConnection.Create(nil);
  FDefConnection.Mode:=cmRead;
  FConnection:=TSgtsADOConnection.Create(nil);
  FConnection.LoginPrompt:=false;
  FConnection.Mode:=cmReadWrite;
  FConnection.ConnectOptions:=coConnectUnspecified;

  FPermissions:=TSgtsCDS.Create(nil);

  FProviders:=TStringList.Create;

  FProcedureCaches:=TSgtsADOProcedureCaches.Create;

  FMaxOutputRecords:=MaxOutputRecords;

  with TSgtsOraAdoGetRecordsProviders(GetRecordsProviders) do begin

    AddGetRecords(SProviderSelectAccounts,SProviderAliasSelectAccounts);
    AddExecute(SProviderInsertAccount,SProviderAliasSelectAccounts);
    AddExecute(SProviderUpdateAccount,SProviderAliasSelectAccounts);
    AddExecute(SProviderDeleteAccount,SProviderAliasSelectAccounts);

    AddGetRecords(SProviderSelectRoles,SProviderAliasSelectRoles);
    AddExecute(SProviderInsertRole,SProviderAliasSelectRoles);
    AddExecute(SProviderUpdateRole,SProviderAliasSelectRoles);
    AddExecute(SProviderDeleteRole,SProviderAliasSelectRoles);

    AddGetRecords(SProviderSelectPersonnels,SProviderAliasSelectPersonnels);
    AddGetRecords(SProviderSelectPersonnelOnlyPerformers,SProviderAliasSelectPersonnelOnlyPerformers);
    AddExecute(SProviderInsertPersonnel,SProviderAliasSelectPersonnels);
    AddExecute(SProviderUpdatePersonnel,SProviderAliasSelectPersonnels);
    AddExecute(SProviderDeletePersonnel,SProviderAliasSelectPersonnels);

    AddGetRecords(SProviderSelectPermissions,SProviderAliasSelectPermissions);
    AddExecute(SProviderInsertPermission,SProviderAliasSelectPermissions);
    AddExecute(SProviderUpdatePermission,SProviderAliasSelectPermissions);
    AddExecute(SProviderDeletePermission,SProviderAliasSelectPermissions);

    AddGetRecords(SProviderSelectRolesAndAccounts,SProviderAliasSelectRolesAndAccounts);

    AddGetRecords(SProviderSelectAccountsRoles,SProviderAliasSelectAccountsRoles);
    AddExecute(SProviderInsertAccountRole,SProviderAliasSelectAccountsRoles);
    AddExecute(SProviderUpdateAccountRole,SProviderAliasSelectAccountsRoles);
    AddExecute(SProviderDeleteAccountRole,SProviderAliasSelectAccountsRoles);
    AddExecute(SProviderClearAccountRole,SProviderAliasSelectAccountsRoles);

    AddGetRecords(SProviderSelectDivisions,SProviderAliasSelectDivisions);
    AddExecute(SProviderInsertDivision,SProviderAliasSelectDivisions);
    AddExecute(SProviderUpdateDivision,SProviderAliasSelectDivisions);
    AddExecute(SProviderDeleteDivision,SProviderAliasSelectDivisions);

    AddGetRecords(SProviderSelectObjects,SProviderAliasSelectObjects);
    AddExecute(SProviderInsertObject,SProviderAliasSelectObjects);
    AddExecute(SProviderUpdateObject,SProviderAliasSelectObjects);
    AddExecute(SProviderDeleteObject,SProviderAliasSelectObjects);

    AddClass(TSgtsOraAdoSelectPointManagementProvider).InitByDataBase(Self);
    AddClass(TSgtsOraAdoInsertPointManagementProvider);

    AddClass(TSgtsOraAdoSelectPersonnelManagementProvider).InitByDataBase(Self);
    AddClass(TSgtsOraAdoInsertPersonnelManagementProvider);

    AddGetRecords(SProviderSelectPointTypes,SProviderAliasSelectPointTypes);
    AddExecute(SProviderInsertPointType,SProviderAliasSelectPointTypes);
    AddExecute(SProviderUpdatePointType,SProviderAliasSelectPointTypes);
    AddExecute(SProviderDeletePointType,SProviderAliasSelectPointTypes);

    AddGetRecords(SProviderSelectPoints,SProviderAliasSelectPoints);
    AddExecute(SProviderInsertPoint,SProviderAliasSelectPoints);
    AddExecute(SProviderUpdatePoint,SProviderAliasSelectPoints);
    AddExecute(SProviderDeletePoint,SProviderAliasSelectPoints);

    AddGetRecords(SProviderSelectRoutes,SProviderAliasSelectRoutes);
    AddExecute(SProviderInsertRoute,SProviderAliasSelectRoutes);
    AddExecute(SProviderUpdateRoute,SProviderAliasSelectRoutes);
    AddExecute(SProviderDeleteRoute,SProviderAliasSelectRoutes);

    AddGetRecords(SProviderSelectMeasureTypes,SProviderAliasSelectMeasureTypes);
    AddExecute(SProviderInsertMeasureType,SProviderAliasSelectMeasureTypes);
    AddExecute(SProviderUpdateMeasureType,SProviderAliasSelectMeasureTypes);
    AddExecute(SProviderDeleteMeasureType,SProviderAliasSelectMeasureTypes);

    AddGetRecords(SProviderSelectInstrumentTypes,SProviderAliasSelectInstrumentTypes);
    AddExecute(SProviderInsertInstrumentType,SProviderAliasSelectInstrumentTypes);
    AddExecute(SProviderUpdateInstrumentType,SProviderAliasSelectInstrumentTypes);
    AddExecute(SProviderDeleteInstrumentType,SProviderAliasSelectInstrumentTypes);

    AddGetRecords(SProviderSelectInstruments,SProviderAliasSelectInstruments);
    AddExecute(SProviderInsertInstrument,SProviderAliasSelectInstruments);
    AddExecute(SProviderUpdateInstrument,SProviderAliasSelectInstruments);
    AddExecute(SProviderDeleteInstrument,SProviderAliasSelectInstruments);

    AddGetRecords(SProviderSelectMeasureUnits,SProviderAliasSelectMeasureUnits);
    AddExecute(SProviderInsertMeasureUnit,SProviderAliasSelectMeasureUnits);
    AddExecute(SProviderUpdateMeasureUnit,SProviderAliasSelectMeasureUnits);
    AddExecute(SProviderDeleteMeasureUnit,SProviderAliasSelectMeasureUnits);

    AddGetRecords(SProviderSelectInstrumentUnits,SProviderAliasSelectInstrumentUnits);
    AddExecute(SProviderInsertInstrumentUnit,SProviderAliasSelectInstrumentUnits);
    AddExecute(SProviderUpdateInstrumentUnit,SProviderAliasSelectInstrumentUnits);
    AddExecute(SProviderDeleteInstrumentUnit,SProviderAliasSelectInstrumentUnits);

    AddGetRecords(SProviderSelectRoutePoints,SProviderAliasSelectRoutePoints);
    AddExecute(SProviderInsertRoutePoint,SProviderAliasSelectRoutePoints);
    AddExecute(SProviderUpdateRoutePoint,SProviderAliasSelectRoutePoints);
    AddExecute(SProviderDeleteRoutePoint,SProviderAliasSelectRoutePoints);

    AddGetRecords(SProviderSelectMeasureTypeRoutes,SProviderAliasSelectMeasureTypeRoutes);
    AddExecute(SProviderInsertMeasureTypeRoute,SProviderAliasSelectMeasureTypeRoutes);
    AddExecute(SProviderUpdateMeasureTypeRoute,SProviderAliasSelectMeasureTypeRoutes);
    AddExecute(SProviderDeleteMeasureTypeRoute,SProviderAliasSelectMeasureTypeRoutes);

    AddGetRecords(SProviderSelectPersonnelRoutes,SProviderAliasSelectPersonnelRoutes);
    AddExecute(SProviderInsertPersonnelRoute,SProviderAliasSelectPersonnelRoutes);
    AddExecute(SProviderUpdatePersonnelRoute,SProviderAliasSelectPersonnelRoutes);
    AddExecute(SProviderDeletePersonnelRoute,SProviderAliasSelectPersonnelRoutes);

    AddGetRecords(SProviderSelectCycles,SProviderAliasSelectCycles);
    AddExecute(SProviderInsertCycle,SProviderAliasSelectCycles);
    AddExecute(SProviderUpdateCycle,SProviderAliasSelectCycles);
    AddExecute(SProviderDeleteCycle,SProviderAliasSelectCycles);

    AddGetRecords(SProviderSelectPlans,SProviderAliasSelectPlans);
    AddExecute(SProviderInsertPlan,SProviderAliasSelectPlans);
    AddExecute(SProviderUpdatePlan,SProviderAliasSelectPlans);
    AddExecute(SProviderDeletePlan,SProviderAliasSelectPlans);

    AddGetRecords(SProviderSelectGraphs,SProviderAliasSelectGraphs);
    AddExecute(SProviderInsertGraph,SProviderAliasSelectGraphs);
    AddExecute(SProviderUpdateGraph,SProviderAliasSelectGraphs);
    AddExecute(SProviderDeleteGraph,SProviderAliasSelectGraphs);

    AddGetRecords(SProviderSelectObjectTrees,SProviderAliasSelectObjectTrees);
    AddExecute(SProviderInsertObjectTree,SProviderAliasSelectObjectTrees);
    AddExecute(SProviderUpdateObjectTree,SProviderAliasSelectObjectTrees);
    AddExecute(SProviderDeleteObjectTree,SProviderAliasSelectObjectTrees);

    AddGetRecords(SProviderSelectAlgorithms,SProviderAliasSelectAlgorithms);
    AddExecute(SProviderInsertAlgorithm,SProviderAliasSelectAlgorithms);
    AddExecute(SProviderUpdateAlgorithm,SProviderAliasSelectAlgorithms);
    AddExecute(SProviderDeleteAlgorithm,SProviderAliasSelectAlgorithms);

    AddGetRecords(SProviderSelectMeasureTypeAlgorithms,SProviderAliasSelectMeasureTypeAlgorithms);
    AddExecute(SProviderInsertMeasureTypeAlgorithm,SProviderAliasSelectMeasureTypeAlgorithms);
    AddExecute(SProviderUpdateMeasureTypeAlgorithm,SProviderAliasSelectMeasureTypeAlgorithms);
    AddExecute(SProviderDeleteMeasureTypeAlgorithm,SProviderAliasSelectMeasureTypeAlgorithms);

    AddGetRecords(SProviderSelectLevels,SProviderAliasSelectLevels);
    AddExecute(SProviderInsertLevel,SProviderAliasSelectLevels);
    AddExecute(SProviderUpdateLevel,SProviderAliasSelectLevels);
    AddExecute(SProviderDeleteLevel,SProviderAliasSelectLevels);

    AddGetRecords(SProviderSelectParams,SProviderAliasSelectParams);
    AddExecute(SProviderInsertParam,SProviderAliasSelectParams);
    AddExecute(SProviderUpdateParam,SProviderAliasSelectParams);
    AddExecute(SProviderDeleteParam,SProviderAliasSelectParams);

    AddGetRecords(SProviderSelectMeasureTypeParams,SProviderAliasSelectMeasureTypeParams);
    AddExecute(SProviderInsertMeasureTypeParam,SProviderAliasSelectMeasureTypeParams);
    AddExecute(SProviderUpdateMeasureTypeParam,SProviderAliasSelectMeasureTypeParams);
    AddExecute(SProviderDeleteMeasureTypeParam,SProviderAliasSelectMeasureTypeParams);

    AddGetRecords(SProviderSelectParamLevels,SProviderAliasSelectParamLevels);
    AddExecute(SProviderInsertParamLevel,SProviderAliasSelectParamLevels);
    AddExecute(SProviderUpdateParamLevel,SProviderAliasSelectParamLevels);
    AddExecute(SProviderDeleteParamLevel,SProviderAliasSelectParamLevels);

    AddGetRecords(SProviderSelectJournalFields,SProviderAliasSelectJournalFields);
    AddExecute(SProviderInsertJournalField,SProviderAliasSelectJournalFields);
    AddExecute(SProviderUpdateJournalField,SProviderAliasSelectJournalFields);
    AddExecute(SProviderDeleteJournalField,SProviderAliasSelectJournalFields);

    AddGetRecords(SProviderSelectJournalObservations,SProviderAliasSelectJournalObservations);
    AddExecute(SProviderInsertJournalObservation,SProviderAliasSelectJournalObservations);
    AddExecute(SProviderUpdateJournalObservation,SProviderAliasSelectJournalObservations);
    AddExecute(SProviderDeleteJournalObservation,SProviderAliasSelectJournalObservations);

    AddGetRecords(SProviderSelectMeasureTypePersonnels,SProviderAliasSelectMeasureTypePersonnels);

    AddGetRecords(SProviderSelectFileReports,SProviderAliasSelectFileReports);
    AddExecute(SProviderInsertFileReport,SProviderAliasSelectFileReports);
    AddExecute(SProviderUpdateFileReport,SProviderAliasSelectFileReports);
    AddExecute(SProviderDeleteFileReport,SProviderAliasSelectFileReports);

    AddGetRecords(SProviderSelectBaseReports,SProviderAliasSelectBaseReports);
    AddExecute(SProviderInsertBaseReport,SProviderAliasSelectBaseReports);
    AddExecute(SProviderUpdateBaseReport,SProviderAliasSelectBaseReports);
    AddExecute(SProviderDeleteBaseReport,SProviderAliasSelectBaseReports);

    AddGetRecords(SProviderSelectRouteObjects,SProviderAliasSelectRouteObjects);
    AddGetRecords(SProviderSelectMeasureTypePoints,SProviderAliasSelectMeasureTypePoints);
    AddGetRecords(SProviderSelectRouteConverters,SProviderAliasSelectRouteConverters);
    AddGetRecords(SProviderSelectMeasureTypeConverters,SProviderAliasSelectMeasureTypeConverters);

    AddGetRecords(SProviderSelectParamInstruments,SProviderAliasSelectParamInstruments);
    AddExecute(SProviderInsertParamInstrument,SProviderAliasSelectParamInstruments);
    AddExecute(SProviderUpdateParamInstrument,SProviderAliasSelectParamInstruments);
    AddExecute(SProviderDeleteParamInstrument,SProviderAliasSelectParamInstruments);

    AddGetRecords(SProviderSelectDocuments,SProviderAliasSelectDocuments);
    AddExecute(SProviderInsertDocument,SProviderAliasSelectDocuments);
    AddExecute(SProviderUpdateDocument,SProviderAliasSelectDocuments);
    AddExecute(SProviderDeleteDocument,SProviderAliasSelectDocuments);

    AddGetRecords(SProviderSelectPointDocuments,SProviderAliasSelectPointDocuments);
    AddExecute(SProviderInsertPointDocument,SProviderAliasSelectPointDocuments);
    AddExecute(SProviderUpdatePointDocument,SProviderAliasSelectPointDocuments);
    AddExecute(SProviderDeletePointDocument,SProviderAliasSelectPointDocuments);

    AddGetRecords(SProviderSelectConverters,SProviderAliasSelectConverters);
    AddExecute(SProviderInsertConverter,SProviderAliasSelectConverters);
    AddExecute(SProviderUpdateConverter,SProviderAliasSelectConverters);
    AddExecute(SProviderDeleteConverter,SProviderAliasSelectConverters);

    AddGetRecords(SProviderSelectComponents,SProviderAliasSelectComponents);
    AddExecute(SProviderInsertComponent,SProviderAliasSelectComponents);
    AddExecute(SProviderUpdateComponent,SProviderAliasSelectComponents);
    AddExecute(SProviderDeleteComponent,SProviderAliasSelectComponents);

    AddGetRecords(SProviderSelectDevices,SProviderAliasSelectDevices);
    AddExecute(SProviderInsertDevice,SProviderAliasSelectDevices);
    AddExecute(SProviderUpdateDevice,SProviderAliasSelectDevices);
    AddExecute(SProviderDeleteDevice,SProviderAliasSelectDevices);

    AddGetRecords(SProviderSelectDevicePoints,SProviderAliasSelectDevicePoints);
    AddExecute(SProviderInsertDevicePoint,SProviderAliasSelectDevicePoints);
    AddExecute(SProviderUpdateDevicePoint,SProviderAliasSelectDevicePoints);
    AddExecute(SProviderDeleteDevicePoint,SProviderAliasSelectDevicePoints);

    AddGetRecords(SProviderSelectDrawings,SProviderAliasSelectDrawings);
    AddExecute(SProviderInsertDrawing,SProviderAliasSelectDrawings);
    AddExecute(SProviderUpdateDrawing,SProviderAliasSelectDrawings);
    AddExecute(SProviderDeleteDrawing,SProviderAliasSelectDrawings);

    AddGetRecords(SProviderSelectObjectDrawings,SProviderAliasSelectObjectDrawings);
    AddExecute(SProviderInsertObjectDrawing,SProviderAliasSelectObjectDrawings);
    AddExecute(SProviderUpdateObjectDrawing,SProviderAliasSelectObjectDrawings);
    AddExecute(SProviderDeleteObjectDrawing,SProviderAliasSelectObjectDrawings);

    AddGetRecords(SProviderSelectObjectDocuments,SProviderAliasSelectObjectDocuments);
    AddExecute(SProviderInsertObjectDocument,SProviderAliasSelectObjectDocuments);
    AddExecute(SProviderUpdateObjectDocument,SProviderAliasSelectObjectDocuments);
    AddExecute(SProviderDeleteObjectDocument,SProviderAliasSelectObjectDocuments);

    AddGetRecords(SProviderSelectConverterPassports,SProviderAliasSelectConverterPassports);
    AddExecute(SProviderInsertConverterPassport,SProviderAliasSelectConverterPassports);
    AddExecute(SProviderUpdateConverterPassport,SProviderAliasSelectConverterPassports);
    AddExecute(SProviderDeleteConverterPassport,SProviderAliasSelectConverterPassports);

    AddGetRecords(SProviderSelectInstrumentPassports,SProviderAliasSelectInstrumentPassports);
    AddExecute(SProviderInsertInstrumentPassport,SProviderAliasSelectInstrumentPassports);
    AddExecute(SProviderUpdateInstrumentPassport,SProviderAliasSelectInstrumentPassports);
    AddExecute(SProviderDeleteInstrumentPassport,SProviderAliasSelectInstrumentPassports);

    AddGetRecords(SProviderSelectPointPassports,SProviderAliasSelectPointPassports);
    AddExecute(SProviderInsertPointPassport,SProviderAliasSelectPointPassports);
    AddExecute(SProviderUpdatePointPassport,SProviderAliasSelectPointPassports);
    AddExecute(SProviderDeletePointPassport,SProviderAliasSelectPointPassports);

    AddGetRecords(SProviderSelectObjectPassports,SProviderAliasSelectObjectPassports);
    AddExecute(SProviderInsertObjectPassport,SProviderAliasSelectObjectPassports);
    AddExecute(SProviderUpdateObjectPassport,SProviderAliasSelectObjectPassports);
    AddExecute(SProviderDeleteObjectPassport,SProviderAliasSelectObjectPassports);

    AddGetRecords(SProviderSelectInstrumentComponents,SProviderAliasSelectInstrumentComponents);

    AddGetRecords(SProviderSelectJournalActions,SProviderAliasSelectJournalActions);

    AddGetRecords(SProviderSelectMeasureTypeUnits,SProviderAliasSelectMeasureTypeUnits);

    AddGetRecords(SProviderSelectInterfaceReports,SProviderAliasSelectInterfaceReports);
    AddExecute(SProviderInsertInterfaceReport,SProviderAliasSelectInterfaceReports);
    AddExecute(SProviderUpdateInterfaceReport,SProviderAliasSelectInterfaceReports);
    AddExecute(SProviderDeleteInterfaceReport,SProviderAliasSelectInterfaceReports);

    AddGetRecords(SProviderSelectCheckings,SProviderAliasSelectCheckings);
    AddExecute(SProviderInsertChecking,SProviderAliasSelectCheckings);
    AddExecute(SProviderUpdateChecking,SProviderAliasSelectCheckings);
    AddExecute(SProviderDeleteChecking,SProviderAliasSelectCheckings);

    AddGetRecords(SProviderSelectCuts,SProviderAliasSelectCuts);
    AddExecute(SProviderInsertCut,SProviderAliasSelectCuts);
    AddExecute(SProviderUpdateCut,SProviderAliasSelectCuts);
    AddExecute(SProviderDeleteCut,SProviderAliasSelectCuts);

    AddGetRecords(SProviderSelectPointInstruments,SProviderAliasSelectPointInstruments);
    AddExecute(SProviderInsertPointInstrument,SProviderAliasSelectPointInstruments);
    AddExecute(SProviderUpdatePointInstrument,SProviderAliasSelectPointInstruments);
    AddExecute(SProviderDeletePointInstrument,SProviderAliasSelectPointInstruments);

    AddGetRecords(SProviderSelectGmoJournalObservations,SProviderAliasSelectGmoJournalObservations);
    AddGetRecords(SProviderSelectPzmJournalObservationsGmo,SProviderAliasSelectPzmJournalObservationsGmo);
    AddGetRecords(SProviderSelectFltJournalObservationsGmo,SProviderAliasSelectFltJournalObservationsGmo);
    AddGetRecords(SProviderSelectHmzJournalObservationsGmo,SProviderAliasSelectHmzJournalObservationsGmo);
    AddGetRecords(SProviderSelectHmzIntensity,SProviderAliasSelectHmzIntensity);
    AddGetRecords(SProviderSelectTvlJournalObservationsGmo,SProviderAliasSelectTvlJournalObservationsGmo);

    AddGetRecords(SProviderSelectGroups,SProviderAliasSelectGroups);
    AddExecute(SProviderInsertGroup,SProviderAliasSelectGroups);
    AddExecute(SProviderUpdateGroup,SProviderAliasSelectGroups);
    AddExecute(SProviderDeleteGroup,SProviderAliasSelectGroups);

    AddGetRecords(SProviderSelectGroupObjects,SProviderAliasSelectGroupObjects);
    AddExecute(SProviderInsertGroupObject,SProviderAliasSelectGroupObjects);
    AddExecute(SProviderUpdateGroupObject,SProviderAliasSelectGroupObjects);
    AddExecute(SProviderDeleteGroupObject,SProviderAliasSelectGroupObjects);

    AddGetRecords(SProviderSelectDefectViews,SProviderAliasSelectDefectViews);
    AddExecute(SProviderInsertDefectView,SProviderAliasSelectDefectViews);
    AddExecute(SProviderUpdateDefectView,SProviderAliasSelectDefectViews);
    AddExecute(SProviderDeleteDefectView,SProviderAliasSelectDefectViews);

    AddGetRecords(SProviderSelectJournalCheckups,SProviderAliasSelectJournalCheckups);
    AddExecute(SProviderInsertJournalCheckup,SProviderAliasSelectJournalCheckups);
    AddExecute(SProviderUpdateJournalCheckup,SProviderAliasSelectJournalCheckups);
    AddExecute(SProviderDeleteJournalCheckup,SProviderAliasSelectJournalCheckups);

    AddGetRecords(SProviderSelectDocCheckups,SProviderAliasSelectDocCheckups);
    AddExecute(SProviderInsertDocCheckup,SProviderAliasSelectDocCheckups);
    AddExecute(SProviderUpdateDocCheckup,SProviderAliasSelectDocCheckups);
    AddExecute(SProviderDeleteDocCheckup,SProviderAliasSelectDocCheckups);

    AddGetRecords(SProviderSelectCriterias,SProviderAliasSelectCriterias);
    AddExecute(SProviderInsertCriteria,SProviderAliasSelectCriterias);
    AddExecute(SProviderUpdateCriteria,SProviderAliasSelectCriterias);
    AddExecute(SProviderDeleteCriteria,SProviderAliasSelectCriterias);
  end;

  with ExecuteProviders do begin
    AddInsert(SProviderInsertAccount,SProviderAliasInsertAccount,SProviderKeyQueryDual,SFieldAccountId);
    AddUpdate(SProviderUpdateAccount,SProviderAliasInsertAccount);
    AddDelete(SProviderDeleteAccount,SProviderAliasInsertAccount);

    AddInsert(SProviderInsertRole,SProviderAliasInsertRole,SProviderKeyQueryDual,SFieldAccountId);
    AddUpdate(SProviderUpdateRole,SProviderAliasInsertRole);
    AddDelete(SProviderDeleteRole,SProviderAliasInsertRole);

    AddInsert(SProviderInsertPersonnel,SProviderAliasInsertPersonnel,SProviderKeyQueryDual,SFieldPersonnelId);
    AddUpdate(SProviderUpdatePersonnel,SProviderAliasInsertPersonnel);
    AddDelete(SProviderDeletePersonnel,SProviderAliasInsertPersonnel);

    AddInsert(SProviderInsertPermission,SProviderAliasInsertPermission,SProviderKeyQueryDual,SFieldPermissionId);
    AddUpdate(SProviderUpdatePermission,SProviderAliasInsertPermission);
    AddDelete(SProviderDeletePermission,SProviderAliasInsertPermission);

    AddInsert(SProviderInsertAccountRole,SProviderAliasInsertAccountRole);
    AddUpdate(SProviderUpdateAccountRole,SProviderAliasInsertAccountRole);
    AddDelete(SProviderDeleteAccountRole,SProviderAliasInsertAccountRole);
    AddDelete(SProviderClearAccountRole,SProviderAliasInsertAccountRole);

    AddInsert(SProviderInsertDivision,SProviderAliasInsertDivision,SProviderKeyQueryDual,SFieldDivisionId);
    AddUpdate(SProviderUpdateDivision,SProviderAliasInsertDivision);
    AddDelete(SProviderDeleteDivision,SProviderAliasInsertDivision);
    AddDefault(SProviderAuditDivisionParentId);

    AddInsert(SProviderInsertObject,SProviderAliasInsertObject,SProviderKeyQueryDual,SFieldObjectId);
    AddUpdate(SProviderUpdateObject,SProviderAliasInsertObject);
    AddDelete(SProviderDeleteObject,SProviderAliasInsertObject);

    AddInsert(SProviderInsertPersonnelManagement,SProviderAliasInsertPersonnelManagement,SProviderKeyQueryDual,SFieldPersonnelManagementId);

    AddInsert(SProviderInsertPointManagement,SProviderAliasInsertPointManagement,SProviderKeyQueryDual,SFieldPointManagementId);

    AddInsert(SProviderInsertPointType,SProviderAliasInsertPointType,SProviderKeyQueryDual,SFieldPointTypeId);
    AddUpdate(SProviderUpdatePointType,SProviderAliasInsertPointType);
    AddDelete(SProviderDeletePointType,SProviderAliasInsertPointType);

    AddInsert(SProviderInsertPoint,SProviderAliasInsertPoint,SProviderKeyQueryDual,SFieldPointId);
    AddUpdate(SProviderUpdatePoint,SProviderAliasInsertPoint);
    AddDelete(SProviderDeletePoint,SProviderAliasInsertPoint);

    AddInsert(SProviderInsertRoute,SProviderAliasInsertRoute,SProviderKeyQueryDual,SFieldRouteId);
    AddUpdate(SProviderUpdateRoute,SProviderAliasInsertRoute);
    AddDelete(SProviderDeleteRoute,SProviderAliasInsertRoute);

    AddInsert(SProviderInsertMeasureType,SProviderAliasInsertMeasureType,SProviderKeyQueryDual,SFieldMeasureTypeId);
    AddUpdate(SProviderUpdateMeasureType,SProviderAliasInsertMeasureType);
    AddDelete(SProviderDeleteMeasureType,SProviderAliasInsertMeasureType);
    AddDefault(SProviderAuditMeasureTypeParentId);

    AddInsert(SProviderInsertInstrumentType,SProviderAliasInsertInstrumentType,SProviderKeyQueryDual,SFieldInstrumentTypeId);
    AddUpdate(SProviderUpdateInstrumentType,SProviderAliasInsertInstrumentType);
    AddDelete(SProviderDeleteInstrumentType,SProviderAliasInsertInstrumentType);

    AddInsert(SProviderInsertInstrument,SProviderAliasInsertInstrument,SProviderKeyQueryDual,SFieldInstrumentId);
    AddUpdate(SProviderUpdateInstrument,SProviderAliasInsertInstrument);
    AddDelete(SProviderDeleteInstrument,SProviderAliasInsertInstrument);

    AddInsert(SProviderInsertMeasureUnit,SProviderAliasInsertMeasureUnit,SProviderKeyQueryDual,SFieldMeasureUnitId);
    AddUpdate(SProviderUpdateMeasureUnit,SProviderAliasInsertMeasureUnit);
    AddDelete(SProviderDeleteMeasureUnit,SProviderAliasInsertMeasureUnit);

    AddInsert(SProviderInsertInstrumentUnit,SProviderAliasInsertInstrumentUnit);
    AddUpdate(SProviderUpdateInstrumentUnit,SProviderAliasInsertInstrumentUnit);
    AddDelete(SProviderDeleteInstrumentUnit,SProviderAliasInsertInstrumentUnit);

    AddInsert(SProviderInsertRoutePoint,SProviderAliasInsertRoutePoint);
    AddUpdate(SProviderUpdateRoutePoint,SProviderAliasInsertRoutePoint);
    AddDelete(SProviderDeleteRoutePoint,SProviderAliasInsertRoutePoint);

    AddInsert(SProviderInsertMeasureTypeRoute,SProviderAliasInsertMeasureTypeRoute);
    AddUpdate(SProviderUpdateMeasureTypeRoute,SProviderAliasInsertMeasureTypeRoute);
    AddDelete(SProviderDeleteMeasureTypeRoute,SProviderAliasInsertMeasureTypeRoute);

    AddInsert(SProviderInsertPersonnelRoute,SProviderAliasInsertPersonnelRoute);
    AddUpdate(SProviderUpdatePersonnelRoute,SProviderAliasInsertPersonnelRoute);
    AddDelete(SProviderDeletePersonnelRoute,SProviderAliasInsertPersonnelRoute);

    AddInsert(SProviderInsertCycle,SProviderAliasInsertCycle,SProviderKeyQueryDual,SFieldCycleId);
    AddUpdate(SProviderUpdateCycle,SProviderAliasInsertCycle);
    AddDelete(SProviderDeleteCycle,SProviderAliasInsertCycle);

    AddInsert(SProviderInsertPlan,SProviderAliasInsertPlan,SProviderKeyQueryDual,SFieldPlanId);
    AddUpdate(SProviderUpdatePlan,SProviderAliasInsertPlan);
    AddDelete(SProviderDeletePlan,SProviderAliasInsertPlan);

    AddInsert(SProviderInsertGraph,SProviderAliasInsertGraph,SProviderKeyQueryDual,SFieldGraphId);
    AddUpdate(SProviderUpdateGraph,SProviderAliasInsertGraph);
    AddDelete(SProviderDeleteGraph,SProviderAliasInsertGraph);

    AddInsert(SProviderInsertObjectTree,SProviderAliasInsertObjectTree,SProviderKeyQueryDual,SFieldObjectTreeId);
    AddUpdate(SProviderUpdateObjectTree,SProviderAliasInsertObjectTree);
    AddDelete(SProviderDeleteObjectTree,SProviderAliasInsertObjectTree);
    AddDefault(SProviderGetObjectPaths);

    AddInsert(SProviderInsertAlgorithm,SProviderAliasInsertAlgorithm,SProviderKeyQueryDual,SFieldAlgorithmId);
    AddUpdate(SProviderUpdateAlgorithm,SProviderAliasInsertAlgorithm);
    AddDelete(SProviderDeleteAlgorithm,SProviderAliasInsertAlgorithm);

    AddInsert(SProviderInsertMeasureTypeAlgorithm,SProviderAliasInsertMeasureTypeAlgorithm);
    AddUpdate(SProviderUpdateMeasureTypeAlgorithm,SProviderAliasInsertMeasureTypeAlgorithm);
    AddDelete(SProviderDeleteMeasureTypeAlgorithm,SProviderAliasInsertMeasureTypeAlgorithm);

    AddInsert(SProviderInsertLevel,SProviderAliasInsertLevel,SProviderKeyQueryDual,SFieldLevelId);
    AddUpdate(SProviderUpdateLevel,SProviderAliasInsertLevel);
    AddDelete(SProviderDeleteLevel,SProviderAliasInsertLevel);

    AddInsert(SProviderInsertParam,SProviderAliasInsertParam,SProviderKeyQueryDual,SFieldParamId);
    AddUpdate(SProviderUpdateParam,SProviderAliasInsertParam);
    AddDelete(SProviderDeleteParam,SProviderAliasInsertParam);

    AddInsert(SProviderInsertMeasureTypeParam,SProviderAliasInsertMeasureTypeParam);
    AddUpdate(SProviderUpdateMeasureTypeParam,SProviderAliasInsertMeasureTypeParam);
    AddDelete(SProviderDeleteMeasureTypeParam,SProviderAliasInsertMeasureTypeParam);

    AddInsert(SProviderInsertParamLevel,SProviderAliasInsertParamLevel);
    AddUpdate(SProviderUpdateParamLevel,SProviderAliasInsertParamLevel);
    AddDelete(SProviderDeleteParamLevel,SProviderAliasInsertParamLevel);

    AddInsert(SProviderInsertJournalField,SProviderAliasInsertJournalField,SProviderKeyQueryDual,SFieldJournalFieldId);
    AddUpdate(SProviderUpdateJournalField,SProviderAliasInsertJournalField);
    AddDelete(SProviderDeleteJournalField,SProviderAliasInsertJournalField);

    AddInsert(SProviderInsertJournalObservation,SProviderAliasInsertJournalObservation,SProviderKeyQueryDual,SFieldJournalObservationId);
    AddUpdate(SProviderUpdateJournalObservation,SProviderAliasInsertJournalObservation);
    AddDelete(SProviderDeleteJournalObservation,SProviderAliasInsertJournalObservation);

    AddInsert(SProviderInsertFileReport,SProviderAliasInsertFileReport,SProviderKeyQueryDual,SFieldFileReportId);
    AddUpdate(SProviderUpdateFileReport,SProviderAliasInsertFileReport);
    AddDelete(SProviderDeleteFileReport,SProviderAliasInsertFileReport);

    AddInsert(SProviderInsertBaseReport,SProviderAliasInsertBaseReport,SProviderKeyQueryDual,SFieldBaseReportId);
    AddUpdate(SProviderUpdateBaseReport,SProviderAliasInsertBaseReport);
    AddDelete(SProviderDeleteBaseReport,SProviderAliasInsertBaseReport);

    AddInsert(SProviderInsertParamInstrument,SProviderAliasInsertParamInstrument);
    AddUpdate(SProviderUpdateParamInstrument,SProviderAliasInsertParamInstrument);
    AddDelete(SProviderDeleteParamInstrument,SProviderAliasInsertParamInstrument);

    AddInsert(SProviderInsertDocument,SProviderAliasInsertDocument,SProviderKeyQueryDual,SFieldDocumentId);
    AddUpdate(SProviderUpdateDocument,SProviderAliasInsertDocument);
    AddDelete(SProviderDeleteDocument,SProviderAliasInsertDocument);

    AddInsert(SProviderInsertPointDocument,SProviderAliasInsertPointDocument);
    AddUpdate(SProviderUpdatePointDocument,SProviderAliasInsertPointDocument);
    AddDelete(SProviderDeletePointDocument,SProviderAliasInsertPointDocument);

    AddInsert(SProviderInsertConverter,SProviderAliasInsertConverter);
    AddUpdate(SProviderUpdateConverter,SProviderAliasInsertConverter);
    AddDelete(SProviderDeleteConverter,SProviderAliasInsertConverter);

    AddInsert(SProviderInsertComponent,SProviderAliasInsertComponent,SProviderKeyQueryDual,SFieldComponentId);
    AddUpdate(SProviderUpdateComponent,SProviderAliasInsertComponent);
    AddDelete(SProviderDeleteComponent,SProviderAliasInsertComponent);

    AddInsert(SProviderInsertDevice,SProviderAliasInsertDevice,SProviderKeyQueryDual,SFieldDeviceId);
    AddUpdate(SProviderUpdateDevice,SProviderAliasInsertDevice);
    AddDelete(SProviderDeleteDevice,SProviderAliasInsertDevice);

    AddInsert(SProviderInsertDevicePoint,SProviderAliasInsertDevicePoint);
    AddUpdate(SProviderUpdateDevicePoint,SProviderAliasInsertDevicePoint);
    AddDelete(SProviderDeleteDevicePoint,SProviderAliasInsertDevicePoint);

    AddInsert(SProviderInsertDrawing,SProviderAliasInsertDrawing,SProviderKeyQueryDual,SFieldDrawingId);
    AddUpdate(SProviderUpdateDrawing,SProviderAliasInsertDrawing);
    AddDelete(SProviderDeleteDrawing,SProviderAliasInsertDrawing);

    AddInsert(SProviderInsertObjectDrawing,SProviderAliasInsertObjectDrawing);
    AddUpdate(SProviderUpdateObjectDrawing,SProviderAliasInsertObjectDrawing);
    AddDelete(SProviderDeleteObjectDrawing,SProviderAliasInsertObjectDrawing);

    AddInsert(SProviderInsertObjectDocument,SProviderAliasInsertObjectDocument);
    AddUpdate(SProviderUpdateObjectDocument,SProviderAliasInsertObjectDocument);
    AddDelete(SProviderDeleteObjectDocument,SProviderAliasInsertObjectDocument);

    AddInsert(SProviderInsertConverterPassport,SProviderAliasInsertConverterPassport,SProviderKeyQueryDual,SFieldConverterPassportId);
    AddUpdate(SProviderUpdateConverterPassport,SProviderAliasInsertConverterPassport);
    AddDelete(SProviderDeleteConverterPassport,SProviderAliasInsertConverterPassport);

    AddInsert(SProviderInsertInstrumentPassport,SProviderAliasInsertInstrumentPassport,SProviderKeyQueryDual,SFieldInstrumentPassportId);
    AddUpdate(SProviderUpdateInstrumentPassport,SProviderAliasInsertInstrumentPassport);
    AddDelete(SProviderDeleteInstrumentPassport,SProviderAliasInsertInstrumentPassport);

    AddInsert(SProviderInsertPointPassport,SProviderAliasInsertPointPassport,SProviderKeyQueryDual,SFieldPointPassportId);
    AddUpdate(SProviderUpdatePointPassport,SProviderAliasInsertPointPassport);
    AddDelete(SProviderDeletePointPassport,SProviderAliasInsertPointPassport);

    AddInsert(SProviderInsertObjectPassport,SProviderAliasInsertObjectPassport,SProviderKeyQueryDual,SFieldObjectPassportId);
    AddUpdate(SProviderUpdateObjectPassport,SProviderAliasInsertObjectPassport);
    AddDelete(SProviderDeleteObjectPassport,SProviderAliasInsertObjectPassport);

    AddInsert(SProviderInsertInterfaceReport,SProviderAliasInsertInterfaceReport,SProviderKeyQueryDual,SFieldInterfaceReportId);
    AddUpdate(SProviderUpdateInterfaceReport,SProviderAliasInsertInterfaceReport);
    AddDelete(SProviderDeleteInterfaceReport,SProviderAliasInsertInterfaceReport);

    AddInsert(SProviderInsertChecking,SProviderAliasInsertChecking,SProviderKeyQueryDual,SFieldCheckingId);
    AddUpdate(SProviderUpdateChecking,SProviderAliasInsertChecking);
    AddDelete(SProviderDeleteChecking,SProviderAliasInsertChecking);

    AddInsert(SProviderInsertCut,SProviderAliasInsertCut,SProviderKeyQueryDual,SFieldCutId);
    AddUpdate(SProviderUpdateCut,SProviderAliasInsertCut);
    AddDelete(SProviderDeleteCut,SProviderAliasInsertCut);

    AddInsert(SProviderInsertPointInstrument,SProviderAliasInsertPointInstrument);
    AddUpdate(SProviderUpdatePointInstrument,SProviderAliasInsertPointInstrument);
    AddDelete(SProviderDeletePointInstrument,SProviderAliasInsertPointInstrument);

    AddInsert(SProviderInsertGroup,SProviderAliasInsertGroup,SProviderKeyQueryDual,SFieldGroupId);
    AddUpdate(SProviderUpdateGroup,SProviderAliasInsertGroup);
    AddDelete(SProviderDeleteGroup,SProviderAliasInsertGroup);

    AddInsert(SProviderInsertGroupObject,SProviderAliasInsertGroupObject);
    AddUpdate(SProviderUpdateGroupObject,SProviderAliasInsertGroupObject);
    AddDelete(SProviderDeleteGroupObject,SProviderAliasInsertGroupObject);

    AddDefault(SProviderReorderPriorityInRoute);

    AddInsert(SProviderInsertDefectView,SProviderAliasInsertDefectView,SProviderKeyQueryDual,SFieldDefectViewId);
    AddUpdate(SProviderUpdateDefectView,SProviderAliasInsertDefectView);
    AddDelete(SProviderDeleteDefectView,SProviderAliasInsertDefectView);

    AddInsert(SProviderInsertJournalCheckup,SProviderAliasInsertJournalCheckup,SProviderKeyQueryDual,SFieldJournalCheckupId);
    AddUpdate(SProviderUpdateJournalCheckup,SProviderAliasInsertJournalCheckup);
    AddDelete(SProviderDeleteJournalCheckup,SProviderAliasInsertJournalCheckup);

    AddInsert(SProviderInsertDocCheckup,SProviderAliasInsertDocCheckup,SProviderKeyQueryDual,SFieldDocCheckupId);
    AddUpdate(SProviderUpdateDocCheckup,SProviderAliasInsertDocCheckup);
    AddDelete(SProviderDeleteDocCheckup,SProviderAliasInsertDocCheckup);
    AddDefault(SProviderDeleteDocCheckupJournal);

    AddInsert(SProviderInsertCriteria,SProviderAliasInsertCriteria,SProviderKeyQueryDual,SFieldCriteriaId);
    AddUpdate(SProviderUpdateCriteria,SProviderAliasInsertCriteria);
    AddDelete(SProviderDeleteCriteria,SProviderAliasInsertCriteria);

    AddDefault(SProviderConfirmAll);

  end;
end;

destructor TSgtsOraAdoDatabase.Destroy;
begin
  FProcedureCaches:=nil;
  FProviders:=nil;
  FPermissions:=nil;
  FConnection:=nil;
  FDefConnection:=nil;
  inherited Destroy;
end;

procedure TSgtsOraAdoDatabase.InitByModule(ACoreIntf: ISgtsCore; AModuleIntf: ISgtsDatabaseModule);
var
  Str: TStringList;
  i: Integer;
  S: String;
begin
  inherited InitByModule(ACoreIntf,AModuleIntf);
  with ACoreIntf.Config do begin
    FDefConnectionString:=Read(AModuleIntf.Name,SConfigParamConnectionString,FDefConnection.ConnectionString);
    FDefConnection.ConnectionTimeout:=Read(AModuleIntf.Name,SConfigParamConnectionTimeout,FDefConnection.ConnectionTimeout);
    FConnection.ConnectionTimeout:=FDefConnection.ConnectionTimeout;
    FLogPermissions:=Read(AModuleIntf.Name,SConfigParamLogPermissions,FLogPermissions);
    FOutPutDir:=Read(AModuleIntf.Name,SConfigParamOutputDir,FOutPutDir);
    FMaxOutputRecords:=Read(AModuleIntf.Name,SConfigParamMaxOutputRecords,FMaxOutputRecords);
    FFileProviders:=Read(AModuleIntf.Name,SConfigParamFileProviders,FFileProviders);
  end;

  if FileExists(FFileProviders) then
    FProviders.LoadFromFile(FFileProviders);


  AddConnectionParam(SConnectionParamDataSource,SConnectionParamDataSourceDesc,SDbDataSource);
  AddConnectionParam(SConnectionParamUserName,SConnectionParamUserNameDesc,SDbUserName);
  AddConnectionParam(SConnectionParamPassword,SConnectionParamPasswordDesc,SDbPassword);

  Str:=TStringList.Create;
  try
    GetStringsByString(FDefConnectionString,';',Str);
    for i:=0 to Str.Count-1 do begin
      S:=Str.ValueFromIndex[i];
      if AnsiSameText(Str.Names[i],SConnectionDataSource) then begin
        DbSource:=iff(AnsiSameText(S,'%'+SConnectionParamDataSource),'',S);
        ReplaceConnectionParam(SConnectionParamDataSource,SConnectionParamDataSourceDesc,DbSource);
      end;
      if AnsiSameText(Str.Names[i],SConnectionUserId) then begin
        DbUserName:=iff(AnsiSameText(S,'%'+SConnectionParamUserName),'',S);
        ReplaceConnectionParam(SConnectionParamUserName,SConnectionParamUserNameDesc,DbUserName);
      end;
      if AnsiSameText(Str.Names[i],SConnectionPassword) then begin
        DbPassword:=iff(AnsiSameText(S,'%'+SConnectionParamPassword),'',S);
        ReplaceConnectionParam(SConnectionParamPassword,SConnectionParamPasswordDesc,DbPassword);
      end;                                
    end;
  finally
    Str.Free;
  end;

  with FDefConnection do begin
    ConnectionString:=FDefConnectionString;
    LoginPrompt:=False;
  end;
end;

function TSgtsOraAdoDatabase.GetGetRecordsProvidersClass: TSgtsGetRecordsProvidersClass; 
begin
  Result:=TSgtsOraAdoGetRecordsProviders;
end;

procedure TSgtsOraAdoDatabase.ClearUserParams;
begin
  Account:='';
  Password:='';
  AccountId:='';
end;

function TSgtsOraAdoDatabase.Login(const Account, Password: String): Boolean;
begin
  Result:=false;
  LogWrite(Format('Login Account=%s start...',[Account]));
  try
    ClearUserParams;
    with FConnection do begin
      if Connected then
        Connected:=false;
      if not Connected then begin
        FConnection.ConnectionString:=FDefConnection.ConnectionString;

        FDefConnection.Connected:=true;
        try
          SetUserParams(Account);
        finally
          FDefConnection.Connected:=false;
        end;

        if Trim(AccountId)<>'' then
          if not AnsiSameText(Self.Password,Password) then begin
            LogWrite(Format('Login Account=%s failed:%s',[Account,SInvalidUserNameOrPassword]),ltError);
            raise Exception.Create(SInvalidUserNameOrPassword);
          end;
        try
          Open(DbUserName,DbPassword);
          FDefConnection.Connected:=true;
          Result:=Connected;
        finally
          if Result then begin
            if Trim(AccountId)='' then begin
              Connected:=false;
              ClearUserParams;
              Result:=false;
            end;
            if not Result then begin
              LogWrite(Format('Login Account=%s failed:%s',[Account,SInvalidUserNameOrPassword]),ltError);
              raise Exception.Create(SInvalidUserNameOrPassword);
            end;
            SetRoles;
            SetPermissions;
            LogWrite(Format('Login Account=%s success',[Account]));
          end else begin
            ClearUserParams;
          end;
        end;
      end;
    end;
  except
    On E: Exception do begin
      LogWrite(Format('Login Account=%s failed=%s',[Account,SInvalidUserNameOrPassword]),ltError);
      raise;
    end;
  end;  
end;

procedure TSgtsOraAdoDatabase.Logout;
begin
  with FConnection do
    if Connected then begin
      try
        Connected:=false;
        LogWrite('Logout success');
      except
        On E: Exception do begin
          LogWrite(Format('Logout failed=%s',[E.Message]),ltError);
        end;
      end;
    end;
end;

procedure TSgtsOraAdoDatabase.SetUserParams(Account: String);
var
  Query: TSgtsADOQuery;
  DbUser,DbPass: String;
begin
  if FDefConnection.Connected then begin
    Query:=TSgtsADOQuery.Create(nil);
    try
      Query.Connection:=FDefConnection;
      Query.SQL.Text:=Format(SSQLGetUserParams,[QuotedStr(Account)]);
      Query.Open;
      Query.First;
      if Query.Active and not Query.IsEmpty then begin
        Self.Account:=Account;
        Self.AccountId:=Query.FieldByName(SFieldAccountId).Value;
        Self.Password:=Query.FieldByName(SFieldPassword).AsString;

        Self.Personnel:=Query.FieldByName(SFieldPersonnelName).AsString;
        Self.PersonnelId:=Query.FieldByName(SFieldPersonnelId).Value;
        Self.PersonnelFirstName:=Query.FieldByName(SFieldFirstName).AsString;
        Self.PersonnelSecondName:=Query.FieldByName(SFieldSecondName).AsString;
        Self.PersonnelLastName:=Query.FieldByName(SFieldLastName).AsString;

        DbUser:=Query.FieldByName(SFieldDbUser).AsString;
        DbPass:=Query.FieldByName(SFieldDbPass).AsString;

        if Trim(DbUser)<>'' then
          Self.DbUserName:=DbUser;
        if Trim(DbPass)<>'' then
          Self.DbPassword:=DbPass;
      end;
    finally
      Query.Free;
    end;
  end;   
end;

function TSgtsOraAdoDatabase.GetConnected: Boolean;
begin
  Result:=FConnection.Connected;
end;

function TSgtsOraAdoDatabase.GetRecordsFilterDateValue(Value: TDateTime): String;
var
  CurrentFormat: String;
begin
  CurrentFormat:='DD.MM.YYYY HH:MI:SS';
  Result:=Format('TO_DATE(%s,%s)',[QuotedStr(DateTimeToStr(Value)),QuotedStr(CurrentFormat)]);
end;

procedure TSgtsOraAdoDatabase.SetRoles;
var
  Query: TSgtsADOQuery;
begin
  if FDefConnection.Connected then begin
    Query:=TSgtsADOQuery.Create(nil);
    try
      Query.Connection:=FDefConnection;
      Query.SQL.Text:=Format(SSQLGetRoles,[AccountId]);
      Query.Open;
      Query.First;
      if Query.Active then begin
        Roles.Clear;
        while not Query.Eof do begin
          Roles.Add(Query.FieldByName(SFieldName).AsString,Query.FieldByName(SFieldRoleId).AsString);
          Query.Next;
        end;
      end;
    finally
      Query.Free;
    end;
  end;  
end;

procedure TSgtsOraAdoDatabase.SetPermissions;
var
  Query: TSgtsADOQuery;
  RolesIds: String;
begin
  if FDefConnection.Connected then begin
    Query:=TSgtsADOQuery.Create(nil);
    try
      RolesIds:=Roles.GetIds;
      if Trim(RolesIds)='' then
        RolesIds:=AccountId;
      Query.Connection:=FDefConnection;
      Query.SQL.Text:=Format(SSQLGetPermission,[AccountId,RolesIds]);
      Query.Open;
      Query.First;
      if Query.Active and not Query.IsEmpty then begin
        FPermissions.Close;
        FPermissions.CreateDataSetBySource(Query,true,true);
      end;
    finally
      Query.Free;
    end;
  end;
end;

function TSgtsOraAdoDatabase.CheckPermission(const InterfaceName, Permission, Value: String): Boolean;
begin
  Result:=false;
  if FPermissions.Active and
     not FPermissions.IsEmpty then begin
    FPermissions.BeginUpdate;
    try
      FPermissions.Filter:=Format('INTERFACE=%s AND PERMISSION=%s AND PERMISSION_VALUE=%s',
                                  [QuotedStr(InterfaceName),QuotedStr(Permission),QuotedStr(Value)]);
      FPermissions.Filtered:=true;
      Result:=FPermissions.RecordCount>0;
      if FLogPermissions then
        LogWrite(Format('CheckPermission InterfaceName=%s Permission=%s Value=%s %s',
                        [InterfaceName,Permission,Value,iff(Result,'success','failed')]));
    finally
      FPermissions.EndUpdate;
    end;
  end;
end;

function TSgtsOraAdoDatabase.NeedAdditionalFields(Alias: String): Boolean;
var
  Strings: TStringList;
  i: Integer;
  APos: Integer;
begin
  Result:=false;
  Strings:=TStringList.Create;
  try
   Strings.Duplicates:=dupIgnore;
   Strings.AddStrings(FProviders);
   
 {  Strings.Add(SProviderAliasSelectGmoJournalObservations);
   Strings.Add(SProviderAliasSelectPzmJournalObservationsGmo);
   Strings.Add(SProviderAliasSelectFltJournalObservationsGmo);
   Strings.Add(SProviderAliasSelectHmzJournalObservationsGmo);
   Strings.Add(SProviderAliasSelectTvlJournalObservationsGmo);
   Strings.Add(SProviderAliasSelectIndJournalObservationsGmo);
   Strings.Add(SProviderAliasSelectSl1JournalObservationsGmo);
   Strings.Add(SProviderAliasSelectSlwJournalObservationsGmo);
   Strings.Add(SProviderAliasSelectSlfJournalObservationsGmo);
   Strings.Add(SProviderAliasSelectOtvJournalObservationsGmo);
   Strings.Add(SProviderAliasSelectSosJournalObservationsGmo);  }

   for i:=0 to Strings.Count-1 do begin
     APos:=AnsiPos(Strings[i],Alias);
     if APos=1 then begin
       Result:=true;
       break;
     end;

   end;

  finally
    Strings.Free;
  end;
end;

function TSgtsOraAdoDatabase.GetRecordsFieldName(Provider: TSgtsGetRecordsProvider; FieldName: TSgtsGetRecordsConfigFieldName): String;
begin
  Result:=inherited GetRecordsFieldName(Provider,FieldName);
  if NeedAdditionalFields(Provider.Alias) then begin
    if AnsiSameText(FieldName.Name,'RAIN_PERIOD') then
      Result:='SUM(RAIN_DAY) OVER(ORDER BY DATE_OBSERVATION) AS RAIN_PERIOD';
    if AnsiSameText(FieldName.Name,'DAY_OBSERVATION') then
      Result:='TRUNC(DATE_OBSERVATION-TO_DATE(''01.01.''||TO_CHAR(EXTRACT(YEAR FROM MIN(DATE_OBSERVATION) OVER (ORDER BY DATE_OBSERVATION))),''DD.MM.YYYY''))+1 AS DAY_OBSERVATION';
    if AnsiSameText(FieldName.Name,'MONTH_NAME') then
      Result:='TO_CHAR(DATE_OBSERVATION, ''DD MON'') AS MONTH_NAME';
  end;
end;

function TSgtsOraAdoDatabase.GetRecordsFieldNames(Provider: TSgtsGetRecordsProvider; FieldNames: TSgtsGetRecordsConfigFieldNames): String;
begin
  Result:=inherited GetRecordsFieldNames(Provider,FieldNames);
  if NeedAdditionalFields(Provider.Alias) then begin
    if not Assigned(FieldNames.Find('RAIN_PERIOD')) then
      Result:=Format('%s,%s',[Result,'SUM(RAIN_DAY) OVER(ORDER BY DATE_OBSERVATION) AS RAIN_PERIOD']);
    if not Assigned(FieldNames.Find('DAY_OBSERVATION')) then
      Result:=Format('%s,%s',[Result,'TRUNC(DATE_OBSERVATION-TO_DATE(''01.01.''||TO_CHAR(EXTRACT(YEAR FROM MIN(DATE_OBSERVATION) OVER (ORDER BY DATE_OBSERVATION))),''DD.MM.YYYY''))+1 AS DAY_OBSERVATION']);
    if not Assigned(FieldNames.Find('MONTH_NAME')) then
      Result:=Format('%s,%s',[Result,'TO_CHAR(DATE_OBSERVATION, ''DD MON'') AS MONTH_NAME']);
  end;
end;

{function TSgtsOraAdoDatabase.GetRecords(Provider: TSgtsGetRecordsProvider; Config: TSgtsGetRecordsConfig;
                                        ProgressProc: TSgtsDatabaseProgressProc=nil): OleVariant;
var
  Query: TSgtsADOQuery;
  DSOut: TSgtsCDS;
  Params: String;
  Filters: String;
  FieldNames: String;
  Orders: String;
  Groups: String;
  RealCount: Integer;
  RecCount: Integer;
  StartPos: Integer;
  Position: Integer;
  Breaked: Boolean;
  QuerySQL: String;
begin
  LogWrite(Format('GetRecords Provider=%s start...',[Provider.Name]));
  try
    Result:=inherited GetRecords(Provider,Config);
    if FConnection.Connected then begin
      Query:=TSgtsADOQuery.Create(nil);
      DSOut:=TSgtsCDS.Create(nil);
      try
        Query.Connection:=FConnection;

        FieldNames:=GetRecordsFieldNames(Provider,Config.FieldNames);
        Params:=GetRecordsParams(Config.Params);
        Filters:=GetRecordsFilterGroups(Config.FilterGroups);
        if Trim(Filters)<>'' then
          Filters:=' '+Filters;
        Groups:=GetRecordsGroups(Provider,Config.FieldNames);
        if Trim(Groups)<>'' then
          Groups:=' '+Groups;
        Orders:=GetRecordsOrders(Config.Orders);
        if Trim(Orders)<>'' then
          Orders:=' '+Orders;

        QuerySQL:=Trim(Format(SSqlGetRecords,[FieldNames,Provider.Alias,Params,Filters,Groups,Orders]));

        if (Config.FetchCount<>-1) then begin
          Query.Sql.Text:=Trim(Format(SSqlGetRecordsCount,[QuerySQL]));
          LogWrite(Format('GetRecords Provider=%s SQLCount='+#13#10+'%s',[Provider.Name,Trim(Query.Sql.Text)]));
          Query.Open;

          Config.AllCount:=0;
          if not Query.IsEmpty then
            Config.AllCount:=Query.Fields[0].AsInteger;
        end else begin
          Config.AllCount:=MaxInt;
        end;


        Query.Close;
        Query.SQL.Text:=QuerySQL;
        LogWrite(Format('GetRecords Provider=%s SQL='+#13#10+'%s',[Provider.Name,Trim(Query.Sql.Text)]));
        Query.Open;

        if Query.Active then  begin

          if (Config.FetchCount=-1) then
            Config.AllCount:=Query.RecordCount;

          StartPos:=Config.StartPos;

          RealCount:=Config.FetchCount;
          if RealCount<0 then begin
            RealCount:=Config.AllCount-StartPos
          end else begin
            if (StartPos+RealCount)>Config.AllCount then
              RealCount:=Config.AllCount-StartPos;
          end;

          RecCount:=0;
          Breaked:=false;
          Position:=1;
          DSOut.CreateDataSetBySource(Query);
          DSOut.LogChanges:=false;
          while not Query.Eof do begin
            if (RecCount>=StartPos) then begin
              if (RecCount<(StartPos+RealCount)) then begin
                DSOut.FieldValuesBySource(Query,true);
              end else
                break;
            end;
            ProgressByProc(ProgressProc,0,RealCount,Position,Breaked);
            if Breaked then
              Break;
            Inc(RecCount);
            Inc(Position);
            Query.Next;
          end;

          if DSOut.Active then begin
            DSOut.MergeChangeLog;
            DSOut.First;
            Result:=DSOut.Data;
            Config.RecsOut:=DSOut.RecordCount;
            LogWrite(Format('GetRecords Provider=%s StartPos=%d RecordCount=%d success',[Provider.Name,StartPos,Config.RecsOut]));
          end;
        end;

      finally
        DSOut.Free;
        Query.Free;
      end;
    end;
  except
    On E: Exception do begin
      LogWrite(Format('GetRecords Provider=%s failed=%s',[Provider.Name,E.Message]),ltError);
      raise;
    end;
  end;
end;}

function TSgtsOraAdoDatabase.GetRecords(Provider: TSgtsGetRecordsProvider; Config: TSgtsGetRecordsConfig;
                                        ProgressProc: TSgtsDatabaseProgressProc=nil): OleVariant;

var
  OldTypes: TStringList;

  procedure SetEmptyValue(Param: TParameter);
  begin
    case Param.DataType of
      ftString: begin
        Param.Value:='';
        Param.Size:=MaxVarchar2;
      end;
    else
      OldTypes.AddObject(IntToStr(Integer(Param.DataType)),Param);

      Param.DataType:=ftString;
      Param.Value:='';
      Param.Size:=MaxVarchar2;
    end;
  end;

  function ConvertLocal(DataType: TDataType; Value: Variant): Variant;
  var
    VType: Word;
    DType: TDataType;
    S: String;
  begin
    Result:=Value;
    if not VarIsNull(Value) then begin
      VType:=VarType(Value);
      DType:=VarTypeToDataType(VType);
      if (DataType<>DType) and (DType in [ftString,ftWideString]) then begin
        S:=VarToStrDef(Value,'');
        case DataType of
          ftString: Result:=S;
          ftFloat: begin
            S:=ChangeChar(S,'.',DecimalSeparator);
            Result:=VarToExtendedDef(S,0.0);
          end;
          ftBCD: begin
            Result:=VarToIntDef(S,0);
          end; 
        end;
      end;
    end;
  end;

  function GetOldType(Param: TParameter): TDataType;
  var
    Index: Integer;
  begin
    Result:=Param.DataType;
    Index:=OldTypes.IndexOfObject(Param);
    if Index<>-1 then begin
      Result:=TDataType(StrToInt(OldTypes.Strings[Index]));
    end;
  end;

var
  Query: TSgtsADOQuery;
  Proc: TSgtsADOStoredProc;
  DataSet: TCustomADODataSet;
  RecordCount: Integer;
  DSOut: TSgtsCDS;
  Params: String;
  Filters: String;
  FieldNames: String;
  Orders: String;
  Groups: String;
  RealCount: Integer;
  RecCount: Integer;
  StartPos: Integer;
  Position: Integer;
  Breaked: Boolean;
  QuerySQL: String;
  DataExists: Boolean;
  FlagSSPPrmsLob: Boolean;
  i: Integer;
  Param: TParameter;
  Item: TSgtsExecuteConfigParam;
  Stream: TStringStream;
  S: String;
begin
  LogWrite(Format('GetRecords Provider=%s start...',[Provider.Name]));
  try
    Result:=inherited GetRecords(Provider,Config);
    if FConnection.Connected then begin
      Proc:=TSgtsADOStoredProc.Create(nil);
      Query:=TSgtsADOQuery.Create(nil);
      DSOut:=TSgtsCDS.Create(nil);
      try
        DataExists:=false;
        RecordCount:=0;
        DataSet:=nil;
        LogWrite(Format('GetRecords OpenMode=%s',[GetEnumName(TypeInfo(TSgtsGetRecordsConfigOpenMode),Integer(Config.OpenMode))]));
        
        if Config.OpenMode=omOpen then begin

          DataSet:=Query;
          Query.Connection:=FConnection;

          FieldNames:=GetRecordsFieldNames(Provider,Config.FieldNames);
          Params:=GetRecordsParams(Config.Params);
          Filters:=GetRecordsFilterGroups(Config.FilterGroups);
          if Trim(Filters)<>'' then
            Filters:=' '+Filters;
          Groups:=GetRecordsGroups(Provider,Config.FieldNames);
          if Trim(Groups)<>'' then
            Groups:=' '+Groups;
          Orders:=GetRecordsOrders(Config.Orders);
          if Trim(Orders)<>'' then
            Orders:=' '+Orders;

          QuerySQL:=Trim(Format(SSqlGetRecords,[FieldNames,Provider.Alias,Params,Filters,Groups,Orders]));

          if (Config.FetchCount<>-1) then begin
            Query.Sql.Text:=Trim(Format(SSqlGetRecordsCount,[QuerySQL]));
            LogWrite(Format('GetRecords Provider=%s SQLCount='+#13#10+'%s',[Provider.Name,Trim(Query.Sql.Text)]));
            Query.Open;

            Config.AllCount:=0;
            if not Query.IsEmpty then
              Config.AllCount:=Query.Fields[0].AsInteger;
          end else begin
            Config.AllCount:=MaxInt;
          end;

          Query.Close;
          Query.SQL.Text:=QuerySQL;
          LogWrite(Format('GetRecords Provider=%s SQL='+#13#10+'%s',[Provider.Name,Trim(Query.Sql.Text)]));
          Query.Open;

          DataExists:=Query.Active;
          RecordCount:=Query.RecordCount;

        end else begin

          OldTypes:=TStringList.Create;
          try
            try
              DataSet:=Proc;
              Proc.Connection:=FConnection;
              Proc.ProcedureName:=Provider.Name;
              Proc.Parameters.Refresh;

              FlagSSPPrmsLob:=false;

              for i:=Proc.Parameters.Count-1 downto 0 do begin
                Param:=Proc.Parameters.Items[i];
                if Param.DataType in [ftInterface] then begin
                  Proc.Parameters.Delete(i);
                end else
                  if not (Param.Direction in [pdUnknown,pdReturnValue]) then begin
                    Param.Value:=Null;
                  end;
              end;

              with Config.Params do begin
                for i:=0 to Count-1 do begin
                  Item:=Items[i];
                  Param:=Proc.Parameters.FindParam(GetExecuteParamFieldName(Item));
                  if Assigned(Param) then begin
                    if Item.ParamType in [ptInput,ptOutput,ptInputOutput] then begin
                      if Item.ParamType in [ptInput] then begin
                        case Param.DataType of
                          ftBlob,ftMemo,ftVarBytes: begin
                            if not VarIsNull(Item.Value) then begin
                              Stream:=TStringStream.Create(VarToStrDef(Item.Value,''));
                              try
                                if Stream.Size>0 then begin
                                  FlagSSPPrmsLob:=true;
                                  Param.LoadFromStream(Stream,Param.DataType);
                                end;
                              finally
                                Stream.Free;
                              end;
                            end;
                          end;
                        else
                          Param.Value:=Item.Value;
                        end;
                      end else begin
                        if VarIsNull(Item.Value) then begin
                          SetEmptyValue(Param);
                        end else Param.Value:=Item.Value;
                      end;

                      if Item.ParamType in [ptOutput,ptInputOutput] then begin
                        Param.Size:=iff((Param.Size<>-1) or
                                        ((Param.Size=-1) and (Item.Size=0)),
                                        Param.Size,
                                        Item.Size);
                      end;

                      S:='NULL';
                      if not VarIsNull(Item.Value) then
                        S:=Copy(VarToStrDef(Item.Value,''),1,300);
                      LogWrite(Format('GetRecords Provider=%s Param=%s Value=%s',[Provider.Name,Param.Name,S]));
                    end;
                  end;
                end;
              end;

              Proc.Command.CommandObject.Set_ActiveConnection(Proc.Connection.ConnectionObject);
              Proc.Command.Properties[SPLSQLRSet].Value:=true;
              if FlagSSPPrmsLob then begin
                Proc.Command.Properties[SSPPrmsLob].Value:=true;
                LogWrite(Format('GetRecords Provider=%s SPPrmsLob=true',[Provider.Name]));
              end;

              try

                Config.AllCount:=MaxInt;

                Proc.Prepared:=true;
                Proc.Open;

                DataExists:=Proc.Active;
                RecordCount:=Proc.RecordCount;

              except
                on E: EInvalidPointer do begin

                end else
                  raise;
              end;

              LogWrite(Format('GetRecords Provider=%s success',[Provider.Name]));

              with Proc.Parameters do begin
                for i:=0 to Count-1 do begin
                  Param:=Items[i];
                  if not (Param.Direction in [pdUnknown,pdReturnValue]) then begin
                    Item:=Config.Params.Find(Param.Name);
                    if Assigned(Item) and (Item.ParamType in [ptOutput,ptInputOutput]) then begin
                      Item.Value:=ConvertLocal(GetOldType(Param),Param.Value);

                      S:='NULL';
                      if not VarIsNull(Item.Value) then
                        S:=Copy(VarToStrDef(Item.Value,''),1,300);
                      LogWrite(Format('GetRecords Provider=%s Param=%s Value=%s',[Provider.Name,Param.Name,S]));
                    end;
                  end;
                end;
              end;

            except
              On E: Exception do begin
                raise Exception.Create(GetExecuteExceptionMessage(E));
              end;
            end;

          finally
            OldTypes.Free;
          end;
        end;

        if DataExists and Assigned(DataSet) then begin

          if (Config.FetchCount=-1) then
            Config.AllCount:=RecordCount;

          StartPos:=Config.StartPos;

          RealCount:=Config.FetchCount;
          if RealCount<0 then begin
            RealCount:=Config.AllCount-StartPos
          end else begin
            if (StartPos+RealCount)>Config.AllCount then
              RealCount:=Config.AllCount-StartPos;
          end;

          RecCount:=0;
          Breaked:=false;
          Position:=1;
          DataSet.First;
          DSOut.CreateDataSetBySource(DataSet);
          DSOut.LogChanges:=false;
          while not DataSet.Eof do begin
            if (RecCount>=StartPos) then begin
              if (RecCount<(StartPos+RealCount)) then begin
                DSOut.FieldValuesBySource(DataSet,true);
              end else
                break;
            end;
            ProgressByProc(ProgressProc,0,RealCount,Position,Breaked);
            if Breaked then
              Break;
            Inc(RecCount);
            Inc(Position);
            DataSet.Next;
          end;

          if DSOut.Active then begin
            DSOut.MergeChangeLog;
            DSOut.First;
            Result:=DSOut.Data;
            Config.RecsOut:=DSOut.RecordCount;
            LogWrite(Format('GetRecords Provider=%s StartPos=%d RecordCount=%d success',[Provider.Name,StartPos,Config.RecsOut]));
          end;
        end;
      finally
        DSOut.Free;
        Query.Free;
        Proc.Free;
      end;
    end;
  except
    On E: Exception do begin
      LogWrite(Format('GetRecords Provider=%s failed=%s',[Provider.Name,E.Message]),ltError);
      raise;
    end;
  end;
end;

function TSgtsOraAdoDatabase.GetValue(SQL,FieldName: String): Variant;
var
  Query: TSgtsADOQuery;
begin
  if FConnection.Connected then begin
    Query:=TSgtsADOQuery.Create(nil);
    try
      Query.Connection:=FConnection;
      Query.Sql.Text:=SQL;
      Query.Open;
      if Query.Active and not Query.IsEmpty then begin
        Result:=Query.FieldByName(FieldName).Value;
      end;
    finally
      Query.Free;
    end;
  end;
end;

function TSgtsOraAdoDatabase.GetOutputPath: String;
begin
  Result:=ExtractFilePath(GetModuleName(HInstance));
  if DirectoryExists(FOutPutDir) then
    Result:=IncludeTrailingPathDelimiter(FOutPutDir);
end;

function TSgtsOraAdoDatabase.GetNewId(Provider: TSgtsExecuteProvider): Variant;
var
  Sql: String;
  AKeyField, AKeyQuery: String;
begin
  Result:=inherited GetNewId(Provider);
  try
    Sql:=SSqlGetNewId1;
    AKeyField:=Provider.KeyField;
    if Trim(AKeyField)='' then begin
      Sql:=SSqlGetNewId2;
      AKeyField:=Provider.Name;
    end;
    AKeyQuery:=Provider.KeyQuery;
    if Trim(AKeyQuery)='' then
      AKeyQuery:=SProviderKeyQueryDual;
    
    Result:=GetValue(Format(Sql,[AKeyField,AKeyQuery]),SFieldMaxId);
    if VarIsNull(Result) then
      Result:=1;
    LogWrite(Format('GetNewId Provider=%s Value=%s success',[Provider.Name,VarToStrDef(Result,'')]));
  except
    on E: Exception do begin
      LogWrite(Format('GetNewId Provider=%s failed=%s',[Provider.Name,E.Message]),ltError);
      raise;
    end;  
  end;    
end;

function TSgtsOraAdoDatabase.GetExecuteExceptionMessage(E: Exception): String;
var
  S, S1: String;
  APos: Integer;
  Code: Integer;
begin
  Result:=E.Message;
  APos:=AnsiPos(AnsiUpperCase(SORA),AnsiUpperCase(Result));
  if APos>0 then begin
    S:=Copy(Result,APos+Length(SORA)-1,Length(Result));
    APos:=AnsiPos(':',S);
    if APos>0 then begin
      S1:=Copy(S,APos+1,Length(S));
      S:=Copy(S,1,APos-1);
      Code:=StrToIntDef(S,0);
      if (Code>=-20999) and (Code<=-20000) then begin
        APos:=AnsiPos(AnsiUpperCase(SORA),AnsiUpperCase(S1));
        if APos>0 then begin
          Result:=Copy(S1,1,APos-1);
          Result:=Trim(Result);
        end;
      end;
    end;
  end;
end;

{procedure TSgtsOraAdoDatabase.SaveDebug(ACommand: TADOCommand);
var
  i: Integer;
  Str: TStringList;
begin
  Str:=TStringList.Create;
  try
    for i:=0 to ACommand.Properties.Count-1 do begin
      Str.Add(Format('%s=%s',[ACommand.Properties.Item[i].Name,VarToStrDef(ACommand.Properties.Item[i].Value,'')]));
    end;
    Str.SaveToFile('c:\1.txt');
  finally
    Str.Free;
  end;
end;}

procedure TSgtsOraAdoDatabase.Execute(Provider: TSgtsExecuteProvider; Config: TSgtsExecuteConfig);
var
  OldTypes: TStringList;

  procedure SetEmptyValue(Param: TParameter);
  begin
    case Param.DataType of
      ftString: begin
        Param.Value:='';
        Param.Size:=MaxVarchar2;
      end;
    else
      OldTypes.AddObject(IntToStr(Integer(Param.DataType)),Param);

      Param.DataType:=ftString;
      Param.Value:='';
      Param.Size:=MaxVarchar2;
    end;
  end;

  function ConvertLocal(DataType: TDataType; Value: Variant): Variant;
  var
    VType: Word;
    DType: TDataType;
    S: String;
  begin
    Result:=Value;
    if not VarIsNull(Value) then begin
      VType:=VarType(Value);
      DType:=VarTypeToDataType(VType);
      if (DataType<>DType) and (DType in [ftString,ftWideString]) then begin
        S:=VarToStrDef(Value,'');
        case DataType of
          ftString: Result:=S;
          ftFloat: begin
            S:=ChangeChar(S,'.',DecimalSeparator);
            Result:=VarToExtendedDef(S,0.0);
          end;
          ftBCD: begin
            Result:=VarToIntDef(S,0);
          end; 
        end;
      end;
    end;
  end;

  function GetOldType(Param: TParameter): TDataType;
  var
    Index: Integer;
  begin
    Result:=Param.DataType;
    Index:=OldTypes.IndexOfObject(Param);
    if Index<>-1 then begin
      Result:=TDataType(StrToInt(OldTypes.Strings[Index]));
    end;
  end;

var
  Proc: TSgtsADOStoredProc;
  i: Integer;
  Param: TParameter;
  Item: TSgtsExecuteConfigParam;
  Stream: TStringStream;
  FlagSSPPrmsLob: Boolean;
  S: String;
  Cache: TSgtsADOProcedureCache;
begin
  LogWrite(Format('Execute Provider=%s start...',[Provider.Name]));
  try
    if FConnection.Connected then begin
      Proc:=TSgtsADOStoredProc.Create(nil);
      OldTypes:=TStringList.Create;
      try
        try
          Proc.Connection:=FConnection;
          Proc.ExecuteOptions:=Proc.ExecuteOptions-[eoExecuteNoRecords];
          Proc.ProcedureName:=Provider.Name;

          Cache:=FProcedureCaches.Find(Provider.Name);
          if not Assigned(Cache) then begin
            try
              Proc.Parameters.Refresh;
            except
            end;
            Cache:=FProcedureCaches.Add(Provider.Name);
            Cache.CopyFromParameters(Proc.Parameters);
          end else begin
            Cache.CopyToParameters(Proc.Parameters);
          end;

          FlagSSPPrmsLob:=false;

          for i:=0 to Proc.Parameters.Count-1 do begin
            Param:=Proc.Parameters.Items[i];
            if not (Param.Direction in [pdUnknown,pdReturnValue]) then begin
              Param.Value:=Null;
            end;
          end;

          with Config.Params do begin
            for i:=0 to Count-1 do begin
              Item:=Items[i];
              Param:=Proc.Parameters.FindParam(GetExecuteParamFieldName(Item));
              if Assigned(Param) then begin
                if Item.ParamType in [ptInput,ptOutput,ptInputOutput] then begin
                  if Item.ParamType in [ptInput] then begin
                    case Param.DataType of
                      ftBlob,ftMemo,ftVarBytes: begin
                        if not VarIsNull(Item.Value) then begin
                          Stream:=TStringStream.Create(VarToStrDef(Item.Value,''));
                          try
                            if Stream.Size>0 then begin
                              FlagSSPPrmsLob:=true;
                              Param.LoadFromStream(Stream,Param.DataType);
                            end;
                          finally
                            Stream.Free;
                          end;
                        end;
                      end;
                    else
                      Param.Value:=Item.Value;
                    end;
                  end else begin
                    if VarIsNull(Item.Value) then begin
                      SetEmptyValue(Param);
                    end else Param.Value:=Item.Value;
                  end;

                  if Item.ParamType in [ptOutput,ptInputOutput] then begin
                    Param.Size:=iff((Param.Size<>-1) or
                                    ((Param.Size=-1) and (Item.Size=0)),
                                    Param.Size,
                                    Item.Size);
                  end;

                  S:='NULL';
                  if not VarIsNull(Item.Value) then
                    S:=Copy(VarToStrDef(Item.Value,''),1,300);
                  LogWrite(Format('Execute Provider=%s Param=%s Value=%s',[Provider.Name,Param.Name,S]));
                end;
              end;
            end;
          end;

          if FlagSSPPrmsLob then begin
            Proc.Command.CommandObject.Set_ActiveConnection(Proc.Connection.ConnectionObject);
            Proc.Command.Properties[SSPPrmsLob].Value:=true;
            LogWrite(Format('Execute Provider=%s SPPrmsLob=true',[Provider.Name]));
          end;

          try
            Proc.ExecProc;
          except
            on E: EInvalidPointer do begin

            end else
              raise;
          end;

          LogWrite(Format('Execute Provider=%s success',[Provider.Name]));

          with Proc.Parameters do begin
            for i:=0 to Count-1 do begin
              Param:=Items[i];
              if not (Param.Direction in [pdUnknown,pdReturnValue]) then begin
                Item:=Config.Params.Find(Param.Name);
                if Assigned(Item) and (Item.ParamType in [ptOutput,ptInputOutput]) then begin
                  Item.Value:=ConvertLocal(GetOldType(Param),Param.Value);

                  S:='NULL';
                  if not VarIsNull(Item.Value) then
                    S:=Copy(VarToStrDef(Item.Value,''),1,300);
                  LogWrite(Format('Execute Provider=%s Param=%s Value=%s',[Provider.Name,Param.Name,S]));  
                end;
              end;
            end;
          end;

        except
          On E: Exception do begin
            raise Exception.Create(GetExecuteExceptionMessage(E));
          end;
        end;

      finally
        OldTypes.Free;
        Proc.Free;
      end;
    end;
  except
    On E: Exception do begin
      LogWrite(Format('Execute Provider=%s failed=%s',[Provider.Name,E.Message]),ltError);
      raise;
    end;
  end;
end;

procedure TSgtsOraAdoDatabase.DefConnectionWillExecute(
  Connection: TADOConnection; var CommandText: WideString;
  var CursorType: TCursorType; var LockType: TADOLockType;
  var CommandType: TCommandType; var ExecuteOptions: TExecuteOptions;
  var EventStatus: TEventStatus; const Command: _Command;
  const Recordset: _Recordset);
begin
  with TStringList.Create do begin
    Text:=CommandText;
//    SaveToFile('c:\1.txt');
    Free;
  end;
end;


function TSgtsOraAdoDatabase.ExecSql(SQL: String): Boolean;
var
  Command: TSgtsADOCommand;

  function PrepareSqlForWindows: WideString;
  begin
//    Result:=ReplaceText(SQL,#13#10,#10);
    Result:=SQL;
  end;

begin
  Result:=false;
  LogWrite(Format('ExecSql SQL='+#13#10+'%s start...',[SQL]));
  try
    if FDefConnection.Connected then begin
      FDefConnection.OnWillExecute:=DefConnectionWillExecute;
      Command:=TSgtsADOCommand.Create(nil);
      try
        Command.Connection:=FDefConnection;
        Command.CommandType:=cmdText;
        SQL:=Trim(SQL);
        if Length(SQL)>0 then begin
          Command.ParamCheck:=false;
          Command.CommandText:=PrepareSqlForWindows;
          Command.Execute;
          Result:=true;
        end;
        LogWrite(Format('ExecSql SQL='+#13#10+'%s %s',[SQL,iff(Result,'success','failed')]));
      finally
        Command.Free;
        FDefConnection.OnWillExecute:=nil;
      end;
    end;
  except
    On E: Exception do begin
      LogWrite(Format('ExecSql SQL='+#13#10+'%s failed=%s',[SQL,E.Message]),ltError);
      raise;
    end;
  end;  
end;

function TSgtsOraAdoDatabase.LoginDefault(Params: String): Boolean;
var
  FParams: TSgtsCDS;
  AConnectionString: String;
  i: Integer;
  AParam: String;
  AValue: String;
begin
  LogWrite('LoginDefault start...');
  try
    FParams:=TSgtsCDS.Create(nil);
    try
      Result:=false;
      FParams.XMLData:=Params;
      if FParams.Active then begin
        FDefConnection.Connected:=false;
        AConnectionString:=FDefConnectionString;
        i:=0;
        FParams.First;
        while not FParams.Eof do begin
          AParam:=FParams.FieldByName(SDb_Name).AsString;
          AParam:='%'+AParam;
          AValue:=FParams.FieldByName(SDb_Value).AsString;
          if i<ConnectionParams.RecordCount then
            AConnectionString:=StringReplace(AConnectionString,AParam,AValue,[rfReplaceAll,rfIgnoreCase])
          else break;
          FParams.Next;
          inc(i);
        end;
        FDefConnection.ConnectionString:=AConnectionString;
        LogWrite(Format('LoginDefault ConnectionString=%s',[AConnectionString]));
      end;
      FDefConnection.Connected:=true;
      Result:=FDefConnection.Connected;
      if Result then
        CoreIntf.Config.Write(ModuleIntf.Name,SConfigParamConnectionString,FDefConnection.ConnectionString);
      LogWrite(Format('LoginDefault %s',[iff(Result,'success','failed')]));
    finally
      FParams.Free;
    end;
  except
    on E: Exception do begin
      LogWrite(Format('LoginDefault failed=%s',[E.Message]),ltError);
      raise;
    end;
  end;   
end;

procedure TSgtsOraAdoDatabase.LogoutDefault;
begin
  try
    FDefConnection.Connected:=false;
    LogWrite('LogoutDefault success');
  except
    On E: Exception do begin
      LogWrite(Format('LogoutDefault failed=%s',[E.Message]),ltError);
    end;
  end;
end;

function TSgtsOraAdoDatabase.UploadTable(XMLData: String; ProgressProc: TSgtsDatabaseProgressProc=nil): Boolean;
var
  DataSet: TSgtsCDS;
  Table: TSgtsADOTable;
  i: Integer;
  Field1,Field2: TField;
  Position: Integer;
  Breaked: Boolean;
begin
  Result:=false;
  LogWrite('UploadTable start...');
  try
    if FDefConnection.Connected then begin
      DataSet:=TSgtsCDS.Create(nil);
      Table:=TSgtsADOTable.Create(nil);
      try
        Table.Connection:=FDefConnection;
        DataSet.XMLData:=XMLData;
        if DataSet.Active then begin
          Position:=1;
          Breaked:=false;
          Table.TableName:=DataSet.TableName;
          LogWrite(Format('UploadTable TableName=%s',[DataSet.TableName]));
          Table.MaxRecords:=100;
          Table.Open;
          DataSet.First;
          while not DataSet.Eof do begin
            Table.Append;
            for i:=0 to DataSet.FieldCount-1 do begin
              Field1:=DataSet.Fields[i];
              Field2:=Table.FindField(Field1.FieldName);
              if Assigned(Field2) then begin
                Field2.Value:=Field1.Value;
              end;
            end;
            Table.Post;
            ProgressByProc(ProgressProc,0,DataSet.RecordCount,Position,Breaked);
            if Breaked then
              break;
            Inc(Position);
            DataSet.Next;
          end;
          Result:=true;
          LogWrite(Format('UploadTable TableName=%s success',[DataSet.TableName]));
        end;
      finally
        Table.Free;
        DataSet.Free;
      end;
    end;
  except
    On E: Exception do begin
      LogWrite(Format('UploadTable failed=%s',[E.Message]),ltError);
      raise;
    end;
  end;  
end;

function TSgtsOraAdoDatabase.Install(Value: String; InstallType: TSgtsDatabaseInstallType; ProgressProc: TSgtsDatabaseProgressProc=nil): Boolean;
begin
  Result:=false;
  LogWrite(Format('Install Type=%s start...',[GetEnumName(TypeInfo(TSgtsDatabaseInstallType),Integer(InstallType))]));
  case InstallType of
    itScript: Result:=ExecSql(Value);
    itTable: Result:=UploadTable(Value,ProgressProc);
  end;
end;

function TSgtsOraAdoDatabase.GetTableName(SQL: String; var Where: String): String;
var
  APos: Integer;
  i: Integer;
  Ch: Char;
const
  Chars=[' ',#13,#10,#0];
begin
  Result:='';
  APos:=Pos(UpperCase(SFrom),UpperCase(SQL));
  if APos>0 then begin
    Result:=Copy(SQL,APos+Length(SFrom)+1,Length(SQL));
    for i:=1 to Length(Result) do begin
      Ch:=Result[i];
      if Ch in Chars then begin
        Result:=Copy(Result,1,i-1);
        Result:=Trim(Result);
        Result:=StringReplace(Result,'*','',[rfReplaceAll]);
        Result:=StringReplace(Result,'/','',[rfReplaceAll]);
        break;
      end;
    end;
  end;
  APos:=Pos(UpperCase(SWhere),UpperCase(SQL));
  if APos>0 then begin
    Where:=Copy(SQL,APos+Length(SWhere)+1,Length(SQL));
  end;
end;

function TSgtsOraAdoDatabase.GetObjectTypeByName(ObjectTypeName: String): TSgtsOraAdoDatabaseObjectType;
begin
  Result:=dotUnknown;
  if AnsiSameText(ObjectTypeName,SSequence) then Result:=dotSequence;
end;

function TSgtsOraAdoDatabase.GetScript(ObjectName: String; ProgressProc: TSgtsDatabaseProgressProc=nil): String;

  function GenerateSequenceScript(Sequence: String): String;
  var
    Query: TSgtsADOQuery;
  begin
    Result:='';
    Query:=TSgtsADOQuery.Create(nil);
    try
      Query.Connection:=FDefConnection;
      Query.Sql.Text:=Format(SSqlGetSequence,[QuotedStr(Sequence)]);
      Query.Open;
      if Query.Active and not Query.IsEmpty then begin
        Result:=Format(SSqlDropSequence,[Sequence]);
        Result:=Result+SReturn2+SMinus2+SReturn2;
        Result:=Result+Format(SSqlCreateSequence,
                              [Sequence,
                               VarToStrDef(Query.FieldByName(SFieldLastNumber).Value,''),
                               VarToStrDef(Query.FieldByName(SFieldIncrementBy).Value,''),
                               VarToStrDef(Query.FieldByName(SFieldMaxValue).Value,''),
                               VarToStrDef(Query.FieldByName(SFieldLastNumber).Value,''),
                               iff(VarToStrDef(Query.FieldByName(SFieldCycleFlag).Value,'')=SY,SCycle,SNoCycle),
                               VarToStrDef(Query.FieldByName(SFieldCacheSize).Value,''),
                               iff(VarToStrDef(Query.FieldByName(SFieldOrderFlag).Value,'')=SY,SOrder,SNoOrder)]);
        Result:=Result+SReturn2+SMinus2+SReturn2+SCommit;
      end;
    finally
      Query.Free;
    end;
  end;

var
  Query: TSgtsADOQuery;
  ObjectType: TSgtsOraAdoDatabaseObjectType;
begin
  Result:='';
  LogWrite(Format('GetScript ObjectName=%s start...',[ObjectName]));
  try
    if FDefConnection.Connected then begin
      Query:=TSgtsADOQuery.Create(nil);
      try
        Query.Connection:=FDefConnection;
        Query.Sql.Text:=Format(SSqlGetObjectType,[QuotedStr(ObjectName)]);
        LogWrite(Format('GetScript ObjectName=%s SQL='+#13#10+'%s',[ObjectName,Trim(Query.Sql.Text)]));
        Query.Open;
        if Query.Active and not Query.IsEmpty then begin
          ObjectType:=GetObjectTypeByName(Query.Fields[0].AsString);
          case ObjectType of
            dotSequence: Result:=GenerateSequenceScript(ObjectName);
          end;
          LogWrite(Format('GetScript ObjectName=%s Result='+#13#10+'%s',[ObjectName,Result]));
        end;
      finally
        Query.Free;
      end;
    end;
  except
    On E: Exception do begin
      LogWrite(Format('GetScript ObjectName=%s failed',[ObjectName,E.Message]),ltError);
      raise;
    end;
  end;  
end;

function TSgtsOraAdoDatabase.GetTable(SQL: String; ProgressProc: TSgtsDatabaseProgressProc=nil): String;
var
  Query: TSgtsADOQuery;
  DataSet: TSgtsCDS;
  Table: String;
  Breaked: Boolean;
  Position: Integer;
  Where: String;
begin
  Result:='';
  LogWrite(Format('GetTable SQL='+#13#10+'%s start...',[SQL]));
  try
    if FDefConnection.Connected then begin
      Query:=TSgtsADOQuery.Create(nil);
      DataSet:=TSgtsCDS.Create(nil);
      try
        Query.Connection:=FDefConnection;
        Query.Sql.Text:=SQL;
        Query.Open;
        if Query.Active then begin
          Breaked:=false;
          Position:=1;
          Table:=GetTableName(SQL,Where);
          Query.First;
          DataSet.CreateDataSetBySource(Query);
          DataSet.LogChanges:=false;
          while not Query.Eof do begin
            DataSet.FieldValuesBySource(Query,true,true);
            ProgressByProc(ProgressProc,0,Query.RecordCount,Position,Breaked);
            if Breaked then
              break;
            Inc(Position);
            Query.Next;
          end;
          DataSet.TableName:=Table;
          DataSet.MergeChangeLog;
          Result:=DataSet.XMLData;
          LogWrite(Format('GetTable SQL='+#13#10+'%s RecordCount=%d %s',[SQL,DataSet.RecordCount,iff(DataSet.Active,'success','failed')]));
        end;
      finally
        DataSet.Free;
        Query.Free;
      end;
    end;
  except
    On E: Exception do begin
      LogWrite(Format('GetTable SQL='+#13#10+'%s failed=%s',[SQL,E.Message]),ltError); 
      raise;
    end;
  end;  
end;

function TSgtsOraAdoDatabase.GetTableAsScript(SQL: String; ProgressProc: TSgtsDatabaseProgressProc=nil): String;

  function GetValueByField(Field: TField): String;
  begin
    Result:=SNull;
    if not VarIsNull(Field.Value) then begin
      case Field.DataType of
        ftString,ftBlob,ftMemo,ftWideString,ftOraBlob,ftOraClob: Result:=QuotedStr(Field.AsString);
        ftInteger,ftWord,ftSmallint,ftAutoInc,ftLargeint: Result:=Field.AsString;
        ftCurrency,ftFloat,ftBCD,ftFMTBcd: Result:=ChangeChar(Field.AsString,DecimalSeparator,'.');
        ftDateTime: Result:=GetRecordsFilterDateValue(Field.AsDateTime);
      end;
    end;
  end;


var
  Query: TSgtsADOQuery;
  i: Integer;
  Fields, Values: String;
  S: String;
  Field: TField;
  Table: String;
  Breaked: Boolean;
  Position: Integer;
  Where: String;
begin
  Result:='';
  LogWrite(Format('GetTableAsScript SQL='+#13#10+'%s start...',[SQL]));
  try
    if FDefConnection.Connected then begin
      Result:=SBegin+SReturn;
      Query:=TSgtsADOQuery.Create(nil);
      try
        Query.Connection:=FDefConnection;
        Query.Sql.Text:=SQL;
        Query.Open;
        if Query.Active and not Query.IsEmpty then begin
          Position:=1;
          Breaked:=false;
          Table:=GetTableName(SQL,Where);
          Query.First;
          while not Query.Eof do begin
            Fields:='';
            Values:='';
            for i:=0 to Query.Fields.Count-1 do begin
              Field:=Query.Fields[i];
              Fields:=Fields+iff(i=0,Field.FieldName,','+Field.FieldName);
              S:=GetValueByField(Field);
              Values:=Values+iff(i=0,S,','+S);
            end;
            Result:=Result+SReturn+Format(SSqlExecuteInsert,[Table,Fields,Values]);
            ProgressByProc(ProgressProc,0,Query.RecordCount,Position,Breaked);
            if Breaked then
              break;
            Inc(Position);
            Query.Next;
          end;
          Result:=Result+SReturn2+SCommit1+SReturn2+SEnd1;
          LogWrite(Format('GetTableAsScript SQL='+#13#10+'%s Result='+#13#10+'%s',[SQL,Result]));
        end;
      finally
        Query.Free;
      end;
    end;
  except
    On E: Exception do begin
      LogWrite(Format('GetTableAsScript SQL='+#13#10+'%s failed=%s',[SQL,E.Message]),ltError);
      raise;
    end;
  end;
end;

function TSgtsOraAdoDatabase.GetTableAsFiles(SQL: String; ProgressProc: TSgtsDatabaseProgressProc=nil): String;

  procedure SaveQueDataFile(DataSet: TSgtsCDS; Description, FileName, Table: String);
  var
    DSQue: TSgtsCDS;
  begin
    DSQue:=TSgtsCDS.Create(nil);
    try
      DSQue.CreateQueDataSet;
      DSQue.LogChanges:=false;
      DSQue.Append;
      DSQue.FieldByName(SDb_Type).AsInteger:=Integer(itTable);
      DSQue.FieldByName(SDb_Description).AsString:=Description;
      DSQue.FieldByName(SDb_Value).AsString:=DataSet.XMLData;
      DSQue.Post;
      DSQue.MergeChangeLog;
      DSQue.SaveToFile(FileName,dfXMLUTF8);
    finally
      DSQue.Free;
    end;
  end;

var
  Query: TSgtsADOQuery;
  DSQueName: TSgtsCDS;
  DataSet: TSgtsCDS;
  Files: TStringList;
  Table: String;
  Breaked: Boolean;
  Position: Integer;
  Increment: Integer;
  Start: Integer;
  FileName: String;
  Desc: String;
  RecCount: Integer;
  Where: String;

const
  MaxRecordFormat='#0000000';

  procedure FlashDataSet;
  var
    S: String;
  begin
    DataSet.MergeChangeLog;
    Desc:=Format('%s %s-%s',[Table,FormatFloat(MaxRecordFormat,Start+1),FormatFloat(MaxRecordFormat,Start+Increment)]);
    S:=Format('%s.que',[CreateUniqueId]);
    FileName:=GetOutputPath+S;
    DSQueName.Append;
    DSQueName.FieldByName(SDb_Type).AsInteger:=Integer(itFile);
    DSQueName.FieldByName(SDb_Description).AsString:=Desc;
    DSQueName.FieldByName(SDb_Value).AsString:=ExtractFileName(FileName);
    DSQueName.Post;
    SaveQueDataFile(DataSet,Desc,FileName,Table);
    Files.Add(ExtractFileName(FileName));
    LogWrite(Format('GetTableAsFiles SQL='+#13#10+'%s FlashDataSet to file=%s ',[SQL,FileName]));
  end;

var
  i: Integer;  
begin
  Result:='';
  LogWrite(Format('GetTableAsFiles SQL='+#13#10+'%s start...',[SQL]));
  try
    if FDefConnection.Connected then begin
      Query:=TSgtsADOQuery.Create(nil);
      DSQueName:=TSgtsCDS.Create(nil);
      DataSet:=TSgtsCDS.Create(nil);
      Files:=TStringList.Create;
      try
        DSQueName.CreateQueDataSet;
        DSQueName.LogChanges:=false;
        Query.Connection:=FDefConnection;
        Query.Sql.Text:=SQL;
        Query.CacheSize:=FMaxOutputRecords;
        Query.Open;
        if Query.Active then begin
          Breaked:=false;
          Position:=1;
          Increment:=0;
          Start:=0;
          Table:=GetTableName(SQL,Where);
          RecCount:=GetValue(Format('SELECT COUNT(*) AS CNT FROM (%s)',[SQL]),'CNT');
          if RecCount>0 then begin
            Query.First;
            DataSet.CreateDataSetBySource(Query);
            DataSet.LogChanges:=false;
            while not Query.Eof do begin
              if Increment>=FMaxOutputRecords then begin
                DataSet.TableName:=Table;
                FlashDataSet;
                DataSet.Free;
                DataSet:=TSgtsCDS.Create(nil);
                DataSet.CreateDataSetBySource(Query);
                DataSet.LogChanges:=false;
                Start:=Start+Increment;
                Increment:=0;
              end;
              DataSet.FieldValuesBySource(Query,true,true);
              ProgressByProc(ProgressProc,0,RecCount,Position,Breaked);
              if Breaked then
                break;
              Inc(Position);
              Inc(Increment);
              Query.Next;
            end;
            DataSet.TableName:=Table;
            FlashDataSet;
            i:=0;
            FileName:=GetOutputPath+Format('_%s_%s.que',[FormatFloat('#0000',i),Table]);
            while FileExists(FileName) do begin
              Inc(i);
              FileName:=GetOutputPath+Format('_%s_%s.que',[FormatFloat('#0000',i),Table]);
              if i>=9999 then
                break;
            end;
            DSQueName.MergeChangeLog;
            DSQueName.SaveToFile(FileName,dfXMLUTF8);
            Files.Add(ExtractFileName(FileName));
            Result:=Trim(Files.Text);
          end;
          LogWrite(Format('GetTableAsFiles SQL='+#13#10+'%s RecordCount=%d',[SQL,RecCount]));
        end;
      finally
        Files.Free;
        DataSet.Free;
        DSQueName.Free;
        Query.Free;
      end;
    end;
  except
    On E: Exception do begin
      LogWrite(Format('GetTableAsFiles SQL='+#13#10+'%s failed=%s',[SQL,E.Message]),ltError);
      raise;
    end;
  end;
end;

function TSgtsOraAdoDatabase.Export(Value: String; ExportType: TSgtsDatabaseExportType; ProgressProc: TSgtsDatabaseProgressProc=nil): String;
begin
  Result:='';
  LogWrite(Format('Export ExportType=%s start...',[GetEnumName(TypeInfo(TSgtsDatabaseExportType),Integer(ExportType))]));
  case ExportType of
    etScript: Result:=GetScript(Value,ProgressProc);
    etTable: Result:=GetTable(Value,ProgressProc);
    etTableAsScript: Result:=GetTableAsScript(Value,ProgressProc);
    etTableAsFiles: Result:=GetTableAsFiles(Value,ProgressProc);
  end;
end;

procedure TSgtsOraAdoDatabase.RefreshPermissions;
begin
  SetPermissions;
end;

procedure TSgtsOraAdoDatabase.LoadConfig(Stream: TStream);
var
  Query: TSgtsAdoQuery;
begin
  if FDefConnection.Connected and
     Assigned(Stream) then begin
    Query:=TSgtsAdoQuery.Create(nil);
    try
      Query.Connection:=FDefConnection;
      Query.SQL.Text:=Format(SSqlGetAccountAdjustment,[VarToStr(AccountId)]);
      Query.Open;
      if Query.Active and not Query.IsEmpty then begin
        TBlobField(Query.Fields[0]).SaveToStream(Stream); 
      end;
    finally
      Query.Free;
    end;
  end;
end;

procedure TSgtsOraAdoDatabase.SaveConfig(Stream: TStream);
var
  Query: TSgtsAdoQuery;
begin
  if FDefConnection.Connected and
     Assigned(Stream) then begin
    Query:=TSgtsAdoQuery.Create(nil);
    try
      Query.Connection:=FDefConnection;
      Query.CursorType:=ctKeyset;
      Query.LockType:=ltOptimistic;
      Query.SQL.Text:=Format(SSqlGetAccountAdjustment,[VarToStr(AccountId)]);
      Query.Open;
      if Query.Active and not Query.IsEmpty then begin
        Query.Edit;
        TBlobField(Query.Fields[0]).LoadFromStream(Stream);
        Query.Post;
      end;
    finally
      Query.Free;
    end;
  end;
end;

end.
