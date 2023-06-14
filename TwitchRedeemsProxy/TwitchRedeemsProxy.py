import asyncio
import eel
import json
from threading import Thread

from RedeemQueue import RedeemQueue
from TwitchRedeemBackend import *
from TwitchRedeemUtils import thread_safe_print

import TwitchAPIAuthentication
import TwitchAPIHelix
import TwitchRedeemsProxyServer



# Expose a Python function to JavaScript
@eel.expose
def fetch_channel_redeems():
    print("Test")
    #return f"Hello, {name}!"
    return "Done"



# def get_unfulfilled_twitch_redemptions(auth_token, user_id, client_id, reward_id):
#     rewards = TwitchAPIHelix.get_custom_rewards(auth_token, user_id, client_id)
#     redemptions = []
#     for reward in rewards:
#         redemptions.append(TwitchAPIHelix.get_redemptions(auth_token, user_id, client_id, reward_id, status="UNFULFILLED"))
#     return redemptions

if __name__ == '__main__':

    # Set the path to the web folder
    eel.init('web')

    thread_safe_print("Authenticating...")

    auth.AUTH_TOKEN, auth.REFRESH_TOKEN = asyncio.run(TwitchAPIAuthentication.twitch_api_authenticate(CLIENT_ID, CLIENT_SECRET))
    auth.BROADCASTER_ID = TwitchAPIHelix.get_user_id(auth.AUTH_TOKEN, CLIENT_ID)

    thread_safe_print("Creating threads...")

    thread_http_server = Thread(target=TwitchRedeemsProxyServer.run_http_server, args=('', 8000))
    #thread_ws = Thread(target=TwitchAPIEventSub.run_ws,args=(func_event_callback, func_oauth_authenticate, func_oauth_refresh_token, redeem_queue))
    #threads = [thread_http_server, thread_ws] # TODO WT
    threads = [thread_http_server]

    thread_safe_print("Starting threads...")

    for process in threads:
        process.start()

    thread_safe_print("Threads started...")

    for process in threads:
        process.join()

    thread_safe_print("Threads have finished...")

    exit(0)
    # delete_all_twitch_redeem_rewards(auth_token, user_id, CLIENT_ID)
    # TwitchAPIHelix.create_custom_reward(auth_token, user_id, CLIENT_ID, title="ehehe", cost=2, prompt=TWITCH_REDEEM_REWARD_TOKEN)
    # TwitchAPIHelix.create_custom_reward(auth_token, user_id, CLIENT_ID, title="uhuh", cost=3, prompt=TWITCH_REDEEM_REWARD_TOKEN)


    #update_all_twitch_redeem_rewards(auth_token, user_id, CLIENT_ID, paused=True)
    #update_all_twitch_redeem_rewards(auth_token, user_id, CLIENT_ID, paused=False)
    #delete_all_twitch_redeem_rewards(auth_token, user_id, CLIENT_ID)

    # Start the Eel application
    eel.start('index.html', size=(400, 400))
