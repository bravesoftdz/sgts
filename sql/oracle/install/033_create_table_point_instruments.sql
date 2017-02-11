/* �������� ������� �������� ����� */

CREATE TABLE POINT_INSTRUMENTS 
(
  POINT_ID INTEGER NOT NULL, 
  INSTRUMENT_ID INTEGER NOT NULL,
  PARAM_ID INTEGER NOT NULL, 
  PRIORITY INTEGER NOT NULL,
  PRIMARY KEY (POINT_ID,INSTRUMENT_ID,PARAM_ID),
  FOREIGN KEY (POINT_ID) REFERENCES POINTS (POINT_ID),
  FOREIGN KEY (INSTRUMENT_ID) REFERENCES INSTRUMENTS (INSTRUMENT_ID),
  FOREIGN KEY (PARAM_ID) REFERENCES PARAMS (PARAM_ID)
)

--

/* �������� ��������� ������� �������� ����� */

CREATE OR REPLACE VIEW S_POINT_INSTRUMENTS
AS
  SELECT PI.*,
         P.NAME AS POINT_NAME,
		 I.NAME AS INSTRUMENT_NAME,
		 I.DESCRIPTION AS INSTRUMENT_DESCRIPTION,
		 I.INSTRUMENT_TYPE_ID,
		 IT.NAME AS INSTRUMENT_TYPE_NAME,  
		 I.DATE_ENTER AS INSTRUMENT_DATE_ENTER,
		 I.SERIAL_NUMBER AS INSTRUMENT_SERIAL_NUMBER,
		 I.INVENTORY_NUMBER AS INSTRUMENT_INVENTORY_NUMBER,
		 I.FREQUENCY_TEST AS INSTRUMENT_FREQUENCY_TEST,
		 I.DATE_END AS INSTRUMENT_DATE_END,
		 I.CLASS_ACCURACY AS INSTRUMENT_CLASS_ACCURACY,
		 I.RANGE_MEASURE AS INSTRUMENT_RANGE_MEASURE,
		 PR.NAME AS PARAM_NAME
    FROM POINT_INSTRUMENTS PI, POINTS P, INSTRUMENTS I, PARAMS PR,
	     INSTRUMENT_TYPES IT   
   WHERE PI.POINT_ID=P.POINT_ID 
     AND PI.INSTRUMENT_ID=I.INSTRUMENT_ID
	 AND PI.PARAM_ID=PR.PARAM_ID
	 AND I.INSTRUMENT_TYPE_ID=IT.INSTRUMENT_TYPE_ID
ORDER BY PI.PRIORITY	 

--

/* �������� ��������� ���������� ������� ����� */

CREATE OR REPLACE PROCEDURE I_POINT_INSTRUMENT
(
  POINT_ID IN INTEGER,
  INSTRUMENT_ID IN INTEGER,
  PARAM_ID IN INTEGER,
  PRIORITY IN INTEGER
)
AS
BEGIN
  INSERT INTO POINT_INSTRUMENTS (POINT_ID,INSTRUMENT_ID,PARAM_ID,PRIORITY)
       VALUES (POINT_ID,INSTRUMENT_ID,PARAM_ID,PRIORITY);
  COMMIT;
END;

--

/* �������� ��������� ��������� ������� ����� */

CREATE OR REPLACE PROCEDURE U_POINT_INSTRUMENT
(
  POINT_ID IN INTEGER,
  INSTRUMENT_ID IN INTEGER,
  PARAM_ID IN INTEGER,
  PRIORITY IN INTEGER,
  OLD_POINT_ID IN INTEGER,
  OLD_INSTRUMENT_ID IN INTEGER,
  OLD_PARAM_ID IN INTEGER
)
AS
BEGIN
  UPDATE POINT_INSTRUMENTS 
     SET POINT_ID=U_POINT_INSTRUMENT.POINT_ID,
         INSTRUMENT_ID=U_POINT_INSTRUMENT.INSTRUMENT_ID,
		 PARAM_ID=U_POINT_INSTRUMENT.PARAM_ID,
         PRIORITY=U_POINT_INSTRUMENT.PRIORITY
   WHERE POINT_ID=OLD_POINT_ID 
     AND INSTRUMENT_ID=OLD_INSTRUMENT_ID
	 AND PARAM_ID=OLD_PARAM_ID;
  COMMIT;        
END;

--

/* �������� ��������� �������� ������� ����� */

CREATE OR REPLACE PROCEDURE D_POINT_INSTRUMENT
(
  OLD_POINT_ID IN INTEGER,
  OLD_INSTRUMENT_ID IN INTEGER,
  OLD_PARAM_ID IN INTEGER
)
AS
BEGIN
  DELETE FROM POINT_INSTRUMENTS
        WHERE POINT_ID=OLD_POINT_ID
          AND INSTRUMENT_ID=OLD_INSTRUMENT_ID
		  AND PARAM_ID=OLD_PARAM_ID;
  COMMIT;        
END;

--

/* �������� ��������� �� */

COMMIT