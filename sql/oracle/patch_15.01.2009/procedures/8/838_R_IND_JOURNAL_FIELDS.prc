/* �������� ��������� ���������� �������� ������� ������ ������ ����������� ������� */

CREATE OR REPLACE PROCEDURE R_IND_JOURNAL_FIELDS
AS
BEGIN
  DBMS_REFRESH.REFRESH('S_IND_JOURNAL_FIELDS_O');
END;

--

/* �������� ��������� */

COMMIT
