/* �������� ��������� ���������� ������� ���������� 5 ������ ������ ����������-���������������� ��������� */

CREATE OR REPLACE PROCEDURE R_NDS_JOURNAL_OBSERVATIONS_O5
AS 
BEGIN 
  DBMS_REFRESH.REFRESH('S_NDS_JOURNAL_OBSERVATIONS_O5'); 
END;

--

/* �������� ��������� */

COMMIT
