program sqledit;

uses
  Forms,
  SgtsTableEditFrm in 'SgtsTableEditFrm.pas' {SgtsTableEditFrame: TFrame},
  SgtsTableNewFm in 'SgtsTableNewFm.pas' {SgtsTableNewForm},
  SgtsSqlEditFm in 'SgtsSqlEditFm.pas' {SgtsSqlEditForm};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := '�������� SQL ��������';
  Application.CreateForm(TSgtsSqlEditForm, SgtsSqlEditForm);
  Application.Run;
end.
