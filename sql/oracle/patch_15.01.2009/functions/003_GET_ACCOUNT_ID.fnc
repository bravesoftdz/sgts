/* �������� ������ ��������� �������������� ��� ������� ������� ������ */

CREATE FUNCTION GET_ACCOUNT_ID RETURN INTEGER IS
  ID INTEGER;
BEGIN
  SELECT SEQ_ACCOUNTS.NEXTVAL INTO ID FROM DUAL;
  RETURN ID;
END;

--

/* �������� ��������� �� */

COMMIT