@ECHO OFF
SETLOCAL

SET ASPNETCORE_ENVIRONMENT=Development
SET DOTNET_ENVIRONMENT=Development

SET folder=%~1

IF "%folder%"=="" (
    code .
) else (
    code "%folder%"
)

exit /b 1
