@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
color 0B
title BEL SEKOLAH - HARDCORE DEPLOY

REM ═══════════════════════════════════════════════════════════
REM  KONFIGURASI - EDIT BAGIAN INI SAJA!
REM ═══════════════════════════════════════════════════════════
set GITHUB_USER=smpn8ciamis-blip
set REPO_NAME=bel-sekolah
set VERSION=1.0.0
set GIT_NAME=Admin SMPN 8 Ciamis
set GIT_EMAIL=admin@smpn8ciamis.sch.id
REM ═══════════════════════════════════════════════════════════

cls
echo.
echo   ╔══════════════════════════════════════════════════════╗
echo   ║   🔥 BEL SEKOLAH - HARDCORE DEPLOY 🔥                ║
echo   ║   Full Auto: Build + Push + Tag + Trigger            ║
echo   ╚══════════════════════════════════════════════════════╝
echo.
echo   Target : %GITHUB_USER%/%REPO_NAME%
echo   Versi  : v%VERSION%
echo.
pause

REM ═══════════════════ STEP 0: CEK GIT ═══════════════════
echo.
echo   [0/10] 🔍 Cek Git...
where git >nul 2>nul
if %errorlevel% neq 0 (
    echo   ❌ Git belum terinstall!
    echo   Download: https://git-scm.com/download/win
    pause & exit /b 1
)
echo   ✅ Git OK

REM ═══════════════════ STEP 1: BUAT STRUKTUR FOLDER ═══════════════════
echo.
echo   [1/10] 📁 Membuat struktur folder...
if not exist "src" mkdir "src"
if not exist "assets" mkdir "assets"
if not exist "build" mkdir "build"
if not exist ".github\workflows" mkdir ".github\workflows"
echo   ✅ Folder dibuat: src/ assets/ build/ .github/workflows/

REM ═══════════════════ STEP 2: BUAT package.json ═══════════════════
echo.
echo   [2/10] 📝 Membuat package.json...
(
echo {
echo   "name": "bel-sekolah",
echo   "version": "%VERSION%",
echo   "description": "Bel Sekolah Elektron dengan WhatsApp Gateway",
echo   "main": "src/main.js",
echo   "author": "SMPN 8 Ciamis",
echo   "license": "MIT",
echo   "scripts": {
echo     "start": "electron .",
echo     "build": "electron-builder --win --x64"
echo   },
echo   "dependencies": {
echo     "@whiskeysockets/baileys": "^6.7.9",
echo     "qrcode": "^1.5.4",
echo     "pino": "^9.5.0"
echo   },
echo   "devDependencies": {
echo     "electron": "^30.0.0",
echo     "electron-builder": "^24.13.3"
echo   },
echo   "build": {
echo     "appId": "com.smpn8ciamis.belsekolah",
echo     "productName": "BelSekolah",
echo     "directories": { "output": "dist", "buildResources": "build" },
echo     "files": ["src/**/*", "assets/**/*", "package.json"],
echo     "win": {
echo       "target": [
echo         { "target": "nsis", "arch": ["x64"] },
echo         { "target": "portable", "arch": ["x64"] }
echo       ],
echo       "icon": "build/icon.ico"
echo     },
echo     "nsis": {
echo       "oneClick": false,
echo       "allowToChangeInstallationDirectory": true,
echo       "createDesktopShortcut": true,
echo       "shortcutName": "Bel Sekolah",
echo       "artifactName": "BelSekolah-Setup-${version}.${ext}"
echo     },
echo     "portable": {
echo       "artifactName": "BelSekolah-Portable-${version}.${ext}"
echo     }
echo   }
echo }
) > package.json
echo   ✅ package.json dibuat

