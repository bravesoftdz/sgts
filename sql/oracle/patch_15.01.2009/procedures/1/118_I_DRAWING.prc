/* �������� ��������� ���������� ������� */

CREATE OR REPLACE PROCEDURE I_DRAWING
( 
  DRAWING_ID IN INTEGER, 
  NAME IN VARCHAR2, 
  DESCRIPTION IN VARCHAR2, 
  FILE_NAME IN VARCHAR2 
) 
AS 
BEGIN 
  INSERT INTO DRAWINGS (DRAWING_ID,NAME,DESCRIPTION,FILE_NAME) 
       VALUES (DRAWING_ID,NAME,DESCRIPTION,FILE_NAME); 
  COMMIT; 
END;

--

/* �������� ��������� */

COMMIT
