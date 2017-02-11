unit SgtsProviderConsts;

interface

resourcestring
  SProviderSelectAccounts='S_ACCOUNTS';
  SProviderInsertAccount='I_ACCOUNT';
  SProviderUpdateAccount='U_ACCOUNT';
  SProviderDeleteAccount='D_ACCOUNT';

  SProviderSelectRoles='S_ROLES';
  SProviderInsertRole='I_ROLE';
  SProviderUpdateRole='U_ROLE';
  SProviderDeleteRole='D_ROLE';

  SProviderSelectPersonnels='S_PERSONNELS';
  SProviderSelectPersonnelOnlyPerformers='S_PERSONNEL_ONLY_PERFORMERS';
  SProviderInsertPersonnel='I_PERSONNEL';
  SProviderUpdatePersonnel='U_PERSONNEL';
  SProviderDeletePersonnel='D_PERSONNEL';

  SProviderSelectPermissions='S_PERMISSIONS';
  SProviderInsertPermission='I_PERMISSION';
  SProviderUpdatePermission='U_PERMISSION';
  SProviderDeletePermission='D_PERMISSION';

  SProviderSelectRolesAndAccounts='S_ROLES_AND_ACCOUNTS';

  SProviderSelectAccountsRoles='S_ACCOUNTS_ROLES';
  SProviderInsertAccountRole='I_ACCOUNT_ROLE';
  SProviderUpdateAccountRole='U_ACCOUNT_ROLE';
  SProviderDeleteAccountRole='D_ACCOUNT_ROLE';
  SProviderClearAccountRole='C_ACCOUNT_ROLE';

  SProviderSelectDivisions='S_DIVISIONS';
  SProviderInsertDivision='I_DIVISION';
  SProviderUpdateDivision='U_DIVISION';
  SProviderDeleteDivision='D_DIVISION';
  SProviderAuditDivisionParentId='A_DIVISION_PARENT_ID';

  SProviderSelectObjects='S_OBJECTS';
  SProviderInsertObject='I_OBJECT';
  SProviderUpdateObject='U_OBJECT';
  SProviderDeleteObject='D_OBJECT';

  SProviderSelectPersonnelManagement='S_PERSONNEL_MANAGEMENT';
  SProviderInsertPersonnelManagement='I_PERSONNEL_MANAGEMENT';

  SProviderSelectPointManagement='S_POINT_MANAGEMENT';
  SProviderInsertPointManagement='I_POINT_MANAGEMENT';

  SProviderSelectPointTypes='S_POINT_TYPES';
  SProviderInsertPointType='I_POINT_TYPE';
  SProviderUpdatePointType='U_POINT_TYPE';
  SProviderDeletePointType='D_POINT_TYPE';

  SProviderSelectPoints='S_POINTS';
  SProviderInsertPoint='I_POINT';
  SProviderUpdatePoint='U_POINT';
  SProviderDeletePoint='D_POINT';

  SProviderSelectRoutes='S_ROUTES';
  SProviderInsertRoute='I_ROUTE';
  SProviderUpdateRoute='U_ROUTE';
  SProviderDeleteRoute='D_ROUTE';

  SProviderSelectMeasureTypes='S_MEASURE_TYPES';
  SProviderInsertMeasureType='I_MEASURE_TYPE';
  SProviderUpdateMeasureType='U_MEASURE_TYPE';
  SProviderDeleteMeasureType='D_MEASURE_TYPE';
  SProviderAuditMeasureTypeParentId='A_MEASURE_TYPE_PARENT_ID';

  SProviderSelectInstrumentTypes='S_INSTRUMENT_TYPES';
  SProviderInsertInstrumentType='I_INSTRUMENT_TYPE';
  SProviderUpdateInstrumentType='U_INSTRUMENT_TYPE';
  SProviderDeleteInstrumentType='D_INSTRUMENT_TYPE';

  SProviderSelectInstruments='S_INSTRUMENTS';
  SProviderInsertInstrument='I_INSTRUMENT';
  SProviderUpdateInstrument='U_INSTRUMENT';
  SProviderDeleteInstrument='D_INSTRUMENT';

  SProviderSelectMeasureUnits='S_MEASURE_UNITS';
  SProviderInsertMeasureUnit='I_MEASURE_UNIT';
  SProviderUpdateMeasureUnit='U_MEASURE_UNIT';
  SProviderDeleteMeasureUnit='D_MEASURE_UNIT';

  SProviderSelectInstrumentUnits='S_INSTRUMENT_UNITS';
  SProviderInsertInstrumentUnit='I_INSTRUMENT_UNIT';
  SProviderUpdateInstrumentUnit='U_INSTRUMENT_UNIT';
  SProviderDeleteInstrumentUnit='D_INSTRUMENT_UNIT';

  SProviderSelectRoutePoints='S_ROUTE_POINTS';
  SProviderInsertRoutePoint='I_ROUTE_POINT';
  SProviderUpdateRoutePoint='U_ROUTE_POINT';
  SProviderDeleteRoutePoint='D_ROUTE_POINT';

  SProviderSelectMeasureTypeRoutes='S_MEASURE_TYPE_ROUTES';
  SProviderInsertMeasureTypeRoute='I_MEASURE_TYPE_ROUTE';
  SProviderUpdateMeasureTypeRoute='U_MEASURE_TYPE_ROUTE';
  SProviderDeleteMeasureTypeRoute='D_MEASURE_TYPE_ROUTE';

  SProviderSelectPersonnelRoutes='S_PERSONNEL_ROUTES';
  SProviderInsertPersonnelRoute='I_PERSONNEL_ROUTE';
  SProviderUpdatePersonnelRoute='U_PERSONNEL_ROUTE';
  SProviderDeletePersonnelRoute='D_PERSONNEL_ROUTE';

  SProviderSelectCycles='S_CYCLES';
  SProviderInsertCycle='I_CYCLE';
  SProviderUpdateCycle='U_CYCLE';
  SProviderDeleteCycle='D_CYCLE';

  SProviderSelectPlans='S_PLANS';
  SProviderInsertPlan='I_PLAN';
  SProviderUpdatePlan='U_PLAN';
  SProviderDeletePlan='D_PLAN';

  SProviderSelectGraphs='S_GRAPHS';
  SProviderInsertGraph='I_GRAPH';
  SProviderUpdateGraph='U_GRAPH';
  SProviderDeleteGraph='D_GRAPH';

  SProviderSelectObjectTrees='S_OBJECT_TREES';
  SProviderInsertObjectTree='I_OBJECT_TREE';
  SProviderUpdateObjectTree='U_OBJECT_TREE';
  SProviderDeleteObjectTree='D_OBJECT_TREE';
  SProviderGetObjectPaths='G_OBJECT_PATHS';

  SProviderSelectAlgorithms='S_ALGORITHMS';
  SProviderInsertAlgorithm='I_ALGORITHM';
  SProviderUpdateAlgorithm='U_ALGORITHM';
  SProviderDeleteAlgorithm='D_ALGORITHM';

  SProviderSelectMeasureTypeAlgorithms='S_MEASURE_TYPE_ALGORITHMS';
  SProviderInsertMeasureTypeAlgorithm='I_MEASURE_TYPE_ALGORITHM';
  SProviderUpdateMeasureTypeAlgorithm='U_MEASURE_TYPE_ALGORITHM';
  SProviderDeleteMeasureTypeAlgorithm='D_MEASURE_TYPE_ALGORITHM';

  SProviderSelectLevels='S_LEVELS';
  SProviderInsertLevel='I_LEVEL';
  SProviderUpdateLevel='U_LEVEL';
  SProviderDeleteLevel='D_LEVEL';

  SProviderSelectParams='S_PARAMS';
  SProviderInsertParam='I_PARAM';
  SProviderUpdateParam='U_PARAM';
  SProviderDeleteParam='D_PARAM';

  SProviderSelectMeasureTypeParams='S_MEASURE_TYPE_PARAMS';
  SProviderInsertMeasureTypeParam='I_MEASURE_TYPE_PARAM';
  SProviderUpdateMeasureTypeParam='U_MEASURE_TYPE_PARAM';
  SProviderDeleteMeasureTypeParam='D_MEASURE_TYPE_PARAM';

  SProviderSelectParamLevels='S_PARAM_LEVELS';
  SProviderInsertParamLevel='I_PARAM_LEVEL';
  SProviderUpdateParamLevel='U_PARAM_LEVEL';
  SProviderDeleteParamLevel='D_PARAM_LEVEL';

  SProviderSelectJournalFields='S_JOURNAL_FIELDS';
  SProviderInsertJournalField='I_JOURNAL_FIELD';
  SProviderUpdateJournalField='U_JOURNAL_FIELD';
  SProviderDeleteJournalField='D_JOURNAL_FIELD';

  SProviderSelectJournalObservations='S_JOURNAL_OBSERVATIONS';
  SProviderInsertJournalObservation='I_JOURNAL_OBSERVATION';
  SProviderUpdateJournalObservation='U_JOURNAL_OBSERVATION';
  SProviderDeleteJournalObservation='D_JOURNAL_OBSERVATION';

  SProviderSelectMeasureTypePersonnels='S_MEASURE_TYPE_PERSONNELS';

  SProviderSelectFileReports='S_FILE_REPORTS';
  SProviderInsertFileReport='I_FILE_REPORT';
  SProviderUpdateFileReport='U_FILE_REPORT';
  SProviderDeleteFileReport='D_FILE_REPORT';

  SProviderSelectBaseReports='S_BASE_REPORTS';
  SProviderInsertBaseReport='I_BASE_REPORT';
  SProviderUpdateBaseReport='U_BASE_REPORT';
  SProviderDeleteBaseReport='D_BASE_REPORT';

  SProviderSelectRouteObjects='S_ROUTE_OBJECTS';
  SProviderSelectMeasureTypePoints='S_MEASURE_TYPE_POINTS';
  SProviderSelectRouteConverters='S_ROUTE_CONVERTERS';

  SProviderSelectParamInstruments='S_PARAM_INSTRUMENTS';
  SProviderInsertParamInstrument='I_PARAM_INSTRUMENT';
  SProviderUpdateParamInstrument='U_PARAM_INSTRUMENT';
  SProviderDeleteParamInstrument='D_PARAM_INSTRUMENT';

  SProviderSelectDocuments='S_DOCUMENTS';
  SProviderInsertDocument='I_DOCUMENT';
  SProviderUpdateDocument='U_DOCUMENT';
  SProviderDeleteDocument='D_DOCUMENT';

  SProviderSelectPointDocuments='S_POINT_DOCUMENTS';
  SProviderInsertPointDocument='I_POINT_DOCUMENT';
  SProviderUpdatePointDocument='U_POINT_DOCUMENT';
  SProviderDeletePointDocument='D_POINT_DOCUMENT';

  SProviderSelectConverters='S_CONVERTERS';
  SProviderInsertConverter='I_CONVERTER';
  SProviderUpdateConverter='U_CONVERTER';
  SProviderDeleteConverter='D_CONVERTER';

  SProviderSelectComponents='S_COMPONENTS';
  SProviderInsertComponent='I_COMPONENT';
  SProviderUpdateComponent='U_COMPONENT';
  SProviderDeleteComponent='D_COMPONENT';

  SProviderSelectDevices='S_DEVICES';
  SProviderInsertDevice='I_DEVICE';
  SProviderUpdateDevice='U_DEVICE';
  SProviderDeleteDevice='D_DEVICE';

  SProviderSelectDevicePoints='S_DEVICE_POINTS';
  SProviderInsertDevicePoint='I_DEVICE_POINT';
  SProviderUpdateDevicePoint='U_DEVICE_POINT';
  SProviderDeleteDevicePoint='D_DEVICE_POINT';

  SProviderSelectDrawings='S_DRAWINGS';
  SProviderInsertDrawing='I_DRAWING';
  SProviderUpdateDrawing='U_DRAWING';
  SProviderDeleteDrawing='D_DRAWING';

  SProviderSelectObjectDrawings='S_OBJECT_DRAWINGS';
  SProviderInsertObjectDrawing='I_OBJECT_DRAWING';
  SProviderUpdateObjectDrawing='U_OBJECT_DRAWING';
  SProviderDeleteObjectDrawing='D_OBJECT_DRAWING';

  SProviderSelectObjectDocuments='S_OBJECT_DOCUMENTS';
  SProviderInsertObjectDocument='I_OBJECT_DOCUMENT';
  SProviderUpdateObjectDocument='U_OBJECT_DOCUMENT';
  SProviderDeleteObjectDocument='D_OBJECT_DOCUMENT';

  SProviderSelectConverterPassports='S_CONVERTER_PASSPORTS';
  SProviderInsertConverterPassport='I_CONVERTER_PASSPORT';
  SProviderUpdateConverterPassport='U_CONVERTER_PASSPORT';
  SProviderDeleteConverterPassport='D_CONVERTER_PASSPORT';

  SProviderSelectInstrumentPassports='S_INSTRUMENT_PASSPORTS';
  SProviderInsertInstrumentPassport='I_INSTRUMENT_PASSPORT';
  SProviderUpdateInstrumentPassport='U_INSTRUMENT_PASSPORT';
  SProviderDeleteInstrumentPassport='D_INSTRUMENT_PASSPORT';

  SProviderSelectPointPassports='S_POINT_PASSPORTS';
  SProviderInsertPointPassport='I_POINT_PASSPORT';
  SProviderUpdatePointPassport='U_POINT_PASSPORT';
  SProviderDeletePointPassport='D_POINT_PASSPORT';

  SProviderSelectObjectPassports='S_OBJECT_PASSPORTS';
  SProviderInsertObjectPassport='I_OBJECT_PASSPORT';
  SProviderUpdateObjectPassport='U_OBJECT_PASSPORT';
  SProviderDeleteObjectPassport='D_OBJECT_PASSPORT';

  SProviderSelectMeasureTypeColumns='S_MEASURE_TYPE_COLUMNS';
  SProviderSelectInstrumentComponents='S_INSTRUMENT_COMPONENTS';
  SProviderSelectJournalActions='S_JOURNAL_ACTIONS';
  SProviderSelectMeasureTypeUnits='S_MEASURE_TYPE_UNITS';
  SProviderSelectMeasureTypeConverters='S_MEASURE_TYPE_CONVERTERS';

  SProviderSelectInterfaceReports='S_INTERFACE_REPORT';
  SProviderInsertInterfaceReport='I_INTERFACE_REPORT';
  SProviderUpdateInterfaceReport='U_INTERFACE_REPORT';
  SProviderDeleteInterfaceReport='D_INTERFACE_REPORT';

  SProviderSelectCheckings='S_CHECKINGS';
  SProviderInsertChecking='I_CHECKING';
  SProviderUpdateChecking='U_CHECKING';
  SProviderDeleteChecking='D_CHECKING';

  SProviderSelectCuts='S_CUTS';
  SProviderInsertCut='I_CUT';
  SProviderUpdateCut='U_CUT';
  SProviderDeleteCut='D_CUT';

  SProviderSelectPointInstruments='S_POINT_INSTRUMENTS';
  SProviderInsertPointInstrument='I_POINT_INSTRUMENT';
  SProviderUpdatePointInstrument='U_POINT_INSTRUMENT';
  SProviderDeletePointInstrument='D_POINT_INSTRUMENT';

  SProviderSelectGmoJournalObservations='S_GMO_JOURNAL_OBSERVATIONS';
  SProviderSelectPzmJournalObservationsGmo='S_PZM_JOURNAL_OBSERVATIONS_GMO';
  SProviderSelectFltJournalObservationsGmo='S_FLT_JOURNAL_OBSERVATIONS_GMO';
  SProviderSelectHmzJournalObservationsGmo='S_HMZ_JOURNAL_OBSERVATIONS_GMO';
  SProviderSelectHmzIntensity='S_HMZ_INTENSITY';
  SProviderSelectTvlJournalObservationsGmo='S_TVL_JOURNAL_OBSERVATIONS_GMO';

  SProviderSelectGroups='S_GROUPS';
  SProviderInsertGroup='I_GROUP';
  SProviderUpdateGroup='U_GROUP';
  SProviderDeleteGroup='D_GROUP';

  SProviderSelectGroupObjects='S_GROUP_OBJECTS';
  SProviderInsertGroupObject='I_GROUP_OBJECT';
  SProviderUpdateGroupObject='U_GROUP_OBJECT';
  SProviderDeleteGroupObject='D_GROUP_OBJECT';

  SProviderReorderPriorityInRoute='REORDER_PRIORITY_IN_ROUTE';

  SProviderSelectDefectViews='S_DEFECT_VIEWS';
  SProviderInsertDefectView='I_DEFECT_VIEW';
  SProviderUpdateDefectView='U_DEFECT_VIEW';
  SProviderDeleteDefectView='D_DEFECT_VIEW';

  SProviderSelectJournalCheckups='S_JOURNAL_CHECKUPS';
  SProviderInsertJournalCheckup='I_JOURNAL_CHECKUP';
  SProviderUpdateJournalCheckup='U_JOURNAL_CHECKUP';
  SProviderDeleteJournalCheckup='D_JOURNAL_CHECKUP';

  SProviderSelectDocCheckups='S_DOC_CHECKUPS';
  SProviderInsertDocCheckup='I_DOC_CHECKUP';
  SProviderUpdateDocCheckup='U_DOC_CHECKUP';
  SProviderDeleteDocCheckup='D_DOC_CHECKUP';
  SProviderDeleteDocCheckupJournal='D_DOC_CHECKUP_JOURNAL';

  SProviderSelectCriterias='S_CRITERIAS';
  SProviderInsertCriteria='I_CRITERIA';
  SProviderUpdateCriteria='U_CRITERIA';
  SProviderDeleteCriteria='D_CRITERIA';

  SProviderConfirmAll='CONFIRM_ALL';

implementation

end.
