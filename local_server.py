import json
import os
import re
import signal
from hashlib import md5
from math import inf
from pathlib import Path
from time import sleep
from typing import Optional

from datafed.CommandLib import API
from fastapi import BackgroundTasks, FastAPI
from pydantic import BaseModel
from sqlalchemy import create_engine
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, sessionmaker
from uvicorn.server import Server
from watchdog.events import FileSystemEvent, FileSystemEventHandler
from watchdog.observers import Observer

from util import get_metadata


class User(BaseModel):
    username: str
    password: str


class Base(DeclarativeBase):
    pass


class UploadedFile(Base):
    __tablename__ = "sent_files"

    id: Mapped[int] = mapped_column(primary_key=True)
    user: Mapped[str]
    file_name: Mapped[str]
    collection_id: Mapped[str]
    md5sum: Mapped[str]


df_api = API()
app = FastAPI()

db_name = os.path.join(Path.home(), ".datafed", "file_uploads.sqlite")
engine = create_engine(f"sqlite:///{db_name}")
conn = engine.connect()
Session = sessionmaker(bind=engine)
session = Session()
UploadedFile.metadata.create_all(engine)

app.should_exit = False
original_handler = Server.handle_exit


def handle_exit(*args, **kwargs):
    app.should_exit = True
    original_handler(*args, **kwargs)


Server.handle_exit = handle_exit


@app.get("/")
async def root():
    md5sum = md5(
        open(
            r"C:\Users\Asylum User\Documents\AFM_to_DataFed\test_data\HiGl_m750415.ibw",
            "rb",
        ).read()
    ).hexdigest()
    return {"message": md5sum}
    # return {'message': 'Server is running'}


@app.post("/login")
@app.post("/login/")
async def login(user: User):
    return datafed_login(user.username, user.password)


@app.post("/logout")
@app.post("/logout/")
def logout():
    directory_path = os.path.join(Path.home(), ".datafed")
    return {"message": delete_datafed_key_files(directory_path)}


@app.post("/send_file/{file_path:path}")
@app.post("/send_file/{file_path:path}/")
def send_file(file_path: str, collection_id: str, record_name: Optional[str] = None):
    if not record_name:
        record_name = get_record_name(file_path)
    return send_ibw_to_datafed(
        data_record_name=record_name, file_path=file_path, collection_id=collection_id
    )


@app.get("/get_user")
@app.get("/get_user/")
def get_user() -> dict[str, Optional[str]]:
    return {"message": df_api.getAuthUser()}


@app.post("/start_polling/{dir_path:path}")
@app.post("/start_polling/{dir_path:path}/")
async def start_polling(
    dir_path: str, collection_id: str, background_tasks: BackgroundTasks
):
    # print(dir_path)
    background_tasks.add_task(poll_directory, dir_path, collection_id)
    return {"message": f"Polling for new files in {dir_path}"}


@app.get("/stop_polling")
@app.get("/stop_polling/")
async def stop_polling():
    poll_directory.stop = True
    return {"message": "Stopped polling"}


@app.get("/shutdown")
@app.get("/shutdown/")
async def shut_down():
    os.kill(os.getpid(), signal.SIGTERM)
    return {"message": "Server shutting down"}


@app.on_event("shutdown")
def on_shutdown():
    print("Server shutting down...")


class IBWEventHandler(FileSystemEventHandler):
    def __init__(self, user: str, dir_path: str, collection_id: str):
        self.user = user
        self.dir_path = dir_path
        self.collection_id = collection_id

    def on_any_event(self, event: FileSystemEvent) -> None:
        et = event.event_type
        if et == "created":
            file_name = event.src_path
            # print(file_name)
            record_name = get_record_name(file_name)
            check_and_upload(
                f"{record_name}.ibw", self.user, self.dir_path, self.collection_id
            )


def poll_directory(dir_path: str, collection_id: str):
    poll_directory.stop = False
    initial_files = [i for i in os.listdir(dir_path) if i.endswith(".ibw")]
    user = get_user()["message"]
    if not user:
        raise ValueError("User not found")
    for fname in initial_files:
        check_and_upload(fname, user, dir_path, collection_id)
    event_handler = IBWEventHandler(user, dir_path, collection_id)
    observer = Observer()
    observer.schedule(event_handler, dir_path, recursive=False)
    observer.start()
    print("Starting polling...")
    try:
        while not (poll_directory.stop or app.should_exit):
            sleep(1)
    finally:
        print("Stopping polling.")
        observer.stop()
        observer.join()


