import argparse
from util import *
from datafed.CommandLib import API
import os
import glob
import getpass

# Initialize the API object
df_api = API()


def DataFed_Log_In():

    uid = input("User ID: ")
    password = getpass.getpass(prompt="Password: ")

    try:
        # Attempt to log in using provided credentials
        df_api.loginByPassword(uid, password)
        success = f"Successfully logged in to Data as {df_api.getAuthUser()}"
        if df_api.getAuthUser() is not None:
            df_api.setupCredentials()
    except:
        success = "Could not log into DataFed. Check your internet connection, username, and password"

    return success

if __name__ == "__main__":
    login_result = DataFed_Log_In()
    print(login_result)
