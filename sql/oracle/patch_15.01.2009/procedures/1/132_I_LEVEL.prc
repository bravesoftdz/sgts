/* �������� ��������� ���������� ������ */

CREATE OR REPLACE PROCEDURE I_LEVEL
( 
  LEVEL_ID IN INTEGER, 
  NAME IN VARCHAR2, 
  DESCRIPTION IN VARCHAR2 
) 
AS 
BEGIN 
  INSERT INTO LEVELS (LEVEL_ID,NAME,DESCRIPTION) 
       VALUES (LEVEL_ID,NAME,DESCRIPTION); 
  COMMIT; 
END;

--

/* �������� ��������� */

COMMIT
