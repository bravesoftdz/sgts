/* �������� ��������� ���������� �������� ������� 5 ������ ������ ���������� */

CREATE OR REPLACE PROCEDURE R_FLT_JOURNAL_FIELDS_5
AS 
BEGIN 
  DBMS_REFRESH.REFRESH('S_FLT_JOURNAL_FIELDS_O5'); 
END;

--

/* �������� ��������� */

COMMIT
