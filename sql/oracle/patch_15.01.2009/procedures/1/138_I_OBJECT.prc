/* �������� ��������� ���������� ������� */

CREATE OR REPLACE PROCEDURE I_OBJECT
( 
  OBJECT_ID IN INTEGER, 
  NAME IN VARCHAR2, 
  DESCRIPTION IN VARCHAR2, 
  SHORT_NAME IN VARCHAR2 
) 
AS 
BEGIN 
  INSERT INTO OBJECTS (OBJECT_ID,NAME,DESCRIPTION,SHORT_NAME) 
       VALUES (OBJECT_ID,NAME,DESCRIPTION,SHORT_NAME); 
  COMMIT; 
END;

--

/* �������� ��������� */

COMMIT
