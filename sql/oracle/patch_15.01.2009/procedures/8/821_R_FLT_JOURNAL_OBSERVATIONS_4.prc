/* �������� ��������� ���������� ������� ���������� 4 ������ ������ ���������� */

CREATE OR REPLACE PROCEDURE R_FLT_JOURNAL_OBSERVATIONS_4
AS 
BEGIN 
  DBMS_REFRESH.REFRESH('S_FLT_JOURNAL_OBSERVATIONS_O4'); 
END;

--

/* �������� ��������� */

COMMIT
