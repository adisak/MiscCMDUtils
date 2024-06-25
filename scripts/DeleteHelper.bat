@echo off
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
REM -------------------------------------------------------------------
REM  Copyright (c) 2023-2024 Adisak Pochanayon
REM  Contact: adisak@gmail.com
REM  Currently hosted at https://github.com/adisak/MiscCMDUtils
REM -------------------------------------------------------------------

set SCRIPT_NAME=%~nx0
set FIRST_PARAM=%~1
set FIRST_CHAR=%FIRST_PARAM:~0,1%

if "%FIRST_PARAM%"=="/?" GOTO :ShowHelpAndExit
if "%FIRST_PARAM%"=="/help" GOTO :ShowHelpAndExit

if NOT "%FIRST_CHAR%" ==":" GOTO :NoSubSpecified
REM :SubSpecified

REM Comfirm that specified subroutine is valid before calling
set VALID_SUB_LABEL=0
if "%FIRST_PARAM%"==":QuietDelete" set VALID_SUB_LABEL=1
if "%FIRST_PARAM%"==":VerifyDelete" set VALID_SUB_LABEL=1
if "%FIRST_PARAM%"==":ForceDelete" set VALID_SUB_LABEL=1
if "%FIRST_PARAM%"==":CleanDir" set VALID_SUB_LABEL=1
if "%VALID_SUB_LABEL%"=="0" (
	echo Invalid Delete Subroutine Specified.
	GOTO :ShowHelpAndExit
)

REM Subroutine validation succeeded
REM Call specified subroutine
call %*
GOTO :ExitBatch

:ShowHelpAndExit
call :ShowHelp
GOTO :ExitBatch

:NoSubSpecified
REM Fallthrough if no subroutine label was specified
call :VerifyDelete %*

REM -------------------------------------------------------------------
REM EXIT BATCH FILE
REM -------------------------------------------------------------------
:ExitBatch
ENDLOCAL
GOTO:EOF

REM -------------------------------------------------------------------
REM SUBROUTINES
REM -------------------------------------------------------------------

:ShowHelp
echo %SCRIPT_NAME% usage:
echo.
echo.	%SCRIPT_NAME% [Optional Subroutine] FileSpec
echo.
echo.	FileSpec may contain wildcards
echo.
echo.	Valid values for Optional Subroutine are:
echo.		:QuietDelete
echo.		:VerifyDelete (default if none specified)
echo.		:ForceDelete
echo.		:CleanDir
GOTO:EOF

REM -------------------------------------------------------------------

REM :QuietDelete is a delete with no output or error messages (even if it fails)
:QuietDelete
for %%f in ("%~1") do (
	call :QuietDeleteSingle %%f
)
GOTO:EOF

:QuietDeleteSingle
if EXIST "%~1" (
	del "%~1" >nul 2>&1
)
GOTO:EOF

REM :VerifyDelete should report an ERROR if unable to delete files
:VerifyDelete
for %%f in (%1) do (
	call :VerifyDeleteSingle %%f
)
GOTO:EOF

:VerifyDeleteSingle
if EXIST "%~1" (
	del "%~1" >nul 2>&1
)
if EXIST "%~1" (
	echo ERROR: Unable to delete "%~1"
	echo ERROR: File may be read-only or locked by another process
)
GOTO:EOF

REM :ForceDelete will delete even Read-Only files and
REM should report an ERROR if unable to delete files
:ForceDelete
for %%f in (%1) do (
	call :ForceDeleteSingle %%f
)
GOTO:EOF

:ForceDeleteSingle
if EXIST "%~1" (
	del /f "%~1" >nul 2>&1
)
if EXIST "%~1" (
	echo ERROR: Unable to delete "%~1"
	echo ERROR: File may be locked by another process
)
GOTO:EOF

REM -------------------------------------------------------------------

:CleanDir
SETLOCAL
SET CLEANDIR=%~1
call :IsDir "%CLEANDIR%"
if NOT "%IS_DIR%"=="1" GOTO :CleanDir_NoDir
del /s /q "%CLEANDIR%\*.*" >nul 2>&1
for /d %%G in ("%CLEANDIR%\*.*") DO (
	rmdir /s /q "%%G" >nul 2>&1
)
:CleanDir_Exit
ENDLOCAL
GOTO:EOF
:CleanDir_NoDir
echo Directory "%~1" does not exit
GOTO :CleanDir_Exit

REM -------------------------------------------------------------------

:IsDir
SET IS_DIR=0
if NOT EXIST "%~1" GOTO:EOF
if NOT EXIST "%~1\*" GOTO:EOF
SET IS_DIR=1
GOTO:EOF
