inherited SgtsRbkGraphEditForm: TSgtsRbkGraphEditForm
  Left = 482
  Top = 173
  Width = 442
  Height = 467
  Caption = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1085#1080#1077' '#1075#1088#1072#1092#1080#1082#1072
  Constraints.MinHeight = 160
  Constraints.MinWidth = 300
  PixelsPerInch = 96
  TextHeight = 13
  inherited StatusBar: TStatusBar
    Top = 402
    Width = 434
  end
  inherited ToolBar: TToolBar
    Height = 363
  end
  inherited PanelEdit: TPanel
    Width = 399
    Height = 363
    object LabelCut: TLabel
      Left = 68
      Top = 121
      Width = 28
      Height = 13
      Alignment = taRightJustify
      Caption = #1057#1088#1077#1079':'
      FocusControl = EditCut
    end
    object LabelDescription: TLabel
      Left = 43
      Top = 68
      Width = 53
      Height = 13
      Alignment = taRightJustify
      Caption = #1054#1087#1080#1089#1072#1085#1080#1077':'
      FocusControl = MemoDescription
    end
    object LabelName: TLabel
      Left = 19
      Top = 15
      Width = 77
      Height = 13
      Alignment = taRightJustify
      Caption = #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077':'
      FocusControl = EditName
    end
    object LabelGraphType: TLabel
      Left = 28
      Top = 42
      Width = 68
      Height = 13
      Alignment = taRightJustify
      Caption = #1058#1080#1087' '#1075#1088#1072#1092#1080#1082#1072':'
      FocusControl = ComboBoxGraphType
    end
    object LabelMenu: TLabel
      Left = 40
      Top = 315
      Width = 33
      Height = 13
      Alignment = taRightJustify
      Caption = #1052#1077#1085#1102':'
      FocusControl = EditMenu
    end
    object LabelPriority: TLabel
      Left = 221
      Top = 341
      Width = 87
      Height = 13
      Alignment = taRightJustify
      Caption = #1055#1086#1088#1103#1076#1086#1082' '#1074' '#1084#1077#1085#1102':'
      FocusControl = EditPriority
    end
    object EditCut: TEdit
      Left = 106
      Top = 118
      Width = 254
      Height = 21
      Color = clBtnFace
      ReadOnly = True
      TabOrder = 3
    end
    object ButtonCut: TButton
      Left = 366
      Top = 118
      Width = 21
      Height = 21
      Hint = #1042#1099#1073#1088#1072#1090#1100' '#1089#1088#1077#1079
      Caption = '...'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 4
    end
    object MemoDescription: TMemo
      Left = 106
      Top = 65
      Width = 282
      Height = 47
      TabOrder = 2
    end
    object GroupBoxDetermination: TGroupBox
      Left = 29
      Top = 143
      Width = 358
      Height = 161
      Caption = ' '#1055#1072#1088#1072#1084#1077#1090#1088#1099' '
      TabOrder = 5
      object PanelDetermination: TPanel
        Left = 2
        Top = 15
        Width = 354
        Height = 144
        Align = alClient
        BevelOuter = bvNone
        BorderWidth = 5
        TabOrder = 0
        object LabelDetermination: TLabel
          Left = 5
          Top = 5
          Width = 344
          Height = 16
          Align = alTop
          Alignment = taCenter
          AutoSize = False
          Caption = #1055#1072#1088#1072#1084#1077#1090#1088#1099':'
          FocusControl = MemoDescription
          Visible = False
        end
        object MemoDetermination: TMemo
          Left = 5
          Top = 21
          Width = 344
          Height = 118
          Align = alClient
          ScrollBars = ssBoth
          TabOrder = 0
          WordWrap = False
        end
      end
    end
    object EditName: TEdit
      Left = 106
      Top = 11
      Width = 282
      Height = 21
      TabOrder = 0
    end
    object ComboBoxGraphType: TComboBox
      Left = 106
      Top = 38
      Width = 282
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 1
      Items.Strings = (
        #1043#1088#1072#1092#1080#1082' '#1087#1088#1086#1089#1090#1086#1081
        #1043#1088#1072#1092#1080#1082' '#1079#1072' '#1087#1077#1088#1080#1086#1076
        #1043#1088#1072#1092#1080#1082' '#1087#1086' '#1080#1079#1084#1077#1088#1080#1090#1077#1083#1100#1085#1099#1084' '#1090#1086#1095#1082#1072#1084
        #1043#1088#1072#1092#1080#1082' '#1074' '#1088#1072#1079#1088#1077#1079#1077' '#1075#1088#1091#1087#1087' '#1086#1073#1098#1077#1082#1090#1086#1074)
    end
    object EditMenu: TEdit
      Left = 81
      Top = 311
      Width = 306
      Height = 21
      TabOrder = 6
    end
    object EditPriority: TEdit
      Left = 318
      Top = 337
      Width = 69
      Height = 21
      TabOrder = 7
    end
  end
  inherited PanelButton: TPanel
    Top = 363
    Width = 434
    inherited ButtonCancel: TButton
      Left = 350
    end
    inherited ButtonOk: TButton
      Left = 268
    end
  end
  inherited MainMenu: TMainMenu
    Left = 128
    Top = 208
  end
  inherited ImageList: TImageList
    Left = 192
    Top = 210
  end
end
