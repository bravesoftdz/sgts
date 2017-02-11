/* �������� ��������� ���������� ����� */

CREATE OR REPLACE PROCEDURE I_CYCLE
( 
  CYCLE_ID IN INTEGER, 
  CYCLE_NUM IN INTEGER, 
  CYCLE_YEAR IN INTEGER, 
  CYCLE_MONTH IN INTEGER, 
  DESCRIPTION IN VARCHAR2,  
  IS_CLOSE IN INTEGER 
) 
AS 
BEGIN 
  INSERT INTO CYCLES (CYCLE_ID,CYCLE_NUM,CYCLE_YEAR,CYCLE_MONTH,DESCRIPTION,IS_CLOSE) 
       VALUES (CYCLE_ID,CYCLE_NUM,CYCLE_YEAR,CYCLE_MONTH,DESCRIPTION,IS_CLOSE); 
END;

--

/* �������� ��������� */

COMMIT
