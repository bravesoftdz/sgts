/* �������� ������������������ ��� ������� ������ �������� */

DROP SEQUENCE SEQ_OBJECT_TREES

--

/* �������� ������������������ ��� ������� ������ �������� */

CREATE SEQUENCE SEQ_OBJECT_TREES
INCREMENT BY 1 
START WITH 120000
MINVALUE 120000
MAXVALUE 1.0E28 
NOCYCLE 
CACHE 20 
NOORDER

--

/* �������� ��������� �� */

COMMIT
