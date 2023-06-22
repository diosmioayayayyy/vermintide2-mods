const { ipcRenderer } = require('electron');

// Main window elements.
const content = document.getElementById('content');
const twitch_authentication_image = document.getElementById('twitch-authentication-image');
const twitch_eventsub_connection_image = document.getElementById('twitch-eventsub-connection-image');
const game_http_server_connection_image = document.getElementById('game-http-server-connection-image');

let current_content = "";
let twitch_auth_url = "";

// Load dynamic content.
function loadContent(page) {
  const url = `${page}.html`;
  current_content = page;
  fetch(url)
    .then(response => response.text())
    .then(html => {
      content.innerHTML = html;
    })
    .catch(error => {
      console.error(`Failed to load page: ${error}`);
    });
}

ipcRenderer.on('openTwitchAuth', (event, auth_url) => {
  twitch_auth_url = auth_url;
  loadContent('twitch_login');
});

ipcRenderer.on('openMain', (event) => {
  loadContent('main');
  delete_twitch_auth_webview();
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
          load_content_twitch_auth();
        }
        break;
      }
    case "main":
      {
        break;
      }
    default:
      {
        if (current_content != "") {
          console.error("Unkown content: ", current_content);
        }
      }
  }
});


// Title bar buttons.
document.getElementById("min-btn").addEventListener("click", function() {
  ipcRenderer.send('buttonWindowMinimizePressed');
});

document.getElementById("max-btn").addEventListener("click", function() {
  ipcRenderer.send('buttonWindowMaximizePressed');
});

document.getElementById("close-btn").addEventListener("click", function() {
  ipcRenderer.send('buttonWindowClosePressed');
});

// Start observing changes to the body
observer.observe(document.body, { childList: true, subtree: true });


// TODO move content stuff into sep js?
const webview_twitch_auth_id = "webview_twitch_auth";

function load_content_twitch_auth() {
  // Create a new WebView element
  const webview = document.createElement('webview');
  webview.id = webview_twitch_auth_id;

  // Set the src attribute dynamically.
  webview.src = twitch_auth_url;

  // Append the webview to the container element.
  const container = document.getElementById('webview-container');
  container.appendChild(webview);

  webview.addEventListener('dom-ready', () => {
    webview.addEventListener('will-navigate', (event) => {
      event.preventDefault(); // Does not work in webview...
      ipcRenderer.send('twitch-auth-redirect-url', event.url);
    });
  })
}

function delete_twitch_auth_webview() {
  const element = document.getElementById(webview_twitch_auth_id);
  if (element != null) {
    console.log("Removing twitch auth webview");
    element.remove();
  }
}


// Console test stuff
const console_messages = [["",""]];
let console_messages_index = 0;

function push_console_message(severity, message) {
  const consoleElement = document.getElementById('console');
  if (consoleElement) {
    const logEntry = document.createElement('div');

    switch (severity) {
      case "info":    logEntry.className = "console-message info"; break;
      case "warning": logEntry.className = "console-message warning"; break;
      case "error":   logEntry.className = "console-message error"; break;
      case "log":     logEntry.className = "console-message log"; break;
      default: console.error("Unknown severity: ", severity);
    }
  
    logEntry.textContent = message;
    consoleElement.appendChild(logEntry);
    consoleElement.scrollTop = consoleElement.scrollHeight; // Auto-scroll to the bottom
  }
}

function add_console_message(severity, text) {
  console_messages.push([severity, text]);

  // Push new console messages into container.
  for (let index = console_messages_index; index < console_messages.length; index++) {
    if (console_messages_index < index) {
      const [severity, text] = console_messages[index];
      push_console_message(severity, text);
      console_messages_index = index;
    }
  }
}

ipcRenderer.on('logToConsole', (event, severity, text) => {
  add_console_message(severity, text);
});
