/* �������� ��������� ���������� �������� */

CREATE OR REPLACE VIEW S_DOC_CHECKUPS
AS 
SELECT DC.DOC_CHECKUP_ID,DC.JOURNAL_CHECKUP_ID,DC.DATE_DOC,DC.NAME,DC.DESCRIPTION,DC.DOC,DC.EXTENSION
  FROM DOC_CHECKUPS DC

--

/* �������� ��������� */

COMMIT


