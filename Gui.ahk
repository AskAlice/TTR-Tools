#Include XGraph.ahk
#Include config.ahk
toggle :=false
trampRunning :=false
global gardening := false
;TEST
FileCreateDir,%A_AppData%\TTR-Tools\
FileInstall, README.html, %A_AppData%\TTR-Tools\README.html,1
FileInstall, style.html, %A_AppData%\TTR-Tools\style.html,1

FileCreateDir,%A_AppData%\TTR-Tools\assets
FileCreateDir,%A_AppData%\TTR-Tools\assets\css
FileCreateDir,%A_AppData%\TTR-Tools\assets\js
FileCreateDir,%A_AppData%\TTR-Tools\assets\fonts
FileCreateDir,%A_AppData%\TTR-Tools\assets\fonts\roboto
FileInstall, assets\css\main.css, %A_AppData%\TTR-Tools\assets\css\main.css,1
FileInstall, assets\css\materialize.min.css, %A_AppData%\TTR-Tools\assets\css\materialize.min.css,1
FileInstall, assets\css\materialize.css, %A_AppData%\TTR-Tools\assets\css\materialize.css,1
FileInstall, assets\css\github-markdown.css, %A_AppData%\TTR-Tools\assets\css\github-markdown.css,1

FileInstall, assets\js\app.js, %A_AppData%\TTR-Tools\assets\js\app.js,1
FileInstall, assets\js\chart.js, %A_AppData%\TTR-Tools\assets\js\chart.js,1
FileInstall, assets\js\materialize.min.js, %A_AppData%\TTR-Tools\assets\js\materialize.min.js,1

FileInstall assets\fonts\roboto\Roboto-Bold.eot, %A_AppData%\TTR-Tools\assets\fonts\roboto\Roboto-Bold.eot
FileInstall assets\fonts\roboto\Roboto-Bold.ttf, %A_AppData%\TTR-Tools\assets\fonts\roboto\Roboto-Bold.ttf
FileInstall assets\fonts\roboto\Roboto-Bold.woff, %A_AppData%\TTR-Tools\assets\fonts\roboto\Roboto-Bold.woff
FileInstall assets\fonts\roboto\Roboto-Bold.woff2, %A_AppData%\TTR-Tools\assets\fonts\roboto\Roboto-Bold.woff2
FileInstall assets\fonts\roboto\Roboto-Light.eot, %A_AppData%\TTR-Tools\assets\fonts\roboto\Roboto-Light.eot
FileInstall assets\fonts\roboto\Roboto-Light.ttf, %A_AppData%\TTR-Tools\assets\fonts\roboto\Roboto-Light.ttf
FileInstall assets\fonts\roboto\Roboto-Light.woff, %A_AppData%\TTR-Tools\assets\fonts\roboto\Roboto-Light.woff
FileInstall assets\fonts\roboto\Roboto-Light.woff2, %A_AppData%\TTR-Tools\assets\fonts\roboto\Roboto-Light.woff2
FileInstall assets\fonts\roboto\Roboto-Medium.eot, %A_AppData%\TTR-Tools\assets\fonts\roboto\Roboto-Medium.eot
FileInstall assets\fonts\roboto\Roboto-Medium.ttf, %A_AppData%\TTR-Tools\assets\fonts\roboto\Roboto-Medium.ttf
FileInstall assets\fonts\roboto\Roboto-Medium.woff, %A_AppData%\TTR-Tools\assets\fonts\roboto\Roboto-Medium.woff
FileInstall assets\fonts\roboto\Roboto-Medium.woff2, %A_AppData%\TTR-Tools\assets\fonts\roboto\Roboto-Medium.woff2
FileInstall assets\fonts\roboto\Roboto-Regular.eot, %A_AppData%\TTR-Tools\assets\fonts\roboto\Roboto-Regular.eot
FileInstall assets\fonts\roboto\Roboto-Regular.ttf, %A_AppData%\TTR-Tools\assets\fonts\roboto\Roboto-Regular.ttf
FileInstall assets\fonts\roboto\Roboto-Regular.woff, %A_AppData%\TTR-Tools\assets\fonts\roboto\Roboto-Regular.woff
FileInstall assets\fonts\roboto\Roboto-Regular.woff2, %A_AppData%\TTR-Tools\assets\fonts\roboto\Roboto-Regular.woff2
FileInstall assets\fonts\roboto\Roboto-Thin.eot, %A_AppData%\TTR-Tools\assets\fonts\roboto\Roboto-Thin.eot
FileInstall assets\fonts\roboto\Roboto-Thin.ttf, %A_AppData%\TTR-Tools\assets\fonts\roboto\Roboto-Thin.ttf
FileInstall assets\fonts\roboto\Roboto-Thin.woff, %A_AppData%\TTR-Tools\assets\fonts\roboto\Roboto-Thin.woff
FileInstall assets\fonts\roboto\Roboto-Thin.woff2, %A_AppData%\TTR-Tools\assets\fonts\roboto\Roboto-Thin.woff2

