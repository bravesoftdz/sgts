/* �������� ������� ������� �������� ������������ ���������� ������ �������� ����� ������� */

CREATE OR REPLACE FUNCTION CRITERIA_MIN_TENSION 
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
  APARAM_ID INTEGER:=60035 /* ���������� � ������ ���������� */; 
  AMEASURE_TYPE_ID INTEGER:=60001 /* ����������-��������������� ���������\������� */; 
  AROUTE_ID INTEGER:=60001 /* ������� ������� */; 
  APASSPORT_PARAM_ID INTEGER:=60008 /* ������������ ������� */; 
  APASSPORT_VALUE VARCHAR2(100):='������������'; 
BEGIN 
  SELECT FIRST_MIN_VALUE, FIRST_MAX_VALUE, SECOND_MIN_VALUE, SECOND_MAX_VALUE,  
         FIRST_MODULO, SECOND_MODULO 
    INTO FIRST_MIN_VALUE, FIRST_MAX_VALUE, SECOND_MIN_VALUE, SECOND_MAX_VALUE,  
         FIRST_MODULO, SECOND_MODULO  
 FROM CRITERIAS  
   WHERE CRITERIA_ID=CRITERIA_MIN_TENSION.CRITERIA_ID; 
    
  IF (PERIOD=0) THEN 
 
    ADATE_BEGIN:=DATE_BEGIN; 
    IF (ADATE_BEGIN IS NULL) THEN 
   SELECT MIN(DATE_OBSERVATION) INTO ADATE_BEGIN 
     FROM JOURNAL_OBSERVATIONS 
    WHERE PARAM_ID=APARAM_ID 
      AND MEASURE_TYPE_ID=AMEASURE_TYPE_ID 
   AND POINT_ID IN (SELECT RP.POINT_ID  
                            FROM ROUTE_POINTS RP, COMPONENTS C, CONVERTER_PASSPORTS CP  
                           WHERE RP.ROUTE_ID=AROUTE_ID 
                             AND RP.POINT_ID=C.CONVERTER_ID 
                             AND C.PARAM_ID=APASSPORT_PARAM_ID 
                             AND C.COMPONENT_ID=CP.COMPONENT_ID 
                             AND CP.VALUE=APASSPORT_VALUE);    
 END IF; 
 
    ADATE_END:=DATE_END; 
    IF (ADATE_END IS NULL) THEN 
   SELECT MAX(DATE_OBSERVATION) INTO ADATE_END 
     FROM JOURNAL_OBSERVATIONS 
    WHERE PARAM_ID=APARAM_ID 
      AND MEASURE_TYPE_ID=AMEASURE_TYPE_ID 
   AND POINT_ID IN (SELECT RP.POINT_ID  
                            FROM ROUTE_POINTS RP, COMPONENTS C, CONVERTER_PASSPORTS CP  
                           WHERE RP.ROUTE_ID=AROUTE_ID 
                             AND RP.POINT_ID=C.CONVERTER_ID 
                             AND C.PARAM_ID=APASSPORT_PARAM_ID 
                             AND C.COMPONENT_ID=CP.COMPONENT_ID 
                             AND CP.VALUE=APASSPORT_VALUE); 
 END IF; 
  
 IF (ADATE_BEGIN IS NOT NULL) AND (ADATE_END IS NOT NULL) THEN 
       
   FLAG:=0; 
   FOR INC IN (SELECT JO.POINT_ID, JO.DATE_OBSERVATION, JO.CYCLE_ID, JO.VALUE 
                 FROM JOURNAL_OBSERVATIONS JO, CYCLES C 
                   WHERE JO.CYCLE_ID=C.CYCLE_ID 
         AND JO.PARAM_ID=APARAM_ID 
                     AND JO.MEASURE_TYPE_ID=AMEASURE_TYPE_ID 
                     AND JO.POINT_ID IN (SELECT RP.POINT_ID  
                                           FROM ROUTE_POINTS RP, COMPONENTS C, CONVERTER_PASSPORTS CP  
                                          WHERE RP.ROUTE_ID=AROUTE_ID 
                                            AND RP.POINT_ID=C.CONVERTER_ID 
                                            AND C.PARAM_ID=APASSPORT_PARAM_ID 
                                            AND C.COMPONENT_ID=CP.COMPONENT_ID 
                                            AND CP.VALUE=APASSPORT_VALUE) 
            AND JO.DATE_OBSERVATION>=ADATE_BEGIN AND JO.DATE_OBSERVATION<=ADATE_END 
         AND JO.VALUE>=FIRST_MIN_VALUE 
                   ORDER BY JO.DATE_OBSERVATION) LOOP 
        FLAG:=1; 
        RET.POINT_ID:=INC.POINT_ID; 
     RET.DATE_OBSERVATION:=INC.DATE_OBSERVATION; 
  RET.CYCLE_ID:=INC.CYCLE_ID; 
        RET.VALUE:=INC.VALUE; 
        IF (INC.VALUE>=SECOND_MIN_VALUE) THEN 
    RET.STATE:=3; 
  ELSE 
          RET.STATE:=2;        
  END IF;        
     PIPE ROW (RET); 
      END LOOP; 
    
   IF (FLAG=0) THEN 
     FOR INC IN (SELECT T.* 
                FROM (SELECT POINT_ID, DATE_OBSERVATION, CYCLE_ID, MAX(VALUE) AS VALUE 
                           FROM JOURNAL_OBSERVATIONS 
                             WHERE PARAM_ID=APARAM_ID 
                               AND MEASURE_TYPE_ID=AMEASURE_TYPE_ID 
                               AND POINT_ID IN (SELECT RP.POINT_ID  
                                                  FROM ROUTE_POINTS RP, COMPONENTS C, CONVERTER_PASSPORTS CP  
                                                 WHERE RP.ROUTE_ID=AROUTE_ID 
                                                   AND RP.POINT_ID=C.CONVERTER_ID 
                                                   AND C.PARAM_ID=APASSPORT_PARAM_ID 
                                                   AND C.COMPONENT_ID=CP.COMPONENT_ID 
                                                   AND CP.VALUE=APASSPORT_VALUE) 
                      AND DATE_OBSERVATION>=ADATE_BEGIN AND DATE_OBSERVATION<=ADATE_END 
                   AND VALUE<FIRST_MIN_VALUE 
              GROUP BY POINT_ID, DATE_OBSERVATION, CYCLE_ID) T 
      ORDER BY T.VALUE DESC) LOOP 
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
         AND JO.POINT_ID IN (SELECT RP.POINT_ID  
                               FROM ROUTE_POINTS RP, COMPONENTS C, CONVERTER_PASSPORTS CP  
                              WHERE RP.ROUTE_ID=AROUTE_ID 
                                AND RP.POINT_ID=C.CONVERTER_ID 
                                AND C.PARAM_ID=APASSPORT_PARAM_ID 
                                AND C.COMPONENT_ID=CP.COMPONENT_ID 
                                AND CP.VALUE=APASSPORT_VALUE);   
 END IF; 
 
    ACYCLE_MAX:=CYCLE_MAX; 
    IF (ACYCLE_MAX IS NULL) THEN 
   SELECT MAX(C.CYCLE_NUM) INTO ACYCLE_MAX 
     FROM JOURNAL_OBSERVATIONS JO, CYCLES C 
    WHERE JO.CYCLE_ID=C.CYCLE_ID 
      AND JO.PARAM_ID=APARAM_ID 
         AND JO.MEASURE_TYPE_ID=AMEASURE_TYPE_ID 
         AND JO.POINT_ID IN (SELECT RP.POINT_ID  
                               FROM ROUTE_POINTS RP, COMPONENTS C, CONVERTER_PASSPORTS CP  
                              WHERE RP.ROUTE_ID=AROUTE_ID 
                                AND RP.POINT_ID=C.CONVERTER_ID 
                                AND C.PARAM_ID=APASSPORT_PARAM_ID 
                                AND C.COMPONENT_ID=CP.COMPONENT_ID 
                                AND CP.VALUE=APASSPORT_VALUE);   
 END IF; 
  
 IF (ACYCLE_MIN IS NOT NULL) AND (ACYCLE_MAX IS NOT NULL) THEN 
       
   FLAG:=0; 
   FOR INC IN (SELECT JO.POINT_ID, JO.DATE_OBSERVATION, JO.CYCLE_ID, JO.VALUE 
                 FROM JOURNAL_OBSERVATIONS JO, CYCLES C 
                   WHERE JO.CYCLE_ID=C.CYCLE_ID 
                  AND JO.PARAM_ID=APARAM_ID 
                     AND JO.MEASURE_TYPE_ID=AMEASURE_TYPE_ID 
                     AND JO.POINT_ID IN (SELECT RP.POINT_ID  
                                           FROM ROUTE_POINTS RP, COMPONENTS C, CONVERTER_PASSPORTS CP  
                                          WHERE RP.ROUTE_ID=AROUTE_ID 
                                            AND RP.POINT_ID=C.CONVERTER_ID 
                                            AND C.PARAM_ID=APASSPORT_PARAM_ID 
                                            AND C.COMPONENT_ID=CP.COMPONENT_ID 
                                            AND CP.VALUE=APASSPORT_VALUE) 
            AND C.CYCLE_NUM>=ACYCLE_MIN AND C.CYCLE_NUM<=ACYCLE_MAX 
         AND JO.VALUE>=FIRST_MIN_VALUE 
       ORDER BY JO.DATE_OBSERVATION) LOOP 
        FLAG:=1; 
        RET.POINT_ID:=INC.POINT_ID; 
     RET.DATE_OBSERVATION:=INC.DATE_OBSERVATION; 
  RET.CYCLE_ID:=INC.CYCLE_ID; 
        RET.VALUE:=INC.VALUE; 
        IF (INC.VALUE>=SECOND_MIN_VALUE) THEN 
    RET.STATE:=3; 
  ELSE 
          RET.STATE:=2;        
  END IF;        
     PIPE ROW (RET); 
      END LOOP; 
    
   IF (FLAG=0) THEN 
     FOR INC IN (SELECT T.* 
                FROM (SELECT JO.POINT_ID, JO.DATE_OBSERVATION, JO.CYCLE_ID, MAX(JO.VALUE) AS VALUE 
                           FROM JOURNAL_OBSERVATIONS JO, CYCLES C 
                             WHERE JO.CYCLE_ID=C.CYCLE_ID 
                            AND JO.PARAM_ID=APARAM_ID 
                               AND JO.MEASURE_TYPE_ID=AMEASURE_TYPE_ID 
                               AND JO.POINT_ID IN (SELECT RP.POINT_ID  
                                                     FROM ROUTE_POINTS RP, COMPONENTS C, CONVERTER_PASSPORTS CP  
                                                    WHERE RP.ROUTE_ID=AROUTE_ID 
                                                      AND RP.POINT_ID=C.CONVERTER_ID 
                                                      AND C.PARAM_ID=APASSPORT_PARAM_ID 
                                                      AND C.COMPONENT_ID=CP.COMPONENT_ID 
                                                      AND CP.VALUE=APASSPORT_VALUE) 
                      AND C.CYCLE_NUM>=ACYCLE_MIN AND C.CYCLE_NUM<=ACYCLE_MAX 
                   AND JO.VALUE<FIRST_MIN_VALUE 
              GROUP BY JO.POINT_ID, JO.DATE_OBSERVATION, JO.CYCLE_ID) T 
      ORDER BY T.VALUE DESC) LOOP 
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