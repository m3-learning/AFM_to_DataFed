import argparse
from datafed.CommandLib import API
from util import *


# Initialize the API object
df_api = API()


def _send_ibw_to_datafed(data_record_name,file_path, collection_id):
    """This function takes an .ibw file and a datafed collection id, and using that it grabs the metadata from the file. 
    The using the Datafed API it calls a funtion to create a new datarecord and name it the same name as your filepath, 
    and assigns your metadata to the inputted collection id, and then using dataput it actually uploads all of the info to datafed.
    this function only works if you have: Globus personal Connect set up, you have run datafed setup and assigned a globus endpoint,
    and run DataFed_Log_In and logged as an authenticated user. 


    Args:
        file_name (_path_): _the local file path of your .ibw file and make sure you put r' becuase there will be escape characters _
        collection_id (_type_): _the collection id name from your datafed where you want the file transfer to end up,and make sure you put r' becuase there will be escape characters _
    """    

    json_output = get_metadata(file_path)

    print(file_path)
    print(collection_id)
    print(data_record_name)

    # This removes flattening information and fixes inf values in metadata
    try:
        del json_output['Flatten Offsets 0']
    except:
        pass

    try:
        del json_output['Flatten Slopes 0']
    except:
        pass

    try:
        del json_output['Flatten Slopes 4']
    except:
        pass

    try:
        del json_output['Flatten Offsets 4']
    except:
        pass

    try:
        del json_output['Flatten Offsets 1']
    except:
        pass

    try:
        del json_output['Flatten Slopes 1']
    except:
        pass

    for i, (key, value) in enumerate(json_output.items()):
        if value == np.NINF:
            json_output[key] = '-Inf'

    for i, (key, value) in enumerate(json_output.items()):
        if value == np.Inf:
            json_output[key] = 'Inf'

    try:
        # creates a new data record
        dc_resp = df_api.dataCreate(data_record_name,alias=file_path, # file name
                                metadata=json.dumps(json_output), # metadata
                                parent_id=collection_id, # parent collection
                            )
    except Exception as e:
        print('There was an error creating the DataRecord', e)

    try:
        # extracts the record ID
        rec_id = dc_resp[0].data[0].id
    except ValueError:
        print('Could not find record ID')

    try:
        # sends the put command
        put_resp = df_api.dataPut(rec_id,
                                    file_path,
                                    wait = True)
    except Exception:
        print('Could not intiate globus transfer')


if __name__ == "__main__":



    parser = argparse.ArgumentParser(description="Send IBW data to DataFed")
    
    parser.add_argument("data_record_name", help="Desired Data Record name ")
    parser.add_argument("file_path", help="Path to the IBW file")
    parser.add_argument("collection_id", help="ID of the parent collection")

    args = parser.parse_args()


    _send_ibw_to_datafed(data_record_name=args.data_record_name, file_path=args.file_path, collection_id=args.collection_id)