/* �������� ������� ��������� �������������� ��� ������� ������ */

CREATE FUNCTION GET_CUT_ID RETURN INTEGER IS
  ID INTEGER;
BEGIN
  SELECT SEQ_CUTS.NEXTVAL INTO ID FROM DUAL;
  RETURN ID;
END;

--

/* �������� ��������� */

COMMIT