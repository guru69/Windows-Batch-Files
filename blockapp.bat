::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Automatically block single EXE from reaching the internet by creating
:: a windows firewall block rule.
:: Drag and drop an EXE onto this batch file,
:: Script elevates itself, creates outbound 
:: Windows firewall Program block rule
:: Useful for blocking "phone-home" apps or ones that might leak data
:: Requirements: Admin rights, and you must be using Windows Firewall
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
@echo off
if not %1 == ELEV set blockapp="%1"
if not %1 == ELEV echo %blockapp%>"%~dp0blockapp.txt"
if not %1 == ELEV set appname=%~n1
if not %1 == ELEV set appext=%~x1
if not %1 == ELEV echo %appname%%appext%>"%~dp0blocklabel.txt"
CLS
ECHO.
ECHO =============================
ECHO Running Admin shell
ECHO =============================

:checkPrivileges
NET FILE 1>NUL 2>NUL
if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges )

:getPrivileges
if '%1'=='ELEV' (shift & goto gotPrivileges)
ECHO.
ECHO **************************************
ECHO Invoking UAC for Privilege Escalation
ECHO **************************************

setlocal DisableDelayedExpansion
set "batchPath=%~0"
setlocal EnableDelayedExpansion
ECHO Set UAC = CreateObject^("Shell.Application"^) > "%temp%\OEgetPrivileges.vbs"
ECHO UAC.ShellExecute "!batchPath!", "ELEV", "", "runas", 1 >> "%temp%\OEgetPrivileges.vbs"
"%temp%\OEgetPrivileges.vbs"
exit /B

:gotPrivileges
::::::::::::::::::::::::::::
::START
::::::::::::::::::::::::::::
setlocal & pushd .

REM Any Admin commands go under here
:: cmd /k
set /p blockapp=<"%~dp0blockapp.txt"
set /p blocklabel=<"%~dp0blocklabel.txt"
del /Q "%~dp0blockapp.txt"
del /Q "%~dp0blocklabel.txt"
echo The blocked app path is %blockapp:"=%
netsh advfirewall firewall add rule name="%blocklabel:"=%" dir=out action=block program="%blockapp:"=%" enable=yes
pause
