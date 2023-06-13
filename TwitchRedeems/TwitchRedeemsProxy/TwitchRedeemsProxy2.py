import asyncio
import json
import eel
import TwitchAPIAuthentication
import TwitchAPIHelix

from TwitchRedeemGlobals import *

# Set the path to the web folder
eel.init('web')

# Expose a Python function to JavaScript
@eel.expose
def fetch_channel_redeems():
    print("Test")
    #return f"Hello, {name}!"
    return "Done"

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

# def get_unfulfilled_twitch_redemptions(auth_token, user_id, client_id, reward_id):
#     rewards = TwitchAPIHelix.get_custom_rewards(auth_token, user_id, client_id)
#     redemptions = []
#     for reward in rewards:
#         redemptions.append(TwitchAPIHelix.get_redemptions(auth_token, user_id, client_id, reward_id, status="UNFULFILLED"))
#     return redemptions

auth_token, refresh_token = asyncio.run(TwitchAPIAuthentication.twitch_api_authenticate(CLIENT_ID, CLIENT_SECRET))
user_id = TwitchAPIHelix.get_user_id(auth_token, CLIENT_ID)

delete_all_twitch_redeem_rewards(auth_token, user_id, CLIENT_ID)
TwitchAPIHelix.create_custom_reward(auth_token, user_id, CLIENT_ID, title="ehehe", cost=2, prompt=TWITCH_REDEEM_REWARD_TOKEN)
TwitchAPIHelix.create_custom_reward(auth_token, user_id, CLIENT_ID, title="uhuh", cost=3, prompt=TWITCH_REDEEM_REWARD_TOKEN)



#update_all_twitch_redeem_rewards(auth_token, user_id, CLIENT_ID, paused=True)
#update_all_twitch_redeem_rewards(auth_token, user_id, CLIENT_ID, paused=False)
#delete_all_twitch_redeem_rewards(auth_token, user_id, CLIENT_ID)

# Start the Eel application
eel.start('index.html', size=(400, 400))
