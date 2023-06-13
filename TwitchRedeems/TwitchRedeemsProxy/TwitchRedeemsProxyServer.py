from RedeemQueue import RedeemQueue
from http.server import HTTPServer, BaseHTTPRequestHandler
import json

class CustomHandler(BaseHTTPRequestHandler):
    def __init__(self, redeem_queue):
        self.redeem_queue = redeem_queue

    def __call__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

    def _set_response(self, status_code, content_type, response_body):
        self.send_response(status_code)
        self.send_header('Content-type', content_type)
        self.end_headers()
        self.wfile.write(response_body.encode('utf-8'))

    def do_GET(self):
        if self.path == '/pop-redeem':
            redeem = self.redeem_queue.pop()
            print(redeem)
            # Create a JSON response
            #data = {'name': 'John Doe3', 'age': 30, 'city': 'New York'}
            json_data = json.dumps(redeem)
            # Set the response headers and write the JSON data
            self._set_response(200, 'application/json', json_data)
        else:
            # Default response for other paths
            self._set_response(404, 'text/plain', 'Unkown request')

def run_http_server(address, port, redeem_queue):
    server_address = (address, port)
    handler = CustomHandler(redeem_queue)
    try:
        httpd = HTTPServer(server_address, handler)
        print(f'Starting server on port {port}...')
        httpd.serve_forever()
    except Exception:
        print(f'Shutting down HTTP-Server...')
        httpd.shutdown()
