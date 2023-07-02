const { ipcRenderer } = require('electron');
const Controls = require('../src/renderer/controls.js');
const Console = require('../src/renderer/console.js');
const Settings = require('../src/renderer/settings.js');
const TwitchAuth = require('../src/renderer/twitch_auth.js');

// Main window elements.
const menu = document.getElementById('menu');
const content = document.getElementById('content');
const twitch_authentication_image = document.getElementById('twitch-authentication-image');
const twitch_eventsub_connection_image = document.getElementById('twitch-eventsub-connection-image');
const game_http_server_connection_image = document.getElementById('game-http-server-connection-image');

let current_content = "";
let twitch_auth_url = "";
let content_changed = false;

// Load dynamic content.
function loadContent(div_element, page) {
  const url = `${page}.html`;
  current_content = page;
  content_changed = true;
  fetch(url)
    .then(response => response.text())
    .then(html => {
      div_element.innerHTML = html;
    })
    .catch(error => {
      console.error(`Failed to load page: ${error}`);
    });
}

function load_menu() {
  loadContent(menu, "menu");
}

function changeContent(page) {
  loadContent(content, page);
}


ipcRenderer.on('openMain', (event) => {
  loadContent(content, 'main');
  load_menu(); // TODO naming conventions.... xdd
  TwitchAuth.delete_webview();
});

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

// Observe if dynamic content changes.
const observer = new MutationObserver(function (mutationsList, observer) {
  switch (current_content) {
    case "twitch_login":
      {
        const element = document.getElementById("webview_twitch_auth");
        if (element == null) {
          TwitchAuth.load_content();
        }
        break;
      }
    case "main":
      {
        break;
      }
    case "menu":
      {
        break;
      }
    case "controls":
      {
        break;
      }
    case "console":
      {
        if (content_changed) {
          Console.reset_console_message_index();
          Console.print_console_messages();
        }
        break;
      }
    case "settings":
      {
        if (content_changed) {
          Settings.create_event_listeners();
          Settings.request_settings();
        }
        break;
      }
    default:
      {
        if (current_content != "") {
          console.error("Unkown content: ", current_content);
        }
      }
  }
  content_changed = false;
});


// Title bar buttons.
document.getElementById("min-btn").addEventListener("click", function () {
  ipcRenderer.send('buttonWindowMinimizePressed');
});

document.getElementById("max-btn").addEventListener("click", function () {
  ipcRenderer.send('buttonWindowMaximizePressed');
});

document.getElementById("close-btn").addEventListener("click", function () {
  ipcRenderer.send('buttonWindowClosePressed');
});

// Start observing changes to the body
observer.observe(document.body, { childList: true, subtree: true });

// TODO move stuff in files.
