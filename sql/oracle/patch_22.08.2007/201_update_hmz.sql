/* ���������� ��������� ����� */

BEGIN
  UPDATE ROUTE_POINTS SET ROUTE_ID=2640 WHERE (ROUTE_ID=2644) OR (ROUTE_ID=2643) OR (ROUTE_ID=2642) OR (ROUTE_ID=2645);
END;

--

/* ���������� ��������� ����� ��������� */

BEGIN
  UPDATE MEASURE_TYPE_ROUTES SET MEASURE_TYPE_ID=2600 WHERE ROUTE_ID=2640;
END;

--

/* ���������� ���������*/

BEGIN
  UPDATE ROUTES SET NAME='������� ����������' WHERE ROUTE_ID=2640;
  UPDATE ROUTES SET DESCRIPTION='������� ����������' WHERE ROUTE_ID=2640;
END;

--

/* �������� ��������� ����� */ 
  
BEGIN
  DELETE FROM ROUTE_POINTS WHERE (ROUTE_ID=2644) OR (ROUTE_ID=2643) OR (ROUTE_ID=2642) OR (ROUTE_ID=2645); 
END;

--

/* �������� ��������� ����� */ 

BEGIN
  DELETE FROM PERSONNEL_ROUTES WHERE (ROUTE_ID=2644) OR (ROUTE_ID=2643) OR (ROUTE_ID=2642) OR (ROUTE_ID=2645); 
END;

--

/* �������� ��������� ����� ��������� */ 

BEGIN
  DELETE FROM MEASURE_TYPE_ROUTES WHERE (ROUTE_ID=2644) OR (ROUTE_ID=2643) OR (ROUTE_ID=2642) OR (ROUTE_ID=2645); 
END;

--

/* �������� ��������� */ 

BEGIN
  DELETE FROM ROUTES WHERE (ROUTE_ID=2644) OR (ROUTE_ID=2643) OR (ROUTE_ID=2642) OR (ROUTE_ID=2645); 
END;

--

/* ���������� �������� ������� */ 

BEGIN
  UPDATE JOURNAL_FIELDS SET MEASURE_TYPE_ID=2600 
   WHERE (MEASURE_TYPE_ID=2601) OR (MEASURE_TYPE_ID=2602) OR (MEASURE_TYPE_ID=2603) OR (MEASURE_TYPE_ID=2604) OR (MEASURE_TYPE_ID=2607); 
END;

--

/* ���������� ������� ���������� */ 

BEGIN
  UPDATE JOURNAL_OBSERVATIONS SET MEASURE_TYPE_ID=2600 
   WHERE (MEASURE_TYPE_ID=2601) OR (MEASURE_TYPE_ID=2602) OR (MEASURE_TYPE_ID=2603) OR (MEASURE_TYPE_ID=2604) OR (MEASURE_TYPE_ID=2607);
END;

--

/* ���������� �������� */ 

BEGIN
  UPDATE CHECKINGS SET MEASURE_TYPE_ID=2600 WHERE (MEASURE_TYPE_ID=2601);
END;

--

/* �������� �������� */ 

BEGIN
  DELETE FROM CHECKINGS WHERE (MEASURE_TYPE_ID=2602) OR (MEASURE_TYPE_ID=2603) OR (MEASURE_TYPE_ID=2604) OR (MEASURE_TYPE_ID=2607);  
END;

--

/* ���������� ��������� ����� */ 

BEGIN
  UPDATE ROUTE_POINTS SET PRIORITY=POINT_ID-4000 WHERE (POINT_ID>=4001) AND (POINT_ID<=4104);
END;

--

/* ���������� ��������� ����� */ 

