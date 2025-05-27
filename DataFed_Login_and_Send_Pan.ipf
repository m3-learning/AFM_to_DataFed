#Ifdef ARrtGlobals
#pragma rtGlobals=1        // Use modern global access method.
#else
#pragma rtGlobals=3        // Use strict wave reference mode
#endif 



Window DataFedSendPanel() : Panel
	PauseUpdate; Silent 1		// building window...
	String/G pollingDir
	String/G coID
	Variable/G currPolling = 0
	pollingDir = SpecialDirPath("Temporary", 1, 0, 0)
	coID = "c/u_" + GetDataFedUser() + "_root"
	NewPanel /K=1 /W=(1378,319,1906,1080) as "DataFed Login and Send"
	ModifyPanel fixedSize=1
	SetDrawLayer UserBack
	DrawText 84,96,"Collection ID"
	Button DataFedLoginButton_1,pos={100,22},size={129,39},proc=ButtonLoginProc,title="Log In"
	Button DataFedLoginButton_1,help={"Calls a python script to log into DataFed on the command line and save the user credentials "}
	Button DataFedLoginButton_1,font="Arial",fSize=16,fStyle=1
	Button DataFedLoginButton_1,fColor=(61440,61440,61440)
	Button Datafed_Logout,pos={267,21},size={138,40},proc=ButtonLogoutProc,title="Log Out"
	Button Datafed_Logout,help={"After you are done uploading files please press this to log out of datafed "}
	Button Datafed_Logout,font="Arial",fSize=16,fStyle=1,fColor=(61440,61440,61440)
	SetVariable DataFed_coID,pos={159,80},size={160,18},proc=SetCoIDProc,variable=coID
	SetVariable DataFed_coID,help={"The collection ID destination in DataFed"}
	SetVariable DataFed_coID,font="Arial"
	SetVariable PollingDirSetVar_DF,pos={30,117},size={419,18},bodyWidth=387,proc=ARSavePathDFSetVarFunc,title="Path:"
	SetVariable PollingDirSetVar_DF,help={"Folder Location of the data that will be sent "}
	SetVariable PollingDirSetVar_DF,font="Arial",fSize=12
	SetVariable PollingDirSetVar_DF,variable=pollingDir
	TitleBox DirDisplay pos={50,350}, size={1450,40},title="Not currently polling for new .ibw files"
	Button DataFedSendButton_1,pos={143,293},size={216,51},proc=ButtonSendProc,title="Toggle Polling"
	Button DataFedSendButton_1,help={"Runs a script to send your file once you have hit enter on the collection ID, compiled the path,and you have logged in"}
	Button DataFedSendButton_1,fSize=13,fStyle=1,fColor=(61440,61440,61440)
	Button PollingDirBrowseButton,pos={399,82},size={100,25},proc=PickDirectoryProc,title="Browse"
	Button PollingDirBrowseButton,help={"Browse to set the file location"}
	Button PollingDirBrowseButton,userdata(Pict)=  "ImageTab:Generic"
	Button PollingDirBrowseButton,userdata(ButtonPictures)= A"A7]@]F_l.rBk)7\\8SqmKAQ3)I3_*b!ATDKpVeC!lATCU]@s\"M<D..'g<+05s7qHRLEbT#j88iZ_Ei3ksATMp(A5HuMFJPgREb0<5ARn>MG%G\\jBk)7\\VdEA6EbSruBmO>XBOPq&3i&Y"
	Button PollingDirBrowseButton,font="Arial",fSize=12,fColor=(61440,61440,61440)
	Button PollingDirBrowseButton,picture= Generic
	Button OpenImageButton_4,pos={462,117},size={50,25},proc=OpenDirectoryProc,title="Open"
	Button OpenImageButton_4,help={"Opens windows explorer at current save location"}
	Button OpenImageButton_4,font="Arial",fSize=12,fColor=(61440,61440,61440)
	Button OpenImageButton_4,picture= OpenFolder
	SetWindow kwTopWin,hook(AR)=UserCnTPanelHook
	SetWindow kwTopWin,userdata(WindowPos)=  "Left:480;Top:442;"
	SetWindow kwTopWin,userdata(WindowGroup)=  "OfflineProgramming"
	SetWindow kwTopWin,userdata(DrawRectInfo)= A";IsC70W.E]AS#bT0W.6RF_.@)3AEEOVdEA6EbSruBmO>XBOPq&3i&Y"
EndMacro

Function CheckAPIServerRunning(message)
	String message
	variable result = !(strsearch(message, "The server is down", 0) >= 0)
	return result
End

Function CheckAPIServerRunningWithCall()
	string message = DoAPICall("")
	variable result = CheckAPIServerRunning(message)
	return result
End

Function StartServer()
	String cmd = "fastapi run \"C:\Users\Asylum User\Documents\AFM_to_DataFed\local_server.py\""
	RunDosCMD(cmd)
	Sleep 0:0:4
End

Function/S LogIntoDataFed()
	return DoAPICall("login")
End

Function/S LogOutOfDataFed()
	return DoAPICall("logout")
End

Function/S GetDataFedUser()
	return DoAPICall("get_user")[2,inf]
End

Function/S DoAPICall(apiExtension)
	String apiExtension
	Return DoAPICallWithPB(apiExtension, "")
End

Function/S TogglePolling()
	Variable/G currPolling
	if (!currPolling)
		currPolling = 1
		String ctrlName
		String/G pollingDir
		String/G coID
		String path = pollingDir
		TitleBox DirDisplay,title="Polling for new .ibw files in " + path
		String winPath = IgorToWindowsPath(path)
		String call = "start_polling/" + winPath + "?collection_id=" + coID
		return DoAPICallWithPB(call, "{}")
	else
		currPolling = 0
		TitleBox DirDisplay,title="Not currently polling for new .ibw files"
		return DoAPICall("stop_polling")
	endif
