inherited SgtsRbkPermissionEditForm: TSgtsRbkPermissionEditForm
  Left = 445
  Top = 245
  Width = 550
  Height = 225
  Caption = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1085#1080#1077' '#1087#1088#1072#1074#1072
  Constraints.MinHeight = 225
  Constraints.MinWidth = 550
  PixelsPerInch = 96
  TextHeight = 13
  inherited StatusBar: TStatusBar
    Top = 160
    Width = 542
  end
  inherited ToolBar: TToolBar
    Height = 121
  end
  inherited PanelEdit: TPanel
    Width = 507
    Height = 121
    object LabelInterface: TLabel
      Left = 47
      Top = 46
      Width = 60
      Height = 13
      Alignment = taRightJustify
      Caption = #1048#1085#1090#1077#1088#1092#1077#1081#1089':'
      FocusControl = ComboBoxInterface
    end
    object LabelAccount: TLabel
      Left = 23
      Top = 12
      Width = 83
      Height = 26
      Alignment = taRightJustify
      Caption = #1059#1095#1077#1090#1085#1072#1103' '#1079#1072#1087#1080#1089#1100' ('#1088#1086#1083#1100'):'
      FocusControl = EditAccount
      WordWrap = True
    end
    object LabelPermission: TLabel
      Left = 7
      Top = 72
      Width = 99
      Height = 13
      Alignment = taRightJustify
      Caption = #1055#1088#1072#1074#1086' '#1080#1085#1090#1077#1088#1092#1077#1081#1089#1072':'
      FocusControl = ComboBoxPermission
    end
    object LabelValue: TLabel
      Left = 54
      Top = 98
      Width = 52
      Height = 13
      Alignment = taRightJustify
      Caption = #1047#1085#1072#1095#1077#1085#1080#1077':'
      FocusControl = ComboBoxValue
    end
    object EditAccount: TEdit
      Left = 114
      Top = 16
      Width = 191
      Height = 21
      Color = clBtnFace
      ReadOnly = True
      TabOrder = 0
    end
    object ButtonAccount: TButton
      Left = 310
      Top = 16
      Width = 21
      Height = 21
      Hint = #1042#1099#1073#1088#1072#1090#1100' '#1091#1095#1077#1090#1085#1091#1102' '#1079#1072#1087#1080#1089#1100' ('#1088#1086#1083#1100')'
      Caption = '...'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
    end
    object ComboBoxInterface: TComboBox
      Left = 114
      Top = 42
      Width = 383
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      Sorted = True
      TabOrder = 2
      OnChange = ComboBoxInterfaceChange
    end
    object ComboBoxPermission: TComboBox
      Left = 114
      Top = 68
      Width = 239
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 3
      OnChange = ComboBoxPermissionChange
    end
    object ComboBoxValue: TComboBox
      Left = 114
      Top = 94
      Width = 119
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 4
    end
  end
  inherited PanelButton: TPanel
    Top = 121
    Width = 542
    inherited ButtonCancel: TButton
      Left = 461
    end
    inherited ButtonOk: TButton
      Left = 379
    end
  end
  inherited MainMenu: TMainMenu
    Left = 48
    Top = 112
  end
  inherited ImageList: TImageList
    Left = 88
    Top = 114
  end
end
