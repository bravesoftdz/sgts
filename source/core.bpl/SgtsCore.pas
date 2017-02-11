unit SgtsCore;

interface

uses Windows, Classes, Sysutils, Contnrs, AppEvnts,

     SgtsObj, SgtsCoreObj, SgtsConfig, SgtsCmdLine, SgtsLog, SgtsIface,
     SgtsDatabaseConfig,
     SgtsDatabaseModules, SgtsReportModules, SgtsInterfaceModules, SgtsFileReport,

     SgtsMainFm, SgtsSplashFm, SgtsLoginFm, SgtsRbkAccountsFm,
     SgtsAboutFm, SgtsOptionsFm, SgtsInstallSqlFm,
     SgtsRbkRolesFm, SgtsRbkAccountsRolesFm,
     SgtsRbkObjectsFm, SgtsRbkCyclesFm,
     SgtsRbkPointsFm, SgtsRbkPersonnelsFm, SgtsRbkRoutesFm, SgtsRbkMeasureTypesFm,
     SgtsRbkAccountEditFm, SgtsRbkPermissionFm,
     SgtsRbkDivisionsFm, SgtsFunPersonnelManagementFm, SgtsRbkRolesAndAccountsFm,
     SgtsRbkPointTypesFm, SgtsRbkInstrumentTypesFm,
     SgtsRbkInstrumentsFm, SgtsRbkMeasureUnitsFm, SgtsRbkInstrumentUnitsFm,
     SgtsRbkRoutePointsFm, SgtsRbkMeasureTypeRoutesFm,
     SgtsRbkPersonnelRoutesFm, SgtsRbkPlansFm, SgtsRbkObjectTreesFm,
     SgtsFunPointManagementFm, SgtsRbkAlgorithmsFm, SgtsRbkMeasureTypeAlgorithmsFm,
     SgtsRbkLevelsFm, SgtsRbkParamsFm, SgtsRbkMeasureTypeParamsFm,
     SgtsRbkParamLevelsFm, SgtsJrnJournalFieldsFm, SgtsJrnJournalObservationsFm,
     SgtsFunSourceDataFm, SgtsRbkFileReportsFm, SgtsRbkBaseReportsFm, SgtsRbkParamInstrumentsFm,
     SgtsRbkDocumentsFm, SgtsRbkPointDocumentsFm, SgtsRbkDevicePointsFm,
     SgtsRbkConvertersFm, SgtsRbkComponentsFm, SgtsRbkDevicesFm, SgtsRbkDrawingsFm,
     SgtsRbkObjectDrawingsFm, SgtsRbkObjectDocumentsFm, SgtsRbkConverterPassportsFm,
     SgtsRbkInstrumentPassportsFm, SgtsRbkPointPassportsFm, SgtsRbkObjectPassportsFm,
     SgtsJrnJournalActionsFm, SgtsExportSqlFm, SgtsRbkInterfaceReportsFm,
     SgtsRbkCycleEditFm, SgtsRbkCheckingsFm, SgtsRbkCutsFm, SgtsRbkPointInstrumentsFm,
     SgtsRefreshCutsFm, SgtsJrnJournalsFm, SgtsGrpJournalFm, SgtsRbkGraphsFm, SgtsRbkGroupsFm,
     SgtsRbkGroupObjectsFm, SgtsRbkDefectViewsFm, SgtsRbkCriteriasFm, SgtsRecalcJournalObservationsFm,

     SgtsReportFm, SgtsDataFm, SgtsFm,

     SgtsGraphTestIface,

     SgtsDatabase, SgtsInterface, SgtsFileIface, 

     SgtsCoreIntf, SgtsConfigIntf, SgtsCmdLineIntf, SgtsLogIntf, SgtsDatabaseModulesIntf,
     SgtsReportModulesIntf, SgtsInterfaceModulesIntf, SgtsDatabaseConfigIntf,
     SgtsMainFmIntf, SgtsSplashFmIntf, SgtsLoginFmIntf, SgtsIfaceIntf, SgtsDataFmIntf,
     SgtsInstallSqlFmIntf, SgtsChildFmIntf, SgtsReportFmIntf, SgtsExportSqlFmIntf,

     SgtsAboutFmIntf, SgtsOptionsFmIntf, SgtsDataInsertFmIntf;

