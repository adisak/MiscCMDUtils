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
if "%FIRST_PARAM%"==":SetToFullyExpandedPath" GOTO :CallSubAndExit
if "%FIRST_PARAM%"==":SetToFullyExpandedPath_CS" GOTO :CallSubAndExit
if "%FIRST_PARAM%"==":GetUniqueTemporaryFile" GOTO :CallSubAndExit
if "%FIRST_PARAM%"==":GetCurrentProcID" GOTO :CallSubAndExit
if "%FIRST_PARAM%"==":GetParentProcID" GOTO :CallSubAndExit
if "%FIRST_PARAM%"==":GetWindowTitle" GOTO :CallSubAndExit
if "%FIRST_PARAM%"==":AddUniqueToPath" GOTO :CallSubAndExit
if "%FIRST_PARAM%"==":IsInPath" GOTO :CallSubAndExit
if "%FIRST_PARAM%"==":ToUpperCase" GOTO :CallSubAndExit
if "%FIRST_PARAM%"==":ToLowerCase" GOTO :CallSubAndExit

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

REM Add a path to %PATH% if it's not already part of %PATH%
:AddUniqueToPath
SETLOCAL
call :IsInPath "%~1"
if "%IS_IN_PATH%"=="1" GOTO :AUTP_ExitSkipAdd
call :SetToFullyExpandedPath ADD_PATH "%~1"
ENDLOCAL & SET PATH=%PATH%;%ADD_PATH%
GOTO :EOF
:AUTP_ExitSkipAdd
ENDLOCAL
GOTO :EOF

:IsInPath
if "%~2"=="" call :IIP_Normal "%~1" IS_IN_PATH & GOTO:EOF
:IIP_Normal
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
call :SetToFullyExpandedPath TEST_PATH "%~1"
call :ToUpperCase "%TEST_PATH%" TEST_PATH
set IS_IN_PATH=0
for %%a in ("%PATH:;=";"%") do (
	call :IIP_TestPath %%a
	if "!IS_IN_PATH!"=="1" GOTO :IIP_Done
)
:IIP_Done
ENDLOCAL & set %~2=%IS_IN_PATH%
GOTO :EOF

:IIP_TestPath
call :SetToFullyExpandedPath IN_PATH "%~1"
call :ToUpperCase "%IN_PATH%" IN_PATH
if "%IN_PATH%"=="%TEST_PATH%" (
	set IS_IN_PATH=1
	)
GOTO :EOF

REM -------------------------------------------------------------------

:ToUpperCase
if "%~2"=="" call :TUC_Normal "%~1" TO_UPPER & GOTO:EOF
:TUC_Normal
SETLOCAL
set TO_UPPER=%~1
set TO_UPPER=%TO_UPPER:a=A%
set TO_UPPER=%TO_UPPER:b=B%
set TO_UPPER=%TO_UPPER:c=C%
set TO_UPPER=%TO_UPPER:d=D%
set TO_UPPER=%TO_UPPER:e=E%
set TO_UPPER=%TO_UPPER:f=F%
set TO_UPPER=%TO_UPPER:g=G%
set TO_UPPER=%TO_UPPER:h=H%
set TO_UPPER=%TO_UPPER:i=I%
set TO_UPPER=%TO_UPPER:j=J%
set TO_UPPER=%TO_UPPER:k=K%
set TO_UPPER=%TO_UPPER:l=L%
set TO_UPPER=%TO_UPPER:m=M%
set TO_UPPER=%TO_UPPER:n=N%
set TO_UPPER=%TO_UPPER:o=O%
set TO_UPPER=%TO_UPPER:p=P%
set TO_UPPER=%TO_UPPER:q=Q%
set TO_UPPER=%TO_UPPER:r=R%
set TO_UPPER=%TO_UPPER:s=S%
set TO_UPPER=%TO_UPPER:t=T%
set TO_UPPER=%TO_UPPER:u=U%
set TO_UPPER=%TO_UPPER:v=V%
set TO_UPPER=%TO_UPPER:w=W%
set TO_UPPER=%TO_UPPER:x=X%
set TO_UPPER=%TO_UPPER:y=Y%
set TO_UPPER=%TO_UPPER:z=Z%
ENDLOCAL & set %~2=%TO_UPPER%
GOTO :EOF

:ToLowerCase
if "%~2"=="" call :TLC_Normal "%~1" TO_LOWER & GOTO:EOF
:TLC_Normal
SETLOCAL
set TO_LOWER=%~1
set TO_LOWER=%TO_LOWER:A=a%
set TO_LOWER=%TO_LOWER:B=b%
set TO_LOWER=%TO_LOWER:C=c%
set TO_LOWER=%TO_LOWER:D=d%
set TO_LOWER=%TO_LOWER:E=e%
set TO_LOWER=%TO_LOWER:F=f%
set TO_LOWER=%TO_LOWER:G=g%
set TO_LOWER=%TO_LOWER:H=h%
set TO_LOWER=%TO_LOWER:I=i%
set TO_LOWER=%TO_LOWER:J=j%
set TO_LOWER=%TO_LOWER:K=k%
set TO_LOWER=%TO_LOWER:L=l%
set TO_LOWER=%TO_LOWER:M=m%
set TO_LOWER=%TO_LOWER:N=n%
set TO_LOWER=%TO_LOWER:O=o%
set TO_LOWER=%TO_LOWER:P=p%
set TO_LOWER=%TO_LOWER:Q=q%
set TO_LOWER=%TO_LOWER:R=r%
set TO_LOWER=%TO_LOWER:S=s%
set TO_LOWER=%TO_LOWER:T=t%
set TO_LOWER=%TO_LOWER:U=u%
set TO_LOWER=%TO_LOWER:V=v%
set TO_LOWER=%TO_LOWER:W=w%
set TO_LOWER=%TO_LOWER:X=x%
set TO_LOWER=%TO_LOWER:Y=y%
set TO_LOWER=%TO_LOWER:Z=z%
ENDLOCAL & set %~2=%TO_LOWER%
GOTO :EOF

REM -------------------------------------------------------------------