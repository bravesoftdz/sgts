/* �������� ��������� ��������� ������� � ������ */

CREATE OR REPLACE PROCEDURE U_GROUP_OBJECT
( 
  GROUP_ID IN INTEGER, 
  OBJECT_ID IN INTEGER, 
  PRIORITY IN INTEGER, 
  OLD_GROUP_ID IN INTEGER, 
  OLD_OBJECT_ID IN INTEGER 
) 
AS 
BEGIN 
  UPDATE GROUP_OBJECTS  
     SET GROUP_ID=U_GROUP_OBJECT.GROUP_ID, 
         OBJECT_ID=U_GROUP_OBJECT.OBJECT_ID, 
         PRIORITY=U_GROUP_OBJECT.PRIORITY 
   WHERE GROUP_ID=OLD_GROUP_ID  
     AND OBJECT_ID=OLD_OBJECT_ID; 
  COMMIT;         
END;

--

/* �������� ��������� */

COMMIT