type

  TSgtsCoreObjs=class(TObjectList)
  private
    FLock: TRTLCriticalSection;
    function GetItem(Index: Integer): TSgtsObj;
    procedure SetItem(Index: Integer; const Item: TSgtsObj);
  protected
    procedure Lock;
    procedure Unlock;
    function FindInterface(const InterfaceName: String): TSgtsIface;
  public
    constructor Create(OwnObjects: Boolean);
    destructor Destroy; override;

    procedure Init;
    procedure Done;
    procedure BeforeStart;
    procedure ReadParams;
    procedure WriteParams;
    procedure DatabaseLink;
    procedure CheckPermissions;
    procedure ClearReports;
    procedure ClearGraphs; 
    procedure UpdateContents;
    procedure AfterLogin;
    procedure BeforeReadParams;
    procedure BeforeWriteParams;
    procedure ClearIfaces;

    property Items[Index: Integer]: TSgtsObj read GetItem write SetItem;
  end;

  TSgtsCoreStartupMode=(smDefault,smInstallSql,smUninstallSql,smNoProfile);

  TSgtsCore=class(TSgtsObj,ISgtsCore)
  private
    FMutexHandle: THandle;
    FApplicationEvents: TApplicationEvents;

    FConfig: TSgtsConfig;
    FCmdLine: TSgtsCmdLine;
    FLog: TSgtsLog;
    FDatabaseModules: TSgtsDatabaseModules;
    FDatabaseConfig: TSgtsDatabaseConfig;
    FReportModules: TSgtsReportModules;
    FInterfaceModules: TSgtsInterfaceModules;

    FSplashIface: TSgtsSplashIface;
    FLoginIface: TSgtsLoginIface;
    FMainIface: TSgtsMainIface;
    FAboutIface: TSgtsAboutIface;
    FOptionsIface: TSgtsOptionsIface;
    FInstallSqlIface: TSgtsInstallSqlIface;
    FExportSqlIface: TSgtsExportSqlIface;
    FRefreshCutsIface: TSgtsRefreshCutsIface;
    FRecalcJournalObservationsIface: TSgtsRecalcJournalObservationsIface;

    FRbkAccountsIface: TSgtsRbkAccountsIface;
    FRbkRolesIface: TSgtsRbkRolesIface;
    FRbkPersonnelsIface: TSgtsRbkPersonnelsIface;
    FRbkPermissionIface: TSgtsRbkPermissionIface;
    FRbkAccountsRolesIface: TSgtsRbkAccountsRolesIface;
    FRbkDivisionsIface: TSgtsRbkDivisionsIface;
    FRbkObjectsIface: TSgtsRbkObjectsIface;
    FFunPersonnelManagementIface: TSgtsFunPersonnelManagementIface;
    FRolesAndAccountsIface: TSgtsRbkRolesAndAccountsIface;
    FPointTypesIface: TSgtsRbkPointTypesIface;
    FRbkPointsIface: TSgtsRbkPointsIface;
    FRbkMeasureTypesIface: TSgtsRbkMeasureTypesIface;
    FRbkInstrumentTypesIface: TSgtsRbkInstrumentTypesIface;
    FRbkInstrumentsIface: TSgtsRbkInstrumentsIface;
    FRbkMeasureUnitsIface: TSgtsRbkMeasureUnitsIface;
    FRbkInstrumentUnitsIface: TSgtsRbkInstrumentUnitsIface;
    FRbkRoutesIface: TSgtsRbkRoutesIface;
    FRbkRoutePointsIface: TSgtsRbkRoutePointsIface;
    FRbkMeasureTypeRoutesIface: TSgtsRbkMeasureTypeRoutesIface;
    FRbkPersonnelRoutesIface: TSgtsRbkPersonnelRoutesIface;
    FRbkCyclesIface: TSgtsRbkCyclesIface;
    FRbkPlansIface: TSgtsRbkPlansIface;
    FRbkObjectTreesIface: TSgtsRbkObjectTreesIface;
    FFunPointManagementIface: TSgtsFunPointManagementIface;
    FAlgorithmsIface: TSgtsRbkAlgorithmsIface;
    FRbkMeasureTypeAlgorithmsIface: TSgtsRbkMeasureTypeAlgorithmsIface;
    FRbkLevelsIface: TSgtsRbkLevelsIface;
    FRbkParamsIface: TSgtsRbkParamsIface;
    FRbkMeasureTypeParamsIface: TSgtsRbkMeasureTypeParamsIface;
    FRbkParamLevelsIface: TSgtsRbkParamLevelsIface;
    FJrnJournalFieldsIface: TSgtsJrnJournalFieldsIface;
    FJrnJournalObservationsIface: TSgtsJrnJournalObservationsIface;
    FJrnJournalsIface: TSgtsJrnJournalsIface;
    FRbkAccountInsertIface: TSgtsRbkAccountInsertIface;
    FFunSourceDataIface: TSgtsFunSourceDataIface;
    FRbkFileReportsIface: TSgtsRbkFileReportsIface;
    FRbkBaseReportsIface: TSgtsRbkBaseReportsIface;
    FRbkParamInstrumentsIface: TSgtsRbkParamInstrumentsIface;
    FRbkDocumentsIface: TSgtsRbkDocumentsIface;
    FRbkPointDocumentsIface: TSgtsRbkPointDocumentsIface;
    FRbkConvertersIface: TSgtsRbkConvertersIface;
    FRbkComponentsIface: TSgtsRbkComponentsIface;
    FRbkDevicesIface: TSgtsRbkDevicesIface;
    FRbkDevicePointsIface: TSgtsRbkDevicePointsIface;
    FRbkDrawingsIface: TSgtsRbkDrawingsIface;
    FRbkObjectDrawingsIface: TSgtsRbkObjectDrawingsIface;
    FRbkObjectDocumentsIface: TSgtsRbkObjectDocumentsIface;
    FRbkConverterPassportsIface: TSgtsRbkConverterPassportsIface;
    FRbkInstrumentPassportsIface: TSgtsRbkInstrumentPassportsIface;
    FRbkPointPassportsIface: TSgtsRbkPointPassportsIface;
    FRbkObjectPassportsIface: TSgtsRbkObjectPassportsIface;
    FJrnJournalActionsIface: TSgtsJrnJournalActionsIface;
    FRbkInterfaceReportsIface: TSgtsRbkInterfaceReportsIface;
    FRbkCycleEditIface: TSgtsRbkCycleUpdateIface;
    FRbkCheckingsIface: TSgtsRbkCheckingsIface;
    FRbkCutsIface: TSgtsRbkCutsIface;
    FRbkPointInstrumentsIface: TSgtsRbkPointInstrumentsIface;
    FGphJournalIface: TSgtsGrpJournalIface;
    FRbkGraphsIface: TSgtsRbkGraphsIface;
    FRbkGroupsIface: TSgtsRbkGroupsIface;
    FRbkGroupObjectsIface: TSgtsRbkGroupObjectsIface;
    FRbkDefectViewsIface: TSgtsRbkDefectViewsIface;
    FRbkCriteriasIface: TSgtsRbkCriteriasIface;

    FInternalObjs: TSgtsCoreObjs;
    FExternalObjs: TSgtsCoreObjs;

    FTitle: String;
    FVersion: String;
    FInstallSqlFile: String;
    FInstallSqlDBModule: String;

    function _GetConfig: ISgtsConfig;
    function _GetCmdLine: ISgtsCmdLine;
    function _GetLog: ISgtsLog;
    function _GetDatabaseModules: ISgtsDatabaseModules;
    function _GetReportModules: ISgtsReportModules;
    function _GetInterfaceModules: ISgtsInterfaceModules;
    function _GetDatabaseConfig: ISgtsDatabaseConfig;

    function _GetAboutForm: ISgtsAboutForm;
    function _GetSplashForm: ISgtsSplashForm;
    function _GetOptionsForm: ISgtsOptionsForm;
    function _GetMainForm: ISgtsMainForm;
    function _GetInstallSqlForm: ISgtsInstallSqlForm;
    function _GetExportSqlForm: ISgtsExportSqlForm;
    function _GetRefreshCutsForm: ISgtsChildForm;
    function _GetRecalcJournalObservationsForm: ISgtsChildForm;

    function _GetRbkAccountsForm: ISgtsDataForm;
    function _GetRbkRolesForm: ISgtsDataForm;
    function _GetRbkPersonnelsForm: ISgtsDataForm;
    function _GetRbkPermissionForm: ISgtsDataForm;
    function _GetRbkAccountsRolesForm: ISgtsDataForm;
    function _GetRbkDivisionsForm: ISgtsDataForm;
    function _GetRbkObjectsForm: ISgtsDataForm;
    function _GetFunPersonnelManagementForm: ISgtsDataForm;
    function _GetRbkPointTypesForm: ISgtsDataForm;
    function _GetRbkPointsForm: ISgtsDataForm;
    function _GetRbkRoutesForm: ISgtsDataForm;
    function _GetRbkMeasureTypesForm: ISgtsDataForm;
    function _GetRbkInstrumentTypesForm: ISgtsDataForm;
    function _GetRbkInstrumentsForm: ISgtsDataForm;
    function _GetRbkMeasureUnitsForm: ISgtsDataForm;
    function _GetRbkInstrumentUnitsForm: ISgtsDataForm;
    function _GetRbkRoutePointsForm: ISgtsDataForm;
    function _GetRbkMeasureTypeRoutesForm: ISgtsDataForm;
    function _GetRbkPersonnelRoutesForm: ISgtsDataForm;
    function _GetRbkCyclesForm: ISgtsDataForm;
    function _GetRbkPlansForm: ISgtsDataForm;
    function _GetRbkObjectTreesForm: ISgtsDataForm;
    function _GetFunPointManagementForm: ISgtsDataForm;
    function _GetRbkAlgorithmsForm: ISgtsDataForm;
    function _GetRbkMeasureTypeAlgorithmsForm: ISgtsDataForm;
    function _GetRbkLevelsForm: ISgtsDataForm;
    function _GetRbkParamsForm: ISgtsDataForm;
    function _GetRbkMeasureTypeParamsForm: ISgtsDataForm;
    function _GetRbkParamLevelsForm: ISgtsDataForm;
    function _GetJrnJournalFieldsForm: ISgtsDataForm;
    function _GetJrnJournalObservationsForm: ISgtsDataForm;
    function _GetJrnJournalsForm: ISgtsDataForm;
    function _GetRbkAccountInsertForm: ISgtsDataInsertForm;
    function _GetFunSourceDataForm: ISgtsChildForm;
    function _GetRbkFileReportsForm: ISgtsDataForm;
    function _GetRbkBaseReportsForm: ISgtsDataForm;
    function _GetRbkParamInstrumentsForm: ISgtsDataForm;
    function _GetRbkDocumentsForm: ISgtsDataForm;
    function _GetRbkPointDocumentsForm: ISgtsDataForm;
    function _GetRbkConvertersForm: ISgtsDataForm;
    function _GetRbkComponentsForm: ISgtsDataForm;
    function _GetRbkDevicesForm: ISgtsDataForm;
    function _GetRbkDevicePointsForm: ISgtsDataForm;
    function _GetRbkDrawingsForm: ISgtsDataForm;
    function _GetRbkObjectDrawingsForm: ISgtsDataForm;
    function _GetRbkObjectDocumentsForm: ISgtsDataForm;
    function _GetRbkConverterPassportsForm: ISgtsDataForm;
    function _GetRbkInstrumentPassportsForm: ISgtsDataForm;
    function _GetRbkPointPassportsForm: ISgtsDataForm;
    function _GetRbkObjectPassportsForm: ISgtsDataForm;
    function _GetJrnJournalActionsForm: ISgtsDataForm;
    function _GetRbkInterfaceReportsForm: ISgtsDataForm;
    function _GetRbkCheckingsForm: ISgtsDataForm;
    function _GetRbkCutsForm: ISgtsDataForm;
    function _GetRbkPointInstrumentsForm: ISgtsDataForm;
    function _GetRbkGraphsForm: ISgtsDataForm;
    function _GetRbkGroupsForm: ISgtsDataForm;
    function _GetRbkGroupObjectsForm: ISgtsDataForm;
    function _GetRbkDefectViewsForm: ISgtsDataForm;
    function _GetRbkCriteriasForm: ISgtsDataForm;

    function _GetTitle: String;
    function _GetVersion: String;
    function _GetInstallSqlFile: String;
    function _GetInstallSqlDBModule: String;

    function GetStartupMode: TSgtsCoreStartupMode;
    procedure InitFileReportIfaces;
    procedure InitBaseReportIfaces;
    procedure InitBaseGraphIfaces;

    function LogWrite(const Message: String; LogType: TSgtsLogType=ltInformation): Boolean;
    procedure ApplicationEventsException(Sender: TObject; E: Exception);
    procedure RegisterFileIfaces;
  protected
    procedure CreateObj(AObjClass: TSgtsCoreObjClass; var AObj: TSgtsCoreObj);
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Init; override;
    procedure Done; override;
    procedure Start;
    procedure Stop;
    procedure ReadParams;
    procedure WriteParams;
    function Exists: Boolean;
    procedure GetInterfaceNames(Names: TStrings; AClass: TComponentClass=nil);
    procedure GetInterfacePermissions(const IntrefaceName: String; Permissions: TStrings);
    procedure GetInterfacePermissionValues(const InterfaceName, Permission: String; Values: TStrings);
    procedure GetReportModules(Names: TStrings);
    function InterfaceExists(const InterfaceName: String): Boolean;
    procedure CheckPermissions;
    procedure RefreshReports;
    procedure RefreshGraphs;
    procedure RegisterObj(Iface: TSgtsObj);
    procedure UnRegisterObj(Obj: TSgtsObj);

  end;

implementation

