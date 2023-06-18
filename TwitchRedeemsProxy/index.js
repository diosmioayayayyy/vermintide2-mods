const { app, BrowserWindow, ipcMain } = require('electron');
const handlebars = require('handlebars');
const fs = require('fs');
const path = require('path');

const TwitchRedeemsHTTPProxy = require('./twitch_redeems_http_proxy.js');
const TwitchHelixAPI = require('./twitch_helix_api.js');
const TwitchEventSub = require('./twitch_even_sub.js');

let main_window;
let web_view;

function createWindow() {
  var main_window = new BrowserWindow({
    width: 800,
    height: 600,
    minWidth: 300,
    minHeight: 300,
    icon: 'twitch_redeems.png',
    frame: false, // Remove title bar
    titleBarStyle: 'customButtonsOnHover',
    backgroundColor: '#000000',
    center: true,
    closable: true,
    skipTaskbar: false,
    resize: true,
    maximizable: true,
    webPreferences: {
      nodeIntegration : true,
      webviewTag: true,
      enableRemoteModule: true,
      contextIsolation: false,
    },
  });
  global.main_window = main_window;

  // Setup Twitch Authentication.
  const client_id     = "zuknbow10f0m5b0rqosg0gpba6tg41"
  const client_secret = "b2zy7kqjs0h1yn3yzt5ywqnk7fvw6j"
  const redirectUri   = "localhost:17563"
  const scopes        = ["channel:manage:redemptions", "channel:read:redemptions"]

  // Open twitch helix api and get auhtorization url.
  TwitchHelixAPI.open(client_id, client_secret, redirectUri, scopes)
  const auth_url = TwitchHelixAPI.get_authentication_url(true)

  {
    // Handlebars
    const index_path = path.join(__dirname, 'index.hbs');
    const css_file_path = path.join(__dirname, 'partials', 'default.css.hbs');
    const title_path = path.join(__dirname, 'partials', 'title.hbs');
    const bottom_path = path.join(__dirname, 'partials', 'bottom.hbs');
  
    const index_template = fs.readFileSync(index_path, 'utf8');
    const css_partial = fs.readFileSync(css_file_path, 'utf8');
    const title_partial = fs.readFileSync(title_path, 'utf8');
    const bottom_partial = fs.readFileSync(bottom_path, 'utf8');

    // Register the partial with Handlebars
    handlebars.registerPartial('css', css_partial);
    handlebars.registerPartial('title', title_partial);
    handlebars.registerPartial('bottom', bottom_partial);

    // Render the template with data
    var compiledTemplate = handlebars.compile(index_template);
  }

  const html = compiledTemplate({});

  // Authenticate.Options Page
  //main_window.loadURL(auth_url); // TODO
  main_window.loadFile('index.html'); // TODO
  //main_window.loadURL(`data:text/html;charset=utf-8,${encodeURIComponent(html)}`);

  // Catch redirect uri from twitch 
  main_window.webContents.on('will-navigate', function (event, newUrl) {
    const parsedUrl = new URL(newUrl);
    host = parsedUrl.host

    if (parsedUrl.host == redirectUri) {
      const queryParams = parsedUrl.searchParams;
      const auth_code = queryParams.get('code');

      if (auth_code) {
        // Start twitch authorization.
        connectToTwitch(auth_code);
        event.preventDefault();

        // Load app gui.
        //main_window.loadFile('index.html'); // TODO
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
  main_window.webContents.on('did-finish-load', () => {
    main_window.show();
    main_window.focus();
    TwitchRedeemsHTTPProxy.startHTTPProxyServer();
  });

  main_window.on('closed', function () {
    main_window = null;
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
