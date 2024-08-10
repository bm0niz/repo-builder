@ECHO OFF
SET RepoRoot=%~dp0..\..
%RepoRoot%\build.cmd -projects %~dp0project-2.sln %*
