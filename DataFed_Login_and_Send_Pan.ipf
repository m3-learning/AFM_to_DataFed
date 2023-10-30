#Ifdef ARrtGlobals
#pragma rtGlobals=1        // Use modern global access method.
#else
#pragma rtGlobals=3        // Use strict wave reference mode
#endif 


Window DataFedSendPanel() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(1378,319,1906,1080) as "DataFed Login and Send"
	ModifyPanel fixedSize=1
	SetDrawLayer ProgBack
	SetDrawEnv linethick= 3,linefgc= (0,0,39168),fillpat= 0
	DrawRect 3,3,524.999877929688,758.000061035156
	SetDrawLayer UserBack
	DrawText 84,96,"Collection ID"
	DrawText 96,369,"If Compile path and the full path are not updating try running  "
	DrawText 36,385,"CheckandSetDataFolder() in the command window, before attempting anything else "
	Button UserPanelRenameButton_0,pos={40,726},size={80,20},proc=ARUserPanelButtonFunc,title="Rename"
	Button UserPanelRenameButton_0,userdata(ButtonPictures)= A"A7]@]F_l.rBk)7\\VeC!lATCU]@s\"NEE,oN2F(JlYBk)7\\Vf6ZfF)to'88iZ_E_pI[FJPgA;e9u`@;KY(AOC->EcX:;VZ"
	Button UserPanelRenameButton_0,userdata= A":gnHZ3^Yr.F(KB53^Ih4CisS;<HD_l3^dmrF_t]-FE9K/F*VSED,OqdARTUhBKB.7ATCUUDImX*3]fo07S[B/ANE4fFC@XMA7&#KB5)6j@;]U_;e9iW?Vk0K/no9:4%Ne'AQ*#\\ARmhU3r"
	Button UserPanelRenameButton_0,font="Arial",fSize=12,fColor=(61440,61440,61440)
	Button UserPanelSaveButton_0,pos={140,726},size={80,20},proc=ARUserPanelButtonFunc,title="Save"
	Button UserPanelSaveButton_0,userdata(ButtonPictures)= A"A7]@]F_l.rBk)7\\VeC!lATCU]@s\"NEE,oN2F(JlYBk)7\\Vf6ZfF)to'88iZ_E_pI[FJPgA;e9u`@;KY(AOC->EcX:;VZ"
	Button UserPanelSaveButton_0,userdata= A":gnHZ3^Yr.F(KB53^Ih4CisS;<HD_l3^dmrF_t]-FE9K/F*VSED,OqdARTUhBKB.7ATCUUDImX*3]fo07S[B/ANE4fFC@XMA7&#KB5)6j@;]U_;e9iW?Vk0K/no9:4%Ne'AQ*#\\ARmhU3r"
	Button UserPanelSaveButton_0,font="Arial",fSize=12,fColor=(61440,61440,61440)
	PopupMenu UserPanelColorPop_0,pos={220,726},size={83,22},proc=ARUserPanelPopFunc,title="Color"
	PopupMenu UserPanelColorPop_0,userdata= A";IsC70W.E]AS#bT0W.6RF_.@)3AEEOVdEA6EbSruBmO>XBOPq&3i&Y"
	PopupMenu UserPanelColorPop_0,font="Arial",fSize=12
	PopupMenu UserPanelColorPop_0,mode=1,popColor= (0,0,39168),value= #"\"*COLORPOP*\""
	Button DataFedLoginButton_1,pos={100,22},size={129,39},proc=ButtonLoginProc,title="Log In"
	Button DataFedLoginButton_1,help={"Calls a python script to log into DataFed on the command line and save the user credentials "}
	Button DataFedLoginButton_1,font="Arial",fSize=16,fStyle=1
	Button DataFedLoginButton_1,fColor=(61440,61440,61440)
	Button Datafed_Logout,pos={267,21},size={138,40},proc=ButtonLogoutProc,title="Log Out"
	Button Datafed_Logout,help={"After you are done uploading files please press this to log out of datafed "}
	Button Datafed_Logout,font="Arial",fSize=16,fStyle=1,fColor=(61440,61440,61440)
	SetVariable DataFed_coID,pos={159,80},size={160,18},proc=SetCoIDProc
	SetVariable DataFed_coID,help={"The collection ID destination in DataFed"}
	SetVariable DataFed_coID,font="Arial",value= _STR:"c/u_ysp28_root"
	SetVariable SaveImageSetVar_DF,pos={30,117},size={419,18},bodyWidth=387,proc=ARSavePathDFSetVarFunc,title="Path:"
	SetVariable SaveImageSetVar_DF,help={"Folder Location of  the data that will be sent "}
	SetVariable SaveImageSetVar_DF,font="Arial",fSize=12
	SetVariable SaveImageSetVar_DF,limits={-inf,inf,0},value= root:packages:MFP3D:Main:Strings:GlobalStrings[%SaveImage]
	SetVariable BaseNameSetVar_DF,pos={89,158},size={207,20},bodyWidth=207,proc=BaseNameSetDFVarFunc,title=" "
	SetVariable BaseNameSetVar_DF,help={"BaseName of the image files"}
	SetVariable BaseNameSetVar_DF,userdata= A"6tL=KDId<rF@0taFE2;9F#lWrF(J*TD.QXWFB2gj<*q=13r"
	SetVariable BaseNameSetVar_DF,font="Arial",fSize=13
	SetVariable BaseNameSetVar_DF,limits={-inf,inf,0},value= root:packages:MFP3D:Hardware:DF_basename,live= 1
	TitleBox BaseNameSetVarT_0,pos={91,140},size={68,16},title="Base Name"
	TitleBox BaseNameSetVarT_0,help={"BaseName of the image files, hit enter after you have chosen the correct suffix"}
	TitleBox BaseNameSetVarT_0,labelBack=(62208,62208,62208),font="Arial",fSize=13
	TitleBox BaseNameSetVarT_0,frame=0,fStyle=0
	TitleBox BaseSuffixSetVarT_0,pos={332,143},size={32,16},title="Suffix"
	TitleBox BaseSuffixSetVarT_0,help={"The Suffix of the Image file you would like to send"}
	TitleBox BaseSuffixSetVarT_0,labelBack=(62208,62208,62208),font="Arial",fSize=13
	TitleBox BaseSuffixSetVarT_0,frame=0,fStyle=0
	SetVariable Fullpath,pos={40,260},size={436,16},bodyWidth=436,title=" "
	SetVariable Fullpath,help={"This is the file path that will be used in the script to send the file to datafed make sure it is correct and the file exists"}
	SetVariable Fullpath,fSize=6
	SetVariable Fullpath,limits={-inf,inf,0},value= root:packages:MFP3D:Hardware:DF_fullpath
	Button DataFedSendButton_1,pos={143,293},size={216,51},proc=ButtonSendProc,title="Send To DataFed"
	Button DataFedSendButton_1,help={"Runs a script to send your file once you have hit enter on the collection ID, compiled the path,and you have logged in"}
	Button DataFedSendButton_1,fSize=13,fStyle=1,fColor=(61440,61440,61440)
	SetVariable BaseSuffixDF,pos={329,161},size={86,16},proc=SetSuffixProc
	SetVariable BaseSuffixDF,help={"Make sure the suffix doesn't match up to the number in Save Options on the Master Panel. If it does it means the file you are trying to send doesn't exist"}
	SetVariable BaseSuffixDF,format="%04d",limits={0,inf,1},value= _NUM:4
	Button SaveImageBrowseButton,pos={399,82},size={100,25},proc=ARSaveDFPathButtonFunc,title="Browse"
	Button SaveImageBrowseButton,help={"Browse to set the file location"}
	Button SaveImageBrowseButton,userdata(Pict)=  "ImageTab:Generic"
	Button SaveImageBrowseButton,userdata(ButtonPictures)= A"A7]@]F_l.rBk)7\\8SqmKAQ3)I3_*b!ATDKpVeC!lATCU]@s\"M<D..'g<+05s7qHRLEbT#j88iZ_Ei3ksATMp(A5HuMFJPgREb0<5ARn>MG%G\\jBk)7\\VdEA6EbSruBmO>XBOPq&3i&Y"
	Button SaveImageBrowseButton,font="Arial",fSize=12,fColor=(61440,61440,61440)
	Button SaveImageBrowseButton,picture= Generic
	Button OpenImageButton_4,pos={462,117},size={19,14},proc=ARSavePathButtonFunc,title=""
	Button OpenImageButton_4,help={"Opens windows explorer at current save location"}
	Button OpenImageButton_4,font="Arial",fSize=12,fColor=(61440,61440,61440)
	Button OpenImageButton_4,picture= OpenFolder
	Button CompPath,pos={147,194},size={194,41},proc=ButtonPathCompProc,title="Compile Path"
	Button CompPath,help={"Press this button after putting in the correct suffix and basename and hitting enter on base name to update the full file path"}
	Button CompPath,fSize=16,fStyle=1,fColor=(61440,61440,61440)
	SetWindow kwTopWin,hook(AR)=UserCnTPanelHook
	SetWindow kwTopWin,userdata(WindowPos)=  "Left:480;Top:442;"
	SetWindow kwTopWin,userdata(WindowGroup)=  "OfflineProgramming"
	SetWindow kwTopWin,userdata(DrawRectInfo)= A";IsC70W.E]AS#bT0W.6RF_.@)3AEEOVdEA6EbSruBmO>XBOPq&3i&Y"
