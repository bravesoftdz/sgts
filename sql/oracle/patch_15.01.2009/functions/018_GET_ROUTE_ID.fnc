/* �������� ������ ��������� �������������� ��� ������� ��������� */

CREATE OR REPLACE FUNCTION GET_ROUTE_ID RETURN INTEGER IS 
  ID INTEGER; 
BEGIN 
  SELECT SEQ_ROUTES.NEXTVAL INTO ID FROM DUAL; 
  RETURN ID; 
END;

--

/* �������� ��������� */

COMMIT

