/* �������� ��������� ���������� ������� ���������� 2 ������ ������ ����������-���������������� ��������� */

CREATE OR REPLACE PROCEDURE R_NDS_JOURNAL_OBSERVATIONS_O2
AS 
BEGIN 
  DBMS_REFRESH.REFRESH('S_NDS_JOURNAL_OBSERVATIONS_O2'); 
END;

--

/* �������� ��������� */

COMMIT
