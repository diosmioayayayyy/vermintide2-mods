const webview_twitch_auth_id = "webview_twitch_auth";

ipcRenderer.on('openTwitchAuth', (event, auth_url) => {
  twitch_auth_url = auth_url;
  loadContent(content, 'twitch_login');
});

function load_content() {
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

function delete_webview() {
  const element = document.getElementById(webview_twitch_auth_id);
  if (element != null) {
    console.log("Removing twitch auth webview");
    element.remove();
  }
}

module.exports = {
  load_content,
  delete_webview,
};
