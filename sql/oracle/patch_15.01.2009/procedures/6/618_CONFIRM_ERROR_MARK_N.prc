/* �������� ��������� ����������� CONFIRM_ERROR_MARK_N */

CREATE OR REPLACE PROCEDURE CONFIRM_ERROR_MARK_N
( 
  JOURNAL_FIELD_ID IN INTEGER, 
  ALGORITHM_ID IN INTEGER 
) 
AS 
  AMEASURE_TYPE_ID INTEGER; 
  ACYCLE_ID INTEGER; 
  AWHO_CONFIRM INTEGER; 
  ADATE_CONFIRM DATE; 
  AGROUP_ID VARCHAR2(32); 
  APRIORITY INTEGER; 
  APOINT_ID INTEGER; 
  ADATE_OBSERVATION DATE; 
  APARAM_ID INTEGER; 
  AVALUE FLOAT; 
  AROUTE_ID INTEGER; 
  DIFF_SUM FLOAT; 
  INC INTEGER; 
  INC2 INTEGER; 
  V FLOAT; 
  N INTEGER; 
  M FLOAT; 
BEGIN 
  SELECT MEASURE_TYPE_ID,CYCLE_ID,WHO_CONFIRM,DATE_CONFIRM,GROUP_ID,PRIORITY, 
         POINT_ID,DATE_OBSERVATION,PARAM_ID,VALUE 
    INTO AMEASURE_TYPE_ID,ACYCLE_ID,AWHO_CONFIRM,ADATE_CONFIRM,AGROUP_ID,APRIORITY, 
         APOINT_ID,ADATE_OBSERVATION,APARAM_ID,AVALUE 
    FROM JOURNAL_FIELDS 
   WHERE JOURNAL_FIELD_ID=CONFIRM_ERROR_MARK_N.JOURNAL_FIELD_ID; 
 
  IF (APARAM_ID=50008) THEN 
 
    DELETE FROM JOURNAL_OBSERVATIONS 
       WHERE JOURNAL_FIELD_ID=CONFIRM_ERROR_MARK_N.JOURNAL_FIELD_ID 
            AND ALGORITHM_ID=CONFIRM_ERROR_MARK_N.ALGORITHM_ID 
            AND MEASURE_TYPE_ID=AMEASURE_TYPE_ID 
            AND CYCLE_ID=ACYCLE_ID 
            AND DATE_OBSERVATION=ADATE_OBSERVATION 
            AND GROUP_ID=AGROUP_ID 
            AND POINT_ID=APOINT_ID 
            AND PARAM_ID=50023; 
    COMMIT; 
 
    IF (AWHO_CONFIRM IS NOT NULL) THEN 
  
 SELECT ROUTE_ID INTO AROUTE_ID FROM ROUTE_POINTS WHERE (POINT_ID=APOINT_ID); 
 DIFF_SUM:=0; 
  
 FOR INC IN (SELECT POINT_ID FROM ROUTE_POINTS WHERE ROUTE_ID=AROUTE_ID ORDER BY PRIORITY) LOOP 
   FOR INC2 IN (SELECT VALUE FROM JOURNAL_FIELDS WHERE (CYCLE_ID=ACYCLE_ID) AND (POINT_ID=INC.POINT_ID) AND (PARAM_ID=50022)) LOOP 
     V:=INC2.VALUE; 
   END LOOP; 
   DIFF_SUM:=DIFF_SUM+V*V; 
 END LOOP; 
  
 SELECT COUNT(*) INTO N FROM ROUTE_POINTS WHERE (ROUTE_ID=AROUTE_ID); 
  
 M:=SQRT(DIFF_SUM/N)/2; 
 M:=ROUND(M*1000)/1000; 
  
 IF (M IS NOT NULL) THEN 
       
    I_JOURNAL_OBSERVATION(GET_JOURNAL_OBSERVATION_ID, 
                          JOURNAL_FIELD_ID, 
                          NULL, 
                          AMEASURE_TYPE_ID, 
                          NULL, 
                          ADATE_OBSERVATION, 
                          ACYCLE_ID, 
                          APOINT_ID, 
                          50023, 
                          M, 
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