uses Forms, Variants, StrUtils, TypInfo,
     SgtsConsts, SgtsDialogs, SgtsDatabaseCDS, SgtsProviderConsts, SgtsUtils,
     SgtsGetRecordsConfig, SgtsFileReportIface, SgtsBaseReportFm, SgtsDatabaseIntf,
     SgtsSelectDefs, SgtsBaseGraphFm, SgtsBaseGraphPeriodIface, SgtsBaseGraphPeriodPointsIface,
     SgtsBaseGraphPeriodObjectsIface;

{ TSgtsCoreObjs }

constructor TSgtsCoreObjs.Create(OwnObjects: Boolean);
begin
  inherited Create(OwnObjects);
  InitializeCriticalSection(FLock);
end;

destructor TSgtsCoreObjs.Destroy;
begin
  DeleteCriticalSection(FLock);
  inherited Destroy;
end;

procedure TSgtsCoreObjs.Lock;
begin
  EnterCriticalSection(FLock);
end;

procedure TSgtsCoreObjs.UnLock;
begin
  LeaveCriticalSection(FLock);
end;

function TSgtsCoreObjs.GetItem(Index: Integer): TSgtsObj;
begin
  Result:=TSgtsObj(inherited Items[Index]);
end;

procedure TSgtsCoreObjs.SetItem(Index: Integer; const Item: TSgtsObj);
begin
  inherited Items[Index]:=Item;
end;

procedure TSgtsCoreObjs.Init;
var
  i: Integer;
begin
  for i:=0 to Count-1 do
    Items[i].Init;
end;

procedure TSgtsCoreObjs.Done;
var
  i: Integer;
begin
  for i:=Count-1 downto 0 do
    Items[i].Done;
end;

procedure TSgtsCoreObjs.BeforeStart;
var
  i: Integer;
begin
  for i:=Count-1 downto 0 do
    if Items[i] is TSgtsCoreObj then
      TSgtsCoreObj(Items[i]).BeforeStart;
end;

function TSgtsCoreObjs.FindInterface(const InterfaceName: String): TSgtsIface;
var
  i: Integer;
begin
  Result:=nil;
  for i:=Count-1 downto 0 do
    if Items[i] is TSgtsIface then
      if AnsiSameText(TSgtsIface(Items[i]).InterfaceName,InterfaceName) then begin
        Result:=TSgtsIface(Items[i]);
        exit;
      end;
end;

procedure TSgtsCoreObjs.ReadParams;
var
  i: Integer;
begin
  for i:=Count-1 downto 0 do
    if Items[i] is TSgtsIface then
      TSgtsIface(Items[i]).ReadParams;
end;

procedure TSgtsCoreObjs.WriteParams;
var
  i: Integer;
begin
  for i:=Count-1 downto 0 do
    if Items[i] is TSgtsIface then
      TSgtsIface(Items[i]).WriteParams;
end;

procedure TSgtsCoreObjs.DatabaseLink;
var
  i: Integer;
begin
  for i:=0 to Count-1 do
    if Items[i] is TSgtsIface then
      TSgtsIface(Items[i]).DatabaseLink;
end;

procedure TSgtsCoreObjs.CheckPermissions;
var
  i: Integer;
begin
  for i:=0 to Count-1 do
    if Items[i] is TSgtsIface then
      TSgtsIface(Items[i]).CheckPermissions;
end;

procedure TSgtsCoreObjs.ClearReports;
var
  i: Integer;
  Item: TSgtsReportIface;
begin
  Lock;
  try
    for i:=Count-1 downto 0 do begin
      if Items[i] is TSgtsDataIface then
        TSgtsDataIface(Items[i]).ReportClassInfos.Clear;
      if Items[i] is TSgtsFunSourceDataIface then
        TSgtsFunSourceDataIface(Items[i]).ReportClassInfos.Clear;
    end;
    for i:=Count-1 downto 0 do begin
      if Items[i] is TSgtsReportIface then begin
        Item:=TSgtsReportIface(Items[i]);
        Remove(Item);
      end;
    end;
  finally
    Unlock;
  end;
end;

procedure TSgtsCoreObjs.ClearGraphs;
var
  i: Integer;
begin
  Lock;
  try
    for i:=Count-1 downto 0 do begin
      if (Items[i] is TSgtsBaseGraphIface) and
         (TSgtsBaseGraphIface(Items[i]).GraphId<>0) then
        Remove(Items[i]);
    end;
  finally
    Unlock;
  end;
end;

procedure TSgtsCoreObjs.UpdateContents;
var
  i: Integer;
begin
  for i:=0 to Count-1 do
    if Items[i] is TSgtsFormIface then
      TSgtsFormIface(Items[i]).UpdateContents;
end;

procedure TSgtsCoreObjs.AfterLogin;
var
  i: Integer;
begin
  for i:=0 to Count-1 do
    if Items[i] is TSgtsIface then
      TSgtsIface(Items[i]).AfterLogin;
end;

procedure TSgtsCoreObjs.BeforeReadParams;
var
  i: Integer;
begin
  for i:=0 to Count-1 do
    if Items[i] is TSgtsIface then
      TSgtsIface(Items[i]).BeforeReadParams;
end;

procedure TSgtsCoreObjs.BeforeWriteParams;
var
  i: Integer;
begin
  for i:=0 to Count-1 do
    if Items[i] is TSgtsIface then
      TSgtsIface(Items[i]).BeforeWriteParams;
end;

procedure TSgtsCoreObjs.ClearIfaces;
var
  i: Integer;
begin
  for i:=Count-1 downto 0 do
    if Items[i] is TSgtsIface then
      Remove(Items[i]);
end;

{ TSgtsCore }

