/* �������� ������ ��������� �������������� ��� ����� ������������� ����� */

CREATE OR REPLACE FUNCTION GET_POINT_MANAGEMENT_ID RETURN INTEGER IS 
  ID INTEGER; 
BEGIN 
  SELECT SEQ_POINT_MANAGEMENT.NEXTVAL INTO ID FROM DUAL; 
  RETURN ID; 
END;

--

/* �������� ��������� */

COMMIT

