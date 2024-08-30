import getpass
import json

import numpy as np
from datafed.CommandLib import API

from util import get_metadata

# Initialize the API object
df_api = API()


def DataFed_Log_In():
    # Prompt for user ID and password
    uid = input("User ID: ")
    password = getpass.getpass(prompt="Password: ")

    try:
        # Attempt to log in using provided credentials
        df_api.loginByPassword(uid, password)
        success = f"Successfully logged in to Data as {df_api.getAuthUser()}"
    except:
        success = "Could not log into DataFed. Check your internet connection, username, and password"

    return success


def _send_ibw_to_datafed(file_name, collection_id):
    login_result = DataFed_Log_In()
    print(login_result)

    json_output = get_metadata(file_name)

    print(file_name)
    print(collection_id)

    # This removes flattening information and fixes inf values in metadata
    try:
        del json_output["Flatten Offsets 0"]
    except:
        pass

    try:
        del json_output["Flatten Slopes 0"]
    except:
        pass

    try:
        del json_output["Flatten Slopes 4"]
    except:
        pass

    try:
        del json_output["Flatten Offsets 4"]
    except:
        pass

    try:
        del json_output["Flatten Offsets 1"]
    except:
        pass

    try:
        del json_output["Flatten Slopes 1"]
    except:
        pass

    for i, (key, value) in enumerate(json_output.items()):
        if value == np.NINF:
            json_output[key] = "-Inf"

    for i, (key, value) in enumerate(json_output.items()):
        if value == np.Inf:
            json_output[key] = "Inf"

    try:
        # creates a new data record
        dc_resp = df_api.dataCreate(
            file_name,  # file name
            metadata=json.dumps(json_output),  # metadata
            parent_id=collection_id,  # parent collection
        )
    except Exception as e:
        print("There was an error creating the DataRecord", e)

    try:
        # extracts the record ID
        rec_id = dc_resp[0].data[0].id
    except ValueError:
        print("Could not find record ID")

    try:
        # sends the put command
        df_api.dataPut(rec_id, file_name, wait=True)
    except Exception:
        print("Could not intiate globus transfer")


if __name__ == "__main__":
    try:
        _send_ibw_to_datafed(
            file_name=r"C:\Users\Asylum User\Documents\Asylum Research Data\230802\Image0007.ibw",
            collection_id=r"c/u_ysp28_root",
        )
    except:
        pass