def check_and_upload(file_name: str, user: str, dir_path: str, collection_id: str):
    full_path = os.path.join(dir_path, file_name)
    # This solves a windows specific problem where when you try to read a file
    # too quickly it just gives you a permissions error
    count = 0
    while True:
        try:
            md5sum = md5(open(full_path, "rb").read()).hexdigest()
            break
        except PermissionError as e:
            count += 1
            if count == 10:
                print(
                    f"Warning: file {full_path} is either very large or an"
                    + "actual permissions error, retrying the read a few more"
                    + "times"
                )
            if count > 20:
                raise e
            sleep(1)
    fup = (
        session.query(UploadedFile)
        .where(
            (UploadedFile.user == user)
            & (UploadedFile.file_name == file_name)
            & (UploadedFile.collection_id == collection_id)
            & (UploadedFile.md5sum == md5sum)
        )
        .all()
    )
    if not fup:
        print(f"Uploading {file_name[:-4]}")
        send_ibw_to_datafed(
            data_record_name=file_name[:-4],
            file_path=full_path,
            collection_id=collection_id,
        )
        record = UploadedFile(
            user=user, file_name=file_name, collection_id=collection_id, md5sum=md5sum
        )
        session.add(record)
    else:
        print(f"{file_name[:-4]} already uploaded, skipping")
    session.commit()


def get_record_name(file_path):
    match = re.search(r"(.*\\|.*/)?(.+)\.ibw$", file_path)
    if not match:
        raise ValueError("Invalid file path")
    return match.groups()[1]


def datafed_login(uid, password):
    """This function allows for login to datafed using the datafed API and to
    ensure that you are able to sign into your account run igorlogout before
    running this function to ensure there is no credentialled user before you
    login to start your transfer. This function has you input your user id and
    then your password securely and then it

    Returns: _type_: a print statement letting you know whether or not your
    login was successful"""

    output = {}
    try:
        # Attempt to log in using provided credentials
        df_api.loginByPassword(uid, password)
        output["message"] = f"Successfully logged in to Data as {df_api.getAuthUser()}"
        if df_api.getAuthUser():
            df_api.setupCredentials()
    except Exception as e:
        output["message"] = (
            "Could not log into DataFed. Check your internet connection,"
            + " username, and password."
        )
        output["error"] = str(e)
    return output


def delete_datafed_key_files(directory):
    """Delete DataFed user key files from the specified directory.

    This function attempts to remove the DataFed user private key file and the
    associated public key file from the provided directory. If the files exist,
    they are deleted, and a message is printed for each deletion.

    Args:
        directory (str): The directory path where the DataFed user key files
            are located.

    """

    priv_key = "datafed-user-key.priv"
    priv_key_file = os.path.join(directory, priv_key)
    pub_key = "datafed-user-key.pub"
    pub_key_file = os.path.join(directory, pub_key)
    deleted = []

    if os.path.exists(priv_key_file):
        os.remove(priv_key_file)
        deleted.append(priv_key)

    if os.path.exists(pub_key_file):
        os.remove(pub_key_file)
        deleted.append(pub_key)

    deleted_count = len(deleted)
    if not deleted_count:
        return "User was already logged out"
    out = f"Deleted {deleted[0]}"
    if deleted_count > 1:
        out += f" and {deleted[1]}"
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
    prefixes = [f"Flatten {i}" for i in ["Offsets", "Slopes"]]
    for prefix in prefixes:
        for i in [0, 1, 4]:
            curr_key = f"{prefix} {i}"
            if curr_key in keys:
                del json_output[curr_key]

    for _, (key, value) in enumerate(json_output.items()):
        if value == -inf:
            json_output[key] = "-Inf"

    for _, (key, value) in enumerate(json_output.items()):
        if value == inf:
            json_output[key] = "Inf"

    output = {"message": "Uploaded record to datafed"}
    try:
        # creates a new data record
        dc_resp = df_api.dataCreate(
            data_record_name,
            description=file_path,
            metadata=json.dumps(json_output),
            parent_id=collection_id,
        )
    except Exception as e:
        output["message"] = "There was an error creating the DataRecord"
        output["error"] = str(e)
        return output

    try:
        # extracts the record ID
        rec_id = dc_resp[0].data[0].id
    except ValueError as e:
        output["message"] = "Could not find record ID"
        output["error"] = str(e)
        return output

    try:
        # sends the put command
        df_api.dataPut(rec_id, file_path, wait=False)
    except Exception as e:
        output["message"] = "Could not intiate globus transfer"
        output["error"] = str(e)
        return output

    return output
