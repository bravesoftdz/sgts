/* �������� ������������������ ��� ������� ���������� */

DROP SEQUENCE SEQ_ALGORITHMS

--

/* �������� ������������������ ��� ������� ���������� */

CREATE SEQUENCE SEQ_ALGORITHMS 
INCREMENT BY 1 
START WITH 40000
MINVALUE 40000
MAXVALUE 1.0E28 
NOCYCLE 
CACHE 20 
NOORDER

--

/* �������� ��������� �� */

COMMIT