FileInstall, index.html, %A_AppData%\TTR-Tools\index.html,1
FileInstall, webapp.json, %A_AppData%\TTR-Tools\webapp.json,1

FileInstall, def.ico, %A_AppData%\TTR-Tools\def.ico,0
FileInstall, antiafk.ico, %A_AppData%\TTR-Tools\antiafk.ico,0
FileInstall, gardening.ico, %A_AppData%\TTR-Tools\gardening.ico,0
FileInstall, tramp.ico, %A_AppData%\TTR-Tools\tramp.ico,0

if A_IsCompiled
{
  ;Menu, Tray, Icon, %A_ScriptFullPath%, -159
  Menu, Tray, Icon, %A_AppData%\TTR-Tools\def.ico
}
else
{
	Menu, Tray, Icon, %A_AppData%\TTR-Tools\def.ico
	Run, "C:\Program Files (x86)\Pandoc\pandoc.exe" README.md -o README.html
}

#include webGui.ahk
SetWorkingDir %A_ScriptDir% 
webappShown := true
;Gui __Webapp_:Hide
SendMode Input

small := 7*(96/A_ScreenDPI)
standard := 8*(96/A_ScreenDPI)
if(A_ScreenDPI != 96)
	TrayTip, TTR-Tools, "Please set your screen DPI scaling to normal for TTR-Tools to work correctly."

