@echo off
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
REM -------------------------------------------------------------------

SET "CMD_TOKENS=%CMDCMDLINE%"
REM echo CMD_LINE: "%CMD_TOKENS%"

SET "CMD_TOKENS=%CMD_TOKENS:&=%"
REM echo CMD_P: "%CMD_TOKENS%"

SET CMD_TOKEN1=
for /F "tokens=1 delims= " %%a in ("%CMD_TOKENS%") do (
	SET CMD_TOKEN1=%%a
)
REM echo CMD_TOKEN: "%CMD_TOKEN1%"

REM echo COMSPEC: "%COMSPEC%"

if /I "%CMD_TOKEN1%" == "%COMSPEC%" (
	echo Launched from Explorer
	PAUSE
) else (
	echo Launched from Command Line
)

REM -------------------------------------------------------------------
:ExitBatch
ENDLOCAL
GOTO :EOF

