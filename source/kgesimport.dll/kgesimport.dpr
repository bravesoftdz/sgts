library kgesimport;

{$R *.res}
                           
uses
  SgtsFm in '..\core.bpl\SgtsFm.pas' {SgtsForm},
  SgtsChildFm in '..\core.bpl\SgtsChildFm.pas' {SgtsChildForm},
  SgtsDataFm in '..\core.bpl\SgtsDataFm.pas' {SgtsDataForm},
  SgtsDataEditFm in '..\core.bpl\SgtsDataEditFm.pas' {SgtsDataEditForm},
  SgtsDataGridFm in '..\core.bpl\SgtsDataGridFm.pas' {SgtsDataGridForm},
  SgtsKgesImport in 'SgtsKgesImport.pas',
  SgtsKgesImportInterface in 'SgtsKgesImportInterface.pas',
  SgtsKgesASQImportFm in 'SgtsKgesASQImportFm.pas' {SgtsKgesASQImportForm},
  MDBFTable in '..\imports\MitecDbf\MDBFTable.pas';

exports
  InitInterface;
      
begin
end.
