/* �������� ������ ��������� �������������� ��� ������� */

CREATE OR REPLACE FUNCTION GET_LEVEL_ID RETURN INTEGER IS
  ID INTEGER;
BEGIN
  SELECT SEQ_LEVELS.NEXTVAL INTO ID FROM DUAL;
  RETURN ID;
END;

--

/* �������� ��������� */

COMMIT