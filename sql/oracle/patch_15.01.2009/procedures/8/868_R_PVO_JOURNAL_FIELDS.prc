/* �������� ��������� ���������� �������� ������� ������ ������ �������-��������� ����������� */

CREATE OR REPLACE PROCEDURE R_PVO_JOURNAL_FIELDS
AS 
BEGIN 
  DBMS_REFRESH.REFRESH('S_PVO_JOURNAL_FIELDS_O'); 
END;

--

/* �������� ��������� */

COMMIT
