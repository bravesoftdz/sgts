/* �������� ��������� ������������� �������� 3 ������� */

CREATE OR REPLACE VIEW S_OTV_DISPLACEMENT_VERTICAL_3
AS 
SELECT   JO.MEASURE_TYPE_ID,
         MT.NAME AS MEASURE_TYPE_NAME,
         JO.CYCLE_ID,
         CY.CYCLE_NUM,
         JO.POINT_ID,
         P.NAME AS POINT_NAME,
         C.NAME AS CONVERTER_NAME,
         JO.DATE_OBSERVATION,
         CP.VALUE AS VERTIKAL,
         DECODE (C.NAME, '��-1', TO_CHAR (CP2.VALUE), '��-2', TO_CHAR (CP2.VALUE), '��-3', TO_CHAR (CP2.VALUE), P.COORDINATE_Z) AS OTM_POINT,
         JO.VALUE AS SM_X,
         JO.VALUE - JO2.VALUE AS PR_X,
         JO3.VALUE AS SM_Y,
         JO3.VALUE - JO4.VALUE AS PR_Y,
         P.COORDINATE_Z
    FROM JOURNAL_OBSERVATIONS JO,
         JOURNAL_OBSERVATIONS JO2,
         JOURNAL_OBSERVATIONS JO3,
         JOURNAL_OBSERVATIONS JO4,
         MEASURE_TYPES MT,
         CYCLES CY,
         POINTS P,
         COMPONENTS CO,
         CONVERTER_PASSPORTS CP,
         COMPONENTS CO2,
         CONVERTER_PASSPORTS CP2,
         CONVERTERS C
   WHERE (   JO.MEASURE_TYPE_ID = 4621
          OR JO.MEASURE_TYPE_ID = 4622)
     AND (MT.MEASURE_TYPE_ID = JO.MEASURE_TYPE_ID)
     AND (JO.CYCLE_ID = CY.CYCLE_ID)
     AND (JO.POINT_ID = P.POINT_ID)
     AND (CO.CONVERTER_ID = JO.POINT_ID)
     AND (CO.PARAM_ID = 16141)
     AND (CP.COMPONENT_ID = CO.COMPONENT_ID)
     AND (CP.VALUE = '3')
     AND (CO2.CONVERTER_ID = JO.POINT_ID)
     AND (CO2.PARAM_ID = 16142)
     AND (CP2.COMPONENT_ID = CO2.COMPONENT_ID)
     AND (JO.PARAM_ID = 17165)
     AND (JO.POINT_ID = JO2.POINT_ID)
     AND (JO.CYCLE_ID - 1 = JO2.CYCLE_ID)
     AND (JO2.PARAM_ID = 17165)
     AND (JO.POINT_ID = JO3.POINT_ID)
     AND (JO.CYCLE_ID = JO3.CYCLE_ID)
     AND (JO3.PARAM_ID = 17166)
     AND (JO.POINT_ID = JO4.POINT_ID)
     AND (JO.CYCLE_ID - 1 = JO4.CYCLE_ID)
     AND (JO4.PARAM_ID = 17166)
     AND (C.CONVERTER_ID = P.POINT_ID)
ORDER BY JO.MEASURE_TYPE_ID,
         JO.DATE_OBSERVATION,
         DECODE (C.NAME, '��-1', TO_CHAR (CP2.VALUE), '��-2', TO_CHAR (CP2.VALUE), '��-3', TO_CHAR (CP2.VALUE), P.COORDINATE_Z)

--

/* �������� ��������� */

COMMIT


