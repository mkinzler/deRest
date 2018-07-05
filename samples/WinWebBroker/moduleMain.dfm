object WebModule1: TWebModule1
  OldCreateOrder = False
  Actions = <
    item
      Default = True
      Name = 'WebActionItem1'
    end>
  Height = 230
  Width = 415
  object FDConnection1: TFDConnection
    Params.Strings = (
      'Database=apiheaders'
      'User_Name=root'
      'Password=H0n3ym0n5t3r'
      'DriverID=MySQL')
    Connected = True
    LoginPrompt = False
    Left = 64
    Top = 32
  end
  object RESTAPI1: TRESTAPI
    Collections = <
      item
        Connection = FDConnection1
        TableName = 'tbl_categories'
        KeyField = 'str_pkid'
        Endpoint = 'categories'
      end>
    Left = 192
    Top = 96
  end
end
