/* �������� ��������� ���������� �������� ���� ��������� */

CREATE OR REPLACE PROCEDURE I_MEASURE_TYPE_ROUTE
( 
  MEASURE_TYPE_ID IN INTEGER, 
  ROUTE_ID IN INTEGER, 
  PRIORITY IN INTEGER 
) 
AS 
BEGIN 
  INSERT INTO MEASURE_TYPE_ROUTES (MEASURE_TYPE_ID,ROUTE_ID,PRIORITY) 
       VALUES (MEASURE_TYPE_ID,ROUTE_ID,PRIORITY); 
  COMMIT; 
END;

--

/* �������� ��������� */

COMMIT
