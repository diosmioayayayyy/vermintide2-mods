const http = require('http');
const ipc = require('../utils/ipc.js');
const { ipcMain } = require('electron');
require('../utils/utils.js')
const TwitchHelixAPI = require('./twitch_helix_api.js');
const { redeem_queue } = require('../redeem_queue.js');
const { unpauseRedeems } = require('../renderer/controls.js');

let server;
global.twitch_redeems = {};
global.twitch_redeems_settings = {};
global.settings = {
  redeem_idle_time: 30,
  queue_redeem_after_idle_time: false,
};

const TWITCH_REDEEM_REWARD_TOKEN = "[Twitch Redeem]";

function logResponseError(func, response, msg = "") {
  const response_body = JSON.parse(response.data);
  if (msg) msg = "- " + msg
  console.error(`Twitch Helix API response '${func.name}' failed with status code ${response.statusCode} - '${response_body['message']}' ${msg}`);
}

function logRequestError(func, error) {
  console.error(`Twitch Helix API request error in '${func.name}': '${error}'`);
}

function logRequestUrlError(request_type, url) {
  console.error(`Unkown url '${url}' for request type '${request_type}'`);
}

function logHandleRequestError(request_type, error) {
  console.error(`Handling '${request_type}' request : '${error}'`);
}

async function get_twitch_redeems() {
  var redeems = null;
  try {
    // Get channel redeems.
    const response = await TwitchHelixAPI.get_custom_rewards();
    if (response.statusCode == 200) {
      // Iterate over redeems and only process the ones which are marked as twitch redeems.
      const response_body = JSON.parse(response.data);

      // Only add redeems from mod.
      redeems = {}
      for (const redeem of response_body['data']) {
        if (redeem.prompt.includes(TWITCH_REDEEM_REWARD_TOKEN)) {
          redeems[redeem.title] = redeem;
        }
      }
    }
    else {
      logResponseError(get_twitch_redeems, response, "Error requesting redeems from Twitch");
    }
  }
  catch (error) { logRequestError(update_redeems, error); }

  // TODO compute PDFs for bad or bad/good redeems.

  // Compute probability to be picked during idle queuing.
  var sum_costs = 0;
  for (const [_, redeem] of Object.entries(redeems)) {
    var additional_setings = global.twitch_redeems_settings[redeem.title];
    if (additional_setings && additional_setings.allow_auto_queue) {
      sum_costs += 1 / redeem.cost
    }
  }

  // Compute CDF for picking random redeems proportional to their cost.
  var cdf = 0;
  for (const [redeem_key, redeem] of Object.entries(redeems)) {
    redeem.auto_queue = false;

    var additional_setings = global.twitch_redeems_settings[redeem.title];
    if (additional_setings) {
      redeem.auto_queue = additional_setings.allow_auto_queue;
    }

    if (redeem.auto_queue) {
      var p = ( 1 / redeem.cost) / sum_costs;
      redeem.probability = p;
      cdf += p;
      redeem.cdf = cdf;
    }
    else{
      redeem.probability = 0;
      redeem.cdf = 0;
    }
  }

  return redeems;
}

async function pause_redeems(paused) {
  for (var key in  twitch_redeems) {
    const redeem = twitch_redeems[key];
    if (redeem.prompt.includes(TWITCH_REDEEM_REWARD_TOKEN)) {
      await TwitchHelixAPI.pause_custom_reward(redeem.id, paused);
    }
  }
}

async function enable_redeems(enabled) {
  for (var key in  twitch_redeems) {
    const redeem = twitch_redeems[key];
    if (redeem.prompt.includes(TWITCH_REDEEM_REWARD_TOKEN)) {
      await TwitchHelixAPI.enable_custom_reward(redeem.id, enabled);
    }
  }
}

