/* �������� ������ ��������� �������������� ��� ������� �������� */

CREATE OR REPLACE FUNCTION GET_DRAWING_ID RETURN INTEGER IS
  ID INTEGER;
BEGIN
  SELECT SEQ_DRAWINGS.NEXTVAL INTO ID FROM DUAL;
  RETURN ID;
END;

--

/* �������� ��������� */

COMMIT