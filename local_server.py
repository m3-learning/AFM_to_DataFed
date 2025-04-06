import os
import signal
from pathlib import Path

from fastapi import FastAPI
from pydantic import BaseModel

from datafed.CommandLib import API

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
    return {'message': datafed_login(user.username, user.password)}

@app.post('/logout')
@app.post('/logout/')
def logout():
    directory_path = os.path.join(Path.home(), '.datafed')
    return {'message': delete_datafed_key_files(directory_path)}

@app.post('/send_file/{file_path:path}')
@app.post('/send_file/{file_path:path}/')
def send_file(file_path: str):
    pass

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

    try:
        # Attempt to log in using provided credentials
        df_api.loginByPassword(uid, password)
        message = f'Successfully logged in to Data as {df_api.getAuthUser()}'
        if df_api.getAuthUser() is not None:
            df_api.setupCredentials()
    except Exception as e:
        message = 'Could not log into DataFed. Check your internet connection,' +\
        f' username, and password.\nError Message: {e}'
    return message

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
