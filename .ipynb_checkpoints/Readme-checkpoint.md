# Welcome to the AFM to DataFed Utility

## Instructions

1. If you do not have a python instance it is recommended to install [Anaconda]('https://www.anaconda.com/')
1. Download the github respository
1. Install the dependencies using `pip install -r requirements.txt'
1. Setup an account on [DataFed]('https://datafed.ornl.gov/')
1. Setup DataFed

   In your terminal run `datafed setup`

   Enter your username and password

1. Set up a globus account
1. You need to be running globus on the computer and set up an endpoint. This can be done using globus personal connect.
1. Find your globus endpoint ID and type the following command `datafed ep default set <endpoint_name_here>`
1. Done!

## Runing Script

run in the command line `python send_ibw_to_datafed.py "<full file path>" "<collection id on Datafed>"`
