@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
color 0B

echo ╔══════════════════════════════════════════════════╗
echo ║   🔔 BEL SEKOLAH - AUTO DEPLOY (v2 FIXED)       ║
echo ╚══════════════════════════════════════════════════╝
echo.

REM ==================== KONFIGURASI ====================
set GITHUB_USER=smpn8ciamis-blip
set REPO_NAME=bel-sekolah
set BRANCH=main
REM =====================================================

where git >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Git belum terinstall!
    pause & exit /b 1
)

if not exist .git (
    echo [ERROR] Repo belum di-init! Jalankan setup-pertama-kali.bat
    pause & exit /b 1
)

echo Masukkan versi release (contoh: 1.0.0)
set /p VERSION="Versi: "
if "%VERSION%"=="" (echo Versi wajib diisi! & pause & exit /b 1)

set /p COMMIT_MSG="Pesan commit (Enter = default): "
if "%COMMIT_MSG%"=="" set COMMIT_MSG=🚀 Release v%VERSION%

echo.
echo Versi  : v%VERSION%
echo Commit : %COMMIT_MSG%
echo Repo   : %GITHUB_USER%/%REPO_NAME%
echo.
set /p CONFIRM="Lanjut? (Y/N): "
if /i not "%CONFIRM%"=="Y" (echo Dibatalkan. & pause & exit /b 0)

echo.

REM ==== 1. Clean ====
echo [1/7] 🧹 Membersihkan cache...
if exist dist rmdir /s /q dist 2>nul
if exist out rmdir /s /q out 2>nul
echo       OK & echo.

REM ==== 2. Cek status ====
echo [2/7] 📋 Cek status...
git status --short
echo.

REM ==== 3. Stage ====
echo [3/7] 📦 Stage...
git add .
echo       OK & echo.

REM ==== 4. Commit ====
echo [4/7] 💾 Commit...
git commit -m "%COMMIT_MSG%" >nul 2>&1
if %errorlevel% neq 0 (
    echo       (tidak ada perubahan baru)
) else (
    echo       OK
)
echo.

REM ==== 5. Push (dengan auto-fallback force) ====
echo [5/7] 🚀 Push ke GitHub...
git push -u origin %BRANCH% 2>&1 | findstr /C:"rejected" >nul
if %errorlevel%==0 (
    echo.
    echo       ⚠️  Push ditolak (non-fast-forward^)
    echo       → Mencoba force push otomatis...
    echo.
    git push -f -u origin %BRANCH%
    if !errorlevel! neq 0 (
        echo [ERROR] Force push gagal juga!
        pause & exit /b 1
    )
)
echo       OK & echo.

REM ==== 6. Tag ====
echo [6/7] 🏷️  Buat tag v%VERSION%...
git tag -d "v%VERSION%" >nul 2>&1
git tag -a "v%VERSION%" -m "Release v%VERSION%"
echo       OK & echo.

REM ==== 7. Push Tag ====
echo [7/7] 🎯 Push tag (trigger build^)...
git push origin "v%VERSION%"
if %errorlevel% neq 0 (
    echo.
    echo       ⚠️  Tag sudah ada, coba force...
    git push -f origin "v%VERSION%"
)
echo       OK & echo.

echo ╔══════════════════════════════════════════════════╗
echo ║   ✅ DEPLOY BERHASIL!                            ║
echo ╚══════════════════════════════════════════════════╝
echo.
echo   📊 Cek build  : https://github.com/%GITHUB_USER%/%REPO_NAME%/actions
echo   📦 Download   : https://github.com/%GITHUB_USER%/%REPO_NAME%/releases
echo.

set /p OPEN="Buka halaman Actions? (Y/N): "
if /i "%OPEN%"=="Y" start https://github.com/%GITHUB_USER%/%REPO_NAME%/actions

pause