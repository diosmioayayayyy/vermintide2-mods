const { app, BrowserWindow } = require('electron');

const https = require('https');

const TwitchRedeemsHTTPProxy = require('./twitch_redeems_http_proxy.js');
const TwitchHelixAPI = require('./twtich_helix_api.js');
const Requests = require('./https_requests.js');


global.test = 123

function makeHttpRequest(options) {
  return new Promise((resolve, reject) => {
    const req = https.request(options, (res) => {
      let responseData = '';

      res.on('data', (chunk) => {
        responseData += chunk;
      });

      res.on('end', () => {
        resolve({
          statusCode: res.statusCode,
          data: responseData
        });
      });
    });

    req.on('error', (error) => {
      reject(error);
    });

    req.end();
  });
}

async function set_user_authentication(access_token) {
  const options = {
    method: 'GET',
    hostname: 'id.twitch.tv',
    path: '/oauth2/validate',
    headers: {
      'Authorization': `OAuth ${access_token}`
    },
  };

  return Requests.requests(options)
}

function createWindow() {
  var authWindow = new BrowserWindow({
    width: 800,
    height: 600,
    show: false,
    'node-integration': false,
    'web-security': false
  });

  //const authUrl = "https://id.twitch.tv/oauth2/authorize?client_id=zuknbow10f0m5b0rqosg0gpba6tg41&redirect_uri=http://localhost:17563&response_type=token&scope=channel%3Amanage%3Aredemptions%20channel%3Aread%3Aredemptions&force_verify=true&state=fbec947f-c828-4470-a57a-14b3f916c61f"

  // Setup Twitch Authentication.
  const client_id = "zuknbow10f0m5b0rqosg0gpba6tg41"
  const client_secret = "b2zy7kqjs0h1yn3yzt5ywqnk7fvw6j"
  const redirectUri = "localhost:17563"
  const scopes = ["channel:manage:redemptions", "channel:read:redemptions"]

  TwitchHelixAPI.open(client_id, client_secret, redirectUri, scopes)
  const auth_url = TwitchHelixAPI.get_authentication_url(true)

  // Authenticate.
  authWindow.loadURL(auth_url);
  authWindow.show();

  // const twitch_auth = new TwitchHelixAPI.TwitchAuth(client_id, client_secret, redirectUri, scopes)
  // const auth_url = twitch_auth.get_authentication_url(true)

  // Create Twitch Helix API
  //const twitch_api = new TwitchHelixAPI.TwitchHelixAPI(client_id, client_secret) // TODO DEL

  // Create HTTP proxer server for game instance.
  TwitchRedeemsHTTPProxy.startHTTPProxyServer(); // TODO MOVE

  // Catch redirect uri from twitch 
  authWindow.webContents.on('will-navigate', function (event, newUrl) {
    const parsedUrl = new URL(newUrl);
    host = parsedUrl.host

    if (parsedUrl.host == redirectUri) {

      // Get authorization code from query parameters
      const queryParams = parsedUrl.searchParams;
      const auth_code = queryParams.get('code');

      // TODO not needed anymore ig
      // // Get the fragment identifier
      // const fragment = parsedUrl.hash;

      // // Remove the leading "#" character from the fragment
      // const fragmentWithoutHash = fragment.substring(1);

      // // Parse the fragment string into an object of parameters
      // const params = {};
      // fragmentWithoutHash.split('&').forEach((param) => {
      //   const [key, value] = param.split('=');
      //   params[key] = value;
      // });

      //// Start twitch user authentication.
      //const access_token = params['access_token'];

      TwitchHelixAPI.authenticate(auth_code)
    // twitch_auth.get_access_token(auth_code)
      //   .then((response) => {
      //     const data = JSON.parse(response.data);
      //     if (response.statusCode == 200) {
      //       console.log('Twitch authentication token acquired');
      //       // Set twitch authorization tokens.
      //       twitch_auth.access_token = data['access_token']
      //       twitch_auth.refresh_token = data['refresh_token']

      //       // Authenticate user.
      //       twitch_auth.set_user_authentication()
      //         .then((response) => {
      //           const data = JSON.parse(response.data);
      //           if (response.statusCode == 200) {
      //             console.log('Twitch authentication complete');
      //             // Store user id for twitch api requests later.
      //             twitch_auth.user_id = data['user_id']
      //           }
      //           else {
      //             console.error(`Twitch authentication failed with status code ${response.statusCode}`);
      //           }
      //         })
      //         .catch((error) => {
      //           console.error(`Twitch Authentication error: '${error}'`);
      //         });

      //     }
      //     else {
      //       console.error(`Acquiring twitch authentication token failed with status code ${response.statusCode}`);
      //     }
      //   })
      //   .catch((error) => {
      //     console.error(`Error on acquiring twitch authentication token: '${error}'`);
      //   });
  

      event.preventDefault();
    }

  });

  authWindow.on('closed', function () {
    authWindow = null;
  });
}

app.on('ready', function () {
  createWindow();
});

app.on('before-quit', async () => {
  TwitchHelixAPI.close();
  await TwitchRedeemsHTTPProxy.closeHTTPProxyServer();
  console.log('Server is gracefully closed.');
});

// app.whenReady().then(createWindow);
