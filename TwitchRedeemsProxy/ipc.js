
function setTwitchAuthenticationState(is_connected) {
  global.main_window.webContents.send('setTwitchAuthenticationState', is_connected);
}

function setTwitchEventSubConnectionState(is_connected) {
  global.main_window.webContents.send('setTwitchEventSubConnectionState', is_connected);
}

function setGameHttpProxyServerConnectionState(is_connected) {
  global.main_window.webContents.send('setGameHttpProxyServerConnectionState', is_connected);
}

module.exports = {
  setTwitchAuthenticationState,
  setTwitchEventSubConnectionState,
  setGameHttpProxyServerConnectionState,
};
