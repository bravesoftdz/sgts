/* �������� ��������� �������� �������� � ������� */

CREATE OR REPLACE PROCEDURE D_PERSONNEL_ROUTE
( 
  OLD_PERSONNEL_ID IN INTEGER, 
  OLD_ROUTE_ID IN INTEGER 
) 
AS 
BEGIN 
  DELETE FROM PERSONNEL_ROUTES 
        WHERE PERSONNEL_ID=OLD_PERSONNEL_ID 
          AND ROUTE_ID=OLD_ROUTE_ID; 
  COMMIT;         
END;

--

/* �������� ��������� */

COMMIT

