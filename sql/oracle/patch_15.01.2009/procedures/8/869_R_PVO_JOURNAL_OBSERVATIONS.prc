/* �������� ��������� ���������� ������� ���������� ������ ������ �������-��������� ����������� */

CREATE OR REPLACE PROCEDURE R_PVO_JOURNAL_OBSERVATIONS
AS 
BEGIN 
  DBMS_REFRESH.REFRESH('S_PVO_JOURNAL_OBSERVATIONS_O'); 
END;

--

/* �������� ��������� */

COMMIT