async function create_redeems(body) {
  var responses = [];
  // Iterate over redeems to create.
  const redeems = JSON.parse(body);
  for (let redeem of redeems) {
    if ('prompt' in redeem) {
      redeem['prompt'] += ` ${TWITCH_REDEEM_REWARD_TOKEN}`;
    }
    else {
      redeem['prompt'] = TWITCH_REDEEM_REWARD_TOKEN;
    }

    if ('additional_setings' in redeem) {
      global.twitch_redeems_settings[redeem.title] = redeem['additional_setings'];
    }

    try {
      // Create redeems.
      const response = await TwitchHelixAPI.create_custom_reward(redeem)
      if (response.statusCode == 200) {
        console.log(`Created redeem '${redeem.title}'`);
      }
      else {
        logResponseError(create_redeems, response, redeem.title); // TODO still a lot of dup code, can we handle that in HelixAPI file?
      }
      responses.push(response);
    }
    catch (error) {
      logRequestError(create_redeems, error);
    }
  }
  return responses;
}

async function update_redeems(body) {
  var responses = [];
  try {
    const redeem_update = JSON.parse(body);
    // Get channel redeems.
    const response = await TwitchHelixAPI.get_custom_rewards();
    if (response.statusCode == 200) {
      async function process(redeem) {
        try {
          // Delete twitch redeem.
          const response = await TwitchHelixAPI.update_custom_reward(redeem.id, redeem_update);
          if (response.statusCode == 200) {
            console.log(`Updated redeem '${redeem.title}'`);
          }
          else {
            logResponseError(update_redeems, response); // TODO still a lot of dup code, can we handle that in HelixAPI file?
          }
          responses.push(response);
        }
        catch (error) {
          logRequestError(update_redeems, error);
        }
      }
      // Iterate over redeems and only process the ones which are marked as twitch redeems.
      const response_body = JSON.parse(response.data);
      for (const redeem of response_body['data']) {
        if (redeem.prompt.includes(TWITCH_REDEEM_REWARD_TOKEN)) {
          await process(redeem);
        }
      }
    }
  }
  catch (error) { logRequestError(update_redeems, error); }
  return responses;
}

async function delete_redeems() {
  var responses = [];
  try {
    // Get channel redeems.
    const response = await TwitchHelixAPI.get_custom_rewards();
    if (response.statusCode == 200) {
      async function process(redeem) {
        try {
          // Delete twitch redeem.
          const response = await TwitchHelixAPI.delete_custom_reward(redeem.id);
          if (response.statusCode == 204) {
            console.log(`Deleted redeem '${redeem.title}'`);
          }
          else {
            logResponseError(delete_redeems, response); // TODO still a lot of dup code, can we handle that in HelixAPI file?
          }
          responses.push(response);
        }
        catch (error) {
          logRequestError(delete_redeems, error);
        }
      }
      // Iterate over redeems and only process the ones which are marked as twitch redeems.
      const response_body = JSON.parse(response.data);
      for (const redeem of response_body['data']) {
        if (redeem.prompt.includes(TWITCH_REDEEM_REWARD_TOKEN)) {
          await process(redeem);
        }
      }
      global.twitch_redeems = []
    }
  }
  catch (error) { logRequestError(delete_redeems, error); }
  return responses;
}

async function cancel_all_unfulfilled_redeems() {
  var responses = [];
  try {
    // Get channel redeems.
    const response = await TwitchHelixAPI.get_custom_rewards();
    if (response.statusCode == 200) {
      async function process(redeem) {
        try {
          // Get unfulfilled redemptions for specific reward.
          const response = await TwitchHelixAPI.get_unfulfilled_reward_redemptions(redeem.id);
          if (response.statusCode == 200) {
            const response_body = JSON.parse(response.data);
            // Cancel each redemption.
            for (const redemption of response_body.data) {
              TwitchHelixAPI.update_redemption_status_canceled(redemption);
            }
          }
          else {
            logResponseError(cancel_all_unfulfilled_redeems, response); // TODO still a lot of dup code, can we handle that in HelixAPI file?
          }
          responses.push(response);
        }
        catch (error) {
          logRequestError(cancel_all_unfulfilled_redeems, error);
        }
      }
      // Iterate over redeems and only process the ones which are marked as twitch redeems.
      const response_body = JSON.parse(response.data);
      console.log("Canceling all redemptions...")
      for (const redeem of response_body['data']) {
        if (redeem.prompt.includes(TWITCH_REDEEM_REWARD_TOKEN)) {
          await process(redeem);
        }
      }
    }
  }
  catch (error) { logRequestError(cancel_all_unfulfilled_redeems, error); }
}

