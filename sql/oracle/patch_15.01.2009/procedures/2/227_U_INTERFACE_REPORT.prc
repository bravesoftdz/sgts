/* �������� ��������� ��������� ������ ���������� */

CREATE OR REPLACE PROCEDURE U_INTERFACE_REPORT
( 
  INTERFACE_REPORT_ID IN INTEGER, 
  BASE_REPORT_ID IN INTEGER, 
  INTERFACE IN VARCHAR2, 
  PRIORITY IN INTEGER, 
  OLD_INTERFACE_REPORT_ID IN INTEGER 
) 
AS 
BEGIN 
  UPDATE INTERFACE_REPORTS  
     SET INTERFACE_REPORT_ID=U_INTERFACE_REPORT.INTERFACE_REPORT_ID, 
         BASE_REPORT_ID=U_INTERFACE_REPORT.BASE_REPORT_ID, 
         INTERFACE=U_INTERFACE_REPORT.INTERFACE, 
         PRIORITY=U_INTERFACE_REPORT.PRIORITY 
   WHERE INTERFACE_REPORT_ID=OLD_INTERFACE_REPORT_ID; 
  COMMIT;         
END;

--

/* �������� ��������� */

COMMIT

