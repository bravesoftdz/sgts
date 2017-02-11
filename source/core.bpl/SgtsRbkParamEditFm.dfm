inherited SgtsRbkParamEditForm: TSgtsRbkParamEditForm
  Left = 450
  Top = 209
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSizeable
  Caption = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1085#1080#1077' '#1087#1072#1088#1072#1084#1077#1090#1088#1072
  ClientHeight = 386
  ClientWidth = 363
  Constraints.MinHeight = 210
  Constraints.MinWidth = 310
  ExplicitLeft = 450
  ExplicitTop = 209
  ExplicitWidth = 371
  ExplicitHeight = 432
  PixelsPerInch = 96
  TextHeight = 13
  inherited StatusBar: TStatusBar
    Top = 367
    Width = 363
    ExplicitTop = 367
    ExplicitWidth = 363
  end
  inherited ToolBar: TToolBar
    Height = 328
    ExplicitHeight = 328
  end
  inherited PanelEdit: TPanel
    Width = 328
    Height = 328
    ExplicitWidth = 328
    ExplicitHeight = 328
    object LabelName: TLabel
      Left = 35
      Top = 16
      Width = 77
      Height = 13
      Alignment = taRightJustify
      Caption = #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077':'
      FocusControl = EditName
    end
    object LabelDescription: TLabel
      Left = 59
      Top = 40
      Width = 53
      Height = 13
      Alignment = taRightJustify
      Caption = #1054#1087#1080#1089#1072#1085#1080#1077':'
      FocusControl = MemoDescription
    end
    object LabelParamType: TLabel
      Left = 32
      Top = 120
      Width = 79
      Height = 13
      Alignment = taRightJustify
      Caption = #1058#1080#1087' '#1087#1072#1088#1072#1084#1077#1090#1088#1072':'
      FocusControl = ComboBoxParamType
    end
    object LabelAlgorithm: TLabel
      Left = 60
      Top = 146
      Width = 52
      Height = 13
      Alignment = taRightJustify
      Caption = #1040#1083#1075#1086#1088#1080#1090#1084':'
      FocusControl = EditAlgorithm
    end
    object LabelFormat: TLabel
      Left = 70
      Top = 94
      Width = 42
      Height = 13
      Alignment = taRightJustify
      Caption = #1060#1086#1088#1084#1072#1090':'
      FocusControl = EditFormat
    end
    object EditName: TEdit
      Left = 120
      Top = 12
      Width = 198
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Constraints.MaxWidth = 350
      TabOrder = 0
      Text = #1053#1086#1074#1099#1081' '#1087#1072#1088#1072#1084#1077#1090#1088
    end
    object MemoDescription: TMemo
      Left = 120
      Top = 37
      Width = 198
      Height = 48
      Anchors = [akLeft, akTop, akRight]
      Constraints.MaxWidth = 350
      TabOrder = 1
    end
    object ComboBoxParamType: TComboBox
      Left = 120
      Top = 116
      Width = 171
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 3
      OnChange = ComboBoxParamTypeChange
      Items.Strings = (
        #1042#1074#1086#1076#1080#1084#1099#1081
        #1048#1085#1090#1077#1075#1088#1072#1083#1100#1085#1099#1081
        #1055#1088#1086#1080#1079#1074#1086#1076#1085#1099#1081
        #1048#1085#1090#1077#1075#1088#1072#1083#1100#1085#1099#1081' '#1085#1077#1074#1080#1076#1080#1084#1099#1081)
    end
    object EditAlgorithm: TEdit
      Left = 120
      Top = 142
      Width = 171
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Color = clBtnFace
      ReadOnly = True
      TabOrder = 4
    end
    object ButtonAlgorithm: TButton
      Left = 297
      Top = 142
      Width = 21
      Height = 21
      Hint = #1042#1099#1073#1088#1072#1090#1100' '#1072#1083#1075#1086#1088#1080#1090#1084
      Anchors = [akTop, akRight]
      Caption = '...'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 5
    end
    object EditFormat: TEdit
      Left = 120
      Top = 90
      Width = 198
      Height = 21
      TabOrder = 2
    end
    object GroupBoxDetermination: TGroupBox
      Left = 9
      Top = 166
      Width = 309
      Height = 134
      Anchors = [akLeft, akTop, akRight, akBottom]
      Caption = ' '#1053#1072#1089#1090#1088#1086#1081#1082#1072' '
      TabOrder = 6
      object PanelDetermination: TPanel
        Left = 2
        Top = 15
        Width = 305
        Height = 117
        Align = alClient
        BevelOuter = bvNone
        BorderWidth = 5
        TabOrder = 0
        object LabelDetermination: TLabel
          Left = 5
          Top = 5
          Width = 295
          Height = 16
          Align = alTop
          Alignment = taCenter
          AutoSize = False
          Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072':'
          FocusControl = MemoDescription
          Visible = False
        end
        object MemoDetermination: TMemo
          Left = 5
          Top = 21
          Width = 295
          Height = 91
          Align = alClient
          ScrollBars = ssBoth
          TabOrder = 0
          WordWrap = False
        end
      end
    end
    object CheckBoxIsNotConfirm: TCheckBox
      Left = 10
      Top = 304
      Width = 287
      Height = 17
      Anchors = [akLeft, akBottom]
      Caption = #1053#1077' '#1080#1089#1087#1086#1083#1100#1079#1086#1074#1072#1090#1100' '#1076#1083#1103' '#1091#1090#1074#1077#1088#1078#1076#1077#1085#1080#1103
      TabOrder = 7
    end
  end
  inherited PanelButton: TPanel
    Top = 328
    Width = 363
    ExplicitTop = 328
    ExplicitWidth = 363
    DesignSize = (
      363
      39)
    inherited ButtonCancel: TButton
      Left = 282
      ExplicitLeft = 282
    end
    inherited ButtonOk: TButton
      Left = 200
      ExplicitLeft = 200
    end
  end
  inherited MainMenu: TMainMenu
    Left = 176
    Top = 48
  end
  inherited ImageList: TImageList
    Left = 216
    Top = 50
  end
end