constructor TSgtsCore.Create;
begin
  inherited Create;
  FInternalObjs:=TSgtsCoreObjs.Create(true);
  FExternalObjs:=TSgtsCoreObjs.Create(false);

  FCmdLine:=TSgtsCmdLine.Create(Self);
  FInternalObjs.Add(FCmdLine);

  FConfig:=TSgtsConfig.Create(Self);
  FInternalObjs.Add(FConfig);

  FLog:=TSgtsLog.Create(Self);
  FInternalObjs.Add(FLog);

  FDatabaseModules:=TSgtsDatabaseModules.Create(Self);
  FInternalObjs.Add(FDatabaseModules);

  FDatabaseConfig:=TSgtsDatabaseConfig.Create(Self);
  FInternalObjs.Add(FDatabaseConfig);

  FReportModules:=TSgtsReportModules.Create(Self);
  FInternalObjs.Add(FReportModules);

  FInterfaceModules:=TSgtsInterfaceModules.Create(Self);
  FInternalObjs.Add(FInterfaceModules);

  FSplashIface:=TSgtsSplashIface.Create(Self);
  FInternalObjs.Add(FSplashIface);

  FLoginIface:=TSgtsLoginIface.Create(Self);
  FInternalObjs.Add(FLoginIface);

  FMainIface:=TSgtsMainIface.Create(Self);
  FInternalObjs.Add(FMainIface);

  FAboutIface:=TSgtsAboutIface.Create(Self);
  FInternalObjs.Add(FAboutIface);

  FInstallSqlIface:=TSgtsInstallSqlIface.Create(Self);
  FInternalObjs.Add(FInstallSqlIface);

  FExportSqlIface:=TSgtsExportSqlIface.Create(Self);
  FInternalObjs.Add(FExportSqlIface);

  FRefreshCutsIface:=TSgtsRefreshCutsIface.Create(Self);
  FInternalObjs.Add(FRefreshCutsIface);

  FRecalcJournalObservationsIface:=TSgtsRecalcJournalObservationsIface.Create(Self);
  FInternalObjs.Add(FRecalcJournalObservationsIface);

  FRbkAccountsIface:=TSgtsRbkAccountsIface.Create(Self);
  FInternalObjs.Add(FRbkAccountsIface);

  FRbkRolesIface:=TSgtsRbkRolesIface.Create(Self);
  FInternalObjs.Add(FRbkRolesIface);

  FRbkPersonnelsIface:=TSgtsRbkPersonnelsIface.Create(Self);
  FInternalObjs.Add(FRbkPersonnelsIface);

  FRbkPermissionIface:=TSgtsRbkPermissionIface.Create(Self);
  FInternalObjs.Add(FRbkPermissionIface);

  FRbkAccountsRolesIface:=TSgtsRbkAccountsRolesIface.Create(Self);
  FInternalObjs.Add(FRbkAccountsRolesIface);

  FRbkDivisionsIface:=TSgtsRbkDivisionsIface.Create(Self);
  FInternalObjs.Add(FRbkDivisionsIface);

  FRbkObjectsIface:=TSgtsRbkObjectsIface.Create(Self);
  FInternalObjs.Add(FRbkObjectsIface);

  FFunPersonnelManagementIface:=TSgtsFunPersonnelManagementIface.Create(Self);
  FInternalObjs.Add(FFunPersonnelManagementIface);

  FRolesAndAccountsIface:=TSgtsRbkRolesAndAccountsIface.Create(Self);
  FInternalObjs.Add(FRolesAndAccountsIface);

  FPointTypesIface:=TSgtsRbkPointTypesIface.Create(Self);
  FInternalObjs.Add(FPointTypesIface);

  FRbkPointsIface:=TSgtsRbkPointsIface.Create(Self);
  FInternalObjs.Add(FRbkPointsIface);

  FRbkRoutesIface:=TSgtsRbkRoutesIface.Create(Self);
  FInternalObjs.Add(FRbkRoutesIface);

  FRbkMeasureTypesIface:=TSgtsRbkMeasureTypesIface.Create(Self);
  FInternalObjs.Add(FRbkMeasureTypesIface);

  FRbkInstrumentTypesIface:=TSgtsRbkInstrumentTypesIface.Create(Self);
  FInternalObjs.Add(FRbkInstrumentTypesIface);

  FRbkInstrumentsIface:=TSgtsRbkInstrumentsIface.Create(Self);
  FInternalObjs.Add(FRbkInstrumentsIface);

  FRbkMeasureUnitsIface:=TSgtsRbkMeasureUnitsIface.Create(Self);
  FInternalObjs.Add(FRbkMeasureUnitsIface);

  FRbkInstrumentUnitsIface:=TSgtsRbkInstrumentUnitsIface.Create(Self);
  FInternalObjs.Add(FRbkInstrumentUnitsIface);

  FRbkRoutePointsIface:=TSgtsRbkRoutePointsIface.Create(Self);
  FInternalObjs.Add(FRbkRoutePointsIface);

  FRbkMeasureTypeRoutesIface:=TSgtsRbkMeasureTypeRoutesIface.Create(Self);
  FInternalObjs.Add(FRbkMeasureTypeRoutesIface);

  FRbkPersonnelRoutesIface:=TSgtsRbkPersonnelRoutesIface.Create(Self);
  FInternalObjs.Add(FRbkPersonnelRoutesIface);

  FRbkCyclesIface:=TSgtsRbkCyclesIface.Create(Self);
  FInternalObjs.Add(FRbkCyclesIface);

  FRbkPlansIface:=TSgtsRbkPlansIface.Create(Self);
  FInternalObjs.Add(FRbkPlansIface);

  FRbkObjectTreesIface:=TSgtsRbkObjectTreesIface.Create(Self);
  FInternalObjs.Add(FRbkObjectTreesIface);

  FFunPointManagementIface:=TSgtsFunPointManagementIface.Create(Self);
  FInternalObjs.Add(FFunPointManagementIface);

  FAlgorithmsIface:=TSgtsRbkAlgorithmsIface.Create(Self);
  FInternalObjs.Add(FAlgorithmsIface);

  FRbkMeasureTypeAlgorithmsIface:=TSgtsRbkMeasureTypeAlgorithmsIface.Create(Self);
  FInternalObjs.Add(FRbkMeasureTypeAlgorithmsIface);

  FRbkLevelsIface:=TSgtsRbkLevelsIface.Create(Self);
  FInternalObjs.Add(FRbkLevelsIface);

  FRbkParamsIface:=TSgtsRbkParamsIface.Create(Self);
  FInternalObjs.Add(FRbkParamsIface);

  FRbkMeasureTypeParamsIface:=TSgtsRbkMeasureTypeParamsIface.Create(Self);
  FInternalObjs.Add(FRbkMeasureTypeParamsIface);

  FRbkParamLevelsIface:=TSgtsRbkParamLevelsIface.Create(Self);
  FInternalObjs.Add(FRbkParamLevelsIface);

  FJrnJournalFieldsIface:=TSgtsJrnJournalFieldsIface.Create(Self);
  FInternalObjs.Add(FJrnJournalFieldsIface);

  FJrnJournalObservationsIface:=TSgtsJrnJournalObservationsIface.Create(Self);
  FInternalObjs.Add(FJrnJournalObservationsIface);

  FJrnJournalsIface:=TSgtsJrnJournalsIface.Create(Self);
  FInternalObjs.Add(FJrnJournalsIface);

  FRbkAccountInsertIface:=TSgtsRbkAccountInsertIface.Create(Self,nil);
  FInternalObjs.Add(FRbkAccountInsertIface);
  
  FFunSourceDataIface:=TSgtsFunSourceDataIface.Create(Self);
  FInternalObjs.Add(FFunSourceDataIface);

  FRbkFileReportsIface:=TSgtsRbkFileReportsIface.Create(Self);
  FInternalObjs.Add(FRbkFileReportsIface);

  FRbkBaseReportsIface:=TSgtsRbkBaseReportsIface.Create(Self);
  FInternalObjs.Add(FRbkBaseReportsIface);

  FRbkParamInstrumentsIface:=TSgtsRbkParamInstrumentsIface.Create(Self);
  FInternalObjs.Add(FRbkParamInstrumentsIface);

  FRbkDocumentsIface:=TSgtsRbkDocumentsIface.Create(Self);
  FInternalObjs.Add(FRbkDocumentsIface);

  FRbkPointDocumentsIface:=TSgtsRbkPointDocumentsIface.Create(Self);
  FInternalObjs.Add(FRbkPointDocumentsIface);

  FRbkConvertersIface:=TSgtsRbkConvertersIface.Create(Self);
  FInternalObjs.Add(FRbkConvertersIface);

  FRbkComponentsIface:=TSgtsRbkComponentsIface.Create(Self);
  FInternalObjs.Add(FRbkComponentsIface);

  FRbkDevicesIface:=TSgtsRbkDevicesIface.Create(Self);
  FInternalObjs.Add(FRbkDevicesIface);

  FRbkDevicePointsIface:=TSgtsRbkDevicePointsIface.Create(Self);
  FInternalObjs.Add(FRbkDevicePointsIface);

  FRbkDrawingsIface:=TSgtsRbkDrawingsIface.Create(Self);
  FInternalObjs.Add(FRbkDrawingsIface);

  FRbkObjectDrawingsIface:=TSgtsRbkObjectDrawingsIface.Create(Self);
  FInternalObjs.Add(FRbkObjectDrawingsIface);

  FRbkObjectDocumentsIface:=TSgtsRbkObjectDocumentsIface.Create(Self);
  FInternalObjs.Add(FRbkObjectDocumentsIface);

  FRbkConverterPassportsIface:=TSgtsRbkConverterPassportsIface.Create(Self);
  FInternalObjs.Add(FRbkConverterPassportsIface);

  FRbkInstrumentPassportsIface:=TSgtsRbkInstrumentPassportsIface.Create(Self);
  FInternalObjs.Add(FRbkInstrumentPassportsIface);

  FRbkPointPassportsIface:=TSgtsRbkPointPassportsIface.Create(Self);
  FInternalObjs.Add(FRbkPointPassportsIface);

  FRbkObjectPassportsIface:=TSgtsRbkObjectPassportsIface.Create(Self);
  FInternalObjs.Add(FRbkObjectPassportsIface);

  FJrnJournalActionsIface:=TSgtsJrnJournalActionsIface.Create(Self);
  FInternalObjs.Add(FJrnJournalActionsIface);

  FRbkInterfaceReportsIface:=TSgtsRbkInterfaceReportsIface.Create(Self);
  FInternalObjs.Add(FRbkInterfaceReportsIface);

  FRbkCycleEditIface:=TSgtsRbkCycleUpdateIface.Create(Self,nil);
  FInternalObjs.Add(FRbkCycleEditIface);

  FRbkCheckingsIface:=TSgtsRbkCheckingsIface.Create(Self);
  FInternalObjs.Add(FRbkCheckingsIface);

  FRbkCutsIface:=TSgtsRbkCutsIface.Create(Self);
  FInternalObjs.Add(FRbkCutsIface);

  FRbkPointInstrumentsIface:=TSgtsRbkPointInstrumentsIface.Create(Self);
  FInternalObjs.Add(FRbkPointInstrumentsIface);

  FGphJournalIface:=TSgtsGrpJournalIface.Create(Self);
  FInternalObjs.Add(FGphJournalIface);

  FRbkGraphsIface:=TSgtsRbkGraphsIface.Create(Self);
  FInternalObjs.Add(FRbkGraphsIface);

  FRbkGroupsIface:=TSgtsRbkGroupsIface.Create(Self);
  FInternalObjs.Add(FRbkGroupsIface);

  FRbkGroupObjectsIface:=TSgtsRbkGroupObjectsIface.Create(Self);
  FInternalObjs.Add(FRbkGroupObjectsIface);

  FRbkDefectViewsIface:=TSgtsRbkDefectViewsIface.Create(Self);
  FInternalObjs.Add(FRbkDefectViewsIface);

  FRbkCriteriasIface:=TSgtsRbkCriteriasIface.Create(Self);
  FInternalObjs.Add(FRbkCriteriasIface);

  FOptionsIface:=TSgtsOptionsIface.Create(Self);
  FInternalObjs.Add(FOptionsIface);

  FApplicationEvents:=TApplicationEvents.Create(Self);
  FApplicationEvents.OnException:=ApplicationEventsException;
end;

destructor TSgtsCore.Destroy;
begin
  FApplicationEvents.Free;
  CloseHandle(FMutexHandle);
  FreeAndNil(FExternalObjs);
  FreeAndNil(FInternalObjs);
  inherited Destroy;
