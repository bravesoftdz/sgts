/* �������� ������������������ ��� ������� ����� */

DROP SEQUENCE SEQ_POINTS

--

/* �������� ������������������ ��� ������� ����� */

CREATE SEQUENCE SEQ_POINTS 
INCREMENT BY 1 
START WITH 170000
MINVALUE 170000
MAXVALUE 1.0E28 
NOCYCLE 
CACHE 20 
NOORDER

--

/* �������� ��������� �� */

COMMIT