function update_settings(body) {
  const settings = JSON.parse(body);
  for (const [key, value] of Object.entries(settings)) {
    global.settings[key] = value;
  }

  redeem_queue.stop_idle_timer();
}

function check_response_status_codes(responses, success_code) {
  for (const response of responses) {
    if (response.statusCode != success_code) {
      return response.statusCode;
    }
  }
  return success_code;
}

async function handleRequestGet(request, response, body) {
  const request_type = "GET"; // TODO a lot of same code in handleRequests functions...
  let status_code;
  let response_body;

  const url = new URL(request.url, `http://${request.headers.host}`);

  try {
    if (url.pathname == '/pop-redeem') {
      const redeem = redeem_queue.request_redeem();
      if (redeem != null) {
        status_code = 200;

        // Construct reponse.
        body = {
          "title": redeem.reward.title,
          "user": redeem.user_name,
          "user_input": redeem.user_input,
          "user_color": redeem.user_chat_color
        }
      }
      else {
        status_code = 204;
        body = {};
      }

      response_body = JSON.stringify(body);
    }
    else if (url.pathname == '/queued-redeems') {
      const head_redeem_id = url.searchParams.get("head-redeem-id")
      let start_index = head_redeem_id < 0 ? 0 : redeem_queue.find_by_uid(head_redeem_id);

      const redeems = [];
      let first_redeem_uid = -1;
      let last_redeem_uid = -1;

      if (start_index != null && start_index < redeem_queue.size()) {
        first_redeem_uid = redeem_queue.queue.items[start_index].twitch_redeems_uid;

        for (let i = start_index; i < redeem_queue.size(); i++) {
          const redeem = redeem_queue.queue.items[i];

          const r = {
            "title": redeem.reward.title,
            "title_color": redeem.reward.title_color,
            "user": redeem.user_name,
            "user_color": redeem.user_chat_color,
            "uid": redeem.twitch_redeems_uid,
          }

          redeems.push(r)
          last_redeem_uid = redeem.twitch_redeems_uid;
        }
      }

      // Construct reponse.
      body = {
        redeems: redeems,
        first_redeem_id: first_redeem_uid,
        last_redeemed_id: redeem_queue.last_redeemed_id,
        timer: redeem_queue.queue_timer,
        reset: redeem_queue.reset_browser_overlay,
      }

      redeem_queue.reset_browser_overlay = false;

      response_body = JSON.stringify(body);
      status_code = 200;
    }
    else {
      logRequestUrlError(request_type, request.url);
      status_code = 400;
    }
  }
  catch (error) {
    logHandleRequestError(request_type, error);
    status_code = 500;
  }

  return [status_code, response_body];
}

async function handleRequestPost(request, response, body) {
  const request_type = "POST"; // TODO a lot of same code in handleRequests functions...
  let status_code;
  let response_body;

  try {
    if (request.url == '/redeems') {
      await delete_redeems();
      const responses = await create_redeems(body);
      status_code = check_response_status_codes(responses, 200);

      if (status_code == 200) {
        global.twitch_redeems = await get_twitch_redeems();
      }
    }
    else if (request.url == '/map_start') {
      console.log("Game is starting...");
      console.log("Unpausing redeems...");
      pause_redeems(false);
      status_code = 200;
    }
    else if (request.url == '/map_end') {
      console.log("Game is ending...");
      redeem_queue.stop_idle_timer();
      redeem_queue.init();
      cancel_all_unfulfilled_redeems();
      console.log("Pausing redeems...");
      pause_redeems(true);
      status_code = 200;
    }
    else if (request.url == '/redeem_settings') {
      console.log("Received new redeem settings");
      update_settings(body);
      status_code = 200;
    }
    else {
      logRequestUrlError(request_type, request.url);
      status_code = 400;
    }
  }
  catch (error) {
    logHandleRequestError(request_type, error);
    status_code = 500;
  }

  return [status_code, response_body];
}

