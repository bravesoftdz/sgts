/* �������� ������� ��������� �������� ��������� ���������� � ���� */

CREATE OR REPLACE FUNCTION GET_VALUE_NEAR_DATE (PO_ID INTEGER, PA_ID INTEGER, DATA DATE) RETURN FLOAT IS    RES FLOAT;

D1 DATE;
D2 DATE;
ITER INTEGER;
J_ID_LAST INTEGER;
J_ID_NEXT INTEGER;
FLAG BOOLEAN;
R1 INTEGER;
R2 INTEGER;

BEGIN
	 ITER:=1;
	 FLAG:=FALSE;
	 FOR INC IN (SELECT JOURNAL_OBSERVATION_ID, DATE_OBSERVATION, VALUE FROM JOURNAL_OBSERVATIONS WHERE POINT_ID=PO_ID AND PARAM_ID=PA_ID ORDER BY DATE_OBSERVATION) LOOP

		 IF ITER=1 THEN
		 	IF INC.DATE_OBSERVATION>=DATA THEN
			   FLAG:=TRUE;
			   RES:=INC.VALUE;
			   RETURN RES;
			ELSE
		 		J_ID_LAST:=INC.JOURNAL_OBSERVATION_ID;
			END IF;
		 END IF;

		 IF ITER<>1 AND FLAG=FALSE THEN
		 	IF INC.DATE_OBSERVATION>=DATA THEN
			   SELECT DATE_OBSERVATION INTO D1 FROM JOURNAL_OBSERVATIONS WHERE JOURNAL_OBSERVATION_ID=J_ID_LAST;
			   D2:=INC.DATE_OBSERVATION;
			   R1:=DATA-D1;
			   R2:=D2-DATA;
			   IF R2<R1 THEN
			   	  SELECT VALUE INTO RES FROM JOURNAL_OBSERVATIONS WHERE JOURNAL_OBSERVATION_ID=INC.JOURNAL_OBSERVATION_ID;
				  RETURN RES;
			   	  FLAG:=TRUE;
			   END IF;
			   IF R2>=R1 THEN
			   	  SELECT VALUE INTO RES FROM JOURNAL_OBSERVATIONS WHERE JOURNAL_OBSERVATION_ID=J_ID_LAST;
				  RETURN RES;
			   	  FLAG:=TRUE;
			   END IF;
			ELSE
				J_ID_LAST:=INC.JOURNAL_OBSERVATION_ID;
			END IF;
		 END IF;

		 ITER:=ITER+1;

	 END LOOP;
END;

--

/* �������� ��������� �� */

COMMIT