End

Function/S DoAPICallWithPB(apiExtension, postBody)
	String apiExtension
	String postBody
	String ctrlName
	String igorFile = SpecialDirPath("Temporary", 1, 0, 0) + "response.txt"
	String winFile = IgorToWindowsPath(igorFile)
	String apiURL = "\"http://127.0.0.1:8000/" + apiExtension + "\""
	// I have no idea why but %20 didn't work, this did
	apiURL = ReplaceString(" ", apiURL, "%%%220")
	String cmd = "curl -s " + apiURL
	if (strlen(postBody))
		cmd += " -X \"POST\" -H \"Content-Type: application/json\" -d '" + postBody + "'"
	endif
	cmd += " > \"" + winFile + "\""
	RunDosCMD(cmd)
	String content
	Variable refNum
	Open /R /T="TEXT" refNum as igorFile
	FReadLine refNum, content
	Close refNum
	String message = ExtractMessage(content)
	if (!CheckAPIServerRunning(message))
		StartServer()
		return DoAPICallWithPB(apiExtension, postBody)
	else
		return message
	endif
End

Function/S ExtractMessage(message)
	String message
	String out
	if (strsearch(message, "\"error\":", 0) >= 0)
		return "API call failed: " + message
	endif
	Variable messageLoc = strsearch(message, "\"message\":", 0)
	if (messageLoc >= 0)
		out = message[messageLoc+11,inf]
		out = out[0,strsearch(out, "\"", 0)-1]
	else
		out = "API call failed: The server is down"
	endif
	return out
End

Function/S IgorToWindowsPath(igorPath)
	String igorPath
	String winPath
	winPath = ReplaceString(":", igorPath, "\\")
	winPath = winPath[0] + ":\\" + winPath[2,inf]
	Return winPath
End

// Button action function
Function PickDirectoryProc(ctrlName) : ButtonControl
    String ctrlName
    String/G pollingDir
    String chosenDir
    String pathName = "userDirPath"

    // Prompt user to choose a directory
    NewPath/O/M="Choose a directory" $pathName
    PathInfo $pathName

    // Check if a path was set (user did not cancel)
    if (strlen(S_path) > 0)
        //chosenDir = S_path
        // Display in TitleBox (may truncate long paths)
        pollingDir = S_path
		//SetVariable PollingDirSetVar_DF,value=chosenDir
        //TitleBox DirDisplay title=chosenDir
    //else
		//SetVariable PollingDirSetVar_DF,value="No directory selected"
        //TitleBox DirDisplay title="No directory selected"
    endif
End

Function OpenDirectoryProc(ctrlName) : ButtonControl
	String ctrlName
	String/G pollingDir
	String path = pollingDir
	String cmd = "Explorer.exe \"" + IgorToWindowsPath(path) + "\""
	RunDosCMD(cmd)
	//ExecuteScriptText cmd
End

Function ButtonLogoutProc(ctrlName) : ButtonControl
	String ctrlName
	LogOutOfDataFed()
End

Function ButtonLoginProc(ctrlName) : ButtonControl
	String ctrlName
	LogIntoDataFed()
End

Function ButtonSendProc(ctrlName) : ButtonControl
	 String ctrlName
	 TogglePolling()
End


/////////////////////////////////////////////////////////////////////////////////////////////////

Function SetCoIDProc(datafedcoid) : SetVariableControl
	STRUCT WMSetVariableAction &datafedcoid
	string/g Datafed_coid = datafedcoid.sval

	switch( datafedcoid.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = datafedcoid.dval
			String sval = datafedcoid.sval
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

	
Function ARSavePathDFSetVarFunc(InfoStruct)
	Struct WMSetVariableAction &InfoStruct
	//EventCode
	//VName
	//SVal
	//svWave
	String/g Igor_filepath = InfoStruct.sval

	TrackSetVar(InfoStruct)
	
	if (InfoStruct.EventCode != 2)
		return(0)
	endif
	
	String VarName = InfoStruct.VName	
	
	String ParmName = ARConvertVarName2ParmName(VarName)
	Wave/T ParmWave = InfoStruct.svWave		//we know our svWave is a text wave.
	String PathStr = ConvertPCPathToIgor(InfoStruct.sval)
		String LastPath = ParmWave[%$"Last"+ParmName][0]
		String PName = ParmName        //just to be clear, when it is acting as a symbolic path.


	Variable Error = 0

		Error = BuildFileFolder(PName,PathStr)
		if (Error || ARIsWriteProtected(PName))        //****** FUNCTION CALL INSIDE IF STATEMENT *******
			DoAlert 0,"Invalid path, or You do not have write privileges to this folder, try again"
			NewPath/O/Q/Z $PName,LastPath
			ParmWave[%$ParmName][0] = LastPath

   	else
			if (CmpStr(PathStr[Strlen(PathStr)-1],":") != 0)
			PathStr += ":"
			endif

			ParmWave[%$"Last"+ParmName][0] = PathStr
			InsertNewPathInHistory(PathStr)
			ParmWave[%$ParmName][0] = PathStr        //make sure, if something calls the setvar func, it needs to put it in the wave.

			if (GV("UseImagePath"))
			//then we need to push the image path to the force path.
			ParmWave[%LastSaveForce][0] = PathStr
			ParmWave[%SaveForce][0] = PathStr
			BuildFileFolder("SaveForce",PathStr)
			endif

		endif
   	
	
	
	ARCheckSuffix()
	UpdateStatusText()
	UpdateHDDStrength()
	return(0)
End //ARSavePathSetVarFunc
