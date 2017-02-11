/* �������� ��������� �������� CHECK_DIFFERENCE_COURSE_N */

CREATE OR REPLACE PROCEDURE CHECK_DIFFERENCE_COURSE_N  (
  VALUE_0 IN FLOAT, 
  VALUE_1 IN FLOAT,     
  SUCCESS OUT INTEGER,     
  INFO OUT VARCHAR2  )   
AS   
  AVALUE FLOAT; 
BEGIN     
  AVALUE:=ABS(VALUE_0-VALUE_1); 
  IF (AVALUE>0.25) THEN       
    SUCCESS:=0;       
 INFO:='�������� �� �������. ������ ������������ ���������� �������� ����� ��������� ����� ����� � ������� ='||TO_CHAR(AVALUE)||' � > 0.25';     
  ELSE        
    SUCCESS:=1;       
 INFO:='�������� �������. ������ ������������ ���������� �������� ����� ��������� ����� ����� � ������� ='||TO_CHAR(AVALUE)||' � <= 0.25';     
  END IF;     
END;

--

/* �������� ��������� */

COMMIT

