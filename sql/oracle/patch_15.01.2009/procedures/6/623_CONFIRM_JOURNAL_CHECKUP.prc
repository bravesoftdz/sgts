/* �������� ��������� ����������� ������ ������� �������� */

CREATE OR REPLACE PROCEDURE CONFIRM_JOURNAL_CHECKUP
( 
  JOURNAL_CHECKUP_ID IN INTEGER 
) 
AS 
BEGIN 
  COMMIT;            
END;

--

/* �������� */

COMMIT
