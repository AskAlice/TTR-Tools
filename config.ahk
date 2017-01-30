#include json.ahk
version = v1.1.3
IfNotExist %A_AppData%\TTR-Tools\config.ini
	FileInstall, default-conf.ini, %A_AppData%\TTR-Tools\config.ini
versionInt := formatVersion(version)
ini = %A_AppData%\TTR-Tools\config.ini
FileInstall, default-conf.ini, %A_AppData%\TTR-Tools\config.ini,0
IniRead, iniVer, %ini%,TTR-Tools, version
iniVersionInt := formatVersion(iniVer)
IniRead, windowName, %ini%,TTR-Tools, windowName
global windowName := windowName
IniRead, iniUpdate, %ini%,TTR-Tools, CheckUpdate
IniRead, iniTrampolineEnabled, %ini%,Trampoline, enabled
if(iniTrampolineEnabled=="0" || iniTrampolineEnabled=="false" )
	enableFeatureTrampoline:= false
if(iniTrampolineEnabled=="1" || iniTrampolineEnabled=="true" )
	enableFeatureTrampoline:= true
IniRead, iniRep, %ini%,Trampoline, repeat
IniRead, iniAFKMins, %ini%, AFK, afkMins
IniRead, iniTimesToWater, %ini%, Garden, timesToWater
IniRead, iniReplant, %ini%, Garden, replant
download = % URLDownloadToVar("https://api.github.com/repos/thezoid/TTR-Tools/releases/latest")
parsed := JSON.load(download)
liveVer := parsed.tag_name
downloadURL := "https://github.com/thezoid/TTR-Tools/releases/latest"
liveVersionInt := formatVersion(liveVer)
if(iniUpdate != 0)
{
	if(versionInt < liveVersionInt)
	{
		MsgBox, 4, Update Found, TTR-Tools has found a more recent version released on GitHub. Compare- Current Version: %version%. Latest Version: %liveVer%. Download now?
		IfMsgBox Yes
		{
			Run, %downloadURL%
		}
		IfMsgBox No
		{
			MsgBox, 4, Update Found, Okay, TTR-Tools will not update. Remember this change?
				IfMsgBox Yes
			{
				IniWrite, 0, %ini%, TTR-Tools, CheckUpdate
				MsgBox, 0, TTR-Tools, Won't check for updates again. Download new version manually to re-enable, or go into config file at %ini%.
			}
		}
	}
}
if(iniVersionInt < versionInt || iniVersionInt == "" || !iniVersionInt || iniVersionInt == "RO"){
FileInstall, default-conf.ini, %A_AppData%\TTR-Tools\config.ini,1
}
formatVersion( str ){
versionNum1:= SubStr(str,2,1)
versionNum2:= SubStr(str,4,1)
versionNum3:= SubStr(str,6,1)
full :=  versionNum1 . versionNum2 . VersionNum3
return full
}
;debug
;ListVars
;pause