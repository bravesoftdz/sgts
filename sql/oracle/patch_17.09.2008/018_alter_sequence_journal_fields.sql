/* �������� ������������������ ��� ������� �������� ������� */

DROP SEQUENCE SEQ_JOURNAL_FIELDS

--

/* �������� ������������������ ��� ������� �������� ������� */

CREATE SEQUENCE SEQ_JOURNAL_FIELDS
INCREMENT BY 1 
START WITH 30000000
MINVALUE 30000000
MAXVALUE 1.0E28 
NOCYCLE 
CACHE 20 
NOORDER

--

/* �������� ��������� �� */

COMMIT
