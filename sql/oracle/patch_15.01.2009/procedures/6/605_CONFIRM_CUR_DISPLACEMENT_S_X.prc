/* �������� ��������� ����������� CONFIRM_CUR_DISPLACEMENT_S_X */

CREATE OR REPLACE PROCEDURE CONFIRM_CUR_DISPLACEMENT_S_X
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
  APARAM_ID INTEGER;   
  X FLOAT; 
  XOLD FLOAT; 
  DX FLOAT; 
  ADATE_OBSERVATION DATE; 
BEGIN 
  SELECT MEASURE_TYPE_ID,CYCLE_ID,WHO_CONFIRM,DATE_CONFIRM,GROUP_ID,PRIORITY,POINT_ID, 
         DATE_OBSERVATION, VALUE, PARAM_ID 
    INTO AMEASURE_TYPE_ID,ACYCLE_ID,AWHO_CONFIRM,ADATE_CONFIRM,AGROUP_ID,APRIORITY,APOINT_ID, 
         ADATE_OBSERVATION, X, APARAM_ID 
    FROM JOURNAL_FIELDS 
   WHERE JOURNAL_FIELD_ID=CONFIRM_CUR_DISPLACEMENT_S_X.JOURNAL_FIELD_ID;    
   IF (APARAM_ID=50043)   THEN 
   DELETE FROM JOURNAL_OBSERVATIONS 
        WHERE JOURNAL_FIELD_ID=CONFIRM_CUR_DISPLACEMENT_S_X.JOURNAL_FIELD_ID 
             AND ALGORITHM_ID=CONFIRM_CUR_DISPLACEMENT_S_X.ALGORITHM_ID 
             AND MEASURE_TYPE_ID=AMEASURE_TYPE_ID 
             AND CYCLE_ID=ACYCLE_ID 
             AND DATE_OBSERVATION=ADATE_OBSERVATION 
             AND GROUP_ID=AGROUP_ID 
             AND POINT_ID=APOINT_ID 
             AND PARAM_ID=50048; 
    COMMIT; 
 END IF; 
  IF (APARAM_ID=50043) THEN 
     DELETE FROM JOURNAL_OBSERVATIONS 
        WHERE JOURNAL_FIELD_ID=CONFIRM_CUR_DISPLACEMENT_S_X.JOURNAL_FIELD_ID 
             AND ALGORITHM_ID=CONFIRM_CUR_DISPLACEMENT_S_X.ALGORITHM_ID 
             AND MEASURE_TYPE_ID=AMEASURE_TYPE_ID 
             AND CYCLE_ID=ACYCLE_ID 
             AND DATE_OBSERVATION=ADATE_OBSERVATION 
             AND GROUP_ID=AGROUP_ID 
             AND POINT_ID=APOINT_ID 
             AND PARAM_ID=50048;  
    COMMIT;  
IF (AWHO_CONFIRM IS NOT NULL) THEN 
      XOLD:=NULL; 
      FOR INC IN (SELECT VALUE 
                    FROM JOURNAL_FIELDS 
                   WHERE MEASURE_TYPE_ID=AMEASURE_TYPE_ID 
         AND POINT_ID=APOINT_ID 
                     AND PARAM_ID=50043  
                     AND DATE_OBSERVATION<ADATE_OBSERVATION 
                ORDER BY DATE_OBSERVATION DESC) LOOP 
        XOLD:=INC.VALUE; 
        EXIT WHEN XOLD IS NOT NULL; 
      END LOOP; 
      IF XOLD IS NOT NULL THEN 
        DX:=(X-XOLD)*1000; 
        I_JOURNAL_OBSERVATION(GET_JOURNAL_OBSERVATION_ID, 
                              JOURNAL_FIELD_ID, 
                              NULL, 
                              AMEASURE_TYPE_ID, 
                              NULL, 
                              ADATE_OBSERVATION, 
                              ACYCLE_ID, 
                              APOINT_ID, 
                              50048, 
                              DX, 
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
