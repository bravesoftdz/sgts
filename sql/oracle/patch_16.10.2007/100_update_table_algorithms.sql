/* ���������� ������� ���������� */

DECLARE

A_ID INTEGER;
PA_ID INTEGER;

BEGIN
	 A_ID:=GET_ALGORITHM_ID;
	 INSERT INTO ALGORITHMS VALUES (A_ID, '����. ���� ����� ����� ��. � ���.', 'DEFAULT_DIFFERENCE_COURSE', '�������� ���� ����� ����� ����� � �������');
	 COMMIT;

	 PA_ID:=GET_PARAM_ID;
	 INSERT INTO PARAMS VALUES (PA_ID, A_ID, '����. ����', '�������� ���� ����� ����� ����� � �������', 0, '##0.00');
	 COMMIT;

	 INSERT INTO MEASURE_TYPE_PARAMS VALUES (3620, PA_ID, 4);
	 COMMIT;

	 INSERT INTO MEASURE_TYPE_ALGORITHMS VALUES (3620, A_ID, 7);
	 COMMIT;
	 
END;