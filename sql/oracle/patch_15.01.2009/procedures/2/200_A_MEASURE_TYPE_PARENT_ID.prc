/* �������� ��������� �������� ������������� ���� ��������� */

CREATE OR REPLACE PROCEDURE A_MEASURE_TYPE_PARENT_ID
( 
  MEASURE_TYPE_ID IN INTEGER, 
  PARENT_ID IN INTEGER 
) 
AS 
  CNT INTEGER; 
  E EXCEPTION; 
  ERROR VARCHAR2(500); 
BEGIN 
  IF (MEASURE_TYPE_ID=PARENT_ID) THEN 
    ERROR:='��� ��������� �� ����� ��������� ��� �� ����.'; 
    RAISE E; 
  END IF; 
   
  SELECT COUNT(*) INTO CNT FROM DUAL 
   WHERE PARENT_ID IN (SELECT MT1.MEASURE_TYPE_ID 
                         FROM MEASURE_TYPES MT1, MEASURE_TYPES MT2  
                        WHERE MT1.PARENT_ID=MT2.MEASURE_TYPE_ID (+)   
                   START WITH MT1.MEASURE_TYPE_ID=A_MEASURE_TYPE_PARENT_ID.MEASURE_TYPE_ID 
                   CONNECT BY MT1.PARENT_ID=PRIOR MT1.MEASURE_TYPE_ID); 
   
  IF (CNT>0) THEN 
    ERROR:='��� ��������� �� ����� ��������� �� �������� ���� ���������.'; 
    RAISE E; 
  END IF; 
   
EXCEPTION 
  WHEN E THEN  
       RAISE_APPLICATION_ERROR(-20100,ERROR); 
END;

--

/* �������� ��������� */

COMMIT

