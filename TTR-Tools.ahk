/*
Welcome to TTR Tools v1.0.0
Released under the GPL
Please be sure to follow the license

*/
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
ListLines, Off
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#UseHook
#InstallMouseHook
#InstallKeybdHook
#SingleInstance, Force
#Include XGraph.ahk

global _starttime
SetBatchLines, -1
Process, priority, , High
FileCreateDir,%A_AppData%\TTR-Tools\
FileInstall, README.html, %A_AppData%\TTR-Tools\README.html,1
FileInstall, style.html, %A_AppData%\TTR-Tools\style.html,1
if A_IsCompiled
{
  Menu, Tray, Icon, %A_ScriptFullPath%, -159
}
else
{
	Menu, Tray, Icon, def.ico
	Run, "C:\Program Files (x86)\Pandoc\pandoc.exe" README.md -o README.html
}
FileInstall, README.html, %A_AppData%\TTR-Tools\README.html,1
if not A_IsAdmin
{
   Run *RunAs "%A_ScriptFullPath%"  ; Requires v1.0.92.01+
   ExitApp
}
;TTR Tools Version Number
RGB_Euclidian_Distance( c1, c2 ) ; find the distance between 2 colors
{ ; function by [VxE], return value range = [0, 441.67295593006372]
; that just means that any two colors will have a distance less than 442
   r1 := c1 >> 16
   g1 := c1 >> 8 & 255
   b1 := c1 & 255
   r2 := c2 >> 16
   g2 := c2 >> 8 & 255
   b2 := c2 & 255
   return Sqrt( (r1-r2)**2 + (g1-g2)**2 + (b1-b2)**2 )
}
width := 816
height :=639
variance := 25
WinGet active_id, ID, Toontown Rewritten [BETA]
toggle :=false
trampRunning :=false
Gui +AlwaysOnTop
Gui, Margin, 0, 0
Gui, Add, Text,h12 y5, Welcome to TTR Tools v1.0.0
Gui, font, s7
Gui, Add, Button, x+5 y0 ghelp, View Help
Gui, font
Gui, Add, Text,vtxt2 w300 h15 x0, CTRL+ALT+SHIFT+(1-AntiAFK)(2-Trampoline/3-Stop)
;Gui, Add, Checkbox, x0 gChecked, AntiAFK
;Gui, Add, Checkbox, x+0  gChecked, AntiAFK
Gui, font,bold
Gui, Add, Text, x0 vstatusLabel, Status:
	Gui, font
	Gui, Add, Text,x+3 vstatus, Trampoline %trampRunning% AntiAFK %toggle%
Gui, Add, Text, x0 vopts, Opts:
	Gui, Add, checkbox,x+3 vspeedy gSave, Lagfix (>40)
	Gui, Add, checkbox,x+3 vrepeat Checked gSave, Repeat
	Gui, Add, Text, x+0 vtextAFK,| AFK Time (mins):
	Gui, Add, Edit, h16 x+3 vtimeAFK gSave number, 8
	Gui, Add, UpDown, vtimeAFKUD Range1-11, 8
Gui, Add, Text,x0 vtxt w300 h15,Trampoline bot graph will plot when running
Gui, Add, Text, x0 w300 h310 hwndhGraph vGraph
pGraph := XGraph( hGraph, 0x55daba, 5, "5,5,5,5", 0x649e90,5 )
Gui, Add, Text, x0 w300 h40 hwndvGraph vvGraph
vGraph := XGraph( vGraph, 0x688443, 5, "5,5,5,5", 0x649e90,1 )
Gui, Show,, TTR Tools
timeMS := timeAFK*60000
	SetTimer Afk, %timeMS%
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
Home::
ListVars
return
Save:	
Gui, Submit, NoHide
if(timeAFK*60000 != timeMS)
	{
		timeMS := timeAFK*60000
		SetTimer Afk, %timeMS%
		if(toggle)
			SetTimer plotAFK, 6000
	}
