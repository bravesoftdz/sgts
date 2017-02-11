/* �������� ������� ���������������� */

CREATE TABLE CONVERTERS 
(
  CONVERTER_ID INTEGER NOT NULL,
  NAME VARCHAR2(100) NOT NULL,
  DESCRIPTION VARCHAR2(250),
  DATE_ENTER DATE NOT NULL,   
  NOT_OPERATION INTEGER NOT NULL,
  PRIMARY KEY (CONVERTER_ID),
  FOREIGN KEY (CONVERTER_ID) REFERENCES POINTS (POINT_ID)
)

--

/* �������� ��������� ������� ���������������� */

CREATE OR REPLACE VIEW S_CONVERTERS
AS
  SELECT C.*, 
		 P.NAME AS POINT_NAME,
		 P.DESCRIPTION AS POINT_DESCRIPTION
    FROM CONVERTERS C, POINTS P
   WHERE C.CONVERTER_ID=P.POINT_ID

--

/* �������� ��������� �������� ��������������� */

CREATE OR REPLACE PROCEDURE I_CONVERTER
(
  CONVERTER_ID IN INTEGER,
  NAME IN VARCHAR2,
  DESCRIPTION IN VARCHAR2,
  DATE_ENTER IN DATE,
  NOT_OPERATION IN INTEGER   
)
AS
  CNT INTEGER;
  CONVERTER_E EXCEPTION;
  ERROR VARCHAR(500);
BEGIN

 SELECT COUNT(*) INTO CNT FROM CONVERTERS WHERE CONVERTER_ID=I_CONVERTER.CONVERTER_ID;
  IF (CNT>0) THEN
    ERROR:='������������� ����� ��� ����� ���� ���������������.'||CHR(13)||
	       '��� �������� ����������, ��������� � ��������� I_CONVERTER.';
    RAISE CONVERTER_E;
  END IF;

  INSERT INTO CONVERTERS (CONVERTER_ID,NAME,DESCRIPTION,DATE_ENTER,NOT_OPERATION)
       VALUES (CONVERTER_ID,NAME,DESCRIPTION,DATE_ENTER,NOT_OPERATION);
  COMMIT;
EXCEPTION 
  WHEN CONVERTER_E THEN 
       RAISE_APPLICATION_ERROR(-20100,ERROR);
END;

--

/* �������� ��������� ��������� ��������������� */

CREATE OR REPLACE PROCEDURE U_CONVERTER
(
  CONVERTER_ID IN INTEGER,
  NAME IN VARCHAR2,
  DESCRIPTION IN VARCHAR2,
  DATE_ENTER IN DATE,
  NOT_OPERATION IN INTEGER,   
  OLD_CONVERTER_ID IN INTEGER
)
AS
BEGIN
  UPDATE CONVERTERS 
     SET CONVERTER_ID=U_CONVERTER.CONVERTER_ID,
         NAME=U_CONVERTER.NAME,
		 DESCRIPTION=U_CONVERTER.DESCRIPTION,
		 DATE_ENTER=U_CONVERTER.DATE_ENTER,
		 NOT_OPERATION=U_CONVERTER.NOT_OPERATION
   WHERE CONVERTER_ID=OLD_CONVERTER_ID;
  COMMIT;        
END;

--

/* �������� ��������� �������� ��������������� */

CREATE PROCEDURE D_CONVERTER
(
  OLD_CONVERTER_ID IN INTEGER
)
AS
BEGIN
  DELETE FROM CONVERTERS
        WHERE CONVERTER_ID=OLD_CONVERTER_ID;
  COMMIT;        
END;

--

/* �������� ��������� �� */

COMMIT