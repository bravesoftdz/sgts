/* �������� ��������� ���������� ������� ���������� 6 ������ ������ ���������� */

CREATE OR REPLACE PROCEDURE R_FLT_JOURNAL_OBSERVATIONS_6
AS 
BEGIN 
  DBMS_REFRESH.REFRESH('S_FLT_JOURNAL_OBSERVATIONS_O6'); 
END;

--

/* �������� ��������� */

COMMIT
