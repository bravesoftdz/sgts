/* �������� ������ ��������� �������������� ��� ������� ����������� ���������������� */

CREATE OR REPLACE FUNCTION GET_COMPONENT_ID RETURN INTEGER IS
  ID INTEGER;
BEGIN
  SELECT SEQ_COMPONENTS.NEXTVAL INTO ID FROM DUAL;
  RETURN ID;
END;

--

/* �������� ��������� */

COMMIT