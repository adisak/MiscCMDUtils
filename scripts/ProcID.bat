@echo off
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
REM -------------------------------------------------------------------
REM  Copyright (c) 2023-2024 Adisak Pochanayon
REM  Contact: adisak@gmail.com
REM  Currently hosted at https://github.com/adisak/MiscCMDUtils
REM -------------------------------------------------------------------

REM Set the SCRIPT_PATH to the path of this script
REM call :SetToFullyExpandedPath SCRIPT_PATH "%~dp0"
REM set SCRIPT_NAME=%~nx0

REM -------------------------------------------------------------------

REM Validate Subroutine to call

REM set MISC_UTILS_NO_VALIDATE=1
REM if "%MISC_UTILS_NO_VALIDATE%"=="1" GOTO :CallSubAndExit

set FIRST_PARAM=%~1
set FIRST_CHAR=%FIRST_PARAM:~0,1%
if "%FIRST_PARAM%"=="/?" (
	call :ShowHelp
	GOTO :ExitBatch
)

if NOT "%FIRST_CHAR%" ==":" GOTO :NoSubSpecified
REM :SubSpecified

REM Uncomment next line to skip subroutine [label is valid] safety checks
REM GOTO :CallSubAndExit

if "%FIRST_PARAM%"==":ShowHelp" GOTO :CallSubAndExit

if "%FIRST_PARAM%"==":GetCurrentProcID" GOTO :CallSubAndExit
if "%FIRST_PARAM%"==":GetParentProcID" GOTO :CallSubAndExit
if "%FIRST_PARAM%"==":GetWindowTitle" GOTO :CallSubAndExit

REM -------------------------------------------------------------------

:InvalidSub
echo Invalid Subroutine Specified - %FIRST_PARAM%

:NoSubSpecified
REM Fallthrough if no subroutine label was specified
call :ShowHelp
REM GOTO :ExitBatch

REM -------------------------------------------------------------------
REM EXIT BATCH FILE
REM -------------------------------------------------------------------
:ExitBatch
ENDLOCAL
GOTO:EOF

:CallSubAndExit
ENDLOCAL
REM Subroutine validation succeeded
REM Call specified subroutine
call %*
GOTO:EOF

REM -------------------------------------------------------------------
REM SUBROUTINES
REM -------------------------------------------------------------------

:ShowHelp
SETLOCAL
set SCRIPT_NAME=%~nx0
echo %SCRIPT_NAME% usage:
echo.
echo.	%SCRIPT_NAME% [Subroutine] [Parameters]
echo.
ENDLOCAL
GOTO:EOF

:SetToFullyExpandedPath
set %~1=%~f2
GOTO:EOF

:SetToFullyExpandedPath_CS
REM Case Sensitive Version (Changes Drive Letter to UPPERCASE)
REM set %~1=%~d2%~p2%~n2
SETLOCAL
call :ToUpperCase "%~d2"
ENDLOCAL & set %~1=%TO_UPPER%%~p2%~n2
GOTO:EOF

:GetUniqueTemporaryFile
if "%~1"=="" call :GUTF_Normal UTEMP "%~2" & GOTO:EOF 
:GUTF_Normal
SETLOCAL
:GUTF_Retry
if "%~2"=="" (
	set UTEMP=%tmp%\bat_%RANDOM%.tmp
) else (
	set UTEMP=%~f2\bat_%RANDOM%.tmp
)
if EXIST "%UTEMP%" GOTO :GUTF_Retry
ENDLOCAL & set %~1=%UTEMP%
GOTO :EOF

REM -------------------------------------------------------------------

:GetCurrentProcID
if "%~1"=="" call :GCPID_Normal PROCID & GOTO:EOF
:GCPID_Normal
SETLOCAL
set PROCID=
for /f %%a in ('wmic os get LocalDateTime ^| findstr [0-9]') do set NOW=%%a
call :GetUniqueTemporaryFile
wmic process where "Name='wmic.exe' and CreationDate > '%NOW%'" get ParentProcessId > %UTEMP%
for /f "skip=1" %%a in ('type "%UTEMP%"') do (
	set PROCID=%%a
	GOTO :GCPID_PIDSet
)
:GCPID_PIDSet
del "%UTEMP%" >nul 2>&1
ENDLOCAL & set %~1=%PROCID%
GOTO :EOF

:GetParentProcID
if "%~2"=="" call :GPPID_Normal "%~1" PARENT_PROCID & GOTO:EOF
:GPPID_Normal
SETLOCAL
set PARENT_PROCID=
for /f "usebackq skip=1" %%a in (`wmic process where "Handle='%~1'" get ParentProcessId`) do (
	set PARENT_PROCID=%%a
	GOTO :GPPID_PIDSet
)
:GPPID_PIDSet
ENDLOCAL & set %~2=%PARENT_PROCID%
GOTO :EOF

REM -------------------------------------------------------------------

REM This only works for English Locale
:GetWindowTitle
if "%~1"=="" call :GWT_Normal WINTITLE & GOTO:EOF 
:GWT_Normal
SETLOCAL
call :GetCurrentProcID
call :GetUniqueTemporaryFile

:GWT_Retry
set WINTITLE=
tasklist /fi "pid eq %PROCID%" /fo list /v > %UTEMP%
for /f "tokens=* delims=" %%a in ('findstr "Window Title:" "%UTEMP%"') do (
	set WINTITLE=%%a
)
del "%UTEMP%" >nul 2>&1

if NOT "%WINTITLE%"=="Window Title: N/A" GOTO :GWT_Acquired
call :GetParentProcID %PROCID% PROCID
if NOT "%PROCID%"=="" GOTO :GWT_Retry

:GWT_Acquired
if "Window Title: "=="%WINTITLE:~0,14%" set WINTITLE=%WINTITLE:~14%
if "Administrator:  "=="%WINTITLE:~0,16%" set WINTITLE=%WINTITLE:~16%
ENDLOCAL & set %~1=%WINTITLE%
GOTO :EOF

REM -------------------------------------------------------------------
