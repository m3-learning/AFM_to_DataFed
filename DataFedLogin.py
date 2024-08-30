# from util import *
import getpass

from datafed.CommandLib import API

# Initialize the API object
df_api = API()


def DataFed_Log_In():
    """This function allows for login to datafed using the datafed API and to ensure that you are able to sign into your account
    run igorlogout before running this function to ensure there is no credentialled user before you login to start your transfer.
    This function has you input your user id and then your password securely and then it


    Returns:
        _type_: a print statement letting you know whether or not your login was successful
    """

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
