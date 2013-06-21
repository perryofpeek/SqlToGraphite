properties {
  $Build_Artifacts = 'output'
  $Pkgs = 'pkgs'
  $fullPath= 'src\SqlToGraphite.host\output'
  $version = '1.0.0.3'
  $Debug = 'Debug'
  $pwd = pwd
  $TestReport = "";
}

task default -depends Init , Clean, GetPublicPackages, GetPrivatePackages, CopyToOutput, Package

task GetPublicPackages {
    Exec { .\NuGet.exe install SqlToGraphiteInterfaces -OutputDirectory "$Pkgs" -version 0.3.2 }
    Exec { .\NuGet.exe install SqlToGraphite -OutputDirectory "$Pkgs" -version 0.3.0.12 }
    Exec { .\NuGet.exe install SqlToGraphitePlugin-Oracle -OutputDirectory "$Pkgs" -version 0.1.0 }
    Exec { .\NuGet.exe install SqlToGraphitePlugin-SqlServer -OutputDirectory "$Pkgs" -version 0.1.0 }
    #Exec { .\NuGet.exe install SqlToGraphitePlugin-LogParser -OutputDirectory pkgs -version 0.1.0 }
	#Exec { .\NuGet.exe install SqlToGraphitePlugin-CCTray -OutputDirectory pkgs -version 0.1.0 }
}

task GetPrivatePackages {
 #Exec { .\NuGet.exe install SqlToGraphitePlugin-TracsTransactionCount -OutputDirectory "$Pkgs" -version 0.1.0 }
}

task Clean {
  if((test-path  $Build_Artifacts -pathtype container))
  {
	rmdir -Force -Recurse $Build_Artifacts;
  }
  
  if((test-path  $Pkgs -pathtype container))
  {
	rmdir -Force -Recurse $Pkgs;
  }
}

task Init {
	$Company = "peek.org.uk";
	$Description = "Graphite Service for collecting metrics";
	$Product = "SqlToGraphite $version";
	$Title = "SqlToGraphite $version";
	$Copyright = "PerryOfPeek 2013";	
}

task CopyToOutput {

	mkdir $Build_Artifacts;

	$files = Get-ChildItem -Recurse -Include *.dll -Path $Pkgs
    foreach($file in $files)
	{
		Copy-Item $file $Build_Artifacts;	
	}
	
	$files = Get-ChildItem -Recurse -Include *.exe -Path $Pkgs
    foreach($file in $files)
	{
		Copy-Item $file $Build_Artifacts;	
	}
	
	$files = Get-ChildItem -Recurse -Include *.exe.config -Path $Pkgs
    foreach($file in $files)
	{
		Copy-Item $file $Build_Artifacts;	
	}
	
	Copy-Item "DefaultConfig.xml" $Build_Artifacts;	
}

task Package {
	Exec { c:\Apps\NSIS\makensis.exe /p4 /v2 sqlToGraphite.nsi }
    Move-item -Force SqlToGraphite-Setup.exe "SqlToGraphite-Setup-$version.exe"	
}

task ? -Description "Helper to display task info" {
    Write-Documentation
}

function Get-Git-Commit
{
    $gitLog = git log --oneline -1
    return $gitLog.Split(' ')[0]
}
