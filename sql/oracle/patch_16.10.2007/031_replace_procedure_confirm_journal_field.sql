/* ��������� ��������� ����������� �������� ������� */

CREATE OR REPLACE PROCEDURE CONFIRM_JOURNAL_FIELD
(
  JOURNAL_FIELD_ID IN INTEGER
)
AS
  CNT INTEGER;
  CNT1 INTEGER;
  CNT2 INTEGER;
  AMEASURE_TYPE_ID INTEGER;
  ADATE_ENTER DATE; 
  ADATE_CONFIRM DATE;
  AWHO_CONFIRM INTEGER;
  ACYCLE_ID INTEGER;
  APARAM_ID INTEGER;
  APOINT_ID INTEGER;
  ADATE_OBSERVATION DATE;
  SQLS VARCHAR2(5000):=NULL;
  AIS_BASE INTEGER;
  MAX_DATE DATE;
  MAX_POINT_ID INTEGER;
  MAX_PARAM_ID INTEGER;
BEGIN
  SELECT COUNT(*) INTO CNT FROM JOURNAL_FIELDS
   WHERE JOURNAL_FIELD_ID=CONFIRM_JOURNAL_FIELD.JOURNAL_FIELD_ID;
  
  IF (CNT>0) THEN

    SELECT /*+ INDEX(JF) */
	       DATE_CONFIRM,WHO_ENTER,DATE_ENTER,MEASURE_TYPE_ID,CYCLE_ID,
	       PARAM_ID,POINT_ID,DATE_OBSERVATION,IS_BASE 
	  INTO ADATE_CONFIRM,AWHO_CONFIRM,ADATE_ENTER,AMEASURE_TYPE_ID,ACYCLE_ID,
	       APARAM_ID,APOINT_ID,ADATE_OBSERVATION,AIS_BASE
	  FROM JOURNAL_FIELDS JF
     WHERE JOURNAL_FIELD_ID=CONFIRM_JOURNAL_FIELD.JOURNAL_FIELD_ID;
	 
    SELECT /*+ INDEX(JF) */
	       MAX(DATE_OBSERVATION)
	  INTO MAX_DATE 
	  FROM JOURNAL_FIELDS JF
	 WHERE MEASURE_TYPE_ID=AMEASURE_TYPE_ID
	   AND CYCLE_ID=ACYCLE_ID
	   AND IS_BASE=1;

    DBMS_OUTPUT.PUT_LINE('***START***');	
	DBMS_OUTPUT.PUT_LINE(CONFIRM_JOURNAL_FIELD.JOURNAL_FIELD_ID);
    DBMS_OUTPUT.PUT_LINE(MAX_DATE);	
    DBMS_OUTPUT.PUT_LINE(ADATE_OBSERVATION);	
	IF (MAX_DATE=ADATE_OBSERVATION) THEN
	  
/*	  FOR INC IN (SELECT POINT_ID
                    FROM MEASURE_TYPE_ROUTES MTR, ROUTE_POINTS RP, CONVERTERS C
                   WHERE MTR.ROUTE_ID=RP.ROUTE_ID
                     AND MTR.MEASURE_TYPE_ID=AMEASURE_TYPE_ID
					 AND RP.POINT_ID=C.CONVERTER_ID
					 AND C.DATE_ENTER<=ADATE_OBSERVATION
					 AND C.NOT_OPERATION=0
                   ORDER BY RP.PRIORITY DESC) LOOP
        MAX_POINT_ID:=INC.POINT_ID;
		EXIT WHEN MAX_POINT_ID IS NOT NULL; 				   
      END LOOP;				   
	   	 
	  DBMS_OUTPUT.PUT_LINE(MAX_POINT_ID);
	  DBMS_OUTPUT.PUT_LINE(APOINT_ID);
	  IF (MAX_POINT_ID=APOINT_ID) THEN*/
	    
		FOR INC IN (SELECT PARAM_ID
                      FROM MEASURE_TYPE_PARAMS MTA
                     WHERE MTA.MEASURE_TYPE_ID=AMEASURE_TYPE_ID
                     ORDER BY MTA.PRIORITY DESC) LOOP
          MAX_PARAM_ID:=INC.PARAM_ID;
		  EXIT WHEN MAX_PARAM_ID IS NOT NULL; 					 
        END LOOP;
		 
	    DBMS_OUTPUT.PUT_LINE(MAX_PARAM_ID);
	    DBMS_OUTPUT.PUT_LINE(APARAM_ID);
		IF (MAX_PARAM_ID=APARAM_ID) AND
		   (AWHO_CONFIRM IS NOT NULL) AND
		   (AIS_BASE=1) THEN        
	 
         /* SELECT COUNT(*) INTO CNT1 
            FROM JOURNAL_FIELDS JF
           WHERE JF.MEASURE_TYPE_ID=AMEASURE_TYPE_ID
             AND JF.CYCLE_ID=ACYCLE_ID
			 AND JF.IS_BASE=1
             AND JF.WHO_CONFIRM IS NOT NULL; 
   			   
          SELECT COUNT(*) INTO CNT2 
            FROM MEASURE_TYPE_PARAMS MTA, MEASURE_TYPE_ROUTES MTR, 
			     ROUTE_POINTS RP, CONVERTERS C
           WHERE MTA.MEASURE_TYPE_ID=AMEASURE_TYPE_ID
             AND MTA.MEASURE_TYPE_ID=MTR.MEASURE_TYPE_ID
             AND MTR.ROUTE_ID=RP.ROUTE_ID
			 AND RP.POINT_ID=C.CONVERTER_ID
			 AND C.NOT_OPERATION=0;	   
	  
	      DBMS_OUTPUT.PUT_LINE(CNT1);
	      DBMS_OUTPUT.PUT_LINE(CNT2);
          IF (MOD(CNT1,CNT2)=0) THEN*/
	
            FOR INC IN (SELECT A.PROC_NAME,A.ALGORITHM_ID
                          FROM MEASURE_TYPE_ALGORITHMS MTA, ALGORITHMS A
                         WHERE MTA.ALGORITHM_ID=A.ALGORITHM_ID
                           AND MTA.MEASURE_TYPE_ID=AMEASURE_TYPE_ID
						   AND MTA.DATE_BEGIN<=TRUNC(CURRENT_DATE)
						   AND (MTA.DATE_END IS NULL OR MTA.DATE_END>=TRUNC(CURRENT_DATE))
                         ORDER BY MTA.PRIORITY) LOOP
				
              FOR INC2 IN (SELECT /*+ INDEX(JF) */ 
			                      JOURNAL_FIELD_ID
                             FROM JOURNAL_FIELDS JF
                            WHERE MEASURE_TYPE_ID=AMEASURE_TYPE_ID
                              AND CYCLE_ID=ACYCLE_ID
                            ORDER BY DATE_OBSERVATION) LOOP	
    
                SQLS:='BEGIN '||INC.PROC_NAME||'('||TO_CHAR(INC2.JOURNAL_FIELD_ID)||','||TO_CHAR(INC.ALGORITHM_ID)||'); END;';
                EXECUTE IMMEDIATE SQLS;
              END LOOP;
            END LOOP;
/*	      END IF;		
	    END IF;		*/
      END IF;
	END IF;  
  END IF;         
END;

--

/* �������� ��������� �� */

COMMIT