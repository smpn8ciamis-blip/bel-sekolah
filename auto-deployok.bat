@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
color 0B

echo ╔══════════════════════════════════════════════════╗
echo ║   🔔 BEL SEKOLAH - AUTO DEPLOY 🔔               ║
echo ║   Push + Tag + Build otomatis                    ║
echo ╚══════════════════════════════════════════════════╝
echo.

REM ==================== KONFIGURASI ====================
set GITHUB_USER=smpn8ciamis-blip
set REPO_NAME=bel-sekolah
set BRANCH=main
REM =====================================================

REM ==== Cek Git ====
where git >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Git belum terinstall!
    pause & exit /b 1
)

REM ==== Cek .git ====
if not exist .git (
    echo [ERROR] Repo belum di-init!
    echo Jalankan dulu: setup-pertama-kali.bat
    pause & exit /b 1
)

REM ==== Input versi ====
echo.
echo Masukkan versi release
echo Contoh: 1.0.0  ^|  1.2.3  ^|  2.0.0
echo.
set /p VERSION="Versi: "

if "%VERSION%"=="" (
    echo [ERROR] Versi tidak boleh kosong!
    pause & exit /b 1
)

set /p COMMIT_MSG="Pesan commit (kosong = default): "
if "%COMMIT_MSG%"=="" set COMMIT_MSG=🚀 Release v%VERSION%

echo.
echo ═══════════════════════════════════════════════════
echo    Versi    : v%VERSION%
echo    Commit   : %COMMIT_MSG%
echo    Repo     : %GITHUB_USER%/%REPO_NAME%
echo ═══════════════════════════════════════════════════
echo.
set /p CONFIRM="Lanjut? (Y/N): "
if /i not "%CONFIRM%"=="Y" (
    echo Dibatalkan.
    pause & exit /b 0
)

echo.

REM ==== STEP 1: Clean ====
echo [1/7] 🧹 Membersihkan cache build lama...
if exist dist rmdir /s /q dist 2>nul
if exist out rmdir /s /q out 2>nul
echo       OK
echo.

REM ==== STEP 2: Cek status ====
echo [2/7] 📋 Cek status repo...
git status --short
echo.

REM ==== STEP 3: Stage ====
echo [3/7] 📦 Stage semua file...
git add .
echo       OK
echo.

REM ==== STEP 4: Commit ====
echo [4/7] 💾 Commit perubahan...
git commit -m "%COMMIT_MSG%" >nul 2>&1
if %errorlevel% neq 0 (
    echo       (tidak ada perubahan baru, lanjut ke tag)
) else (
    echo       OK - Commit dibuat
)
echo.

REM ==== STEP 5: Push branch ====
echo [5/7] 🚀 Push ke GitHub (%BRANCH%)...
git push -u origin %BRANCH%
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Push gagal! Cek koneksi / kredensial.
    pause & exit /b 1
)
echo       OK
echo.

REM ==== STEP 6: Buat tag ====
echo [6/7] 🏷️  Buat tag v%VERSION%...
git tag -d "v%VERSION%" >nul 2>&1
git tag -a "v%VERSION%" -m "Release v%VERSION%"
echo       OK
echo.

REM ==== STEP 7: Push tag (trigger build) ====
echo [7/7] 🎯 Push tag (trigger auto-build)...
git push origin "v%VERSION%"
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Push tag gagal!
    pause & exit /b 1
)
echo       OK
echo.

echo ╔══════════════════════════════════════════════════╗
echo ║   ✅ DEPLOY BERHASIL!                            ║
echo ╚══════════════════════════════════════════════════╝
echo.
echo   📊 Cek progress build (3-5 menit):
echo      https://github.com/%GITHUB_USER%/%REPO_NAME%/actions
echo.
echo   📦 Download .exe setelah selesai:
echo      https://github.com/%GITHUB_USER%/%REPO_NAME%/releases
echo.

REM ==== Auto buka browser ====
set /p OPEN="Buka halaman Actions di browser? (Y/N): "
if /i "%OPEN%"=="Y" (
    start https://github.com/%GITHUB_USER%/%REPO_NAME%/actions
)

echo.
pause