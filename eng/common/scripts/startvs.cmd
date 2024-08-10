@ECHO OFF
SETLOCAL

SET ASPNETCORE_ENVIRONMENT=Development
SET DOTNET_ENVIRONMENT=Development

SET sln=%~1

IF "%sln%"=="" (
    echo Error^: Expected argument ^<SLN_FILE^>
    echo Usage^: startvs.cmd ^<SLN_FILE^>

    exit /b 1
)

IF "%VSINSTALLDIR%" == "" (
    start "" "%sln%"
) else (
    "%VSINSTALLDIR%\Common7\IDE\devenv.com" "%sln%"
)
