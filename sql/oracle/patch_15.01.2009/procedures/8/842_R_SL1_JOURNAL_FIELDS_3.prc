/* �������� ��������� ���������� �������� ������� 3 ������ ������ ��������� ��������� */

CREATE OR REPLACE PROCEDURE R_SL1_JOURNAL_FIELDS_3
AS
BEGIN
  DBMS_REFRESH.REFRESH('S_SL1_JOURNAL_FIELDS_O3');
END;

--

/* �������� ��������� */

COMMIT
