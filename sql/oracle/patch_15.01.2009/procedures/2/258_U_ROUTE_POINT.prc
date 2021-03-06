/* �������� ��������� ��������� ����� � �������� */

CREATE OR REPLACE PROCEDURE U_ROUTE_POINT
( 
  ROUTE_ID IN INTEGER, 
  POINT_ID IN INTEGER, 
  PRIORITY IN INTEGER, 
  OLD_ROUTE_ID IN INTEGER, 
  OLD_POINT_ID IN INTEGER 
) 
AS 
BEGIN 
  UPDATE ROUTE_POINTS  
     SET ROUTE_ID=U_ROUTE_POINT.ROUTE_ID, 
         POINT_ID=U_ROUTE_POINT.POINT_ID, 
         PRIORITY=U_ROUTE_POINT.PRIORITY 
   WHERE ROUTE_ID=OLD_ROUTE_ID  
     AND POINT_ID=OLD_POINT_ID; 
  COMMIT;         
END;

--

/* �������� ��������� */

COMMIT

