/* �������� ��������� ���������� ����� ���������� */

CREATE OR REPLACE PROCEDURE I_DEVICE_POINT
( 
  DEVICE_ID IN INTEGER, 
  POINT_ID IN INTEGER, 
  PRIORITY IN INTEGER 
) 
AS 
BEGIN 
  INSERT INTO DEVICE_POINTS (DEVICE_ID,POINT_ID,PRIORITY) 
       VALUES (DEVICE_ID,POINT_ID,PRIORITY); 
  COMMIT; 
END;

--

/* �������� ��������� */

COMMIT