end;

procedure TSgtsCore.CreateObj(AObjClass: TSgtsCoreObjClass; var AObj: TSgtsCoreObj);
begin
  AObj:=AObjClass.Create(Self);
end;

function TSgtsCore._GetConfig: ISgtsConfig;
begin
  Result:=FConfig as ISgtsConfig;
end;

function TSgtsCore._GetCmdLine: ISgtsCmdLine;
begin
  Result:=FCmdLine as ISgtsCmdLine;
end;

function TSgtsCore._GetLog: ISgtsLog;
begin
  Result:=FLog as ISgtsLog;
end;

function TSgtsCore._GetDatabaseModules: ISgtsDatabaseModules;
begin
  Result:=FDatabaseModules as ISgtsDatabaseModules;
end;

function TSgtsCore._GetReportModules: ISgtsReportModules;
begin
  Result:=FReportModules as ISgtsReportModules;
end;

function TSgtsCore._GetInterfaceModules: ISgtsInterfaceModules;
begin
  Result:=FInterfaceModules as ISgtsInterfaceModules;
end;

function TSgtsCore._GetDatabaseConfig: ISgtsDatabaseConfig;
begin
  Result:=FDatabaseConfig as ISgtsDatabaseConfig;
end;

function TSgtsCore._GetAboutForm: ISgtsAboutForm;
begin
  Result:=FAboutIface as ISgtsAboutForm;
end;

function TSgtsCore._GetSplashForm: ISgtsSplashForm;
begin
  Result:=FSplashIface as ISgtsSplashForm;
end;

function TSgtsCore._GetOptionsForm: ISgtsOptionsForm;
begin
  Result:=FOptionsIface as ISgtsOptionsForm;
end;

function TSgtsCore._GetMainForm: ISgtsMainForm;
begin
  Result:=FMainIface as ISgtsMainForm;
end;

function TSgtsCore._GetInstallSqlForm: ISgtsInstallSqlForm;
begin
  Result:=FInstallSqlIface as ISgtsInstallSqlForm;
end;

function TSgtsCore._GetExportSqlForm: ISgtsExportSqlForm;
begin
  Result:=FExportSqlIface as ISgtsExportSqlForm;
end;

function TSgtsCore._GetRefreshCutsForm: ISgtsChildForm;
begin
  Result:=FRefreshCutsIface as ISgtsChildForm;
end;

function TSgtsCore._GetRecalcJournalObservationsForm: ISgtsChildForm;
begin
  Result:=FRecalcJournalObservationsIface as ISgtsChildForm;
end;

function TSgtsCore._GetRbkAccountsForm: ISgtsDataForm;
begin
  Result:=FRbkAccountsIface as ISgtsDataForm;
end;

function TSgtsCore._GetRbkRolesForm: ISgtsDataForm;
begin
  Result:=FRbkRolesIface as ISgtsDataForm;
end;

function TSgtsCore._GetRbkAccountsRolesForm: ISgtsDataForm;
begin
  Result:=FRbkAccountsRolesIface as ISgtsDataForm;
end;

function TSgtsCore._GetRbkDivisionsForm: ISgtsDataForm;
begin
  Result:=FRbkDivisionsIface as ISgtsDataForm;
end;

function TSgtsCore._GetRbkObjectsForm: ISgtsDataForm;
begin
  Result:=FRbkObjectsIface as ISgtsDataForm;
end;

function TSgtsCore._GetRbkPersonnelsForm: ISgtsDataForm;
begin
  Result:=FRbkPersonnelsIface as ISgtsDataForm;
end;

function TSgtsCore._GetFunPersonnelManagementForm: ISgtsDataForm;
begin
  Result:=FFunPersonnelManagementIface as ISgtsDataForm;
end;

function TSgtsCore._GetRbkPointTypesForm: ISgtsDataForm;
begin
  Result:=FPointTypesIface as ISgtsDataForm;
end;

function TSgtsCore._GetRbkPointsForm: ISgtsDataForm;
begin
  Result:=FRbkPointsIface as ISgtsDataForm;
end;

function TSgtsCore._GetRbkRoutesForm: ISgtsDataForm;
begin
  Result:=FRbkRoutesIface as ISgtsDataForm;
end;

function TSgtsCore._GetRbkMeasureTypesForm: ISgtsDataForm;
begin
  Result:=FRbkMeasureTypesIface as ISgtsDataForm;
end;

function TSgtsCore._GetRbkInstrumentTypesForm: ISgtsDataForm;
begin
  Result:=FRbkInstrumentTypesIface as ISgtsDataForm;
end;

function TSgtsCore._GetRbkInstrumentsForm: ISgtsDataForm;
begin
  Result:=FRbkInstrumentsIface as ISgtsDataForm;
end;

function TSgtsCore._GetRbkMeasureUnitsForm: ISgtsDataForm;
begin
  Result:=FRbkMeasureUnitsIface as ISgtsDataForm;
end;

function TSgtsCore._GetRbkInstrumentUnitsForm: ISgtsDataForm;
begin
  Result:=FRbkInstrumentUnitsIface as ISgtsDataForm;
end;

function TSgtsCore._GetRbkRoutePointsForm: ISgtsDataForm;
begin
  Result:=FRbkRoutePointsIface as ISgtsDataForm;
end;

function TSgtsCore._GetRbkMeasureTypeRoutesForm: ISgtsDataForm;
begin
  Result:=FRbkMeasureTypeRoutesIface as ISgtsDataForm;
end;

function TSgtsCore._GetRbkPersonnelRoutesForm: ISgtsDataForm;
begin
  Result:=FRbkPersonnelRoutesIface as ISgtsDataForm;
end;

function TSgtsCore._GetRbkCyclesForm: ISgtsDataForm;
begin
  Result:=FRbkCyclesIface as ISgtsDataForm;
end;

function TSgtsCore._GetRbkPlansForm: ISgtsDataForm;
begin
  Result:=FRbkPlansIface as ISgtsDataForm;
end;

function TSgtsCore._GetRbkObjectTreesForm: ISgtsDataForm;
begin
  Result:=FRbkObjectTreesIface as ISgtsDataForm;
end;

function TSgtsCore._GetFunPointManagementForm: ISgtsDataForm;
begin
  Result:=FFunPointManagementIface as ISgtsDataForm;
end;

function TSgtsCore._GetRbkAlgorithmsForm: ISgtsDataForm;
begin
  Result:=FAlgorithmsIface as ISgtsDataForm;
end;

function TSgtsCore._GetRbkMeasureTypeAlgorithmsForm: ISgtsDataForm;
begin
  Result:=FRbkMeasureTypeAlgorithmsIface as ISgtsDataForm;
end;

function TSgtsCore._GetRbkLevelsForm: ISgtsDataForm;
begin
  Result:=FRbkLevelsIface as ISgtsDataForm;
end;

function TSgtsCore._GetRbkParamsForm: ISgtsDataForm;
begin
  Result:=FRbkParamsIface as ISgtsDataForm;
end;

function TSgtsCore._GetRbkMeasureTypeParamsForm: ISgtsDataForm;
begin
  Result:=FRbkMeasureTypeParamsIface as ISgtsDataForm;
end;

function TSgtsCore._GetRbkParamLevelsForm: ISgtsDataForm;
begin
  Result:=FRbkParamLevelsIface as ISgtsDataForm;
end;

function TSgtsCore._GetJrnJournalFieldsForm: ISgtsDataForm;
begin
  Result:=FJrnJournalFieldsIface as ISgtsDataForm;
end;

function TSgtsCore._GetJrnJournalObservationsForm: ISgtsDataForm;
begin
  Result:=FJrnJournalObservationsIface as ISgtsDataForm;
end;

function TSgtsCore._GetJrnJournalsForm: ISgtsDataForm;
begin
  Result:=FJrnJournalsIface as ISgtsDataForm;
end;

function TSgtsCore._GetRbkAccountInsertForm: ISgtsDataInsertForm;
begin
  Result:=FRbkAccountInsertIface as ISgtsDataInsertForm;
end;

function TSgtsCore._GetFunSourceDataForm: ISgtsChildForm;
begin
  Result:=FFunSourceDataIface as ISgtsChildForm;
end;

function TSgtsCore._GetRbkPermissionForm: ISgtsDataForm;
begin
  Result:=FRbkPermissionIface as ISgtsDataForm;
end;

function TSgtsCore._GetRbkFileReportsForm: ISgtsDataForm;
begin
  Result:=FRbkFileReportsIface as ISgtsDataForm;
end;

function TSgtsCore._GetRbkBaseReportsForm: ISgtsDataForm;
begin
  Result:=FRbkBaseReportsIface as ISgtsDataForm;
end;

function TSgtsCore._GetRbkParamInstrumentsForm: ISgtsDataForm;
begin
  Result:=FRbkParamInstrumentsIface as ISgtsDataForm;
end;

function TSgtsCore._GetRbkDocumentsForm: ISgtsDataForm;
begin
  Result:=FRbkDocumentsIface as ISgtsDataForm;
end;

function TSgtsCore._GetRbkPointDocumentsForm: ISgtsDataForm;
begin
  Result:=FRbkPointDocumentsIface as ISgtsDataForm;
