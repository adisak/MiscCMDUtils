@echo off
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
REM -------------------------------------------------------------------
REM  Copyright (c) 2023 Adisak Pochanayon
REM  Contact: adisak@gmail.com
REM  Currently hosted at https://github.com/adisak/MiscCMDUtils
REM -------------------------------------------------------------------

REM Set the SCRIPT_PATH to the path of this script
REM call :SetToFullyExpandedPath SCRIPT_PATH "%~dp0"
REM set SCRIPT_NAME=%~nx0

REM -------------------------------------------------------------------

set FIRST_PARAM=%~1
set FIRST_CHAR=%FIRST_PARAM:~0,1%
if "%FIRST_PARAM%"=="/?" (
	call :ShowHelp
	GOTO :ExitBatch
)

if NOT "%FIRST_CHAR%" ==":" GOTO :NoSubSpecified
REM :SubSpecified

if "%FIRST_PARAM%"==":ShowHelp" GOTO :CallSubAndExit
if "%FIRST_PARAM%"==":SetToFullyExpandedPath" GOTO :CallSubAndExit
if "%FIRST_PARAM%"==":GetUniqueTemporaryFile" GOTO :CallSubAndExit

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
set %1=%~f2
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
ENDLOCAL & set %1=%UTEMP%
GOTO :EOF
