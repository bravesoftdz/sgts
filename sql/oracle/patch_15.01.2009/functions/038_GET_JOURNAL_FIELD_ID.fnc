/* �������� ������ ��������� �������������� ������� �������� ������� */

CREATE OR REPLACE FUNCTION GET_JOURNAL_FIELD_ID RETURN INTEGER IS
  ID INTEGER;
BEGIN
  SELECT SEQ_JOURNAL_FIELDS.NEXTVAL INTO ID FROM DUAL;
  RETURN ID;
END;

--

/* �������� ��������� */

COMMIT