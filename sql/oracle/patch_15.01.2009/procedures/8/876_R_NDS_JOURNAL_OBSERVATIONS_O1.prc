/* �������� ��������� ���������� ������� ���������� 1 ������ ������ ����������-���������������� ��������� */

CREATE OR REPLACE PROCEDURE R_NDS_JOURNAL_OBSERVATIONS_O1
AS 
BEGIN 
  DBMS_REFRESH.REFRESH('S_NDS_JOURNAL_OBSERVATIONS_O1'); 
END;

--

/* �������� ��������� */

COMMIT
