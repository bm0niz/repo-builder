$ErrorActionPreference = 'Stop'

function Create-Directory ([string[]] $path) {
    New-Item -Path $path -Force -ItemType 'Directory' | Out-Null
}

function ExitWithExitCode([int] $exitCode) {
  exit $exitCode
}

function Exec-Process([string]$command, [string]$commandArgs) {
  $startInfo = New-Object System.Diagnostics.ProcessStartInfo
  $startInfo.FileName = $command
  $startInfo.Arguments = $commandArgs
  $startInfo.UseShellExecute = $false
  $startInfo.WorkingDirectory = Get-Location

  $process = New-Object System.Diagnostics.Process
  $process.StartInfo = $startInfo
  $process.Start() | Out-Null

  $finished = $false
  try {
    while (-not $process.WaitForExit(100)) {
      # Non-blocking loop done to allow ctr-c interrupts
    }

    $finished = $true
    return $global:LASTEXITCODE = $process.ExitCode
  }
  finally {
    if (-not $finished) {
      $process.Kill()
    }
  }
}

function MSBuild {
  $cmdArgs = "msbuild $EngRoot\common\tools\Build.proj /m /nologo /clp:Summary /v:$verbosity /warnaserror /p:TreatWarningsAsErrors=true"

  foreach ($arg in $args) {
    if ($null -ne $arg -and $arg.Trim() -ne "") {
      if ($arg.EndsWith('\')) {
        $arg = $arg + "\"
      }
      $cmdArgs += " `"$arg`""
    }
  }

  $exitCode = Exec-Process dotnet $cmdArgs

  if ($exitCode -ne 0) {
    Write-Host "Build failed with exit code $exitCode. Check errors above."
    ExitWithExitCode $exitCode
  }
}

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot '..\..\')
$EngRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$ArtifactsDir = Join-Path $RepoRoot 'artifacts'
$PackagesDir = Join-Path $RepoRoot 'packages'
$LogDir = Join-Path (Join-Path $ArtifactsDir 'log') $configuration
$TempDir = Join-Path (Join-Path $ArtifactsDir 'tmp') $configuration
$GlobalJson = Get-Content -Raw -Path (Join-Path $RepoRoot 'global.json') | ConvertFrom-Json

Create-Directory $TempDir
Create-Directory $LogDir