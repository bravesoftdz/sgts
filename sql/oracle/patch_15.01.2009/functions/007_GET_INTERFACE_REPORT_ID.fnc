/* �������� ������ ��������� �������������� ��� ������� ������� ����������� */

CREATE OR REPLACE FUNCTION GET_INTERFACE_REPORT_ID RETURN INTEGER IS
  ID INTEGER;
BEGIN
  SELECT SEQ_INTERFACE_REPORTS.NEXTVAL INTO ID FROM DUAL;
  RETURN ID;
END;

--

/* �������� ��������� */

COMMIT