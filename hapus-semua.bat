@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
color 0C

echo ╔══════════════════════════════════════════════════╗
echo ║   ⚠️  HAPUS SEMUA FILE DARI GITHUB ⚠️           ║
echo ║   Repo tetap ada, tapi semua file dihapus       ║
echo ╚══════════════════════════════════════════════════╝
echo.

REM ==================== KONFIGURASI ====================
set GITHUB_USER=smpn8ciamis-blip
set REPO_NAME=bel-sekolah
set BRANCH=main
REM =====================================================

echo [INFO] Repo target:
echo    %GITHUB_USER%/%REPO_NAME%
echo.

set /p CONFIRM="⚠️  YAKIN mau hapus SEMUA file? Ketik HAPUS untuk konfirmasi: "
if /i not "%CONFIRM%"=="HAPUS" (
    echo Dibatalkan.
    pause & exit /b 0
)

echo.
echo [1/4] 📥 Sync dengan remote...
git fetch origin
git checkout %BRANCH%
git pull origin %BRANCH%

echo.
echo [2/4] 🗑️  Hapus semua file dari Git (kecuali .git)...
git rm -rf --cached . >nul 2>&1
git rm -rf . >nul 2>&1

echo.
echo [3/4] 💾 Commit penghapusan...
git commit -m "🗑️ Hapus semua file"

echo.
echo [4/4] 🚀 Push ke GitHub...
git push origin %BRANCH%

echo.
echo ╔══════════════════════════════════════════════════╗
echo ║   ✅ SEMUA FILE SUDAH DIHAPUS!                  ║
echo ╚══════════════════════════════════════════════════╝
echo.
echo    Cek: https://github.com/%GITHUB_USER%/%REPO_NAME%
echo.
echo    ⚠️  File lokal Anda TIDAK terhapus.
echo    Untuk mulai fresh: hapus folder .git, lalu jalankan
echo    setup-pertama-kali.bat lagi.
echo.
pause