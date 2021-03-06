unit SgtsAccessConsts;

interface

resourcestring
  SInvalidUserNameOrPassword='�������� ������������ ��� ������.';

  SParamConnectionString='ConnectionString';

  SFieldAccountId='ACCOUNT_ID';
  SFieldPassword='PASS';
  SFieldDbUser='DB_USER';
  SFieldDbPass='DB_PASS';
  SFieldName='NAME';
  SFieldRoleId='ROLE_ID';
  SFieldMaxId='MAX_ID';
  SFieldPersonnelId='PERSONNEL_ID';
  SFieldPermissionId='PERMISSION_ID';
  SFieldDivisionId='DIVISION_ID';
  SFieldObjectId='OBJECT_ID';
  SFieldUnionType='UNION_TYPE';
  SFieldTreeId='TREE_ID';
  SFieldParentId='PARENT_ID';
  SFieldUnionId='UNION_ID';
  SFieldUnionParentId='UNION_PARENT_ID';

  SProviderAliasSelectAccounts='S_ACCOUNTS';
  SProviderAliasSelectRoles='S_ROLES';
  SProviderAliasSelectPersonnel='S_PERSONNELS';
  SProviderAliasSelectPermission='S_PERMISSIONS';
  SProviderAliasSelectRolesAndAccounts='ACCOUNTS';
  SProviderAliasSelectAccountsRoles='S_ACCOUNTS_ROLES';
  SProviderAliasSelectDivisions='S_DIVISIONS';
  SProviderAliasSelectObjects='S_OBJECTS';
  SProviderAliasSelectPersonnelManagement='S_PERSONNEL_MANAGEMENT';

  SProviderAliasInsertAccount='ACCOUNTS';
  SProviderAliasInsertRole='ACCOUNTS';
  SProviderAliasInsertPersonnel='PERSONNELS';
  SProviderAliasInsertPermission='PERMISSIONS';
  SProviderAliasInsertAccountRole='ACCOUNTS_ROLES';
  SProviderAliasInsertDivision='DIVISIONS';
  SProviderAliasInsertObject='OBJECTS';
  SProviderAliasInsertPersonnelManagement='';

  SProviderKeyQueryInsertAccount='(SELECT * FROM ACCOUNTS)';
  SProviderKeyQueryInsertRole='(SELECT * FROM ACCOUNTS)';
  SProviderKeyQueryInsertPersonnel='S_PERSONNELS';
  SProviderKeyQueryInsertPermission='S_PERMISSIONS';
  SProviderKeyQueryInsertDivision='S_DIVISIONS';
  SProviderKeyQueryInsertObject='S_OBJECTS';
  SProviderKeyQueryInsertPersonnelManagement='(SELECT COUNT(*) AS TREE_ID FROM S_PERSONNEL_MANAGEMENT)';

  SSqlGetRecordsCount='SELECT COUNT(*) FROM %s%s %s';
  SSqlGetRecords='SELECT %s FROM %s%s %s %s';
  SSqlGetNewId='SELECT MAX(%s)+1 AS MAX_ID FROM %s';
  SSqlExecuteInsert='INSERT INTO %s %s VALUES %s';
  SSqlExecuteUpdate='UPDATE %s SET %s WHERE %s';
  SSqlExecuteDelete='DELETE FROM %s WHERE %s';

  SSqlGetUserParams='SELECT ACCOUNT_ID, PASS, DB_USER, DB_PASS FROM ACCOUNTS WHERE NAME=%s AND IS_ROLE=0';
  SSqlGetRoles='SELECT A.NAME, AR.ROLE_ID '+
               'FROM ACCOUNTS_ROLES AS AR INNER JOIN ACCOUNTS AS A ON AR.ROLE_ID = A.ACCOUNT_ID '+
               'WHERE (((AR.ACCOUNT_ID)=%s))';
  SSqlGetPermission='SELECT INTERFACE, PERMISSION, PERMISSION_VALUE FROM PERMISSIONS '+
                    'WHERE ((ACCOUNT_ID=%s) OR (ACCOUNT_ID IN (%s))) AND '+
                    'INTERFACE=%s AND PERMISSION=%s AND PERMISSION_VALUE=%s';

implementation

end.
