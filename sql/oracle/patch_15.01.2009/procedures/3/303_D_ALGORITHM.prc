/* �������� ��������� �������� ��������� */

CREATE OR REPLACE PROCEDURE D_ALGORITHM
( 
  OLD_ALGORITHM_ID IN INTEGER 
) 
AS 
BEGIN 
  DELETE FROM ALGORITHMS 
        WHERE ALGORITHM_ID=OLD_ALGORITHM_ID; 
  COMMIT;         
END;

--

/* �������� ��������� */

COMMIT

