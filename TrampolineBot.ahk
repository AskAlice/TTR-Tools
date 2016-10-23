#Include XGraph.ahk
enableFeatureTrampoline = true
#Include Gui.ahk
^!+3:: 
looping := false
return

^!+2:: 
width := 816
height := 639
;Bool used for GUI
trampRunning :=true
;using Label variable to avoid compilation errors when built standalone
toggleAFKLabel = toggleAFK
if(enableFeatureAFK)
	if(toggle)
	{
		gosub, %toggleAFKLabel%
	}
;OutputDebug Started
;GUI changes while in this bot
GuiControl,,txt,Trampoline Bot Searching. Stop with CTRL+ALT+SHIFT+3
GuiControl, Enable, repeat
GuiControl, Disable, timeAFK
GuiControl, Disable, timeAFKUD
goSub, Save
;Menu Tray, Icon, tramp.ico

;Make sure the graph is shown
XGraph_Plot(pGraph)
WinGet active_id, ID, Toontown Rewritten [BETA]
SendMode Input
IfWinExist, Toontown Rewritten [BETA]
	{
		WinActivate ; use the window found above
		WinGetPos,winX,winY,curWidth,curHeight
		if(curWidth != width || curHeight != height)
			WinMove, Toontown Rewritten [BETA], , ,  , width, height
	}
else
    {
	TrayTip TTR Tools, "Toontown Application not open", 1, 1
	GuiControl,,txt, Toontown not open
	trampRunning := false
	goSub setStatus
	GuiControl, Show, textAFK
	GuiControl, Show, timeAFK
	GuiControl, Show, timeAFKUD
	return
	}
TrayTip TTR Tools, "Looking for trampoline meter. Keep window focused.", 1,32
count :=0
prevStrength :=0
looped := true
goSub, setStatus
looping := true
_starttime := A_TickCount 
loop
{
	if(!looping)
		break
	count++
	if(prevStrength == 0)
		_starttime := A_TickCount 
	elapsedtime := A_TickCount - _starttime
	if (GetKeyState("Alt", "P") && GetKeyState("Shift", "P") && GetKeyState("Ctrl", "P") && GetKeyState("3", "P"))
	{
	TrayTip TTR Tools,"Trampoline bot stopped by hotkey", 1,32
	trampRunning := false
	;GoSub, setStatus
	GuiControl,,txt, Trampoline bot graph will plot when running
	GuiControl, Show, textAFK
	GuiControl, Show, timeAFK
	GuiControl, Show, timeAFKUD
	break
	} 
	;PixelSearch, Px, Py, 5, 451, 65, 459, 0xEFEFEF, 10 Fast RGB
	;if(width != winWidth || height != winHeight)
	if(elapsedtime > 4400)
	{
			color := 0xEFEFEF
			variance := 12
			highestPy := 451
	}
	else if(elapsedtime > 3000)
	{
			color := 0xEFEFEF
			variance := 23
			highestPy := 451
	}
	else if(elapsedtime > 1000)
	{
		color := 0xEFEFEF
		variance := 35
		highestPy := 451
	}
	else
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
		if(prevStrength == 0)
		{
				PixelGetColor, purp, 25,469, RGB
				dist := RGB_Euclidian_Distance(purp,0x8d519a)
				if(dist < 25)
				{
					_starttime := A_TickCount
					prevStrength := 1
				}
				else
					prevStrength:= 0
		}
		if(looped && count > 10 && prevStrength > 0)
		{
		elapsedtime := A_TickCount - _starttime
				;OutputDebug %count% color %color% variance %variance% pixel %highestPy% distance %bunceD%, lag %elapsedtime%
			prevStrength := count
			XGraph_Plot(pGraph,310-(elapsedtime*0.0596153846))
			GuiControl,,txt, Variance %variance%, Strength %count%, Time %elapsedtime%
			count := 0
			_starttime := A_TickCount 
			XGraph_Plot(vGraph,40-variance)
			ControlSend,, {Ctrl},ahk_id %active_id%
			;SendInput {Ctrl}
			looped := false
		}
		;OutputDebug ayy
	}
	else
	{
		if(count > 340)
		{
			IfWinExist, Toontown Rewritten [BETA]
			{
				WinGetPos,winX,winY,curWidth,curHeight
				if(curWidth != width || curHeight != height)
					WinMove, Toontown Rewritten [BETA], , ,  , width, height
			}
			else
			{
				TrayTip TTR Tools, "Toontown Application not open", 1, 1
				GuiControl,,txt, Toontown not open
				trampRunning := false
				goSub setStatus
				GuiControl, Show, textAFK
				GuiControl, Show, timeAFK
				GuiControl, Show, timeAFKUD
				return
			}
			if(repeat)
			{
				PixelGetColor, purp, 25,469, RGB
				dist := RGB_Euclidian_Distance(purp,0x8d519a)
				if(dist > 25)
				{
					prevStrength:= 0
					GuiControl,,txt, Jump Bar not detected. Don't resize TT or tab out. Disable Flux
					PixelGetColor,okbtn,400,450 RGB
					okbDist := RGB_Euclidian_Distance(okbtn,0x50CC22)
					if(okbDist < 30)
					{
						count := 0
						prevStrength:= 0
						MouseGetPos, mouseX, mouseY
						if((mouseX >= 0 && mouseX <= 816) && (mouseY >= 0 && mouseY <= 639))
							MouseMove, 400, 450
						ControlClick, x400 y450,ahk_id %active_id%,,,2, NA
						ControlSend,, {Down DOWN},ahk_id %active_id%
						Sleep 800
						ControlSend,, {Down UP},ahk_id %active_id%=
						Sleep 1400
						IfWinExist, Toontown Rewritten [BETA]
						WinActivate
						PixelGetColor,playbtn,726,593 RGB
						bDist := RGB_Euclidian_Distance(playbtn,0x00b714)
						if(bDist < 35)
						{
							MouseGetPos, mouseX, mouseY
							if((mouseX >= 0 && mouseX <= 816) && (mouseY >= 0 && mouseY <= 639))
							MouseMove, 726, 593
							ControlClick, x726 y593,ahk_id %active_id%,,,4, NA
						}
						else
						{
							Sleep 1000
							PixelGetColor,playbtn,726,593 RGB
							bDist := RGB_Euclidian_Distance(playbtn,0x00b714)
							if(bDist < 35)
							{
								ControlClick, x726 y593,ahk_id %active_id%,,,4, NA
							}
						}
					}
				}
			}
		}
		looped :=true
	}
}
trampRunning := false
goSub, setStatus
GuiControl,,txt, Trampoline bot graph will plot when running
GuiControl, Show, textAFK
GuiControl, Show, timeAFK
GuiControl, Show, timeAFKUD
;Menu Tray, Icon, def.ico
;OutputDebug Stopped
return