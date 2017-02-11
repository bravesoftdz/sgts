/* �������� ��������� ��������� ���� � ������ �������� */

CREATE OR REPLACE PROCEDURE U_OBJECT_TREE
( 
  OBJECT_TREE_ID IN INTEGER, 
  OBJECT_ID IN INTEGER, 
  PRIORITY IN INTEGER, 
  PARENT_ID IN INTEGER, 
  OLD_OBJECT_TREE_ID IN INTEGER 
) 
AS 
BEGIN 
  UPDATE OBJECT_TREES  
     SET OBJECT_TREE_ID=U_OBJECT_TREE.OBJECT_TREE_ID, 
         OBJECT_ID=U_OBJECT_TREE.OBJECT_ID, 
   PRIORITY=U_OBJECT_TREE.PRIORITY,  
         PARENT_ID=U_OBJECT_TREE.PARENT_ID  
   WHERE OBJECT_TREE_ID=OLD_OBJECT_TREE_ID; 
  COMMIT;         
END;

--

/* �������� ��������� */

COMMIT

