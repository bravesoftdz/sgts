inherited SgtsRbkCriteriaEditForm: TSgtsRbkCriteriaEditForm
  Left = 413
  Top = 314
  BorderStyle = bsSizeable
  Caption = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1085#1080#1077' '#1082#1088#1080#1090#1077#1088#1080#1103
  ClientHeight = 311
  ClientWidth = 461
  Constraints.MaxHeight = 400
  Constraints.MinHeight = 210
  Constraints.MinWidth = 310
  ExplicitLeft = 413
  ExplicitTop = 314
  ExplicitWidth = 469
  ExplicitHeight = 357
  PixelsPerInch = 96
  TextHeight = 13
  inherited StatusBar: TStatusBar
    Top = 292
    Width = 461
    ExplicitTop = 265
    ExplicitWidth = 352
  end
  inherited ToolBar: TToolBar
    Height = 253
    ExplicitHeight = 230
  end
  inherited PanelEdit: TPanel
    Width = 426
    Height = 253
    ExplicitLeft = 27
    ExplicitTop = 2
    ExplicitWidth = 317
    ExplicitHeight = 226
    object LabelName: TLabel
      Left = 26
      Top = 14
      Width = 77
      Height = 13
      Alignment = taRightJustify
      Caption = #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077':'
      FocusControl = EditName
    end
    object LabelDescription: TLabel
      Left = 50
      Top = 40
      Width = 53
      Height = 13
      Alignment = taRightJustify
      Caption = #1054#1087#1080#1089#1072#1085#1080#1077':'
      FocusControl = MemoDescription
    end
    object LabelPriority: TLabel
      Left = 55
      Top = 221
      Width = 48
      Height = 13
      Alignment = taRightJustify
      Caption = #1055#1086#1088#1103#1076#1086#1082':'
      FocusControl = EditPriority
    end
    object LabelAlgorithm: TLabel
      Left = 52
      Top = 113
      Width = 52
      Height = 13
      Alignment = taRightJustify
      Caption = #1040#1083#1075#1086#1088#1080#1090#1084':'
      FocusControl = EditAlgorithm
    end
    object LabelFirstMinValue: TLabel
      Left = 65
      Top = 140
      Width = 38
      Height = 13
      Alignment = taRightJustify
      Caption = #1050'1 '#1084#1080#1085':'
      FocusControl = EditFirstMinValue
    end
    object LabelFirstMaxValue: TLabel
      Left = 189
      Top = 140
      Width = 42
      Height = 13
      Alignment = taRightJustify
      Caption = 'K1 '#1084#1072#1082#1089':'
      FocusControl = EditFirstMaxValue
    end
    object LabelSecondMinValue: TLabel
      Left = 65
      Top = 167
      Width = 38
      Height = 13
      Alignment = taRightJustify
      Caption = #1050'2 '#1084#1080#1085':'
      FocusControl = EditSecondMinValue
    end
    object LabelSecondMaxValue: TLabel
      Left = 189
      Top = 167
      Width = 42
      Height = 13
      Alignment = taRightJustify
      Caption = 'K2 '#1084#1072#1082#1089':'
      FocusControl = EditSecondMaxValue
    end
    object LabelMeasureUnit: TLabel
      Left = 2
      Top = 194
      Width = 103
      Height = 13
      Alignment = taRightJustify
      Caption = #1045#1076#1080#1085#1080#1094#1072' '#1080#1079#1084#1077#1088#1077#1085#1080#1103':'
      FocusControl = EditMeasureUnit
    end
    object EditName: TEdit
      Left = 109
      Top = 11
      Width = 306
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
      Text = #1053#1086#1074#1099#1081' '#1082#1088#1080#1090#1077#1088#1080#1081
    end
    object MemoDescription: TMemo
      Left = 109
      Top = 37
      Width = 306
      Height = 67
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 1
    end
    object EditPriority: TEdit
      Left = 109
      Top = 218
      Width = 69
      Height = 21
      TabOrder = 10
      Text = '1'
    end
    object EditAlgorithm: TEdit
      Left = 109
      Top = 110
      Width = 279
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Color = clBtnFace
      ReadOnly = True
      TabOrder = 2
    end
    object ButtonAlgorithm: TButton
      Left = 394
      Top = 110
      Width = 21
      Height = 21
      Hint = #1042#1099#1073#1088#1072#1090#1100' '#1072#1083#1075#1086#1088#1080#1090#1084
      Anchors = [akTop, akRight]
      Caption = '...'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 3
    end
    object CheckBoxEnabled: TCheckBox
      Left = 184
      Top = 220
      Width = 97
      Height = 17
      Hint = #1042#1082#1083#1102#1095#1080#1090#1100'/'#1074#1099#1082#1083#1102#1095#1080#1090#1100' '#1082#1086#1085#1090#1088#1086#1083#1100
      Caption = #1042#1082#1083#1102#1095#1077#1085
      ParentShowHint = False
      ShowHint = True
      TabOrder = 11
    end
    object EditFirstMinValue: TEdit
      Left = 109
      Top = 137
      Width = 69
      Height = 21
      TabOrder = 4
    end
    object EditFirstMaxValue: TEdit
      Left = 237
      Top = 137
      Width = 69
      Height = 21
      TabOrder = 5
    end
    object EditSecondMinValue: TEdit
      Left = 109
      Top = 164
      Width = 69
      Height = 21
      TabOrder = 7
    end
    object EditSecondMaxValue: TEdit
      Left = 237
      Top = 164
      Width = 69
      Height = 21
      TabOrder = 8
    end
    object EditMeasureUnit: TEdit
      Left = 110
      Top = 191
      Width = 169
      Height = 21
      Color = clBtnFace
      ReadOnly = True
      TabOrder = 12
    end
    object ButtonMeasureUnit: TButton
      Left = 285
      Top = 191
      Width = 21
      Height = 21
      Hint = #1042#1099#1073#1088#1072#1090#1100' '#1077#1076#1080#1085#1080#1094#1091' '#1080#1079#1084#1077#1088#1077#1085#1080#1103
      Caption = '...'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 13
    end
    object CheckBoxFirstModulo: TCheckBox
      Left = 312
      Top = 139
      Width = 97
      Height = 17
      Caption = #1055#1086' '#1084#1086#1076#1091#1083#1102
      ParentShowHint = False
      ShowHint = True
      TabOrder = 6
    end
    object CheckBoxSecondModulo: TCheckBox
      Left = 312
      Top = 166
      Width = 97
      Height = 17
      Caption = #1055#1086' '#1084#1086#1076#1091#1083#1102
      ParentShowHint = False
      ShowHint = True
      TabOrder = 9
    end
  end
  inherited PanelButton: TPanel
    Top = 253
    Width = 461
    ExplicitTop = 226
    ExplicitWidth = 352
    DesignSize = (
      461
      39)
    inherited ButtonCancel: TButton
      Left = 380
      ExplicitLeft = 271
    end
    inherited ButtonOk: TButton
      Left = 298
      ExplicitLeft = 189
    end
  end
  inherited MainMenu: TMainMenu
    Left = 256
    Top = 40
  end
  inherited ImageList: TImageList
    Left = 184
    Top = 42
  end
end
