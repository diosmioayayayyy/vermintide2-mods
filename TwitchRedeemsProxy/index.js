const { app, BrowserWindow } = require('electron');

const TwitchRedeemsHTTPProxy = require('./twitch_redeems_http_proxy.js');
const TwitchHelixAPI = require('./twitch_helix_api.js');
const TwitchEventSub = require('./twitch_even_sub.js');

function createWindow() {
  var authWindow = new BrowserWindow({
    width: 800,
    height: 600,
    show: false,
    'node-integration': false,
    'web-security': false
  });

  // Setup Twitch Authentication.
  const client_id = "zuknbow10f0m5b0rqosg0gpba6tg41"
  const client_secret = "b2zy7kqjs0h1yn3yzt5ywqnk7fvw6j"
  const redirectUri = "localhost:17563"
  const scopes = ["channel:manage:redemptions", "channel:read:redemptions"]

  // Open twitch helix api and get auhtorization url.
  TwitchHelixAPI.open(client_id, client_secret, redirectUri, scopes)
  const auth_url = TwitchHelixAPI.get_authentication_url(true)

  // Authenticate.
  authWindow.loadURL(auth_url);
  authWindow.show();

  // Catch redirect uri from twitch 
  authWindow.webContents.on('will-navigate', function (event, newUrl) {
    const parsedUrl = new URL(newUrl);
    host = parsedUrl.host

    if (parsedUrl.host == redirectUri) {
      const queryParams = parsedUrl.searchParams;
      const auth_code = queryParams.get('code');

      if (auth_code) {
        // Start twitch authorization.
        connectToTwitch(auth_code);
        event.preventDefault();
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

  authWindow.on('closed', function () {
    authWindow = null;
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
    }
    catch (error) { console.error(`Twitch EventSub: '${error}'`); }
  }
  catch (error) { console.error(`Twitch authentication: '${error}'`); }
}

app.on('ready', function () {
  createWindow();
  TwitchRedeemsHTTPProxy.startHTTPProxyServer();
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

// TODO font: Caslon Antique
