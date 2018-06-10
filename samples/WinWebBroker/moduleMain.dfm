object WebModule1: TWebModule1
  OldCreateOrder = False
  Actions = <
    item
      Name = 'WebActionItem1'
      PathInfo = '/api'
    end
    item
      Name = 'WebActionItem2'
      PathInfo = '/api'
    end
    item
      Name = 'WebActionItem3'
      PathInfo = '/api'
    end
    item
      Name = 'WebActionItem4'
      PathInfo = '/api'
    end
    item
      Name = 'WebActionItem5'
      PathInfo = '/api'
    end
    item
      Name = 'WebActionItem6'
      PathInfo = '/api'
    end
    item
      Name = 'WebActionItem7'
      PathInfo = '/api'
    end
    item
      Name = 'WebActionItem8'
      PathInfo = '/api'
    end
    item
      Name = 'WebActionItem9'
      PathInfo = '/api'
    end
    item
      Name = 'WebActionItem10'
      PathInfo = '/api'
    end
    item
      Name = 'WebActionItem11'
      PathInfo = '/api'
    end
    item
      Name = 'WebActionItem12'
      PathInfo = '/'
    end
    item
      Name = 'WebActionItem13'
      PathInfo = '/'
    end
    item
      Name = 'WebActionItem14'
      PathInfo = '/RESTAPI1'
    end
    item
      Name = 'WebActionItem15'
      PathInfo = '/RESTAPI1'
    end
    item
      Name = 'WebActionItem16'
      PathInfo = '/RESTAPI1'
    end
    item
      Name = 'WebActionItem17'
      PathInfo = '/RESTAPI1'
    end
    item
      Name = 'WebActionItem18'
      PathInfo = '/RESTAPI1'
    end
    item
      Name = 'WebActionItem19'
      PathInfo = '/RESTAPI1'
    end
    item
      Name = 'WebActionItem20'
      PathInfo = '/RESTAPI1'
    end
    item
      Name = 'WebActionItem21'
      PathInfo = '/RESTAPI1'
    end
    item
      Name = 'WebActionItem22'
      PathInfo = '/RESTAPI1'
    end
    item
      Name = 'WebActionItem23'
      PathInfo = '/'
    end
    item
      Default = True
      Name = 'WebActionItem24'
      PathInfo = '/RESTAPI1'
    end>
  Height = 230
  Width = 415
  object FDMemTable1: TFDMemTable
    Active = True
    FieldDefs = <>
    IndexDefs = <>
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    StoreDefs = True
    Left = 64
    Top = 56
  end
  object RESTAPI1: TRESTAPI
    Name = 'RESTAPI1'
    Endpoints = <
      item
        Datset = FDMemTable1
        Fields = <
          item
          end>
        Name = 'users'
      end>
    Left = 192
    Top = 104
  end
end
