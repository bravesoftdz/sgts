/* ���������� ����������� ���������� */

BEGIN
  UPDATE PARAMS
     SET IS_NOT_CONFIRM=1
   WHERE PARAM_ID=3082;
  COMMIT;
END;

--

/* ��������� �������� ��������������� */

ALTER TABLE CONVERTER_PASSPORTS
MODIFY VALUE NULL

--

/* �������� ��������� */

COMMIT