/* ��������� ��������� �������� ����� */

CREATE OR REPLACE PROCEDURE D_POINT
(
  OLD_POINT_ID IN INTEGER
)
AS
  CNT INTEGER;
  JOURNAL_FIELDS_E EXCEPTION;
  ERROR VARCHAR(500);
BEGIN

  SELECT COUNT(*) INTO CNT FROM JOURNAL_FIELDS WHERE POINT_ID=OLD_POINT_ID;
  IF (CNT>0) THEN
    ERROR:='������������� ����� ������������ � ������� �������.'||CHR(13)||
	       '��� �������� ����������, ��������� � ��������� D_POINT.';
    RAISE JOURNAL_FIELDS_E;
  END IF;
     
  DELETE FROM ROUTE_POINTS
        WHERE POINT_ID=OLD_POINT_ID;

  DELETE FROM POINT_DOCUMENTS
        WHERE POINT_ID=OLD_POINT_ID;

  DELETE FROM CONVERTERS
        WHERE CONVERTER_ID=OLD_POINT_ID;

  DELETE FROM DEVICE_POINTS
        WHERE POINT_ID=OLD_POINT_ID;
		
  DELETE FROM POINTS
        WHERE POINT_ID=OLD_POINT_ID;

  COMMIT; 
  
EXCEPTION
  WHEN JOURNAL_FIELDS_E THEN 
       RAISE_APPLICATION_ERROR(-20100,ERROR);
END;

--

/* �������� ��������� �� */

COMMIT