/* �������� ��������� �������� ���������� */

CREATE OR REPLACE VIEW S_PARAM_INSTRUMENTS
AS 
SELECT PI.PARAM_ID,
       PI.INSTRUMENT_ID,
       PI.PRIORITY,
       P.NAME AS PARAM_NAME,
       I.NAME AS INSTRUMENT_NAME
  FROM PARAM_INSTRUMENTS PI,
       PARAMS P,
       INSTRUMENTS I
 WHERE PI.PARAM_ID = P.PARAM_ID
   AND PI.INSTRUMENT_ID = I.INSTRUMENT_ID

--

/* �������� ��������� */

COMMIT