end;

function TSgtsCore._GetRbkConvertersForm: ISgtsDataForm;
begin
  Result:=FRbkConvertersIface as ISgtsDataForm;
end;

function TSgtsCore._GetRbkCriteriasForm: ISgtsDataForm;
begin
  Result:=FRbkCriteriasIface as ISgtsDataForm;
end;

function TSgtsCore._GetRbkComponentsForm: ISgtsDataForm;
begin
  Result:=FRbkComponentsIface as ISgtsDataForm;
end;

function TSgtsCore._GetRbkDevicesForm: ISgtsDataForm;
begin
  Result:=FRbkDevicesIface as ISgtsDataForm;
end;

function TSgtsCore._GetRbkDefectViewsForm: ISgtsDataForm;
begin
  Result:=FRbkDefectViewsIface as  ISgtsDataForm;
end;

function TSgtsCore._GetRbkDevicePointsForm: ISgtsDataForm;
begin
  Result:=FRbkDevicePointsIface as ISgtsDataForm;
end;

function TSgtsCore._GetRbkDrawingsForm: ISgtsDataForm;
begin
  Result:=FRbkDrawingsIface as ISgtsDataForm;
end;

function TSgtsCore._GetRbkObjectDrawingsForm: ISgtsDataForm;
begin
  Result:=FRbkObjectDrawingsIface as ISgtsDataForm;
end;

function TSgtsCore._GetRbkObjectDocumentsForm: ISgtsDataForm;
begin
  Result:=FRbkObjectDocumentsIface as ISgtsDataForm;
end;

function TSgtsCore._GetRbkConverterPassportsForm: ISgtsDataForm;
begin
  Result:=FRbkConverterPassportsIface as ISgtsDataForm;
end;

function TSgtsCore._GetRbkInstrumentPassportsForm: ISgtsDataForm;
begin
  Result:=FRbkInstrumentPassportsIface as ISgtsDataForm;
end;

function TSgtsCore._GetRbkPointPassportsForm: ISgtsDataForm;
begin
  Result:=FRbkPointPassportsIface as ISgtsDataForm;
end;

function TSgtsCore._GetRbkObjectPassportsForm: ISgtsDataForm;
begin
  Result:=FRbkObjectPassportsIface as ISgtsDataForm;
end;

function TSgtsCore._GetJrnJournalActionsForm: ISgtsDataForm;
begin
  Result:=FJrnJournalActionsIface as ISgtsDataForm;
end;

function TSgtsCore._GetRbkInterfaceReportsForm: ISgtsDataForm;
begin
  Result:=FRbkInterfaceReportsIface as ISgtsDataForm;
end;

function TSgtsCore._GetRbkCheckingsForm: ISgtsDataForm;
begin
  Result:=FRbkCheckingsIface as ISgtsDataForm;
end;

function TSgtsCore._GetRbkCutsForm: ISgtsDataForm;
begin
  Result:=FRbkCutsIface as ISgtsDataForm;
end;

function TSgtsCore._GetRbkPointInstrumentsForm: ISgtsDataForm;
begin
  Result:=FRbkPointInstrumentsIface as ISgtsDataForm;
end;

function TSgtsCore._GetRbkGraphsForm: ISgtsDataForm;
begin
  Result:=FRbkGraphsIface as ISgtsDataForm;
end;

function TSgtsCore._GetRbkGroupsForm: ISgtsDataForm;
begin
  Result:=FRbkGroupsIface as ISgtsDataForm;
end;

function TSgtsCore._GetRbkGroupObjectsForm: ISgtsDataForm;
begin
  Result:=FRbkGroupObjectsIface as ISgtsDataForm;
end;

function TSgtsCore._GetTitle: String;
begin
  Result:=FTitle;
end;

function TSgtsCore._GetVersion: String;
begin
  Result:=FVersion;
end;

function TSgtsCore._GetInstallSqlFile: String;
begin
  Result:=FInstallSqlFile;
end;

function TSgtsCore._GetInstallSqlDBModule: String;
begin
  Result:=FInstallSqlDBModule;
end;

function TSgtsCore.LogWrite(const Message: String; LogType: TSgtsLogType=ltInformation): Boolean;
var
  S: String;
begin
  Result:=false;
  if Assigned(FLog) then begin
    S:=Format(SLogNameFormat,[Name,Message]);
    Result:=FLog.Write(S,LogType);
  end;
end;

procedure TSgtsCore.Init;
begin
  inherited Init;
  FTitle:=FConfig.Read(Name,SConfigParamTitle,STitleDefault);
  FInternalObjs.Init;
  RegisterFileIfaces;
  FLoginIface.BeforeReadParams;
  FLoginIface.ReadParams;
  FMainIface.Caption:=FTitle;
end;

procedure TSgtsCore.Done;
begin
  FLoginIface.BeforeWriteParams;
  FLoginIface.WriteParams;
  FInternalObjs.Done;
  FInternalObjs.ClearIfaces;
  inherited Done;
end;

function TSgtsCore.GetStartupMode: TSgtsCoreStartupMode;
begin
  Result:=smDefault;

  if FCmdLine.ParamExists(SParamInstallSql) then begin
    FInstallSqlFile:=FCmdLine.ValueByParam(SParamInstallSql,0);
    FInstallSqlDBModule:=FCmdLine.ValueByParam(SParamInstallSql,1);
    if not FileExists(FInstallSqlFile) then begin
      FInstallSqlFile:=ExtractFilePath(FCmdLine.FileName)+FInstallSqlFile;
    end;
    if FileExists(FInstallSqlFile) then begin
      Result:=smInstallSql;
      exit;
    end else begin
      FInstallSqlFile:='';
      FInstallSqlDBModule:='';
    end;
  end;

  if FCmdLine.ParamExists(SParamUnInstallSql) then begin
    FInstallSqlFile:=FCmdLine.ValueByParam(SParamUnInstallSql,0);
    FInstallSqlDBModule:=FCmdLine.ValueByParam(SParamUnInstallSql,1);
    if not FileExists(FInstallSqlFile) then begin
      FInstallSqlFile:=ExtractFilePath(FCmdLine.FileName)+FInstallSqlFile;
    end;
    if FileExists(FInstallSqlFile) then begin
      Result:=smUnInstallSql;
      exit;
    end else begin
      FInstallSqlFile:='';
      FInstallSqlDBModule:='';
    end;
  end;

  if FCmdLine.ParamExists(SParamNoProfile) then
    Result:=smNoProfile;
  

end;

procedure TSgtsCore.InitFileReportIfaces;
var
  DS: TSgtsDatabaseCDS;
  Iface: TSgtsFileReportIface;
begin
  if Assigned(FDatabaseModules.Current) and
     Assigned(FDatabaseModules.Current.Database) then begin
    if FDatabaseModules.Current.Database.ProviderExists(SProviderSelectFileReports) then begin
      DS:=TSgtsDatabaseCDS.Create(Self);
      try
        DS.ProviderName:=SProviderSelectFileReports;
        with DS.SelectDefs do begin
          AddInvisible(SDb_FileReportId);
          AddInvisible(SDb_Name);
          AddInvisible(SDb_Description);
          AddInvisible(SDb_ModuleName);
          AddInvisible(SDb_FileName);
          AddInvisible(SDb_Menu);
        end;
        DS.Orders.Add(SDb_Priority,otAsc);
        DS.Open;
        if DS.Active and not DS.IsEmpty then begin
          DS.First;
          while not DS.Eof do begin
            if not InterfaceExists(DS.Fields[1].AsString) then begin
              Iface:=TSgtsFileReportIface.Create(Self);
              Iface.Init(DS.Fields[0].Value,
                         DS.Fields[1].AsString,
                         DS.Fields[2].AsString,
                         DS.Fields[3].AsString,
                         DS.Fields[4].AsString,
                         DS.Fields[5].AsString);
              Iface.ReadParams;                          
              FInternalObjs.Add(Iface);
            end;  
            DS.Next;
          end;
        end;
      finally
        DS.Free;
      end;
    end;
  end;
end;

procedure TSgtsCore.InitBaseReportIfaces;
var
  DSReports: TSgtsDatabaseCDS;
  DSInterfaces: TSgtsDatabaseCDS;
  Str: TStringList;
  Iface: TSgtsBaseReportIface;
