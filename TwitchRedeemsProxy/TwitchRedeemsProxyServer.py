import json
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse, parse_qs
from TwitchRedeemBackend import *
from TwitchRedeemUtils import thread_safe_print

class CustomHandler(BaseHTTPRequestHandler):
    def __init__(self):
        return

    def __call__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

    def _set_response(self, status_code, content_type, response_body):
        self.send_response(status_code)
        self.send_header('Content-type', content_type)
        self.end_headers()
        self.wfile.write(response_body.encode('utf-8'))

    def do_POST(self):
        # Parse the URI
        parsed_uri = urlparse(self.path)

        # Parse the query parameters
        query_params = parse_qs(parsed_uri.query)

        content_length = int(self.headers['Content-Length'])
        payload = json.loads(self.rfile.read(content_length).decode('utf-8'))

        if parsed_uri.path == '/redeems':
            action = query_params["action"][0]
            if action == "create":
                delete_all_twitch_redeem_rewards(auth.AUTH_TOKEN, auth.BROADCASTER_ID, CLIENT_ID)
                for r in payload:
                    TwitchAPIHelix.create_custom_reward(auth.AUTH_TOKEN, auth.BROADCASTER_ID, CLIENT_ID, r['title'], cost=r['cost'], prompt=TWITCH_REDEEM_REWARD_TOKEN)
                self._set_response(200, 'application/json', json.dumps({}))
            elif action == "delete":
                delete_all_twitch_redeem_rewards(auth.AUTH_TOKEN, auth.BROADCASTER_ID, CLIENT_ID)
                self._set_response(200, 'application/json', json.dumps({}))
            else:
                self._set_response(404, 'application/json', json.dumps({}))

        else:
            # Default response for other paths
            self._set_response(404, 'text/plain', 'Unkown request')

    def do_DELETE(self):
        # Parse the URI
        parsed_uri = urlparse(self.path)

        # Parse the query parameters
        query_params = parse_qs(parsed_uri.query)

        if parsed_uri.path == '/redeems':
            action = query_params["action"][0]
            if action == "delete":
                delete_all_twitch_redeem_rewards(auth.AUTH_TOKEN, auth.BROADCASTER_ID, CLIENT_ID)
                self._set_response(200, 'application/json', json.dumps({}))
            else:
                self._set_response(404, 'application/json', json.dumps({}))

        else:
            # Default response for other paths
            self._set_response(404, 'text/plain', 'Unkown request')

    def do_GET(self):
        # Parse the URI
        parsed_uri = urlparse(self.path)

        # Parse the query parameters
        query_params = parse_qs(parsed_uri.query)

        # TODO WT: make GET, POST, UPDATE, DELETE requests instead of all GET
        # TODO WT: remove action delete/create

        if parsed_uri.path == '/pop-redeem':
            # Pop redeem from queue and set redeem fulfilled.
            redeem = redeem_queue.pop()
            if redeem:
                fulfill_twitch_redemption(auth.AUTH_TOKEN, auth.BROADCASTER_ID, CLIENT_ID, redeem['id'])
                self._set_response(200, 'application/json', json.dumps(redeem))
            else:
                self._set_response(201, 'application/json', json.dumps({}))

        elif parsed_uri.path == '/map_start':
            # Map starts, unpause all redeems.
            update_all_twitch_redeem_rewards(auth.AUTH_TOKEN, auth.BROADCASTER_ID, CLIENT_ID, paused=False)
            self._set_response(200, 'application/json', json.dumps({}))

        elif parsed_uri.path == '/map_end':
            # Map has ended, pause all redeems and refund all unprocessed redeems.
            update_all_twitch_redeem_rewards(auth.AUTH_TOKEN, auth.BROADCASTER_ID, CLIENT_ID, paused=True)
            for redeem in redeem_queue:
                refund_twitch_redemption(auth.AUTH_TOKEN, auth.BROADCASTER_ID, CLIENT_ID, redeem['id'])
            self._set_response(200, 'application/json', json.dumps({}))

        elif parsed_uri.path == '/keep_enter':
            1
            # TODO do we need to do something here?

        else:
            # Default response for other paths
            self._set_response(404, 'text/plain', 'Unkown request')

def run_http_server(address, port):
    server_address = (address, port)
    handler = CustomHandler()
    try:
        httpd = HTTPServer(server_address, handler)
        thread_safe_print(f'Starting server on port {port}...')
        httpd.serve_forever()
    except Exception as e:
        thread_safe_print(f'Shutting down HTTP-Server...  {str(e)}')
        httpd.shutdown()