return
^!+1:: 
if(!trampRunning)
	gosub, toggleAFK
return
toggleAFK:
toggle := !toggle
if(toggle)
	{
	GuiControl,,status, Trampoline %trampRunning% AntiAFK 1
	GuiControl, Disable, speedy
	GuiControl, Disable, repeat
	GuiControl, Enable, timeAFK
	GuiControl, Enable, timeAFKUD
	TrayTip TTR Tools, "Anti AFK Started", 1
	TrayTip txt, "Anti AFK Started", 1
	GuiControl,,txt, AFK Running. Triggers shown in spikes in lower graph
	XGraph_Plot(vGraph,25)
	SetTimer plotAFK, 6000
	;Menu Tray, Icon, afk.ico
	}
else
	{
	GuiControl,,status, Trampoline %trampRunning% AntiAFK 0
	TrayTip TTR Tools, "Anti AFK Stopped", 1
	SetTimer plotAFK, off
	GuiControl, Enable, speedy
	GuiControl, Enable, repeat
	GuiControl, Enable, timeAFK
	GuiControl, Enable, timeAFKUD
	;Menu Tray, Icon, def.ico
	}
return
plotAFK:
	if(sentLast)
	{
			XGraph_Plot(vGraph,0)
			global sentLast := false
	}
	else
			XGraph_Plot(vGraph,25)
return
Afk:
	WinGet active_id, ID, Toontown Rewritten [BETA]
	if(toggle)
	{
			ControlSend,,{Ctrl DOWN},ahk_id %active_id%
			sleep 60
			ControlSend,,{Ctrl UP},ahk_id %active_id%
			OutputDebug  Anti-AFK Run
			global sentLast := true
	}
return
^!+2:: 
trampRunning :=true
if(toggle)
{
	gosub, toggleAFK
}
OutputDebug Started
GuiControl,,status, Trampoline %trampRunning% AntiAFK %toggle%
GuiControl,,txt,Trampoline Bot Running. Searching for jump bar
GuiControl, Enable, speedy
GuiControl, Enable, repeat
GuiControl, Disable, timeAFK
GuiControl, Disable, timeAFKUD
;Menu Tray, Icon, tramp.ico
inMinigame := false

XGraph_Plot(pGraph)
WinMove, Toontown Rewritten [BETA], , ,  , width, height
SendMode Input
IfWinExist, Toontown
    WinActivate ; use the window found above
else
    {
	TrayTip TTR Tools, "Toontown Application not open", 1, 1
	GuiControl,,txt, Toontown not open
	trampRunning := false
	GuiControl,,status, Trampoline %trampRunning% AntiAFK %toggle%
	GuiControl, Show, textAFK
	GuiControl, Show, timeAFK
	GuiControl, Show, timeAFKUD
	return
	}
