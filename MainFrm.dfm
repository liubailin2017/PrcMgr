object PrcMainFrm: TPrcMainFrm
  Left = 0
  Top = 0
  Caption = 'Process Manager'
  ClientHeight = 594
  ClientWidth = 806
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object LabelStatus: TLabel
    Left = 16
    Top = 576
    Width = 56
    Height = 13
    Caption = 'LabelStatus'
  end
  object BoxCPUUsage: TGroupBox
    Left = 8
    Top = 377
    Width = 787
    Height = 97
    Caption = 'CPU Usage History'
    TabOrder = 0
    object PaintBoxCPUUsage: TPaintBox
      Left = 3
      Top = 16
      Width = 781
      Height = 73
      OnPaint = PBConPaint
    end
  end
  object BoxMemUsage: TGroupBox
    Left = 8
    Top = 472
    Width = 790
    Height = 97
    Caption = 'Memery Usage History'
    TabOrder = 1
    object PaintBoxMemUsage: TPaintBox
      Left = 3
      Top = 16
      Width = 784
      Height = 73
      OnPaint = PBMonPaint
    end
  end
  object Panel1: TPanel
    Left = 8
    Top = 8
    Width = 790
    Height = 363
    Caption = 'Process List'
    TabOrder = 2
    object ProcessList: TListView
      Left = 0
      Top = 0
      Width = 790
      Height = 363
      Columns = <
        item
          Caption = 'Name'
          Width = 100
        end
        item
          Caption = 'Memery Usage'
          Width = 100
        end
        item
          Caption = 'CPU Usage'
          Width = 100
        end
        item
          Caption = 'Priority'
          Width = 100
        end
        item
          Caption = 'User Name'
          Width = 100
        end>
      TabOrder = 0
      ViewStyle = vsReport
    end
  end
  object TimerUpdateUsageHistory: TTimer
    Interval = 500
    OnTimer = TimerUpdateUsageHistoryTimer
    Left = 120
    Top = 568
  end
  object IconList: TImageList
    Left = 744
    Top = 24
  end
end
