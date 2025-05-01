#Ifdef ARrtGlobals
#pragma rtGlobals=1        // Use modern global access method.
#else
#pragma rtGlobals=3        // Use strict wave reference mode
#endif 

Window MainPanel() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(100,100,500,300) as "API Testing Panel"
	Button GetUserButton,pos={50,50},size={120,30},proc=GetUserProc,title="Get User"
	TitleBox UserLabel,pos={50,90},size={127,21},title="Updated Text Goes Here"
EndMacro

Function GetUserProc(ctrlName) : ButtonControl
	// Program doesn't seem to compile without both this argument and the declaration that it's a string
	String ctrlName
	String content = GetDataFedUser()
	TitleBox UserLabel,title=content
End

Function/S GetDataFedUser()
	return DoAPICall("get_user")
End

Function/S DoAPICall(apiExtension)
	String apiExtension
	Return DoAPICallWithPB(apiExtension, "")
End

Function/S DoAPICallWithPB(apiExtension, postBody)
	string apiExtension
	string postBody
	String ctrlName
	String igorFile = SpecialDirPath("Temporary", 1, 0, 0) + "response.txt"
	String winFile = IgorToWindowsPath(igorFile)
	String apiURL = "http://127.0.0.1:8000/" + apiExtension
	String cmd = "curl -s " + apiURL
	if (strlen(postBody))
		cmd += "-X \"POST\" -H \"Content-Type: application/json\" -d '" + postBody + "'"
	endif
	cmd +=  " > \"" + winFile + "\""
	RunDosCMD(cmd)
	String content
	Variable refNum
	Open /R /T="TEXT" refNum as igorFile
	FReadLine refNum, content
	Close refNum
	Return ExtractMessage(content)
End

Function/S ExtractMessage(message)
	String message
	if (strsearch(message, "\"error\":", 0) >= 0)
		return "API call failed: " + message
	endif
	String out = message[strsearch(message, "\"message\":", 0)+11,inf]
	out = out[0,strsearch(out, "\"", 0)-1]
	return out
End

Function/S IgorToWindowsPath(igorPath)
	String igorPath
	String winPath
	winPath = ReplaceString(":", igorPath, "\\\\")
	winPath = winPath[0] + ":\\" + winPath[2,inf]
	Return winPath
End