async function handleRequestPut(request, response, body) {
  const request_type = "PUT"; // TODO a lot of same code in handleRequests functions...
  let status_code;
  let response_body;
  try {
    logRequestUrlError(request_type, request.url);
    status_code = 400;
  }
  catch (error) {
    logHandleRequestError(request_type, error);
    status_code = 500;
  }

  return [status_code, response_body];
}

async function handleRequestDelete(request, response, body) {
  const request_type = "DELETE"; // TODO a lot of same code in handleRequests functions...
  let status_code;
  let response_body;

  try {
    if (request.url == '/redeems') {
      const responses = await delete_redeems();
      status_code = check_response_status_codes(responses, 200);
    }
    else {
      logRequestUrlError(request_type, request.url);
      status_code = 400;
    }
  }
  catch (error) {
    logHandleRequestError(request_type, error);
    status_code = 500;
  }

  return [status_code, response_body];
}

async function handleRequestPatch(request, response, body) {
  const request_type = "PATCH";
  let status_code;
  let response_body;

  try {
    if (request.url == '/redeems') {
      const responses = await update_redeems(body);
      status_code = check_response_status_codes(responses, 200);
    }
    else {
      logRequestUrlError(request_type, request.url);
      status_code = 400;
    }
  }
  catch (error) {
    logHandleRequestError(request_type, error);
    status_code = 500;
  }

  return [status_code, response_body];
}

async function startHTTPProxyServer(port) {
  // Get current twitch redeems.
  global.twitch_redeems = await get_twitch_redeems();

  server = http.createServer(function (request, response) {
    // Set response header.
    response.setHeader('Content-Type', 'application/json');
    response.appendHeader('Access-Control-Allow-Origin', '*');

    let requestBody = '';
    request.on('data', (chunk) => {
      requestBody += chunk;
    });

    let responseBody;
    request.on('end', async () => {
      try {
        // Process requests.
        if (request.method === 'GET') {
          [response.statusCode, responseBody] = await handleRequestGet(request, response, requestBody);
        }
        else if (request.method === 'POST') {
          [response.statusCode, responseBody] = await handleRequestPost(request, response, requestBody);
        }
        else if (request.method === 'PUT') {
          [response.statusCode, responseBody] = await handleRequestPut(request, response, requestBody);
        }
        else if (request.method === 'DELETE') {
          [response.statusCode, responseBody] = await handleRequestDelete(request, response, requestBody);
        }
        else if (request.method === 'PATCH') {
          [response.statusCode, responseBody] = await handleRequestPatch(request, response, requestBody);
        }
        else {
          console.error(`Unknown request method '${request.method}'`);
        }
      }
      catch (error) {
        console.error(`Processing http proxy server requests: '${error}'`);
      }

      // Set response body.
      response.end(JSON.stringify(responseBody));
    });
  });

  server.listen(port, '127.0.0.1', function () {
    console.log(`Server started on http://127.0.0.1:${port}`);
    ipc.setGameHttpProxyServerConnectionState(true);
  });

  server.on('close', () => {
    console.log('Twitch Redeems HTTP ProxyServer is gracefully closed.');
    ipc.setGameHttpProxyServerConnectionState(false);
  });
}

async function closeHTTPProxyServer() {
  if (server) {
    server.close(() => {
    });
  }
}

ipcMain.on("refundChannelPoints", (event) => {
  cancel_all_unfulfilled_redeems();
});

ipcMain.on("resetRedeemQueue", (event) => {
  cancel_all_unfulfilled_redeems();
  redeem_queue.init();
});

ipcMain.on("getTwitchRedeems", (event) => {
  get_twitch_redeems();
});

ipcMain.on("deleteRedeems", (event) => {
  delete_redeems();
});

ipcMain.on("pauseRedeems", (event) => {
  pause_redeems(true);
});

ipcMain.on("unpauseRedeems", (event) => {
  pause_redeems(false);
});

module.exports = {
  startHTTPProxyServer,
  closeHTTPProxyServer,
};