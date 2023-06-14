from RedeemQueue import RedeemQueue
from twitchAPI.twitch import Twitch
from twitchAPI.oauth import UserAuthenticator
from twitchAPI.types import AuthScope
import websockets
import asyncio
import json
import pycurl
import requests
from io import BytesIO

# curl -X POST 'https://api.twitch.tv/helix/eventsub/subscriptions' \
# -H 'Authorization: Bearer 2gbdx6oar67tqtcmt49t3wpcgycthx' \
# -H 'Client-Id: wbmytr93xzw8zbg0p1izqyzzc5mbiz' \
# -H 'Content-Type: application/json' \
# -d '{"type":"channel.channel_points_custom_reward_redemption.add","version":"1","condition":{"user_id":"1234"},"transport":{"method":"websocket"}}'

# '{"type":"user.update","version":"1","condition":{"user_id":"1234"},"transport":{"method":"webhook","callback":"https://this-is-a-callback.com","secret":"s3cre7"}}'

uri = "wss://pubsub-edge.twitch.tv"
uri = "wss://eventsub.wss.twitch.tv/ws"

def get_user_id(auth_token, client_id):
    headers = {'Authorization': f'Bearer {auth_token}', 'Client-Id': f'{client_id}'}
    response = requests.put(url="https://api.twitch.tv/helix/users" , headers=headers)
    user_id = None

    if response.status_code == 200:
        j = json.loads(response.text)
        j["data"][0]['id']
        user_id = j["data"][0]['id']

    return user_id

def subscribe(auth_token, session_id):
    client_id = 'zuknbow10f0m5b0rqosg0gpba6tg41' # TODO client_id
    user_id = get_user_id(auth_token, client_id)
    if not user_id:
        print("ERROR no user id") # TODO BETTER ERROR HANDLING

    headers = {'Authorization': f'Bearer {auth_token}', 'Client-Id': f'{client_id}', 'Content-Type': 'application/json'}
    data = { "type": "channel.channel_points_custom_reward_redemption.add", "version": "1", "condition": {"broadcaster_user_id": f"{user_id}"}, "transport": {"method":"websocket", "session_id": f"{session_id}"}}

    print(headers)
    print(data)

    response = requests.post(url="https://api.twitch.tv/helix/eventsub/subscriptions" , headers=headers, data=json.dumps(data))
    if response.status_code == 202:
        print("xddsmile")

    #data = '{"type":"channel.channel_points_custom_reward_redemption.add","version":"1","condition":{"user_id":"1234"},"transport":{"method":"webhook","callback":"https://this-is-a-callback.com","secret":"s3cre7"}}'
#     url = 'https://api.twitch.tv/helix/eventsub/subscriptions'

# '{"type":"user.update","version":"1","condition":{"user_id":"1234"},"transport":{"method":"webhook","callback":"https://this-is-a-callback.com","secret":"s3cre7"}}'

async def eventSubWebsocket(recv_callback, auth_token, redeem_queue):
    async with websockets.connect(uri) as websocket:
        data = await websocket.recv()
        session_id = json.loads(data)["payload"]["session"]["id"]
        print(f"Welcome: session_id={session_id}")

        subscribe(auth_token, session_id)

        # PUBSUB stuff, not the future xdd
        # # Subscribe to events.
        # print("Creating EventSub subscription...")
        # nonce = "TwitchRedeems"
        # sub = f'{{ "type": "LISTEN", "nonce": "{nonce}", "data": {{"topics": ["channel-points-channel-v1.162349768"], "auth_token": "{auth_token}" }} }}'
        # await websocket.send(sub)
        # data = await websocket.recv()
        # rslt = json.loads(data)
        # if rslt["error"] != "":
        #     print("ERROR subscribing to event!") # TODO proper error handling

        # Enter main loop for receiving subbed events.
        print("Waiting for events...")
        while True:
            try:
                data = await websocket.recv()
                print("Event received")
            except Exception as e:
                print(f'unexpected exception: {e}')

            # Parse event.
            j = json.loads(data)
            message_type = j["metadata"]["message_type"]
            if message_type == "session_keepalive":
                print("Received keep-alive message")
            elif message_type == "notification":
                redeemer = j["payload"]["event"]["user_name"]
                redeem_title = j["payload"]["event"]["reward"]["title"]
                redeem_text = j["payload"]["event"]["user_input"]
                redeem = { "redeemer": redeemer, "redeem_title": redeem_title, "redeem_text" :redeem_text }
                redeem_queue.push(redeem)
            else:
                print(f"Unknown message type: {message_type}")
            


            # PUBSUB stuff, not the future xdd
            # message = json.loads(j["data"]["message"])
            # if message["type"] == "reward-redeemed":
            #     redemption = message["data"]["redemption"]
            #     redeemer = redemption["user"]["display_name"]
            #     redeem_title = redemption["reward"]["title"]
            #     redeem_text = redemption["user_input"] if "user_input" in redemption else ""
            #     redeem = { "redeemer": redeemer, "redeem_title": redeem_title, "redeem_text" :redeem_text }
            #     redeem_queue.push(redeem)
            #     #recv_callback(data)


def run_ws(recv_callback, func_oauth_authenticate, func_oauth_refresh_token, redeem_queue):
    # Request OAuth Token.
    print("Requesting OAuth token...")
    auth_token, refresh_token = asyncio.run(func_oauth_authenticate())
    asyncio.run(eventSubWebsocket(recv_callback, auth_token,redeem_queue))
