/* �������� ��������� ����������� � ������� ������� �� ��� */

CREATE OR REPLACE PROCEDURE CONFIRM_RAIN_YEAR
( 
  JOURNAL_FIELD_ID IN INTEGER, 
  ALGORITHM_ID IN INTEGER 
) 
AS 
  JOURNAL_OBSERVATION_ID INTEGER; 
  AMEASURE_TYPE_ID INTEGER; 
  ACYCLE_ID INTEGER; 
  AWHO_CONFIRM INTEGER; 
  ADATE_CONFIRM DATE; 
  AGROUP_ID VARCHAR2(32); 
  APRIORITY INTEGER; 
  APOINT_ID INTEGER; 
  ADATE_OBSERVATION DATE; 
  APARAM_ID INTEGER; 
  CUR_YEAR INTEGER; 
  NEW_DATE DATE; 
  RAIN_YEAR FLOAT; 
BEGIN 
  SELECT MEASURE_TYPE_ID,CYCLE_ID,WHO_CONFIRM,DATE_CONFIRM,GROUP_ID,PRIORITY, 
         POINT_ID,DATE_OBSERVATION,PARAM_ID  
    INTO AMEASURE_TYPE_ID,ACYCLE_ID,AWHO_CONFIRM,ADATE_CONFIRM,AGROUP_ID,APRIORITY, 
      APOINT_ID,ADATE_OBSERVATION,APARAM_ID 
    FROM JOURNAL_FIELDS 
   WHERE JOURNAL_FIELD_ID=CONFIRM_RAIN_YEAR.JOURNAL_FIELD_ID; 
 
  IF (APARAM_ID=2907)/* ������� �� ����� */ THEN 
    
    DELETE FROM JOURNAL_OBSERVATIONS 
       WHERE JOURNAL_FIELD_ID=CONFIRM_RAIN_YEAR.JOURNAL_FIELD_ID 
            AND ALGORITHM_ID=CONFIRM_RAIN_YEAR.ALGORITHM_ID  
            AND MEASURE_TYPE_ID=AMEASURE_TYPE_ID 
            AND CYCLE_ID=ACYCLE_ID 
            AND DATE_OBSERVATION=ADATE_OBSERVATION 
            AND GROUP_ID=AGROUP_ID 
            AND POINT_ID=APOINT_ID 
            AND PARAM_ID=2910;/* ������� � ������ ���� */ 
    COMMIT; 
 
    IF (AWHO_CONFIRM IS NOT NULL) THEN 
  
      CUR_YEAR:=EXTRACT(YEAR FROM ADATE_OBSERVATION); 
   NEW_DATE:=TO_DATE('01.01.'||TO_CHAR(CUR_YEAR),'DD.MM.YYYY'); 
      SELECT SUM(VALUE) INTO RAIN_YEAR  
     FROM JOURNAL_FIELDS 
    WHERE MEASURE_TYPE_ID=AMEASURE_TYPE_ID 
      AND PARAM_ID=2907 /* ������� �� ����� */ 
      AND DATE_OBSERVATION>=NEW_DATE 
      AND DATE_OBSERVATION<=ADATE_OBSERVATION; 
   IF (RAIN_YEAR IS NOT NULL) THEN       
        I_JOURNAL_OBSERVATION(GET_JOURNAL_OBSERVATION_ID, 
                            JOURNAL_FIELD_ID, 
                          NULL, 
                              AMEASURE_TYPE_ID, 
                              NULL, 
                              ADATE_OBSERVATION, 
              ACYCLE_ID, 
              APOINT_ID, 
              2910,/* ������� � ������ ���� */ 
              RAIN_YEAR, 
              AWHO_CONFIRM, 
              ADATE_CONFIRM, 
              ALGORITHM_ID, 
           AGROUP_ID, 
           APRIORITY); 
      END IF;          
    END IF;          
  END IF;   
END;

--

/* �������� */

COMMIT
