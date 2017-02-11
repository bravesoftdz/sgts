/* �������� ��������� ��������� ������ ���������� �� X, Y, Z ��� ��������� ��������� */

CREATE OR REPLACE PROCEDURE CALCULATE_SLF_VALUES
(
  ADATE_OBSERVATION IN DATE,
  APOINT_ID IN INTEGER,
  VALUE_AB_RACK IN OUT FLOAT,
  VALUE_AB_COMPASSES IN OUT FLOAT,
  VALUE_AB_MICROMETR IN OUT FLOAT,
  VALUE_BA_RACK IN OUT FLOAT,
  VALUE_BA_COMPASSES IN OUT FLOAT,
  VALUE_BA_MICROMETR IN OUT FLOAT,
  VALUE_AC_RACK IN OUT FLOAT,
  VALUE_AC_COMPASSES IN OUT FLOAT,
  VALUE_AC_MICROMETR IN OUT FLOAT,
  VALUE_CA_RACK IN OUT FLOAT,
  VALUE_CA_COMPASSES IN OUT FLOAT,
  VALUE_CA_MICROMETR IN OUT FLOAT,
  VALUE_BC_RACK IN OUT FLOAT,
  VALUE_BC_COMPASSES IN OUT FLOAT,
  VALUE_BC_MICROMETR IN OUT FLOAT,
  VALUE_CB_RACK IN OUT FLOAT,
  VALUE_CB_COMPASSES IN OUT FLOAT,
  VALUE_CB_MICROMETR IN OUT FLOAT,
  AVERAGE_AB_COMPASSES IN OUT FLOAT,
  AVERAGE_AB_MICROMETR IN OUT FLOAT,
  AVERAGE_AC_COMPASSES IN OUT FLOAT,
  AVERAGE_AC_MICROMETR IN OUT FLOAT,
  AVERAGE_BC_COMPASSES IN OUT FLOAT,
  AVERAGE_BC_MICROMETR IN OUT FLOAT,
  ERROR IN OUT FLOAT,
  OPENING_X IN OUT FLOAT,
  OPENING_Y IN OUT FLOAT,
  OPENING_Z IN OUT FLOAT,
  CURRENT_OPENING_X IN OUT FLOAT,
  CURRENT_OPENING_Y IN OUT FLOAT,
  CURRENT_OPENING_Z IN OUT FLOAT
)
AS
  DISTANCE_X FLOAT;
  DISTANCE_Y FLOAT;
  DISTANCE_Z FLOAT;
  BASE_DISTANCE_X FLOAT;
  BASE_DISTANCE_Y FLOAT;
  BASE_DISTANCE_Z FLOAT;
  BASE_OPENING_X FLOAT;  
  BASE_OPENING_Y FLOAT;  
  BASE_OPENING_Z FLOAT; 
  OPENING_LAST_X FLOAT; 
  OPENING_LAST_Y FLOAT; 
  OPENING_LAST_Z FLOAT; 
  P1 FLOAT;
  P2 FLOAT;