EndMacro

Function CheckandSetDataFolder()
    // Define the desired data folder path
    String/g desiredDF = "root:packages:MFP3D:Hardware:"
    String/g currentDF = GetDataFolder(1)

   // Get the current data folder path    
    // Compare the current path with the desired path
    if (cmpstr(currentDF, desiredDF) != 0)
        // Set the data folder to the desired path
      SetDataFolder desiredDF
    endif
End


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
Function SetSuffixProc(suf) : SetVariableControl
	STRUCT WMSetVariableAction &suf
	String/g DF_basesuffix
	Variable/g DF_basesuffixnum 
	switch( suf.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable BaseSuffixDF = suf.dval
			String sufnum = suf.sval
			DF_basesuffixnum =suf.dval
    				suf.dval /= 10^(max(strlen(num2istr(suf.dval))-4,0))
    				suf.dval = floor(Abs(suf.dval))
 			sprintf DF_basesuffix ,"%04d", DF_basesuffixnum
 			PV("BaseSuffix",suf.dval)
                		ARCheckSuffix()
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
Function BaseNameSetDFVarFunc(bname)
	Struct WMSetvariableAction &bname
	string/g DF_basename
    // EventCode
    	switch (bname.eventCode)
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			if (!Strlen(bname.SVal))
               			bname.SVal = "Image"
            		else
                			Variable MaxLength = ARBaseNameMaxLengthFunc()
                			if (Strlen(bname.SVal) > MaxLength)
                    			bname.SVal = "Image"
                			endif
           		endif
			String AlertStr = "Your Base Name had an issue\rOnly letters, numbers, and \"_\" are allowed\rIt also has to start with a letter, cannot contain the string \"Mask\",\rcan't be the exact name of a function, and must be <= " + Num2str(MaxLength) + " characters long.\rIt has been fixed."
            		String FixedName = FixARImageName(bname.SVal, 0, MaxLength=MaxLength)

            		if (!StringMatch(bname.SVal, FixedName)) // check to see if the name is legal, warn if not
                			if (GV("ScanStatus"))
                    			print AlertStr
                    			DoWindow/H
                			else
                    			DoAlert 0, AlertStr
                			endif
                			bname.SVal = FixedName
            		endif

            // Force, BaseName = 17, suffix ("0001") = 4, DataType ("Force") = 5, Section ("_Away") = 5
            // total = 31
		SVAR BaseName = root:Packages:MFP3D:Main:Variables:BaseName
            	BaseName = bname.SVal

            	PV("BaseSuffix", 0) // reset the suffix to 0
            	ARCheckSuffix()
            	ARCheckUserNote(0)
            	break
        		case -1: // control being killed
            	break
	endswitch
	return 0
end // BaseNameSetVarFunc

Function ButtonPathCompProc(path) : ButtonControl
	STRUCT WMButtonAction &path
	SVAR/Z Igor_filepath = root:packages:MFP3D:Hardware:Igor_filepath
	SVAR/Z DF_basename = root:Packages:MFP3D:Hardware:DF_basename
	SVAR/Z DF_basesuffix =root:packages:MFP3D:Hardware:DF_basesuffix

	

	switch( path.eventCode)
		case 2: // mouse up
			String/g DF_basepath = DF_basename + DF_basesuffix
			String/g cut_path = ReplaceString("C:", Igor_filepath,"")
			String/g  Win_path=  "C:\\" + ReplaceString( ":",cut_path, "\\") 
			String/g  DF_fullpath =Win_path + DF_basepath + ".ibw"
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function ButtonLoginProc(DFlogin) : ButtonControl
    STRUCT WMButtonAction &DFlogin


    switch( DFlogin.eventCode )
        case 2: // mouse up
            	Datafed_Login()
            break
        case -1: // control being killed
            break
    endswitch
    return 0
End

Function Datafed_Login()

	String/g Login = ""
	//Login += "\"C:\\Users\\Asylum User\\anaconda3\\python.exe\"" You either need this line or the word python in the next line not both
	Login += " python " +" \"C:\\Users\\Asylum User\\Documents\\AFM_to_DataFed\\DataFedLogin.py\""+"\r"
	Login += "pause"+"\r"
	RunDosCMD(Login)
End //
 

Function ButtonSendProc(DFSend) : ButtonControl
	STRUCT WMButtonAction &DFSend
    switch( DFSend.eventCode )
        case 2: // mouse up
            	Datafed_Sendfile()
            break
        case -1: // control being killed
            break
    endswitch
    return 0
End

Function Datafed_Sendfile()
	SVAR/Z DF_fullpath=root:packages:MFP3D:Hardware:DF_fullpath 
	SVAR/Z Datafed_coid =root:packages:MFP3D:Hardware:Datafed_coid
	SVAR/Z DF_basepath=root:packages:MFP3D:Hardware:DF_basepath

	String/g  Send = ""
	//Send += "\"C:\\Users\\Asylum User\\anaconda3\\python.exe\""  You either need this line or the word python in the next line not both
	Send += " python" +" \"C:\\Users\\Asylum User\\Documents\\AFM_to_DataFed\\ibw_to_datafed.py\"" + " \"" + DF_basepath + "\" \"" + DF_fullpath + "\" \"" + Datafed_coid + "\"" + "\r"	
	Send += " pause"+"\r"
	RunDosCMD(Send)
End //



Function ButtonLogoutProc(DFlogout) : ButtonControl
    STRUCT WMButtonAction &DFlogout

    switch( DFlogout.eventCode )
        case 2: // mouse up
            	Datafed_Logout()
            break
        case -1: // control being killed
            break
    endswitch
    return 0
End



Function Datafed_Logout()

	String/g  Logout = ""
	//Logout += "\"C:\\Users\\Asylum User\\anaconda3\\python.exe\"" You either need this line or the word python in the next line not both
	Logout += " python" +" \"C:\\Users\\Asylum User\\Documents\\AFM_to_DataFed\\DataFedLogout.py\""+"\r"
	Logout += "pause"+"\r"
	RunDosCMD(Logout)
End //




Function ARSaveDFPathButtonFunc(InfoStruct)
	Struct WMButtonAction &InfoStruct
	//ctrlname
	//eventCode
	//win is passed around, but not used.
	
	TrackButton(InfoStruct)
	ARButtonHover(InfoStruct)
	
	if (InfoStruct.EventCode != 2)
		return(0)
	endif
	
	String CtrlName = InfoStruct.CtrlName
	
	
	String ParmName = ARConvertName2Parm(CtrlName,"Button")

	String PName = ""	
	String DataFolder = GetDF("TOC")
	//Wave/T PathWave = $DataFolder+"PathWave"
	SVAR LastARPath = $DataFolder+"LastARPath"
	
	
	Variable Error
	String PrePath = "", CommandString
	
	StrSwitch (ParmName)
		case "SaveImageBrowse":
		Case "SaveForceBrowse":
			PName = ParmName[0,Strlen(ParmName)-strlen("Browse")-1]	//drop the browse
			ARBrowsePath(PName,1,"ARPathButtonCallback(\""+InfoStruct.Win+"\",\""+ParmName+"NextButton\",\""+GetFuncName()+"\")",Message="Path To Save Data")
			break

		case "SaveImageBrowseNext":
		case "SaveForceBrowseNext":
			PName = ParmName[0,Strlen(ParmName)-strlen("BrowseNext")-1]	//drop the browseNext
			PathInfo $PName
			if (V_Flag)
				if (ARIsWriteProtected(PName))
					DoAlert 0,"You do not have write privileges to this folder, try again"
					V_Flag = 0		//Does not count
				endif
			endif

			if (V_Flag)		//it worked
				PathInfo/S $PName
				LastARPath = S_path
				
				PS(ListMultiply(";Last;",PName,";"),S_Path)
				if (GV("UseImagePath") && StringMatch(PName,"SaveImage"))		//then PName must have been SaveImage, and we have to link up the force path.
					PName = "SaveForce"
					NewPath/O/Q/Z $PName S_path
					if (SafePathInfo(PName))
						PS(ListMultiply(";Last;",PName,";"),S_path)
					else
						NewPath/O/Q/Z $Pname,GS("Last"+PName)
					endif
				endif
				
				InsertNewPathInHistory(S_Path)
			else
				KillPath/Z $Pname
				NewPath/O/Q/Z $PName,GS("Last"+PName)
				return(0)
			endif
			ARCheckSuffix()
			break
			
		case "OpenImage":
		case "OpenForce":
			PName = "Save"+ParmName[strlen("Open"),Strlen(ParmName)-1]	//drop the open
			
			PathInfo/SHOW $PName
			break
			
		case "SetDefault":
			if (GV("SavePathAsAdmin"))
				Pname = GetUserParmPath()
			else
				Pname = ARUserPath("Preferences")
			endif
			
			//Make it
			//if these change, then change the same code in SetupDefaultSavePaths
			String VarList = "SaveImage;SaveForce;FMapSave;BaseSuffix;FMapBaseSuffix;UseImagePath;UseForcePath;"
			String PList = "SaveImage;SaveForce;"
			String SVARList = "BaseName;FMapBaseName;"
			String DefaultSVARList = "Image;ForceMap;"
			String ValueStr, DateStr
			
			DateStr = ARDateStamp()
			DateStr = ARWhosLogOn()+":"+DateStr+":"
			ValueStr = GS("SaveImage")
			if (GrepString(ValueStr,ARWhosLogOn()+":[0-9]{6,6}:$"))	//must have Name:6digits:
				ValueStr = ValueStr[0,Strlen(ValueStr)-Strlen(DateStr)-1]
				PS("SaveImage",ValueStr)
			endif
			
			Variable Value, A, nop = ItemsInList(VarList,";")
			nop += ItemsInList(PList,";")
			nop += ItemsInList(SVARList,";")
			Wave/T UserPathWave = InitOrDefaultTextWave(GetDF("TOC")+"DefaultPaths",Nop)
			Redimension/N=(nop) UserPathWave
			SetDimLabels(UserPathWave,VarList+ListMultiply(PList,"path",";")+SVARList,0)
			nop = ItemsInList(VarList,";")
			for (A = 0;A < Nop;A += 1)
				ParmName = StringFromList(A,VarList,";")
				Value = GV(ParmName)
				UserPathWave[%$ParmName][0] = num2str(Value)
			endfor
			nop = ItemsInList(SVARList,";")
			DataFolder = GetDF("Variables")
			for (A = 0;A < nop;A += 1)
				ParmName = StringFromList(A,SVARList,";")
				SVAR BaseName = $DataFolder+ParmName
				if (StringMatch(BaseName,StringFromList(A,DefaultSVARList,";")))
					UserPathWave[%$ParmName][0] = ""
				else
					UserPathWave[%$ParmName][0] = BaseName
				endif
			endfor
			nop = ItemsInList(PList,";")
			for (A = 0;A < nop;A += 1)
				ParmName = StringFromList(A,PList,";")
				ValueStr = GS(ParmName)
				UserPathWave[%$ParmName+"Path"][0] = ValueStr
			endfor
			
			Save/C/O/P=$Pname UserPathWave as NameOfWave(UserPathWave)+".ibw"

			Variable FileRef
			Open/P=$Pname FileRef as NameOfWave(UserPathWave)+".ibw"
			//*************************************************************************
			WriteFooter(FileRef,1,"UPath","")		//This is where the file version is hardcoded
			//I am probably not going to find this when i want to change it.....
			//*************************************************************************
			close(FileRef)

			GhostARSavePanel()
			//Dont break
		case "UpdateDefault":
			PS("SaveImage;SaveForce;","")
			SetupDefaultSavePaths()
			break
			
		case "ResetDefault":
			if (GV("SavePathAsAdmin"))
				Pname = GetUserParmPath()
			else
				Pname = ARUserPath("Preferences")
			endif
			DeleteFile/P=$PName/Z "DefaultPaths.ibw"
			GhostARSavePanel()
			PS("SaveImage;SaveForce;","")
			SetupDefaultSavePaths()
			break
			
	endswitch
	
	//you may wonder why the <edit> does setting the path have to do with hardware.
	//well if a certain someone sets the path, then they get different text in the status area
	//This is the area to the right of the ARC status
	UpdateStatusText()
	UpdateHDDStrength()		//this also needs to be done to update the Disk Health tool tip
	return(0)
End //ARSavePathButtonFunc

