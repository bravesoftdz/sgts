/* �������� ������� ��������� ��������� �������� 2 */

CREATE OR REPLACE VIEW S_FLT_TOTAL_CHARGES_2
AS 
SELECT
JO.MEASURE_TYPE_ID,
MT.NAME AS MEASURE_TYPE_NAME,
JO.CYCLE_ID,
C.CYCLE_NUM,
P.POINT_ID,
JO.DATE_OBSERVATION,
SUM(JO.VALUE) AS RASXOD,
P.COORDINATE_Z,
CP.VALUE AS SEK,
MT.PRIORITY AS PR_MT
FROM
JOURNAL_OBSERVATIONS JO,
CYCLES C,
POINTS P,
MEASURE_TYPES MT,
COMPONENTS CO,
CONVERTER_PASSPORTS CP
WHERE
JO.MEASURE_TYPE_ID IN (2584,2585)
AND JO.PARAM_ID=3042
AND C.CYCLE_ID=JO.CYCLE_ID
AND P.POINT_ID=JO.POINT_ID
AND MT.MEASURE_TYPE_ID=JO.MEASURE_TYPE_ID
AND CO.CONVERTER_ID=P.POINT_ID
AND CO.PARAM_ID=3003
AND CO.COMPONENT_ID=CP.COMPONENT_ID
AND P.POINT_ID IN (3736,3529,3500,3499)
GROUP BY
JO.MEASURE_TYPE_ID,
MT.NAME,
JO.CYCLE_ID,
C.CYCLE_NUM,
P.POINT_ID,
JO.DATE_OBSERVATION,
P.COORDINATE_Z,
CP.VALUE,
MT.PRIORITY
ORDER BY
MT.PRIORITY,
P.COORDINATE_Z DESC


