from RedeemQueue import RedeemQueue
import TwitchAPIHelix

CLIENT_ID = "zuknbow10f0m5b0rqosg0gpba6tg41"
CLIENT_SECRET = "b2zy7kqjs0h1yn3yzt5ywqnk7fvw6j"
TWITCH_REDEEM_REWARD_TOKEN = "[Twitch Redeem]"

redeem_queue = RedeemQueue()

class Authorization():
    def __init__(self):
        self.AUTH_TOKEN = None
        self.REFRESH_TOKEN = None
        self.BROADCASTER_ID = None

auth = Authorization()

def set_auth(auth_token=None, refresh_token=None, broadcaster_id=None):
    global AUTH_TOKEN
    global REFRESH_TOKEN
    global BROADCASTER_ID
    if auth_token: AUTH_TOKEN = auth_token
    if refresh_token: REFRESH_TOKEN = auth_token
    if broadcaster_id: BROADCASTER_ID = auth_token

# Deletes all custom twitch redeem rewards from channel.
def delete_all_twitch_redeem_rewards(auth_token, user_id, client_id):
    rewards = TwitchAPIHelix.get_custom_rewards(auth_token, user_id, client_id)
    for reward in rewards:
        if TWITCH_REDEEM_REWARD_TOKEN in reward['prompt']:
            TwitchAPIHelix.delete_custom_reward(auth_token, user_id, client_id, reward['id'])

# Pause/Unpause all custom twitch redeem rewards from channel.
def update_all_twitch_redeem_rewards(auth_token, user_id, client_id, paused):
    rewards = TwitchAPIHelix.get_custom_rewards(auth_token, user_id, client_id)
    for reward in rewards:
        if TWITCH_REDEEM_REWARD_TOKEN in reward['prompt']:
            TwitchAPIHelix.update_custom_reward(auth_token, user_id, client_id, reward['id'], is_paused=paused)

# Refund all twitch redemptions.
def update_all_twitch_redeem_rewards(auth_token, user_id, client_id, paused):
    rewards = TwitchAPIHelix.get_custom_rewards(auth_token, user_id, client_id)
    for reward in rewards:
        if TWITCH_REDEEM_REWARD_TOKEN in reward['prompt']:
            TwitchAPIHelix.update_custom_reward(auth_token, user_id, client_id, reward['id'], is_paused=paused)

# Refund twitch redemption
def refund_twitch_redemption(auth_token, user_id, client_id, redemption_id):
    return TwitchAPIHelix.update_redemption_status(auth_token, user_id, client_id,redemption_id, status="CANCELED")

# Fulfill twitch redemption
def fulfill_twitch_redemption(auth_token, user_id, client_id, redemption_id):
    return TwitchAPIHelix.update_redemption_status(auth_token, user_id, client_id,redemption_id, status="FULFILLED")