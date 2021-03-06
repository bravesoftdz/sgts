inherited SgtsPeriodForm: TSgtsPeriodForm
  Left = 408
  Top = 159
  Caption = #1042#1099#1073#1086#1088' '#1087#1077#1088#1080#1086#1076#1072
  ClientHeight = 203
  ClientWidth = 256
  OnCreate = FormCreate
  ExplicitLeft = 408
  ExplicitTop = 159
  ExplicitWidth = 264
  ExplicitHeight = 230
  PixelsPerInch = 96
  TextHeight = 13
  object lbBegin: TLabel [0]
    Left = 96
    Top = 114
    Width = 9
    Height = 13
    Caption = 'c:'
    FocusControl = dtpBegin
  end
  object lbEnd: TLabel [1]
    Left = 90
    Top = 138
    Width = 16
    Height = 13
    Caption = #1087#1086':'
    FocusControl = dtpEnd
  end
  inherited PanelDialog: TPanel
    Width = 256
    Height = 165
    TabOrder = 14
    ExplicitWidth = 256
    ExplicitHeight = 165
  end
  inherited PanelButton: TPanel
    Top = 165
    Width = 256
    TabOrder = 15
    ExplicitTop = 165
    ExplicitWidth = 256
    inherited ButtonOk: TButton
      Left = 93
      ExplicitLeft = 93
    end
    inherited ButtonCancel: TButton
      Left = 175
      ExplicitLeft = 175
    end
  end
  object dtpBegin: TDateTimePicker
    Left = 112
    Top = 110
    Width = 133
    Height = 21
    Date = 36907.446560219900000000
    Time = 36907.446560219900000000
    DateFormat = dfLong
    TabOrder = 12
  end
  object dtpEnd: TDateTimePicker
    Left = 112
    Top = 134
    Width = 133
    Height = 21
    Date = 36907.446560219900000000
    Time = 36907.446560219900000000
    DateFormat = dfLong
    TabOrder = 13
  end
  object rbKvartal: TRadioButton
    Left = 8
    Top = 40
    Width = 76
    Height = 17
    Caption = #1050#1074#1072#1088#1090#1072#1083':'
    TabOrder = 3
    OnClick = rbKvartalClick
  end
  object rbMonth: TRadioButton
    Left = 8
    Top = 64
    Width = 76
    Height = 17
    Caption = #1052#1077#1089#1103#1094':'
    TabOrder = 6
    OnClick = rbKvartalClick
  end
  object rbDay: TRadioButton
    Left = 8
    Top = 88
    Width = 76
    Height = 17
    Caption = #1044#1077#1085#1100':'
    TabOrder = 9
    OnClick = rbKvartalClick
  end
  object rbInterval: TRadioButton
    Left = 8
    Top = 112
    Width = 76
    Height = 17
    Caption = #1048#1085#1090#1077#1088#1074#1072#1083':'
    TabOrder = 11
    OnClick = rbKvartalClick
  end
  object edKvartal: TEdit
    Left = 112
    Top = 38
    Width = 117
    Height = 21
    ReadOnly = True
    TabOrder = 4
    Text = '0'
    OnChange = edKvartalChange
  end
  object udKvartal: TUpDown
    Left = 229
    Top = 38
    Width = 15
    Height = 21
    Associate = edKvartal
    Min = -4
    Max = 4
    TabOrder = 5
    OnChangingEx = udKvartalChangingEx
  end
  object edMonth: TEdit
    Left = 112
    Top = 62
    Width = 117
    Height = 21
    ReadOnly = True
    TabOrder = 7
    Text = '0'
    OnChange = edMonthChange
  end
  object udMonth: TUpDown
    Left = 229
    Top = 62
    Width = 15
    Height = 21
    Associate = edMonth
    Min = -4
    Max = 4
    TabOrder = 8
    OnChangingEx = udMonthChangingEx
  end
  object dtpDay: TDateTimePicker
    Left = 112
    Top = 86
    Width = 133
    Height = 21
    Date = 36907.446560219900000000
    Time = 36907.446560219900000000
    DateFormat = dfLong
    TabOrder = 10
  end
  object rbYear: TRadioButton
    Left = 8
    Top = 16
    Width = 76
    Height = 17
    Caption = #1043#1086#1076':'
    Checked = True
    TabOrder = 0
    TabStop = True
    OnClick = rbKvartalClick
  end
  object edYear: TEdit
    Left = 112
    Top = 14
    Width = 117
    Height = 21
    TabOrder = 1
    Text = '2001'
  end
  object udYear: TUpDown
    Left = 229
    Top = 14
    Width = 16
    Height = 21
    Associate = edYear
    Min = 1900
    Max = 9000
    Position = 2001
    TabOrder = 2
    Thousands = False
    OnChangingEx = udYearChangingEx
  end
end
