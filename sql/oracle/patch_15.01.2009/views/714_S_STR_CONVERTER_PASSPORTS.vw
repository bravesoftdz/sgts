/* �������� ��������� ��������� ���������������� ��� ������-����������� ������ */

CREATE OR REPLACE VIEW S_STR_CONVERTER_PASSPORTS
AS 
SELECT    MT.MEASURE_TYPE_ID,    P.POINT_ID,    P.NAME AS POINT_NAME,    C.NAME AS CONVERTER_NAME,    CP.VALUE AS SEK,    CP2.VALUE AS OTM,    CP3.VALUE AS KOEF,
CP4.VALUE AS LEFT_OTV,    CP5.VALUE AS RIGHT_OTV    FROM    MEASURE_TYPES MT,    POINTS P,    CONVERTERS C,    ROUTE_POINTS RP,    CONVERTER_PASSPORTS CP,
COMPONENTS CO,    CONVERTER_PASSPORTS CP2,    COMPONENTS CO2,    CONVERTER_PASSPORTS CP3,    COMPONENTS CO3,    CONVERTER_PASSPORTS CP4,    COMPONENTS CO4,
CONVERTER_PASSPORTS CP5,    COMPONENTS CO5
WHERE    P.POINT_ID=C.CONVERTER_ID    AND MT.MEASURE_TYPE_ID=3620    AND RP.ROUTE_ID=3660    AND P.POINT_ID=RP.POINT_ID    AND CO.CONVERTER_ID=P.POINT_ID
AND CO.PARAM_ID=14100    AND CP.COMPONENT_ID=CO.COMPONENT_ID    AND CO2.CONVERTER_ID=P.POINT_ID    AND CO2.PARAM_ID=14101    AND CP2.COMPONENT_ID=CO2.COMPONENT_ID
 AND CO3.CONVERTER_ID=P.POINT_ID    AND CO3.PARAM_ID=14104    AND CP3.COMPONENT_ID=CO3.COMPONENT_ID    AND CO4.CONVERTER_ID=P.POINT_ID    AND CO4.PARAM_ID=14102
  AND CP4.COMPONENT_ID=CO4.COMPONENT_ID    AND CO5.CONVERTER_ID=P.POINT_ID    AND CO5.PARAM_ID=14103    AND CP5.COMPONENT_ID=CO5.COMPONENT_ID
   ORDER BY  TO_NUMBER(P.NAME)

--

/* �������� ��������� */

COMMIT

