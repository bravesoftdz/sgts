program tbledit;

uses
  Forms,
  SgtsTableEditFm in 'SgtsTableEditFm.pas' {SgtsTableEditForm},
  SgtsTableNewFm in 'SgtsTableNewFm.pas' {SgtsTableNewForm},
  SgtsTableEditFrm in '..\sqledit.exe\SgtsTableEditFrm.pas' {SgtsTableEditFrame: TFrame},
  SgtsMemoFm in 'SgtsMemoFm.pas' {SgtsMemoForm};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := '�������� XML ������';
  Application.CreateForm(TSgtsTableEditForm, SgtsTableEditForm);
  Application.Run;
end.