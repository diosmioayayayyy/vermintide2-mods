from RedeemQueue import RedeemQueue
import TwitchAPIAuthentication
import TwitchAPIEventSub
import TwitchRedeemsProxyServer
import json
import queue
from threading import Thread

def func_event_callback(data): # TODO DEL ?
    j = json.loads(data)
    message = json.loads(j["data"]["message"])
    if message["type"] == "reward-redeemed":
        redemption = message["data"]["redemption"]
        redeemer = redemption["user"]["display_name"]
        redeem_title = redemption["reward"]["title"]
        redeem_text = redemption["user_input"] if "user_input" in redemption else ""

        #q.put({redeemer, redeem_title, redeem_text})
        #print("\n --- ")
        #for i in q.queue:
        #    print(i)
        ## TODO add redeem to queue
        ## TODO find out if it's a rat game redeem? or let game logic check?
    return

def func_oauth_authenticate():
    return TwitchAPIAuthentication.twitch_api_authenticate()

def func_oauth_refresh_token():
    return "", "" # TODO

if __name__ == '__main__':

    redeem_queue = RedeemQueue()

    print("Creating threads...")

    thread_http_server = Thread(target=TwitchRedeemsProxyServer.run_http_server, args=('', 8000, redeem_queue))
    thread_ws = Thread(target=TwitchAPIEventSub.run_ws,args=(func_event_callback, func_oauth_authenticate, func_oauth_refresh_token, redeem_queue))
    threads = [thread_http_server, thread_ws]

    print("Starting threads...")

    for process in threads:
        process.start()

    print("Threads started...")

    for process in threads:
        process.join()

    print("Threads have finished...")
    exit(0)
