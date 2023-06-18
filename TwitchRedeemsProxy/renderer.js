const { ipcRenderer } = require('electron');

const twitch_authentication_image = document.getElementById('twitch-authentication-image');
const twitch_eventsub_connection_image = document.getElementById('twitch-eventsub-connection-image');
const game_http_server_connection_image = document.getElementById('game-http-server-connection-image');

ipcRenderer.on('setTwitchAuthenticationState', (event, is_connected) => {
  const image_src = is_connected ? 'images/locked.png' : 'images/unlocked.png';
  const alt_text = is_connected ? 'authenticated' : 'not authenticated';
  twitch_authentication_image.src = image_src
  twitch_authentication_image.alt = alt_text
});

ipcRenderer.on('setTwitchEventSubConnectionState', (event, is_connected) => {
  const image_src = is_connected ? 'images/connected.png' : 'images/disconnected.png';
  const alt_text = is_connected ? 'connected' : 'disconnected';
  twitch_eventsub_connection_image.src = image_src
  twitch_eventsub_connection_image.alt = alt_text
});

ipcRenderer.on('setGameHttpProxyServerConnectionState', (event, is_connected) => {
  const image_src = is_connected ? 'images/connected.png' : 'images/disconnected.png';
  const alt_text = is_connected ? 'connected' : 'disconnected';
  game_http_server_connection_image.src = image_src
  game_http_server_connection_image.alt = alt_text
});
