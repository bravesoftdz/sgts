/* �������� ��������� ���������� ������ � ������� �������� */

CREATE OR REPLACE PROCEDURE I_JOURNAL_ACTION
( 
  JOURNAL_ACTION_ID IN INTEGER, 
  PERSONNEL_ID IN INTEGER, 
  DATE_ACTION IN DATE,  
  OBJECT IN VARCHAR2, 
  METHOD IN VARCHAR2, 
  PARAM IN VARCHAR2, 
  VALUE IN CLOB 
) 
AS 
  AJOURNAL_ACTION_ID INTEGER; 
BEGIN 
  AJOURNAL_ACTION_ID:=JOURNAL_ACTION_ID; 
  IF (AJOURNAL_ACTION_ID IS NULL) THEN 
    AJOURNAL_ACTION_ID:=GET_JOURNAL_ACTION_ID; 
  END IF; 
  INSERT INTO JOURNAL_ACTIONS (JOURNAL_ACTION_ID,DATE_ACTION,PERSONNEL_ID,OBJECT,METHOD,PARAM,VALUE) 
       VALUES (AJOURNAL_ACTION_ID,DATE_ACTION,PERSONNEL_ID,OBJECT,METHOD,PARAM,VALUE); 
  COMMIT; 
END;

--

/* �������� ��������� */

COMMIT
