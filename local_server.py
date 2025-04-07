import os
import signal
import json
import re
from pathlib import Path
from math import inf

from fastapi import FastAPI
from pydantic import BaseModel

from datafed.CommandLib import API

from util import get_metadata

class User(BaseModel):
    username: str
    password: str

df_api = API()
app = FastAPI()

@app.get('/')
async def root():
    return {'message': 'Server is running'}

@app.post('/login')
@app.post('/login/')
async def login(user: User):
    return datafed_login(user.username, user.password)

@app.post('/logout')
@app.post('/logout/')
def logout():
    directory_path = os.path.join(Path.home(), '.datafed')
    return {'message': delete_datafed_key_files(directory_path)}

@app.post('/send_file/{file_path:path}')
@app.post('/send_file/{file_path:path}/')
def send_file(file_path: str, collection_id: str,
              record_name: str | None = None):
    if not record_name:
        record_name = re.search(r'(.*\\|.*/)?(.+)\.ibw$', file_path).groups()[1]
    print(record_name)
    return send_ibw_to_datafed(data_record_name=record_name,
                               file_path=file_path,
                               collection_id=collection_id)

@app.get('/shutdown')
@app.get('/shutdown/')
async def shut_down():
    os.kill(os.getpid(), signal.SIGTERM)
    return {'message': 'Server shutting down'}

@app.on_event('shutdown')
def on_shutdown():
    print('Server shutting down...')

def datafed_login(uid, password):
    """This function allows for login to datafed using the datafed API and to
    ensure that you are able to sign into your account run igorlogout before
    running this function to ensure there is no credentialled user before you
    login to start your transfer. This function has you input your user id and
    then your password securely and then it

    Returns: _type_: a print statement letting you know whether or not your
    login was successful """

    output = {}
    try:
        # Attempt to log in using provided credentials
        df_api.loginByPassword(uid, password)
        output['message'] = f'Successfully logged in to Data as {df_api.getAuthUser()}'
        if df_api.getAuthUser():
            df_api.setupCredentials()
    except Exception as e:
        output['message'] = 'Could not log into DataFed. Check your internet connection,' +\
        f' username, and password.'
        output['error'] = str(e)
    return output

def delete_datafed_key_files(directory):
    """ Delete DataFed user key files from the specified directory.

    This function attempts to remove the DataFed user private key file and the
    associated public key file from the provided directory. If the files exist,
    they are deleted, and a message is printed for each deletion.

    Args:
        directory (str): The directory path where the DataFed user key files
            are located.

    """

    priv_key = 'datafed-user-key.priv'
    priv_key_file = os.path.join(directory, priv_key)
    pub_key = 'datafed-user-key.pub'
    pub_key_file = os.path.join(directory, pub_key)
    deleted = []

    if os.path.exists(priv_key_file):
        os.remove(priv_key_file)
        deleted.append(priv_key)

    if os.path.exists(pub_key_file):
        os.remove(pub_key_file)
        deleted.append(pub_key)

    l = len(deleted)
    if not l:
        return 'User was already logged out'
    out = f'Deleted {deleted[0]}'
    if l > 1:
        out += f' and {deleted[1]}'
    return out

def send_ibw_to_datafed(data_record_name, file_path, collection_id):
    """This function takes an .ibw file and a datafed collection id, and using
    that it grabs the metadata from the file. The using the Datafed API it
    calls a funtion to create a new datarecord and name it the same name as
    your filepath, and assigns your metadata to the inputted collection id, and
    then using dataput it actually uploads all of the info to datafed. this
    function only works if you have: Globus personal Connect set up, you have
    run datafed setup and assigned a globus endpoint, and run DataFed_Log_In
    and logged as an authenticated user.

    Args:
        file_name (_path_): _the local file path of your .ibw file and make
            sure you put r' becuase there will be escape characters _
        collection_id (_type_): _the collection id name from your datafed where
            you want the file transfer to end up,and make sure you put r' becuase
            there will be escape characters _
    """

    json_output = get_metadata(file_path)

    # This removes flattening information and fixes inf values in metadata
    keys = json_output.keys()
    prefixes = [f'Flatten {i}' for i in ['Offsets', 'Slopes']]
    for prefix in prefixes:
        for i in [0, 1, 4]:
            curr_key = f'{prefix} {i}'
            if curr_key in keys:
                del json_output[curr_key]

    for _, (key, value) in enumerate(json_output.items()):
        if value == -inf:
            json_output[key] = '-Inf'

    for _, (key, value) in enumerate(json_output.items()):
        if value == inf:
            json_output[key] = 'Inf'

    output = {'message': 'Uploaded record to datafed'}
    try:
        # creates a new data record
        dc_resp = df_api.dataCreate(data_record_name, description=file_path,
                                    metadata=json.dumps(json_output),
                                    parent_id=collection_id)
    except Exception as e:
        output['message'] = 'There was an error creating the DataRecord'
        output['error'] = str(e)
        return output

    try:
        # extracts the record ID
        rec_id = dc_resp[0].data[0].id
    except ValueError as e:
        output['message'] = 'Could not find record ID'
        output['error'] = str(e)
        return output

    try:
        # sends the put command
        df_api.dataPut(rec_id, file_path, wait=True)
    except Exception as e:
        output['message'] = 'Could not intiate globus transfer'
        output['error'] = str(e)
        return output

    return output
