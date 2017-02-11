; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

[Setup]
AppName=����
AppVerName=���� 1.0
DefaultDirName={pf}\����
DefaultGroupName=����
OutputDir=U:\install\Output
OutputBaseFilename=sgts_oracle
Compression=lzma
SolidCompression=yes

[Languages]
Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "U:\install\oracle\adortl70.bpl"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle\core.bpl"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle\dbrtl70.bpl"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle\designide70.bpl"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle\dsnap70.bpl"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle\indy70.bpl"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle\report.bpl"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle\rtl70.bpl"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle\tee70.bpl"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle\teedb70.bpl"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle\teeui70.bpl"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle\vcl70.bpl"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle\vclactnband70.bpl"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle\vcldb70.bpl"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle\vcljpg70.bpl"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle\vclsmp70.bpl"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle\vclx70.bpl"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle\install.cmd"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle\uninstall.cmd"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle\kgesgraphs.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle\midas.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle\oraado.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle\sgts.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle\sgts.ini"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle\sgtsrd.ini"; DestDir: "{app}"; Flags: ignoreversion

Source: "U:\install\oracle\JOURNAL_FIELDS_0000001_0100000.que"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle\JOURNAL_FIELDS_0100001_0200000.que"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle\JOURNAL_FIELDS_0200001_0300000.que"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle\JOURNAL_FIELDS_0300001_0400000.que"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle\JOURNAL_FIELDS_0400001_0500000.que"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle\JOURNAL_FIELDS_0500001_0600000.que"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle\JOURNAL_FIELDS_0600001_0650000.que"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle\JOURNAL_FIELDS_0650001_0700000.que"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle\JOURNAL_FIELDS_0700001_0800000.que"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle\JOURNAL_FIELDS_0800001_0900000.que"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle\JOURNAL_FIELDS_0900001_1000000.que"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle\JOURNAL_FIELDS_1000001_1100000.que"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle\JOURNAL_FIELDS_1100001_1200000.que"; DestDir: "{app}"; Flags: ignoreversion

Source: "U:\install\oracle\JOURNAL_OBSERVATIONS_0000001_0100000.que"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle\JOURNAL_OBSERVATIONS_0100001_0200000.que"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle\JOURNAL_OBSERVATIONS_0200001_0300000.que"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle\JOURNAL_OBSERVATIONS_0300001_0400000.que"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle\JOURNAL_OBSERVATIONS_0400001_0500000.que"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle\JOURNAL_OBSERVATIONS_0500001_0600000.que"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle\JOURNAL_OBSERVATIONS_0600001_0700000.que"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle\JOURNAL_OBSERVATIONS_0700001_0800000.que"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle\JOURNAL_OBSERVATIONS_0800001_0900000.que"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle\JOURNAL_OBSERVATIONS_0900001_1000000.que"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle\JOURNAL_OBSERVATIONS_1000001_1100000.que"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle\JOURNAL_OBSERVATIONS_1100001_1200000.que"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle\JOURNAL_OBSERVATIONS_1200001_1300000.que"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle\JOURNAL_OBSERVATIONS_1300001_1400000.que"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle\JOURNAL_OBSERVATIONS_1400001_1500000.que"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle\JOURNAL_OBSERVATIONS_1500001_1600000.que"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle\JOURNAL_OBSERVATIONS_1600001_1700000.que"; DestDir: "{app}"; Flags: ignoreversion

Source: "U:\install\oracle\install.que"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle\uninstall.que"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle\rtl70.rus"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle\vcl70.rus"; DestDir: "{app}"; Flags: ignoreversion
Source: "U:\install\oracle\vcldb70.rus"; DestDir: "{app}"; Flags: ignoreversion
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{group}\����"; Filename: "{app}\sgts.exe"
Name: "{group}\{cm:UninstallProgram,����}"; Filename: "{uninstallexe}"
Name: "{userdesktop}\����"; Filename: "{app}\sgts.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\sgts.exe"; Description: "{cm:LaunchProgram,����}"; Flags: nowait postinstall skipifsilent

[Code]

procedure CurStepChanged(CurStep: TSetupStep);
var
  ResultCode: Integer;
begin
  case CurStep of
    ssPostInstall: begin
      Exec(ExpandConstant('{sys}\regsvr32.exe'), ExpandConstant('"{app}\midas.dll" /s'), '', SW_SHOWNORMAL, ewWaitUntilTerminated, ResultCode);
      if MsgBox('���������� SQL ������� ��� ���� ������?', mbConfirmation, MB_YESNO) = idYes then begin
        if not Exec(ExpandConstant('{app}\sgts.exe'), '/install_sql install.que OracleSgts', '', SW_SHOWNORMAL, ewWaitUntilTerminated, ResultCode) then
          MsgBox(SysErrorMessage(ResultCode) + '.', mbError, MB_OK);
      end;
(*      if MsgBox('���������� SQL ������� ��� �������� ���� ������?', mbConfirmation, MB_YESNO) = idYes then begin
        if not Exec(ExpandConstant('{app}\sgts.exe'), '/install_sql install.que OracleTest', '', SW_SHOWNORMAL, ewWaitUntilTerminated, ResultCode) then
          MsgBox(SysErrorMessage(ResultCode) + '.', mbError, MB_OK);
      end;*)
      BringToFrontAndRestore();
    end;
  end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  ResultCode: Integer;
begin
  case CurUninstallStep of
    usUninstall: begin
      Exec(ExpandConstant('{sys}\regsvr32.exe'), ExpandConstant('"{app}\midas.dll" /s'), '', SW_SHOWNORMAL, ewWaitUntilTerminated, ResultCode);
      if MsgBox('������� SQL ������� ��� ���� ������?', mbConfirmation, MB_YESNO) = idYes then begin
        if not Exec(ExpandConstant('{app}\sgts.exe'), '/uninstall_sql uninstall.que OracleSgts', '', SW_SHOWNORMAL, ewWaitUntilTerminated, ResultCode) then
          MsgBox(SysErrorMessage(ResultCode) + '.', mbError, MB_OK);
      end;
(*      if MsgBox('������� SQL ������� ��� �������� ���� ������?', mbConfirmation, MB_YESNO) = idYes then begin
        if not Exec(ExpandConstant('{app}\sgts.exe'), '/uninstall_sql uninstall.que OracleTest', '', SW_SHOWNORMAL, ewWaitUntilTerminated, ResultCode) then
          MsgBox(SysErrorMessage(ResultCode) + '.', mbError, MB_OK);
      end;*)
      Exec(ExpandConstant('{sys}\regsvr32.exe'), ExpandConstant('"{app}\midas.dll" /u /s'), '', SW_SHOWNORMAL, ewWaitUntilTerminated, ResultCode);
      BringToFrontAndRestore();
    end;
  end;
end;