WinGet active_id, ID, Toontown Rewritten [BETA]
TrayTip TTR Tools, "Looking for trampoline meter. Keep window focused.", 1,32
count :=0
prevStrength :=0
looped := true
loop
{
	count++
	if (GetKeyState("Alt", "P") && GetKeyState("Shift", "P") && GetKeyState("Ctrl", "P") && GetKeyState("3", "P"))
	{
	TrayTip TTR Tools,"Trampoline bot stopped by hotkey", 1,32
	trampRunning := false
	GuiControl,,status, Trampoline %trampRunning% AntiAFK %toggle%
	GuiControl,,txt, Trampoline bot graph will plot when running
	GuiControl, Show, textAFK
	GuiControl, Show, timeAFK
	GuiControl, Show, timeAFKUD
	break
	} 
	;PixelSearch, Px, Py, 5, 451, 65, 459, 0xEFEFEF, 10 Fast RGB
	;if(width != winWidth || height != winHeight)
	if(count >=200)
	{
		color := 0xFFFFFF
		variance := 3
		highestPy := 445
	}
	/*else if(count >=191)
	{
		color := 0xFFFFFF
		variance := 3
		highestPy := 445
	}
	else if(count > 160)
	{
		color := 0xEFEFEF
		variance := 23
		highestPy := 451
	} 
*/	else
	{
		color := 0xEFEFEF
		variance := 35
		highestPy := 451
	}
	PixelSearch, Px, Py, 16, highestPy, 65, 459, color, variance, Fast RGB
	;PixelSearch, Px, Py, calcLeft, calcTop, calcRight, calcBottom, 0xEFEFEF, 23, Fast RGB
	;PixelSearch, Px, Py, 16, lowestPy, 65, highestPy, 0xEFEFEF, 255, Fast RGB ; max 99 tested @ 25 variance !! 23 variance 101 feet!
	;PixelSearch, Px, Py, 16, lowestPy, 65, highestPy, 0xcEFEFEF, variance, Fast RGB  ; dyamic
	if (ErrorLevel == 0)
	{
	_starttime := A_TickCount 
	if(!speedy)
	{
	PixelGetColor, bounce, pX,Py, RGB
	bunceD := Round(RGB_Euclidian_Distance(bounce,color))
	PixelGetColor, purp, 25,469, RGB
	dist := RGB_Euclidian_Distance(purp,0x8d519a)
	if(dist >25)
	{
		inMinigame := false
		GuiControl,,txt, Jump Bar not detected. Don't resize TT or tab out. Disable F.lux
	}
	}
	else
	{
	dist = 0
	bunceD = Simple
	}
		inMinigame := true
		if(looped && count > 10 && dist < 25)
		{
				elapsedtime := A_TickCount - _starttime
				GuiControl,,txt, Variance %variance%, Strength %count%, Integrity %bunceD%, lag. %elapsedtime%. foundBar %inMinigame%		
		if(prevStrength == 0)
			{
				OutputDebug %prevStrength% color %color% variance %variance% pixel %highestPy%
				XGraph_Plot(pGraph,310-prevStrength)
			}
			else{
				OutputDebug %count% color %color% variance %variance% pixel %highestPy% distance %bunceD%, lag %elapsedtime%
				prevStrength := count
				XGraph_Plot(pGraph,310-count)
			}
			prevStrength := count
			count := 0
			XGraph_Plot(vGraph,40-variance)
			ControlSend,, {Ctrl},ahk_id %active_id%
			;SendInput {Ctrl}
			looped := false
		}
		;OutputDebug ayy
	}
	else
	{
		if(count > 340 && repeat)
		{
		PixelGetColor, purp, 25,469, RGB
		dist := RGB_Euclidian_Distance(purp,0x8d519a)
		if(dist > 25)
						GuiControl,,txt, Jump Bar not detected. Don't resize TT or tab out. Disable Flux
			count := 0
			prevStrength:= 0
			ControlClick, x400 y450,ahk_id %active_id%,,,2, NA
			ControlSend,, {Down DOWN},ahk_id %active_id%
			Sleep 800
			ControlSend,, {Down UP},ahk_id %active_id%=
			Sleep 1400
		PixelGetColor,book,762,565 RGB
		bDist := RGB_Euclidian_Distance(book,0xf6fa84)
		if(bDist < 25)
			ControlClick, x726 y593,ahk_id %active_id%,,,4, NA
			Sleep 300
			ControlClick, x726 y593,ahk_id %active_id%,,,4, NA
		}
		looped :=true
	}
}
trampRunning := false
GuiControl,,status, Trampoline %trampRunning% AntiAFK %toggle%
GuiControl,,txt, Trampoline bot graph will plot when running
GuiControl, Show, textAFK
GuiControl, Show, timeAFK
GuiControl, Show, timeAFKUD
;Menu Tray, Icon, def.ico
OutputDebug Stopped
return

helpGuiEscape:
helpGuiClose:
    Gui , help:Destroy
	return
GuiClose:		;close Gui to Exit
GuiEscape:		;press Esc to Exit
ExitApp
return