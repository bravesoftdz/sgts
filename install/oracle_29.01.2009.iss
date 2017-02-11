; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define AppBinDir "oracle_29.01.2009"
#define AppBin SourcePath+"\"+AppBinDir
#define AppVersion GetFileVersion(AppBin+"\sgts.exe")
#define AppName "����"
#define AppPublisher "DMD"
#define OutputDir SourcePath+"\_output"
#define HistoryFile AppBin+"\history.rtf"
#define ReadmeFile AppBin+"\readme.rtf"

[Setup]
AppName={#AppName}
AppVerName={#AppName} {#AppVersion}
AppPublisher={#AppPublisher}
DefaultDirName={pf}\{#AppName}
DefaultGroupName={#AppName}
OutputDir={#OutputDir}
OutputBaseFilename=sgts_{#AppBinDir}
InfoAfterFile={#HistoryFile}
InfoBeforeFile={#ReadmeFile}
Compression=lzma/ultra
SolidCompression=yes
InternalCompressLevel=ultra
VersionInfoVersion={#AppVersion}
VersionInfoCompany={#AppPublisher}
VersionInfoDescription={#AppName} Setup
VersionInfoTextVersion={#AppVersion}
VersionInfoCopyright={#AppPublisher}
MinVersion=4.0.950,5.0.2195
AppCopyright={#AppPublisher}
AppMutex=DMD_sgts
EnableDirDoesntExistWarning=true
AppVersion={#AppVersion}
UninstallDisplayName={#AppName} {#AppVersion}
UserInfoPage=true
PrivilegesRequired=admin


[Languages]
Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"

[Types]
Name: full; Description: ������ ���������; Flags: iscustom

[Files]
Source: {#AppBin}\core.bpl; DestDir: {app}; Flags: replacesameversion; Components: client
Source: {#AppBin}\dbrtl100.bpl; DestDir: {app}; Flags: replacesameversion; Components: client
Source: {#AppBin}\dsnap100.bpl; DestDir: {app}; Flags: replacesameversion; Components: client
Source: {#AppBin}\objects.bpl; DestDir: {app}; Flags: replacesameversion; Components: client
Source: {#AppBin}\report.bpl; DestDir: {app}; Flags: replacesameversion; Components: client
Source: {#AppBin}\rtl100.bpl; DestDir: {app}; Flags: replacesameversion; Components: client
Source: {#AppBin}\tee7100.bpl; DestDir: {app}; Flags: replacesameversion; Components: client
Source: {#AppBin}\teedb7100.bpl; DestDir: {app}; Flags: replacesameversion; Components: client
Source: {#AppBin}\teeui7100.bpl; DestDir: {app}; Flags: replacesameversion; Components: client
Source: {#AppBin}\vcl100.bpl; DestDir: {app}; Flags: replacesameversion; Components: client
Source: {#AppBin}\vcldb100.bpl; DestDir: {app}; Flags: replacesameversion; Components: client
Source: {#AppBin}\vcljpg100.bpl; DestDir: {app}; Flags: replacesameversion; Components: client
Source: {#AppBin}\vclsmp100.bpl; DestDir: {app}; Flags: replacesameversion; Components: client
Source: {#AppBin}\vclx100.bpl; DestDir: {app}; Flags: replacesameversion; Components: client
Source: {#AppBin}\install.cmd; DestDir: {app}; Flags: replacesameversion; Components: client
Source: {#AppBin}\noprofile.cmd; DestDir: {app}; Flags: replacesameversion; Components: client
Source: {#AppBin}\uninstall.cmd; DestDir: {app}; Flags: replacesameversion; Components: client
Source: {#AppBin}\kgesimport.dll; DestDir: {app}; Flags: replacesameversion; Components: client
Source: {#AppBin}\midas.dll; DestDir: {app}; Flags: replacesameversion; Components: client
Source: {#AppBin}\oraado.dll; DestDir: {app}; Flags: replacesameversion; Components: client
Source: {#AppBin}\plan.dll; DestDir: {app}; Flags: replacesameversion; Components: client
Source: {#AppBin}\help.doc; DestDir: {app}; Flags: ignoreversion; Components: client
Source: {#AppBin}\sgts.exe; DestDir: {app}; Flags: replacesameversion; Components: client
Source: {#AppBin}\sgts.ini; DestDir: {app}; Flags: ignoreversion; Components: client
Source: {#AppBin}\sgtsrd.ini; DestDir: {app}; Flags: ignoreversion; Components: client
Source: {#AppBin}\splash.jpg; DestDir: {app}; Flags: ignoreversion; Components: client
Source: {#HistoryFile}; DestDir: {app}; Flags: ignoreversion; DestName: history.rtf; Components: client
Source: {#ReadmeFile}; DestDir: {app}; Flags: ignoreversion; DestName: readme.rtf; Components: client
Source: {#AppBin}\vcl100.rus; DestDir: {app}; Flags: replacesameversion; Components: client
Source: {#AppBin}\vcldb100.rus; DestDir: {app}; Flags: replacesameversion; Components: client
Source: {#AppBin}\providers.txt; DestDir: {app}; Flags: ignoreversion; Components: client

[Components]
Name: client; Description: ��������� {#AppName} {#AppVersion}; Types: full; Flags: fixed

[Icons]
Name: {userprograms}\{#AppName}\���������; Filename: {app}\sgts.exe; WorkingDir: {app}; IconFilename: {app}\sgts.exe; Comment: ��������� {#AppName} {#AppVersion}; IconIndex: 0; Components: client
Name: {userprograms}\{#AppName}\����������� �����������; Filename: {app}\help.doc; WorkingDir: {app}; IconFilename: {app}\help.doc; Comment: ����������� ����������� {#AppName} {#AppVersion}; Components: client
Name: {userprograms}\{#AppName}\�������; Filename: {app}\history.rtf; WorkingDir: {app}; IconFilename: {app}\history.rtf; Comment: ������� {#AppName} {#AppVersion}; Components: client
Name: {userprograms}\{#AppName}\�������; Filename: {uninstallexe}; WorkingDir: {app}; IconFilename: {uninstallexe}; Comment: ������� {#AppName} {#AppVersion}; Components: client
Name: {userdesktop}\{#AppName}; Filename: {app}\sgts.exe; WorkingDir: {app}; IconFilename: {app}\sgts.exe; Comment: {#AppName} {#AppVersion}; IconIndex: 0; Components: client

[Run]
Filename: {sys}\regsvr32.exe; Parameters: {app}\midas.dll /s; WorkingDir: {sys}; Flags: runhidden waituntilidle; Components: client
Filename: {app}\sgts.exe; WorkingDir: {app}; Flags: nowait postinstall skipifsilent; Components: client; Description: ��������� {#AppName}


[UninstallRun]
Filename: {sys}\regsvr32.exe; Parameters: {app}\midas.dll /u /s; WorkingDir: {sys}; Flags: runhidden waituntilidle; Components: client


[Code]
var
  PageUpdate: TWizardPage;
  LabelUser: TLabel;
  EditUser: TEdit;
  LabelPass: TLabel;
  EditPass: TPasswordEdit;
  LabelBase: TLabel;
  EditBase: TEdit;

function PageUpdateCreatePage(PreviousPageId: Integer): Integer;
begin
  PageUpdate := CreateCustomPage(PreviousPageId,
                                 '����������� ���� ������ �� ���������',
                                 '����������, ������� ������ ��� �����������.');

  LabelBase := TLabel.Create(PageUpdate);
  with LabelBase do
  begin
    Parent := PageUpdate.Surface;
    Caption := '���� ������:';
    Left := ScaleX(50);
    Top := ScaleY(56);
    Width := ScaleX(183);
    Height := ScaleY(13);
    FocusControl := EditBase;
  end;

  EditBase := TEdit.Create(PageUpdate);
  with EditBase do
  begin
    Parent := PageUpdate.Surface;
    Left := ScaleX(125);
    Top :=  ScaleY(52);
    Width := ScaleX(269);
    Height := ScaleY(21);
    Text:='SGTS';
    TabOrder := 0;
  end;

  LabelUser := TLabel.Create(PageUpdate);
  with LabelUser do
  begin
    Parent := PageUpdate.Surface;
    Caption :='������������ ��:';
    Left := ScaleX(23);
    Top := ScaleY(90);
    Width := ScaleX(94);
    Height := ScaleY(13);
    Alignment := taRightJustify;
    FocusControl := EditUser;
  end;

  EditUser := TEdit.Create(PageUpdate);
  with EditUser do
  begin
    Parent := PageUpdate.Surface;
    Left := ScaleX(125);
    Top := ScaleY(86);
    Width := ScaleX(100);
    Height := ScaleY(21);
    Text:='SGTS';
    TabOrder := 1;
  end;

  LabelPass := TLabel.Create(PageUpdate);
  with LabelPass do
  begin
    Parent := PageUpdate.Surface;
    Caption := '������:';
    Left := ScaleX(244);
    Top := ScaleY(90);
    Width := ScaleX(41);
    Height := ScaleY(13);
    Alignment := taRightJustify;
    FocusControl := EditPass;
  end;

  EditPass := TPasswordEdit.Create(PageUpdate);
  with EditPass do
  begin
    Parent := PageUpdate.Surface;
    Left := ScaleX(294);
    Top := ScaleY(86);
    Width := ScaleX(100);
    Height := ScaleY(21);
    TabOrder := 2;
  end;

  Result := PageUpdate.ID;
end;

procedure InitializeWizard();
begin
  PageUpdateCreatePage(wpSelectComponents);
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  IniFile: String;
  ConnectionString: String;
//  ResultCode: Integer;
//  Params: String;
begin
  case CurStep of
    ssPostInstall: begin
      IniFile:=ExpandConstant('{app}\sgts.ini');
      if FileExists(IniFile) then begin
        ConnectionString:=GetIniString('OracleSgts','ConnectionString','',IniFile);
        StringChange(ConnectionString,'%DATA_SOURCE',EditBase.Text);
        StringChange(ConnectionString,'%USER_NAME',EditUser.Text);
        StringChange(ConnectionString,'%PASSWORD',EditPass.Text);
        SetIniString('OracleSgts','ConnectionString',ConnectionString,IniFile);
      end;
      
      BringToFrontAndRestore();
    end;
  end;
end;