begin
  if Assigned(FDatabaseModules.Current) and
     Assigned(FDatabaseModules.Current.Database) then begin
    if FDatabaseModules.Current.Database.ProviderExists(SProviderSelectBaseReports) then begin
      DSReports:=TSgtsDatabaseCDS.Create(Self);
      DSInterfaces:=TSgtsDatabaseCDS.Create(Self);
      Str:=TStringList.Create;
      try
        DSReports.ProviderName:=SProviderSelectBaseReports;
        with DSReports.SelectDefs do begin
          AddInvisible(SDb_BaseReportId);
          AddInvisible(SDb_Name);
          AddInvisible(SDb_Description);
          AddInvisible(SDb_Menu);
          AddInvisible(SDb_ReportExists);
        end;
        DSReports.Orders.Add(SDb_Priority,otAsc);
        DSReports.Open;

        DSInterfaces.ProviderName:=SProviderSelectInterfaceReports;
        with DSInterfaces.SelectDefs do begin
          AddInvisible(SDb_Interface);
          AddInvisible(SDb_BaseReportId);
        end;
        DSInterfaces.Orders.Add(SDb_Priority,otAsc);
        DSInterfaces.Open;

        if DSReports.Active and not DSReports.IsEmpty and
           DSInterfaces.Active then begin
          DSReports.First;
          while not DSReports.Eof do begin
            DSInterfaces.BeginUpdate;
            try
              DSInterfaces.Filter:=Format('%s=%s',[SDb_BaseReportId,QuotedStr(DSReports.FieldByName(SDb_BaseReportId).AsString)]);
              DSInterfaces.Filtered:=true;
              Str.Clear;
              DSInterfaces.First;
              while not DSInterfaces.Eof do begin
                Str.Add(DSInterfaces.FieldByName(SDb_Interface).AsString);
                DSInterfaces.Next;
              end;
              if not InterfaceExists(DSReports.FieldByName(SDb_Name).AsString) then begin
                Iface:=TSgtsBaseReportIface.Create(Self);
                Iface.Init(DSReports.FieldByName(SDb_BaseReportId).Value,
                           DSReports.FieldByName(SDb_Name).AsString,
                           DSReports.FieldByName(SDb_Description).AsString,
                           Str.Text,
                           DSReports.FieldByName(SDb_Menu).AsString,
                           Boolean(DSReports.FieldByName(SDb_ReportExists).AsInteger));
                Iface.BeforeReadParams;                           
                Iface.ReadParams;                           
                FInternalObjs.Add(Iface);
              end;
            finally
              DSInterfaces.EndUpdate;
            end;  
            DSReports.Next;
          end;
        end;
      finally
        Str.Free;
        DSInterfaces.Free;
        DSReports.Free;
      end;
    end;   
  end;
end;

procedure TSgtsCore.InitBaseGraphIfaces;
var
  DS: TSgtsDatabaseCDS;

  function CreateIfaceByGraphType: TSgtsBaseGraphIface;
  begin
    Result:=nil;
    case  DS.FieldByName(SDb_GraphType).AsInteger of
      0: Result:=TSgtsBaseGraphIface.Create(Self);
      1: Result:=TSgtsBaseGraphPeriodIface.Create(Self);
      2: Result:=TSgtsBaseGraphPeriodPointsIface.Create(Self);
      3: Result:=TSgtsBaseGraphPeriodObjectsIface.Create(Self);
    end;
  end;

var
  Iface: TSgtsBaseGraphIface;
begin
  if Assigned(FDatabaseModules.Current) and
     Assigned(FDatabaseModules.Current.Database) then begin
    if FDatabaseModules.Current.Database.ProviderExists(SProviderSelectGraphs) then begin
      DS:=TSgtsDatabaseCDS.Create(Self);
      try
        DS.ProviderName:=SProviderSelectGraphs;
        with DS.SelectDefs do begin
          AddInvisible(SDb_GraphId);
          AddInvisible(SDb_Name);
          AddInvisible(SDb_Description);
          AddInvisible(SDb_Menu);
          AddInvisible(SDb_GraphType);
          AddInvisible(SDb_Determination);
          AddInvisible(SDb_CutDetermination);
          AddInvisible(SDb_ViewName);
          AddInvisible(SDb_Condition);
        end;
        DS.Orders.Add(SDb_Priority,otAsc);
        DS.Open;
        if DS.Active and not DS.IsEmpty then begin
          DS.First;
          while not DS.Eof do begin
            if not InterfaceExists(DS.FieldByName(SDb_Name).AsString) then begin
              Iface:=CreateIfaceByGraphType;
              if Assigned(Iface) then begin
                Iface.Init(DS.FieldByName(SDb_GraphId).AsInteger,
                           DS.FieldByName(SDb_Name).AsString,
                           DS.FieldByName(SDb_Description).AsString,
                           DS.FieldByName(SDb_Menu).AsString,
                           DS.FieldByName(SDb_Determination).AsString,
                           DS.FieldByName(SDb_CutDetermination).AsString,
                           DS.FieldByName(SDb_ViewName).AsString,
                           DS.FieldByName(SDb_Condition).AsString);
                Iface.BeforeReadParams;                           
                Iface.ReadParams;                           
                FInternalObjs.Add(Iface);
              end;
            end;
            DS.Next;
          end;
        end;
      finally
        DS.Free;
      end;    
    end;
  end;   
end;

procedure TSgtsCore.Start;
var
  Mode: TSgtsCoreStartupMode;
  S: String;
begin
  Mode:=GetStartupMode;

  LogWrite(DupeString('-',50));
  LogWrite(Format(SCoreStartDir,[ExtractFileDir(FCmdLine.FileName)]));
  LogWrite(Format(SCoreStartCmd,[FCmdLine.Text]));
  LogWrite(Format(SCoreStartMode,[GetEnumName(TypeInfo(TSgtsCoreStartupMode),Integer(Mode))]));

  S:=FCmdLine.FileName;
  FVersion:=GetFileVersionEx(S);
  LogWrite(Format(SCoreStartFileVersionSize,[S,FVersion,GetFileSizeEx(S)]));
  S:=ExtractFilePath(FCmdLine.FileName)+SMidasDll;
  LogWrite(Format(SCoreStartFileVersionSize,[S,GetFileVersionEx(S),GetFileSizeEx(S)]));
  S:=ExtractFilePath(FCmdLine.FileName)+SObjectsBpl;
  LogWrite(Format(SCoreStartFileVersionSize,[S,GetFileVersionEx(S),GetFileSizeEx(S)]));
  S:=ExtractFilePath(FCmdLine.FileName)+SReportBpl;
  LogWrite(Format(SCoreStartFileVersionSize,[S,GetFileVersionEx(S),GetFileSizeEx(S)]));
  S:=GetModuleName(HInstance);
  LogWrite(Format(SCoreStartFileVersionSize,[S,GetFileVersionEx(S),GetFileSizeEx(S)]));

  S:=ExtractFilePath(FCmdLine.FileName)+SRtlBpl;
  LogWrite(Format(SCoreStartFileVersionSize,[S,GetFileVersionEx(S),GetFileSizeEx(S)]));
  S:=ExtractFilePath(FCmdLine.FileName)+SVclBpl;
  LogWrite(Format(SCoreStartFileVersionSize,[S,GetFileVersionEx(S),GetFileSizeEx(S)]));
  S:=ExtractFilePath(FCmdLine.FileName)+SDsnapBpl;
  LogWrite(Format(SCoreStartFileVersionSize,[S,GetFileVersionEx(S),GetFileSizeEx(S)]));
  S:=ExtractFilePath(FCmdLine.FileName)+SDbrtlBpl;
  LogWrite(Format(SCoreStartFileVersionSize,[S,GetFileVersionEx(S),GetFileSizeEx(S)]));
  S:=ExtractFilePath(FCmdLine.FileName)+SVcldbBpl;
  LogWrite(Format(SCoreStartFileVersionSize,[S,GetFileVersionEx(S),GetFileSizeEx(S)]));
  S:=ExtractFilePath(FCmdLine.FileName)+SVclxBpl;
  LogWrite(Format(SCoreStartFileVersionSize,[S,GetFileVersionEx(S),GetFileSizeEx(S)]));
  S:=ExtractFilePath(FCmdLine.FileName)+SVclsmpBpl;
  LogWrite(Format(SCoreStartFileVersionSize,[S,GetFileVersionEx(S),GetFileSizeEx(S)]));
  S:=ExtractFilePath(FCmdLine.FileName)+SVcljpgBpl;
  LogWrite(Format(SCoreStartFileVersionSize,[S,GetFileVersionEx(S),GetFileSizeEx(S)]));
  S:=ExtractFilePath(FCmdLine.FileName)+STeeBpl;
  LogWrite(Format(SCoreStartFileVersionSize,[S,GetFileVersionEx(S),GetFileSizeEx(S)]));
  S:=ExtractFilePath(FCmdLine.FileName)+STeedbBpl;
  LogWrite(Format(SCoreStartFileVersionSize,[S,GetFileVersionEx(S),GetFileSizeEx(S)]));
  S:=ExtractFilePath(FCmdLine.FileName)+STeeuiBpl;
  LogWrite(Format(SCoreStartFileVersionSize,[S,GetFileVersionEx(S),GetFileSizeEx(S)]));

  LogWrite(Format(SCoreStartConfigText,[FConfig.Text]));

  case Mode of
     smDefault,smNoProfile: begin
      FSplashIface.Show;
      FSplashIface.Status(SLoadModules);
      FDatabaseModules.Load;
      FReportModules.Load;
      FInterfaceModules.Load;
      FExternalObjs.Init;
      try
        Sleep(DSleepSplashStart);
        FSplashIface.Status(SAuthentification);
        if FLoginIface.Login then begin
          FInternalObjs.AfterLogin;
          FExternalObjs.AfterLogin;

          if Mode<>smNoProfile then
            FDatabaseConfig.LoadFromDatabase;

          FInternalObjs.BeforeReadParams;
          FExternalObjs.BeforeReadParams;

          FInternalObjs.ReadParams;
          FExternalObjs.ReadParams;
          try
            FSplashIface.Show;

            InitFileReportIfaces;
            InitBaseReportIfaces;
            InitBaseGraphIfaces;

            FInternalObjs.DatabaseLink;
            FExternalObjs.DatabaseLink;

            FSplashIface.Status(SNearlyAllReady);
            FSplashIface.StayOnTop;
            FMainIface.Show;

            FInternalObjs.BeforeStart;
            FExternalObjs.BeforeStart;

            FMainIface.UpdateContents;
            FSplashIface.HideByTimer(DSleepSplashStart);
            FMainIface.Start;
          finally
            FInternalObjs.BeforeWriteParams;
            FExternalObjs.BeforeWriteParams;

            FInternalObjs.WriteParams;
            FExternalObjs.WriteParams;
            
            FDatabaseConfig.SaveToDatabase;
          end;
        end;
      finally
        FExternalObjs.Done;
        FExternalObjs.Clear;
        FInterfaceModules.Unload;
        FReportModules.Unload;
        FDatabaseModules.Unload;
      end;
    end;
    smInstallSql: begin
      FDatabaseModules.Load;
      try
        FInstallSqlIface.Install;
      finally
        FDatabaseModules.Unload;
      end;  
    end;
    smUninstallSql: begin
      FDatabaseModules.Load;
      try
        FInstallSqlIface.UnInstall;
      finally
        FDatabaseModules.Unload;
      end;
    end;
  end;
