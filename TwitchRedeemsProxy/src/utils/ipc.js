const { ipcMain } = require('electron');

function setTwitchAuthenticationState(is_connected) {
  global.main_window.webContents.send('setTwitchAuthenticationState', is_connected);
}

function setTwitchEventSubConnectionState(is_connected) {
  global.main_window.webContents.send('setTwitchEventSubConnectionState', is_connected);
}

function setGameHttpProxyServerConnectionState(is_connected) {
  global.main_window.webContents.send('setGameHttpProxyServerConnectionState', is_connected);
}

function registerTitleButtonActions(app) {
  ipcMain.on("buttonWindowClosePressed", (event) => {
    if (global.main_window) {
      app.quit();
    }
  });
  
  ipcMain.on("buttonWindowMaximizePressed", (event) => {
    if (global.main_window) {
      global.main_window.maximize();
    }
  });
  
  ipcMain.on("buttonWindowMinimizePressed", (event) => {
    if (global.main_window) {
      global.main_window.minimize();
    }
  });
}

module.exports = {
  setTwitchAuthenticationState,
  setTwitchEventSubConnectionState,
  setGameHttpProxyServerConnectionState,
  registerTitleButtonActions,
};
