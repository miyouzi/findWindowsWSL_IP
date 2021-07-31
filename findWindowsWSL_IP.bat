@chcp 65001 >nul
@echo off
@setlocal enabledelayedexpansion
title findWindowsWSL_IP By Miyouzi
call :getadmin

cd /D "%~dp0"
if exist hosts del /q hosts
set "domain=windows.local"
set /P pwd=<wsl_passwd.ini

echo === Finding WSL IP ===
echo(
for /f "tokens=1,2 delims=:" %%a in ('ipconfig') do (
	echo "%%a" | findstr "WSL" > nul && (
		set "flag=a"
	)
	if defined flag set /a n+=1
	if !n! equ 4 set "ip=%%b"
)
set "ip=%ip:~1%"
echo === WSL IP Found ! %ip% ===


set existingFlag=false
set foundFlag=false
for /F "tokens=1* delims=]" %%a in ('find /n /v "" ^< C:\Windows\System32\drivers\etc\hosts') do (
	if !foundFlag! == true (
		>>hosts echo %ip% %domain%
		set foundFlag=false
		set existingFlag=true
	) else (
		>>hosts echo(%%b
	)
	
	if "%%b" == "# Manage By findWindowsWSL_IP" (
		set foundFlag=true
	)
)

if !existingFlag! == false (
	>>hosts echo # Manage By findWindowsWSL_IP
	>>hosts echo %ip% %domain%
)

echo(
echo === Copy hosts to C:\Windows\System32\drivers\etc ===
copy /Y /V .\hosts /B C:\Windows\System32\drivers\etc\hosts

echo(
echo === Refresh hosts in WSL ===
set "regxIP=%ip:.=\.%"
wsl echo %pwd% ^| sudo -S sed -i 's/.*windows\.local/%regxIP% windows\.local/g' /etc/hosts >nul 2>nul


echo(
echo === All Done ! ===

echo(
echo === wait for 10s then exit===
ping localhost -n 10 >nul 2>nul
exit



REM ============================= check and require admin ===========================
REM from https://sites.google.com/site/eneerge/home/BatchGotAdmin
:getadmin
	>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
	if '%errorlevel%' NEQ '0' (
		echo === check and require admin ===
		mshta vbscript:"<html style=background:buttonface><title>BatchGetAdmin</title><body><script language=vbscript>Set UAC = CreateObject(""Shell.Application""):UAC.ShellExecute ""%~s0"", ""%var% %var2%"", """", ""runas"", 1:self.close</script></body></html>"
		exit
	)
goto :eof
REM ==================================================================================