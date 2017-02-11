/* �������� ��������� ��������� �������� �� ��������� ��� �������� ������� */

CREATE OR REPLACE PROCEDURE DEFAULT_ADJUSTMENT_WET
( 
  VALUE_2 IN OUT FLOAT, 
  VALUE_3 IN OUT FLOAT, 
  VALUE_4 IN OUT FLOAT, 
  VALUE_5 IN OUT FLOAT, 
  VALUE_6 IN OUT FLOAT 
)   
AS 
BEGIN 
  IF (VALUE_4 IS NULL) THEN 
    VALUE_4:=0.0; 
  END IF; 
  VALUE_5:=VALUE_3+VALUE_4; 
  CALCULATE_MOISTURE(VALUE_2,VALUE_5,VALUE_6); 
END;

--

/* �������� ��������� */

COMMIT
