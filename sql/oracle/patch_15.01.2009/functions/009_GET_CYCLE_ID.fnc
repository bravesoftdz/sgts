/* �������� ������ ��������� �������������� ��� ������� ������ */

CREATE FUNCTION GET_CYCLE_ID RETURN INTEGER IS
  ID INTEGER;
BEGIN
  SELECT SEQ_CYCLES.NEXTVAL INTO ID FROM DUAL;
  RETURN ID;
END;

--

/* �������� ��������� */

COMMIT