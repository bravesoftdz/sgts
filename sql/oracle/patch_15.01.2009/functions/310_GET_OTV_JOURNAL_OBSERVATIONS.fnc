/* �������� ������� ��������� ������� � ������� ���������� */

CREATE OR REPLACE FUNCTION GET_OTV_JOURNAL_OBSERVATIONS 
( 
  MEASURE_TYPE_ID INTEGER, 
  IS_CLOSE INTEGER 
) 
RETURN OTV_JOURNAL_OBSERVATION_TABLE 
PIPELINED 
IS 
  INC2 OTV_JOURNAL_OBSERVATION_OBJECT:=OTV_JOURNAL_OBSERVATION_OBJECT(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL, 
                                                                      NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL, 
                            NULL,NULL,NULL,NULL); 
  NUM_MIN INTEGER:=NULL; 
  NUM_MAX INTEGER:=NULL; 
BEGIN 
  FOR INC IN (SELECT MIN(CYCLE_NUM) AS NUM_MIN, MAX(CYCLE_NUM) AS NUM_MAX  
                FROM CYCLES 
               WHERE IS_CLOSE=GET_OTV_JOURNAL_OBSERVATIONS.IS_CLOSE) LOOP 
    NUM_MIN:=INC.NUM_MIN; 
 NUM_MAX:=INC.NUM_MAX;           
    EXIT;       
  END LOOP;        
    
  FOR INC1 IN (SELECT /*+ INDEX (JO) INDEX (C) INDEX (P) INDEX (RP) INDEX (CR) */ 
                      JO.DATE_OBSERVATION, 
                      JO.MEASURE_TYPE_ID, 
                      JO.CYCLE_ID, 
                      C.CYCLE_NUM, 
                      JO.POINT_ID, 
                      P.NAME AS POINT_NAME, 
                      CR.CONVERTER_ID, 
                      CR.NAME AS CONVERTER_NAME, 
       CR.DATE_ENTER, 
         MIN(DECODE(JO.PARAM_ID,17157,JF.VALUE,NULL)) AS COUNTING_OUT_AXIS_X,   
         MIN(DECODE(JO.PARAM_ID,17158,JF.VALUE,NULL)) AS COUNTING_OUT_AXIS_Y,   
         MIN(DECODE(JO.PARAM_ID,17161,JF.VALUE,NULL)) AS OFFSET_X_WITH_BEGIN_OBSERV, 
         MIN(DECODE(JO.PARAM_ID,17162,JF.VALUE,NULL)) AS OFFSET_Y_WITH_BEGIN_OBSERV, 
         MIN(DECODE(JO.PARAM_ID,17163,JF.VALUE,NULL)) AS CURRENT_OFFSET_X, 
         MIN(DECODE(JO.PARAM_ID,17164,JF.VALUE,NULL)) AS CURRENT_OFFSET_Y, 
       (SELECT MIN(CP.VALUE) FROM CONVERTER_PASSPORTS CP, COMPONENTS CM  
                        WHERE CP.COMPONENT_ID=CM.COMPONENT_ID 
                          AND CM.CONVERTER_ID=CR.CONVERTER_ID 
            AND CM.PARAM_ID=16140 /* ������ ������ */ ) AS GROUP_NAME, 
        (SELECT TO_NUMBER(REPLACE(CP.VALUE,',','.'),'FM99999.9999') FROM CONVERTER_PASSPORTS CP, COMPONENTS CM  
                        WHERE CP.COMPONENT_ID=CM.COMPONENT_ID 
                          AND CM.CONVERTER_ID=CR.CONVERTER_ID 
                          AND CM.PARAM_ID=16142 /* ���. ������ ��� ����� ������ */ ) AS MARH_GRAP_OR_ANCHOR_PLUMB,              
       OT.OBJECT_PATHS, 
   (SELECT GO.PRIORITY AS OBJECT_PRIORITY 
        FROM GROUP_OBJECTS GO 
       WHERE GO.GROUP_ID=30001 
         AND JO.MEASURE_TYPE_ID=4622 
         AND GO.OBJECT_ID=P.OBJECT_ID) AS AXES_PRIORITY, 
  (SELECT GO.PRIORITY AS OBJECT_PRIORITY 
        FROM GROUP_OBJECTS GO 
       WHERE GO.GROUP_ID=2503 
         AND JO.MEASURE_TYPE_ID=4621 
         AND GO.OBJECT_ID=(SELECT PARENT_ID 
              FROM OBJECT_TREES 
           WHERE OBJECT_ID=P.OBJECT_ID)) AS SECTION_PRIORITY, 
       P.COORDINATE_Z, 
       JF.NOTE 
        
                 FROM JOURNAL_OBSERVATIONS JO, JOURNAL_FIELDS JF, CYCLES C, POINTS P, 
                      ROUTE_POINTS RP, CONVERTERS CR, 
                      (SELECT OT1.OBJECT_ID, SUBSTR(MAX(SYS_CONNECT_BY_PATH(O1.NAME,'\')),2) AS OBJECT_PATHS 
                         FROM OBJECT_TREES OT1, OBJECTS O1 
                        WHERE OT1.OBJECT_ID=O1.OBJECT_ID 
                        START WITH OT1.PARENT_ID IS NULL 
                      CONNECT BY OT1.PARENT_ID=PRIOR OT1.OBJECT_TREE_ID 
         GROUP BY OT1.OBJECT_ID) OT 
                WHERE JO.JOURNAL_FIELD_ID=JF.JOURNAL_FIELD_ID 
      AND JO.CYCLE_ID=C.CYCLE_ID 
                  AND JO.POINT_ID=P.POINT_ID 
                  AND RP.POINT_ID=JO.POINT_ID 
                  AND CR.CONVERTER_ID=P.POINT_ID  
      AND P.OBJECT_ID=OT.OBJECT_ID 
                  AND JO.MEASURE_TYPE_ID=GET_OTV_JOURNAL_OBSERVATIONS.MEASURE_TYPE_ID 
                   AND JO.PARAM_ID IN (17157, /* ������ �� ��� X */ 
                                      17158, /* ������ �� ��� Y */ 
                                      17161, /* �������� �� X � ���. ����. */ 
                                      17162, /* �������� �� Y � ���. ����. */ 
                                      17163, /* ������� ����. �� X */ 
                                      17164 /* ������� ����. �� Y */) 
                  AND C.CYCLE_NUM>=NUM_MIN AND C.CYCLE_NUM<=NUM_MAX 
      AND C.IS_CLOSE=GET_OTV_JOURNAL_OBSERVATIONS.IS_CLOSE           
    GROUP BY JO.DATE_OBSERVATION, JO.MEASURE_TYPE_ID, JO.CYCLE_ID, C.CYCLE_NUM, JO.POINT_ID,  
             P.NAME, CR.CONVERTER_ID, CR.NAME, JO.GROUP_ID, RP.PRIORITY, CR.DATE_ENTER,  
       OT.OBJECT_PATHS, P.OBJECT_ID, P.COORDINATE_Z, JF.NOTE 
                ORDER BY JO.DATE_OBSERVATION, JO.GROUP_ID, RP.PRIORITY) LOOP 
     
 INC2.CYCLE_ID:=INC1.CYCLE_ID; 
 INC2.CYCLE_NUM:=INC1.CYCLE_NUM; 
 INC2.DATE_OBSERVATION:=INC1.DATE_OBSERVATION; 
 INC2.MEASURE_TYPE_ID:=INC1.MEASURE_TYPE_ID; 
 INC2.POINT_ID:=INC1.POINT_ID; 
 INC2.POINT_NAME:=INC1.POINT_NAME; 
 INC2.CONVERTER_ID:=INC1.CONVERTER_ID; 
 INC2.CONVERTER_NAME:=INC1.CONVERTER_NAME; 
 INC2.DATE_ENTER:=INC1.DATE_ENTER; 
 INC2.COUNTING_OUT_AXIS_X:=INC1.COUNTING_OUT_AXIS_X;   
 INC2.COUNTING_OUT_AXIS_Y:=INC1.COUNTING_OUT_AXIS_Y;   
 INC2.OFFSET_X_WITH_BEGIN_OBSERV:=INC1.OFFSET_X_WITH_BEGIN_OBSERV; 
 INC2.OFFSET_Y_WITH_BEGIN_OBSERV:=INC1.OFFSET_Y_WITH_BEGIN_OBSERV; 
 INC2.CURRENT_OFFSET_X:=INC1.CURRENT_OFFSET_X; 
 INC2.CURRENT_OFFSET_Y:=INC1.CURRENT_OFFSET_Y; 
 INC2.GROUP_NAME:=INC1.GROUP_NAME; 
 INC2.MARH_GRAP_OR_ANCHOR_PLUMB:=INC1.MARH_GRAP_OR_ANCHOR_PLUMB; 
 INC2.OBJECT_PATHS:=INC1.OBJECT_PATHS;  
 INC2.AXES_PRIORITY:=INC1.AXES_PRIORITY; 
 INC2.SECTION_PRIORITY:=INC1.SECTION_PRIORITY; 
 INC2.COORDINATE_Z:=INC1.COORDINATE_Z; 
 INC2.DESCRIPTION:=INC1.NOTE; 
  
    PIPE ROW (INC2); 
  END LOOP;  
  RETURN; 
END;

--

/* �������� ��������� */

COMMIT

