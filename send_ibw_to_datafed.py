import argparse
from util import *
from datafed.CommandLib import API
import os

def _send_ibw_to_datafed(file_name, collection_id):
    df_api = API()
    
    json_output = get_metadata(file_name)

    print(file_name)
    print(collection_id)

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
        dc_resp = df_api.dataCreate(os.path.basename(file_name), # file name
                                metadata=json.dumps(json_output), # metadata
                                parent_id=collection_id, # parent collection
                            )
    except Exception:

        print('There was an error creating the DataRecord')

    try: 
        # extracts the record ID
        rec_id = dc_resp[0].data[0].id
    except ValueError:
        print('Could not find record ID')

    try:
        # sends the put command
        put_resp = df_api.dataPut(rec_id,
                                    file_name,
                                    wait = False)
    except Exception:
        print('Could not intiate globus transfer')

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="This is a function that sends ibw files from Oxford Instruments Asylum Research Atomic Force Microscopes to DataFed"
    )
    parser.add_argument("file_name", help="This is the name of the full file path")
    parser.add_argument("collection_id", help="This is the name of the collection ID where the file will be saved on DataFed")
    args = parser.parse_args()

    _send_ibw_to_datafed(args.file_name, args.collection_id)