BEGIN
  FOR INC IN (SELECT * FROM POINTS WHERE (POINT_ID>=4001) AND (POINT_ID<=4104)) LOOP
 	 IF (INC.NAME>=67) AND (INC.NAME<=100) THEN
	 	INSERT INTO POINT_PASSPORTS VALUES (GET_POINT_PASSPORT_ID, INC.POINT_ID, '21.08.2007', '�������������� �����: ������� ����');
	 END IF;
	 IF (INC.NAME>=54) AND (INC.NAME<=66) THEN
	 	INSERT INTO POINT_PASSPORTS VALUES (GET_POINT_PASSPORT_ID, INC.POINT_ID, '21.08.2007', '�������������� �����: ������� ������ � ���');
	 END IF;
	 IF (INC.NAME=101) THEN
	 	INSERT INTO POINT_PASSPORTS VALUES (GET_POINT_PASSPORT_ID, INC.POINT_ID, '21.08.2007', '�������������� �����: ������� ������ � ���');
	 END IF;
	 IF (INC.NAME>=29) AND (INC.NAME<=53) THEN
	 	INSERT INTO POINT_PASSPORTS VALUES (GET_POINT_PASSPORT_ID, INC.POINT_ID, '21.08.2007', '�������������� �����: ������� ����������');
	 END IF;
	 IF (INC.NAME>=6) AND (INC.NAME<=28) THEN
	 	INSERT INTO POINT_PASSPORTS VALUES (GET_POINT_PASSPORT_ID, INC.POINT_ID, '21.08.2007', '�������������� �����: ������� ��������� 1�� ����');
	 END IF;
	 IF (INC.NAME>=1) AND (INC.NAME<=5) THEN
	 	INSERT INTO POINT_PASSPORTS VALUES (GET_POINT_PASSPORT_ID, INC.POINT_ID, '21.08.2007', '�������������� �����: ������� ��������� 2�� ����');
	 END IF;
  END LOOP;
END;

--

/* ���������� ������� ������ */ 

BEGIN
  UPDATE CUTS SET CUT_ID=2600 WHERE CUT_ID=2601;
  UPDATE CUTS SET NAME='���������', DESCRIPTION='���� ����������', VIEW_NAME='S_HMZ_JOURNAL_OBSERVATIONS', PROC_NAME='R_HMZ_JOURNALS'
   WHERE CUT_ID=2600;
END;

--

/* �������� ������ */ 

BEGIN
  DELETE FROM CUTS WHERE (CUT_ID=2601) OR (CUT_ID=2602) OR (CUT_ID=2603) OR (CUT_ID=2604) OR (CUT_ID=2607);
END;

--

/* �������� ���������� � ����� ��������� */ 

BEGIN
  DELETE FROM MEASURE_TYPE_ALGORITHMS 
   WHERE (MEASURE_TYPE_ID=2601) OR (MEASURE_TYPE_ID=2602) OR (MEASURE_TYPE_ID=2603) OR (MEASURE_TYPE_ID=2604) OR (MEASURE_TYPE_ID=2607);
END;

--

/* �������� ���������� � ����� ��������� */ 

BEGIN
  DELETE FROM MEASURE_TYPE_PARAMS 
   WHERE (MEASURE_TYPE_ID=2601) OR (MEASURE_TYPE_ID=2602) OR (MEASURE_TYPE_ID=2603) OR (MEASURE_TYPE_ID=2604) OR (MEASURE_TYPE_ID=2607);
END;

--

/* �������� ����� ��������� */ 

BEGIN
  DELETE FROM MEASURE_TYPES 
   WHERE (MEASURE_TYPE_ID=2601) OR (MEASURE_TYPE_ID=2602) OR (MEASURE_TYPE_ID=2603) OR (MEASURE_TYPE_ID=2604) OR (MEASURE_TYPE_ID=2607);
END;

--

/* ���������� ���������� ���� ��������� */ 

BEGIN
  INSERT INTO MEASURE_TYPE_PARAMS VALUES (2600, 3060, 1);
  INSERT INTO MEASURE_TYPE_PARAMS VALUES (2600, 3061, 2);
  INSERT INTO MEASURE_TYPE_PARAMS VALUES (2600, 3062, 3);
  INSERT INTO MEASURE_TYPE_PARAMS VALUES (2600, 3063, 4);
  INSERT INTO MEASURE_TYPE_PARAMS VALUES (2600, 3065, 5);
  INSERT INTO MEASURE_TYPE_PARAMS VALUES (2600, 3066, 6);
  INSERT INTO MEASURE_TYPE_PARAMS VALUES (2600, 3067, 7);
  INSERT INTO MEASURE_TYPE_PARAMS VALUES (2600, 3068, 8);
  INSERT INTO MEASURE_TYPE_PARAMS VALUES (2600, 3069, 9);
  INSERT INTO MEASURE_TYPE_PARAMS VALUES (2600, 3070, 10);
  INSERT INTO MEASURE_TYPE_PARAMS VALUES (2600, 3071, 11);
  INSERT INTO MEASURE_TYPE_PARAMS VALUES (2600, 3072, 12);
  INSERT INTO MEASURE_TYPE_PARAMS VALUES (2600, 3100, 13);
END;

--

/* ���������� ���������� ���� ��������� */ 

BEGIN
  INSERT INTO MEASURE_TYPE_ALGORITHMS VALUES (2600, 2580, 1);
END;

--

/* �������� ��������� ����� */ 

COMMIT
