const http = require('http');
const myModule  = require('./test.js'); // TODO RENAME this file
const TwitchHelixAPI = require('./twitch_helix_api.js');

let server;

const TWITCH_REDEEM_REWARD_TOKEN = "[Twitch Redeem]" // TODO move?

function logResponseError(func, response) {
  const response_body = JSON.parse(response.data);
  console.error(`Twitch Helix API response '${func.name}' failed with status code ${response.statusCode} - '${response_body['message']}'`);
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
    try {
      // Create redeems.
      const response = await TwitchHelixAPI.create_custom_reward(redeem)
      if (response.statusCode == 200) {
        console.log(`Created redeem '${redeem.title}'`);
      }
      else {
        logResponseError(create_redeems, response); // TODO still a lot of dup code, can we handle that in HelixAPI file?
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
    }
  }
  catch (error) { logRequestError(delete_redeems, error); }
  return responses;
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

async function handleRequestPost(request, response, body) {
  const request_type = "POST"; // TODO a lot of same code in handleRequests functions...
  let status_code;
  let response_body;

  try {
    if (request.url == '/redeems') {
      const responses = await create_redeems(body);
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

function startHTTPProxyServer() {
  server = http.createServer(function (request, response) {
    // Set response header.
    response.setHeader('Content-Type', 'application/json');

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

  const port = 8000;  // TODO : setting?
  server.listen(port, '127.0.0.1', function () {
    console.log(`Server started on http://127.0.0.1:${port}`);
  });

  server.on('close', () => {
    console.log('Twitch Redeems HTTP ProxyServer is gracefully closed.');
    myModule.setGameHttpProxyServerConnectionState(false);
  });

  myModule.setGameHttpProxyServerConnectionState(true);
}

async function closeHTTPProxyServer() {
  server.close(() => {s
  });
}

module.exports = {
  startHTTPProxyServer,
  closeHTTPProxyServer
};