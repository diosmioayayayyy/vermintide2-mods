const { app, BrowserWindow, ipcMain, protocol } = require('electron');
const path = require('path');

require('./utils/logging.js');
const ipc = require('./utils/ipc.js');
const TwitchRedeemsHTTPProxy = require('./api/twitch_redeems_http_proxy.js');
const TwitchHelixAPI = require('./api/twitch_helix_api.js');
const TwitchEventSub = require('./api/twitch_even_sub.js');

function createWindow() {
  global.main_window = new BrowserWindow({
    width: 800,
    height: 600,
    minWidth: 300,
    minHeight: 300,
    icon: 'twitch_redeems.png',
    frame: false,
    titleBarStyle: 'customButtonsOnHover',
    backgroundColor: '#000000',
    center: true,
    closable: true,
    skipTaskbar: false,
    resize: true,
    maximizable: true,
    webPreferences: {
      nodeIntegration : true,
      webSecurity: true,
      webviewTag: true,
      enableRemoteModule: true,
      contextIsolation: false,
    },
  });

  // Setup Twitch Authentication.
  const client_id     = "zuknbow10f0m5b0rqosg0gpba6tg41"
  const client_secret = "b2zy7kqjs0h1yn3yzt5ywqnk7fvw6j"
  const redirectUri   = "localhost:17563"
  const scopes        = ["channel:manage:redemptions", "channel:read:redemptions"]

  // Open twitch helix api and get auhtorization url.
  TwitchHelixAPI.open(client_id, client_secret, redirectUri, scopes)
  const auth_url = TwitchHelixAPI.get_authentication_url(true);

  // Open index page.
  global.main_window.loadFile('content/index.html');

  ipcMain.on('twitch-auth-redirect-url', (event, redirect_url) => {
    // Parse redirect uri from twitch authentication procedure.
    const parsedUrl = new URL(redirect_url);
    if (!global.twitch_auth_redirected && parsedUrl.host == redirectUri) {
      global.twitch_auth_redirected = true; // This happens two times for whatever reason, just execute it once.
      const queryParams = parsedUrl.searchParams;
      const auth_code = queryParams.get('code');

      if (auth_code) {
        // Start twitch authorization.
        connectToTwitch(auth_code);

        // Load main content after successful authentication.
        global.main_window.webContents.send('openMain');
      }
      else {
        // Shut down app.
        const error = queryParams.get('error');
        if (error) {
          console.error(`Shutting down: ${error}`)
        }
        app.quit();
      }
    }
  });

  // Wait for the window to be ready
  global.main_window.webContents.on('did-finish-load', () => {
    main_window.show();
    main_window.focus();
    global.main_window.webContents.send('openTwitchAuth', auth_url);
  });

  global.main_window.on('closed', function () {
    global.main_window = null;
  });
}

async function connectToTwitch(auth_code) {
  try {
    // Twitch authentication.
    await TwitchHelixAPI.authenticate(auth_code);
    try {
      // Open EventSub websocket connection.
      const events = ['channel.channel_points_custom_reward_redemption.add']
      await TwitchEventSub.openEventSubWebsocket(events, cb);

      const port = 8000;
      TwitchRedeemsHTTPProxy.startHTTPProxyServer(port);
    }
    catch (error) { console.error(`Twitch EventSub: '${error}'`); }
  }
  catch (error) { console.error(`Twitch authentication: '${error}'`); }
}

app.on('ready', function () {
  createWindow();
  ipc.registerTitleButtonActions(app);
});

app.on('before-quit', async () => {
  await TwitchHelixAPI.revoke_authentication();
  await TwitchHelixAPI.close();
  await TwitchRedeemsHTTPProxy.closeHTTPProxyServer();
  console.log('Server is gracefully closed.');
});

function cb(data) {
  // TODO this is the event callback
  console.log(data.payload.event.reward.title)
}
