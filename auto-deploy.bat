@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
color 0E

echo ╔══════════════════════════════════════════════════╗
echo ║   🔧 SETUP PERTAMA KALI - BEL SEKOLAH 🔧        ║
echo ║   (Cukup jalankan SEKALI saja!)                  ║
echo ╚══════════════════════════════════════════════════╝
echo.

REM ==================== KONFIGURASI ====================
set GITHUB_USER=smpn8ciamis-blip
set REPO_NAME=bel-sekolah
set BRANCH=main
set GIT_NAME=Admin SMPN 8 Ciamis
set GIT_EMAIL=admin@smpn8ciamis.sch.id
REM =====================================================

echo [INFO] Setup untuk:
echo    GitHub User : %GITHUB_USER%
echo    Repository  : %REPO_NAME%
echo    Branch      : %BRANCH%
echo.
pause

REM ==== 1. Cek Git ====
echo [1/8] Cek Git...
where git >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Git belum terinstall!
    echo Download: https://git-scm.com/download/win
    pause & exit /b 1
)
echo    OK - Git terinstall
echo.

REM ==== 2. Set config Git global ====
echo [2/8] Set config Git...
git config --global user.name "%GIT_NAME%"
git config --global user.email "%GIT_EMAIL%"
git config --global credential.helper manager
git config --global init.defaultBranch main
echo    OK
echo.

REM ==== 3. Init repo lokal ====
echo [3/8] Init repository lokal...
if exist .git (
    echo    .git sudah ada, skip init
) else (
    git init
    git branch -M %BRANCH%
    echo    OK - Repo lokal dibuat
)
echo.

REM ==== 4. Set remote ====
echo [4/8] Set remote origin...
git remote remove origin 2>nul
git remote add origin https://github.com/%GITHUB_USER%/%REPO_NAME%.git
git remote -v
echo.

REM ==== 5. Buat .gitignore jika belum ada ====
echo [5/8] Cek .gitignore...
if not exist .gitignore (
    (
        echo node_modules/
        echo dist/
        echo out/
        echo *.log
        echo .DS_Store
        echo Thumbs.db
        echo .env
        echo wa-auth/
    ) > .gitignore
    echo    OK - .gitignore dibuat
) else (
    echo    .gitignore sudah ada
)
echo.

REM ==== 6. Stage semua file ====
echo [6/8] Stage semua file...
git add .
echo    OK
echo.

REM ==== 7. Commit pertama ====
echo [7/8] Commit pertama...
git commit -m "🎉 Initial commit - Bel Sekolah Elektron"
if %errorlevel% neq 0 echo    (tidak ada perubahan atau sudah commit)
echo.

REM ==== 8. Push pertama ====
echo [8/8] Push ke GitHub...
echo.
echo ⚠️  AKAN DIMINTA LOGIN GITHUB!
echo.
echo    Username : %GITHUB_USER%
echo    Password : GUNAKAN PERSONAL ACCESS TOKEN (bukan password!)
echo.
echo    Buat token di: https://github.com/settings/tokens
echo    Centang scope: [repo] dan [workflow]
echo.
pause

git push -u origin %BRANCH%

if %errorlevel% neq 0 (
    echo.
    echo ╔══════════════════════════════════════════════════╗
    echo ║   ❌ PUSH GAGAL! Cek hal berikut:               ║
    echo ╚══════════════════════════════════════════════════╝
    echo    1. Repo "%REPO_NAME%" sudah dibuat di GitHub?
    echo       Buat di: https://github.com/new
    echo    2. Token GitHub valid?
    echo    3. Koneksi internet OK?
    echo.
    pause & exit /b 1
)

echo.
echo ╔══════════════════════════════════════════════════╗
echo ║   ✅ SETUP BERHASIL!                             ║
echo ╚══════════════════════════════════════════════════╝
echo.
echo    Repo Anda: https://github.com/%GITHUB_USER%/%REPO_NAME%
echo.
echo    Langkah selanjutnya:
echo    → Klik 2x "auto-deploy.bat" setiap kali mau release
echo.
pause