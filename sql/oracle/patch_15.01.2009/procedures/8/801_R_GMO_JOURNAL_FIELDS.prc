/* �������� ��������� ���������� �������� ������� ������ ������ ����������������� */

CREATE OR REPLACE PROCEDURE R_GMO_JOURNAL_FIELDS
AS 
BEGIN 
  DBMS_REFRESH.REFRESH('S_GMO_JOURNAL_FIELDS_OLD'); 
END;

--

/* �������� ��������� */

COMMIT
