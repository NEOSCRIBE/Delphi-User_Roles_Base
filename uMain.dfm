object fmMain: TfmMain
  Left = 397
  Top = 279
  Caption = 'User Roles 0.1 alfa'
  ClientHeight = 447
  ClientWidth = 496
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = mmMain
  OldCreateOrder = False
  Position = poDesigned
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object gbUsers: TGroupBox
    Left = 0
    Top = 0
    Width = 185
    Height = 447
    Align = alLeft
    Caption = 'Users'
    TabOrder = 0
    object lbUsers: TListBox
      Left = 2
      Top = 15
      Width = 181
      Height = 430
      Align = alClient
      ItemHeight = 13
      PopupMenu = pmUsers
      TabOrder = 0
      OnClick = lbUsersClick
    end
  end
  object gbRoles: TGroupBox
    Left = 185
    Top = 0
    Width = 311
    Height = 447
    Align = alClient
    Caption = 'Roles'
    TabOrder = 1
    object sgRoles: TStringGrid
      Left = 2
      Top = 15
      Width = 307
      Height = 430
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alClient
      BevelInner = bvNone
      BevelOuter = bvNone
      ColCount = 2
      DefaultColWidth = 150
      DefaultRowHeight = 15
      RowCount = 2
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goEditing]
      PopupMenu = pmRoles
      ScrollBars = ssVertical
      TabOrder = 0
      OnExit = sgRolesExit
      OnGetEditText = sgRolesGetEditText
      OnSelectCell = sgRolesSelectCell
      OnSetEditText = sgRolesSetEditText
    end
  end
  object mmMain: TMainMenu
    Left = 8
    Top = 24
    object mmFile: TMenuItem
      Caption = 'File'
      object mmConnect: TMenuItem
        Caption = 'Connect'
        Default = True
        OnClick = mmConnectClick
      end
      object mmInit: TMenuItem
        Caption = 'Init base'
        OnClick = mmInitClick
      end
      object mmClear: TMenuItem
        Caption = 'Clear base'
        OnClick = mmClearClick
      end
      object mmExit: TMenuItem
        Caption = 'Exit'
        OnClick = mmExitClick
      end
    end
  end
  object pmUsers: TPopupMenu
    Alignment = paRight
    Left = 48
    Top = 24
    object piUAdd: TMenuItem
      Caption = 'Add'
      Default = True
      OnClick = piUAddClick
    end
    object piUEdit: TMenuItem
      Caption = 'Edit'
      OnClick = piUEditClick
    end
    object piUDelete: TMenuItem
      Caption = 'Delete'
      OnClick = piUDeleteClick
    end
  end
  object pmRoles: TPopupMenu
    Left = 88
    Top = 24
    object piRAdd: TMenuItem
      Caption = 'Add'
      OnClick = piRAddClick
    end
    object piRDelete: TMenuItem
      Caption = 'Delete'
      OnClick = piRDeleteClick
    end
  end
end
