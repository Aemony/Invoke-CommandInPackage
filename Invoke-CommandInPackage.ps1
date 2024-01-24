# Basic setup:
# Leave empty if not using custom executable, or use 'cmd.exe'
#   to launch multiple other tools within the package context
$ExecutableCustom  = 'cmd.exe'

# The index of the application that the executable should be launched in the context of
# This will be 0 for most games as they only have a single launch option, but a few games define separate launch
#   options in their appxmanifest.xml files, where the first entry (0) might not correspond to the game/desired context
$AppIndex          = 0

# Setup
$Package           = Get-AppXPackage | Out-GridView -OutputMode Single -Title "Select desktop package..."
$PackageFamilyName = $Package.PackageFamilyName
$InstallLocation   = $Package.InstallLocation
$XmlManifest       = Select-Xml -Path "$InstallLocation\appxmanifest.xml" -XPath '/'
$Applications      = $XmlManifest.Node.Package.Applications.Application
$AppId             = if ($null -eq $Applications.Count) { $Applications.Id         } else { $Applications[$AppIndex].Id         }
$Executable        = if ($null -eq $Applications.Count) { $Applications.Executable } else { $Applications[$AppIndex].Executable }
$Command           = if ($null -eq $ExecutableCustom -or [string]::IsNullOrEmpty($ExecutableCustom)) { $Executable } else { $ExecutableCustom }

# Fix executables stored in the install folder
if ((Test-Path $Command -PathType leaf) -eq $false)
{
  if ((Test-Path "$InstallLocation\$Command" -PathType leaf))
  {
    $Command = "$InstallLocation\$Command"
  }
}

# Launch
$params = @{
  AppId             = $AppId
  PackageFamilyName = $PackageFamilyName
  Command           = $Command
  PreventBreakaway  = $true
}

Invoke-CommandInDesktopPackage @params
