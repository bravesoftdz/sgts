/* �������� ��������� ��������� ������� ������� */

CREATE OR REPLACE PROCEDURE U_OBJECT_DRAWING
( 
  OBJECT_ID IN INTEGER, 
  DRAWING_ID IN INTEGER, 
  PRIORITY IN INTEGER, 
  OLD_OBJECT_ID IN INTEGER, 
  OLD_DRAWING_ID IN INTEGER 
) 
AS 
BEGIN 
  UPDATE OBJECT_DRAWINGS  
     SET OBJECT_ID=U_OBJECT_DRAWING.OBJECT_ID, 
         DRAWING_ID=U_OBJECT_DRAWING.DRAWING_ID, 
         PRIORITY=U_OBJECT_DRAWING.PRIORITY 
   WHERE OBJECT_ID=OLD_OBJECT_ID  
     AND DRAWING_ID=OLD_DRAWING_ID; 
  COMMIT;         
END;

--

/* �������� ��������� */

COMMIT

