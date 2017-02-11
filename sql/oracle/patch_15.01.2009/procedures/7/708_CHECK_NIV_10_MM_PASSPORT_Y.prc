/* �������� ��������� �������� CHECK_NIV_10_MM_PASSPORT_Y */

CREATE OR REPLACE PROCEDURE CHECK_NIV_10_MM_PASSPORT_Y
( 
  DATE_OBSERVATION IN DATE, 
  CYCLE_ID IN INTEGER, 
  MEASURE_TYPE_ID IN INTEGER, 
  OBJECT_ID IN INTEGER, 
  POINT_ID IN INTEGER, 
  PARAM_ID IN INTEGER, 
  VALUE IN FLOAT, 
  SUCCESS OUT INTEGER, 
  INFO OUT VARCHAR2 
) 
AS 
  AVALUE FLOAT; 
BEGIN 
  SELECT COORDINATE_Y INTO AVALUE 
  FROM POINTS 
  WHERE POINT_ID=CHECK_NIV_10_MM_PASSPORT_Y.POINT_ID; 
   
  IF (VALUE<AVALUE-0.01) THEN 
    SUCCESS:=0;  
   INFO:='�������� �� �������. �������� < '||TO_CHAR(AVALUE-0.01); 
  ELSE 
    IF(VALUE>AVALUE+0.01) THEN 
   SUCCESS:=0; 
   INFO:='�������� �� �������. �������� > '||TO_CHAR(AVALUE+0.01);  
 ELSE 
    SUCCESS:=1; 
    INFO:='�������� �������. �������� �� ���������� �� 10�� �� ����������� '||TO_CHAR(AVALUE); 
 END IF; 
  END IF; 
END;

--

/* �������� ��������� */

COMMIT
