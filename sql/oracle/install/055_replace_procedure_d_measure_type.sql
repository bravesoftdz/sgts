/* ��������� ��������������� ��������� �������� ���� ��������� */

CREATE OR REPLACE PROCEDURE D_MEASURE_TYPE_EX
(
  OLD_MEASURE_TYPE_ID IN INTEGER
)
AS
  CURSOR CUR IS
         SELECT MEASURE_TYPE_ID FROM MEASURE_TYPES
		  WHERE PARENT_ID=OLD_MEASURE_TYPE_ID;
BEGIN
  DELETE FROM MEASURE_TYPE_ALGORITHMS
        WHERE MEASURE_TYPE_ID=OLD_MEASURE_TYPE_ID;

  DELETE FROM MEASURE_TYPE_PARAMS
        WHERE MEASURE_TYPE_ID=OLD_MEASURE_TYPE_ID;

  DELETE FROM MEASURE_TYPE_ROUTES
        WHERE MEASURE_TYPE_ID=OLD_MEASURE_TYPE_ID;

  DELETE FROM GRAPHS
        WHERE GRAPH_ID=OLD_MEASURE_TYPE_ID;

  DELETE FROM PLANS
        WHERE MEASURE_TYPE_ID=OLD_MEASURE_TYPE_ID;

  FOR INC IN CUR LOOP
    D_MEASURE_TYPE_EX (INC.MEASURE_TYPE_ID);
  END LOOP;

  DELETE FROM MEASURE_TYPES
        WHERE MEASURE_TYPE_ID=OLD_MEASURE_TYPE_ID;

END;

--

/* ��������� ��������� �������� ���� ��������� */

CREATE OR REPLACE PROCEDURE D_MEASURE_TYPE
(
  OLD_MEASURE_TYPE_ID IN INTEGER
)
AS
BEGIN
  D_MEASURE_TYPE_EX (OLD_MEASURE_TYPE_ID);
  COMMIT;
END;

--

/* �������� ��������� �� */

COMMIT