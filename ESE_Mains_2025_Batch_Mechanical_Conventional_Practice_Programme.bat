@echo off
:: Enable ANSI escape sequences
for /f %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"

setlocal enabledelayedexpansion

:: Environment Variables
set "REQUIRED_EXES=curl.exe N_m3u8DL-RE.exe ffmpeg.exe"
set "MISSING_EXES="
set "DOWNLOAD_DIR=C:\PWJarvis"
set "CURRENT_DIR=%CD%"

:: Check Required Executables
echo !ESC![33m[STATUS]!ESC![0m Checking system requirements...
echo -----------------------------------------------------------
for %%E in (%REQUIRED_EXES%) do (
    where %%E >nul 2>&1
    if !errorlevel! neq 0 (
        echo !ESC![31m[MISSING]!ESC![0m %%E
        set "MISSING_EXES=!MISSING_EXES! %%E"
    ) else (
        echo !ESC![32m[FOUND]!ESC![0m %%E
    )
)

:: Setup Environment if Needed
if not "!MISSING_EXES!"=="" (
    echo.
    echo !ESC![33m[ACTION]!ESC![0m Setting up missing components...
    if not exist "%DOWNLOAD_DIR%" (
        mkdir "%DOWNLOAD_DIR%"
        echo !ESC![32m[CREATED]!ESC![0m %DOWNLOAD_DIR%
    )
    pushd "%CURRENT_DIR%"
    cd /d "%DOWNLOAD_DIR%"
    for %%E in (%MISSING_EXES%) do (
        echo !ESC![33m[DOWNLOADING]!ESC![0m %%E
        set "exe=%%E"
        set "base_url=https://github.com/mrotaku12/files/raw/refs/heads/main/"
        set "url=!base_url!%%E"
        
        if "!exe!"=="curl.exe" (
            :: Download curl using PowerShell
            powershell -Command "Invoke-WebRequest -Uri '!url!' -OutFile '!exe!'"
        ) else (
            :: Check if curl is available
            where curl.exe >nul 2>&1
            if !errorlevel! equ 0 (
                :: Use curl to download the executable
                curl -L "!url!" -o "!exe!"
            ) else (
                :: Fallback to PowerShell
                powershell -Command "Invoke-WebRequest -Uri '!url!' -OutFile '!exe!'"
            )
        )
        if !errorlevel! equ 0 (
            echo !ESC![32m[SUCCESS]!ESC![0m %%E
        ) else (
            echo !ESC![31m[ERROR]!ESC![0m Failed to download %%E
        )
    )
    echo.
    echo !ESC![33m[STATUS]!ESC![0m Updating system path...
    for /f "tokens=2*" %%A in ('reg query HKCU\Environment /v PATH 2^>nul') do set "CURRENT_USER_PATH=%%B"
    echo !CURRENT_USER_PATH! | find /i "%DOWNLOAD_DIR%" >nul
    if !errorlevel! neq 0 (
        if defined CURRENT_USER_PATH (
            reg add HKCU\Environment /v PATH /t REG_EXPAND_SZ /d "%DOWNLOAD_DIR%;!CURRENT_USER_PATH!" /f
        ) else (
            reg add HKCU\Environment /v PATH /t REG_EXPAND_SZ /d "%DOWNLOAD_DIR%" /f
        )
        powershell -Command "[Environment]::SetEnvironmentVariable('PATH', [Environment]::GetEnvironmentVariable('PATH', 'User'), 'User')"
        echo !ESC![32m[SUCCESS]!ESC![0m Path updated - restart may be required
    )
    set "PATH=%DOWNLOAD_DIR%;%PATH%"
    popd
    echo.
    echo !ESC![32m[READY]!ESC![0m Environment setup complete
)

:: Check and Enable Long Path Support
echo !ESC![33m[STATUS]!ESC![0m Checking long path support...
reg query "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v LongPathsEnabled | find "0x1" >nul
if !errorlevel! equ 0 (
    echo !ESC![32m[ENABLED]!ESC![0m Long path support is already active
) else (
    echo !ESC![33m[ACTION]!ESC![0m Enabling long path support...
    powershell -Command "Start-Process reg -ArgumentList 'add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v LongPathsEnabled /t REG_DWORD /d 1 /f' -Verb runAs"
    echo !ESC![33m[NOTE]!ESC![0m System restart required for long path support to take effect
    echo.
    echo !ESC![33m[ACTION]!ESC![0m Press any key to restart your PC...
    pause >nul
    shutdown /r /t 0
    exit
)

cls
set "batch=ESE Mains 2025 Batch - Mechanical -Conventional Practice Programme"
mkdir "%batch%" 2>nul
cd /d "%batch%"
set "BATCH_ROOT=%CD%"
echo.
echo !ESC![33m[PROGRESS]!ESC![0m Working in: %batch%
echo -----------------------------------------------------------

echo.
echo -----------------------------------------------------------
echo !ESC![34m[SUBJECT]!ESC![0m Fluid Mechanics
echo -----------------------------------------------------------
mkdir "Fluid Mechanics" 2>nul
cd /d "Fluid Mechanics"

echo.
echo !ESC![35m[CHAPTER]!ESC![0m Lecture Planner - -Only PDF
echo -----------------------------------------------------------
mkdir "Lecture Planner - -Only PDF" 2>nul
cd /d "Lecture Planner - -Only PDF"
mkdir "Notes" 2>nul
set "note_0=Lecture Planner  Fluid Mechanics -ESE Mains"

echo.
if not exist "Notes\!note_0!.pdf" (
    title Downloading: !note_0!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_0!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Fluid Mechanics\Lecture Planner - -Only PDF\Notes\!note_0!.pdf"
    curl -L -o "\\?\!full_path!" "https://d2bps9p1kiy4ka.cloudfront.net/5eb393ee95fab7468a79d189/22d22d49-982a-4c34-9f34-6d88b94093dd.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_0!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_0!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_0!.pdf
    title File Exists: !note_0!
)
cd ..

echo.
echo !ESC![35m[CHAPTER]!ESC![0m ESE Mains Practice Questions
echo -----------------------------------------------------------
mkdir "ESE Mains Practice Questions" 2>nul
cd /d "ESE Mains Practice Questions"
mkdir "Lectures" 2>nul
set "lecture_0=Fluid Mechanics 07 - Fluid Mechanics -Part 07- - Extra Class"

echo.
if not exist "Lectures\!lecture_0!.mp4" (
    title Downloading: !lecture_0!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_0!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiYTQyMDdhN2ItYTM2Yy00NmU0LThhZmItZDY4ODkzMmQyYWFhIiwiZXhwIjoxNzU2MDcwOTkzfQ.no_KwcykqO18k0PxIJ2jDibck_4usAGPhlByNS9KAqs/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_0!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_0!.ts" (
        ren "Lectures\!lecture_0!.ts" "!lecture_0!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_0!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_0!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_0!.mp4
    title File Exists: !lecture_0!
)
set "lecture_1=Fluid Mechanics 06 - Fluid Mechanics -Part 06- - Extra Class"

echo.
if not exist "Lectures\!lecture_1!.mp4" (
    title Downloading: !lecture_1!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_1!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiMDVlNWY2YjItYTAxZC00MDQ5LWE3YTYtYTg5NGExMWM2YWU0IiwiZXhwIjoxNzU2MDcwOTkzfQ.VD8B1SxkQtvPP5JkAUKxNZSplyDy7VKqOW9pgroovO4/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_1!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_1!.ts" (
        ren "Lectures\!lecture_1!.ts" "!lecture_1!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_1!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_1!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_1!.mp4
    title File Exists: !lecture_1!
)
set "lecture_2=Fluid Mechanics 05 - Fluid Mechanics -Part 05"

echo.
if not exist "Lectures\!lecture_2!.mp4" (
    title Downloading: !lecture_2!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_2!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiMTFkZmFiZDUtMjUxZC00NWUwLThiNjMtOTEyNDg0YjkzOGE1IiwiZXhwIjoxNzU2MDcwOTkzfQ.Jie0lhkyiraSa_Q_F67Zw0AnBze9u0hPDgKUMOuQd-M/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_2!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_2!.ts" (
        ren "Lectures\!lecture_2!.ts" "!lecture_2!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_2!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_2!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_2!.mp4
    title File Exists: !lecture_2!
)
set "lecture_3=Fluid Mechanics 04 - Fluid Mechanics -Part 04"

echo.
if not exist "Lectures\!lecture_3!.mp4" (
    title Downloading: !lecture_3!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_3!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiMDIxMjEzZjQtYmYwMS00ZTBmLWE0NzUtMWFiMTA3OWU2YzM0IiwiZXhwIjoxNzU2MDcwOTkzfQ.4oxAr24S9jXM4en-P3z04pTri0GNspMzsmCesAsCXyM/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_3!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_3!.ts" (
        ren "Lectures\!lecture_3!.ts" "!lecture_3!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_3!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_3!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_3!.mp4
    title File Exists: !lecture_3!
)
set "lecture_4=Fluid Mechanics 03 - Fluid Mechanics -Part 03- - Rescheduled @11-05AM"

echo.
if not exist "Lectures\!lecture_4!.mp4" (
    title Downloading: !lecture_4!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_4!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiMjM3OTg5M2ItMTYwNy00MjU2LWEyZGMtMWNlMTE5YWM4ZTQxIiwiZXhwIjoxNzU2MDcwOTkzfQ.HdCJ4d9o8XpRu535ux5ex2j0_sGRMDVyUPuoYbU85co/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_4!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_4!.ts" (
        ren "Lectures\!lecture_4!.ts" "!lecture_4!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_4!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_4!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_4!.mp4
    title File Exists: !lecture_4!
)
set "lecture_5=Fluid Mechanics 02 - Fluid Mechanics -Part 02"

echo.
if not exist "Lectures\!lecture_5!.mp4" (
    title Downloading: !lecture_5!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_5!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiZWE2YTQ0MTAtMjEzZC00YmEzLWFjMjItNzFhZThhMDljNmRjIiwiZXhwIjoxNzU2MDcwOTkzfQ.VCFZ7V4AXEjbwIW1yGYwqjC6qgLw-LfDynllJN92iCI/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_5!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_5!.ts" (
        ren "Lectures\!lecture_5!.ts" "!lecture_5!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_5!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_5!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_5!.mp4
    title File Exists: !lecture_5!
)
set "lecture_6=Fluid Mechanics 01 - Fluid Mechanics -Part 01"

echo.
if not exist "Lectures\!lecture_6!.mp4" (
    title Downloading: !lecture_6!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_6!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiNGU2MWIxYzEtOWM4Ni00YzA5LWFlMDUtZjkxZDc0NWQ2Y2E5IiwiZXhwIjoxNzU2MDcwOTkzfQ.ltWBfKM5LML3YPMDI8Ff9pZk3yJ890M__CnuIcelq5c/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_6!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_6!.ts" (
        ren "Lectures\!lecture_6!.ts" "!lecture_6!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_6!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_6!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_6!.mp4
    title File Exists: !lecture_6!
)
mkdir "Notes" 2>nul
set "note_1=Fluid Mechanics 07  Class Notes"

echo.
if not exist "Notes\!note_1!.pdf" (
    title Downloading: !note_1!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_1!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Fluid Mechanics\ESE Mains Practice Questions\Notes\!note_1!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/91534f72-1fab-4b98-814c-71d62d3046ae.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_1!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_1!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_1!.pdf
    title File Exists: !note_1!
)
set "note_2=Fluid Mechanics 06  Class Notes"

echo.
if not exist "Notes\!note_2!.pdf" (
    title Downloading: !note_2!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_2!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Fluid Mechanics\ESE Mains Practice Questions\Notes\!note_2!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/07515b06-ccf2-4fe2-8af9-5cb57de5b087.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_2!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_2!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_2!.pdf
    title File Exists: !note_2!
)
set "note_3=Fluid Mechanics 05  Class Notes"

echo.
if not exist "Notes\!note_3!.pdf" (
    title Downloading: !note_3!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_3!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Fluid Mechanics\ESE Mains Practice Questions\Notes\!note_3!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/a32ce01f-d623-4ac7-ae7d-474d26fa1e6e.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_3!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_3!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_3!.pdf
    title File Exists: !note_3!
)
set "note_4=Fluid Mechanics 04  Class Notes"

echo.
if not exist "Notes\!note_4!.pdf" (
    title Downloading: !note_4!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_4!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Fluid Mechanics\ESE Mains Practice Questions\Notes\!note_4!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/3e574e1c-5d62-49b3-92a5-7067521cb33b.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_4!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_4!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_4!.pdf
    title File Exists: !note_4!
)
set "note_5=Fluid Mechanics 03  Class Notes"

echo.
if not exist "Notes\!note_5!.pdf" (
    title Downloading: !note_5!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_5!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Fluid Mechanics\ESE Mains Practice Questions\Notes\!note_5!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/f5c971c1-8d53-483e-a8d7-242ef24b1668.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_5!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_5!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_5!.pdf
    title File Exists: !note_5!
)
set "note_6=Fluid Mechanics 02  Class Notes"

echo.
if not exist "Notes\!note_6!.pdf" (
    title Downloading: !note_6!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_6!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Fluid Mechanics\ESE Mains Practice Questions\Notes\!note_6!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/a919cb4c-6203-48e3-b1a4-467254cc766b.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_6!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_6!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_6!.pdf
    title File Exists: !note_6!
)
set "note_7=Fluid Mechanics 01  Class Notes"

echo.
if not exist "Notes\!note_7!.pdf" (
    title Downloading: !note_7!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_7!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Fluid Mechanics\ESE Mains Practice Questions\Notes\!note_7!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/25bffc7e-e469-43de-92e2-0f3ee718771e.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_7!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_7!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_7!.pdf
    title File Exists: !note_7!
)
mkdir "DPP_Notes" 2>nul
set "dpp_note_0=Fluid Mechanics  Theoretical Question Bank"

echo.
if not exist "DPP_Notes\!dpp_note_0!.pdf" (
    title Downloading: !dpp_note_0!
    echo !ESC![33m[DOWNLOAD]!ESC![0m DPP Notes: !dpp_note_0!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Fluid Mechanics\ESE Mains Practice Questions\DPP_Notes\!dpp_note_0!.pdf"
    curl -L -o "\\?\!full_path!" "https://d2bps9p1kiy4ka.cloudfront.net/5eb393ee95fab7468a79d189/73c75675-0657-4c5c-b009-e540db17fd62.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !dpp_note_0!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !dpp_note_0!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !dpp_note_0!.pdf
    title File Exists: !dpp_note_0!
)
cd ..
cd ..

echo.
echo -----------------------------------------------------------
echo !ESC![34m[SUBJECT]!ESC![0m Hydraulic Machine
echo -----------------------------------------------------------
mkdir "Hydraulic Machine" 2>nul
cd /d "Hydraulic Machine"

echo.
echo !ESC![35m[CHAPTER]!ESC![0m Lecture Planner - -Only PDF
echo -----------------------------------------------------------
mkdir "Lecture Planner - -Only PDF" 2>nul
cd /d "Lecture Planner - -Only PDF"
mkdir "Notes" 2>nul
set "note_8=Lecture Planner  Hydraulic Machine"

echo.
if not exist "Notes\!note_8!.pdf" (
    title Downloading: !note_8!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_8!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Hydraulic Machine\Lecture Planner - -Only PDF\Notes\!note_8!.pdf"
    curl -L -o "\\?\!full_path!" "https://d2bps9p1kiy4ka.cloudfront.net/5eb393ee95fab7468a79d189/40fa9503-c588-456f-88cf-48518d391952.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_8!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_8!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_8!.pdf
    title File Exists: !note_8!
)
cd ..
cd ..

echo.
echo -----------------------------------------------------------
echo !ESC![34m[SUBJECT]!ESC![0m Strength of Materials
echo -----------------------------------------------------------
mkdir "Strength of Materials" 2>nul
cd /d "Strength of Materials"

echo.
echo !ESC![35m[CHAPTER]!ESC![0m Lecture Planner - -Only PDF
echo -----------------------------------------------------------
mkdir "Lecture Planner - -Only PDF" 2>nul
cd /d "Lecture Planner - -Only PDF"
mkdir "Notes" 2>nul
set "note_9=Strength of Materials Lecture Planner"

echo.
if not exist "Notes\!note_9!.pdf" (
    title Downloading: !note_9!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_9!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Strength of Materials\Lecture Planner - -Only PDF\Notes\!note_9!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/541d4728-058f-454c-be2e-93a786a83733.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_9!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_9!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_9!.pdf
    title File Exists: !note_9!
)
cd ..

echo.
echo !ESC![35m[CHAPTER]!ESC![0m ESE Main Practice Question
echo -----------------------------------------------------------
mkdir "ESE Main Practice Question" 2>nul
cd /d "ESE Main Practice Question"
mkdir "Lectures" 2>nul
set "lecture_7=Strength of Materials 11 - Strength of Materials -Part 11"

echo.
if not exist "Lectures\!lecture_7!.mp4" (
    title Downloading: !lecture_7!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_7!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiY2JjNjkyMWMtNjRiNy00MzY2LWE2MDMtYmY2MmU0YTlhZmZlIiwiZXhwIjoxNzU2MDcwOTkzfQ.fC5_hmxr6ojBgNDIUcW3qjGI6ylNCLOZGuo0NA-Wc9g/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_7!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_7!.ts" (
        ren "Lectures\!lecture_7!.ts" "!lecture_7!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_7!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_7!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_7!.mp4
    title File Exists: !lecture_7!
)
set "lecture_8=Strength of Materials 10 - Strength of Materials -Part 10"

echo.
if not exist "Lectures\!lecture_8!.mp4" (
    title Downloading: !lecture_8!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_8!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiYzcyODYzZGYtNjkwYS00MjQ4LTg4YmYtNzlhZjQ2OGNmZjliIiwiZXhwIjoxNzU2MDcwOTkzfQ.pQwRRlPk4aeM7lMRAo559mWNcL8nai3MDkm3CMZOE40/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_8!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_8!.ts" (
        ren "Lectures\!lecture_8!.ts" "!lecture_8!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_8!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_8!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_8!.mp4
    title File Exists: !lecture_8!
)
set "lecture_9=Strength of Materials 09 - Strength of Materials -Part 09"

echo.
if not exist "Lectures\!lecture_9!.mp4" (
    title Downloading: !lecture_9!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_9!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiMmI0NGIyZGEtNjQ4Yi00MGVhLWI5OTctYjI4NDMwYzczODk0IiwiZXhwIjoxNzU2MDcwOTkzfQ.a3trUFCK3VaIKnsqamGsDzTSrT9qn5mr97yNuyo7LF0/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_9!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_9!.ts" (
        ren "Lectures\!lecture_9!.ts" "!lecture_9!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_9!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_9!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_9!.mp4
    title File Exists: !lecture_9!
)
set "lecture_10=Strength of Materials 08 - Strength of Materials -Part 08"

echo.
if not exist "Lectures\!lecture_10!.mp4" (
    title Downloading: !lecture_10!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_10!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiOTVjOWU1ZWMtMjEyNy00NTU0LWI0MDUtNzM3MzI5MmJkYzgzIiwiZXhwIjoxNzU2MDcwOTkzfQ.4YWOsuY3xBb2CnoDFtYU7S9Uq54oUTmfm7v9TVVvy2k/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_10!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_10!.ts" (
        ren "Lectures\!lecture_10!.ts" "!lecture_10!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_10!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_10!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_10!.mp4
    title File Exists: !lecture_10!
)
set "lecture_11=Strength of Materials 07 - Strength of Materials -Part 07"

echo.
if not exist "Lectures\!lecture_11!.mp4" (
    title Downloading: !lecture_11!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_11!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiOTQ4NWFkODgtMWQ0MS00YjJkLTk4N2QtOTYzZjM0OGQyZjBjIiwiZXhwIjoxNzU2MDcwOTkzfQ.LExgHvj4fX2d-0OV0zijgND9WHv3k3UDRDOJVmEbZQk/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_11!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_11!.ts" (
        ren "Lectures\!lecture_11!.ts" "!lecture_11!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_11!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_11!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_11!.mp4
    title File Exists: !lecture_11!
)
set "lecture_12=Strength of Materials 06 - Strength of Materials -Part 06"

echo.
if not exist "Lectures\!lecture_12!.mp4" (
    title Downloading: !lecture_12!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_12!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiZTkwYjdmMmYtMzJjZC00ZDhmLThlY2MtNTFhOTU4OTVkNmJkIiwiZXhwIjoxNzU2MDcwOTkzfQ.0yIn-KYvSSLhvbEUoz0kpmbe0LNWoONioS3JoEV6PCQ/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_12!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_12!.ts" (
        ren "Lectures\!lecture_12!.ts" "!lecture_12!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_12!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_12!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_12!.mp4
    title File Exists: !lecture_12!
)
set "lecture_13=Strength of Materials 05 -  Strength of Materials -Part 05"

echo.
if not exist "Lectures\!lecture_13!.mp4" (
    title Downloading: !lecture_13!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_13!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiOWNiYWNjZTgtMzc1Yy00ZDA4LWEzMDItZDBiYmI2YTQxYWU2IiwiZXhwIjoxNzU2MDcwOTkzfQ.G6OBVUWBYkNPTp6kfoMRKOtgHciuCrfRNKnLT1h6yn8/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_13!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_13!.ts" (
        ren "Lectures\!lecture_13!.ts" "!lecture_13!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_13!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_13!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_13!.mp4
    title File Exists: !lecture_13!
)
set "lecture_14=Strength of Materials 04 -  Strength of Materials -Part 04"

echo.
if not exist "Lectures\!lecture_14!.mp4" (
    title Downloading: !lecture_14!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_14!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiNzk0ZjBkNTUtYzdiYi00MDc3LTkzMjYtMGViODRkNzA3ZjIyIiwiZXhwIjoxNzU2MDcwOTkzfQ.iIFYC7zzSNmt4Q8kZX7D52bO26xbeKmFCQmxjLB5ajc/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_14!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_14!.ts" (
        ren "Lectures\!lecture_14!.ts" "!lecture_14!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_14!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_14!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_14!.mp4
    title File Exists: !lecture_14!
)
set "lecture_15=Strength of Materials 03 -  Strength of Materials -Part 03"

echo.
if not exist "Lectures\!lecture_15!.mp4" (
    title Downloading: !lecture_15!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_15!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiMGVkZmRkODQtOThjMS00NDhlLTg0OGMtNjZkZGIxNWU0OTM1IiwiZXhwIjoxNzU2MDcwOTkzfQ.JWIelARN6h5Q7j8fxUJ8pS7JxHlwwk_CkckNW-wRt1E/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_15!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_15!.ts" (
        ren "Lectures\!lecture_15!.ts" "!lecture_15!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_15!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_15!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_15!.mp4
    title File Exists: !lecture_15!
)
set "lecture_16=Strength of Materials 02 -  Strength of Materials -Part 02"

echo.
if not exist "Lectures\!lecture_16!.mp4" (
    title Downloading: !lecture_16!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_16!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiMzVlY2YwNzUtZTM0MS00MDMzLWIyY2UtMTFjM2MwZGZhNWI5IiwiZXhwIjoxNzU2MDcwOTkzfQ.nibBR6-29EsPufg6fnyrtqQ7b4h58DqmKmPnc2GV97M/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_16!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_16!.ts" (
        ren "Lectures\!lecture_16!.ts" "!lecture_16!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_16!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_16!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_16!.mp4
    title File Exists: !lecture_16!
)
set "lecture_17=Strength of Materials 01 -  Strength of Materials -Part 01"

echo.
if not exist "Lectures\!lecture_17!.mp4" (
    title Downloading: !lecture_17!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_17!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiY2MwYmVmZWYtNzk5Ni00ZGQxLThjNGQtNjI3YzJiODI3YTVkIiwiZXhwIjoxNzU2MDcwOTkzfQ.bCDfODYzBwYCDNT-YEIbsCfSSkXgpPYe2652CMtZyic/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_17!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_17!.ts" (
        ren "Lectures\!lecture_17!.ts" "!lecture_17!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_17!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_17!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_17!.mp4
    title File Exists: !lecture_17!
)
mkdir "Notes" 2>nul
set "note_10=Strength of Materials 11 Class Notes"

echo.
if not exist "Notes\!note_10!.pdf" (
    title Downloading: !note_10!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_10!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Strength of Materials\ESE Main Practice Question\Notes\!note_10!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/18815b70-feae-4d32-88ea-f8d7d7c2e4bb.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_10!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_10!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_10!.pdf
    title File Exists: !note_10!
)
set "note_11=Strength of Materials 10 Class Notes"

echo.
if not exist "Notes\!note_11!.pdf" (
    title Downloading: !note_11!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_11!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Strength of Materials\ESE Main Practice Question\Notes\!note_11!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/efd714f9-7744-4351-ba0b-33955ad7295f.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_11!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_11!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_11!.pdf
    title File Exists: !note_11!
)
set "note_12=Strength of Materials 09 Class Notes"

echo.
if not exist "Notes\!note_12!.pdf" (
    title Downloading: !note_12!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_12!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Strength of Materials\ESE Main Practice Question\Notes\!note_12!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/bbe201c4-aee7-4596-90d4-c48e7e18e31d.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_12!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_12!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_12!.pdf
    title File Exists: !note_12!
)
set "note_13=Strength of Materials 08 Class Notes"

echo.
if not exist "Notes\!note_13!.pdf" (
    title Downloading: !note_13!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_13!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Strength of Materials\ESE Main Practice Question\Notes\!note_13!.pdf"
    curl -L -o "\\?\!full_path!" "https://d2bps9p1kiy4ka.cloudfront.net/5eb393ee95fab7468a79d189/8af84f46-17e4-419a-962f-a11546977323.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_13!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_13!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_13!.pdf
    title File Exists: !note_13!
)
set "note_14=Strength of Materials 07 Class Notes"

echo.
if not exist "Notes\!note_14!.pdf" (
    title Downloading: !note_14!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_14!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Strength of Materials\ESE Main Practice Question\Notes\!note_14!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/32f8656f-4a26-4d00-bf0c-acd02d9e722f.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_14!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_14!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_14!.pdf
    title File Exists: !note_14!
)
set "note_15=Strength of Materials 06 Class Notes"

echo.
if not exist "Notes\!note_15!.pdf" (
    title Downloading: !note_15!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_15!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Strength of Materials\ESE Main Practice Question\Notes\!note_15!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/46174dac-87ad-4c7c-814b-c8267fc7fa41.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_15!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_15!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_15!.pdf
    title File Exists: !note_15!
)
set "note_16=Strength of Materials 05 Class Notes"

echo.
if not exist "Notes\!note_16!.pdf" (
    title Downloading: !note_16!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_16!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Strength of Materials\ESE Main Practice Question\Notes\!note_16!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/3489d4d8-722b-494e-9da4-bd319490ee6e.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_16!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_16!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_16!.pdf
    title File Exists: !note_16!
)
set "note_17=Strength of Materials 04 Class Notes"

echo.
if not exist "Notes\!note_17!.pdf" (
    title Downloading: !note_17!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_17!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Strength of Materials\ESE Main Practice Question\Notes\!note_17!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/3d92948f-d6ab-4040-98bb-6d19e5b5be6c.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_17!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_17!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_17!.pdf
    title File Exists: !note_17!
)
set "note_18=Strength of Materials 03 Class Notes"

echo.
if not exist "Notes\!note_18!.pdf" (
    title Downloading: !note_18!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_18!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Strength of Materials\ESE Main Practice Question\Notes\!note_18!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/7158cf21-aa5a-45fa-83b2-04f451e7e4c6.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_18!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_18!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_18!.pdf
    title File Exists: !note_18!
)
set "note_19=Strength of Materials 02 Class Notes"

echo.
if not exist "Notes\!note_19!.pdf" (
    title Downloading: !note_19!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_19!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Strength of Materials\ESE Main Practice Question\Notes\!note_19!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/d8213313-7c91-4111-876c-8777951cbe16.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_19!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_19!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_19!.pdf
    title File Exists: !note_19!
)
set "note_20=Strength of Materials 01 Class Notes"

echo.
if not exist "Notes\!note_20!.pdf" (
    title Downloading: !note_20!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_20!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Strength of Materials\ESE Main Practice Question\Notes\!note_20!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/4edbd5ed-479e-4ef0-80a4-a0652199027d.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_20!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_20!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_20!.pdf
    title File Exists: !note_20!
)
mkdir "DPP_Notes" 2>nul
set "dpp_note_1=Strength of Materials Theoretical Question Bank"

echo.
if not exist "DPP_Notes\!dpp_note_1!.pdf" (
    title Downloading: !dpp_note_1!
    echo !ESC![33m[DOWNLOAD]!ESC![0m DPP Notes: !dpp_note_1!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Strength of Materials\ESE Main Practice Question\DPP_Notes\!dpp_note_1!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/fecbdf12-90b6-49e1-8914-c081b26e680f.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !dpp_note_1!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !dpp_note_1!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !dpp_note_1!.pdf
    title File Exists: !dpp_note_1!
)
cd ..
cd ..

echo.
echo -----------------------------------------------------------
echo !ESC![34m[SUBJECT]!ESC![0m Heat transfer
echo -----------------------------------------------------------
mkdir "Heat transfer" 2>nul
cd /d "Heat transfer"

echo.
echo !ESC![35m[CHAPTER]!ESC![0m Lecture Planner - -Only PDF
echo -----------------------------------------------------------
mkdir "Lecture Planner - -Only PDF" 2>nul
cd /d "Lecture Planner - -Only PDF"
mkdir "Notes" 2>nul
set "note_21=Heat Transfer Lecture Planner"

echo.
if not exist "Notes\!note_21!.pdf" (
    title Downloading: !note_21!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_21!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Heat transfer\Lecture Planner - -Only PDF\Notes\!note_21!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/2848810d-d137-42b8-ad34-1bb390bb75eb.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_21!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_21!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_21!.pdf
    title File Exists: !note_21!
)
cd ..

echo.
echo !ESC![35m[CHAPTER]!ESC![0m ESE Main Practice Question
echo -----------------------------------------------------------
mkdir "ESE Main Practice Question" 2>nul
cd /d "ESE Main Practice Question"
mkdir "Lectures" 2>nul
set "lecture_18=Heat Transfer 06 - Heat Transfer -Part 06"

echo.
if not exist "Lectures\!lecture_18!.mp4" (
    title Downloading: !lecture_18!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_18!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiMzA1M2JlNmMtOTAxMi00ZWE3LWFlNmYtZWRlN2JlYWRhMzA3IiwiZXhwIjoxNzU2MDcwOTkzfQ.xuqelRZ50h07S3AgMu8A-tfmG66JJzCyfGKAoJWzCVs/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_18!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_18!.ts" (
        ren "Lectures\!lecture_18!.ts" "!lecture_18!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_18!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_18!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_18!.mp4
    title File Exists: !lecture_18!
)
set "lecture_19=Heat Transfer 05 - Heat Transfer -Part 05"

echo.
if not exist "Lectures\!lecture_19!.mp4" (
    title Downloading: !lecture_19!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_19!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiOWE0YWQ3MjgtNTQ5ZC00YTVkLWJkMmUtMjRkMDFhOThjZWUxIiwiZXhwIjoxNzU2MDcwOTkzfQ.izDRKqAND9dJAzmwKF7674-9ecRH-69CmE_cCX5gjc8/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_19!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_19!.ts" (
        ren "Lectures\!lecture_19!.ts" "!lecture_19!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_19!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_19!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_19!.mp4
    title File Exists: !lecture_19!
)
set "lecture_20=Heat Transfer 04 - Heat Transfer -Part 04"

echo.
if not exist "Lectures\!lecture_20!.mp4" (
    title Downloading: !lecture_20!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_20!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiNzIzYzBjNzYtZjliYi00NGM4LTg0NzYtOWIwNzQ3YTdjZDM0IiwiZXhwIjoxNzU2MDcwOTkzfQ.M6zxqUA5MOKKkQvcppdg8JRs3DIj5Qi-EGmdwX69MUM/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_20!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_20!.ts" (
        ren "Lectures\!lecture_20!.ts" "!lecture_20!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_20!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_20!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_20!.mp4
    title File Exists: !lecture_20!
)
set "lecture_21=Heat Transfer 03 - Heat Transfer -Part 03"

echo.
if not exist "Lectures\!lecture_21!.mp4" (
    title Downloading: !lecture_21!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_21!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiYTcyZmU2NjItMDVmNi00ZDRmLWIzNjAtZTQ5MDYwNzkxNWY4IiwiZXhwIjoxNzU2MDcwOTkzfQ.phC91a9xuoyzcF5dqVuqNSpfN1QOQG5mJ8vE1qbvW-4/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_21!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_21!.ts" (
        ren "Lectures\!lecture_21!.ts" "!lecture_21!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_21!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_21!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_21!.mp4
    title File Exists: !lecture_21!
)
set "lecture_22=Heat Transfer 02- Heat Transfer -Part 02"

echo.
if not exist "Lectures\!lecture_22!.mp4" (
    title Downloading: !lecture_22!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_22!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiM2NkZGZkMmYtZTI2NC00Y2ViLWEwY2EtN2VhNWM2NTU4NjQwIiwiZXhwIjoxNzU2MDcwOTkzfQ.vAaWrg-AXF9g35QSUKNGIMpsv5vuFrnm5d3hQtyZTac/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_22!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_22!.ts" (
        ren "Lectures\!lecture_22!.ts" "!lecture_22!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_22!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_22!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_22!.mp4
    title File Exists: !lecture_22!
)
set "lecture_23=Heat Transfer 01 - Heat Transfer -Part 01"

echo.
if not exist "Lectures\!lecture_23!.mp4" (
    title Downloading: !lecture_23!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_23!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiYmE4MTNlYWMtMzg4OC00OWEwLTk5OGYtOTk5YzRlNWFhZWY2IiwiZXhwIjoxNzU2MDcwOTkzfQ.zhO4mnhMLbBqTvm6xvbnaGxRpvXwND5arrlYdnzuTmI/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_23!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_23!.ts" (
        ren "Lectures\!lecture_23!.ts" "!lecture_23!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_23!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_23!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_23!.mp4
    title File Exists: !lecture_23!
)
mkdir "Notes" 2>nul
set "note_22=Heat Transfer 06  Class Notes"

echo.
if not exist "Notes\!note_22!.pdf" (
    title Downloading: !note_22!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_22!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Heat transfer\ESE Main Practice Question\Notes\!note_22!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/b6f223aa-a9fa-49a2-b4d9-d50f72777934.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_22!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_22!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_22!.pdf
    title File Exists: !note_22!
)
set "note_23=Heat Transfer 05 Class Notes"

echo.
if not exist "Notes\!note_23!.pdf" (
    title Downloading: !note_23!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_23!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Heat transfer\ESE Main Practice Question\Notes\!note_23!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/0fdf1071-ff8f-4b6f-ad67-37e4b923132d.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_23!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_23!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_23!.pdf
    title File Exists: !note_23!
)
set "note_24=Heat Transfer 04 Class Notes"

echo.
if not exist "Notes\!note_24!.pdf" (
    title Downloading: !note_24!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_24!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Heat transfer\ESE Main Practice Question\Notes\!note_24!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/23c6a5f5-7eb4-4021-ac3e-46cf2511a372.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_24!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_24!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_24!.pdf
    title File Exists: !note_24!
)
set "note_25=Heat Transfer 03 Class Notes"

echo.
if not exist "Notes\!note_25!.pdf" (
    title Downloading: !note_25!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_25!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Heat transfer\ESE Main Practice Question\Notes\!note_25!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/790751f1-dfaf-4d1c-95a1-2e7dadae2efb.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_25!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_25!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_25!.pdf
    title File Exists: !note_25!
)
set "note_26=Heat Transfer 02 Class Notes"

echo.
if not exist "Notes\!note_26!.pdf" (
    title Downloading: !note_26!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_26!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Heat transfer\ESE Main Practice Question\Notes\!note_26!.pdf"
    curl -L -o "\\?\!full_path!" "https://d2bps9p1kiy4ka.cloudfront.net/5eb393ee95fab7468a79d189/86fb298e-cf80-42e0-92b1-e454e4de5963.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_26!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_26!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_26!.pdf
    title File Exists: !note_26!
)
set "note_27=Heat Transfer 01 Class Notes"

echo.
if not exist "Notes\!note_27!.pdf" (
    title Downloading: !note_27!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_27!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Heat transfer\ESE Main Practice Question\Notes\!note_27!.pdf"
    curl -L -o "\\?\!full_path!" "https://d2bps9p1kiy4ka.cloudfront.net/5eb393ee95fab7468a79d189/a60ead31-ea13-4978-98bc-ce945434d531.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_27!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_27!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_27!.pdf
    title File Exists: !note_27!
)
mkdir "DPP_Notes" 2>nul
set "dpp_note_2=Heat Transfer Theoretical Question Bank"

echo.
if not exist "DPP_Notes\!dpp_note_2!.pdf" (
    title Downloading: !dpp_note_2!
    echo !ESC![33m[DOWNLOAD]!ESC![0m DPP Notes: !dpp_note_2!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Heat transfer\ESE Main Practice Question\DPP_Notes\!dpp_note_2!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/20d546f2-0428-44d1-a6b8-3d73141e6f5c.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !dpp_note_2!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !dpp_note_2!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !dpp_note_2!.pdf
    title File Exists: !dpp_note_2!
)
cd ..
cd ..

echo.
echo -----------------------------------------------------------
echo !ESC![34m[SUBJECT]!ESC![0m Material Science
echo -----------------------------------------------------------
mkdir "Material Science" 2>nul
cd /d "Material Science"

echo.
echo !ESC![35m[CHAPTER]!ESC![0m Lecture Planner - -Only PDF
echo -----------------------------------------------------------
mkdir "Lecture Planner - -Only PDF" 2>nul
cd /d "Lecture Planner - -Only PDF"
mkdir "Notes" 2>nul
set "note_28=Lecture Planner_Material Science"

echo.
if not exist "Notes\!note_28!.pdf" (
    title Downloading: !note_28!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_28!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Material Science\Lecture Planner - -Only PDF\Notes\!note_28!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/9d8c7f7f-a287-45a6-b2cd-a92242237cce.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_28!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_28!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_28!.pdf
    title File Exists: !note_28!
)
cd ..

echo.
echo !ESC![35m[CHAPTER]!ESC![0m GATE-O-PEDIA - -Only PDF
echo -----------------------------------------------------------
mkdir "GATE-O-PEDIA - -Only PDF" 2>nul
cd /d "GATE-O-PEDIA - -Only PDF"
mkdir "Notes" 2>nul
set "note_29=Material Science_GATE-O-PEDIA"

echo.
if not exist "Notes\!note_29!.pdf" (
    title Downloading: !note_29!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_29!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Material Science\GATE-O-PEDIA - -Only PDF\Notes\!note_29!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/a6620370-636d-40d3-933c-4a6267751ff3.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_29!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_29!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_29!.pdf
    title File Exists: !note_29!
)
cd ..

echo.
echo !ESC![35m[CHAPTER]!ESC![0m PYQ Quiz
echo -----------------------------------------------------------
mkdir "PYQ Quiz" 2>nul
cd /d "PYQ Quiz"
cd ..

echo.
echo !ESC![35m[CHAPTER]!ESC![0m ESE Main Practice Question
echo -----------------------------------------------------------
mkdir "ESE Main Practice Question" 2>nul
cd /d "ESE Main Practice Question"
mkdir "Lectures" 2>nul
set "lecture_24=Material Science 04 - Material Science -Part 04"

echo.
if not exist "Lectures\!lecture_24!.mp4" (
    title Downloading: !lecture_24!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_24!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiMjE2N2YzMjMtYmEwYS00MGFkLTg1MDAtMWVkMWQ0MTZjM2I1IiwiZXhwIjoxNzU2MDcwOTkzfQ.zg5EiYixu0Ki-QJp74WOhhzDLhU6bRGN4vWA7T1s2rc/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_24!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_24!.ts" (
        ren "Lectures\!lecture_24!.ts" "!lecture_24!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_24!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_24!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_24!.mp4
    title File Exists: !lecture_24!
)
set "lecture_25=Material Science 03 - Material Science -Part 03"

echo.
if not exist "Lectures\!lecture_25!.mp4" (
    title Downloading: !lecture_25!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_25!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiZjk1NDM1MjEtYTVmMy00ZWMyLWExMjgtODA2NzZhMmNjYjRjIiwiZXhwIjoxNzU2MDcwOTkzfQ.htKV6OnJhmhdK9X1xjQvIvRN2XfiPpYgNxSOv9HFZts/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_25!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_25!.ts" (
        ren "Lectures\!lecture_25!.ts" "!lecture_25!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_25!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_25!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_25!.mp4
    title File Exists: !lecture_25!
)
set "lecture_26=Material Science 02 - Material Science -Part 02"

echo.
if not exist "Lectures\!lecture_26!.mp4" (
    title Downloading: !lecture_26!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_26!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiOTYxMGI4ZmEtN2E2MS00MWMxLWIyNmYtOWJlM2YzZjk2M2VjIiwiZXhwIjoxNzU2MDcwOTkzfQ.OFGztix4XovZZjJFBSJ_NKTv0BQFhBTlXN54KZ3MHQ8/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_26!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_26!.ts" (
        ren "Lectures\!lecture_26!.ts" "!lecture_26!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_26!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_26!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_26!.mp4
    title File Exists: !lecture_26!
)
set "lecture_27=Material Science 01 - Material Science -Part 01"

echo.
if not exist "Lectures\!lecture_27!.mp4" (
    title Downloading: !lecture_27!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_27!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiNzQwMTliMTItYTI3Zi00NGFkLWExNjYtNGJhZDk5MmE4NTEyIiwiZXhwIjoxNzU2MDcwOTkzfQ.R67raxrh6jMka24kfluYBndI14RKjeL4xx_cauw5DTE/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_27!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_27!.ts" (
        ren "Lectures\!lecture_27!.ts" "!lecture_27!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_27!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_27!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_27!.mp4
    title File Exists: !lecture_27!
)
mkdir "Notes" 2>nul
set "note_30=Material Science 04_Class Notes"

echo.
if not exist "Notes\!note_30!.pdf" (
    title Downloading: !note_30!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_30!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Material Science\ESE Main Practice Question\Notes\!note_30!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/ff2ceda0-37a0-4721-af7e-513e1b6be939.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_30!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_30!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_30!.pdf
    title File Exists: !note_30!
)
set "note_31=Material Science 03- Class Notes"

echo.
if not exist "Notes\!note_31!.pdf" (
    title Downloading: !note_31!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_31!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Material Science\ESE Main Practice Question\Notes\!note_31!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/ac3c22b3-0daa-401a-969a-77cff361d3b6.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_31!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_31!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_31!.pdf
    title File Exists: !note_31!
)
set "note_32=Material Science 02_Class Notes"

echo.
if not exist "Notes\!note_32!.pdf" (
    title Downloading: !note_32!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_32!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Material Science\ESE Main Practice Question\Notes\!note_32!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/40babe36-4648-404c-8681-a78644fac949.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_32!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_32!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_32!.pdf
    title File Exists: !note_32!
)
set "note_33=Material Science 01_Class Notes"

echo.
if not exist "Notes\!note_33!.pdf" (
    title Downloading: !note_33!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_33!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Material Science\ESE Main Practice Question\Notes\!note_33!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/3282ab0d-1603-4c43-9099-f9712def1fc5.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_33!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_33!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_33!.pdf
    title File Exists: !note_33!
)
mkdir "DPP_Notes" 2>nul
set "dpp_note_3=Material Science_Theoretical Question Bank"

echo.
if not exist "DPP_Notes\!dpp_note_3!.pdf" (
    title Downloading: !dpp_note_3!
    echo !ESC![33m[DOWNLOAD]!ESC![0m DPP Notes: !dpp_note_3!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Material Science\ESE Main Practice Question\DPP_Notes\!dpp_note_3!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/84aecd0e-a104-4df6-b27b-cbe31421912b.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !dpp_note_3!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !dpp_note_3!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !dpp_note_3!.pdf
    title File Exists: !dpp_note_3!
)
cd ..
cd ..

echo.
echo -----------------------------------------------------------
echo !ESC![34m[SUBJECT]!ESC![0m Theory of Machines and Vibrations
echo -----------------------------------------------------------
mkdir "Theory of Machines and Vibrations" 2>nul
cd /d "Theory of Machines and Vibrations"

echo.
echo !ESC![35m[CHAPTER]!ESC![0m Lecture Planner - -Only PDF
echo -----------------------------------------------------------
mkdir "Lecture Planner - -Only PDF" 2>nul
cd /d "Lecture Planner - -Only PDF"
mkdir "Notes" 2>nul
set "note_34=Theory of Machines and Vibrations Lecture Planner"

echo.
if not exist "Notes\!note_34!.pdf" (
    title Downloading: !note_34!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_34!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Theory of Machines and Vibrations\Lecture Planner - -Only PDF\Notes\!note_34!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/f8d5171b-d7a3-4b0c-8b3c-443e0013a828.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_34!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_34!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_34!.pdf
    title File Exists: !note_34!
)
cd ..

echo.
echo !ESC![35m[CHAPTER]!ESC![0m ESE Main Practice Question
echo -----------------------------------------------------------
mkdir "ESE Main Practice Question" 2>nul
cd /d "ESE Main Practice Question"
mkdir "Lectures" 2>nul
set "lecture_28=Theory of Machines and Vibrations 10 - Theory of Machines and Vibrations -Part 10"

echo.
if not exist "Lectures\!lecture_28!.mp4" (
    title Downloading: !lecture_28!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_28!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiOGVjZTZiNjItMjkxNy00N2I5LTg4ZjYtNTRjMzZiZGQzYzRkIiwiZXhwIjoxNzU2MDcwOTkzfQ.0h-Sa-Hom93M3llefeXnJVJ06FfLQ0WZBqfRMUUlxeU/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_28!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_28!.ts" (
        ren "Lectures\!lecture_28!.ts" "!lecture_28!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_28!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_28!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_28!.mp4
    title File Exists: !lecture_28!
)
set "lecture_29=Theory of Machines and Vibrations 09 - Theory of Machines and Vibrations -Part 09"

echo.
if not exist "Lectures\!lecture_29!.mp4" (
    title Downloading: !lecture_29!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_29!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiODQ0OWRkNDEtNjZkYy00MTE3LTljODItOWU3MjQ0NDEyZjQ1IiwiZXhwIjoxNzU2MDcwOTkzfQ.3EN-ZXyg6stNYCannrUZooxxZvvBwoQamMYJHWFsthM/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_29!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_29!.ts" (
        ren "Lectures\!lecture_29!.ts" "!lecture_29!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_29!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_29!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_29!.mp4
    title File Exists: !lecture_29!
)
set "lecture_30=Theory of Machines and Vibrations 08 - Theory of Machines and Vibrations -Part 08"

echo.
if not exist "Lectures\!lecture_30!.mp4" (
    title Downloading: !lecture_30!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_30!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiNGVmNmZlYzMtYmVmOC00ZDY2LTgzN2ItMzNiOTk3YzU2ZDlhIiwiZXhwIjoxNzU2MDcwOTkzfQ.SJ97P0N_IxGe3W-aqBDkzYdOhx_hzfMP-ZB6TKXJc4g/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_30!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_30!.ts" (
        ren "Lectures\!lecture_30!.ts" "!lecture_30!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_30!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_30!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_30!.mp4
    title File Exists: !lecture_30!
)
set "lecture_31=Theory of Machines and Vibrations 07 - Theory of Machines and Vibrations -Part 07"

echo.
if not exist "Lectures\!lecture_31!.mp4" (
    title Downloading: !lecture_31!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_31!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiYzUzYTJmNDYtMzU3NS00MDk3LWEwZDctOGYxZjkxNTk0MDg3IiwiZXhwIjoxNzU2MDcwOTkzfQ.p39LURs_6aBD8omT9dHtyoao1zMsEcIX6iUAi4q5TRI/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_31!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_31!.ts" (
        ren "Lectures\!lecture_31!.ts" "!lecture_31!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_31!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_31!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_31!.mp4
    title File Exists: !lecture_31!
)
set "lecture_32=Theory of Machines and Vibrations 06 - Theory of Machines and Vibrations -Part 06"

echo.
if not exist "Lectures\!lecture_32!.mp4" (
    title Downloading: !lecture_32!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_32!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiNjc2MWJjZGQtMDU5ZS00ZjExLWI4MjItNzNhZGQ5MWQ1NWU5IiwiZXhwIjoxNzU2MDcwOTkzfQ.mRW3B1sLgmEJ6bkmdvVhWhxF13TgnZPZ3qTHtEi166Q/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_32!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_32!.ts" (
        ren "Lectures\!lecture_32!.ts" "!lecture_32!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_32!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_32!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_32!.mp4
    title File Exists: !lecture_32!
)
set "lecture_33=Theory of Machines and Vibrations 05 - Theory of Machines and Vibrations -Part 05"

echo.
if not exist "Lectures\!lecture_33!.mp4" (
    title Downloading: !lecture_33!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_33!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiZmVmNzVjOTktYzUxMi00ZjhhLThjYTgtODg5NGY4MGNhYjJhIiwiZXhwIjoxNzU2MDcwOTkzfQ.6J1hA734nYCHiOcN6BZbttTlu4yTa6KCknResjTcr0o/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_33!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_33!.ts" (
        ren "Lectures\!lecture_33!.ts" "!lecture_33!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_33!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_33!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_33!.mp4
    title File Exists: !lecture_33!
)
set "lecture_34=Theory of Machines and Vibrations 04 - Theory of Machines and Vibrations -Part 04"

echo.
if not exist "Lectures\!lecture_34!.mp4" (
    title Downloading: !lecture_34!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_34!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiZTM0YjQwZGUtMWNlMS00ZjY0LTkyYmMtMjA1ZDVhMWM4ZGQ0IiwiZXhwIjoxNzU2MDcwOTkzfQ.PvDqjwdYt33b28Wl4YZNn4a65ouShrcCaXT53PT_nbM/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_34!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_34!.ts" (
        ren "Lectures\!lecture_34!.ts" "!lecture_34!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_34!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_34!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_34!.mp4
    title File Exists: !lecture_34!
)
set "lecture_35=Theory of Machines and Vibrations 03 - Theory of Machines and Vibrations -Part 03"

echo.
if not exist "Lectures\!lecture_35!.mp4" (
    title Downloading: !lecture_35!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_35!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiZjY5ZGUyMmMtNzgyZC00ZGEwLTk2NmYtOWVmYjFjZTQ4YjcxIiwiZXhwIjoxNzU2MDcwOTkzfQ.aldxwXZzjmokfraSgIA-MbecJGcRc9_nTAbiFPYpYEo/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_35!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_35!.ts" (
        ren "Lectures\!lecture_35!.ts" "!lecture_35!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_35!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_35!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_35!.mp4
    title File Exists: !lecture_35!
)
set "lecture_36=Theory of Machines and Vibrations 02 - Theory of Machines and Vibrations -Part 02"

echo.
if not exist "Lectures\!lecture_36!.mp4" (
    title Downloading: !lecture_36!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_36!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiNTQxNWU4NGItZWI3Yy00ZmFmLWEwMzUtOGMxM2JhNzAwNjA1IiwiZXhwIjoxNzU2MDcwOTkzfQ.wEWnbyNuqC2-jPDXHDjylGHyudK2GeltOPKw6SYfpnI/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_36!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_36!.ts" (
        ren "Lectures\!lecture_36!.ts" "!lecture_36!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_36!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_36!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_36!.mp4
    title File Exists: !lecture_36!
)
set "lecture_37=Theory of Machines and Vibrations 01 - Theory of Machines and Vibrations -Part 01- - Reschedule @5-00pm"

echo.
if not exist "Lectures\!lecture_37!.mp4" (
    title Downloading: !lecture_37!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_37!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiNmYxNzU3ZTQtZWU4Mi00YjllLWIyZmEtMDE1MDc3MjRmMjk2IiwiZXhwIjoxNzU2MDcwOTkzfQ.p4U1wgAdo8PpeBNdj1zqKrdaJN1H2HVowUOeoFckvWM/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_37!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_37!.ts" (
        ren "Lectures\!lecture_37!.ts" "!lecture_37!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_37!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_37!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_37!.mp4
    title File Exists: !lecture_37!
)
mkdir "Notes" 2>nul
set "note_35=Theory of Machines and Vibrations 10 Class Notes"

echo.
if not exist "Notes\!note_35!.pdf" (
    title Downloading: !note_35!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_35!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Theory of Machines and Vibrations\ESE Main Practice Question\Notes\!note_35!.pdf"
    curl -L -o "\\?\!full_path!" "https://d2bps9p1kiy4ka.cloudfront.net/5eb393ee95fab7468a79d189/f60fd21c-3955-41c4-9552-3df4d483a5f7.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_35!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_35!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_35!.pdf
    title File Exists: !note_35!
)
set "note_36=Theory of Machines and Vibrations 09 Class Notes"

echo.
if not exist "Notes\!note_36!.pdf" (
    title Downloading: !note_36!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_36!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Theory of Machines and Vibrations\ESE Main Practice Question\Notes\!note_36!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/2d15a26b-3b17-4c9d-96ab-f4aff0f665f2.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_36!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_36!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_36!.pdf
    title File Exists: !note_36!
)
set "note_37=Theory of Machines and Vibrations 08 Class Notes"

echo.
if not exist "Notes\!note_37!.pdf" (
    title Downloading: !note_37!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_37!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Theory of Machines and Vibrations\ESE Main Practice Question\Notes\!note_37!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/4305993d-1aca-4097-81b1-0b67a0a1e878.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_37!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_37!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_37!.pdf
    title File Exists: !note_37!
)
set "note_38=Theory of Machines and Vibrations 07 Class Notes"

echo.
if not exist "Notes\!note_38!.pdf" (
    title Downloading: !note_38!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_38!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Theory of Machines and Vibrations\ESE Main Practice Question\Notes\!note_38!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/2c9f7b7a-e782-4b70-bb37-10a561d074db.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_38!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_38!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_38!.pdf
    title File Exists: !note_38!
)
set "note_39=Theory of Machines and Vibrations 06 _ Class Notes"

echo.
if not exist "Notes\!note_39!.pdf" (
    title Downloading: !note_39!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_39!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Theory of Machines and Vibrations\ESE Main Practice Question\Notes\!note_39!.pdf"
    curl -L -o "\\?\!full_path!" "https://d2bps9p1kiy4ka.cloudfront.net/5eb393ee95fab7468a79d189/d8937295-108b-4bcf-968f-6ad21e8c63ea.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_39!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_39!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_39!.pdf
    title File Exists: !note_39!
)
set "note_40=Theory of Machines and Vibrations 05 Class Notes"

echo.
if not exist "Notes\!note_40!.pdf" (
    title Downloading: !note_40!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_40!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Theory of Machines and Vibrations\ESE Main Practice Question\Notes\!note_40!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/07e6acbe-ddce-4c73-9934-cbbd18ba433e.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_40!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_40!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_40!.pdf
    title File Exists: !note_40!
)
set "note_41=Theory of Machines and Vibrations 04 Class Notes"

echo.
if not exist "Notes\!note_41!.pdf" (
    title Downloading: !note_41!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_41!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Theory of Machines and Vibrations\ESE Main Practice Question\Notes\!note_41!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/cf77a4c9-096a-4208-b5d0-894c34bc4cac.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_41!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_41!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_41!.pdf
    title File Exists: !note_41!
)
set "note_42=Theory of Machines and Vibrations 03 Class Notes"

echo.
if not exist "Notes\!note_42!.pdf" (
    title Downloading: !note_42!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_42!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Theory of Machines and Vibrations\ESE Main Practice Question\Notes\!note_42!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/9db90b18-5bec-4a7f-bc9d-026e86f5a8a1.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_42!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_42!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_42!.pdf
    title File Exists: !note_42!
)
set "note_43=Theory of Machines and Vibrations 02 Class Notes"

echo.
if not exist "Notes\!note_43!.pdf" (
    title Downloading: !note_43!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_43!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Theory of Machines and Vibrations\ESE Main Practice Question\Notes\!note_43!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/ef98b0b4-75e9-4025-a28f-0837efa4a25d.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_43!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_43!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_43!.pdf
    title File Exists: !note_43!
)
set "note_44=Theory of Machines and Vibrations 01 Class Notes"

echo.
if not exist "Notes\!note_44!.pdf" (
    title Downloading: !note_44!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_44!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Theory of Machines and Vibrations\ESE Main Practice Question\Notes\!note_44!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/7777eef5-4293-4c27-9c27-9254d9b05db8.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_44!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_44!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_44!.pdf
    title File Exists: !note_44!
)
mkdir "DPP_Notes" 2>nul
set "dpp_note_4=Theory of Machines and Vibrations Theoretical Question Bank"

echo.
if not exist "DPP_Notes\!dpp_note_4!.pdf" (
    title Downloading: !dpp_note_4!
    echo !ESC![33m[DOWNLOAD]!ESC![0m DPP Notes: !dpp_note_4!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Theory of Machines and Vibrations\ESE Main Practice Question\DPP_Notes\!dpp_note_4!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/5f4c6d87-3255-4cdf-9da6-2a37844a9a9c.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !dpp_note_4!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !dpp_note_4!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !dpp_note_4!.pdf
    title File Exists: !dpp_note_4!
)
cd ..
cd ..

echo.
echo -----------------------------------------------------------
echo !ESC![34m[SUBJECT]!ESC![0m Basic Thermodynamics
echo -----------------------------------------------------------
mkdir "Basic Thermodynamics" 2>nul
cd /d "Basic Thermodynamics"

echo.
echo !ESC![35m[CHAPTER]!ESC![0m Lecture Planner - -Only PDF
echo -----------------------------------------------------------
mkdir "Lecture Planner - -Only PDF" 2>nul
cd /d "Lecture Planner - -Only PDF"
mkdir "Notes" 2>nul
set "note_45=Basic Thermodynamics Lecture Planner"

echo.
if not exist "Notes\!note_45!.pdf" (
    title Downloading: !note_45!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_45!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Basic Thermodynamics\Lecture Planner - -Only PDF\Notes\!note_45!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/f9d82778-8807-4f25-a372-fcd576af06f2.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_45!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_45!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_45!.pdf
    title File Exists: !note_45!
)
cd ..

echo.
echo !ESC![35m[CHAPTER]!ESC![0m GATE-O-PEDIA - -Only PDF
echo -----------------------------------------------------------
mkdir "GATE-O-PEDIA - -Only PDF" 2>nul
cd /d "GATE-O-PEDIA - -Only PDF"
mkdir "Notes" 2>nul
set "note_46=Basic Thermodynamics _ GATE -O-PEDIA"

echo.
if not exist "Notes\!note_46!.pdf" (
    title Downloading: !note_46!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_46!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Basic Thermodynamics\GATE-O-PEDIA - -Only PDF\Notes\!note_46!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/5780ccd6-8d6b-4a43-ad5f-5174c3687d54.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_46!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_46!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_46!.pdf
    title File Exists: !note_46!
)
cd ..

echo.
echo !ESC![35m[CHAPTER]!ESC![0m PYQ Quiz
echo -----------------------------------------------------------
mkdir "PYQ Quiz" 2>nul
cd /d "PYQ Quiz"
cd ..

echo.
echo !ESC![35m[CHAPTER]!ESC![0m ESE Main Practice Question
echo -----------------------------------------------------------
mkdir "ESE Main Practice Question" 2>nul
cd /d "ESE Main Practice Question"
mkdir "Lectures" 2>nul
set "lecture_38=Basic Thermodynamics 05 - Basic Thermodynamics -Part 05- - Rescheduled @12-00 PM"

echo.
if not exist "Lectures\!lecture_38!.mp4" (
    title Downloading: !lecture_38!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_38!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiMjI1YWRhMDEtOWVlYS00YWZhLTlkZTAtNTJhYjJmMGFiNTZhIiwiZXhwIjoxNzU2MDcwOTkzfQ.t5HejQ5mAsB8lWwUOsIT4rdnJR6CJIfgg-MN-cYXs2E/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_38!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_38!.ts" (
        ren "Lectures\!lecture_38!.ts" "!lecture_38!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_38!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_38!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_38!.mp4
    title File Exists: !lecture_38!
)
set "lecture_39=Basic Thermodynamics 04 - Basic Thermodynamics -Part 04"

echo.
if not exist "Lectures\!lecture_39!.mp4" (
    title Downloading: !lecture_39!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_39!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiZTIzMDU1N2MtN2M5OS00MDc5LTg5MGUtOGExYmRhMTM3M2M4IiwiZXhwIjoxNzU2MDcwOTkzfQ.Xw4Ytd-gSlzYyEUPcJYzAn8eskVJ4neNm1xCX1g0IvU/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_39!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_39!.ts" (
        ren "Lectures\!lecture_39!.ts" "!lecture_39!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_39!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_39!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_39!.mp4
    title File Exists: !lecture_39!
)
set "lecture_40=Basic Thermodynamics 03 - Basic Thermodynamics -Part 03"

echo.
if not exist "Lectures\!lecture_40!.mp4" (
    title Downloading: !lecture_40!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_40!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiMzQ5ZTQ0Y2MtZTBlOC00ZTFmLTkzOWItOTY4YmY3N2FjMWYxIiwiZXhwIjoxNzU2MDcwOTkzfQ.T4JMRuHTIZgsdv0wuNOcbih6_qRYJ05qI5TgpyETa9w/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_40!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_40!.ts" (
        ren "Lectures\!lecture_40!.ts" "!lecture_40!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_40!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_40!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_40!.mp4
    title File Exists: !lecture_40!
)
set "lecture_41=Basic Thermodynamics 02 - Basic Thermodynamics -Part 02"

echo.
if not exist "Lectures\!lecture_41!.mp4" (
    title Downloading: !lecture_41!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_41!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiODI1YWJlMTgtZDEzOC00MGJlLThiNGEtNjkxOGFiYTUxMzNkIiwiZXhwIjoxNzU2MDcwOTkzfQ.nu49MbX0EZMpWHgAqd6AZ_8zXztO9JuhS0b_pTeQEiA/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_41!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_41!.ts" (
        ren "Lectures\!lecture_41!.ts" "!lecture_41!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_41!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_41!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_41!.mp4
    title File Exists: !lecture_41!
)
set "lecture_42=Basic Thermodynamics 01 - Basic Thermodynamics -Part 01"

echo.
if not exist "Lectures\!lecture_42!.mp4" (
    title Downloading: !lecture_42!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_42!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiZjc4OTc0OWMtMmYxNC00YTk0LTgzOWEtNDViNzdlNDM4MWJhIiwiZXhwIjoxNzU2MDcwOTkzfQ.PDdqvly2i4pGaRYXTwk5is2_URgT9hGZgqUhPNNJvVw/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_42!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_42!.ts" (
        ren "Lectures\!lecture_42!.ts" "!lecture_42!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_42!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_42!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_42!.mp4
    title File Exists: !lecture_42!
)
mkdir "Notes" 2>nul
set "note_47=Basic Thermodynamics 05 Class Notes"

echo.
if not exist "Notes\!note_47!.pdf" (
    title Downloading: !note_47!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_47!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Basic Thermodynamics\ESE Main Practice Question\Notes\!note_47!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/b98b8261-85e2-4664-953e-a713c8c5abc1.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_47!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_47!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_47!.pdf
    title File Exists: !note_47!
)
set "note_48=Basic Thermodynamics 04_Class Notes"

echo.
if not exist "Notes\!note_48!.pdf" (
    title Downloading: !note_48!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_48!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Basic Thermodynamics\ESE Main Practice Question\Notes\!note_48!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/61d885db-1f59-4510-a88b-34569d576dd2.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_48!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_48!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_48!.pdf
    title File Exists: !note_48!
)
set "note_49=Basic Thermodynamics 03_Class Notes"

echo.
if not exist "Notes\!note_49!.pdf" (
    title Downloading: !note_49!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_49!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Basic Thermodynamics\ESE Main Practice Question\Notes\!note_49!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/4f643829-7bf7-4fd4-a044-8379b93fea38.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_49!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_49!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_49!.pdf
    title File Exists: !note_49!
)
set "note_50=Basic Thermodynamics 02 Class Notes"

echo.
if not exist "Notes\!note_50!.pdf" (
    title Downloading: !note_50!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_50!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Basic Thermodynamics\ESE Main Practice Question\Notes\!note_50!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/de6526b2-0c42-47e7-84f8-c1cd4d66fc45.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_50!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_50!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_50!.pdf
    title File Exists: !note_50!
)
set "note_51=Basic Thermodynamics 01 Class Notes"

echo.
if not exist "Notes\!note_51!.pdf" (
    title Downloading: !note_51!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_51!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Basic Thermodynamics\ESE Main Practice Question\Notes\!note_51!.pdf"
    curl -L -o "\\?\!full_path!" "https://d2bps9p1kiy4ka.cloudfront.net/5eb393ee95fab7468a79d189/caa3785c-9553-46a4-a8b0-b62837df2db7.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_51!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_51!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_51!.pdf
    title File Exists: !note_51!
)
mkdir "DPP_Notes" 2>nul
set "dpp_note_5=Basic Thermodynamics_Theoretical Question Bank"

echo.
if not exist "DPP_Notes\!dpp_note_5!.pdf" (
    title Downloading: !dpp_note_5!
    echo !ESC![33m[DOWNLOAD]!ESC![0m DPP Notes: !dpp_note_5!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Basic Thermodynamics\ESE Main Practice Question\DPP_Notes\!dpp_note_5!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/de308697-80ed-4529-a76d-13d00173257a.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !dpp_note_5!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !dpp_note_5!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !dpp_note_5!.pdf
    title File Exists: !dpp_note_5!
)
cd ..
cd ..

echo.
echo -----------------------------------------------------------
echo !ESC![34m[SUBJECT]!ESC![0m Power Plant
echo -----------------------------------------------------------
mkdir "Power Plant" 2>nul
cd /d "Power Plant"

echo.
echo !ESC![35m[CHAPTER]!ESC![0m Lecture Planner - -Only PDF
echo -----------------------------------------------------------
mkdir "Lecture Planner - -Only PDF" 2>nul
cd /d "Lecture Planner - -Only PDF"
mkdir "Notes" 2>nul
set "note_52=Lecture Planner_Power Plant"

echo.
if not exist "Notes\!note_52!.pdf" (
    title Downloading: !note_52!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_52!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Power Plant\Lecture Planner - -Only PDF\Notes\!note_52!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/9107da5b-80c0-4f88-8dda-1ed2b8b4ed84.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_52!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_52!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_52!.pdf
    title File Exists: !note_52!
)
cd ..

echo.
echo !ESC![35m[CHAPTER]!ESC![0m ESE Main Practice Question
echo -----------------------------------------------------------
mkdir "ESE Main Practice Question" 2>nul
cd /d "ESE Main Practice Question"
mkdir "Lectures" 2>nul
set "lecture_43=Power Plant 05 - Power Plant -Part 05"

echo.
if not exist "Lectures\!lecture_43!.mp4" (
    title Downloading: !lecture_43!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_43!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiNGNkMzJjY2QtYmYyNy00NjBlLWEwNjEtYzk1ZDE5ZmJkYTc5IiwiZXhwIjoxNzU2MDcwOTkzfQ.ED5m87RrYZ2_D_4ihwjsuvQrmEO_SvxPXEzVwxic-qE/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_43!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_43!.ts" (
        ren "Lectures\!lecture_43!.ts" "!lecture_43!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_43!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_43!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_43!.mp4
    title File Exists: !lecture_43!
)
set "lecture_44=Power Plant 04 - Power Plant -Part 04"

echo.
if not exist "Lectures\!lecture_44!.mp4" (
    title Downloading: !lecture_44!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_44!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiNjBhMDIzM2EtMDkwZS00MjgwLTljZjUtZDQ3OWYwOWY0NjM3IiwiZXhwIjoxNzU2MDcwOTkzfQ.1dFY2rOrDQf3rfmfKjLIuPpJPHggLW2sR9DN1_3eAiE/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_44!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_44!.ts" (
        ren "Lectures\!lecture_44!.ts" "!lecture_44!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_44!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_44!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_44!.mp4
    title File Exists: !lecture_44!
)
set "lecture_45=Power Plant 03 - Power Plant -Part 03"

echo.
if not exist "Lectures\!lecture_45!.mp4" (
    title Downloading: !lecture_45!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_45!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiNjNiZGNiZjgtM2IxNS00ZDE4LWI0NTEtM2VkNDNhNTZjMWZiIiwiZXhwIjoxNzU2MDcwOTkzfQ.Cma9KARzgPV3kU7pJHQyKHhfsxGVmXm2LUIxWn-UNic/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_45!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_45!.ts" (
        ren "Lectures\!lecture_45!.ts" "!lecture_45!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_45!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_45!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_45!.mp4
    title File Exists: !lecture_45!
)
set "lecture_46=Power Plant 02 - Power Plant -Part 02"

echo.
if not exist "Lectures\!lecture_46!.mp4" (
    title Downloading: !lecture_46!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_46!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiZjAwNDAwYjgtMWRiOS00YTM1LTlkOGEtNjBjODEyYzU0NWMwIiwiZXhwIjoxNzU2MDcwOTkzfQ.lY64mFPRma8VcS8tSNX0q3RDBJVI5NiTJ6Jk3UAkfas/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_46!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_46!.ts" (
        ren "Lectures\!lecture_46!.ts" "!lecture_46!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_46!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_46!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_46!.mp4
    title File Exists: !lecture_46!
)
set "lecture_47=Power Plant 01 - Power Plant -Part 01"

echo.
if not exist "Lectures\!lecture_47!.mp4" (
    title Downloading: !lecture_47!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_47!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiNGE1ODY3MmYtNDUyMS00YWZkLWJkNTgtYmIwYTdkZDcyZDZhIiwiZXhwIjoxNzU2MDcwOTkzfQ.jota-nPZmh0GJfjf7_QxSju3P5WrLFnQUc4Mr1PS_5U/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_47!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_47!.ts" (
        ren "Lectures\!lecture_47!.ts" "!lecture_47!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_47!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_47!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_47!.mp4
    title File Exists: !lecture_47!
)
mkdir "Notes" 2>nul
set "note_53=Power Plant 05_Class Notes"

echo.
if not exist "Notes\!note_53!.pdf" (
    title Downloading: !note_53!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_53!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Power Plant\ESE Main Practice Question\Notes\!note_53!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/77f3a5f6-b5d7-4cf5-b4b0-bbbae3a2224e.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_53!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_53!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_53!.pdf
    title File Exists: !note_53!
)
set "note_54=Power Plant 04_Class Notes"

echo.
if not exist "Notes\!note_54!.pdf" (
    title Downloading: !note_54!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_54!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Power Plant\ESE Main Practice Question\Notes\!note_54!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/3257b035-ad18-4f62-9db9-3664e287cc99.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_54!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_54!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_54!.pdf
    title File Exists: !note_54!
)
set "note_55=Power Plant 03- Class Notes"

echo.
if not exist "Notes\!note_55!.pdf" (
    title Downloading: !note_55!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_55!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Power Plant\ESE Main Practice Question\Notes\!note_55!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/24ca7137-b8b4-425a-92d0-f218739c84b7.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_55!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_55!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_55!.pdf
    title File Exists: !note_55!
)
set "note_56=Power Plant 02_Class Notes"

echo.
if not exist "Notes\!note_56!.pdf" (
    title Downloading: !note_56!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_56!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Power Plant\ESE Main Practice Question\Notes\!note_56!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/fc3a6e36-73f4-45ec-b695-a616414849ed.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_56!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_56!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_56!.pdf
    title File Exists: !note_56!
)
set "note_57=Power Plant 01_Class Notes"

echo.
if not exist "Notes\!note_57!.pdf" (
    title Downloading: !note_57!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_57!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Power Plant\ESE Main Practice Question\Notes\!note_57!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/c321d394-abd8-4d54-8403-e5104c66365f.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_57!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_57!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_57!.pdf
    title File Exists: !note_57!
)
mkdir "DPP_Notes" 2>nul
set "dpp_note_6=Power Plant_Theoretical Question Bank"

echo.
if not exist "DPP_Notes\!dpp_note_6!.pdf" (
    title Downloading: !dpp_note_6!
    echo !ESC![33m[DOWNLOAD]!ESC![0m DPP Notes: !dpp_note_6!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Power Plant\ESE Main Practice Question\DPP_Notes\!dpp_note_6!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/743148ed-5b32-4d68-b244-7b8c2383ef1b.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !dpp_note_6!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !dpp_note_6!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !dpp_note_6!.pdf
    title File Exists: !dpp_note_6!
)
cd ..
cd ..

echo.
echo -----------------------------------------------------------
echo !ESC![34m[SUBJECT]!ESC![0m I.C Engine
echo -----------------------------------------------------------
mkdir "I.C Engine" 2>nul
cd /d "I.C Engine"

echo.
echo !ESC![35m[CHAPTER]!ESC![0m Lecture Planner - -Only PDF
echo -----------------------------------------------------------
mkdir "Lecture Planner - -Only PDF" 2>nul
cd /d "Lecture Planner - -Only PDF"
mkdir "Notes" 2>nul
set "note_58=Lecture Planner_I.C Engine"

echo.
if not exist "Notes\!note_58!.pdf" (
    title Downloading: !note_58!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_58!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\I.C Engine\Lecture Planner - -Only PDF\Notes\!note_58!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/d0d624fd-466c-4eb7-8d09-98beba4b0a64.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_58!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_58!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_58!.pdf
    title File Exists: !note_58!
)
cd ..

echo.
echo !ESC![35m[CHAPTER]!ESC![0m ESE Main Practice Question
echo -----------------------------------------------------------
mkdir "ESE Main Practice Question" 2>nul
cd /d "ESE Main Practice Question"
mkdir "Lectures" 2>nul
set "lecture_48=I.C Engine 04 - I.C Engine -Part 04"

echo.
if not exist "Lectures\!lecture_48!.mp4" (
    title Downloading: !lecture_48!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_48!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiODI3YzQ3MmEtMGI1Yy00MGRiLTlmNjgtZWMwYWRmNTEzMWFlIiwiZXhwIjoxNzU2MDcwOTkzfQ.G-GkPV5LThSEsmRG3LU2Y6dvso_SF7NigI2dh2iADqs/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_48!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_48!.ts" (
        ren "Lectures\!lecture_48!.ts" "!lecture_48!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_48!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_48!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_48!.mp4
    title File Exists: !lecture_48!
)
set "lecture_49=I.C Engine 03 - I.C Engine -Part 03"

echo.
if not exist "Lectures\!lecture_49!.mp4" (
    title Downloading: !lecture_49!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_49!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiZjgwYTNkZDItOTk1Mi00NGM5LTg2MTYtMmU3ZjMyYTU0NGU1IiwiZXhwIjoxNzU2MDcwOTkzfQ.cfMghEKoZ6jJ9IWeKZxxRzEps_uN-Ywh73InzobJb8M/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_49!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_49!.ts" (
        ren "Lectures\!lecture_49!.ts" "!lecture_49!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_49!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_49!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_49!.mp4
    title File Exists: !lecture_49!
)
set "lecture_50=I.C Engine 02 - I.C Engine -Part 02- - Rescheduled @6-00 PM"

echo.
if not exist "Lectures\!lecture_50!.mp4" (
    title Downloading: !lecture_50!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_50!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiNGNkMzI3OTktOTNjZS00MWIyLWFmZDUtZWI5MGU0NzY1N2M2IiwiZXhwIjoxNzU2MDcwOTkzfQ.wwgChuN4NHAbgnyuok7GJhrhvoZtz6Fq8ZUAZCdbIms/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_50!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_50!.ts" (
        ren "Lectures\!lecture_50!.ts" "!lecture_50!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_50!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_50!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_50!.mp4
    title File Exists: !lecture_50!
)
set "lecture_51=I.C Engine 01 - I.C Engine -Part 01"

echo.
if not exist "Lectures\!lecture_51!.mp4" (
    title Downloading: !lecture_51!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_51!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiZWVlMDc3OTEtM2I0OS00MzA1LTk0MGItNWE1NjhkNzI1MTM4IiwiZXhwIjoxNzU2MDcwOTkzfQ.XzM0F_1Qk18bWrAKcXmFuoMjx4En2PxUwFv9mZ_chYQ/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_51!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_51!.ts" (
        ren "Lectures\!lecture_51!.ts" "!lecture_51!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_51!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_51!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_51!.mp4
    title File Exists: !lecture_51!
)
mkdir "Notes" 2>nul
set "note_59=I.C Engine 04_Class Notes"

echo.
if not exist "Notes\!note_59!.pdf" (
    title Downloading: !note_59!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_59!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\I.C Engine\ESE Main Practice Question\Notes\!note_59!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/0d71bed0-2b80-4d9d-b63a-4a16b07489f3.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_59!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_59!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_59!.pdf
    title File Exists: !note_59!
)
set "note_60=I.C Engine 03_Class Notes"

echo.
if not exist "Notes\!note_60!.pdf" (
    title Downloading: !note_60!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_60!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\I.C Engine\ESE Main Practice Question\Notes\!note_60!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/71e957e2-52bc-4b41-bca6-53164afe40af.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_60!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_60!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_60!.pdf
    title File Exists: !note_60!
)
set "note_61=I.C Engine 02_Class Notes"

echo.
if not exist "Notes\!note_61!.pdf" (
    title Downloading: !note_61!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_61!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\I.C Engine\ESE Main Practice Question\Notes\!note_61!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/08e8406e-a1eb-46f9-8a31-b29f98cf0009.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_61!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_61!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_61!.pdf
    title File Exists: !note_61!
)
set "note_62=I.C Engine 01_Class Notes"

echo.
if not exist "Notes\!note_62!.pdf" (
    title Downloading: !note_62!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_62!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\I.C Engine\ESE Main Practice Question\Notes\!note_62!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/abcf63c9-5bb7-4e37-a609-c301e02855fc.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_62!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_62!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_62!.pdf
    title File Exists: !note_62!
)
mkdir "DPP_Notes" 2>nul
set "dpp_note_7=I.C Engine_Theoretical Question Bank"

echo.
if not exist "DPP_Notes\!dpp_note_7!.pdf" (
    title Downloading: !dpp_note_7!
    echo !ESC![33m[DOWNLOAD]!ESC![0m DPP Notes: !dpp_note_7!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\I.C Engine\ESE Main Practice Question\DPP_Notes\!dpp_note_7!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/7feb0d0d-bc6c-40cb-99a7-fb9ea70edd4d.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !dpp_note_7!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !dpp_note_7!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !dpp_note_7!.pdf
    title File Exists: !dpp_note_7!
)
cd ..
cd ..

echo.
echo -----------------------------------------------------------
echo !ESC![34m[SUBJECT]!ESC![0m Refrigeration and Air Conditioning
echo -----------------------------------------------------------
mkdir "Refrigeration and Air Conditioning" 2>nul
cd /d "Refrigeration and Air Conditioning"

echo.
echo !ESC![35m[CHAPTER]!ESC![0m Lecture Planner - -Only PDF
echo -----------------------------------------------------------
mkdir "Lecture Planner - -Only PDF" 2>nul
cd /d "Lecture Planner - -Only PDF"
mkdir "Notes" 2>nul
set "note_63=Lecture Planner_Refrigeration and Air Conditioning"

echo.
if not exist "Notes\!note_63!.pdf" (
    title Downloading: !note_63!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_63!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Refrigeration and Air Conditioning\Lecture Planner - -Only PDF\Notes\!note_63!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/85d42a8d-e82b-4c2d-b371-9b0c3519e712.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_63!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_63!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_63!.pdf
    title File Exists: !note_63!
)
cd ..

echo.
echo !ESC![35m[CHAPTER]!ESC![0m ESE Main Practice Question
echo -----------------------------------------------------------
mkdir "ESE Main Practice Question" 2>nul
cd /d "ESE Main Practice Question"
mkdir "Lectures" 2>nul
set "lecture_52=Refrigeration and Air Conditioning 05 - Refrigeration and Air Conditioning -Part 05"

echo.
if not exist "Lectures\!lecture_52!.mp4" (
    title Downloading: !lecture_52!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_52!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiYzZkZTNhNjMtMDkxYi00NzJkLWI1YzQtZGE4ZGQ1MzNmN2I2IiwiZXhwIjoxNzU2MDcwOTkzfQ.LTc7vuK77aTj681yBmR3Nzp1Iv76IqZR9prKdcvBfio/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_52!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_52!.ts" (
        ren "Lectures\!lecture_52!.ts" "!lecture_52!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_52!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_52!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_52!.mp4
    title File Exists: !lecture_52!
)
set "lecture_53=Refrigeration and Air Conditioning 04 - Refrigeration and Air Conditioning -Part 04"

echo.
if not exist "Lectures\!lecture_53!.mp4" (
    title Downloading: !lecture_53!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_53!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiNTBiN2I4YzgtY2M4OS00NjhlLWE0ZjAtY2MxNjI1ZTFkMWE5IiwiZXhwIjoxNzU2MDcwOTkzfQ.1O_kKSvUBD5dEDjcWWgJdBZrAJKGlKTCJe-JidWboLw/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_53!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_53!.ts" (
        ren "Lectures\!lecture_53!.ts" "!lecture_53!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_53!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_53!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_53!.mp4
    title File Exists: !lecture_53!
)
set "lecture_54=Refrigeration and Air Conditioning 03 - Refrigeration and Air Conditioning -Part 03"

echo.
if not exist "Lectures\!lecture_54!.mp4" (
    title Downloading: !lecture_54!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_54!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiYzI3OTg1YjAtODk1Yy00MmUyLWIzMzYtODY0YmNmMTM0MzAzIiwiZXhwIjoxNzU2MDcwOTkzfQ.J5C-0HrSrqrPtqkKNVgjd2Ove9k9zfWZqtbMPlLAq2A/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_54!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_54!.ts" (
        ren "Lectures\!lecture_54!.ts" "!lecture_54!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_54!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_54!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_54!.mp4
    title File Exists: !lecture_54!
)
set "lecture_55=Refrigeration and Air Conditioning 02 - Refrigeration and Air Conditioning -Part 02"

echo.
if not exist "Lectures\!lecture_55!.mp4" (
    title Downloading: !lecture_55!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_55!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiZDhlMWRlOWUtMjgxMS00ZTkxLThhZDItYWU4MWIyMzkzZTAxIiwiZXhwIjoxNzU2MDcwOTkzfQ.d8kGUln12AJgX8IrNFV_7ZwNFX2DCkwdqm9v8FNoTIg/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_55!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_55!.ts" (
        ren "Lectures\!lecture_55!.ts" "!lecture_55!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_55!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_55!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_55!.mp4
    title File Exists: !lecture_55!
)
set "lecture_56=Refrigeration and Air Conditioning 01 - Refrigeration and Air Conditioning -Part 01"

echo.
if not exist "Lectures\!lecture_56!.mp4" (
    title Downloading: !lecture_56!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_56!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiYzYxODhiODYtNTRkMC00NTFjLWE1ZjMtYTYzZWU1NmZkYzY5IiwiZXhwIjoxNzU2MDcwOTkzfQ.TB_Qari9Tq6762uGZF9xl_VXcigG6Q_ICKHHKfqOzMs/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_56!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_56!.ts" (
        ren "Lectures\!lecture_56!.ts" "!lecture_56!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_56!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_56!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_56!.mp4
    title File Exists: !lecture_56!
)
mkdir "Notes" 2>nul
set "note_64=Refrigeration and Air Conditioning 05_Class Notes"

echo.
if not exist "Notes\!note_64!.pdf" (
    title Downloading: !note_64!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_64!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Refrigeration and Air Conditioning\ESE Main Practice Question\Notes\!note_64!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/23bb38c6-5c98-4e9b-8162-8f97bb44aa5d.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_64!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_64!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_64!.pdf
    title File Exists: !note_64!
)
set "note_65=Refrigeration and Air Conditioning 04_Class Notes"

echo.
if not exist "Notes\!note_65!.pdf" (
    title Downloading: !note_65!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_65!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Refrigeration and Air Conditioning\ESE Main Practice Question\Notes\!note_65!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/9b72385f-3942-4752-a448-dac1508430f4.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_65!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_65!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_65!.pdf
    title File Exists: !note_65!
)
set "note_66=Refrigeration and Air Conditioning 03_Class Notes"

echo.
if not exist "Notes\!note_66!.pdf" (
    title Downloading: !note_66!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_66!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Refrigeration and Air Conditioning\ESE Main Practice Question\Notes\!note_66!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/d69c6de7-83b6-49bc-854d-c70d319e7f73.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_66!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_66!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_66!.pdf
    title File Exists: !note_66!
)
set "note_67=Refrigeration and Air Conditioning 02_Class Notes"

echo.
if not exist "Notes\!note_67!.pdf" (
    title Downloading: !note_67!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_67!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Refrigeration and Air Conditioning\ESE Main Practice Question\Notes\!note_67!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/bcc48ee4-3ec5-4820-a981-6e37a848ca15.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_67!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_67!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_67!.pdf
    title File Exists: !note_67!
)
set "note_68=Refrigeration and Air Conditioning 01_Class Notes"

echo.
if not exist "Notes\!note_68!.pdf" (
    title Downloading: !note_68!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_68!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Refrigeration and Air Conditioning\ESE Main Practice Question\Notes\!note_68!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/44d28845-7c05-4f01-ae4d-f75789119b60.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_68!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_68!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_68!.pdf
    title File Exists: !note_68!
)
mkdir "DPP_Notes" 2>nul
set "dpp_note_8=Refrigeration and Air Conditioning_Theoretical Question Bank"

echo.
if not exist "DPP_Notes\!dpp_note_8!.pdf" (
    title Downloading: !dpp_note_8!
    echo !ESC![33m[DOWNLOAD]!ESC![0m DPP Notes: !dpp_note_8!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Refrigeration and Air Conditioning\ESE Main Practice Question\DPP_Notes\!dpp_note_8!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/91c3438b-8e12-469c-b96e-48987e7e5087.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !dpp_note_8!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !dpp_note_8!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !dpp_note_8!.pdf
    title File Exists: !dpp_note_8!
)
cd ..
cd ..

echo.
echo -----------------------------------------------------------
echo !ESC![34m[SUBJECT]!ESC![0m Renewable Sources of Energy
echo -----------------------------------------------------------
mkdir "Renewable Sources of Energy" 2>nul
cd /d "Renewable Sources of Energy"

echo.
echo !ESC![35m[CHAPTER]!ESC![0m Lecture Planner - -Only PDF
echo -----------------------------------------------------------
mkdir "Lecture Planner - -Only PDF" 2>nul
cd /d "Lecture Planner - -Only PDF"
mkdir "Notes" 2>nul
set "note_69=Lecture Planner  Renewable Sources of Energy"

echo.
if not exist "Notes\!note_69!.pdf" (
    title Downloading: !note_69!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_69!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Renewable Sources of Energy\Lecture Planner - -Only PDF\Notes\!note_69!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/55851895-0d0d-45ef-b1df-3f18674f5bae.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_69!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_69!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_69!.pdf
    title File Exists: !note_69!
)
cd ..

echo.
echo !ESC![35m[CHAPTER]!ESC![0m PYQ Quiz
echo -----------------------------------------------------------
mkdir "PYQ Quiz" 2>nul
cd /d "PYQ Quiz"
cd ..

echo.
echo !ESC![35m[CHAPTER]!ESC![0m ESE Main Practice Question
echo -----------------------------------------------------------
mkdir "ESE Main Practice Question" 2>nul
cd /d "ESE Main Practice Question"
mkdir "Lectures" 2>nul
set "lecture_57=Renewable Sources of Energy 06 - Renewable Sources of Energy -Part 06- - Rescheduled @08-10 AM"

echo.
if not exist "Lectures\!lecture_57!.mp4" (
    title Downloading: !lecture_57!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_57!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiMDgxNmNmZTktYjY5Ni00NDNiLTgwYjctZTdiZGVhMDkzODJlIiwiZXhwIjoxNzU2MDcwOTkzfQ.DO06aVLdsA0e0Rgq4-2TmQO9JFtxrEzewFgT8wtMzEE/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_57!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_57!.ts" (
        ren "Lectures\!lecture_57!.ts" "!lecture_57!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_57!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_57!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_57!.mp4
    title File Exists: !lecture_57!
)
set "lecture_58=Renewable Sources of Energy 05 - Renewable Sources of Energy -Part 05"

echo.
if not exist "Lectures\!lecture_58!.mp4" (
    title Downloading: !lecture_58!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_58!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiOGMxMGFkMDktYjAyZi00MDk4LWFjMjUtYmQ4Y2ZmZTY0OGJhIiwiZXhwIjoxNzU2MDcwOTkzfQ.O2K2-E0Nbl0fFRRkeEhDjDH9m2-VFOA9T4hrG2LAoT8/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_58!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_58!.ts" (
        ren "Lectures\!lecture_58!.ts" "!lecture_58!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_58!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_58!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_58!.mp4
    title File Exists: !lecture_58!
)
set "lecture_59=Renewable Sources of Energy 04 - Renewable Sources of Energy -Part 04"

echo.
if not exist "Lectures\!lecture_59!.mp4" (
    title Downloading: !lecture_59!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_59!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiM2ViOGI2YzAtYzQwNy00ZDE4LTgxYzYtMzAyOTBhMzRjNjk1IiwiZXhwIjoxNzU2MDcwOTkzfQ.3tQcNQk13qfgnhQU3LxphK_dj9dFWgXvNIvo6YShUeQ/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_59!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_59!.ts" (
        ren "Lectures\!lecture_59!.ts" "!lecture_59!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_59!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_59!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_59!.mp4
    title File Exists: !lecture_59!
)
set "lecture_60=Renewable Sources of Energy 03 - Renewable Sources of Energy -Part 03"

echo.
if not exist "Lectures\!lecture_60!.mp4" (
    title Downloading: !lecture_60!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_60!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiZDkxNTVjMDEtMTA4YS00NjQ5LWJhMGEtNzIwZWJmYzE5ZTdmIiwiZXhwIjoxNzU2MDcwOTkzfQ.7PwiY7qbtu-5Kl0TjhtXxBPop_m5vbBY4YRlFtFSNtY/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_60!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_60!.ts" (
        ren "Lectures\!lecture_60!.ts" "!lecture_60!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_60!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_60!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_60!.mp4
    title File Exists: !lecture_60!
)
set "lecture_61=Renewable Sources of Energy 02 - Renewable Sources of Energy -Part 02"

echo.
if not exist "Lectures\!lecture_61!.mp4" (
    title Downloading: !lecture_61!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_61!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiNTM3ZjcxNTItYzc1NC00NzU3LTk2ZTUtOTEyYzZjNWM5ZTQxIiwiZXhwIjoxNzU2MDcwOTkzfQ.YWz03cwwFFLyJbJhVH4KihJDZPywNO09MYYhSuL2ZLo/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_61!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_61!.ts" (
        ren "Lectures\!lecture_61!.ts" "!lecture_61!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_61!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_61!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_61!.mp4
    title File Exists: !lecture_61!
)
set "lecture_62=Renewable Sources of Energy 01 - Renewable Sources of Energy -Part 01"

echo.
if not exist "Lectures\!lecture_62!.mp4" (
    title Downloading: !lecture_62!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_62!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiZWNjNzlmNTMtMzc5OS00NjdlLTgyOGYtZGNkNTcxZmM1Yjc1IiwiZXhwIjoxNzU2MDcwOTkzfQ.fsc6pkyoCtdoW591ImcErQE4YjCc42m6Gqmn56MbfFA/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_62!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_62!.ts" (
        ren "Lectures\!lecture_62!.ts" "!lecture_62!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_62!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_62!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_62!.mp4
    title File Exists: !lecture_62!
)
mkdir "Notes" 2>nul
set "note_70=Renewable Sources of Energy 06  Class Notes"

echo.
if not exist "Notes\!note_70!.pdf" (
    title Downloading: !note_70!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_70!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Renewable Sources of Energy\ESE Main Practice Question\Notes\!note_70!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/0222c4e3-da4e-4279-b9f9-1358fdeef809.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_70!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_70!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_70!.pdf
    title File Exists: !note_70!
)
set "note_71=Renewable Sources of Energy 05 Class Notes"

echo.
if not exist "Notes\!note_71!.pdf" (
    title Downloading: !note_71!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_71!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Renewable Sources of Energy\ESE Main Practice Question\Notes\!note_71!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/3ca8ab6a-f949-4c71-a52e-f99778d9109e.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_71!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_71!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_71!.pdf
    title File Exists: !note_71!
)
set "note_72=Renewable Sources of Energy 04 Class Notes"

echo.
if not exist "Notes\!note_72!.pdf" (
    title Downloading: !note_72!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_72!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Renewable Sources of Energy\ESE Main Practice Question\Notes\!note_72!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/bf963591-d279-4866-846c-a4a5a7c403f3.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_72!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_72!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_72!.pdf
    title File Exists: !note_72!
)
set "note_73=Renewable Sources of Energy 03 Class Notes"

echo.
if not exist "Notes\!note_73!.pdf" (
    title Downloading: !note_73!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_73!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Renewable Sources of Energy\ESE Main Practice Question\Notes\!note_73!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/aa4361ef-6e3c-4054-8e28-d9962cd8e815.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_73!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_73!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_73!.pdf
    title File Exists: !note_73!
)
set "note_74=Renewable Sources of Energy 02  Class Notes"

echo.
if not exist "Notes\!note_74!.pdf" (
    title Downloading: !note_74!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_74!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Renewable Sources of Energy\ESE Main Practice Question\Notes\!note_74!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/5fae27dc-a222-444a-801a-9b7145d37d74.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_74!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_74!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_74!.pdf
    title File Exists: !note_74!
)
set "note_75=Renewable Sources of Energy 01  Class Notes"

echo.
if not exist "Notes\!note_75!.pdf" (
    title Downloading: !note_75!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_75!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Renewable Sources of Energy\ESE Main Practice Question\Notes\!note_75!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/4bdb9ac2-23bf-47f3-83a8-595f7e9091ab.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_75!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_75!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_75!.pdf
    title File Exists: !note_75!
)
mkdir "DPP_Notes" 2>nul
set "dpp_note_9=Renewable Sources of Energy Theoretical Question Bank"

echo.
if not exist "DPP_Notes\!dpp_note_9!.pdf" (
    title Downloading: !dpp_note_9!
    echo !ESC![33m[DOWNLOAD]!ESC![0m DPP Notes: !dpp_note_9!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Renewable Sources of Energy\ESE Main Practice Question\DPP_Notes\!dpp_note_9!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/12394b58-e49e-4196-a79f-ba4a8245b725.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !dpp_note_9!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !dpp_note_9!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !dpp_note_9!.pdf
    title File Exists: !dpp_note_9!
)
cd ..
cd ..

echo.
echo -----------------------------------------------------------
echo !ESC![34m[SUBJECT]!ESC![0m Mechatronics
echo -----------------------------------------------------------
mkdir "Mechatronics" 2>nul
cd /d "Mechatronics"

echo.
echo !ESC![35m[CHAPTER]!ESC![0m Lecture Planner - -Only PDF
echo -----------------------------------------------------------
mkdir "Lecture Planner - -Only PDF" 2>nul
cd /d "Lecture Planner - -Only PDF"
mkdir "Notes" 2>nul
set "note_76=Lecture Planner  Mechatronics"

echo.
if not exist "Notes\!note_76!.pdf" (
    title Downloading: !note_76!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_76!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Mechatronics\Lecture Planner - -Only PDF\Notes\!note_76!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/abddd1fa-3526-4462-bf19-ffe9133fe934.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_76!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_76!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_76!.pdf
    title File Exists: !note_76!
)
cd ..

echo.
echo !ESC![35m[CHAPTER]!ESC![0m PYQ Quiz
echo -----------------------------------------------------------
mkdir "PYQ Quiz" 2>nul
cd /d "PYQ Quiz"
cd ..

echo.
echo !ESC![35m[CHAPTER]!ESC![0m ESE Main Practice Question
echo -----------------------------------------------------------
mkdir "ESE Main Practice Question" 2>nul
cd /d "ESE Main Practice Question"
mkdir "Lectures" 2>nul
set "lecture_63=Mechatronics 05 - Mechatronics -Part 05- - Rescheduled @08-10 AM"

echo.
if not exist "Lectures\!lecture_63!.mp4" (
    title Downloading: !lecture_63!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_63!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiNmZiZTE0N2EtMDBhMS00YWUzLWFiZGQtYWRiYzJhNmVlOTM4IiwiZXhwIjoxNzU2MDcwOTkzfQ.81GBRfy6HBvs5nVjB5ILT7WvEvildG-Yc5w0dcRU4wM/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_63!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_63!.ts" (
        ren "Lectures\!lecture_63!.ts" "!lecture_63!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_63!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_63!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_63!.mp4
    title File Exists: !lecture_63!
)
set "lecture_64=Mechatronics 04 - Mechatronics -Part 04"

echo.
if not exist "Lectures\!lecture_64!.mp4" (
    title Downloading: !lecture_64!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_64!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiNjdkNDMyNzktMDAwYS00YTc2LThlNTctNzM1YzUwNTNiZGU4IiwiZXhwIjoxNzU2MDcwOTkzfQ.oi0qK5-dHsiemRMW091hAiQzPJ_deXYJv3CJN3fUp6w/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_64!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_64!.ts" (
        ren "Lectures\!lecture_64!.ts" "!lecture_64!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_64!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_64!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_64!.mp4
    title File Exists: !lecture_64!
)
set "lecture_65=Mechatronics 03 - Mechatronics -Part 03"

echo.
if not exist "Lectures\!lecture_65!.mp4" (
    title Downloading: !lecture_65!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_65!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiZWRlOTliNGQtMTMzNy00OTEzLWIzMzYtMzQ5YmVmZTI2MmIxIiwiZXhwIjoxNzU2MDcwOTkzfQ.hOpnImKeT7WgQwVUPEz1MgqLxi7rr3OcUaT8fkr5vTE/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_65!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_65!.ts" (
        ren "Lectures\!lecture_65!.ts" "!lecture_65!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_65!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_65!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_65!.mp4
    title File Exists: !lecture_65!
)
set "lecture_66=Mechatronics 02 - Mechatronics -Part 02"

echo.
if not exist "Lectures\!lecture_66!.mp4" (
    title Downloading: !lecture_66!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_66!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiYjFlNzBmZjctZDJjZS00NTlmLWE4MjQtMzg1NGZhYjA1Mzc0IiwiZXhwIjoxNzU2MDcwOTkzfQ.A2-XWDrfffWGSXamO_VAftZ0cqlnQUNr579ZEP4jcpg/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_66!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_66!.ts" (
        ren "Lectures\!lecture_66!.ts" "!lecture_66!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_66!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_66!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_66!.mp4
    title File Exists: !lecture_66!
)
set "lecture_67=Mechatronics 01 - Mechatronics -Part 01"

echo.
if not exist "Lectures\!lecture_67!.mp4" (
    title Downloading: !lecture_67!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_67!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiMjVhMDU0ZTMtZGU3Ny00OGE0LWI2OGUtZmUyOTFhYmY1MmM1IiwiZXhwIjoxNzU2MDcwOTkzfQ.9GbqOJuF3DCZPPum6awaX6cXKEp754N06izCFrJ9KIs/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_67!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_67!.ts" (
        ren "Lectures\!lecture_67!.ts" "!lecture_67!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_67!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_67!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_67!.mp4
    title File Exists: !lecture_67!
)
mkdir "Notes" 2>nul
set "note_77=Mechatronics 05 Class Notes"

echo.
if not exist "Notes\!note_77!.pdf" (
    title Downloading: !note_77!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_77!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Mechatronics\ESE Main Practice Question\Notes\!note_77!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/df2f76e4-7d81-43ab-b2cd-ae518548735f.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_77!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_77!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_77!.pdf
    title File Exists: !note_77!
)
set "note_78=Mechatronics 04 Class Notes"

echo.
if not exist "Notes\!note_78!.pdf" (
    title Downloading: !note_78!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_78!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Mechatronics\ESE Main Practice Question\Notes\!note_78!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/a290443d-4848-4e48-b5e8-019039b46531.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_78!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_78!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_78!.pdf
    title File Exists: !note_78!
)
set "note_79=Mechatronics 03  Class Notes"

echo.
if not exist "Notes\!note_79!.pdf" (
    title Downloading: !note_79!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_79!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Mechatronics\ESE Main Practice Question\Notes\!note_79!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/aaf8feb5-87a6-4e81-b3e2-20dcc38dc2ba.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_79!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_79!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_79!.pdf
    title File Exists: !note_79!
)
set "note_80=Mechatronics 02 Class Notes"

echo.
if not exist "Notes\!note_80!.pdf" (
    title Downloading: !note_80!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_80!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Mechatronics\ESE Main Practice Question\Notes\!note_80!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/dabe218a-59c7-494a-95cf-992a93a89d70.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_80!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_80!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_80!.pdf
    title File Exists: !note_80!
)
set "note_81=Mechatronics 01 Class Notes"

echo.
if not exist "Notes\!note_81!.pdf" (
    title Downloading: !note_81!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_81!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Mechatronics\ESE Main Practice Question\Notes\!note_81!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/b63f7942-dcd0-4327-9abf-e453360d8164.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_81!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_81!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_81!.pdf
    title File Exists: !note_81!
)
mkdir "DPP_Notes" 2>nul
set "dpp_note_10=Mechatronics Theoretical Question Bank"

echo.
if not exist "DPP_Notes\!dpp_note_10!.pdf" (
    title Downloading: !dpp_note_10!
    echo !ESC![33m[DOWNLOAD]!ESC![0m DPP Notes: !dpp_note_10!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Mechatronics\ESE Main Practice Question\DPP_Notes\!dpp_note_10!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/91d00609-f76e-4ec8-a392-eae75b4ea8be.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !dpp_note_10!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !dpp_note_10!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !dpp_note_10!.pdf
    title File Exists: !dpp_note_10!
)
cd ..
cd ..

echo.
echo -----------------------------------------------------------
echo !ESC![34m[SUBJECT]!ESC![0m Robotics
echo -----------------------------------------------------------
mkdir "Robotics" 2>nul
cd /d "Robotics"

echo.
echo !ESC![35m[CHAPTER]!ESC![0m Lecture Planner - -Only PDF
echo -----------------------------------------------------------
mkdir "Lecture Planner - -Only PDF" 2>nul
cd /d "Lecture Planner - -Only PDF"
mkdir "Notes" 2>nul
set "note_82=Lecture Planner Robotics"

echo.
if not exist "Notes\!note_82!.pdf" (
    title Downloading: !note_82!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_82!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Robotics\Lecture Planner - -Only PDF\Notes\!note_82!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/09e8f6af-f3bc-4292-a7f3-1a1cb82d7808.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_82!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_82!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_82!.pdf
    title File Exists: !note_82!
)
cd ..

echo.
echo !ESC![35m[CHAPTER]!ESC![0m PYQ Quiz
echo -----------------------------------------------------------
mkdir "PYQ Quiz" 2>nul
cd /d "PYQ Quiz"
cd ..

echo.
echo !ESC![35m[CHAPTER]!ESC![0m ESE Main Practice Question
echo -----------------------------------------------------------
mkdir "ESE Main Practice Question" 2>nul
cd /d "ESE Main Practice Question"
mkdir "Lectures" 2>nul
set "lecture_68=Robotics 04 - Robotics -Part 04"

echo.
if not exist "Lectures\!lecture_68!.mp4" (
    title Downloading: !lecture_68!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_68!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiMjYwNGU2NmMtOWYyNC00M2E3LWIwMWMtMjJmYmVmNWRhMjhlIiwiZXhwIjoxNzU2MDcwOTkzfQ.LxLDOMnJAy0hgwEHM6dS1XHoU8MrraSjSEvMJbJc7Xs/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_68!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_68!.ts" (
        ren "Lectures\!lecture_68!.ts" "!lecture_68!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_68!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_68!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_68!.mp4
    title File Exists: !lecture_68!
)
set "lecture_69=Robotics 03 - Robotics -Part 03- - Rescheduled @08-15 AM"

echo.
if not exist "Lectures\!lecture_69!.mp4" (
    title Downloading: !lecture_69!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_69!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiODQyZmQwNDgtZjU1MS00ZDRhLWExYmQtNzNhMDMzZjJhYTM3IiwiZXhwIjoxNzU2MDcwOTkzfQ.YV-AzMl5YOPNBDXbEtXqdg73rbFluuxhfQC6pXNjor8/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_69!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_69!.ts" (
        ren "Lectures\!lecture_69!.ts" "!lecture_69!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_69!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_69!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_69!.mp4
    title File Exists: !lecture_69!
)
set "lecture_70=Robotics 02 - Robotics -Part 02"

echo.
if not exist "Lectures\!lecture_70!.mp4" (
    title Downloading: !lecture_70!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_70!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiZTNkY2IzOTItNTJiYi00OTYwLWJmZTctZmM5MGI1Y2RhMmUxIiwiZXhwIjoxNzU2MDcwOTkzfQ.EC_A8xuJey4_UqVPF4cfwPjxNqNitQj60AGpk2xAJ7A/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_70!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_70!.ts" (
        ren "Lectures\!lecture_70!.ts" "!lecture_70!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_70!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_70!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_70!.mp4
    title File Exists: !lecture_70!
)
set "lecture_71=Robotics 01 - Robotics -Part 01"

echo.
if not exist "Lectures\!lecture_71!.mp4" (
    title Downloading: !lecture_71!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_71!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiYWNkZTE2ZjQtZGE1YS00NGNlLTg5NzYtZDdkYWI1YzNkODljIiwiZXhwIjoxNzU2MDcwOTkzfQ.F4VhzZmdaXz8NGz3btkdj6bB8jxluVXQAOYa99G8X7U/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_71!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_71!.ts" (
        ren "Lectures\!lecture_71!.ts" "!lecture_71!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_71!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_71!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_71!.mp4
    title File Exists: !lecture_71!
)
mkdir "Notes" 2>nul
set "note_83=Robotics 04  Class Notes"

echo.
if not exist "Notes\!note_83!.pdf" (
    title Downloading: !note_83!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_83!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Robotics\ESE Main Practice Question\Notes\!note_83!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/5c97e262-02ad-48b9-9008-4dc0018750c9.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_83!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_83!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_83!.pdf
    title File Exists: !note_83!
)
set "note_84=Robotics 03 Class Notes"

echo.
if not exist "Notes\!note_84!.pdf" (
    title Downloading: !note_84!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_84!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Robotics\ESE Main Practice Question\Notes\!note_84!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/6c9454fe-ccd4-4521-ad89-76635db40385.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_84!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_84!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_84!.pdf
    title File Exists: !note_84!
)
set "note_85=Robotics 02  Class Notes"

echo.
if not exist "Notes\!note_85!.pdf" (
    title Downloading: !note_85!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_85!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Robotics\ESE Main Practice Question\Notes\!note_85!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/ae08498e-0098-4895-9dee-86cd5caacea5.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_85!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_85!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_85!.pdf
    title File Exists: !note_85!
)
set "note_86=Robotics 01  Class Notes"

echo.
if not exist "Notes\!note_86!.pdf" (
    title Downloading: !note_86!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_86!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Robotics\ESE Main Practice Question\Notes\!note_86!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/09026d65-7107-456f-8cd8-c47dc4ce3fc6.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_86!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_86!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_86!.pdf
    title File Exists: !note_86!
)
mkdir "DPP_Notes" 2>nul
set "dpp_note_11=Robotics Theoretical Question Bank"

echo.
if not exist "DPP_Notes\!dpp_note_11!.pdf" (
    title Downloading: !dpp_note_11!
    echo !ESC![33m[DOWNLOAD]!ESC![0m DPP Notes: !dpp_note_11!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Robotics\ESE Main Practice Question\DPP_Notes\!dpp_note_11!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/b40e0fef-2447-4f44-b06c-a5adabf145a3.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !dpp_note_11!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !dpp_note_11!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !dpp_note_11!.pdf
    title File Exists: !dpp_note_11!
)
cd ..
cd ..

echo.
echo -----------------------------------------------------------
echo !ESC![34m[SUBJECT]!ESC![0m Manufacturing Process
echo -----------------------------------------------------------
mkdir "Manufacturing Process" 2>nul
cd /d "Manufacturing Process"

echo.
echo !ESC![35m[CHAPTER]!ESC![0m Lecture Planner - -Only PDF
echo -----------------------------------------------------------
mkdir "Lecture Planner - -Only PDF" 2>nul
cd /d "Lecture Planner - -Only PDF"
mkdir "Notes" 2>nul
set "note_87=Lecture Planner_Manufacturing Process"

echo.
if not exist "Notes\!note_87!.pdf" (
    title Downloading: !note_87!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_87!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Manufacturing Process\Lecture Planner - -Only PDF\Notes\!note_87!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/beeed805-1cc1-4f4d-bf85-75f5ef7de9b0.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_87!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_87!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_87!.pdf
    title File Exists: !note_87!
)
cd ..

echo.
echo !ESC![35m[CHAPTER]!ESC![0m ESE Mains Practice Questions
echo -----------------------------------------------------------
mkdir "ESE Mains Practice Questions" 2>nul
cd /d "ESE Mains Practice Questions"
mkdir "Lectures" 2>nul
set "lecture_72=Manufacturing Process 08 - Manufacturing Process -Part -08"

echo.
if not exist "Lectures\!lecture_72!.mp4" (
    title Downloading: !lecture_72!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_72!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiYjAwNGM0ZjQtYjU3Ni00NGU3LWFlYWMtYmRlZTlmMTllODljIiwiZXhwIjoxNzU2MDcwOTkzfQ.QKvzQlnFQsVDXs4vROjnroEcl4WFDrHj0CyfLUbDD5U/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_72!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_72!.ts" (
        ren "Lectures\!lecture_72!.ts" "!lecture_72!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_72!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_72!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_72!.mp4
    title File Exists: !lecture_72!
)
set "lecture_73=Manufacturing Process 07 - Manufacturing Process -Part -07"

echo.
if not exist "Lectures\!lecture_73!.mp4" (
    title Downloading: !lecture_73!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_73!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiYTdlNTgzZjEtMTc4NC00NDkwLWE0MDEtM2YzMDdiODRhZDE4IiwiZXhwIjoxNzU2MDcwOTkzfQ.KMek5Fe7S8LqPhOxYiL8S7elxev6i5WoNJInLtOlRnA/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_73!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_73!.ts" (
        ren "Lectures\!lecture_73!.ts" "!lecture_73!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_73!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_73!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_73!.mp4
    title File Exists: !lecture_73!
)
set "lecture_74=Manufacturing Process 06 - Manufacturing Process -Part -06"

echo.
if not exist "Lectures\!lecture_74!.mp4" (
    title Downloading: !lecture_74!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_74!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiZWMxNjE1YjYtYzVmZS00YjQ1LWI5M2EtOTA5MzM3NDQ1NmFmIiwiZXhwIjoxNzU2MDcwOTkzfQ.cFmmFZpUPpMm2o7onekHPXmgDa81jL0tsjQDqXv0Cow/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_74!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_74!.ts" (
        ren "Lectures\!lecture_74!.ts" "!lecture_74!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_74!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_74!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_74!.mp4
    title File Exists: !lecture_74!
)
set "lecture_75=Manufacturing Process 05 - Manufacturing Process -Part -05- - -Rescheduled @01-00PM"

echo.
if not exist "Lectures\!lecture_75!.mp4" (
    title Downloading: !lecture_75!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_75!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiZTMxOTdiMmItMDQ4NC00NjY4LWEwMzItMjAzNGU2ZmY3MTcxIiwiZXhwIjoxNzU2MDcwOTkzfQ.w4eLvP9N0FLEUaA_HIoHXW6IOnwXcMjWZZ-e_OkoAeE/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_75!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_75!.ts" (
        ren "Lectures\!lecture_75!.ts" "!lecture_75!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_75!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_75!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_75!.mp4
    title File Exists: !lecture_75!
)
set "lecture_76=Manufacturing Process 04 - Manufacturing Process -Part -04"

echo.
if not exist "Lectures\!lecture_76!.mp4" (
    title Downloading: !lecture_76!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_76!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiNmNkMzRhZGEtYzZjOC00MjEwLThmNjgtMDJlNzhhODhkNjMzIiwiZXhwIjoxNzU2MDcwOTkzfQ.kLsuGB1Q91BDhINzOUdfM33eN3ywjzIXGa3KI2dxofY/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_76!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_76!.ts" (
        ren "Lectures\!lecture_76!.ts" "!lecture_76!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_76!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_76!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_76!.mp4
    title File Exists: !lecture_76!
)
set "lecture_77=Manufacturing Process 03 - Manufacturing Process -Part -03"

echo.
if not exist "Lectures\!lecture_77!.mp4" (
    title Downloading: !lecture_77!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_77!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiZjI4NzQwNzAtZmFkMi00Y2I2LWE2ODMtZGU4NzdjYTIzZDA0IiwiZXhwIjoxNzU2MDcwOTkzfQ.OSR0ONyXMTVEwfFWL805a673wu81nrEl9BmJZ2fBVaw/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_77!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_77!.ts" (
        ren "Lectures\!lecture_77!.ts" "!lecture_77!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_77!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_77!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_77!.mp4
    title File Exists: !lecture_77!
)
set "lecture_78=Manufacturing Process 02 - Manufacturing Process -Part -02"

echo.
if not exist "Lectures\!lecture_78!.mp4" (
    title Downloading: !lecture_78!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_78!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiZTA0MTExODctM2E4MC00OWVkLThlZmMtNDNmZmIwOGE1MTcyIiwiZXhwIjoxNzU2MDcwOTkzfQ.2hfCGVTe7Cp6_5Q_aR9XE83gu0gW8FWPMf1W14GMsyE/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_78!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_78!.ts" (
        ren "Lectures\!lecture_78!.ts" "!lecture_78!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_78!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_78!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_78!.mp4
    title File Exists: !lecture_78!
)
set "lecture_79=Manufacturing Process 01 - Manufacturing Process -Part -01"

echo.
if not exist "Lectures\!lecture_79!.mp4" (
    title Downloading: !lecture_79!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_79!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiYzQzNzEwMTMtYzhjYy00YTIxLTg2ZWQtZTkyYjEwYjYxMTM0IiwiZXhwIjoxNzU2MDcwOTkzfQ.Nnj3FjtoaXAegg9g3sX1JPrQki8lIuy3wl_oVc87Gw8/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_79!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_79!.ts" (
        ren "Lectures\!lecture_79!.ts" "!lecture_79!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_79!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_79!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_79!.mp4
    title File Exists: !lecture_79!
)
mkdir "Notes" 2>nul
set "note_88=Manufacturing Process 08_ Class Notes"

echo.
if not exist "Notes\!note_88!.pdf" (
    title Downloading: !note_88!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_88!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Manufacturing Process\ESE Mains Practice Questions\Notes\!note_88!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/d733ad28-18a1-4b69-92e2-2d665988e407.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_88!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_88!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_88!.pdf
    title File Exists: !note_88!
)
set "note_89=Manufacturing Process 07_Class Notes"

echo.
if not exist "Notes\!note_89!.pdf" (
    title Downloading: !note_89!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_89!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Manufacturing Process\ESE Mains Practice Questions\Notes\!note_89!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/2309346d-73d6-4399-b144-3637a6052d62.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_89!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_89!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_89!.pdf
    title File Exists: !note_89!
)
set "note_90=Manufacturing Process 06_Class Notes"

echo.
if not exist "Notes\!note_90!.pdf" (
    title Downloading: !note_90!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_90!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Manufacturing Process\ESE Mains Practice Questions\Notes\!note_90!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/23647e89-a895-4fba-b81f-4a185fb125ee.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_90!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_90!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_90!.pdf
    title File Exists: !note_90!
)
set "note_91=Manufacturing Process 05_Class Notes"

echo.
if not exist "Notes\!note_91!.pdf" (
    title Downloading: !note_91!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_91!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Manufacturing Process\ESE Mains Practice Questions\Notes\!note_91!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/1cff556f-1d1e-4081-b82c-b8722abdf33d.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_91!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_91!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_91!.pdf
    title File Exists: !note_91!
)
set "note_92=Manufacturing Process 04_Class Notes"

echo.
if not exist "Notes\!note_92!.pdf" (
    title Downloading: !note_92!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_92!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Manufacturing Process\ESE Mains Practice Questions\Notes\!note_92!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/96af278f-d5d6-4455-9062-a527f048a6b7.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_92!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_92!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_92!.pdf
    title File Exists: !note_92!
)
set "note_93=Manufacturing Process 03_ Class Notes"

echo.
if not exist "Notes\!note_93!.pdf" (
    title Downloading: !note_93!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_93!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Manufacturing Process\ESE Mains Practice Questions\Notes\!note_93!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/c73a33fc-2a5b-4106-997e-5301002b3def.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_93!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_93!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_93!.pdf
    title File Exists: !note_93!
)
set "note_94=Manufacturing Process 02_Class Notes"

echo.
if not exist "Notes\!note_94!.pdf" (
    title Downloading: !note_94!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_94!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Manufacturing Process\ESE Mains Practice Questions\Notes\!note_94!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/91a46d0f-3827-4a86-9f7f-da22d9ea1305.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_94!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_94!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_94!.pdf
    title File Exists: !note_94!
)
set "note_95=Manufacturing Process 01_Class Notes"

echo.
if not exist "Notes\!note_95!.pdf" (
    title Downloading: !note_95!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_95!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Manufacturing Process\ESE Mains Practice Questions\Notes\!note_95!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/b2bbefb4-8879-4c02-8e1c-cef325f60a0d.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_95!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_95!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_95!.pdf
    title File Exists: !note_95!
)
mkdir "DPP_Notes" 2>nul
set "dpp_note_12=Manufacturing Process_Theoretical Question Bank"

echo.
if not exist "DPP_Notes\!dpp_note_12!.pdf" (
    title Downloading: !dpp_note_12!
    echo !ESC![33m[DOWNLOAD]!ESC![0m DPP Notes: !dpp_note_12!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Manufacturing Process\ESE Mains Practice Questions\DPP_Notes\!dpp_note_12!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/7d504159-6d8a-498e-b401-60a2fcf3c8ae.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !dpp_note_12!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !dpp_note_12!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !dpp_note_12!.pdf
    title File Exists: !dpp_note_12!
)
cd ..
cd ..

echo.
echo -----------------------------------------------------------
echo !ESC![34m[SUBJECT]!ESC![0m Machine Design
echo -----------------------------------------------------------
mkdir "Machine Design" 2>nul
cd /d "Machine Design"

echo.
echo !ESC![35m[CHAPTER]!ESC![0m Lecture Planner - -Only PDF
echo -----------------------------------------------------------
mkdir "Lecture Planner - -Only PDF" 2>nul
cd /d "Lecture Planner - -Only PDF"
mkdir "Notes" 2>nul
set "note_96=Machine Design Lecture Planner"

echo.
if not exist "Notes\!note_96!.pdf" (
    title Downloading: !note_96!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_96!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Machine Design\Lecture Planner - -Only PDF\Notes\!note_96!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/b0f40124-6968-41c2-a833-473deb350aea.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_96!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_96!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_96!.pdf
    title File Exists: !note_96!
)
cd ..

echo.
echo !ESC![35m[CHAPTER]!ESC![0m ESE Main Practice Question
echo -----------------------------------------------------------
mkdir "ESE Main Practice Question" 2>nul
cd /d "ESE Main Practice Question"
mkdir "Lectures" 2>nul
set "lecture_80=Machine Design 06 - Machine Design -Part 06"

echo.
if not exist "Lectures\!lecture_80!.mp4" (
    title Downloading: !lecture_80!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_80!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiMDhhOGQ5NmYtNGUxNy00OTRkLTk5NzctMGI0NGZjOGFlZjE0IiwiZXhwIjoxNzU2MDcwOTkzfQ.vETePfzIDT_4PFy2Fq3NUeWvmu5MBLhB3iS5EA0XJs4/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_80!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_80!.ts" (
        ren "Lectures\!lecture_80!.ts" "!lecture_80!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_80!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_80!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_80!.mp4
    title File Exists: !lecture_80!
)
set "lecture_81=Machine Design 05 - Machine Design -Part 05"

echo.
if not exist "Lectures\!lecture_81!.mp4" (
    title Downloading: !lecture_81!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_81!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiYjVjZDNlMmUtYzAwMS00NzhiLTkyNTktMGYyYWVhYmYyNWQyIiwiZXhwIjoxNzU2MDcwOTkzfQ.UUjzzXx3lkzKugbULNuwoKclWHJRL95ck17aIKL4BfY/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_81!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_81!.ts" (
        ren "Lectures\!lecture_81!.ts" "!lecture_81!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_81!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_81!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_81!.mp4
    title File Exists: !lecture_81!
)
set "lecture_82=Machine Design 04 - Machine Design -Part 04"

echo.
if not exist "Lectures\!lecture_82!.mp4" (
    title Downloading: !lecture_82!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_82!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiZGRlMTQwZGEtYWQ5MC00MmRkLTlkOTgtZmVlNGU3ODM4ZDdmIiwiZXhwIjoxNzU2MDcwOTkzfQ.4jYGBBLJIwOeuuRAKmWc_h_gCDbuVDc7gSfacvYKSOI/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_82!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_82!.ts" (
        ren "Lectures\!lecture_82!.ts" "!lecture_82!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_82!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_82!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_82!.mp4
    title File Exists: !lecture_82!
)
set "lecture_83=Machine Design 03 -  Machine Design -Part 03"

echo.
if not exist "Lectures\!lecture_83!.mp4" (
    title Downloading: !lecture_83!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_83!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiNmJkNzhhZjEtOTkwZi00OTJmLWE3ZmMtN2RjMTkwOWQwMmIxIiwiZXhwIjoxNzU2MDcwOTkzfQ.JV5GHVhlRkAH033UTCJkWVzgpycYuWm4pF6gLdxkS8E/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_83!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_83!.ts" (
        ren "Lectures\!lecture_83!.ts" "!lecture_83!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_83!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_83!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_83!.mp4
    title File Exists: !lecture_83!
)
set "lecture_84=Machine Design 02 -  Machine Design -Part 02"

echo.
if not exist "Lectures\!lecture_84!.mp4" (
    title Downloading: !lecture_84!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_84!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiZDc3YTFlNDctYWViNS00NDA5LThmNjItYWIxMjMxNDUzZWRmIiwiZXhwIjoxNzU2MDcwOTkzfQ.yuYoH0oBf7Z2hnAnXS2a_k1IXvGBEuQYM3cOAzaZ2GU/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_84!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_84!.ts" (
        ren "Lectures\!lecture_84!.ts" "!lecture_84!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_84!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_84!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_84!.mp4
    title File Exists: !lecture_84!
)
set "lecture_85=Machine Design 01 - Machine Design -Part 01"

echo.
if not exist "Lectures\!lecture_85!.mp4" (
    title Downloading: !lecture_85!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_85!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiMTJjMDViYTQtY2Q5Yy00YzZiLWFkM2MtN2YwYmQ0NTE3MGQzIiwiZXhwIjoxNzU2MDcwOTkzfQ.ajI-OngJJXVsyGbsiwmdR4rfoT8BMyvVy0Hptkl8Az8/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_85!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_85!.ts" (
        ren "Lectures\!lecture_85!.ts" "!lecture_85!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_85!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_85!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_85!.mp4
    title File Exists: !lecture_85!
)
mkdir "Notes" 2>nul
set "note_97=Machine Design 06 Class Notes"

echo.
if not exist "Notes\!note_97!.pdf" (
    title Downloading: !note_97!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_97!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Machine Design\ESE Main Practice Question\Notes\!note_97!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/042df8df-494e-4b1c-bd12-f2f31e361b08.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_97!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_97!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_97!.pdf
    title File Exists: !note_97!
)
set "note_98=Machine Design 05 Class Notes"

echo.
if not exist "Notes\!note_98!.pdf" (
    title Downloading: !note_98!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_98!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Machine Design\ESE Main Practice Question\Notes\!note_98!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/69076690-ed5e-482b-b75d-2835f989fadc.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_98!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_98!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_98!.pdf
    title File Exists: !note_98!
)
set "note_99=Machine Design 04 Class Notes"

echo.
if not exist "Notes\!note_99!.pdf" (
    title Downloading: !note_99!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_99!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Machine Design\ESE Main Practice Question\Notes\!note_99!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/f3ab2fb4-4e73-4ba6-aaba-18d51afdcc64.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_99!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_99!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_99!.pdf
    title File Exists: !note_99!
)
set "note_100=Machine Design 03 Class Notes"

echo.
if not exist "Notes\!note_100!.pdf" (
    title Downloading: !note_100!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_100!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Machine Design\ESE Main Practice Question\Notes\!note_100!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/bd80ee92-428f-481d-800a-6412d71a8bda.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_100!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_100!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_100!.pdf
    title File Exists: !note_100!
)
set "note_101=Machine Design 02 Class Notes"

echo.
if not exist "Notes\!note_101!.pdf" (
    title Downloading: !note_101!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_101!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Machine Design\ESE Main Practice Question\Notes\!note_101!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/8a0df89c-941f-439d-b895-50fb0d67c88c.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_101!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_101!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_101!.pdf
    title File Exists: !note_101!
)
set "note_102=Machine Design 01 Class Notes"

echo.
if not exist "Notes\!note_102!.pdf" (
    title Downloading: !note_102!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_102!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Machine Design\ESE Main Practice Question\Notes\!note_102!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/346530b5-ed70-4248-a1ad-581897d4a687.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_102!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_102!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_102!.pdf
    title File Exists: !note_102!
)
mkdir "DPP_Notes" 2>nul
set "dpp_note_13=Machine Design Theoretical Question Bank"

echo.
if not exist "DPP_Notes\!dpp_note_13!.pdf" (
    title Downloading: !dpp_note_13!
    echo !ESC![33m[DOWNLOAD]!ESC![0m DPP Notes: !dpp_note_13!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Machine Design\ESE Main Practice Question\DPP_Notes\!dpp_note_13!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/1093f53e-54a6-4bad-9cd5-9a95878e3bc1.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !dpp_note_13!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !dpp_note_13!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !dpp_note_13!.pdf
    title File Exists: !dpp_note_13!
)
cd ..
cd ..

echo.
echo -----------------------------------------------------------
echo !ESC![34m[SUBJECT]!ESC![0m Industrial and Maintenance Engineering
echo -----------------------------------------------------------
mkdir "Industrial and Maintenance Engineering" 2>nul
cd /d "Industrial and Maintenance Engineering"

echo.
echo !ESC![35m[CHAPTER]!ESC![0m Lecture Planner - -Only PDF
echo -----------------------------------------------------------
mkdir "Lecture Planner - -Only PDF" 2>nul
cd /d "Lecture Planner - -Only PDF"
mkdir "Notes" 2>nul
set "note_103=Lecture Planner_Industrial and Maintenance Engineering"

echo.
if not exist "Notes\!note_103!.pdf" (
    title Downloading: !note_103!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_103!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Industrial and Maintenance Engineering\Lecture Planner - -Only PDF\Notes\!note_103!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/d9696a10-056d-4eaa-b158-326e3d4b8127.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_103!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_103!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_103!.pdf
    title File Exists: !note_103!
)
cd ..

echo.
echo !ESC![35m[CHAPTER]!ESC![0m ESE Main Practice Questions
echo -----------------------------------------------------------
mkdir "ESE Main Practice Questions" 2>nul
cd /d "ESE Main Practice Questions"
mkdir "Lectures" 2>nul
set "lecture_86=Industrial and Maintenance Engineering 06 - Industrial and Maintenance Engineering -Part 06"

echo.
if not exist "Lectures\!lecture_86!.mp4" (
    title Downloading: !lecture_86!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_86!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiZTIxZjQwMzktYjQ2NS00ZjFjLWE1MGUtYTlhZGMxMjU4MWE0IiwiZXhwIjoxNzU2MDcwOTkzfQ.7iaFgT54O5Mb6m8FzeJyovhUWc2bEq7bsUXpmeaAJ8s/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_86!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_86!.ts" (
        ren "Lectures\!lecture_86!.ts" "!lecture_86!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_86!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_86!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_86!.mp4
    title File Exists: !lecture_86!
)
set "lecture_87=Industrial and Maintenance Engineering 05 - Industrial and Maintenance Engineering -Part 05"

echo.
if not exist "Lectures\!lecture_87!.mp4" (
    title Downloading: !lecture_87!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_87!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiOGVlNWY5MGMtMWEzMy00MWI5LWIyYzYtYTQ3OWVmMmYwMTYyIiwiZXhwIjoxNzU2MDcwOTkzfQ.jUvBcCm77LQlZH6IRNMr_t3pPXVfsjxOBtBavZPgNCA/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_87!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_87!.ts" (
        ren "Lectures\!lecture_87!.ts" "!lecture_87!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_87!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_87!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_87!.mp4
    title File Exists: !lecture_87!
)
set "lecture_88=Industrial and Maintenance Engineering 04 - Industrial and Maintenance Engineering -Part 04"

echo.
if not exist "Lectures\!lecture_88!.mp4" (
    title Downloading: !lecture_88!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_88!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiNGZhNTM0NGQtZTlkZi00NjJlLTg4YjktYWUwN2RkOTRkNzI0IiwiZXhwIjoxNzU2MDcwOTkzfQ.MPFbcssBS4N1M8uNdmtqPgp-3vpxO6Oq1aMgpr5wruc/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_88!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_88!.ts" (
        ren "Lectures\!lecture_88!.ts" "!lecture_88!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_88!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_88!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_88!.mp4
    title File Exists: !lecture_88!
)
set "lecture_89=Industrial and Maintenance Engineering 03 - Industrial and Maintenance Engineering -Part 03"

echo.
if not exist "Lectures\!lecture_89!.mp4" (
    title Downloading: !lecture_89!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_89!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiYzkxYzYzYzEtNmFjZS00Mzk0LWJiNzctM2U1ZmU3MWM1MTAzIiwiZXhwIjoxNzU2MDcwOTkzfQ.XBYzDZbPq0WfSfkt1b69RQ1XmHHiEcgZPyWS2Frsbyo/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_89!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_89!.ts" (
        ren "Lectures\!lecture_89!.ts" "!lecture_89!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_89!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_89!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_89!.mp4
    title File Exists: !lecture_89!
)
set "lecture_90=Industrial and Maintenance Engineering 02 - Industrial and Maintenance Engineering -Part 02"

echo.
if not exist "Lectures\!lecture_90!.mp4" (
    title Downloading: !lecture_90!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_90!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiNmU5YjEzOWUtOWE0OS00MzZjLThlZGItOWM5ODgzNjZjNjgwIiwiZXhwIjoxNzU2MDcwOTkzfQ.6ow0Zdho7s90tIfAyULFLo1iXhYvmFeTbmKDd9f5di0/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_90!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_90!.ts" (
        ren "Lectures\!lecture_90!.ts" "!lecture_90!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_90!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_90!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_90!.mp4
    title File Exists: !lecture_90!
)
set "lecture_91=Industrial and Maintenance Engineering 01 - Industrial and Maintenance Engineering -Part 01"

echo.
if not exist "Lectures\!lecture_91!.mp4" (
    title Downloading: !lecture_91!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_91!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiNjA3NDFmYmItZTRkZi00NWUxLTlhNzMtYzIxMmIwYTdjYjlmIiwiZXhwIjoxNzU2MDcwOTkzfQ.5yZp29Mc9Rn2YhwPtRh8oVoM2ohzPkO49sYtGmRhovE/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_91!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_91!.ts" (
        ren "Lectures\!lecture_91!.ts" "!lecture_91!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_91!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_91!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_91!.mp4
    title File Exists: !lecture_91!
)
mkdir "Notes" 2>nul
set "note_104=Industrial and Maintenance Engineering 06_Class Notes"

echo.
if not exist "Notes\!note_104!.pdf" (
    title Downloading: !note_104!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_104!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Industrial and Maintenance Engineering\ESE Main Practice Questions\Notes\!note_104!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/0cc8ee03-2d19-448e-b156-62eee94f8cb5.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_104!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_104!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_104!.pdf
    title File Exists: !note_104!
)
set "note_105=Industrial and Maintenance Engineering 05_Class Notes"

echo.
if not exist "Notes\!note_105!.pdf" (
    title Downloading: !note_105!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_105!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Industrial and Maintenance Engineering\ESE Main Practice Questions\Notes\!note_105!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/890e629d-7a5a-4206-bf01-4c54d219dd2c.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_105!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_105!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_105!.pdf
    title File Exists: !note_105!
)
set "note_106=Industrial and Maintenance Engineering 04_Class Notes"

echo.
if not exist "Notes\!note_106!.pdf" (
    title Downloading: !note_106!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_106!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Industrial and Maintenance Engineering\ESE Main Practice Questions\Notes\!note_106!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/dcb98f6c-9351-4547-8beb-f2a88ef3fbc2.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_106!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_106!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_106!.pdf
    title File Exists: !note_106!
)
set "note_107=Industrial and Maintenance Engineering 03_Class Notes"

echo.
if not exist "Notes\!note_107!.pdf" (
    title Downloading: !note_107!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_107!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Industrial and Maintenance Engineering\ESE Main Practice Questions\Notes\!note_107!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/1a0c60a4-1a2f-4a1a-97fb-642c6709f177.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_107!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_107!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_107!.pdf
    title File Exists: !note_107!
)
set "note_108=Industrial and Maintenance Engineering 02_Class Notes"

echo.
if not exist "Notes\!note_108!.pdf" (
    title Downloading: !note_108!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_108!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Industrial and Maintenance Engineering\ESE Main Practice Questions\Notes\!note_108!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/3f44bca8-8e98-44be-bf23-982209f2f9f9.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_108!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_108!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_108!.pdf
    title File Exists: !note_108!
)
set "note_109=Industrial and Maintenance Engineering 01_Class Notes"

echo.
if not exist "Notes\!note_109!.pdf" (
    title Downloading: !note_109!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_109!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Industrial and Maintenance Engineering\ESE Main Practice Questions\Notes\!note_109!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/60d11a24-dc54-48e9-a77d-4ca9cfbf38b4.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_109!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_109!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_109!.pdf
    title File Exists: !note_109!
)
mkdir "DPP_Notes" 2>nul
set "dpp_note_14=Industrial and Maintenance Engineering_Theoretical Question Bank"

echo.
if not exist "DPP_Notes\!dpp_note_14!.pdf" (
    title Downloading: !dpp_note_14!
    echo !ESC![33m[DOWNLOAD]!ESC![0m DPP Notes: !dpp_note_14!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Industrial and Maintenance Engineering\ESE Main Practice Questions\DPP_Notes\!dpp_note_14!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/9d41662e-28fe-442a-8694-41049c01b66c.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !dpp_note_14!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !dpp_note_14!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !dpp_note_14!.pdf
    title File Exists: !dpp_note_14!
)
cd ..
cd ..

echo.
echo -----------------------------------------------------------
echo !ESC![34m[SUBJECT]!ESC![0m Engineering Mechanics
echo -----------------------------------------------------------
mkdir "Engineering Mechanics" 2>nul
cd /d "Engineering Mechanics"

echo.
echo !ESC![35m[CHAPTER]!ESC![0m Lecture Planner - -Only PDF
echo -----------------------------------------------------------
mkdir "Lecture Planner - -Only PDF" 2>nul
cd /d "Lecture Planner - -Only PDF"
mkdir "Notes" 2>nul
set "note_110=Engineering Mechanics Lecture Planner"

echo.
if not exist "Notes\!note_110!.pdf" (
    title Downloading: !note_110!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_110!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Engineering Mechanics\Lecture Planner - -Only PDF\Notes\!note_110!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/1c974b0e-2a36-4404-8a3e-f75f1e89dc6a.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_110!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_110!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_110!.pdf
    title File Exists: !note_110!
)
cd ..

echo.
echo !ESC![35m[CHAPTER]!ESC![0m ESE Main Practice Question
echo -----------------------------------------------------------
mkdir "ESE Main Practice Question" 2>nul
cd /d "ESE Main Practice Question"
mkdir "Lectures" 2>nul
set "lecture_92=Engineering Mechanics 04 -  Engineering Mechanics -Part 04"

echo.
if not exist "Lectures\!lecture_92!.mp4" (
    title Downloading: !lecture_92!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_92!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiMjVjZjRlMjctMGI3Ny00MGY5LThiM2MtYjNlOTQ1MTlhZTkxIiwiZXhwIjoxNzU2MDcwOTkzfQ.BlBToldk7VSaN9C7X-tmrLP2UNAGtP3TGRgJdqlRVXY/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_92!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_92!.ts" (
        ren "Lectures\!lecture_92!.ts" "!lecture_92!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_92!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_92!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_92!.mp4
    title File Exists: !lecture_92!
)
set "lecture_93=Engineering Mechanics 03 -  Engineering Mechanics -Part 03"

echo.
if not exist "Lectures\!lecture_93!.mp4" (
    title Downloading: !lecture_93!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_93!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiMmNjOTI1OTEtY2FhZC00NjA5LTgzNGYtZDg5NTNmYjFlYmVhIiwiZXhwIjoxNzU2MDcwOTkzfQ.x8eHoAyYfwP_rgGI0cYLtIvu90_6jl2Nql_N2mxS0Dc/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_93!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_93!.ts" (
        ren "Lectures\!lecture_93!.ts" "!lecture_93!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_93!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_93!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_93!.mp4
    title File Exists: !lecture_93!
)
set "lecture_94=Engineering Mechanics 02 -  Engineering Mechanics -Part 02"

echo.
if not exist "Lectures\!lecture_94!.mp4" (
    title Downloading: !lecture_94!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_94!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiN2M0OTFjYzYtMjYwNS00ODQ0LWE5ZDItNWY4MTY5MDJlMTQxIiwiZXhwIjoxNzU2MDcwOTkzfQ.5WtccVusmCFGrYShn0Fqf795BcxMhtUijKrkCelmgdc/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_94!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_94!.ts" (
        ren "Lectures\!lecture_94!.ts" "!lecture_94!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_94!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_94!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_94!.mp4
    title File Exists: !lecture_94!
)
set "lecture_95=Engineering Mechanics 01 -  Engineering Mechanics -Part 01"

echo.
if not exist "Lectures\!lecture_95!.mp4" (
    title Downloading: !lecture_95!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Lectures: !lecture_95!
    N_m3u8DL-RE "https://stream.pwjarvis.app/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2aWRlb0lkIjoiZDk2Y2Y1N2EtYzZlNi00ZjZlLTk2NDktMGI3MzZmNWRjYzgyIiwiZXhwIjoxNzU2MDcwOTkzfQ.6ljgFuojDyJHsNfek1XydF7nMVZq8bZtcyCNcKvPLts/hls/480/main.m3u8" --save-dir "Lectures" --save-name "!lecture_95!" -mt --live-pipe-mux --thread-count 16
    if exist "Lectures\!lecture_95!.ts" (
        ren "Lectures\!lecture_95!.ts" "!lecture_95!.mp4"
    )
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !lecture_95!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !lecture_95!
    )
    cls
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !lecture_95!.mp4
    title File Exists: !lecture_95!
)
mkdir "Notes" 2>nul
set "note_111=Engineering Mechanics 04 Class Notes"

echo.
if not exist "Notes\!note_111!.pdf" (
    title Downloading: !note_111!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_111!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Engineering Mechanics\ESE Main Practice Question\Notes\!note_111!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/06eca293-9909-49bb-b976-ad5ebd096b2a.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_111!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_111!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_111!.pdf
    title File Exists: !note_111!
)
set "note_112=Engineering Mechanics 03 Class Notes"

echo.
if not exist "Notes\!note_112!.pdf" (
    title Downloading: !note_112!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_112!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Engineering Mechanics\ESE Main Practice Question\Notes\!note_112!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/d73374bb-b818-4e4e-aa38-4caa7b409cf3.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_112!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_112!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_112!.pdf
    title File Exists: !note_112!
)
set "note_113=Engineering Mechanics 02 Class Notes"

echo.
if not exist "Notes\!note_113!.pdf" (
    title Downloading: !note_113!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_113!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Engineering Mechanics\ESE Main Practice Question\Notes\!note_113!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/494b60b6-f2a3-421c-bb26-b84947c87a31.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_113!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_113!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_113!.pdf
    title File Exists: !note_113!
)
set "note_114=Engineering Mechanics 01 Class Notes"

echo.
if not exist "Notes\!note_114!.pdf" (
    title Downloading: !note_114!
    echo !ESC![33m[DOWNLOAD]!ESC![0m Notes: !note_114!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Engineering Mechanics\ESE Main Practice Question\Notes\!note_114!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/3c00ed52-1724-44f3-b1d2-9474570930e0.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !note_114!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !note_114!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !note_114!.pdf
    title File Exists: !note_114!
)
mkdir "DPP_Notes" 2>nul
set "dpp_note_15=Engineering Mechanics  Theoretical Question Bank"

echo.
if not exist "DPP_Notes\!dpp_note_15!.pdf" (
    title Downloading: !dpp_note_15!
    echo !ESC![33m[DOWNLOAD]!ESC![0m DPP Notes: !dpp_note_15!
    pushd "%BATCH_ROOT%"
    set "full_path=%~dp0%batch%\Engineering Mechanics\ESE Main Practice Question\DPP_Notes\!dpp_note_15!.pdf"
    curl -L -o "\\?\!full_path!" "https://static.pw.live/5eb393ee95fab7468a79d189/ADMIN/908a78b9-bf21-422b-aed1-e542497b15b4.pdf"
    popd
    if !errorlevel! equ 0 (
        echo !ESC![32m[SUCCESS]!ESC![0m !dpp_note_15!
    ) else (
        echo !ESC![31m[FAILED]!ESC![0m !dpp_note_15!
    )
    
) else (
    echo !ESC![36m[EXISTS]!ESC![0m !dpp_note_15!.pdf
    title File Exists: !dpp_note_15!
)
cd ..
cd ..

echo.
echo -----------------------------------------------------------
echo !ESC![32m[COMPLETED]!ESC![0m All download tasks finished
echo -----------------------------------------------------------
title Download Complete
timeout /t 5