/* �������� ������ ��������� �������������� ������� ������� �������� */

CREATE OR REPLACE FUNCTION GET_JOURNAL_ACTION_ID RETURN INTEGER IS
  ID INTEGER;
BEGIN
  SELECT SEQ_JOURNAL_ACTIONS.NEXTVAL INTO ID FROM DUAL;
  RETURN ID;
END;

--

/* �������� ��������� */

COMMIT