BEGIN
  
  IF (VALUE_AB_COMPASSES IS NOT NULL) AND
     (VALUE_BA_COMPASSES IS NOT NULL) THEN
    AVERAGE_AB_COMPASSES:=(VALUE_AB_COMPASSES+VALUE_BA_COMPASSES)/2;
  END IF;
	 
  IF (VALUE_AB_COMPASSES IS NOT NULL) AND
     (VALUE_CA_COMPASSES IS NOT NULL) THEN	 
    AVERAGE_AC_COMPASSES:=(VALUE_AB_COMPASSES+VALUE_CA_COMPASSES)/2;
  END IF; 	 	  
	  
  IF (VALUE_BC_COMPASSES IS NOT NULL) AND
     (VALUE_CB_COMPASSES IS NOT NULL) THEN	  
    AVERAGE_BC_COMPASSES:=(VALUE_BC_COMPASSES+VALUE_CB_COMPASSES)/2;
  END IF;		  
  
  IF (VALUE_AB_RACK IS NOT NULL) AND
     (VALUE_AB_MICROMETR IS NOT NULL) AND
	 (VALUE_BA_RACK IS NOT NULL) AND
	 (VALUE_BA_MICROMETR IS NOT NULL) THEN
    AVERAGE_AB_MICROMETR:=((VALUE_AB_RACK+VALUE_AB_MICROMETR)-(VALUE_BA_RACK+VALUE_BA_MICROMETR))/2;
  END IF;
  	
  IF (VALUE_AC_RACK IS NOT NULL) AND
     (VALUE_AC_MICROMETR IS NOT NULL) AND
	 (VALUE_CA_RACK IS NOT NULL) AND
	 (VALUE_CA_MICROMETR IS NOT NULL) THEN
    AVERAGE_AC_MICROMETR:=((VALUE_AC_RACK+VALUE_AC_MICROMETR)-(VALUE_CA_RACK+VALUE_CA_MICROMETR))/2;
  END IF;
  	
  IF (VALUE_BC_RACK IS NOT NULL) AND
     (VALUE_BC_MICROMETR IS NOT NULL) AND
	 (VALUE_CB_RACK IS NOT NULL) AND
	 (VALUE_CB_MICROMETR IS NOT NULL) THEN	
    AVERAGE_BC_MICROMETR:=((VALUE_BC_RACK+VALUE_BC_MICROMETR)-(VALUE_CB_RACK+VALUE_CB_MICROMETR))/2;
  END IF;	
  	
  IF (AVERAGE_AB_MICROMETR IS NOT NULL) AND
     (AVERAGE_BC_MICROMETR IS NOT NULL) AND
	 (AVERAGE_AC_MICROMETR IS NOT NULL) THEN	
    ERROR:=AVERAGE_AB_MICROMETR+AVERAGE_BC_MICROMETR+AVERAGE_AC_MICROMETR;
  END IF;  		
  
  IF (AVERAGE_AC_COMPASSES IS NOT NULL) AND
     (AVERAGE_AB_COMPASSES IS NOT NULL) AND
	 (AVERAGE_BC_COMPASSES IS NOT NULL) THEN
	IF (AVERAGE_AB_COMPASSES<>0.0) THEN 
      DISTANCE_X:=(POWER(AVERAGE_AC_COMPASSES,2)+POWER(AVERAGE_AB_COMPASSES,2)-POWER(AVERAGE_BC_COMPASSES,2))/(AVERAGE_AB_COMPASSES*2);
	ELSE  
	  DISTANCE_X:=0.0;
	END IF;  
  END IF;
  	
  IF (AVERAGE_AC_COMPASSES IS NOT NULL) AND
     (DISTANCE_X IS NOT NULL) THEN
	P1:=POWER(AVERAGE_AC_COMPASSES,2);
	P2:=POWER(DISTANCE_X,2);
	IF (P1>=P2) THEN   	
  	  DISTANCE_Y:=POWER((P1-P2),1/2);
	ELSE
	  DISTANCE_Y:=0.0;  
	END IF;  
  END IF;	
  
  IF (AVERAGE_AB_MICROMETR IS NOT NULL) AND
     (AVERAGE_AC_MICROMETR IS NOT NULL) AND
	 (AVERAGE_BC_MICROMETR IS NOT NULL) THEN
    DISTANCE_Z:=(AVERAGE_AB_MICROMETR+AVERAGE_AC_MICROMETR+AVERAGE_BC_MICROMETR)/2;
  END IF;
  
  IF (DISTANCE_X IS NOT NULL) THEN

    BASE_DISTANCE_X:=0.0;
    FOR INC IN (SELECT CP.VALUE,
                       CP.DATE_BEGIN,
                       CP.DATE_END
                  FROM CONVERTER_PASSPORTS CP, COMPONENTS C
                 WHERE CP.COMPONENT_ID=C.COMPONENT_ID
                   AND C.CONVERTER_ID=APOINT_ID
                   AND C.PARAM_ID=30020 /* ���������� �� X */
                 ORDER BY CP.DATE_BEGIN) LOOP
      BASE_DISTANCE_X:=TO_NUMBER(REPLACE(INC.VALUE,',','.'),'FM99999.9999');
      EXIT WHEN (ADATE_OBSERVATION>=INC.DATE_BEGIN) AND (ADATE_OBSERVATION<INC.DATE_END);
    END LOOP;
  
    BASE_OPENING_X:=0.0;
    FOR INC IN (SELECT CP.VALUE,
                       CP.DATE_BEGIN,
                       CP.DATE_END
                  FROM CONVERTER_PASSPORTS CP, COMPONENTS C
                 WHERE CP.COMPONENT_ID=C.COMPONENT_ID
                   AND C.CONVERTER_ID=APOINT_ID
                   AND C.PARAM_ID=30024 /* ��������� � ������ ���������� �� X */
                 ORDER BY CP.DATE_BEGIN) LOOP
      BASE_OPENING_X:=TO_NUMBER(REPLACE(INC.VALUE,',','.'),'FM99999.9999');
      EXIT WHEN (ADATE_OBSERVATION>=INC.DATE_BEGIN) AND (ADATE_OBSERVATION<INC.DATE_END);
    END LOOP;
	
	OPENING_X:=DISTANCE_X-BASE_DISTANCE_X+BASE_OPENING_X;

    OPENING_LAST_X:=0.0;
    FOR INC IN (SELECT J.VALUE
                  FROM JOURNAL_FIELDS J, CYCLES C
	             WHERE J.CYCLE_ID=C.CYCLE_ID
				   AND J.POINT_ID=APOINT_ID
				   AND J.PARAM_ID=30024 /* ��������� � ������ ���������� �� X */
				   AND J.DATE_OBSERVATION<ADATE_OBSERVATION
			     ORDER BY J.DATE_OBSERVATION DESC) LOOP
      OPENING_LAST_X:=INC.VALUE; 
	  EXIT WHEN OPENING_LAST_X IS NOT NULL;
    END LOOP;
  	
	CURRENT_OPENING_X:=OPENING_X-OPENING_LAST_X;
  
  END IF;


  IF (DISTANCE_Y IS NOT NULL) THEN

    BASE_DISTANCE_Y:=0.0;
    FOR INC IN (SELECT CP.VALUE,
                       CP.DATE_BEGIN,
                       CP.DATE_END
                  FROM CONVERTER_PASSPORTS CP, COMPONENTS C
                 WHERE CP.COMPONENT_ID=C.COMPONENT_ID
                   AND C.CONVERTER_ID=APOINT_ID
                   AND C.PARAM_ID=30021 /* ���������� �� Y */
                 ORDER BY CP.DATE_BEGIN) LOOP
      BASE_DISTANCE_Y:=TO_NUMBER(REPLACE(INC.VALUE,',','.'),'FM99999.9999');
      EXIT WHEN (ADATE_OBSERVATION>=INC.DATE_BEGIN) AND (ADATE_OBSERVATION<INC.DATE_END);
    END LOOP;
  
    BASE_OPENING_Y:=0.0;
    FOR INC IN (SELECT CP.VALUE,
                       CP.DATE_BEGIN,
                       CP.DATE_END
                  FROM CONVERTER_PASSPORTS CP, COMPONENTS C
                 WHERE CP.COMPONENT_ID=C.COMPONENT_ID
                   AND C.CONVERTER_ID=APOINT_ID
                   AND C.PARAM_ID=30025 /* ��������� � ������ ���������� �� Y */
                 ORDER BY CP.DATE_BEGIN) LOOP
      BASE_OPENING_Y:=TO_NUMBER(REPLACE(INC.VALUE,',','.'),'FM99999.9999');
      EXIT WHEN (ADATE_OBSERVATION>=INC.DATE_BEGIN) AND (ADATE_OBSERVATION<INC.DATE_END);
    END LOOP;
	
	OPENING_Y:=DISTANCE_Y-BASE_DISTANCE_Y+BASE_OPENING_Y;

    OPENING_LAST_Y:=0.0;
    FOR INC IN (SELECT J.VALUE
                  FROM JOURNAL_FIELDS J, CYCLES C
	             WHERE J.CYCLE_ID=C.CYCLE_ID
				   AND J.POINT_ID=APOINT_ID
				   AND J.PARAM_ID=30025 /* ��������� � ������ ���������� �� Y */
				   AND J.DATE_OBSERVATION<ADATE_OBSERVATION
			     ORDER BY J.DATE_OBSERVATION DESC) LOOP
      OPENING_LAST_Y:=INC.VALUE; 
	  EXIT WHEN OPENING_LAST_Y IS NOT NULL;
    END LOOP;
  	
	CURRENT_OPENING_Y:=OPENING_Y-OPENING_LAST_Y;
  
  END IF;

  IF (DISTANCE_Z IS NOT NULL) THEN

    BASE_DISTANCE_Z:=0.0;
    FOR INC IN (SELECT CP.VALUE,
                       CP.DATE_BEGIN,
                       CP.DATE_END
                  FROM CONVERTER_PASSPORTS CP, COMPONENTS C
                 WHERE CP.COMPONENT_ID=C.COMPONENT_ID
                   AND C.CONVERTER_ID=APOINT_ID
                   AND C.PARAM_ID=30022 /* ���������� �� Z */
                 ORDER BY CP.DATE_BEGIN) LOOP
      BASE_DISTANCE_Z:=TO_NUMBER(REPLACE(INC.VALUE,',','.'),'FM99999.9999');
      EXIT WHEN (ADATE_OBSERVATION>=INC.DATE_BEGIN) AND (ADATE_OBSERVATION<INC.DATE_END);
    END LOOP;
  
    BASE_OPENING_Z:=0.0;
    FOR INC IN (SELECT CP.VALUE,
                       CP.DATE_BEGIN,
                       CP.DATE_END
                  FROM CONVERTER_PASSPORTS CP, COMPONENTS C
                 WHERE CP.COMPONENT_ID=C.COMPONENT_ID
                   AND C.CONVERTER_ID=APOINT_ID
                   AND C.PARAM_ID=30026 /* ��������� � ������ ���������� �� Z */
                 ORDER BY CP.DATE_BEGIN) LOOP
      BASE_OPENING_Z:=TO_NUMBER(REPLACE(INC.VALUE,',','.'),'FM99999.9999');
      EXIT WHEN (ADATE_OBSERVATION>=INC.DATE_BEGIN) AND (ADATE_OBSERVATION<INC.DATE_END);
    END LOOP;
	
	OPENING_Z:=DISTANCE_Z-BASE_DISTANCE_Z+BASE_OPENING_Z;

    OPENING_LAST_Z:=0.0;
    FOR INC IN (SELECT J.VALUE
                  FROM JOURNAL_FIELDS J, CYCLES C
	             WHERE J.CYCLE_ID=C.CYCLE_ID
				   AND J.POINT_ID=APOINT_ID
				   AND J.PARAM_ID=30026 /* ��������� � ������ ���������� �� Z */
				   AND J.DATE_OBSERVATION<ADATE_OBSERVATION
			     ORDER BY J.DATE_OBSERVATION DESC) LOOP
      OPENING_LAST_Z:=INC.VALUE; 
	  EXIT WHEN OPENING_LAST_Z IS NOT NULL;
    END LOOP;
  	
	CURRENT_OPENING_Z:=OPENING_Z-OPENING_LAST_Z;
  
  END IF;
  	
END;

--

/* �������� ��������� �� */

COMMIT