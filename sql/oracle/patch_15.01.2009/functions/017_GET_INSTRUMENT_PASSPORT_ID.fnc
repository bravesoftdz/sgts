/* �������� ������ ��������� �������������� ��� ������� ��������� �������� */

CREATE OR REPLACE FUNCTION GET_INSTRUMENT_PASSPORT_ID RETURN INTEGER IS
  ID INTEGER;
BEGIN
  SELECT SEQ_INSTRUMENT_PASSPORTS.NEXTVAL INTO ID FROM DUAL;
  RETURN ID;
END;

--

/* �������� ��������� */

COMMIT