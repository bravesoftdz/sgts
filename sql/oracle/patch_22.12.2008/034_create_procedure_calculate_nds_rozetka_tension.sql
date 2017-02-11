/* �������� ��������� ������� ���������� �� ������� */

CREATE OR REPLACE PROCEDURE CALCULATE_NDS_ROZETKA_TENSION
(
  POINT_ID IN INTEGER,
  ROZETKA IN INTEGER,
  DATE_OBSERVATION IN DATE,
  MEASURE_TYPE_ID IN INTEGER,
  CYCLE_ID IN INTEGER,
  IS_BASE IN INTEGER,
  TENSION_V_B IN FLOAT,
  TENSION_G_B IN FLOAT,
  TENSION_PR_B IN FLOAT,
  TENSION_V OUT FLOAT,
  TENSION_G OUT FLOAT,
  TENSION_PR OUT FLOAT
)
AS
  DEFORMATION_V FLOAT;
  DEFORMATION_G FLOAT;
  DEFORMATION_PR FLOAT;
  DEFORMATION_V_B FLOAT;
  DEFORMATION_G_B FLOAT;
  DEFORMATION_PR_B FLOAT;
  D_DEFORMATION_V FLOAT;
  D_DEFORMATION_G FLOAT;
  D_DEFORMATION_PR FLOAT;
  DD_DEFORMATION_V FLOAT;
  DD_DEFORMATION_G FLOAT;
  DD_DEFORMATION_PR FLOAT;
  D_TENSION_V FLOAT;
  D_TENSION_G FLOAT;
  D_TENSION_PR FLOAT;
  D_TENSION_V_B FLOAT;
  D_TENSION_G_B FLOAT;
  D_TENSION_PR_B FLOAT;
  POINT_ID_V INTEGER;
  POINT_ID_G INTEGER;
  POINT_ID_PR INTEGER;
  POINT_ID_V_B INTEGER;
  POINT_ID_G_B INTEGER;
  POINT_ID_PR_B INTEGER;
  MODULE FLOAT;
  POINT_NAME INTEGER;
  D_V FLOAT;
  D_G FLOAT;
  D_PR FLOAT;
BEGIN

  SELECT NAME INTO POINT_NAME FROM POINTS WHERE POINT_ID=CALCULATE_NDS_ROZETKA_TENSION.POINT_ID;
/*  DBMS_OUTPUT.PUT_LINE('POINT_NAME='||TO_CHAR(POINT_NAME));			
  DBMS_OUTPUT.PUT_LINE('DATE='||TO_CHAR(DATE_OBSERVATION));			
  			
  DBMS_OUTPUT.PUT_LINE('1.TIME='||TO_CHAR(SYSDATE,'DD.MM.YYYY HH24:MI:SS'));*/
  			
  CALCULATE_NDS_ROZETKA_DEFORM(ROZETKA,DATE_OBSERVATION,MEASURE_TYPE_ID,CYCLE_ID,IS_BASE,
	                           DEFORMATION_V,DEFORMATION_G,DEFORMATION_PR,
						       POINT_ID_V,POINT_ID_G,POINT_ID_PR);

/*  DBMS_OUTPUT.PUT_LINE('2.TIME='||TO_CHAR(SYSDATE,'DD.MM.YYYY HH24:MI:SS'));
  DBMS_OUTPUT.PUT_LINE('DEFORMATION_V='||TO_CHAR(DEFORMATION_V));			
  DBMS_OUTPUT.PUT_LINE('DEFORMATION_G='||TO_CHAR(DEFORMATION_G));			
  DBMS_OUTPUT.PUT_LINE('DEFORMATION_PR='||TO_CHAR(DEFORMATION_PR));*/			
						
  DEFORMATION_V_B:=0.0;			
  DEFORMATION_G_B:=0.0;			
  DEFORMATION_PR_B:=0.0;

  FOR INC IN (SELECT T.DATE_OBSERVATION 
                FROM (SELECT JF.DATE_OBSERVATION, COUNT(*) AS CT
	                    FROM JOURNAL_FIELDS JF
	   		           WHERE JF.MEASURE_TYPE_ID=CALCULATE_NDS_ROZETKA_TENSION.MEASURE_TYPE_ID
				         AND JF.IS_BASE=CALCULATE_NDS_ROZETKA_TENSION.IS_BASE
				         AND JF.POINT_ID IN (POINT_ID_V)
				         AND JF.DATE_OBSERVATION<CALCULATE_NDS_ROZETKA_TENSION.DATE_OBSERVATION
				         AND JF.WHO_CONFIRM IS NOT NULL
				         AND JF.DATE_CONFIRM IS NOT NULL
				         AND JF.VALUE<>0.0
				         AND JF.PARAM_ID IN (60003) /* ������� */
				       GROUP BY JF.DATE_OBSERVATION) T
               WHERE T.CT>=1					    	 
			   ORDER BY T.DATE_OBSERVATION DESC) LOOP
						  
/*    DBMS_OUTPUT.PUT_LINE('DATE_B='||TO_CHAR(INC.DATE_OBSERVATION));*/
	 						  
