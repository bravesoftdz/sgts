/* �������� ��������� �������� ������� */

CREATE OR REPLACE VIEW S_FILE_REPORTS
AS 
SELECT P.FILE_REPORT_ID,P.NAME,P.DESCRIPTION,P.FILE_NAME,P.MODULE_NAME,P.PRIORITY,P.MENU
  FROM FILE_REPORTS P

--

/* �������� ��������� */

COMMIT


