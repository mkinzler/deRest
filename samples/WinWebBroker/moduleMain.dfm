object WebModule1: TWebModule1
  OldCreateOrder = False
  Actions = <
    item
      Name = 'WebActionItem1'
      PathInfo = '/api'
      Producer = RESTAPI1
    end>
  Height = 230
  Width = 415
  object RESTAPI1: TRESTAPI
    Datasets = <
      item
        Dataset = FDMemTable1
        PublicName = 'users'
      end>
    Left = 32
    Top = 16
  end
  object FDMemTable1: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 40
    Top = 88
  end
end
