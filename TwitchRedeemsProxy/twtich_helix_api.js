const https = require('https');
const Requests = require('./https_requests.js');

let twitch_api = null;
let twitch_auth = null;

function open(client_id, client_secret, redirect_uri, scopes) {
  twitch_auth = new TwitchAuth(client_id, client_secret, redirect_uri, scopes)
  twitch_api = new TwitchHelixAPI(client_id, client_secret)
}

function close() {
  // TODO
}

class TwitchAuth {
  constructor(client_id, client_secret, redirect_uri, scopes) {
    // Authentication settings.
    this.client_id = client_id;
    this.client_secret = client_secret;
    this.redirect_uri = redirect_uri;
    this.scopes = scopes;

    // Will be set after successful authentication.
    this.access_token = null;
    this.refresh_token = null;
    this.user_id = null;
  }

  get_authentication_url(force_verify) {
    let url = "https://id.twitch.tv/oauth2/authorize";
    url += `?client_id=${this.client_id}`;
    url += `&redirect_uri=http://${this.redirect_uri}`;
    url += `&response_type=code`; //token`
    url += `&scope=${this.scopes.map(scope => encodeURIComponent(scope)).join('+')}`;
    url += `&force_verify=${force_verify}`;
    url += `&state=${"THIS-IS-A-TOTALLY-RANDOM-STRING"}`; // TODO xdd
    return url;
  }

  async get_access_token(auth_code) {
    let body = `client_id=${this.client_id}`;
    body += `&client_secret=${this.client_secret}`;
    body += `&code=${auth_code}`;
    body += `&grant_type=authorization_code`;
    body += `&redirect_uri=http://${this.redirect_uri}`;

    const options = {
      method: 'POST',
      hostname: 'id.twitch.tv',
      path: '/oauth2/token',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Content-Length': Buffer.byteLength(body),
      },
    };

    return Requests.requests(options, body);
  }

  async set_user_authentication() {
    const options = {
      method: 'GET',
      hostname: 'id.twitch.tv',
      path: '/oauth2/validate',
      headers: { 'Authorization': `OAuth ${this.access_token}` }
    };
    return Requests.requests(options)
  }
}

function get_authentication_url(force_verify) {
  if (!twitch_auth) {
    const criticalError = new Error('Twitch API has not been opened');
    throw criticalError;
  }
  return twitch_auth.get_authentication_url(force_verify)
}

function authenticate(auth_code) {
  twitch_auth.get_access_token(auth_code)
    .then((response) => {
      const data = JSON.parse(response.data);
      if (response.statusCode == 200) {
        console.log('Twitch authentication token acquired');

        // Set twitch authorization tokens.
        twitch_auth.access_token = data['access_token']
        twitch_auth.refresh_token = data['refresh_token']

        // Authenticate user.
        twitch_auth.set_user_authentication()
          .then((response) => {
            // Check response.
            const data = JSON.parse(response.data);
            if (response.statusCode == 200) {
              console.log('Twitch authentication complete');
              // Store user id for twitch api requests later.
              twitch_auth.user_id = data['user_id']
            }
            else {
              console.error(`Twitch authentication failed with status code ${response.statusCode}`);
            }
          })
          .catch((error) => {
            console.error(`Twitch Authentication error: '${error}'`);
          });

      }
      else {
        console.error(`Acquiring twitch authentication token failed with status code ${response.statusCode}`);
      }
    })
    .catch((error) => {
      console.error(`Error on acquiring twitch authentication token: '${error}'`);
    });
}

class TwitchHelixAPI {
  constructor(client_id, client_secret, redirect_uri) {
    this.client_id = client_id;
    this.client_secret = client_secret;
    this.redirect_uri = redirect_uri;
    this.url_helix_api = "api.twitch.tv"
  }

  async create_custom_reward(reward) {
    // https://dev.twitch.tv/docs/api/reference/#create-custom-rewards
    const body = JSON.stringify(reward);
    const options = {
      method: 'POST',
      hostname: this.url_helix_api,
      path: `/helix/channel_points/custom_rewards?broadcaster_id=${twitch_auth.user_id}`,
      headers: {
        'Authorization': `Bearer ${twitch_auth.access_token}`,
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(body),
        'Client-Id': `${this.client_id}`,
      }
    };
    return Requests.requests(options, body);
  }

  async update_custom_reward(custom_reward_id, redeem_update) {
    // https://dev.twitch.tv/docs/api/reference/#update-custom-reward
    const body = JSON.stringify(redeem_update);
    const options = {
      method: 'PATCH',
      hostname: this.url_helix_api,
      path: `/helix/channel_points/custom_rewards?broadcaster_id=${twitch_auth.user_id}&id=${custom_reward_id}`,
      headers: {
        'Authorization': `Bearer ${twitch_auth.access_token}`,
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(body),
        'Client-Id': `${this.client_id}`,
      }
    };
    return Requests.requests(options, body);
  }

  async delete_custom_reward(custom_reward_id) {
    // https://dev.twitch.tv/docs/api/reference/#delete-custom-reward
    const options = {
      method: 'DELETE',
      hostname: this.url_helix_api,
      path: `/helix/channel_points/custom_rewards?broadcaster_id=${twitch_auth.user_id}&id=${custom_reward_id}`,
      headers: {
        'Authorization': `Bearer ${twitch_auth.access_token}`,
        'Client-Id': `${this.client_id}`,
      }
    };
    return Requests.requests(options);
  }

  async get_custom_rewards() {
    // https://dev.twitch.tv/docs/api/reference/#get-custom-reward
    const options = {
      method: 'GET',
      hostname: this.url_helix_api,
      path: `/helix/channel_points/custom_rewards?broadcaster_id=${twitch_auth.user_id}`,
      headers: {
        'Authorization': `Bearer ${twitch_auth.access_token}`,
        'Client-Id': `${this.client_id}`,
      }
    };
    return Requests.requests(options);
  }
}


// TODO probably not wait for promise here
async function create_custom_reward(reward) {
  return twitch_api.create_custom_reward(reward);
  // return twitch_api.create_custom_reward(reward)
  //   .then((response) => {
  //     console.log("GOOD")
  //   })
  //   .catch((error) => {
  //     console.error(`Twitch Authentication error: '${error}'`);
  //   });
}

async function delete_custom_reward(custom_reward_id) {
  return twitch_api.delete_custom_reward(custom_reward_id);
  // return twitch_api.delete_custom_reward(custom_reward_id)
  //   .then((response) => {
  //     console.log("GOOD")
  //   })
  //   .catch((error) => {
  //     console.error(`Twitch Authentication error: '${error}'`);
  //   });
}

async function get_custom_rewards() {
  return twitch_api.get_custom_rewards();
}

async function update_custom_reward(custom_reward_id, redeem_update) {
  return twitch_api.update_custom_reward(custom_reward_id, redeem_update);
}

module.exports = {
  open,
  close,
  get_authentication_url,
  authenticate,
  create_custom_reward,
  update_custom_reward,
  delete_custom_reward,
  get_custom_rewards,
};