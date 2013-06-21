param([string]$task="default")

if ((Test-Path ".\nuget.exe") -eq $false)
{
	$webClient = new-object net.webclient
	$webClient.DownloadFile('https://s3.amazonaws.com/nuget_exe/NuGet.exe','nuget.exe')
}

 .\nuget.exe install psake -Source "https://nuget.org/api/v2" -ExcludeVersion -OutputDirectory "packages"
Import-Module '.\packages\psake\tools\psake.psm1';
Invoke-psake  .\default.ps1 -t $task