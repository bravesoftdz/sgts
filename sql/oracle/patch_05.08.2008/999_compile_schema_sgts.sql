/* �������������� ���� ����� */

DECLARE
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  DBMS_UTILITY.COMPILE_SCHEMA('SGTS',true);
  DBMS_UTILITY.ANALYZE_SCHEMA('SGTS','COMPUTE');
END;