end;

procedure TSgtsCore.Stop;
begin
//  FMainFormIntf:=nil;
end;

procedure TSgtsCore.ReadParams;
begin
  FInternalObjs.ReadParams;
  FExternalObjs.ReadParams;
end;

procedure TSgtsCore.WriteParams;
begin
  FInternalObjs.WriteParams;
  FExternalObjs.WriteParams;
end;

function TSgtsCore.Exists: Boolean;
var
  Ret: DWord;
  S: String;
begin
  FTitle:=FConfig.Read(Name,SConfigParamTitle,STitleDefault);
  S:=Format(SMutexFormat,[FCmdLine.FileName,FConfig.FileName]);
  FMutexHandle:=CreateMutex(nil,false,PChar(S));
  Ret:=GetLastError;
  Result:=Ret=ERROR_ALREADY_EXISTS;
end;

procedure TSgtsCore.GetInterfaceNames(Names: TStrings; AClass: TComponentClass=nil);

  procedure GetInterfaceNamesLocal(List: TSgtsCoreObjs);
  var
    i: Integer;
    Obj: TSgtsObj;
    Iface: TSgtsIface;
    Flag: Boolean;
  begin
    List.Lock;
    try
      for i:=0 to List.Count-1 do begin
        Obj:=List.Items[i];
        if Assigned(Obj) and (Obj is TSgtsIface) then begin
          Iface:=TSgtsIface(Obj);
          Flag:=Trim(Iface.InterfaceName)<>'';
          if Assigned(AClass) then
            Flag:=Iface is AClass;
          if Flag then begin
            Names.AddObject(Iface.InterfaceName,Iface);
          end;
        end;
      end;
    finally
      List.Unlock;
    end;  
  end;

begin
  Names.BeginUpdate;
  try
    GetInterfaceNamesLocal(FInternalObjs);
    GetInterfaceNamesLocal(FExternalObjs);
  finally
    Names.EndUpdate;
  end;
end;

procedure TSgtsCore.GetInterfacePermissions(const IntrefaceName: String; Permissions: TStrings);

  procedure GetInterfacePermissionsLocal(List: TSgtsCoreObjs);
  var
    i: Integer;
    Iface: TSgtsIface;
    Perm: TSgtsIfacePermission;
  begin
    Iface:=List.FindInterface(IntrefaceName);
    if Assigned(Iface) then begin
      for i:=0 to Iface.Permissions.Count-1 do begin
        Perm:=Iface.Permissions.Items[i];
        Permissions.Add(Perm.Name);
      end;
    end;
  end;

begin
  Permissions.BeginUpdate;
  try
    GetInterfacePermissionsLocal(FInternalObjs);
    GetInterfacePermissionsLocal(FExternalObjs);
  finally
    Permissions.EndUpdate;
  end;
end;

procedure TSgtsCore.GetInterfacePermissionValues(const InterfaceName, Permission: String; Values: TStrings);

  procedure GetInterfacePermissionValuesLocal(List: TSgtsCoreObjs);
  var
    i: Integer;
    Iface: TSgtsIface;
    Perm: TSgtsIfacePermission;
  begin
    Iface:=List.FindInterface(InterfaceName);
    if Assigned(Iface) then begin
      Perm:=Iface.Permissions.Find(Permission);
      if Assigned(Perm) then begin
        for i:=0 to Perm.Values.Count-1 do begin
          Values.Add(Perm.Values.Strings[i]);
        end;
      end;
    end;
  end;

begin
  Values.BeginUpdate;
  try
    GetInterfacePermissionValuesLocal(FInternalObjs);
    GetInterfacePermissionValuesLocal(FExternalObjs);
  finally
    Values.EndUpdate;
  end;
end;

procedure TSgtsCore.GetReportModules(Names: TStrings);
var
  i: Integer;
  Module: TSgtsReportModule;
begin
  Names.BeginUpdate;
  try
    for i:=0 to FReportModules.Count-1 do begin
      Module:=FReportModules.Items[i];
      if Trim(Module.Name)<>'' then
        Names.AddObject(Module.Name,Module);
    end;
  finally
    Names.EndUpdate;
  end;
end;

function TSgtsCore.InterfaceExists(const InterfaceName: String): Boolean;

  function InterfaceExistsLocal(List: TSgtsCoreObjs): Boolean;
  var
    Iface: TSgtsIface;
  begin
    Iface:=List.FindInterface(InterfaceName);
    Result:=Assigned(Iface);
  end;

begin
  Result:=InterfaceExistsLocal(FInternalObjs);
  if not Result then
    Result:=InterfaceExistsLocal(FExternalObjs);
end;

procedure TSgtsCore.CheckPermissions;
var
  Database: ISgtsDatabase;
begin
  if Assigned(FDatabaseModules.Current) then begin
    Database:=FDatabaseModules.Current.Database;
    if Assigned(Database) then begin
      Database.RefreshPermissions;

      FInternalObjs.CheckPermissions;
      FExternalObjs.CheckPermissions;

      FInternalObjs.UpdateContents;
      FExternalObjs.UpdateContents;
    end;
  end;
end;

procedure TSgtsCore.RefreshReports;
var
  Database: ISgtsDatabase;
begin
  if Assigned(FDatabaseModules.Current) then begin
    Database:=FDatabaseModules.Current.Database;
    if Assigned(Database) then begin
      FInternalObjs.WriteParams;

      FInternalObjs.ClearReports;
      FExternalObjs.ClearReports;

      InitBaseReportIfaces;
      InitFileReportIfaces;
      
      Database.RefreshPermissions;

      FInternalObjs.DatabaseLink;
      FExternalObjs.DatabaseLink;

      FInternalObjs.UpdateContents;
      FExternalObjs.UpdateContents;
    end;
  end;      
end;

procedure TSgtsCore.RefreshGraphs;
var
  Database: ISgtsDatabase;
begin
  if Assigned(FDatabaseModules.Current) then begin
    Database:=FDatabaseModules.Current.Database;
    if Assigned(Database) then begin
      FInternalObjs.WriteParams;
      FInternalObjs.ClearGraphs;
      InitBaseGraphIfaces;
      Database.RefreshPermissions;
      FInternalObjs.DatabaseLink;
      FInternalObjs.UpdateContents;
    end;
  end;    
end;

procedure TSgtsCore.RegisterObj(Iface: TSgtsObj);
begin
  FExternalObjs.Add(Iface);
end;

procedure TSgtsCore.UnRegisterObj(Obj: TSgtsObj);
begin
  FExternalObjs.Remove(Obj);
end;

procedure TSgtsCore.ApplicationEventsException(Sender: TObject; E: Exception);
begin
  LogWrite(Format(SCoreException,[E.Message]),ltError);
  ShowError(E.Message);
end;

procedure TSgtsCore.RegisterFileIfaces;
var
  Values: TStringList;
  i: Integer;
  AIface: TSgtsFileIface;
  S: String;
begin
  Values:=TStringList.Create;
  try
    FConfig.ReadSectionValues(SConfigSectionMenu,Values);
    for i:=0 to Values.Count-1 do begin
      S:=Values.Names[i];
      if Trim(S)<>'' then begin
        AIface:=TSgtsFileIface.Create(Self);
        AIface.MenuPath:=S;
        AIface.FileName:=Values.Values[S];
        AIface.MenuIndex:=i+1001;
        FInternalObjs.Add(AIface);
        AIface.Init;
      end;
    end;
  finally
    Values.Free;
  end;
end;


end.