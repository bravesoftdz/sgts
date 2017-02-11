/* �������� ������� ������� �������� ������ ������� */

CREATE OR REPLACE FUNCTION CRITERIA_DRAFT_DAM 
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
  ADATE_BEGIN DATE; 
  ADATE_END DATE; 
  ACYCLE_MIN INTEGER; 
  ACYCLE_MAX INTEGER; 
  FLAG INTEGER; 
  APARAM_ID INTEGER:=50024 /* ������ ������� */; 
  AMEASURE_TYPE_ID INTEGER:=49984 /* ������������� */; 
  AROUTE_ID1 INTEGER:=50028 /* ������� �1 */; 
  AROUTE_ID2 INTEGER:=50029 /* ������� �2 */; 
BEGIN 
  SELECT FIRST_MIN_VALUE, FIRST_MAX_VALUE, SECOND_MIN_VALUE, SECOND_MAX_VALUE,  
         FIRST_MODULO, SECOND_MODULO 
    INTO FIRST_MIN_VALUE, FIRST_MAX_VALUE, SECOND_MIN_VALUE, SECOND_MAX_VALUE,  
         FIRST_MODULO, SECOND_MODULO  
 FROM CRITERIAS  
   WHERE CRITERIA_ID=CRITERIA_DRAFT_DAM.CRITERIA_ID; 
    
  IF (PERIOD=0) THEN 
 
    ADATE_BEGIN:=DATE_BEGIN; 
    IF (ADATE_BEGIN IS NULL) THEN 
   SELECT MIN(DATE_OBSERVATION) INTO ADATE_BEGIN 
     FROM JOURNAL_OBSERVATIONS 
    WHERE PARAM_ID=APARAM_ID  
      AND MEASURE_TYPE_ID=AMEASURE_TYPE_ID  
   AND POINT_ID IN (SELECT POINT_ID FROM ROUTE_POINTS WHERE ROUTE_ID IN (AROUTE_ID1,AROUTE_ID2));   
 END IF; 
 
    ADATE_END:=DATE_END; 
    IF (ADATE_END IS NULL) THEN 
   SELECT MAX(DATE_OBSERVATION) INTO ADATE_END 
     FROM JOURNAL_OBSERVATIONS 
    WHERE PARAM_ID=APARAM_ID  
      AND MEASURE_TYPE_ID=AMEASURE_TYPE_ID  
   AND POINT_ID IN (SELECT POINT_ID FROM ROUTE_POINTS WHERE ROUTE_ID IN (AROUTE_ID1,AROUTE_ID2)); 
 END IF; 
  
 IF (ADATE_BEGIN IS NOT NULL) AND (ADATE_END IS NOT NULL) THEN 
       
   FLAG:=0; 
   FOR INC IN (SELECT JO.POINT_ID, JO.DATE_OBSERVATION, JO.CYCLE_ID, JO.VALUE 
                 FROM JOURNAL_OBSERVATIONS JO, CYCLES C 
                   WHERE JO.CYCLE_ID=C.CYCLE_ID 
         AND JO.PARAM_ID=APARAM_ID 
                     AND JO.MEASURE_TYPE_ID=AMEASURE_TYPE_ID 
                     AND JO.POINT_ID IN (SELECT POINT_ID FROM ROUTE_POINTS WHERE ROUTE_ID IN (AROUTE_ID1,AROUTE_ID2)) 
             AND JO.DATE_OBSERVATION>=ADATE_BEGIN AND JO.DATE_OBSERVATION<=ADATE_END 
         AND JO.VALUE<=FIRST_MIN_VALUE 
                   ORDER BY JO.DATE_OBSERVATION) LOOP 
        FLAG:=1; 
        RET.POINT_ID:=INC.POINT_ID; 
     RET.DATE_OBSERVATION:=INC.DATE_OBSERVATION; 
  RET.CYCLE_ID:=INC.CYCLE_ID; 
        RET.VALUE:=INC.VALUE; 
        IF (INC.VALUE<=SECOND_MIN_VALUE) THEN 
    RET.STATE:=3; 
  ELSE 
          RET.STATE:=2;        
  END IF;        
     PIPE ROW (RET); 
      END LOOP; 
    
   IF (FLAG=0) THEN 
     FOR INC IN (SELECT T.* 
                FROM (SELECT POINT_ID, DATE_OBSERVATION, CYCLE_ID, MIN(VALUE) AS VALUE 
                           FROM JOURNAL_OBSERVATIONS 
                             WHERE PARAM_ID=APARAM_ID 
                               AND MEASURE_TYPE_ID=AMEASURE_TYPE_ID 
                               AND POINT_ID IN (SELECT POINT_ID FROM ROUTE_POINTS WHERE ROUTE_ID IN (AROUTE_ID1,AROUTE_ID2)) 
                      AND DATE_OBSERVATION>=ADATE_BEGIN AND DATE_OBSERVATION<=ADATE_END 
                   AND VALUE>FIRST_MIN_VALUE 
              GROUP BY POINT_ID, DATE_OBSERVATION, CYCLE_ID) T 
      ORDER BY T.VALUE ASC) LOOP 
          RET.POINT_ID:=INC.POINT_ID; 
       RET.DATE_OBSERVATION:=INC.DATE_OBSERVATION; 
    RET.CYCLE_ID:=INC.CYCLE_ID; 
          RET.VALUE:=INC.VALUE; 
    RET.STATE:=1; 
    PIPE ROW (RET); 
    EXIT; 
  END LOOP; 
   END IF; 
    
 END IF;           
 
  ELSE 
 
    ACYCLE_MIN:=CYCLE_MIN; 
    IF (ACYCLE_MIN IS NULL) THEN 
   SELECT MIN(C.CYCLE_NUM) INTO ACYCLE_MIN 
     FROM JOURNAL_OBSERVATIONS JO, CYCLES C 
    WHERE JO.CYCLE_ID=C.CYCLE_ID 
      AND JO.PARAM_ID=APARAM_ID 
         AND JO.MEASURE_TYPE_ID=AMEASURE_TYPE_ID 
         AND JO.POINT_ID IN (SELECT POINT_ID FROM ROUTE_POINTS WHERE ROUTE_ID IN (AROUTE_ID1,AROUTE_ID2));   
 END IF; 
 
    ACYCLE_MAX:=CYCLE_MAX; 
    IF (ACYCLE_MAX IS NULL) THEN 
   SELECT MAX(C.CYCLE_NUM) INTO ACYCLE_MAX 
     FROM JOURNAL_OBSERVATIONS JO, CYCLES C 
    WHERE JO.CYCLE_ID=C.CYCLE_ID 
      AND JO.PARAM_ID=APARAM_ID 
         AND JO.MEASURE_TYPE_ID=AMEASURE_TYPE_ID 
         AND JO.POINT_ID IN (SELECT POINT_ID FROM ROUTE_POINTS WHERE ROUTE_ID IN (AROUTE_ID1,AROUTE_ID2));   
 END IF; 
  
 IF (ACYCLE_MIN IS NOT NULL) AND (ACYCLE_MAX IS NOT NULL) THEN 
       
   FLAG:=0; 
   FOR INC IN (SELECT JO.POINT_ID, JO.DATE_OBSERVATION, JO.CYCLE_ID, JO.VALUE 
                 FROM JOURNAL_OBSERVATIONS JO, CYCLES C 
                   WHERE JO.CYCLE_ID=C.CYCLE_ID 
                  AND JO.PARAM_ID=APARAM_ID 
                     AND JO.MEASURE_TYPE_ID=AMEASURE_TYPE_ID 
                     AND JO.POINT_ID IN (SELECT POINT_ID FROM ROUTE_POINTS WHERE ROUTE_ID IN (AROUTE_ID1,AROUTE_ID2)) 
            AND C.CYCLE_NUM>=ACYCLE_MIN AND C.CYCLE_NUM<=ACYCLE_MAX 
         AND JO.VALUE<=FIRST_MIN_VALUE 
       ORDER BY JO.DATE_OBSERVATION) LOOP 
        FLAG:=1; 
        RET.POINT_ID:=INC.POINT_ID; 
     RET.DATE_OBSERVATION:=INC.DATE_OBSERVATION; 
  RET.CYCLE_ID:=INC.CYCLE_ID; 
        RET.VALUE:=INC.VALUE; 
        IF (INC.VALUE<=SECOND_MIN_VALUE) THEN 
    RET.STATE:=3; 
  ELSE 
          RET.STATE:=2;        
  END IF;        
     PIPE ROW (RET); 
      END LOOP; 
    
   IF (FLAG=0) THEN 
     FOR INC IN (SELECT T.* 
                FROM (SELECT JO.POINT_ID, JO.DATE_OBSERVATION, JO.CYCLE_ID, MIN(JO.VALUE) AS VALUE 
                           FROM JOURNAL_OBSERVATIONS JO, CYCLES C 
                             WHERE JO.CYCLE_ID=C.CYCLE_ID 
                            AND JO.PARAM_ID=APARAM_ID 
                               AND JO.MEASURE_TYPE_ID=AMEASURE_TYPE_ID 
                               AND JO.POINT_ID IN (SELECT POINT_ID FROM ROUTE_POINTS WHERE ROUTE_ID IN (AROUTE_ID1,AROUTE_ID2)) 
                      AND C.CYCLE_NUM>=ACYCLE_MIN AND C.CYCLE_NUM<=ACYCLE_MAX 
                   AND JO.VALUE>FIRST_MIN_VALUE 
              GROUP BY JO.POINT_ID, JO.DATE_OBSERVATION, JO.CYCLE_ID) T 
      ORDER BY T.VALUE ASC) LOOP 
          RET.POINT_ID:=INC.POINT_ID; 
       RET.DATE_OBSERVATION:=INC.DATE_OBSERVATION; 
    RET.CYCLE_ID:=INC.CYCLE_ID; 
          RET.VALUE:=INC.VALUE; 
    RET.STATE:=1; 
    PIPE ROW (RET); 
    EXIT; 
  END LOOP; 
   END IF; 
    
 END IF;           
     
  END IF;   
 
  RETURN;  
END;

--

/* �������� ��������� */

COMMIT