/*    DBMS_OUTPUT.PUT_LINE('3.TIME='||TO_CHAR(SYSDATE,'DD.MM.YYYY HH24:MI:SS'));*/
	
    CALCULATE_NDS_ROZETKA_DEFORM(ROZETKA,INC.DATE_OBSERVATION,MEASURE_TYPE_ID,CYCLE_ID,IS_BASE,
	                             DEFORMATION_V_B,DEFORMATION_G_B,DEFORMATION_PR_B,
							     POINT_ID_V_B,POINT_ID_G_B,POINT_ID_PR_B);
							  
    EXIT;						  
  END LOOP;

/*  DBMS_OUTPUT.PUT_LINE('DEFORMATION_V_B='||TO_CHAR(DEFORMATION_V_B));			
  DBMS_OUTPUT.PUT_LINE('DEFORMATION_G_B='||TO_CHAR(DEFORMATION_G_B));			
  DBMS_OUTPUT.PUT_LINE('DEFORMATION_PR_B='||TO_CHAR(DEFORMATION_PR_B));*/
				
  D_DEFORMATION_V:=DEFORMATION_V-DEFORMATION_V_B;
  D_DEFORMATION_G:=DEFORMATION_G-DEFORMATION_G_B;
  D_DEFORMATION_PR:=DEFORMATION_PR-DEFORMATION_PR_B;

/*  DBMS_OUTPUT.PUT_LINE('D_DEFORMATION_V='||TO_CHAR(D_DEFORMATION_V));			
  DBMS_OUTPUT.PUT_LINE('D_DEFORMATION_G='||TO_CHAR(D_DEFORMATION_G));			
  DBMS_OUTPUT.PUT_LINE('D_DEFORMATION_PR='||TO_CHAR(D_DEFORMATION_PR));*/
  
  D_V:=D_DEFORMATION_V;
  D_G:=D_DEFORMATION_G;
  D_PR:=D_DEFORMATION_PR;

  IF (D_G IS NULL) THEN
    D_G:=0.0;
  END IF;
  
  IF (D_PR IS NULL) THEN
    D_PR:=0.0;
  END IF;
  
  DD_DEFORMATION_V:=0.86*D_DEFORMATION_V+0.2*(D_V+D_G+D_PR);    
  DD_DEFORMATION_G:=0.86*D_DEFORMATION_G+0.2*(D_V+D_G+D_PR);
  DD_DEFORMATION_PR:=0.86*D_DEFORMATION_PR+0.2*(D_V+D_G+D_PR);

/*  DBMS_OUTPUT.PUT_LINE('DD_DEFORMATION_V='||TO_CHAR(DD_DEFORMATION_V));			
  DBMS_OUTPUT.PUT_LINE('DD_DEFORMATION_G='||TO_CHAR(DD_DEFORMATION_G));			
  DBMS_OUTPUT.PUT_LINE('DD_DEFORMATION_PR='||TO_CHAR(DD_DEFORMATION_PR));*/			

  D_TENSION_V_B:=TENSION_V_B;
  D_TENSION_G_B:=TENSION_G_B;
  D_TENSION_PR_B:=TENSION_PR_B;

/*  DBMS_OUTPUT.PUT_LINE('D_TENSION_V_B='||TO_CHAR(D_TENSION_V_B));			
  DBMS_OUTPUT.PUT_LINE('D_TENSION_G_B='||TO_CHAR(D_TENSION_G_B));			
  DBMS_OUTPUT.PUT_LINE('D_TENSION_PR_B='||TO_CHAR(D_TENSION_PR_B));*/			
  
/*  DBMS_OUTPUT.PUT_LINE('4.TIME='||TO_CHAR(SYSDATE,'DD.MM.YYYY HH24:MI:SS'));*/
  
  CALCULATE_NDS_MODULE_CONCRETE(POINT_ID_V,DATE_OBSERVATION,MODULE);  

/*  DBMS_OUTPUT.PUT_LINE('5.TIME='||TO_CHAR(SYSDATE,'DD.MM.YYYY HH24:MI:SS'));*/
  			
  D_TENSION_V:=D_TENSION_V_B+DD_DEFORMATION_V*MODULE*0.0981;
  D_TENSION_G:=D_TENSION_G_B+DD_DEFORMATION_G*MODULE*0.0981;
  D_TENSION_PR:=D_TENSION_PR_B+DD_DEFORMATION_PR*MODULE*0.0981;

/*  DBMS_OUTPUT.PUT_LINE('D_TENSION_V='||TO_CHAR(D_TENSION_V));			
  DBMS_OUTPUT.PUT_LINE('D_TENSION_G='||TO_CHAR(D_TENSION_G));			
  DBMS_OUTPUT.PUT_LINE('D_TENSION_PR='||TO_CHAR(D_TENSION_PR));*/

  TENSION_V:=D_TENSION_V;
  TENSION_G:=D_TENSION_G;
  TENSION_PR:=D_TENSION_PR;
  
END;

--

/* �������� ��������� �� */

COMMIT