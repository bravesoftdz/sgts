/* �������� ��������� ���������� ������� ���������� ������ ������ ����������������� */

CREATE OR REPLACE PROCEDURE R_GMO_JOURNAL_OBSERVATIONS
AS 
BEGIN 
  DBMS_REFRESH.REFRESH('S_GMO_JOURNAL_OBSERVATIONS_OLD'); 
END;

--

/* �������� ��������� */

COMMIT
