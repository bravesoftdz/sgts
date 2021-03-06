/* �������� ��������� �������� ����� ��������� */

CREATE OR REPLACE VIEW S_MEASURE_TYPE_GRAPHS
AS
SELECT MT.NAME AS MEASURE_TYPE_NAME,
       DECODE (MT.PARENT_ID, NULL, 0, MT.PARENT_ID) AS PARENT_ID,
       MT.PRIORITY,
       MTG.YEAR,
       MTG.MEASURE_TYPE_ID,
       MTG.JANUARY,
       MTG.FEBRUARY,
       MTG.MARCH,
       MTG.APRIL,
       MTG.MAY,
       MTG.JUNE,
       MTG.JULY,
       MTG.AUGUST,
       MTG.SEPTEMBER,
       MTG.OKTOBER,
       MTG.NOVEMBER,
       MTG.DECEMBER
  FROM MEASURE_TYPE_GRAPHS MTG,
       MEASURE_TYPES MT
 WHERE MTG.MEASURE_TYPE_ID = MT.MEASURE_TYPE_ID


--

/* �������� ��������� */

COMMIT

