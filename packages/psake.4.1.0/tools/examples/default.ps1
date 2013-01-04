properties {
  $testMessage = 'Executed Test!'
  $compileMessage = 'Executed Compile!'
  $cleanMessage = 'Executed Clean!'
}

task default -depends Test

task Test -depends Compile, Clean { 
  $testMessage
}

task Compile -depends Clean { 
  $compileMessage
}

task Clean { 
  Exec { "C:\Windows\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe" }
  $cleanMessage
}

task ? -Description "Helper to display task info" {
	Write-Documentation
}