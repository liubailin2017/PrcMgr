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
  OnDestroy = FormOnDestroy
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
    OnClick = BoxCPUUsageClick
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
    Height = 105
    Caption = 'Memery Usage History'
    TabOrder = 1
    object PaintBoxMemUsage: TPaintBox
      Left = 3
      Top = 16
      Width = 784
      Height = 82
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
          Caption = 'Name      v'
          Width = 140
        end
        item
          Caption = 'Memery Usage(k)'
          Width = 120
        end
        item
          Caption = 'CPU Usage(%)'
          Width = 120
        end
        item
          Caption = 'Priority'
          Width = 140
        end
        item
          Caption = 'User Name'
          Width = 200
        end>
      Font.Charset = GB2312_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = #24494#36719#38597#40657
      Font.Style = []
      FlatScrollBars = True
      GridLines = True
      GroupHeaderImages = IconList
      RowSelect = True
      ParentFont = False
      SmallImages = IconList
      TabOrder = 0
      ViewStyle = vsReport
      OnColumnClick = PrcListOnColumClick
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
    Top = 40
  end
end
