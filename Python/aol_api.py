import base64
import hashlib
import hmac
import json
import time
import urlparse
import requests
#from pass_file import get_key
from data_file import platforms

client_config = {
    "REALM": "aolcorporate/aolexternals",
    "BASE_URL": "https://id.corp.aol.com",
    "REDIRECT_URI":  "https://id.corp.aol.com/identity/oauth2/access_token?realm=<realm>",
    }


def get_creds(platform):

    #sys.exit(0)

    client_id = platforms[platform]["access"]['id']
    client_secret = platforms[platform]["access"]['secret']

    return client_id, client_secret


def hmac_sha256(key, msg, encode_output=False):
    message = bytes(msg).encode('utf-8')
    secret = bytes(key).encode('utf-8')
    signature = hmac.new(secret, message, digestmod=hashlib.sha256).digest()
    return base64.b64encode(signature) if encode_output else signature

def get_access_token(platform):
    """
    Authenticates a user using Oauth and returns an access token
    :param client_config: A dict with the environment variables. Is different on QA/PROD
    :param oauth_code: The oauth_code included in the url when the user has logged-in in AOL and is redirected to
    the app
    :return: the oauth access token for the user
    """

    # Gets clientd_id and client_secret from file
    client_id = platforms[platform]["access"]['id']
    client_secret = platforms[platform]["access"]['secret']
    
    #client_id = get_key[platform]['id']
    #client_secret = get_key[platform]['secret']

    realm = client_config['REALM']
    base_url = client_config['BASE_URL']
    redirect_uri = client_config['REDIRECT_URI']
    access_token_url_path = 'identity/oauth2/access_token'
	

    jwt_header = json.dumps({
	"typ": "JWT",
	"alg": "HS256",
	})

    issue_time = int(time.time()) # Seconds since epoch
    expiry_time = issue_time + 600
    aud = urlparse.urljoin(base_url, '{path}?realm={realm}'.format(path=access_token_url_path, realm=realm))

    jwt_body = {
	"iss": client_id,
	"sub": client_id,
	"aud": aud,
	"exp": expiry_time,
	"iat": issue_time,
	}

    jwt_body = json.dumps(jwt_body)
    jwt_signing_string = base64.b64encode(jwt_header) + '.' + base64.b64encode(jwt_body)
    signature = hmac_sha256(client_secret, jwt_signing_string)
    jwt_signature = base64.b64encode(signature)
    client_assertion = jwt_signing_string + '.' + jwt_signature

    data = {
	'grant_type': 'client_credentials',
	'client_assertion_type': 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer',
	'client_assertion': client_assertion,
	'scope': 'one',
	'realm': 'aolcorporate/aolexternals',
	}

    resp = requests.post(urlparse.urljoin(base_url, access_token_url_path), data=data)
	
    result = resp.json()
    return result['access_token']


def run_existing_report(login_token, report_id):
    return requests.session().post('https://onevideo.aol.com/reporting/run_existing_report?report_id=' + str(report_id), headers={"Authorization":'Bearer'+' '+ login_token}).text

