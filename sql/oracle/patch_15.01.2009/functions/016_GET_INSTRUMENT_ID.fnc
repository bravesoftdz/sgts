/* �������� ������ ��������� �������������� ��� ������� �������� */

CREATE OR REPLACE FUNCTION GET_INSTRUMENT_ID RETURN INTEGER IS
  ID INTEGER;
BEGIN
  SELECT SEQ_INSTRUMENTS.NEXTVAL INTO ID FROM DUAL;
  RETURN ID;
END;

--

/* �������� ��������� */

COMMIT