/* �������� ������� ��������� ����������� � ������� ������� */

CREATE OR REPLACE FUNCTION GET_PZM_JOURNAL_FIELDS 
( 
  MEASURE_TYPE_ID INTEGER, 
  IS_CLOSE INTEGER 
) 
RETURN PZM_JOURNAL_FIELD_TABLE 
PIPELINED 
IS 
  INC2 PZM_JOURNAL_FIELD_OBJECT:=PZM_JOURNAL_FIELD_OBJECT(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL, 
                                                          NULL,NULL,NULL,NULL,NULL,NULL); 
  NUM_MIN INTEGER:=NULL; 
  NUM_MAX INTEGER:=NULL; 
BEGIN 
  FOR INC IN (SELECT MIN(CYCLE_NUM) AS NUM_MIN, MAX(CYCLE_NUM) AS NUM_MAX  
                FROM CYCLES 
               WHERE IS_CLOSE=GET_PZM_JOURNAL_FIELDS.IS_CLOSE) LOOP 
    NUM_MIN:=INC.NUM_MIN; 
 NUM_MAX:=INC.NUM_MAX;           
    EXIT;       
  END LOOP;        
 
  FOR INC1 IN (SELECT /*+ INDEX (JF) INDEX (C) INDEX (P) INDEX (RP) INDEX (I) INDEX (CR) */ 
                      JF.DATE_OBSERVATION,  
                      JF.VALUE,  
                      JF.MEASURE_TYPE_ID, 
                      JF.JOURNAL_NUM, 
                      JF.CYCLE_ID, 
                      C.CYCLE_NUM, 
                      JF.POINT_ID, 
                      P.NAME AS POINT_NAME, 
                      JF.INSTRUMENT_ID, 
                      I.NAME AS INSTRUMENT_NAME, 
                      CR.CONVERTER_ID, 
                      CR.NAME AS CONVERTER_NAME, 
                      OT.OBJECT_PATHS, 
                      P.COORDINATE_Z 
                 FROM JOURNAL_FIELDS JF, CYCLES C, POINTS P, 
                      ROUTE_POINTS RP, INSTRUMENTS I, CONVERTERS CR, 
                      (SELECT OT1.OBJECT_ID, SUBSTR(MAX(SYS_CONNECT_BY_PATH(O1.NAME,'\')),2) AS OBJECT_PATHS 
                         FROM OBJECT_TREES OT1, OBJECTS O1 
                        WHERE OT1.OBJECT_ID=O1.OBJECT_ID 
                        START WITH OT1.PARENT_ID IS NULL 
                      CONNECT BY OT1.PARENT_ID=PRIOR OT1.OBJECT_TREE_ID 
         GROUP BY OT1.OBJECT_ID) OT 
                WHERE JF.CYCLE_ID=C.CYCLE_ID 
                  AND JF.POINT_ID=P.POINT_ID 
                  AND RP.POINT_ID=JF.POINT_ID 
      AND OT.OBJECT_ID=P.OBJECT_ID 
                  AND I.INSTRUMENT_ID=JF.INSTRUMENT_ID  
                  AND CR.CONVERTER_ID=P.POINT_ID  
                  AND JF.MEASURE_TYPE_ID=GET_PZM_JOURNAL_FIELDS.MEASURE_TYPE_ID 
                  AND JF.PARAM_ID=2920 /* ������ ���������� */ 
                  AND C.CYCLE_NUM>=NUM_MIN AND C.CYCLE_NUM<=NUM_MAX 
                  AND C.IS_CLOSE=GET_PZM_JOURNAL_FIELDS.IS_CLOSE  
                ORDER BY JF.DATE_OBSERVATION, RP.PRIORITY) LOOP 
    INC2.CYCLE_ID:=INC1.CYCLE_ID; 
    INC2.CYCLE_NUM:=INC1.CYCLE_NUM; 
 INC2.DATE_OBSERVATION:=INC1.DATE_OBSERVATION; 
 INC2.MEASURE_TYPE_ID:=INC1.MEASURE_TYPE_ID; 
 INC2.JOURNAL_NUM:=INC1.JOURNAL_NUM; 
    INC2.POINT_ID:=INC1.POINT_ID; 
    INC2.POINT_NAME:=INC1.POINT_NAME; 
    INC2.CONVERTER_ID:=INC1.CONVERTER_ID; 
 INC2.CONVERTER_NAME:=INC1.CONVERTER_NAME; 
 INC2.INSTRUMENT_ID:=INC1.INSTRUMENT_ID; 
 INC2.INSTRUMENT_NAME:=INC1.INSTRUMENT_NAME; 
    INC2.VALUE:=INC1.VALUE; 
    INC2.OBJECT_PATHS:=INC1.OBJECT_PATHS; 
    INC2.COORDINATE_Z:=INC1.COORDINATE_Z; 
  
    PIPE ROW (INC2); 
  END LOOP; 
  RETURN; 
END;

--

/* �������� ��������� */

COMMIT

