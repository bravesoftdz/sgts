/* �������� ��������� ���������� �������� ������� 1 ������ ������ ����������� */

CREATE OR REPLACE PROCEDURE R_PZM_JOURNAL_FIELDS_1
AS 
BEGIN 
  DBMS_REFRESH.REFRESH('S_PZM_JOURNAL_FIELDS_O1'); 
END;

--

/* �������� ��������� */

COMMIT
