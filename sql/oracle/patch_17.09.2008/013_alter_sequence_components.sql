/* �������� ������������������ ��� ������� ��������� */

DROP SEQUENCE SEQ_COMPONENTS

--

/* �������� ������������������ ��� ������� ��������� */

CREATE SEQUENCE SEQ_COMPONENTS
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
