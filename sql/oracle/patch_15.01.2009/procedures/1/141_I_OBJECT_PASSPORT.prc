/* �������� ��������� ���������� �������� ������� */

CREATE OR REPLACE PROCEDURE I_OBJECT_PASSPORT
( 
  OBJECT_PASSPORT_ID IN INTEGER, 
  OBJECT_ID IN INTEGER, 
  DATE_PASSPORT IN DATE, 
  PARAM_NAME IN VARCHAR2, 
  VALUE IN FLOAT,   
  DESCRIPTION IN VARCHAR2 
) 
AS 
BEGIN 
  INSERT INTO OBJECT_PASSPORTS (OBJECT_PASSPORT_ID,OBJECT_ID,DATE_PASSPORT, 
                                PARAM_NAME,VALUE,DESCRIPTION) 
       VALUES (OBJECT_PASSPORT_ID,OBJECT_ID,DATE_PASSPORT, 
               PARAM_NAME,VALUE,DESCRIPTION); 
  COMMIT; 
END;

--

/* �������� ��������� */

COMMIT
