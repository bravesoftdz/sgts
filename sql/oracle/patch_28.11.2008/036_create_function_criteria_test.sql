/* �������� ������� ������� ��������� �������� */

CREATE OR REPLACE FUNCTION CRITERIA_TEST
(
  CRITERIA_ID IN INTEGER,
  PERIOD IN INTEGER,
  DATE_BEGIN IN DATE,
  DATE_END IN DATE,
  CYCLE_MIN IN INTEGER,
  CYCLE_MAX IN INTEGER
) 
RETURN CRITERIA_TABLE 
PIPELINED 
AS
  RET CRITERIA_OBJECT:=CRITERIA_OBJECT(NULL,NULL,NULL,NULL,NULL);
  FIRST_MIN_VALUE FLOAT;
  FIRST_MAX_VALUE FLOAT;
  SECOND_MIN_VALUE FLOAT;
  SECOND_MAX_VALUE FLOAT;
  FIRST_MODULO INTEGER;
  SECOND_MODULO INTEGER;
BEGIN
  SELECT FIRST_MIN_VALUE, FIRST_MAX_VALUE, SECOND_MIN_VALUE, SECOND_MAX_VALUE, 
         FIRST_MODULO, SECOND_MODULO
    INTO FIRST_MIN_VALUE, FIRST_MAX_VALUE, SECOND_MIN_VALUE, SECOND_MAX_VALUE, 
         FIRST_MODULO, SECOND_MODULO 
	FROM CRITERIAS 
   WHERE CRITERIA_ID=CRITERIA_TEST.CRITERIA_ID;	

    RET.POINT_ID:=NULL;
	RET.DATE_OBSERVATION:=CURRENT_DATE;
	RET.CYCLE_ID:=NULL;
	RET.VALUE:=100.0;
	RET.STATE:=1;
	
    PIPE ROW (RET);

	  
  RETURN; 
END; 

--

/* �������� ��������� */

COMMIT