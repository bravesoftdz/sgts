/* �������� ������������������ ��� ������� ���������� */

DROP SEQUENCE SEQ_PARAMS

--

/* �������� ������������������ ��� ������� ���������� */

CREATE SEQUENCE SEQ_PARAMS 
INCREMENT BY 1 
START WITH 60000
MINVALUE 60000
MAXVALUE 1.0E28 
NOCYCLE 
CACHE 20 
NOORDER

--

/* �������� ��������� �� */

COMMIT