REM ═══════════════════ STEP 3: BUAT src/main.js ═══════════════════
echo.
echo   [3/10] 📝 Membuat src/main.js...
(
echo const { app, BrowserWindow, ipcMain, Menu, globalShortcut, dialog } = require('electron');
echo const path = require('path');
echo const fs = require('fs');
echo.
echo const WhatsAppManager = require('./wa-manager');
echo.
echo let mainWindow;
echo let waManager = null;
echo.
echo const DATA_DIR = app.getPath('userData');
echo const DATA_FILE = path.join(DATA_DIR, 'bel-sekolah-data.json');
echo const SOUND_DIR = path.join(DATA_DIR, 'sounds');
echo.
echo if (!fs.existsSync(SOUND_DIR^)^) fs.mkdirSync(SOUND_DIR, { recursive: true }^);
echo.
echo function loadData() {
echo   try {
echo     if (fs.existsSync(DATA_FILE^)^) {
echo       return JSON.parse(fs.readFileSync(DATA_FILE, 'utf-8'^)^);
echo     }
echo   } catch (e^) { console.error('Load error:', e^); }
echo   return {
echo     schedules: [],
echo     active: false,
echo     volume: 0.8,
echo     ttsEnabled: true,
echo     ttsText: 'Bel berbunyi, siswa harap masuk kelas',
echo     soundFile: null,
echo     waEnabled: false,
echo     waTargets: [],
echo     waTemplate: '🔔 *BEL SEKOLAH*\n\n{label}\nWaktu: {time}\n\n{tts}',
echo     waSendToTeacher: true,
echo     guruList: []
echo   };
echo }
echo.
echo function saveData(data^) {
echo   try {
echo     fs.writeFileSync(DATA_FILE, JSON.stringify(data, null, 2^)^);
echo     return true;
echo   } catch (e^) { console.error('Save error:', e^); return false; }
echo }
echo.
echo let appData = loadData();
echo.
echo function createWindow() {
echo   mainWindow = new BrowserWindow({
echo     width: 1400,
echo     height: 900,
echo     minWidth: 1000,
echo     minHeight: 700,
echo     title: 'Bel Sekolah Elektron',
echo     backgroundColor: '#0f172a',
echo     webPreferences: {
echo       preload: path.join(__dirname, 'preload.js'^),
echo       contextIsolation: true,
echo       nodeIntegration: false
echo     },
echo     autoHideMenuBar: true
echo   }^);
echo   mainWindow.loadFile(path.join(__dirname, 'index.html'^)^);
echo   mainWindow.on('closed', (^) =^> { mainWindow = null; }^);
echo }
echo.
echo ipcMain.handle('data:get', (^) =^> appData^);
echo ipcMain.handle('data:save', (e, newData^) =^> {
echo   appData = { ...appData, ...newData };
echo   return saveData(appData^);
echo }^);
echo.
echo ipcMain.handle('schedule:add', (e, sch^) =^> {
echo   appData.schedules.push(sch^);
echo   saveData(appData^);
echo   return { ok: true, data: appData.schedules };
echo }^);
echo.
echo ipcMain.handle('schedule:update', (e, { index, sch }^) =^> {
echo   if (index ^>= 0 ^&^& index ^< appData.schedules.length^) {
echo     appData.schedules[index] = { ...appData.schedules[index], ...sch };
echo     saveData(appData^);
echo   }
echo   return { ok: true, data: appData.schedules };
echo }^);
echo.
echo ipcMain.handle('schedule:delete', (e, index^) =^> {
echo   appData.schedules.splice(index, 1^);
echo   saveData(appData^);
echo   return { ok: true, data: appData.schedules };
echo }^);
echo.
echo ipcMain.handle('schedule:export', async (^) =^> {
echo   const { filePath } = await dialog.showSaveDialog(mainWindow, {
echo     title: 'Export Jadwal',
echo     defaultPath: 'jadwal-bel-' + new Date(^).toISOString(^).slice(0,10^) + '.json',
echo     filters: [{ name: 'JSON', extensions: ['json'] }, { name: 'CSV', extensions: ['csv'] }]
echo   }^);
echo   if (!filePath^) return { ok: false };
echo   try {
echo     if (filePath.endsWith('.csv'^)^) {
echo       const header = 'waktu,label,tipe,hari,enabled\n';
echo       const rows = appData.schedules.map(s =^>
echo         s.time + ',"' + s.label + '","' + s.type + '","' + s.days.join(',') + '",' + s.enabled
echo       ^).join('\n'^);
echo       fs.writeFileSync(filePath, header + rows, 'utf-8'^);
echo     } else {
echo       fs.writeFileSync(filePath, JSON.stringify(appData.schedules, null, 2^), 'utf-8'^);
echo     }
echo     return { ok: true, filePath };
echo   } catch (e^) { return { ok: false, error: e.message }; }
echo }^);
echo.
echo ipcMain.handle('schedule:import', async (^) =^> {
echo   const { filePaths } = await dialog.showOpenDialog(mainWindow, {
echo     title: 'Import Jadwal',
echo     properties: ['openFile'],
echo     filters: [{ name: 'Jadwal', extensions: ['json', 'csv'] }]
echo   }^);
echo   if (!filePaths ^|^| filePaths.length === 0^) return { ok: false };
echo   try {
echo     const content = fs.readFileSync(filePaths[0], 'utf-8'^);
echo     let imported = [];
echo     if (filePaths[0].endsWith('.csv'^)^) {
echo       const lines = content.trim(^).split('\n'^).slice(1^);
echo       imported = lines.map(line =^> {
echo         const parts = line.match(/(".*?"^|[^,]+^)(?=\s*,^\|\s*$^)/g^);
echo         if (!parts ^|^| parts.length ^< 5^) return null;
echo         return {
echo           time: parts[0].trim(^),
echo           label: parts[1].replace(/"/g, ''^).trim(^),
echo           type: parts[2].replace(/"/g, ''^).trim(^) ^|^| 'normal',
echo           days: parts[3].replace(/"/g, ''^).split(','^).map(d =^> parseInt(d.trim(^)^)^),
echo           enabled: parts[4].trim(^).toLowerCase(^) === 'true'
echo         };
echo       }^).filter(Boolean^);
echo     } else {
echo       imported = JSON.parse(content^);
echo     }
echo     if (!Array.isArray(imported^)^) throw new Error('Format tidak valid'^);
echo     const mode = await dialog.showMessageBox(mainWindow, {
echo       type: 'question',
echo       buttons: ['Gabung', 'Timpa', 'Batal'],
echo       defaultId: 0,
echo       title: 'Mode Import',
echo       message: 'Ditemukan ' + imported.length + ' jadwal. Mau diapakan?'
echo     }^);
echo     if (mode.response === 0^) appData.schedules = [...appData.schedules, ...imported];
echo     else if (mode.response === 1^) appData.schedules = imported;
echo     else return { ok: false, cancelled: true };
echo     saveData(appData^);
echo     return { ok: true, count: imported.length, data: appData.schedules };
echo   } catch (e^) { return { ok: false, error: e.message }; }
echo }^);
echo.
echo ipcMain.handle('sound:upload', async (^) =^> {
echo   const { filePaths } = await dialog.showOpenDialog(mainWindow, {
echo     title: 'Pilih File Suara',
echo     properties: ['openFile'],
echo     filters: [{ name: 'Audio', extensions: ['mp3', 'wav', 'ogg', 'm4a'] }]
echo   }^);
echo   if (!filePaths ^|^| filePaths.length === 0^) return { ok: false };
echo   try {
echo     const src = filePaths[0];
echo     const ext = path.extname(src^);
echo     const dest = path.join(SOUND_DIR, 'bell-sound' + ext^);
echo     if (fs.existsSync(SOUND_DIR^)^) {
echo       fs.readdirSync(SOUND_DIR^).forEach(f =^> {
echo         if (f.startsWith('bell-sound'^)^) fs.unlinkSync(path.join(SOUND_DIR, f^)^);
echo       }^);
echo     }
echo     fs.copyFileSync(src, dest^);
echo     appData.soundFile = dest;
echo     saveData(appData^);
echo     return { ok: true, path: dest, name: path.basename(src^) };
echo   } catch (e^) { return { ok: false, error: e.message }; }
echo }^);
echo.
echo ipcMain.handle('sound:remove', (^) =^> {
echo   try {
echo     if (fs.existsSync(SOUND_DIR^)^) {
echo       fs.readdirSync(SOUND_DIR^).forEach(f =^> fs.unlinkSync(path.join(SOUND_DIR, f^)^)^);
echo     }
echo     appData.soundFile = null;
echo     saveData(appData^);
echo     return { ok: true };
echo   } catch (e^) { return { ok: false, error: e.message }; }
echo }^);
echo.
echo ipcMain.handle('sound:info', (^) =^> {
echo   if (appData.soundFile ^&^& fs.existsSync(appData.soundFile^)^) {
echo     return {
echo       ok: true,
echo       name: path.basename(appData.soundFile^),
echo       size: fs.statSync(appData.soundFile^).size
echo     };
echo   }
echo   return { ok: false };
echo }^);
echo.
echo ipcMain.handle('guru:add', (e, guru^) =^> {
echo   if (!appData.guruList^) appData.guruList = [];
echo   appData.guruList.push({ ...guru, id: Date.now(^) }^);
echo   saveData(appData^);
echo   return { ok: true, data: appData.guruList };
echo }^);
echo.
echo ipcMain.handle('guru:update', (e, { id, guru }^) =^> {
echo   const idx = appData.guruList.findIndex(g =^> g.id === id^);
echo   if (idx ^>= 0^) {
echo     appData.guruList[idx] = { ...appData.guruList[idx], ...guru };
echo     saveData(appData^);
echo   }
echo   return { ok: true, data: appData.guruList };
echo }^);
echo.
echo ipcMain.handle('guru:delete', (e, id^) =^> {
echo   appData.guruList = appData.guruList.filter(g =^> g.id !== id^);
echo   saveData(appData^);
echo   return { ok: true, data: appData.guruList };
echo }^);
echo.
echo ipcMain.handle('guru:import', async (^) =^> {
echo   const { filePaths } = await dialog.showOpenDialog(mainWindow, {
echo     title: 'Import Daftar Guru',
echo     properties: ['openFile'],
echo     filters: [{ name: 'Data', extensions: ['json', 'csv'] }]
echo   }^);
echo   if (!filePaths ^|^| filePaths.length === 0^) return { ok: false };
echo   try {
echo     const content = fs.readFileSync(filePaths[0], 'utf-8'^);
echo     let guru = [];
echo     if (filePaths[0].endsWith('.csv'^)^) {
echo       const lines = content.trim(^).split('\n'^).slice(1^);
echo       guru = lines.map(line =^> {
echo         const parts = line.split(','^).map(p =^> p.trim(^).replace(/^"^|"$/g, ''^)^);
echo         return { nama: parts[0], mapel: parts[1], phone: parts[2], aktif: true };
echo       }^).filter(g =^> g.nama ^&^& g.phone^);
echo     } else {
echo       guru = JSON.parse(content^);
echo     }
echo     if (!Array.isArray(guru^)^) throw new Error('Format tidak valid'^);
echo     guru = guru.map(g =^> ({ ...g, id: Date.now(^) + Math.random(^), aktif: g.aktif !== false }^)^);
echo     appData.guruList = [...(appData.guruList ^|^| []^), ...guru];
echo     saveData(appData^);
echo     return { ok: true, count: guru.length, data: appData.guruList };
echo   } catch (e^) { return { ok: false, error: e.message }; }
echo }^);
echo.
echo function ensureWAManager(^) {
echo   if (!waManager^) waManager = new WhatsAppManager(mainWindow, appData^);
echo   return waManager;
echo }
echo.
echo ipcMain.handle('wa:connect', async (^) =^> {
echo   const mgr = ensureWAManager(^);
echo   await mgr.connect(^);
echo   return { ok: true };
echo }^);
echo.
echo ipcMain.handle('wa:disconnect', async (^) =^> {
echo   if (waManager^) await waManager.disconnect(^);
echo   return { ok: true };
echo }^);
echo.
echo ipcMain.handle('wa:status', (^) =^> {
echo   return waManager ? waManager.getStatus(^) : { connected: false };
echo }^);
echo.
echo ipcMain.handle('wa:send-test', async (e, { phone, message }^) =^> {
echo   if (!waManager ^|^| !waManager.isConnected(^)^) {
echo     return { ok: false, error: 'WhatsApp belum terhubung' };
echo   }
echo   return waManager.sendMessage(phone, message^);
echo }^);
echo.
echo ipcMain.handle('bell:fired', async (e, schedule^) =^> {
echo   if (!appData.waEnabled^) return { ok: false, reason: 'WA disabled' };
echo   const mgr = ensureWAManager(^);
echo   if (!mgr.isConnected(^)^) return { ok: false, reason: 'WA not connected' };
echo   const message = appData.waTemplate
echo     .replace(/{label}/g, schedule.label^)
echo     .replace(/{time}/g, schedule.time^)
echo     .replace(/{tts}/g, schedule.ttsText ^|^| appData.ttsText^);
echo   const results = [];
echo   const targets = (appData.waTargets ^|^| []^).filter(t =^> t.aktif^);
echo   for (const t of targets^) {
echo     const r = await mgr.sendMessage(t.phone, message^);
echo     results.push({ name: t.name, phone: t.phone, ...r });
echo   }
echo   if (appData.waSendToTeacher^) {
echo     const gurus = (appData.guruList ^|^| []^).filter(g =^> g.aktif ^&^& g.phone^);
echo     for (const g of gurus^) {
echo       const r = await mgr.sendMessage(g.phone, message^);
echo       results.push({ name: g.nama, phone: g.phone, role: 'guru', ...r });
echo     }
echo   }
echo   return { ok: true, sent: results.length, results };
echo }^);
echo.
echo function createMenu(^) {
echo   Menu.setApplicationMenu(Menu.buildFromTemplate([
echo     {
echo       label: 'File',
echo       submenu: [
echo         { label: 'Reload', accelerator: 'Ctrl+R', click: (^) =^> mainWindow.reload(^) },
echo         { label: 'Fullscreen', accelerator: 'F11', click: (^) =^> mainWindow.setFullScreen(!mainWindow.isFullScreen(^)^) },
echo         { type: 'separator' },
echo         { label: 'Keluar', accelerator: 'Ctrl+Q', click: (^) =^> app.quit(^) }
echo       ]
echo     },
echo     {
echo       label: 'WhatsApp',
echo       submenu: [
echo         { label: 'Hubungkan', click: (^) =^> ensureWAManager(^).connect(^) },
echo         { label: 'Putuskan', click: (^) =^> waManager ^&^& waManager.disconnect(^) }
echo       ]
echo     }
echo   ]^)^);
echo }
echo.
echo app.whenReady(^).then((^) =^> {
echo   createWindow(^);
echo   createMenu(^);
echo   const { powerSaveBlocker } = require('electron');
echo   powerSaveBlocker.start('prevent-display-sleep'^);
echo   globalShortcut.register('F11', (^) =^> {
echo     if (mainWindow^) mainWindow.setFullScreen(!mainWindow.isFullScreen(^)^);
echo   }^);
echo }^);
echo.
echo app.on('window-all-closed', (^) =^> {
echo   if (process.platform !== 'darwin'^) app.quit(^);
echo }^);
echo.
echo app.on('will-quit', async (^) =^> {
echo   if (waManager^) await waManager.disconnect(^);
echo   globalShortcut.unregisterAll(^);
echo }^);
) > src\main.js
echo   ✅ src/main.js dibuat

REM ═══════════════════ STEP 4: BUAT src/wa-manager.js ═══════════════════
echo.
echo   [4/10] 📝 Membuat src/wa-manager.js...
(
echo const path = require('path');
echo const fs = require('fs');
echo const { app } = require('electron');
echo const makeWASocket = require('@whiskeysockets/baileys').default;
echo const { useMultiFileAuthState, DisconnectReason, fetchLatestBaileysVersion } = require('@whiskeysockets/baileys');
echo const QRCode = require('qrcode');
echo const pino = require('pino');
echo.
echo class WhatsAppManager {
echo   constructor(mainWindow, appData^) {
echo     this.mainWindow = mainWindow;
echo     this.appData = appData;
echo     this.sock = null;
echo     this.connected = false;
echo     this.qrData = null;
echo     this.authPath = path.join(app.getPath('userData'^), 'wa-auth'^);
echo     this.reconnectTimer = null;
echo   }
echo.
echo   isConnected(^) { return this.connected ^&^& this.sock; }
echo.
echo   getStatus(^) {
echo     return {
echo       connected: this.connected,
echo       hasQR: !!this.qrData,
echo       user: this.sock?.user?.id ^|^| null
echo     };
echo   }
echo.
echo   send(event, payload^) {
echo     if (this.mainWindow ^&^& !this.mainWindow.isDestroyed(^)^) {
echo       this.mainWindow.webContents.send(event, payload^);
echo     }
echo   }
echo.
echo   async connect(^) {
echo     try {
echo       const { state, saveCreds } = await useMultiFileAuthState(this.authPath^);
echo       const { version } = await fetchLatestBaileysVersion(^);
echo       this.sock = makeWASocket({
echo         version,
echo         auth: state,
echo         printQRInTerminal: false,
echo         logger: pino({ level: 'silent' }^),
echo         browser: ['Bel Sekolah', 'Chrome', '1.0.0'],
echo         connectTimeoutMs: 60000,
echo         defaultQueryTimeoutMs: 60000
echo       }^);
echo       this.sock.ev.on('creds.update', saveCreds^);
echo       this.sock.ev.on('connection.update', async (update^) =^> {
echo         const { connection, lastDisconnect, qr } = update;
echo         if (qr^) {
echo           try {
echo             this.qrData = await QRCode.toDataURL(qr, { width: 320, margin: 2 }^);
echo             this.send('wa:qr', this.qrData^);
echo           } catch (e^) { console.error('QR error:', e^); }
echo         }
echo         if (connection === 'open'^) {
echo           this.connected = true;
echo           this.qrData = null;
echo           this.send('wa:connected', {
echo             phone: this.sock.user?.id?.split(':'^)[0] ^|^| 'unknown',
echo             name: this.sock.user?.name ^|^| 'WhatsApp'
echo           }^);
echo         }
echo         if (connection === 'close'^) {
echo           this.connected = false;
echo           const statusCode = lastDisconnect?.error?.output?.statusCode;
echo           const shouldReconnect = statusCode !== DisconnectReason.loggedOut;
echo           this.send('wa:disconnected', {
echo             reason: statusCode === DisconnectReason.loggedOut ? 'loggedOut' : 'connectionLost',
echo             reconnect: shouldReconnect
echo           }^);
echo           if (shouldReconnect^) {
echo             this.reconnectTimer = setTimeout((^) =^> this.connect(^), 5000^);
echo           }
echo         }
echo       }^);
echo     } catch (err^) {
echo       console.error('WA connect error:', err^);
echo       this.send('wa:error', err.message^);
echo     }
echo   }
echo.
echo   async disconnect(^) {
echo     if (this.reconnectTimer^) {
echo       clearTimeout(this.reconnectTimer^);
echo       this.reconnectTimer = null;
echo     }
echo     try {
echo       if (this.sock^) {
echo         await this.sock.logout(^);
echo         this.sock = null;
echo         this.connected = false;
echo       }
echo       if (fs.existsSync(this.authPath^)^) {
echo         fs.rmSync(this.authPath, { recursive: true, force: true }^);
echo       }
echo     } catch (e^) { console.error('Disconnect error:', e^); }
echo   }
echo.
echo   async sendMessage(phone, message^) {
echo     if (!this.isConnected(^)^) return { ok: false, error: 'Not connected' };
echo     try {
echo       let cleanPhone = phone.replace(/[^0-9]/g, ''^);
echo       if (cleanPhone.startsWith('0'^)^) cleanPhone = '62' + cleanPhone.slice(1^);
echo       if (!cleanPhone.startsWith('62'^)^) cleanPhone = '62' + cleanPhone;
echo       const jid = cleanPhone + '@s.whatsapp.net';
echo       await this.sock.sendMessage(jid, { text: message }^);
echo       return { ok: true, phone: cleanPhone };
echo     } catch (err^) {
echo       return { ok: false, error: err.message };
echo     }
echo   }
echo }
echo.
echo module.exports = WhatsAppManager;
) > src\wa-manager.js
echo   ✅ src/wa-manager.js dibuat

REM ═══════════════════ STEP 5: BUAT src/preload.js ═══════════════════
echo.
echo   [5/10] 📝 Membuat src/preload.js...
(
echo const { contextBridge, ipcRenderer } = require('electron');
echo.
echo contextBridge.exposeInMainWorld('api', {
echo   getData: (^) =^> ipcRenderer.invoke('data:get'^),
echo   saveData: (data^) =^> ipcRenderer.invoke('data:save', data^),
echo   addSchedule: (sch^) =^> ipcRenderer.invoke('schedule:add', sch^),
echo   updateSchedule: (index, sch^) =^> ipcRenderer.invoke('schedule:update', { index, sch }^),
echo   deleteSchedule: (index^) =^> ipcRenderer.invoke('schedule:delete', index^),
echo   exportSchedules: (^) =^> ipcRenderer.invoke('schedule:export'^),
echo   importSchedules: (^) =^> ipcRenderer.invoke('schedule:import'^),
echo   uploadSound: (^) =^> ipcRenderer.invoke('sound:upload'^),
echo   removeSound: (^) =^> ipcRenderer.invoke('sound:remove'^),
echo   getSoundInfo: (^) =^> ipcRenderer.invoke('sound:info'^),
echo   addGuru: (guru^) =^> ipcRenderer.invoke('guru:add', guru^),
echo   updateGuru: (id, guru^) =^> ipcRenderer.invoke('guru:update', { id, guru }^),
echo   deleteGuru: (id^) =^> ipcRenderer.invoke('guru:delete', id^),
echo   importGuru: (^) =^> ipcRenderer.invoke('guru:import'^),
echo   waConnect: (^) =^> ipcRenderer.invoke('wa:connect'^),
echo   waDisconnect: (^) =^> ipcRenderer.invoke('wa:disconnect'^),
echo   waStatus: (^) =^> ipcRenderer.invoke('wa:status'^),
echo   waSendTest: (phone, message^) =^> ipcRenderer.invoke('wa:send-test', { phone, message }^),
echo   bellFired: (schedule^) =^> ipcRenderer.invoke('bell:fired', schedule^),
echo   onWACallback: (callback^) =^> {
echo     ipcRenderer.on('wa:qr', (_, qr^) =^> callback('qr', qr^)^);
echo     ipcRenderer.on('wa:connected', (_, d^) =^> callback('connected', d^)^);
echo     ipcRenderer.on('wa:disconnected', (_, d^) =^> callback('disconnected', d^)^);
echo     ipcRenderer.on('wa:error', (_, e^) =^> callback('error', e^)^);
echo   }
echo }^);
) > src\preload.js
echo   ✅ src/preload.js dibuat

REM ═══════════════════ STEP 6: BUAT src/index.html ═══════════════════
echo.
echo   [6/10] 📝 Membuat src/index.html...
(
echo ^<!DOCTYPE html^>
echo ^<html lang="id"^>
echo ^<head^>
echo ^<meta charset="UTF-8"^>
echo ^<title^>Bel Sekolah Elektron^</title^>
echo ^<style^>
echo *{margin:0;padding:0;box-sizing:border-box;font-family:'Segoe UI',sans-serif}
echo :root{--pri:#6366f1;--pri2:#4f46e5;--ok:#10b981;--bad:#ef4444;--warn:#f59e0b;--bg:#0f172a;--card:#1e293b;--inp:#334155;--tx:#f1f5f9;--mut:#94a3b8;--br:#334155}
echo body{background:var(--bg);color:var(--tx);padding:20px;min-height:100vh}
echo .wrap{max-width:1300px;margin:0 auto}
echo h1{text-align:center;font-size:1.8em;margin-bottom:20px;color:var(--pri)}
echo .grid{display:grid;grid-template-columns:1fr 1fr;gap:20px}
echo @media(max-width:1000px){.grid{grid-template-columns:1fr}}
echo .card{background:var(--card);border-radius:12px;padding:20px;margin-bottom:16px;border:1px solid var(--br)}
echo .card h2{color:var(--pri);font-size:1em;margin-bottom:14px;padding-bottom:10px;border-bottom:1px solid var(--br)}
echo .time{font-size:3.5em;font-weight:bold;color:var(--pri);text-align:center;letter-spacing:3px;font-family:monospace}
echo .date{text-align:center;color:var(--mut);margin-top:8px}
echo .btn{padding:10px 18px;border-radius:8px;border:none;font-weight:bold;cursor:pointer;margin:4px;transition:.2s;font-size:.9em}
echo .btn:hover{transform:translateY(-1px)}
echo .btn-p{background:var(--pri);color:white}.btn-p:hover{background:var(--pri2)}
echo .btn-ok{background:var(--ok);color:white}
echo .btn-bad{background:var(--bad);color:white}
echo .btn-warn{background:var(--warn);color:white}
echo .btn-ghost{background:transparent;color:var(--mut);border:1px solid var(--br)}
echo .btn-sm{padding:6px 12px;font-size:.8em}
echo .btn-block{width:100%;margin:4px 0}
echo input,select,textarea{width:100%;padding:10px;background:var(--inp);color:white;border:1px solid var(--br);border-radius:8px;margin:4px 0;font-size:.9em}
echo input:focus,select:focus,textarea:focus{outline:none;border-color:var(--pri)}
echo .row{display:flex;gap:8px}.row^>*{flex:1}
echo .tabs{display:flex;gap:4px;background:var(--bg);padding:4px;border-radius:10px;margin-bottom:14px;flex-wrap:wrap}
echo .tab{flex:1;padding:8px;border-radius:8px;border:none;background:transparent;color:var(--mut);font-weight:bold;cursor:pointer;font-size:.8em;min-width:80px}
echo .tab.active{background:var(--pri);color:white}
echo .item{background:var(--bg);border:1px solid var(--br);border-radius:10px;padding:12px;margin-bottom:8px;display:flex;align-items:center;gap:10px}
echo .item .badge{background:var(--pri);color:white;padding:6px 12px;border-radius:6px;font-weight:bold;font-family:monospace;min-width:70px;text-align:center}
echo .item .info{flex:1}.item .info .lbl{font-weight:bold}.item .info .meta{font-size:.75em;color:var(--mut);margin-top:2px}
echo .list{max-height:400px;overflow-y:auto}
echo .empty{text-align:center;color:var(--mut);padding:30px;font-size:.9em}
echo .qr-box{text-align:center;padding:20px}
echo .qr-box img{max-width:280px;border:4px solid var(--pri);border-radius:12px;background:white;padding:8px}
echo .status{padding:6px 12px;border-radius:20px;font-size:.8em;font-weight:bold;display:inline-block}
echo .status-on{background:rgba(16,185,129,.2);color:var(--ok)}
echo .status-off{background:rgba(148,163,184,.2);color:var(--mut)}
echo .status-wa{background:rgba(37,211,102,.2);color:#25d366}
echo .log{max-height:200px;overflow-y:auto;font-family:monospace;font-size:.8em}
echo .log div{padding:4px;border-bottom:1px solid var(--br);color:var(--mut)}
echo .log .t{color:var(--pri);margin-right:6px}
echo ::-webkit-scrollbar{width:6px}::-webkit-scrollbar-track{background:transparent}::-webkit-scrollbar-thumb{background:var(--br);border-radius:3px}
echo ^</style^>
echo ^</head^>
echo ^<body^>
echo ^<div class="wrap"^>
echo ^<h1^>🔔 Bel Sekolah Elektron^</h1^>
echo ^<div class="grid"^>
echo ^<div^>
echo ^<div class="card"^>
echo ^<div class="time" id="clock"^>00:00:00^</div^>
echo ^<div class="date" id="date"^>-^</div^>
echo ^<div style="text-align:center;margin-top:12px;color:var(--mut);font-size:.9em" id="next"^>Bel berikutnya: -^</div^>
echo ^</div^>
echo ^<div class="card"^>
echo ^<h2^>⚙️ Kontrol^</h2^>
echo ^<button class="btn btn-ok btn-block" id="btnStart"^>▶ Aktifkan Sistem^</button^>
echo ^<button class="btn btn-bad btn-block" id="btnStop"^>⏹ Nonaktifkan^</button^>
echo ^<div class="row" style="margin-top:8px"^>
echo ^<button class="btn btn-warn" id="btnTest"^>🔔 Test Bel^</button^>
echo ^<button class="btn btn-ghost" id="btnFull"^>⛶ Fullscreen^</button^>
echo ^</div^>
echo ^<div style="margin-top:12px"^>^<label style="font-size:.85em;color:var(--mut)"^>Volume: ^<span id="volVal"^>80%^</span^>^</label^>
echo ^<input type="range" id="volume" min="0" max="100" value="80"^>^</div^>
echo ^</div^>
echo ^<div class="card"^>
echo ^<h2^>📜 Log^</h2^>
echo ^<div class="log" id="log"^>^<div^>Belum ada aktivitas^</div^>^</div^>
echo ^</div^>
echo ^</div^>
echo ^<div^>
echo ^<div class="card"^>
echo ^<div class="tabs"^>
echo ^<button class="tab active" data-t="jadwal"^>📅 Jadwal^</button^>
echo ^<button class="tab" data-t="suara"^>🔊 Suara^</button^>
echo ^<button class="tab" data-t="guru"^>👨‍🏫 Guru^</button^>
echo ^<button class="tab" data-t="wa"^>💬 WhatsApp^</button^>
echo ^<button class="tab" data-t="setting"^>⚙️ Setting^</button^>
echo ^</div^>
echo ^<div id="tab-jadwal" class="tc"^>
echo ^<input type="time" id="inpTime"^>
echo ^<input type="text" id="inpLabel" placeholder="Nama bel (cth: Masuk Sekolah)"^>
echo ^<select id="inpType"^>
echo ^<option value="normal"^>Bel Normal^</option^>
echo ^<option value="panjang"^>Bel Panjang^</option^>
echo ^<option value="darurat"^>Bel Darurat^</option^>
echo ^<option value="istirahat"^>Bel Istirahat^</option^>
echo ^</select^>
echo ^<div id="daySel" style="display:flex;gap:6px;flex-wrap:wrap;margin:8px 0"^>^</div^>
echo ^<button class="btn btn-p btn-block" id="btnAdd"^>➕ Tambah Jadwal^</button^>
echo ^<div class="row" style="margin-top:8px"^>
echo ^<button class="btn btn-ghost btn-sm" id="btnExport"^>📤 Export^</button^>
echo ^<button class="btn btn-ghost btn-sm" id="btnImport"^>📥 Import^</button^>
echo ^</div^>
echo ^<div class="list" id="schedList" style="margin-top:12px"^>^<div class="empty"^>Belum ada jadwal^</div^>^</div^>
echo ^</div^>
echo ^<div id="tab-suara" class="tc" style="display:none"^>
echo ^<p style="color:var(--mut);font-size:.85em;margin-bottom:10px"^>Upload file suara bel custom (MP3/WAV, maks 10MB)^</p^>
echo ^<button class="btn btn-p btn-block" id="btnUploadSound"^>📁 Upload Suara Bel^</button^>
echo ^<div id="soundInfo" style="margin-top:12px;padding:12px;background:var(--bg);border-radius:8px;font-size:.85em;color:var(--mut)"^>Belum ada suara custom (pakai suara default)^</div^>
echo ^<button class="btn btn-bad btn-sm" id="btnRemoveSound" style="margin-top:8px"^>🗑 Hapus Suara Custom^</button^>
echo ^</div^>
echo ^<div id="tab-guru" class="tc" style="display:none"^>
echo ^<div class="row"^>
echo ^<input type="text" id="guruNama" placeholder="Nama guru"^>
echo ^<input type="text" id="guruMapel" placeholder="Mapel"^>
echo ^</div^>
echo ^<input type="text" id="guruPhone" placeholder="Nomor WA (cth: 08123456789)"^>
echo ^<button class="btn btn-p btn-block" id="btnAddGuru"^>➕ Tambah Guru^</button^>
echo ^<button class="btn btn-ghost btn-block btn-sm" id="btnImportGuru"^>📥 Import CSV/JSON Guru^</button^>
echo ^<div class="list" id="guruList" style="margin-top:12px"^>^<div class="empty"^>Belum ada guru^</div^>^</div^>
echo ^</div^>
echo ^<div id="tab-wa" class="tc" style="display:none"^>
echo ^<div class="row"^>
echo ^<button class="btn btn-ok btn-sm" id="btnWAConnect"^>🔗 Hubungkan^</button^>
echo ^<button class="btn btn-bad btn-sm" id="btnWADisconnect"^>🔌 Putuskan^</button^>
echo ^<span class="status status-off" id="waStatus" style="margin-left:auto"^>Offline^</span^>
echo ^</div^>
echo ^<div id="qrBox" class="qr-box" style="display:none"^>
echo ^<img id="qrImg"^>
echo ^<p style="color:var(--mut);font-size:.85em;margin-top:8px"^>Scan QR ini dengan WhatsApp Anda^</p^>
echo ^</div^>
echo ^<div id="waInfo" style="margin-top:12px;padding:12px;background:var(--bg);border-radius:8px;font-size:.85em;color:var(--mut)"^>Belum terhubung^</div^>
echo ^<label style="display:flex;align-items:center;gap:8px;margin:12px 0;color:var(--tx)"^>
echo ^<input type="checkbox" id="waEnabled" style="width:auto"^> Kirim notifikasi WA otomatis saat bel berbunyi
echo ^</label^>
echo ^<label style="display:flex;align-items:center;gap:8px;margin:8px 0;color:var(--tx)"^>
echo ^<input type="checkbox" id="waToTeacher" style="width:auto"^> Kirim ke semua guru di tab Guru
echo ^</label^>
echo ^<textarea id="waTemplate" rows="4" placeholder="Template pesan. Gunakan {label}, {time}, {tts}"^>^</textarea^>
echo ^<button class="btn btn-p btn-block btn-sm" id="btnSaveTemplate"^>💾 Simpan Template^</button^>
echo ^<div class="row" style="margin-top:12px"^>
echo ^<input type="text" id="testPhone" placeholder="Nomor test (cth: 08123456789)"^>
echo ^<button class="btn btn-warn btn-sm" id="btnTestWA"^>🧪 Test WA^</button^>
echo ^</div^>
echo ^</div^>
echo ^<div id="tab-setting" class="tc" style="display:none"^>
echo ^<label style="color:var(--mut);font-size:.85em"^>Teks TTS default^</label^>
echo ^<input type="text" id="ttsText"^>
echo ^<button class="btn btn-p btn-sm" id="btnSaveTTS" style="margin-top:8px"^>💾 Simpan^</button^>
echo ^</div^>
echo ^</div^>
echo ^</div^>
echo ^</div^>
echo ^<script^>
echo let D = {};
echo const DAYS = ['Min','Sen','Sel','Rab','Kam','Jum','Sab'];
echo.
echo async function init() {
echo   D = await window.api.getData(^);
echo   renderDays(^); renderSched(^); renderGuru(^); renderLog(^);
echo   document.getElementById('volume').value = (D.volume ^|^| 0.8) * 100;
echo   document.getElementById('volVal').textContent = Math.round((D.volume ^|^| 0.8) * 100) + '%';
echo   document.getElementById('waEnabled').checked = !!D.waEnabled;
echo   document.getElementById('waToTeacher').checked = D.waSendToTeacher !== false;
echo   document.getElementById('waTemplate').value = D.waTemplate ^|^| '';
echo   document.getElementById('ttsText').value = D.ttsText ^|^| '';
echo   updateClock(^);
echo   setInterval(updateClock, 1000^);
echo   checkSound(^);
echo   window.api.onWACallback((ev, data^) =^> {
echo     if (ev === 'qr'^) {
echo       document.getElementById('qrImg').src = data;
echo       document.getElementById('qrBox').style.display = 'block';
echo       document.getElementById('waInfo').textContent = 'Menunggu scan QR...';
echo     }
echo     if (ev === 'connected'^) {
echo       document.getElementById('qrBox').style.display = 'none';
echo       document.getElementById('waInfo').textContent = '✅ Terhubung: ' + (data.phone ^|^| ''^);
echo       document.getElementById('waStatus').textContent = 'Online';
echo       document.getElementById('waStatus').className = 'status status-wa';
echo     }
echo     if (ev === 'disconnected'^) {
echo       document.getElementById('waStatus').textContent = 'Offline';
echo       document.getElementById('waStatus').className = 'status status-off';
echo       document.getElementById('waInfo').textContent = '❌ Terputus. Klik Hubungkan lagi.';
echo     }
echo   }^);
echo }
echo.
echo function updateClock(^) {
echo   const n = new Date(^);
echo   document.getElementById('clock').textContent =
echo     String(n.getHours(^)^).padStart(2,'0'^) + ':' +
echo     String(n.getMinutes(^)^).padStart(2,'0'^) + ':' +
echo     String(n.getSeconds(^)^).padStart(2,'0'^);
echo   const days = ['Minggu','Senin','Selasa','Rabu','Kamis','Jumat','Sabtu'];
echo   const mon = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
echo   document.getElementById('date').textContent = days[n.getDay(^)^] + ', ' + n.getDate(^) + ' ' + mon[n.getMonth(^)^] + ' ' + n.getFullYear(^);
echo   if (D.active^) checkSched(n^);
echo }
echo.
echo async function checkSched(n^) {
echo   if (n.getSeconds(^) !== 0^) return;
echo   const t = String(n.getHours(^)^).padStart(2,'0'^) + ':' + String(n.getMinutes(^)^).padStart(2,'0'^);
echo   const key = n.toDateString(^) + '_' + t;
echo   if (!D._fired^) D._fired = {};
echo   if (D._fired[key]^) return;
echo   const day = n.getDay(^);
echo   D.schedules.forEach(async (s, i^) =^> {
echo     if (!s.enabled ^|^| s.time !== t ^|^| !s.days.includes(day^)^) return;
echo     D._fired[key] = true;
echo     log('🔔 ' + s.label + ' (' + s.time + ')'^);
echo     try { playBell(s.type^); } catch(e){}
echo     if (D.ttsEnabled^) speak(s.ttsText ^|^| D.ttsText^);
echo     window.api.bellFired(s^);
echo   }^);
echo }
echo.
echo let audioCtx = null;
echo function playBell(type = 'normal'^) {
echo   if (!audioCtx^) audioCtx = new (window.AudioContext ^|^| window.webkitAudioContext^)(^);
echo   if (audioCtx.state === 'suspended'^) audioCtx.resume(^);
echo   const now = audioCtx.currentTime;
echo   let pattern = type === 'panjang' ? [[0,800],[1.2,800],[2.4,800],[3.6,800]] : [[0,880],[0.8,880]];
echo   pattern.forEach(([t, f]^) =^> {
echo     const o = audioCtx.createOscillator(^);
echo     const g = audioCtx.createGain(^);
echo     o.frequency.value = f;
echo     g.gain.setValueAtTime(0, now + t^);
echo     g.gain.linearRampToValueAtTime((D.volume ^|^| 0.8^) * 0.5, now + t + 0.02^);
echo     g.gain.exponentialRampToValueAtTime(0.001, now + t + 0.6^);
echo     o.connect(g^); g.connect(audioCtx.destination^);
echo     o.start(now + t^); o.stop(now + t + 0.7^);
echo   }^);
echo }
echo.
echo function speak(text^) {
echo   if (!D.ttsEnabled ^|^| !text ^|^| !('speechSynthesis' in window^)^) return;
echo   speechSynthesis.cancel(^);
echo   const u = new SpeechSynthesisUtterance(text^);
echo   u.lang = 'id-ID'; u.rate = 0.95; u.volume = D.volume ^|^| 0.8;
echo   setTimeout((^) =^> speechSynthesis.speak(u), 1500^);
echo }
echo.
echo function renderDays(^) {
echo   document.getElementById('daySel').innerHTML = DAYS.map((d,i) =^>
echo     '^<label style="display:flex;align-items:center;gap:4px;font-size:.85em"^>^<input type="checkbox" value="' + i + '"' + (i^>=1^&^&i^<=5?' checked':'') + ' style="width:auto"^> ' + d + '^</label^>'
echo   ^).join(''^);
echo }
echo.
echo function renderSched(^) {
echo   const el = document.getElementById('schedList'^);
echo   if (!D.schedules ^|^| D.schedules.length === 0^) {
echo     el.innerHTML = '^<div class="empty"^>Belum ada jadwal^</div^>';
echo     return;
echo   }
echo   const sorted = [...D.schedules].sort((a,b) =^> a.time.localeCompare(b.time^)^);
echo   el.innerHTML = sorted.map(s =^> {
echo     const i = D.schedules.indexOf(s^);
echo     const days = s.days.map(d =^> DAYS[d]^).join(',');
echo     return '^<div class="item"^>^<span class="badge"^>' + s.time + '^</span^>^<div class="info"^>^<div class="lbl"^>' + s.label + '^</div^>^<div class="meta"^>' + days + ' • ' + s.type + '^</div^>^</div^>^<button class="btn btn-bad btn-sm" onclick="delS(' + i + ')"^>🗑^</button^>^</div^>';
echo   }^).join(''^);
echo }
echo.
echo async function delS(i^) {
echo   if (!confirm('Hapus jadwal ini?'^)^) return;
echo   const r = await window.api.deleteSchedule(i^);
echo   D.schedules = r.data; renderSched(^); log('🗑 Jadwal dihapus'^);
echo }
echo.
echo function renderGuru(^) {
echo   const el = document.getElementById('guruList'^);
echo   if (!D.guruList ^|^| D.guruList.length === 0^) {
echo     el.innerHTML = '^<div class="empty"^>Belum ada guru^</div^>';
echo     return;
echo   }
echo   el.innerHTML = D.guruList.map(g =^>
echo     '^<div class="item"^>^<div class="info"^>^<div class="lbl"^>' + g.nama + '^</div^>^<div class="meta"^>' + (g.mapel^|^|'-') + ' • ' + g.phone + '^</div^>^</div^>^<button class="btn btn-bad btn-sm" onclick="delG(' + g.id + ')"^>🗑^</button^>^</div^>'
echo   ^).join(''^);
echo }
echo.
echo async function delG(id^) {
echo   const r = await window.api.deleteGuru(id^);
echo   D.guruList = r.data; renderGuru(^);
echo }
echo.
echo function renderLog(^) {
echo   const el = document.getElementById('log'^);
echo   if (!D.log ^|^| D.log.length === 0^) { el.innerHTML = '^<div^>Belum ada aktivitas^</div^>'; return; }
echo   el.innerHTML = D.log.slice(0,50^).map(l =^> '^<div^>^<span class="t"^>[' + l.t + ']^</span^>' + l.m + '^</div^>'^).join(''^);
echo }
echo.
echo function log(m^) {
echo   if (!D.log^) D.log = [];
echo   const n = new Date(^);
echo   const t = String(n.getHours(^)^).padStart(2,'0'^) + ':' + String(n.getMinutes(^)^).padStart(2,'0'^) + ':' + String(n.getSeconds(^)^).padStart(2,'0'^);
echo   D.log.unshift({t,m}^);
echo   if (D.log.length ^> 100^) D.log.pop(^);
echo   renderLog(^);
echo }
echo.
echo async function checkSound(^) {
echo   const r = await window.api.getSoundInfo(^);
echo   if (r.ok^) document.getElementById('soundInfo').textContent = '✅ Suara custom: ' + r.name;
echo }
echo.
echo // EVENTS
echo document.querySelectorAll('.tab'^).forEach(t =^> t.onclick = (^) =^> {
echo   document.querySelectorAll('.tab'^).forEach(x =^> x.classList.remove('active'^)^);
echo   document.querySelectorAll('.tc'^).forEach(x =^> x.style.display = 'none'^);
echo   t.classList.add('active'^);
echo   document.getElementById('tab-' + t.dataset.t^).style.display = 'block';
echo }^);
echo.
echo document.getElementById('btnStart').onclick = async (^) =^> {
echo   D.active = true; await window.api.saveData({active:true}^);
echo   log('▶ Sistem diaktifkan'^); alert('✅ Sistem bel aktif'^);
echo };
echo document.getElementById('btnStop').onclick = async (^) =^> {
echo   D.active = false; await window.api.saveData({active:false}^);
echo   log('⏹ Sistem dimatikan'^);
echo };
echo document.getElementById('btnTest').onclick = (^) =^> { playBell('normal'^); speak('Tes bel sekolah'^); log('🔔 Test bel'^); };
echo document.getElementById('btnFull').onclick = (^) =^> {
echo   if (!document.fullscreenElement^) document.documentElement.requestFullscreen(^);
echo   else document.exitFullscreen(^);
echo };
echo document.getElementById('volume').oninput = async (e^) =^> {
echo   D.volume = e.target.value / 100;
echo   document.getElementById('volVal').textContent = e.target.value + '%';
echo   await window.api.saveData({volume:D.volume}^);
echo };
echo.
echo document.getElementById('btnAdd').onclick = async (^) =^> {
echo   const time = document.getElementById('inpTime').value;
echo   const label = document.getElementById('inpLabel').value.trim(^);
echo   const type = document.getElementById('inpType').value;
echo   const days = [...document.querySelectorAll('#daySel input:checked'^)].map(i =^> parseInt(i.value^)^);
echo   if (!time ^|^| !label ^|^| days.length === 0^) return alert('Lengkapi waktu, nama, dan hari!'^);
echo   const r = await window.api.addSchedule({time, label, type, days, enabled:true}^);
echo   D.schedules = r.data; renderSched(^);
echo   document.getElementById('inpLabel').value = '';
echo   log('➕ Jadwal: ' + label + ' (' + time + ')'^);
echo };
echo document.getElementById('btnExport').onclick = async (^) =^> {
echo   const r = await window.api.exportSchedules(^);
echo   if (r.ok^) { alert('✅ Export berhasil!'^); log('📤 Export jadwal'^); }
echo };
echo document.getElementById('btnImport').onclick = async (^) =^> {
echo   const r = await window.api.importSchedules(^);
echo   if (r.ok^) {
echo     const g = await window.api.getData(^); D.schedules = g.schedules;
echo     renderSched(^); alert('✅ Import ' + r.count + ' jadwal!'^); log('📥 Import ' + r.count + ' jadwal'^);
echo   } else if (r.error^) alert('❌ ' + r.error^);
echo };
echo.
echo document.getElementById('btnUploadSound').onclick = async (^) =^> {
echo   const r = await window.api.uploadSound(^);
echo   if (r.ok^) { alert('✅ Suara diupload!'^); checkSound(^); log('🔊 Upload suara'^); }
echo };
echo document.getElementById('btnRemoveSound').onclick = async (^) =^> {
echo   if (!confirm('Hapus suara custom?'^)^) return;
echo   await window.api.removeSound(^); alert('✅ Dihapus'^); checkSound(^);
echo };
echo.
echo document.getElementById('btnAddGuru').onclick = async (^) =^> {
echo   const nama = document.getElementById('guruNama').value.trim(^);
echo   const mapel = document.getElementById('guruMapel').value.trim(^);
echo   const phone = document.getElementById('guruPhone').value.trim(^);
echo   if (!nama ^|^| !phone^) return alert('Nama dan nomor wajib!'^);
echo   const r = await window.api.addGuru({nama, mapel, phone, aktif:true}^);
echo   D.guruList = r.data; renderGuru(^);
echo   document.getElementById('guruNama').value = '';
echo   document.getElementById('guruMapel').value = '';
echo   document.getElementById('guruPhone').value = '';
echo   log('👨‍🏫 Guru: ' + nama^);
echo };
echo document.getElementById('btnImportGuru').onclick = async (^) =^> {
echo   const r = await window.api.importGuru(^);
echo   if (r.ok^) { D.guruList = r.data; renderGuru(^); alert('✅ Import ' + r.count + ' guru'^); }
echo };
echo.
echo document.getElementById('btnWAConnect').onclick = async (^) =^> {
echo   await window.api.waConnect(^);
echo   log('💬 Menghubungkan WA...'^);
echo };
echo document.getElementById('btnWADisconnect').onclick = async (^) =^> {
echo   if (!confirm('Putuskan WhatsApp?'^)^) return;
echo   await window.api.waDisconnect(^); log('🔌 WA diputuskan'^);
echo };
echo document.getElementById('waEnabled').onchange = async (e^) =^> {
echo   D.waEnabled = e.target.checked;
echo   await window.api.saveData({waEnabled:D.waEnabled}^);
echo };
echo document.getElementById('waToTeacher').onchange = async (e^) =^> {
echo   D.waSendToTeacher = e.target.checked;
echo   await window.api.saveData({waSendToTeacher:D.waSendToTeacher}^);
echo };
echo document.getElementById('btnSaveTemplate').onclick = async (^) =^> {
echo   const t = document.getElementById('waTemplate').value;
echo   D.waTemplate = t;
echo   await window.api.saveData({waTemplate:t}^);
echo   alert('✅ Template disimpan'^);
echo };
echo document.getElementById('btnTestWA').onclick = async (^) =^> {
echo   const phone = document.getElementById('testPhone').value.trim(^);
echo   if (!phone^) return alert('Isi nomor!'^);
echo   const r = await window.api.waSendTest(phone, '🧪 Test dari Bel Sekolah'^);
echo   if (r.ok^) alert('✅ Terkirim!'^); else alert('❌ ' + r.error^);
echo };
echo document.getElementById('btnSaveTTS').onclick = async (^) =^> {
echo   D.ttsText = document.getElementById('ttsText').value;
echo   await window.api.saveData({ttsText:D.ttsText}^);
echo   alert('✅ TTS disimpan'^);
echo };
echo.
echo document.body.addEventListener('click', (^) =^> {
echo   if (!audioCtx^) audioCtx = new (window.AudioContext ^|^| window.webkitAudioContext^)(^);
echo }, {once:true}^);
echo.
echo init(^);
echo ^</script^>
echo ^</body^>
echo ^</html^>
) > src\index.html
echo   ✅ src/index.html dibuat

REM ═══════════════════ STEP 7: BUAT WORKFLOW ═══════════════════
echo.
echo   [7/10] 📝 Membuat .github/workflows/build.yml...
(
echo name: Build Bel Sekolah
echo.
echo on:
echo   push:
echo     tags: ['v*']
echo   workflow_dispatch:
echo.
echo permissions:
echo   contents: write
echo.
echo jobs:
echo   build:
echo     runs-on: windows-latest
echo     steps:
echo       - uses: actions/checkout@v4
echo       - uses: actions/setup-node@v4
echo         with:
echo           node-version: '20'
echo       - run: npm install
echo       - run: npm run build
echo         env:
echo           GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
echo       - uses: actions/upload-artifact@v4
echo         with:
echo           name: BelSekolah-Windows
echo           path: |
echo             dist/*.exe
echo             dist/*.blockmap
echo           retention-days: 30
echo       - if: startsWith(github.ref, 'refs/tags/v')
echo         uses: softprops/action-gh-release@v2
echo         with:
echo           name: Bel Sekolah ${{ github.ref_name }}
echo           draft: false
echo           prerelease: false
echo           files: |
echo             dist/*.exe
echo             dist/*.blockmap
echo           body: |
echo             ## 🔔 Bel Sekolah Elektron ${{ github.ref_name }}
echo             
echo             ### 📥 Download
echo             - BelSekolah-Setup-*.exe (installer)
echo             - BelSekolah-Portable-*.exe (portable)
echo             
echo             ### ✨ Fitur
echo             - Jadwal bel otomatis
echo             - Upload suara bel custom
echo             - Import/Export jadwal (JSON/CSV)
echo             - WhatsApp notif guru via Baileys
echo             - TTS Bahasa Indonesia
echo             
echo             ### 💻 Windows 10/11 (64-bit)
echo         env:
echo           GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
) > .github\workflows\build.yml
echo   ✅ build.yml dibuat

REM ═══════════════════ STEP 8: BUAT .gitignore ═══════════════════
echo.
echo   [8/10] 📝 Membuat .gitignore...
(
echo node_modules/
echo dist/
echo out/
echo *.log
echo .DS_Store
echo Thumbs.db
echo .env
echo wa-auth/
echo package-lock.json
) > .gitignore
echo   ✅ .gitignore dibuat

REM ═══════════════════ STEP 9: INSTALL DEPENDENCIES ═══════════════════
echo.
echo   [9/10] 📦 Install dependencies (butuh 2-5 menit)...
echo   ⏳ Sabar ya, sedang download electron + baileys...
echo.
call npm install
if %errorlevel% neq 0 (
    echo   ❌ npm install gagal!
    echo   Pastikan Node.js sudah terinstall: https://nodejs.org
    pause & exit /b 1
)
echo   ✅ Dependencies terinstall

REM ═══════════════════ STEP 10: GIT + PUSH + TAG ═══════════════════
echo.
echo   [10/10] 🚀 Git deploy...

git config --global user.name "%GIT_NAME%"
git config --global user.email "%GIT_EMAIL%"
git config --global credential.helper manager

if not exist .git (
    git init
    git branch -M main
    git remote add origin https://github.com/%GITHUB_USER%/%REPO_NAME%.git
)

git remote set-url origin https://github.com/%GITHUB_USER%/%REPO_NAME%.git
git add .
git commit -m "🔥 Hardcore deploy v%VERSION%" 2>nul

echo.
echo   ⚠️  Push akan minta login GitHub.
echo   Username : %GITHUB_USER%
echo   Password : GUNAKAN PERSONAL ACCESS TOKEN (bukan password akun!)
echo   Buat token: https://github.com/settings/tokens
echo.
pause

git push -f -u origin main
if %errorlevel% neq 0 (
    echo   ❌ Push gagal!
    pause & exit /b 1
)

git tag -d v%VERSION% 2>nul
git tag -a v%VERSION% -m "Release v%VERSION%"
git push -f origin v%VERSION%

echo.
echo   ╔══════════════════════════════════════════════════════╗
echo   ║   🎉 HARDCORE DEPLOY BERHASIL! 🎉                    ║
echo   ╚══════════════════════════════════════════════════════╝
echo.
echo   📊 Cek build:  https://github.com/%GITHUB_USER%/%REPO_NAME%/actions
echo   📦 Download:   https://github.com/%GITHUB_USER%/%REPO_NAME%/releases
echo.
echo   ⏱️  Tunggu 5-8 menit untuk build selesai.
echo.
pause

start https://github.com/%GITHUB_USER%/%REPO_NAME%/actions

echo.
echo   Selesai! Tekan Enter untuk keluar...
pause >nul