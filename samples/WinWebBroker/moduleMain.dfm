object WebModule1: TWebModule1
  OldCreateOrder = False
  Actions = <
    item
      Name = 'wactCategories'
      PathInfo = '/api/categories'
      Producer = restCategories
    end
    item
      Name = 'wactCategories2'
      PathInfo = '/api2/categories'
      Producer = restCategories
    end>
  Height = 230
  Width = 415
  object restCategories: TRESTCollection
    Connection = FDConnection1
    TableName = 'tbl_categories'
    Left = 64
    Top = 104
  end
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
end
