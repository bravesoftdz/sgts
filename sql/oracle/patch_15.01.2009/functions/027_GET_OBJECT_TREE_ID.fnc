/* �������� ������ ��������� �������������� ��� ������� ������ �������� */

CREATE OR REPLACE FUNCTION GET_OBJECT_TREE_ID RETURN INTEGER IS 
  ID INTEGER; 
BEGIN 
  SELECT SEQ_OBJECT_TREES.NEXTVAL INTO ID FROM DUAL; 
  RETURN ID; 
END;

--

/* �������� ��������� */

COMMIT

