/* �������� ������������������ ��� ������� ��������� ���������������� */

DROP SEQUENCE SEQ_CONVERTER_PASSPORTS

--

/* �������� ������������������ ��� ������� ��������� ���������������� */

CREATE SEQUENCE SEQ_CONVERTER_PASSPORTS
INCREMENT BY 1 
START WITH 600000
MINVALUE 600000
MAXVALUE 1.0E28 
NOCYCLE 
CACHE 20 
NOORDER

--

/* �������� ��������� �� */

COMMIT
