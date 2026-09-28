const { app, BrowserWindow, Menu, globalShortcut } = require('electron');
const path = require('path');
const fs = require('fs');

let mainWindow;

// Data file path
const DATA_FILE = path.join(app.getPath('userData'), 'bel-sekolah-data.json');

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1400,
    height: 900,
    minWidth: 1000,
    minHeight: 700,
    title: 'Bel Sekolah Elektron',
    backgroundColor: '#0f172a',
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      contextIsolation: true,
      nodeIntegration: false
    },
    autoHideMenuBar: true
  });

  mainWindow.loadFile(path.join(__dirname, 'index.html'));

  mainWindow.on('closed', () => { mainWindow = null; });
}

function createMenu() {
  Menu.setApplicationMenu(Menu.buildFromTemplate([
    {
      label: 'File',
      submenu: [
        { label: 'Reload', accelerator: 'Ctrl+R', click: () => mainWindow.reload() },
        { label: 'Fullscreen', accelerator: 'F11', click: () => mainWindow.setFullScreen(!mainWindow.isFullScreen()) },
        { type: 'separator' },
        { label: 'Keluar', accelerator: 'Ctrl+Q', click: () => app.quit() }
      ]
    },
    {
      label: 'Bantuan',
      submenu: [
        {
          label: 'Tentang',
          click: () => {
            const { dialog } = require('electron');
            dialog.showMessageBox(mainWindow, {
              type: 'info',
              title: 'Tentang',
              message: 'Bel Sekolah Elektron v' + app.getVersion(),
              detail: 'Aplikasi bel sekolah dengan jadwal otomatis, TTS, dan suara custom.'
            });
          }
        }
      ]
    }
  ]));
}

app.whenReady().then(() => {
  createWindow();
  createMenu();
  
  // Prevent sleep agar bel tetap bunyi
  const { powerSaveBlocker } = require('electron');
  powerSaveBlocker.start('prevent-display-sleep');

  // Fullscreen shortcut
  globalShortcut.register('F11', () => {
    if (mainWindow) mainWindow.setFullScreen(!mainWindow.isFullScreen());
  });
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') app.quit();
});

app.on('activate', () => {
  if (BrowserWindow.getAllWindows().length === 0) createWindow();
});

app.on('will-quit', () => {
  globalShortcut.unregisterAll();
});