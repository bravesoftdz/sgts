/* �������� ��������� ���������� ���� ����� */

CREATE OR REPLACE PROCEDURE I_POINT_TYPE
( 
  POINT_TYPE_ID IN INTEGER, 
  NAME IN VARCHAR2, 
  DESCRIPTION IN VARCHAR2 
) 
AS 
BEGIN 
  INSERT INTO POINT_TYPES (POINT_TYPE_ID,NAME,DESCRIPTION) 
       VALUES (POINT_TYPE_ID,NAME,DESCRIPTION); 
  COMMIT; 
END;

--

/* �������� ��������� */

COMMIT