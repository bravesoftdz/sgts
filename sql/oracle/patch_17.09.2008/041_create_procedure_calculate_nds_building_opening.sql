/* �������� ��������� ������� ��������� ������������� ��� */

CREATE OR REPLACE PROCEDURE CALCULATE_NDS_BUILDING_OPENING
(
  POINT_ID IN INTEGER,
  FREQUENCY IN FLOAT,
  RESISTANCE IN FLOAT,
  RESISTANCE_LINE IN FLOAT,
  BY_B IN INTEGER,
  DATE_OBSERVATION IN DATE,
  MEASURE_TYPE_ID IN INTEGER,
  CYCLE_ID IN INTEGER,
  IS_BASE IN INTEGER,
  OPENING OUT FLOAT
)
AS
  B0 FLOAT;
  B1 FLOAT;
  B2 FLOAT;
  LENGTH_INSTRUMENT FLOAT;
  RATIO_INSTRUMENT FLOAT;
  RATIO_TEMPERATURE FLOAT;
  RATIO_TEMPERATURE2 FLOAT;
  TEMPERATURE FLOAT;
  MODULE_FREQUENCY FLOAT;
  FREQUENCY_0 FLOAT;
  RESISTANCE_0 FLOAT;
  POINT_NAME INTEGER;
BEGIN

  SELECT NAME INTO POINT_NAME FROM POINTS WHERE POINT_ID=CALCULATE_NDS_BUILDING_OPENING.POINT_ID;
  DBMS_OUTPUT.PUT_LINE('POINT_NAME='||TO_CHAR(POINT_NAME));			
  DBMS_OUTPUT.PUT_LINE('DATE='||TO_CHAR(DATE_OBSERVATION));		
  DBMS_OUTPUT.PUT_LINE('FREQUENCY='||TO_CHAR(FREQUENCY));		
  DBMS_OUTPUT.PUT_LINE('RESISTANCE='||TO_CHAR(RESISTANCE));		
  DBMS_OUTPUT.PUT_LINE('RESISTANCE_LINE='||TO_CHAR(RESISTANCE_LINE));		
  
  IF (BY_B=1) THEN
    B0:=NULL;
    FOR INC IN (SELECT CP.VALUE,
 	                   CP.DATE_BEGIN,
                       CP.DATE_END
                  FROM CONVERTER_PASSPORTS CP, COMPONENTS C, POINTS P
                 WHERE CP.COMPONENT_ID=C.COMPONENT_ID
                   AND C.CONVERTER_ID=P.POINT_ID
                   AND P.POINT_ID=CALCULATE_NDS_BUILDING_OPENING.POINT_ID
                   AND C.PARAM_ID=60014 /* B0 */
                 ORDER BY CP.DATE_BEGIN) LOOP
      B0:=TO_NUMBER(REPLACE(INC.VALUE,',','.'),'FM99999.9999');			   
	  EXIT WHEN B0 IS NOT NULL;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('B0='||TO_CHAR(B0));		
	  
    B1:=NULL;
    FOR INC IN (SELECT CP.VALUE,
 	                   CP.DATE_BEGIN,
                       CP.DATE_END
                  FROM CONVERTER_PASSPORTS CP, COMPONENTS C, POINTS P
                 WHERE CP.COMPONENT_ID=C.COMPONENT_ID
                   AND C.CONVERTER_ID=P.POINT_ID
                   AND P.POINT_ID=CALCULATE_NDS_BUILDING_OPENING.POINT_ID
                   AND C.PARAM_ID=60015 /* B1 */
                 ORDER BY CP.DATE_BEGIN) LOOP
      B1:=TO_NUMBER(REPLACE(INC.VALUE,',','.'),'FM99999.9999');			   
	  EXIT WHEN B1 IS NOT NULL;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('B1='||TO_CHAR(B1));		

    B2:=NULL;
    FOR INC IN (SELECT CP.VALUE,
                       CP.DATE_BEGIN,
                       CP.DATE_END
                  FROM CONVERTER_PASSPORTS CP, COMPONENTS C, POINTS P
                 WHERE CP.COMPONENT_ID=C.COMPONENT_ID
                   AND C.CONVERTER_ID=P.POINT_ID
                   AND P.POINT_ID=CALCULATE_NDS_BUILDING_OPENING.POINT_ID
                   AND C.PARAM_ID=60016 /* B2 */
                 ORDER BY CP.DATE_BEGIN) LOOP
      B2:=TO_NUMBER(REPLACE(INC.VALUE,',','.'),'FM99999.9999');			   
	  EXIT WHEN B2 IS NOT NULL;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('B2='||TO_CHAR(B2));		

    IF (B0 IS NOT NULL) AND
       (B1 IS NOT NULL) AND
	   (B2 IS NOT NULL) THEN
	 
      OPENING:=B0+B1*FREQUENCY+B2*POWER(FREQUENCY,2); 
    END IF;
	
  ELSE
    RATIO_INSTRUMENT:=NULL;
    FOR INC IN (SELECT CP.VALUE,
 	                   CP.DATE_BEGIN,
                       CP.DATE_END
                  FROM CONVERTER_PASSPORTS CP, COMPONENTS C, POINTS P
                 WHERE CP.COMPONENT_ID=C.COMPONENT_ID
                   AND C.CONVERTER_ID=P.POINT_ID
                   AND P.POINT_ID=CALCULATE_NDS_BUILDING_OPENING.POINT_ID
                   AND C.PARAM_ID=60018 /* ����������� ������� */
                 ORDER BY CP.DATE_BEGIN) LOOP
      RATIO_INSTRUMENT:=TO_NUMBER(REPLACE(INC.VALUE,',','.'),'FM99999.9999');			   
	  EXIT WHEN RATIO_INSTRUMENT IS NOT NULL;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('RATIO_INSTRUMENT='||TO_CHAR(RATIO_INSTRUMENT));
	 
    RATIO_TEMPERATURE:=NULL;
    FOR INC IN (SELECT CP.VALUE,
 	                   CP.DATE_BEGIN,
                       CP.DATE_END
                  FROM CONVERTER_PASSPORTS CP, COMPONENTS C, POINTS P
                 WHERE CP.COMPONENT_ID=C.COMPONENT_ID
                   AND C.CONVERTER_ID=P.POINT_ID
                   AND P.POINT_ID=CALCULATE_NDS_BUILDING_OPENING.POINT_ID
                   AND C.PARAM_ID=60011 /* ������������� ����������� ������� */
                 ORDER BY CP.DATE_BEGIN) LOOP
      RATIO_TEMPERATURE:=TO_NUMBER(REPLACE(INC.VALUE,',','.'),'FM99999.9999');			   
	  EXIT WHEN RATIO_TEMPERATURE IS NOT NULL;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('RATIO_TEMPERATURE='||TO_CHAR(RATIO_TEMPERATURE));
	 
    RATIO_TEMPERATURE2:=NULL;
    FOR INC IN (SELECT CP.VALUE,
 	                   CP.DATE_BEGIN,
                       CP.DATE_END
                  FROM CONVERTER_PASSPORTS CP, COMPONENTS C, POINTS P
                 WHERE CP.COMPONENT_ID=C.COMPONENT_ID
                   AND C.CONVERTER_ID=P.POINT_ID
                   AND P.POINT_ID=CALCULATE_NDS_BUILDING_OPENING.POINT_ID
                   AND C.PARAM_ID=60025 /* ������������� ����������� ��� ��������� */
                 ORDER BY CP.DATE_BEGIN) LOOP
      RATIO_TEMPERATURE2:=TO_NUMBER(REPLACE(INC.VALUE,',','.'),'FM99999.9999');			   
	  EXIT WHEN RATIO_TEMPERATURE2 IS NOT NULL;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('RATIO_TEMPERATURE2='||TO_CHAR(RATIO_TEMPERATURE2));
	 
    TEMPERATURE:=NULL;
    FOR INC IN (SELECT CP.VALUE,
 	                   CP.DATE_BEGIN,
                       CP.DATE_END
                  FROM CONVERTER_PASSPORTS CP, COMPONENTS C, POINTS P
                 WHERE CP.COMPONENT_ID=C.COMPONENT_ID
                   AND C.CONVERTER_ID=P.POINT_ID
                   AND P.POINT_ID=CALCULATE_NDS_BUILDING_OPENING.POINT_ID
                   AND C.PARAM_ID=60020 /* ����������� ��� �������� */
                 ORDER BY CP.DATE_BEGIN) LOOP
      TEMPERATURE:=TO_NUMBER(REPLACE(INC.VALUE,',','.'),'FM99999.9999');			   
	  EXIT WHEN TEMPERATURE IS NOT NULL;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('TEMPERATURE='||TO_CHAR(TEMPERATURE));
	 
    LENGTH_INSTRUMENT:=NULL;
    FOR INC IN (SELECT CP.VALUE,
 	                   CP.DATE_BEGIN,
                       CP.DATE_END
                  FROM CONVERTER_PASSPORTS CP, COMPONENTS C, POINTS P
                 WHERE CP.COMPONENT_ID=C.COMPONENT_ID
                   AND C.CONVERTER_ID=P.POINT_ID
                   AND P.POINT_ID=CALCULATE_NDS_BUILDING_OPENING.POINT_ID
                   AND C.PARAM_ID=60022 /* ����� ������� */
                 ORDER BY CP.DATE_BEGIN) LOOP
      LENGTH_INSTRUMENT:=TO_NUMBER(REPLACE(INC.VALUE,',','.'),'FM99999.9999');			   
	  EXIT WHEN LENGTH_INSTRUMENT IS NOT NULL;
    END LOOP;
	
    DBMS_OUTPUT.PUT_LINE('LENGTH_INSTRUMENT='||TO_CHAR(LENGTH_INSTRUMENT));
	 
    MODULE_FREQUENCY:=NULL;
    FOR INC IN (SELECT CP.VALUE,
 	                   CP.DATE_BEGIN,
                       CP.DATE_END
                  FROM CONVERTER_PASSPORTS CP, COMPONENTS C, POINTS P
                 WHERE CP.COMPONENT_ID=C.COMPONENT_ID
                   AND C.CONVERTER_ID=P.POINT_ID
                   AND P.POINT_ID=CALCULATE_NDS_BUILDING_OPENING.POINT_ID
                   AND C.PARAM_ID=60019 /* ������ ������� */
                 ORDER BY CP.DATE_BEGIN) LOOP
      MODULE_FREQUENCY:=TO_NUMBER(REPLACE(INC.VALUE,',','.'),'FM99999.9999');			   
	  EXIT WHEN MODULE_FREQUENCY IS NOT NULL;
    END LOOP;
	
	DBMS_OUTPUT.PUT_LINE('MODULE_FREQUENCY='||TO_CHAR(MODULE_FREQUENCY));
	
    RESISTANCE_0:=NULL;
    FOR INC IN (SELECT CP.VALUE,
 	                   CP.DATE_BEGIN,
                       CP.DATE_END
                  FROM CONVERTER_PASSPORTS CP, COMPONENTS C, POINTS P
                 WHERE CP.COMPONENT_ID=C.COMPONENT_ID
                   AND C.CONVERTER_ID=P.POINT_ID
                   AND P.POINT_ID=CALCULATE_NDS_BUILDING_OPENING.POINT_ID
                   AND C.PARAM_ID=60010 /* ������������� ������� */
                 ORDER BY CP.DATE_BEGIN) LOOP
      RESISTANCE_0:=TO_NUMBER(REPLACE(INC.VALUE,',','.'),'FM99999.9999');			   
      EXIT WHEN RESISTANCE_0 IS NOT NULL;
    END LOOP;
	
	DBMS_OUTPUT.PUT_LINE('RESISTANCE_0='||TO_CHAR(RESISTANCE_0));
	
	IF (RATIO_INSTRUMENT IS NOT NULL) AND
       (RATIO_TEMPERATURE IS NOT NULL) AND
       (RATIO_TEMPERATURE2 IS NOT NULL) AND
       (TEMPERATURE IS NOT NULL) AND
	   (LENGTH_INSTRUMENT IS NOT NULL) AND
	   (MODULE_FREQUENCY IS NOT NULL) AND
	   (RESISTANCE_0 IS NOT NULL) AND
	   (RATIO_TEMPERATURE<>0.0) THEN

	  FREQUENCY_0:=SQRT(1000*MODULE_FREQUENCY);
	  OPENING:=((POWER(FREQUENCY,2)/1000-MODULE_FREQUENCY)*RATIO_INSTRUMENT-
	           (((RESISTANCE-RESISTANCE_LINE-RESISTANCE_0)/RATIO_TEMPERATURE-TEMPERATURE)*RATIO_TEMPERATURE2))*LENGTH_INSTRUMENT/POWER(10,5);
	           
    END IF;
  END IF;
  
  DBMS_OUTPUT.PUT_LINE('OPENING='||TO_CHAR(OPENING));		 
END;

--

/* �������� ��������� �� */

COMMIT