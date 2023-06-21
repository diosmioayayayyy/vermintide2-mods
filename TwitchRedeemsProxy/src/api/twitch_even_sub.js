const WebSocket = require('ws');
const Requests = require('../utils/https_requests.js');
const TwitchHelixAPI = require('./twitch_helix_api.js');
const ipc = require('../utils/ipc.js');
require('../utils/utils.js');

const url = "wss://eventsub.wss.twitch.tv/ws"
let twitch_event_sub_api = null;

class TwitchEventSubAPI {
  constructor(events, event_callback) {
    this.events = events;
    this.event_callback = event_callback;
    this.ws = null
    this.session_id = null;
    this.timeout_id = null;
  }

  start_timeout() {
    this.timeout_id = setTimeout(() => {
      // After 10s twitch eventsub will close connection if no message has been sent.
      console.error("Twitch EventSub connection has timed out. Trying to reconnect...")

      // Try to reconnect.
      this.close()
      this.connect()
    }, 15000);
  }

  reset_timer() {
    console.log("Eventsub keep-alive message received")
    clearTimeout(this.timeout_id)
    this.start_timeout()
  }

  async on_receive_welcome_message(data) {
    this.session_id = data.payload.session.id
    this.start_timeout()

    var responses = [];

    // Subscribe to events.
    for (const event of this.events) {
      responses.push(await twitch_event_sub_api.subscribe(event));
    }

    const success_code = 202;
    const status_code = check_response_status_codes(responses, success_code);
    if (status_code != success_code) {
      const criticalError = new Error(`Subscribing to events failed with status code ${status_code}`);
      throw criticalError;
    }
    else {
      ipc.setTwitchEventSubConnectionState(true);
      console.log("Subscribed to events")
    }
  }

  on_event_received(data){
    console.log(`Event received: ${data.metadata.subscription_type}`)
    this.event_callback(data);
  }

  on_recive_message(data) {
    const message_type = data.metadata.message_type
    if (message_type == "session_welcome") {
      this.on_receive_welcome_message(data);
    }
    else if (message_type == "session_keepalive") {
      // Just reset timeout timer.
      this.reset_timer();
    }
    else if (message_type == "notification") {
      this.reset_timer();
      this.on_event_received(data);
    }
    else {
      console.error(`Received unknown Twitch EventSub message '${message_type}'`);
    }
  }

  connect() {
    this.ws = new WebSocket(url);

    this.ws.on('open', () => {
      console.log('Twitch EventSub websocket connection established');
    });
    
    this.ws.on('message', async (msg) => {
      try {
        this.on_recive_message(JSON.parse(msg))
      } catch (error) {
        console.error('Error parsing message:', error);
      }
    });
    
    this.ws.on('close', () => {
      console.log('Twitch EventSub websocket closed');
      ipc.setTwitchEventSubConnectionState(false);
      // TODO handle when closed, but game is still running.
    });
  }

  async subscribe(event) {
    const [broadcaster_id, client_id, access_token] = TwitchHelixAPI.getAuthData();

    const body = JSON.stringify({
      'type': event,
      'version': '1',
      'condition': {'broadcaster_user_id': broadcaster_id },
      'transport': {'method': 'websocket', 'session_id': this.session_id }
    });

    const options = {
      method: 'POST',
      hostname: 'api.twitch.tv',
      path: '/helix/eventsub/subscriptions',
      headers: {
        'Authorization': `Bearer ${access_token}`,
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(body),
        'Client-Id': `${client_id}`,
      }
    };
    '{"type":"channel.channel_points_custom_reward_redemption.add","version":"1","condition":{"broadcaster_user_id":"162349768"},"transport":{"method":"websocket"},"session_id":"AgoQOcnjLTjDT3SdcviRarp3zRIGY2VsbC1j"}'
    return Requests.requests(options, body);
  }

  close() {
    this.ws.close()
  }
};

async function openEventSubWebsocket(events, event_callback) {
  twitch_event_sub_api = new TwitchEventSubAPI(events, event_callback)
  twitch_event_sub_api.connect()
}

async function closeEventSubWebsocket() {
  twitch_event_sub_api.close()
}

async function subscribeToEvent(client_id, broadcaster_id, auth_token, event) {
  return twitch_event_sub_api.subscribe(client_id, broadcaster_id, auth_token)
}

module.exports = {
  openEventSubWebsocket,
  closeEventSubWebsocket,
  subscribeToEvent,
};