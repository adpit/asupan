@echo off
setlocal enabledelayedexpansion

:: === HANYA GANTI NAMA FILE DI BAWAH INI SAJA ===
set "FILE-SATU=lele1.ex4"
set "FILE-DUA=lele2.ex4"
set "FILE-TIGA=lele3.ex4"
:: =============================================

:: Definisikan path sumber untuk semua file
set "EA-SATU=%USERPROFILE%\Downloads\%FILE-SATU%"
set "EA-DUA=%USERPROFILE%\Downloads\%FILE-DUA%"
set "EA-TIGA=%USERPROFILE%\Downloads\%FILE-TIGA%"

:: Path folder arsip
set "archive_folder=%USERPROFILE%\Downloads\arsip"

:: Path folder utama Terminal MetaQuotes
set "metaquotes_folder=C:\Users\Administrator\AppData\Roaming\MetaQuotes\Terminal"

:: Periksa apakah folder MetaQuotes ada
if not exist "%metaquotes_folder%" (
    echo ========================================
    echo ^| [91mERROR: Folder MetaQuotes tidak ditemukan di[0m
    echo ^| [93m"%metaquotes_folder%"[0m
    echo ========================================
    goto :end_prompt
)

:: Periksa keberadaan semua file sumber
set "missing_files=0"
for %%F in ("%EA-SATU%" "%EA-DUA%" "%EA-TIGA%") do (
    if not exist "%%F" (
        echo ========================================
        echo ^| [91mERROR: File sumber %%~nxF tidak ditemukan.[0m
        echo ========================================
        set "missing_files=1"
    )
)
if "!missing_files!"=="1" (
    goto :end_prompt
)

:: Buat folder arsip jika belum ada
if not exist "%archive_folder%" (
    mkdir "%archive_folder%"
    if !errorlevel! equ 0 (
        echo ========================================
        echo ^| [92mFolder arsip dibuat di:[0m
        echo ^| [96m"%archive_folder%"[0m
        echo ========================================
    ) else (
        echo ========================================
        echo ^| [91mERROR: Gagal membuat folder arsip.[0m
        echo ========================================
        goto :end_prompt
    )
)

:: Loop melalui semua subfolder di dalam folder Terminal
for /d %%i in ("%metaquotes_folder%\*") do (
    set "target_folder=%%i\MQL4\Experts"

    :: Periksa apakah folder Experts ada di subfolder
    if not exist "!target_folder!" (
        echo ========================================
        echo ^| [93mWARNING: Folder Experts tidak ditemukan di[0m
        echo ^| [96m"%%i"[0m
        echo ^| [93mMelewati...[0m
        echo ========================================
    ) else (
        echo ========================================
        echo ^| [92mMemproses folder:[0m
        echo ^| [96m"!target_folder!"[0m
        echo ========================================

        :: === PINDAHKAN FILE .ex4 YANG TIDAK DIINGINKAN KE ARSIP ===
        echo ^| [93mMemindahkan file .ex4 yang tidak diinginkan ke arsip...[0m
        for %%f in ("!target_folder!\*.ex4") do (
            set "filename=%%~nxf"
            set "should_move=1"
            if "!filename!"=="%FILE-SATU%" set "should_move=0"
            if "!filename!"=="%FILE-DUA%" set "should_move=0"
            if "!filename!"=="%FILE-TIGA%" set "should_move=0"

            if "!should_move!"=="1" (
                :: Buat struktur folder di arsip yang mencerminkan path asal
                set "relative_path=%%i\MQL4\Experts"
                :: Hilangkan bagian path MetaQuotes untuk membuat relative path
                call set "relative_path=!relative_path:%metaquotes_folder%\=!"
                set "archive_subfolder=%archive_folder%\!relative_path!"
                if not exist "!archive_subfolder!" mkdir "!archive_subfolder!"

                move "%%f" "!archive_subfolder!\!filename!" >nul 2>&1
                if !errorlevel! equ 0 (
                    echo ^| [92m  - Dipindahkan: !filename![0m
                ) else (
                    echo ^| [91m  - Gagal memindahkan: !filename![0m
                )
            ) else (
                echo ^| [94m  - Dipertahankan: !filename![0m
            )
        )
        echo ========================================

        :: Fungsi salin hanya jika berbeda
        call :CopyIfDifferent "%EA-SATU%" "!target_folder!\%FILE-SATU%" "[BTC]"
        call :CopyIfDifferent "%EA-DUA%" "!target_folder!\%FILE-DUA%" "[CENT-OFF]"
        call :CopyIfDifferent "%EA-TIGA%" "!target_folder!\%FILE-TIGA%" "[CUBOT-CENT-OFF]"
    )
)

echo ========================================
echo ^| [92m      Proses penyalinan selesai.[0m       ^|
echo ========================================

:end_prompt
echo.
echo Tekan tombol apa saja untuk menutup jendela ini...
pause >nul
exit /b 0

:: ===============================
:: FUNGSI: CopyIfDifferent
:: ===============================
:CopyIfDifferent source_file target_file label
set "source=%~1"
set "target=%~2"
set "label=%~3"

:: Jika file target tidak ada, langsung salin
if not exist "%target%" (
    copy "%source%" "%target%" >nul
    if !errorlevel! equ 0 (
        echo ^| [92m%label% File baru disalin ke target.[0m
    ) else (
        echo ^| [91m%label% ERROR: Gagal menyalin file ke target.[0m
    )
    exit /b
)

:: Jika file ada, bandingkan dengan fc
fc /b "%source%" "%target%" >nul
if errorlevel 1 (
    del /f /q "%target%" >nul
    copy "%source%" "%target%" >nul
    if !errorlevel! equ 0 (
        echo ^| [92m%label% File berbeda. Telah diperbarui.[0m
    ) else (
        echo ^| [91m%label% ERROR: Gagal memperbarui file.[0m
    )
) else (
    echo ^| [96m%label% File sama. Tidak ada perubahan.[0m
)
exit /b
