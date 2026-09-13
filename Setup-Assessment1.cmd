@echo off
setlocal
rem This beginner-friendly launcher lets File Explorer start the PowerShell setup.
rem -NoProfile avoids unrelated local PowerShell customisations changing the result.
rem -ExecutionPolicy Bypass applies only to this one setup process; it does not
rem change Windows security settings permanently.
echo.
echo BFC Advanced Games Programming - Assessment 1 setup
echo Starting the checked setup script. Please read this window until it finishes.
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Setup-Assessment1.ps1"
set "BFC_SETUP_EXIT=%ERRORLEVEL%"
echo.
if "%BFC_SETUP_EXIT%"=="0" (
    echo Setup finished successfully.
) else (
    echo Setup stopped with exit code %BFC_SETUP_EXIT%. Keep this window open and show the message to your lecturer or IT.
)
rem Double-clicking normally starts cmd.exe with /c. Keep that window open so
rem beginners can read the result; /NoPause avoids this when wanted in a terminal.
echo %CMDCMDLINE% | findstr /i /c:"/c" >nul
if not errorlevel 1 if /i not "%~1"=="/NoPause" pause
exit /b %BFC_SETUP_EXIT%
