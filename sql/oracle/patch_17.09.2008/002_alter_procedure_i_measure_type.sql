/* ��������� ��������� �������� ���� ��������� */

CREATE OR REPLACE PROCEDURE I_MEASURE_TYPE
(
  MEASURE_TYPE_ID IN INTEGER,
  PARENT_ID IN INTEGER,
  NAME IN VARCHAR2,
  DESCRIPTION IN VARCHAR2,
  DATE_BEGIN IN DATE,
  IS_ACTIVE IN INTEGER,
  PRIORITY IN INTEGER,
  IS_VISUAL IN INTEGER
)
AS
  CNT INTEGER;
  AIS_VISUAL INTEGER;
BEGIN
  AIS_VISUAL:=IS_VISUAL;
  IF (PARENT_ID IS NOT NULL) THEN
    SELECT COUNT(*) INTO CNT FROM MEASURE_TYPES
     WHERE MEASURE_TYPE_ID=PARENT_ID;
    IF (CNT>0) THEN
      SELECT IS_VISUAL INTO AIS_VISUAL
        FROM MEASURE_TYPES
       WHERE MEASURE_TYPE_ID=PARENT_ID;
    END IF;
  END IF;
  
  INSERT INTO MEASURE_TYPES (MEASURE_TYPE_ID,PARENT_ID,NAME,DESCRIPTION,
                             DATE_BEGIN,IS_ACTIVE,PRIORITY,IS_VISUAL)
       VALUES (MEASURE_TYPE_ID,PARENT_ID,NAME,DESCRIPTION,
            DATE_BEGIN,IS_ACTIVE,PRIORITY,AIS_VISUAL);

  UPDATE MEASURE_TYPE_ROUTES
     SET MEASURE_TYPE_ID=I_MEASURE_TYPE.MEASURE_TYPE_ID
   WHERE MEASURE_TYPE_ID=PARENT_ID;

  UPDATE MEASURE_TYPE_ALGORITHMS
     SET MEASURE_TYPE_ID=I_MEASURE_TYPE.MEASURE_TYPE_ID
   WHERE MEASURE_TYPE_ID=PARENT_ID;

  UPDATE MEASURE_TYPE_PARAMS
     SET MEASURE_TYPE_ID=I_MEASURE_TYPE.MEASURE_TYPE_ID
   WHERE MEASURE_TYPE_ID=PARENT_ID;

  UPDATE PLANS
     SET MEASURE_TYPE_ID=I_MEASURE_TYPE.MEASURE_TYPE_ID
   WHERE MEASURE_TYPE_ID=PARENT_ID;

  COMMIT;
END;

--

/* �������� ��������� �� */

COMMIT