inherited SgtsRecalcJournalObservationsForm: TSgtsRecalcJournalObservationsForm
  Left = 617
  Top = 293
  Caption = #1056#1072#1089#1095#1077#1090' '#1078#1091#1088#1085#1072#1083#1072' '#1085#1072#1073#1083#1102#1076#1077#1085#1080#1081
  ClientHeight = 373
  ClientWidth = 492
  Constraints.MinHeight = 400
  Constraints.MinWidth = 500
  OnCloseQuery = FormCloseQuery
  ExplicitWidth = 500
  ExplicitHeight = 400
  PixelsPerInch = 96
  TextHeight = 13
  object PanelGrid: TPanel
    Left = 0
    Top = 34
    Width = 492
    Height = 300
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 3
    TabOrder = 1
    object Splitter: TSplitter
      Left = 3
      Top = 211
      Width = 486
      Height = 6
      Cursor = crVSplit
      Align = alBottom
      ExplicitTop = 114
      ExplicitWidth = 386
    end
    object GroupBoxOption: TGroupBox
      Left = 3
      Top = 3
      Width = 486
      Height = 208
      Align = alClient
      Caption = ' '#1042#1080#1076#1099' '#1080#1079#1084#1077#1088#1077#1085#1080#1103' '
      TabOrder = 0
      object PanelOption: TPanel
        Left = 2
        Top = 15
        Width = 482
        Height = 191
        Align = alClient
        BevelOuter = bvNone
        BorderWidth = 5
        TabOrder = 0
      end
    end
    object MemoStatus: TMemo
      Left = 3
      Top = 217
      Width = 486
      Height = 80
      Align = alBottom
      ReadOnly = True
      ScrollBars = ssVertical
      TabOrder = 1
    end
  end
  object PanelBottom: TPanel
    Left = 0
    Top = 334
    Width = 492
    Height = 39
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    DesignSize = (
      492
      39)
    object ButtonRecalc: TButton
      Left = 304
      Top = 8
      Width = 100
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = #1056#1072#1089#1095#1080#1090#1072#1090#1100
      Default = True
      TabOrder = 2
      OnClick = ButtonRecalcClick
    end
    object ButtonClose: TButton
      Left = 411
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = #1047#1072#1082#1088#1099#1090#1100
      TabOrder = 3
      OnClick = ButtonCloseClick
    end
    object btUpColumns: TBitBtn
      Left = 8
      Top = 6
      Width = 25
      Height = 25
      Hint = #1042#1074#1077#1088#1093
      TabOrder = 0
      OnClick = btUpColumnsClick
      Glyph.Data = {
        F6000000424DF600000000000000760000002800000010000000100000000100
        0400000000008000000000000000000000001000000010000000000000000000
        8000008000000080800080000000800080008080000080808000C0C0C0000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00888888888888
        8888888888888888888888888888888888888888888888888888888880000088
        8888888880666088888888888066608888888888806660888888880000666000
        0888888066666660888888880666660888888888806660888888888888060888
        8888888888808888888888888888888888888888888888888888}
    end
    object btDownColumns: TBitBtn
      Left = 39
      Top = 6
      Width = 25
      Height = 25
      Hint = #1042#1085#1080#1079
      TabOrder = 1
      OnClick = btDownColumnsClick
      Glyph.Data = {
        F6000000424DF600000000000000760000002800000010000000100000000100
        0400000000008000000000000000000000001000000010000000000000000000
        8000008000000080800080000000800080008080000080808000C0C0C0000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00888888888888
        8888888888888888888888888888888888888888888888888888888888808888
        8888888888060888888888888066608888888888066666088888888066666660
        8888880000666000088888888066608888888888806660888888888880666088
        8888888880000088888888888888888888888888888888888888}
    end
  end
  object PanelPeriod: TPanel
    Left = 0
    Top = 0
    Width = 492
    Height = 34
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object LabelCycleBegin: TLabel
      Left = 59
      Top = 13
      Width = 38
      Height = 13
      Alignment = taRightJustify
      Caption = #1062#1080#1082#1083' '#1089':'
      FocusControl = EditCycleBegin
    end
    object LabelCycleEnd: TLabel
      Left = 198
      Top = 13
      Width = 16
      Height = 13
      Alignment = taRightJustify
      Caption = #1087#1086':'
      FocusControl = EditCycleEnd
    end
    object EditCycleBegin: TEdit
      Left = 103
      Top = 10
      Width = 60
      Height = 21
      Hint = #1053#1072#1095#1072#1083#1100#1085#1099#1081' '#1094#1080#1082#1083
      TabOrder = 0
    end
    object ButtonCycleBegin: TButton
      Left = 169
      Top = 10
      Width = 21
      Height = 21
      Caption = '...'
      TabOrder = 1
      OnClick = ButtonCycleBeginClick
    end
    object EditCycleEnd: TEdit
      Left = 220
      Top = 10
      Width = 60
      Height = 21
      Hint = #1050#1086#1085#1077#1095#1085#1099#1081' '#1094#1080#1082#1083
      TabOrder = 2
    end
    object ButtonCycleEnd: TButton
      Left = 286
      Top = 10
      Width = 21
      Height = 21
      Caption = '...'
      TabOrder = 3
      OnClick = ButtonCycleEndClick
    end
  end
  object DataSource: TDataSource
    Left = 205
    Top = 124
  end
  object PopupMenu: TPopupMenu
    OnPopup = PopupMenuPopup
    Left = 88
    Top = 140
    object MenuItemCheckAll: TMenuItem
      Caption = #1042#1099#1073#1088#1072#1090#1100' '#1074#1089#1077
      Hint = #1042#1099#1073#1088#1072#1090#1100' '#1075#1072#1083#1086#1095#1082#1086#1081' '#1074#1089#1077' '#1087#1072#1088#1072#1084#1077#1090#1088#1099
      OnClick = MenuItemCheckAllClick
    end
    object MenuItemUncheckAll: TMenuItem
      Caption = #1054#1095#1080#1089#1090#1080#1090#1100' '#1074#1089#1077
      Hint = #1059#1073#1088#1072#1090#1100' '#1075#1072#1083#1086#1095#1082#1080' '#1085#1072' '#1074#1089#1077' '#1087#1072#1088#1072#1084#1077#1090#1088#1072#1093
      OnClick = MenuItemUncheckAllClick
    end
  end
end