Gui, TTRTools:+AlwaysOnTop
Gui, TTRTools:-DPIScale
Gui, TTRTools:Margin, 0, 0
Gui, TTRTools:font, s%standard%
Gui, TTRTools:Add, Text,h12 y5, Welcome to TTR Tools %version%
Gui, TTRTools:font, s%small%
Gui, TTRTools:Add, Button, x+2 y0 vhelpBtn ghelp, Help
Gui, TTRTools:Add, Button, x+2 y0 gopenConfig, Config
Gui, TTRTools:Add, Button, x+2 y0 gopenWeb, Beta GUI
Gui, TTRTools:font, s%standard%
if(enableFeatureAFK || enableFeatureTrampoline || enableFeatureGarden)
{
	Gui, TTRTools:Add, Text, h15 x0, ALT+SHIFT+
	if(enableFeatureAFK)
		Gui, TTRTools:Add, Text,vtxt2 h15 x+0, (1-AntiAFK)
	if(enableFeatureTrampoline)
		Gui, TTRTools:Add, Text, vtxt3 h15 x+0, (2/3-Trampoline) 
		if(enableFeatureGarden)
		Gui, TTRTools:Add, Text, vtxt4 h15 x+0, (4/5-Garden--Num1-5)
}
	if(enableFeatureAFK || enableFeatureTrampoline || enableFeatureGarden)
	{
		Gui, TTRTools:font,bold
		Gui, TTRTools:Add, Text, x0 vstatusLabel, Status:
		Gui, TTRTools:font
		Gui, TTRTools:font, s%standard%
			if(enableFeatureAFK)
				Gui, TTRTools:Add, Text,x+3 vstatus, AntiAFK %toggle% |
			if(enableFeatureTrampoline)
				Gui, TTRTools:Add, Text,x+3 vstatus2, Trampoline %trampRunning% |
			if(enableFeatureGarden)
				Gui, TTRTools:Add, Text,x+3 vstatus3, Garden %gardening% |
				
	}
	if(enableFeatureAFK || enableFeatureTrampoline || enableFeatureGarden)
{
	Gui, TTRTools:font,bold
	Gui, TTRTools:Add, Text, x0 vopts, Opts:
	Gui, TTRTools:font
	Gui, TTRTools:font, s%standard%
		if(enableFeatureTrampoline)
		{
			;Gui, TTRTools:Add, checkbox,x+3 vspeedy gSave, Lagfix (>40)
			if(iniRep == 1)
				Gui, TTRTools:Add, checkbox,x+3 vrepeat Checked gSave, Repeat Trampoline
			else if(iniRep== 0)
				Gui, TTRTools:Add, checkbox,x+3 vrepeat gSave, Repeat Trampoline
			else
				Gui, TTRTools:Add, checkbox,x+3 vrepeat Checked gSave, Repeat Trampoline
		}
		if(enableFeatureAFK)
			{
				Gui, TTRTools:Add, Text, x+0 vtextAFK,| AFK Time (mins):
				if(!iniAFKMins)
				{
					Gui, TTRTools:Add, Edit, h16 x+3 w35 vtimeAFK gSave number, 4
					Gui, TTRTools:Add, UpDown, vtimeAFKUD Range1-11, 4
				}
				else
				{
					Gui, TTRTools:Add, Edit, h16 x+3 w35 vtimeAFK gSave number, %iniAFKMins%
					Gui, TTRTools:Add, UpDown, vtimeAFKUD Range1-11, %iniAFKMins%
					sendJS("updateValue('#interval','" . %iniAFKMins% . "');")
				}
			}
		if(enableFeatureGarden)
		{
				Gui, TTRTools:font,bold
				Gui, TTRTools:Add, Text, x0 vgopts, Garden:
				Gui, TTRTools:font
				Gui, TTRTools:font, s%standard%
				if(iniReplant == 1)
				Gui, TTRTools:Add, checkbox,x+0 vreplant Checked gSave,Pick+Replant
			else if(iniReplant == 0)
				Gui, TTRTools:Add, checkbox,x+0 vreplant gSave,Pick+Replant
			else
				Gui, TTRTools:Add, checkbox,x+0 vreplant Checked gSave,Pick+Replant
			Gui, TTRTools:Add, Text, x+0 vtextWater,| Times to Water (0-5):
			if(!iniTimesToWater)
			{
				Gui, TTRTools:Add, Edit, h16 x+0 w30 vtimesToWater gSave number, 2
				Gui, TTRTools:Add, UpDown, vtimesToWaterUD Range0-5, 2
			}
			else
			{
				Gui, TTRTools:Add, Edit, h16 x+0 w30 vtimesToWater gSave number, %iniTimesToWater%
				Gui, TTRTools:Add, UpDown, vtimesToWaterUD Range0-5, %iniTimesToWater%
				sendJS("updateValue('#water','" . %iniTimesToWater% . "');")
			}
		}
}
if(enableFeatureAFK || enableFeatureTrampoline || enableFeatureGarden)
{
	Gui, TTRTools:Add, Text,x0 vtxt w300 h15,Trampoline bot graph will plot when running
	if(!enableFeatureTrampoline)
	GuiControl, TTRTools:, txt, Enable a bot
}
if(enableFeatureAFK || enableFeatureTrampoline)
{
	if(enableFeatureTrampoline)
	{
		Gui, TTRTools:Add, Text, x0 w300 h310 hwndhGraph vGraph
		pGraph := XGraph( hGraph, 0x55daba, 5, "0,0,0,0", 0x649e90,5 )
	}
	Gui, TTRTools:Add, Text, x0 w300 h40 hwndvGraphv vvGraph
	vGraph := XGraph( vGraphv, 0x688443, 5, "0,0,0,0", 0x649e90,1 )
}
	Gui, TTRTools:Show,, TTR Tools
	if(!enableFeatureTrampoline){
	sendJS("disableFeature('ttab')")
	}
;if AFK label is created in current file (ie: if included in TTR-Tools)
AfkLabel = Afk
if(enableFeatureAFK)
{
	timeMS := timeAFK*60000
	SetTimer %AfkLabel%, %timeMS%
}

return

