/* �������� ��������� ���������� ��������� */

CREATE OR REPLACE PROCEDURE I_ALGORITHM
( 
  ALGORITHM_ID IN INTEGER, 
  NAME IN VARCHAR2, 
  PROC_NAME IN VARCHAR2, 
  DESCRIPTION IN VARCHAR2 
) 
AS 
BEGIN 
  INSERT INTO ALGORITHMS (ALGORITHM_ID,NAME,PROC_NAME,DESCRIPTION) 
       VALUES (ALGORITHM_ID,NAME,PROC_NAME,DESCRIPTION); 
  COMMIT; 
END;

--

/* �������� ��������� */

COMMIT
