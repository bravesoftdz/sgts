/* �������� ��������� ���������� ����� �������� */

CREATE OR REPLACE PROCEDURE I_ROUTE_POINT
( 
  ROUTE_ID IN INTEGER, 
  POINT_ID IN INTEGER, 
  PRIORITY IN INTEGER 
) 
AS 
BEGIN 
  INSERT INTO ROUTE_POINTS (ROUTE_ID,POINT_ID,PRIORITY) 
       VALUES (ROUTE_ID,POINT_ID,PRIORITY); 
  COMMIT; 
END;

--

/* �������� ��������� */

COMMIT
