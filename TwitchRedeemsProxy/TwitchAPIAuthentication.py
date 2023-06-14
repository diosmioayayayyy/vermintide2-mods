from twitchAPI.twitch import Twitch
from twitchAPI.oauth import UserAuthenticator
from twitchAPI.types import AuthScope
import asyncio

# https://stackoverflow.com/questions/59416326/safely-distribute-oauth-2-0-client-secret-in-desktop-applications-in-python

async def authenticate(client_id, client_secret):
    # Set your Twitch API credentials
    target_scope = [AuthScope.CHANNEL_MANAGE_REDEMPTIONS, AuthScope.CHANNEL_READ_REDEMPTIONS ] # , AuthScope.USER_EDIT

    # Create a Twitch instance
    twitch = Twitch(client_id, client_secret)

    # this will open your default browser and prompt you with the twitch verification website
    auth = UserAuthenticator(twitch, target_scope, force_verify=True)
    token, refresh_token = auth.authenticate()

    # Set the access token on the Twitch instance
    twitch.set_user_authentication(token, refresh_token=refresh_token, scope=target_scope)

    # Print the access token
    print(f"Access Token: ***") # {token}

    return token, refresh_token

async def twitch_api_refresh_token(refresh_token):
    #token, refresh_token = asyncio.run(authenticate())
    token = ""
    # TODO?
    return token, refresh_token

async def twitch_api_authenticate(client_id, client_secret):
    token, refresh_token = await authenticate(client_id, client_secret)
    return token, refresh_token
