object PrcMainFrm: TPrcMainFrm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Process Manager'
  ClientHeight = 594
  ClientWidth = 806
  Color = clBtnFace
  Constraints.MaxHeight = 633
  Constraints.MaxWidth = 822
  Constraints.MinHeight = 633
  Constraints.MinWidth = 822
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
    Left = 8
    Top = 578
    Width = 56
    Height = 13
    Caption = 'LabelStatus'
  end
  object PaintBoxCPUUsage: TPaintBox
    Left = 8
    Top = 398
    Width = 790
    Height = 82
    OnPaint = PBConPaint
  end
  object PaintBoxMemUsage: TPaintBox
    Left = 8
    Top = 495
    Width = 790
    Height = 82
    OnPaint = PBMonPaint
  end
  object Label1: TLabel
    Left = 8
    Top = 382
    Width = 90
    Height = 13
    Caption = 'CPU Usage History'
  end
  object Label2: TLabel
    Left = 8
    Top = 480
    Width = 108
    Height = 13
    Caption = 'Memory Usage History'
  end
  object ProcessList: TListView
    Left = 8
    Top = 8
    Width = 790
    Height = 369
    BorderStyle = bsNone
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
        Width = 180
      end
      item
        Caption = 'User Name'
        Width = 240
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
    OnSelectItem = LVOnSelected
  end
  object TimerUpdateUsageHistory: TTimer
    Interval = 500
    OnTimer = TimerUpdateUsageHistoryTimer
    Left = 760
    Top = 400
  end
  object IconList: TImageList
    ColorDepth = cd32Bit
    Left = 744
    Top = 40
  end
end
