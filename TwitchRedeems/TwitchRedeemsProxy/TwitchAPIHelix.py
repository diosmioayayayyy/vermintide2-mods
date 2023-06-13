import json
import requests

helix_url = "https://api.twitch.tv/helix/"

# https://dev.twitch.tv/docs/api/reference/#get-users
def get_user_id(auth_token, client_id):
    headers = {'Authorization': f'Bearer {auth_token}', 'Client-Id': f'{client_id}'}
    response = requests.get(url="https://api.twitch.tv/helix/users" , headers=headers)

    if response.status_code != 200:
        raise Exception(f"BroadcasterID could not be retrieved [{response.status_code}]")

    j = json.loads(response.text)
    user_id = j['data'][0]['id']

    return user_id

def get_user_id_old(auth_token, client_id):
    headers = {'Authorization': f'Bearer {auth_token}', 'Client-Id': f'{client_id}'}
    response = requests.put(url="https://api.twitch.tv/helix/users" , headers=headers) # ?login=diosmioayayayyy
    user_id = None

    if response.status_code == 200:
        j = json.loads(response.text)
        user_id = j['data'][0]['id']

    return user_id

# https://dev.twitch.tv/docs/api/reference/#get-custom-reward
def get_custom_rewards(auth_token, broadcaster_id, client_id):
    headers = {'Authorization': f'Bearer {auth_token}', 'Client-Id': f'{client_id}'}
    response = requests.get(url=f"https://api.twitch.tv/helix/channel_points/custom_rewards?broadcaster_id={broadcaster_id}" , headers=headers)

    if response.status_code != 200:
        raise Exception(f"Custom Rewards could not be retrieved [{response.status_code}]")

    j = json.loads(response.text)
    raw_reward_list = j['data']

    reward_list = []
    for r in raw_reward_list:
        reward_list.append(r)

    return reward_list

# https://dev.twitch.tv/docs/api/reference/#create-custom-rewards
def create_custom_reward(auth_token, broadcaster_id, client_id,
                         title,
                         cost,
                         prompt=None,
                         background_color=None,
                         is_user_input_required=None,
                         is_global_cooldown_enabled=None,
                         global_cooldown_seconds=None):

    headers = {'Authorization': f'Bearer {auth_token}', 'Client-Id': f'{client_id}', 'Content-Type': 'application/json'}

    body = { 
        'title' : title,
        'cost'  : cost,
    }

    if prompt                     is not None: body['prompt']                     = prompt
    if background_color           is not None: body['background_color']           = background_color
    if is_user_input_required     is not None: body['is_user_input_required']     = is_user_input_required
    if is_global_cooldown_enabled is not None: body['is_global_cooldown_enabled'] = is_global_cooldown_enabled
    if global_cooldown_seconds    is not None: body['global_cooldown_seconds']    = global_cooldown_seconds

    response = requests.post(url=f"https://api.twitch.tv/helix/channel_points/custom_rewards?broadcaster_id={broadcaster_id}" , headers=headers, data=json.dumps(body))

    if response.status_code != 200:
       return False

    return True

# https://dev.twitch.tv/docs/api/reference/#update-custom-reward
def update_custom_reward(auth_token, broadcaster_id, client_id, custom_reward_id,
                         is_enabled=None,
                         is_paused=None):

    headers = {'Authorization': f'Bearer {auth_token}', 'Client-Id': f'{client_id}', 'Content-Type': 'application/json'}

    body = {}

    if is_enabled is not None:  body['is_enabled'] = is_enabled
    if is_paused  is not None:   body['is_paused']  = is_paused

    if len(body) == 0:
        return False

    response = requests.patch(url=f"https://api.twitch.tv/helix/channel_points/custom_rewards?broadcaster_id={broadcaster_id}&id={custom_reward_id}" , headers=headers, data=json.dumps(body))

    if response.status_code != 200:
       return False

    return True

# TODO NOT TESTED YET
# https://dev.twitch.tv/docs/api/reference/#get-custom-reward-redemption
def get_redemptions(auth_token, broadcaster_id, client_id, reward_id, status, first=None, after=None):
    headers = {'Authorization': f'Bearer {auth_token}', 'Client-Id': f'{client_id}', 'Content-Type': 'application/json'}
    body = { 'status' : status}

    url = url=f"https://api.twitch.tv/helix/channel_points/custom_rewards/redemptions?broadcaster_id={broadcaster_id}&reward_id={reward_id}&status={status}"
    if first: url = url + f"&first={first}"
    if after: url = url + f"&after={after}"
    response = requests.get(url=url, headers=headers, data=json.dumps(body))

    if response.status_code != 200:
       return False

    return True

# TODO NOT TESTED YET
# https://dev.twitch.tv/docs/api/reference/#update-redemption-status
def update_redemption_status(auth_token, broadcaster_id, client_id, redemption_id, status):

    headers = {'Authorization': f'Bearer {auth_token}', 'Client-Id': f'{client_id}', 'Content-Type': 'application/json'}
    body = { 'status' : status} # Possible values for 'status' are CANCELED or FULFILLED.

    response = requests.patch(url=f"https://api.twitch.tv/helix/channel_points/custom_rewards?broadcaster_id={broadcaster_id}&reward_id={redemption_id}" , headers=headers, data=json.dumps(body))

    if response.status_code != 200:
       return False

    return True

# https://dev.twitch.tv/docs/api/reference/#delete-custom-reward
def delete_custom_reward(auth_token, broadcaster_id, client_id, custom_reward_id):
    headers = {'Authorization': f'Bearer {auth_token}', 'Client-Id': f'{client_id}'}
    response = requests.delete(url=f"https://api.twitch.tv/helix/channel_points/custom_rewards?broadcaster_id={broadcaster_id}&id={custom_reward_id}" , headers=headers)

    if response.status_code != 200:
       return False

    return True
