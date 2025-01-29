@echo off

REM --------------------------------------------------------------

if NOT EXIST "%windir%\System32\fltmc.exe" GOTO :NoCmd_fltmc
fltmc >NUL 2>&1
GOTO :ResultsOut

:NoCmd_fltmc
echo Command "fltmc" is not supported

REM --------------------------------------------------------------

if NOT EXIST "%windir%\System32\net.exe" GOTO :NoCmd_net
net session >NUL 2>&1
GOTO :ResultsOut

:NoCmd_net
echo Command "net" is not supported

REM --------------------------------------------------------------

setlocal enabledelayedexpansion
set "dv==::"
if defined !dv! (
	echo Running as User
) else (
	echo Running as Admin
)
endlocal

GOTO :EOF

REM --------------------------------------------------------------

:ResultsOut
if "%ERRORLEVEL%"=="0" (
	echo Running as Admin
) else (
	echo Running as User
)

GOTO :EOF

REM --------------------------------------------------------------
