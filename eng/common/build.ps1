[CmdletBinding(PositionalBinding=$false)]
Param(
  [string][Alias('c')]$configuration = "Debug",
  [string] $platform,
  [string] $projects,
  [string][Alias('v')]$verbosity = "minimal",
  [bool] $warnAsError = $true,
  [switch][Alias('r')]$restore,
  [switch][Alias('b')]$build,
  [switch] $rebuild,
  [switch][Alias('t')]$test,
  [switch] $integrationTest,
  [switch] $publish,
  [switch] $clean,
  [switch] $pack,
  [switch] $ci,
  [switch] $format,
  [switch] $help,
  [Parameter(ValueFromRemainingArguments=$true)][String[]]$properties
)

function Print-Usage() {
  Write-Host "Common settings:"
  Write-Host "  -configuration <value>  Build configuration: 'Debug' or 'Release' (short: -c)"
  Write-Host "  -platform <value>       Platform configuration: 'x86', 'x64' or any valid Platform value to pass to msbuild"
  Write-Host "  -verbosity <value>      Msbuild verbosity: q[uiet], m[inimal], n[ormal], d[etailed], and diag[nostic] (short: -v)"
  Write-Host "  -help                   Print help and exit"
  Write-Host ""

  Write-Host "Actions:"
  Write-Host "  -restore                Restore dependencies (short: -r)"
  Write-Host "  -build                  Build solution (short: -b)"
  Write-Host "  -rebuild                Rebuild solution"
  Write-Host "  -test                   Run all unit tests in the solution (short: -t)"
  Write-Host "  -integrationTest        Run all integration tests in the solution"
  Write-Host "  -pack                   Package build outputs into NuGet packages and Willow components"
  Write-Host "  -publish                Publish artifacts (e.g. symbols)"
  Write-Host "  -clean                  Clean the solution"
  Write-Host ""

  Write-Host "Advanced settings:"
  Write-Host "  -projects <value>       Semi-colon delimited list of sln/proj's to build. Globbing is supported (*.sln)"
  Write-Host "  -ci                     Set when running on CI server"
  Write-Host "  -warnAsError <value>    Sets warnaserror msbuild parameter ('true' or 'false')"
  Write-Host ""

  Write-Host "Command line arguments not listed above are passed thru to msbuild."
  Write-Host "The above arguments can be shortened as much as to be unambiguous (e.g. -co for configuration, -t for test, etc.)."
}

. $PSScriptRoot\tools.ps1

try {
  if ($clean) {
    if (Test-Path $ArtifactsDir) {
      Remove-Item -Recurse -Force $ArtifactsDir
      Write-Host 'Artifacts directory deleted.'
    }
    exit 0
  }

  if ($help -or (($null -ne $properties) -and ($properties.Contains('/help') -or $properties.Contains('/?')))) {
    PrintUsage
    exit 0
  }

  $platformArg = if ($platform) { "/p:Platform=$platform" } else { '' }

  if ($projects) {
    [string[]] $msbuildArgs = $properties
    $projects = ($projects.Split(';').ForEach({Resolve-Path $_}) -join ';')
    $msbuildArgs += "/p:Projects=$projects"
    $properties = $msbuildArgs
  }

  MSBuild `
    $platformArg `
    /p:Configuration=$configuration `
    /p:RepoRoot=$RepoRoot `
    /p:Restore=$restore `
    /p:Build=$build `
    /p:Test=$test `
    /p:Pack=$pack `
    /p:IntegrationTest=$integrationTest `
    /p:Publish=$publish `
    @properties

}
catch {
  Write-Host $_.ScriptStackTrace
  ExitWithExitCode 1
}

ExitWithExitCode 0