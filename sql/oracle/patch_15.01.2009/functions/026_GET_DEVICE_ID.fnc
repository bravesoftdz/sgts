/* �������� ������ ��������� �������������� ��� ������� ��������� */

CREATE OR REPLACE FUNCTION GET_DEVICE_ID RETURN INTEGER IS
  ID INTEGER;
BEGIN
  SELECT SEQ_DEVICES.NEXTVAL INTO ID FROM DUAL;
  RETURN ID;
END;

--

/* �������� ��������� */

COMMIT