/* �������� ������ ��������� �������������� ��� ������� ����� �������� */

CREATE OR REPLACE FUNCTION GET_DEFECT_VIEW_ID RETURN INTEGER IS
  ID INTEGER;
BEGIN
  SELECT SEQ_DEFECT_VIEWS.NEXTVAL INTO ID FROM DUAL;
  RETURN ID;
END;

--

/* �������� ��������� */

COMMIT