guiText(controlVar, controlText, guiName:="TTRTools:",showTime:=true)
{
;OutputDebug GuiControl,%guiName%,%controlVar%,%ControlText%
GuiControl,%guiName%,%controlVar%,%ControlText%
global trampRunning
global gardening
global toggle
StringReplace, controlText, controlText, ',, All
/*
\"(.*?\'.*)\"
*/
regex := RegExMatch(controlText, "(.*?\'.*)")
if((regex != "" && regex != "0") || regex)
	{
		OutputDebug REGEX Returned %regex%
		guiText("txt", "Regex Returned: " . regex)
	}
if(controlVar == "txt")
{
		FormatTime, TimeString,, h:mm:ss
	if(showTime)
	{
	if(trampRunning)
		sendJS("updateConsole('[" . TimeString . "] " . controlText . "')")
	else if(gardening)
		sendJS("updateConsole('[" . TimeString . "] " . controlText . "', '#garden-console')")
	else if(toggle)
		sendJS("updateConsole('[" . TimeString . "] " . controlText . "', '#afk-console')")
	else
		sendJS("updateConsole('[" . TimeString . "][unknown-task] " . controlText . "', '#error-console')")
	}
	else{
	if(trampRunning)
		sendJS("updateConsole('" . controlText . "')")
	else if(gardening)
		sendJS("updateConsole('" . controlText . "', '#garden-console')")
	else if(toggle)
		sendJS("updateConsole('" . controlText . "', '#afk-console')")
	else
		sendJS("updateConsole('[" . TimeString . "][unknown-task] " . controlText . "', '#error-console')")
		}
	}
}

Help::
    Gui , help:Destroy
	if A_IsCompiled
	{
		FileRead,fileContents,%A_AppData%\TTR-Tools\README.html
		FileRead,htmlpage,%A_AppData%\TTR-Tools\style.html
	}
	else
	{
		FileRead,fileContents,README.html
		FileRead,htmlpage,style.html
	}
	Gui help:+AlwaysOnTop
	Gui, help:Margin, 0, 0
	htmlpage.=fileContents
	htmlpage.="</body></html>"
	Gui, help:add,ActiveX,vpage w1000 h750 +BackgroundTrans, HTMLFile
	page.silent := true
	page.write(htmlpage)
	Gui, help:Show, , TTR Tools Help
	ComObjConnect(page, "IE_")
return

openConfig(){
gosub, openConfig
}
openConfig:
Run, %ini%
return
openWeb:
if(webappShown)
	Gui __Webapp_:Hide
else
	Gui __Webapp_:Show, w%__Webapp_Width% h%__Webapp_height%, %__Webapp_Name%
webappShown := !webappShown
return

Save:	
	Gui, TTRTools:Submit, NoHide
	
; config.ahk update
IniWrite, %repeat%, %ini%,Trampoline, repeat
IniWrite, %timeAFK%, %ini%, AFK, afkMins
IniWrite, %timesToWater%, %ini%, Garden, timesToWater
IniWrite, %replant%, %ini%, Garden, replant
/* doesn't seem to work */
/*sendJS("updateValue('#water','" . %iniTimesToWater% . "');")
sendJS("updateValue('interval','" . %timeAFK% . "');") 
*/
; end config.ahk update

if(enableFeatureAFK)
	{
		if(timeAFK*60000 != timeMS)
		{
			AfkLabel = Afk
			timeMS := timeAFK*60000
			SetTimer %AfkLabel%, %timeMS%
			plotAFKLabel= plotAFK
			if(isLabel(plotAFKLabel))
				{
					if(toggle)
					{
						plotAFKTime := Round(timeMS/300)
						SetTimer %plotAFKLabel%, %plotAFKTime%
					}
				}
		}
	}
return		

setStatus:
	global gardening
	global toggle
	global trampRunning
		if(enableFeatureAFK)
			GuiText("status","AntiAFK " .  toggle . " |")
		if(enableFeatureTrampoline)
			GuiText("status2","Trampoline " . trampRunning . " |")
		if(enableFeatureGarden)
			GuiText("status3","Garden " . gardening . " |")
		sleep, 250
		updateToggles(toggle,trampRunning,gardening)
		if(gardening)
			Menu, Tray, Icon, %A_AppData%\TTR-Tools\gardening.ico
		else if(toggle)
			Menu, Tray, Icon, %A_AppData%\TTR-Tools\antiafk.ico
		else if(trampRunning)
			Menu, Tray, Icon, %A_AppData%\TTR-Tools\tramp.ico
		else
			Menu, Tray, Icon, %A_AppData%\TTR-Tools\def.ico
return

;Debug information
^!+Ins::
	MouseMove, 726, 593
	return
^!+Home::
ListVars
return

helpGuiEscape:
helpGuiClose:
    Gui , help:Destroy
	return

TTRToolsGuiClose:		;close Gui to Exit
	ExitApp
	return