/* �������� ��������� ���������� �������� ������� 2 ������ ������ ����������-���������������� ��������� */

CREATE OR REPLACE PROCEDURE R_NDS_JOURNAL_FIELDS_O2
AS 
BEGIN 
  DBMS_REFRESH.REFRESH('S_NDS_JOURNAL_FIELDS_O2'); 
END;

--

/* �������� ��������� */

COMMIT
