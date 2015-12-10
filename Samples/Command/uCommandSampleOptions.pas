unit uCommandSampleOptions;

interface

type
  TGlobalOptions =  class
  public
    class var
      Verbose : boolean;
  end;

  TInstallOptions = class
  public
    class var
      InstallPath : string;
  end;

  TUninstallOptions = class
  public
    class var
      KeepSettings : boolean;
  end;

  TInstallLicense = class
  public
    class var
      LicenseFile : string;
  end;


  THelpOptions = class
  public
    class var
      HelpCommand : string;
  end;




implementation

end.
