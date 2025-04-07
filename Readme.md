# Welcome to the AFM to DataFed Utility

## Initial Setup

<!--1. If you do not have a python instance it is recommended to install [Anaconda]('https://www.anaconda.com/')
1. Download the github respository-->
1. Install the dependencies using `pip install -r requirements.txt` .
1. Set up a [Globus](https://www.globus.org/globus-connect) account.
1. You need to be running [Globus-Personal-Connect](https://www.globus.org/globus-connect-personal) on the computer and set up an endpoint.
1. Setup an account on [DataFed](https://datafed.ornl.gov/).
1. Setup DataFed:

   In your terminal run `datafed setup`

   Enter your username and password

1. Find your globus endpoint ID and type the following command `datafed ep default set <endpoint_name_here>`.

## Execution Instructions

1. Run `fastapi run local_server.py` to start the local API server.
1. The server includes routes:
    * `login`: Logs the user into DataFed. Post body parameters:
        * `username`: Globus ID.
        * `password`: Globus password.
    * `logout`: Logs the user out of DataFed.
    * `send_file`: Uploads an `.ibw` file to DataFed.
 
        Example: `http://127.0.0.1:8000/send_file//home/user/somewhere/AFM_to_DataFed/test_data/HiGl_m750506.ibw?collection_id=1?record_name=HiGl1`

        Parameters:
        * `file_path`: Full path to the file. Passed at the end of the URL. Including a second / like in the example is required as it is interpreted as part of the path.
        * `collection_id`: Collection ID on DataFed. Passed as a query parameter.
        * `record_name` (optional): Name to be given to the record. If not provided, will default to the name of the file sans extension.

    * `shutdown`: Shuts down the API server.

## Using the Igor Panel
