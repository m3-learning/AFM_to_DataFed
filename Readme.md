# Welcome to the AFM to DataFed Utility

## Instructions

1. If you do not have a python instance it is recommended to install [Anaconda]('https://www.anaconda.com/')
1. Download the github respository
1. Install the dependencies using `pip install -r requirements.txt'
1. Set up a [globus] ('https://www.globus.org/globus-connect') account 
1. You need to be running [Globus-Personal-Connect] ('https://www.globus.org/globus-connect-personal') on the computer and set up an endpoint.  
1. Setup an account on [DataFed]('https://datafed.ornl.gov/')
1. Setup DataFed
   
   In your terminal run `datafed setup`

   Enter your username and password
1. Set up a globus account
1. You need to be running globus on the computer and set up an endpoint. This can be done using globus personal connect. 
1.  Find your globus endpoint ID and type the following command `datafed ep default set <endpoint_name_here>`
1.  Done!

## Running Script

run in the command line `python DataFedLogin.py` and input your username and password when prompted, once "Successfully logged in to Data as {your username}" is printed you are free to upload as many files you want 
this can be done by running this in the command line `python ibw_to_datafed.py "<full file path>" "<collection id on Datafed>"` as many times for as many files as you would like.
when you are done uploading your files to maintain security please run `python DataFedLogout.py` this is to ensure your account does automatically sign in the next time someone tries to upload a file.


## Using the Igor Panel 




