/* �������� ��������� ���������� �������� ������� ������ ������ �������������� */

CREATE OR REPLACE PROCEDURE R_HDN_JOURNAL_FIELDS
AS 
BEGIN 
  DBMS_REFRESH.REFRESH('S_HDN_JOURNAL_FIELDS_O'); 
END;

--

/* �������� ��������� */

COMMIT
