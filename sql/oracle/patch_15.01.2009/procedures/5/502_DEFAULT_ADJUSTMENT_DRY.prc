/* �������� ��������� ��������� �������� �� ��������� ��� �������� ������ */

CREATE OR REPLACE PROCEDURE DEFAULT_ADJUSTMENT_DRY
( 
  VALUE_0 IN OUT FLOAT, 
  VALUE_1 IN OUT FLOAT, 
  VALUE_2 IN OUT FLOAT, 
  VALUE_5 IN OUT FLOAT, 
  VALUE_6 IN OUT FLOAT 
)   
AS 
BEGIN 
  IF (VALUE_1 IS NULL) THEN 
    VALUE_1:=0.0; 
  END IF; 
  VALUE_2:=VALUE_0+VALUE_1; 
  CALCULATE_MOISTURE(VALUE_2,VALUE_5,VALUE_6); 
END;

--

/* �������� ��������� */

COMMIT
