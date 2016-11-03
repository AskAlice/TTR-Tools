#Include XGraph.ahk
enableFeatureAFK= true
#Include Gui.ahk
!+1:: 
if(!trampRunning)
	gosub, toggleAFK
else
	TrayTip TTR Tools, Can't run AFK while Trampoline bot is running.
return

toggleAFK:
toggle := !toggle
if(toggle)
	{
	;Initialize Anti AFK
	Gosub, setStatus
	GuiControl, Disable, speedy
	GuiControl, Disable, repeat
	GuiControl, Enable, timeAFK
	GuiControl, Enable, timeAFKUD
	TrayTip TTR Tools, "Anti AFK Started", 1
	GuiControl,,txt, AFK Running. Triggers shown in spikes in lower graph
	XGraph_Detach(vGraph) 
	global sentLast := false
	vGraph := XGraph( vGraphv, 0x83A654, 1, "0,5,0,5", 0xFAFAFA,2)
	Loop, 30
	XGraph_Plot(vGraph,29)
	plotAFKTime := Round(timeMS/300)
	SetTimer, plotAFK, %plotAFKTIme%
	;Menu Tray, Icon, afk.ico
	}
else
	{
	;Quit Anti AFK
	Gosub, setStatus
	TrayTip TTR Tools, "Anti AFK Stopped", 1
	vGraph := XGraph_Detach(vGraph) 
	vGraph := XGraph( vGraphv, 0x688443, 5, "0,0,0,0", 0x649e90,1 )
	SetTimer plotAFK, off
	GuiControl, Enable, speedy
	GuiControl, Enable, repeat
	GuiControl, Enable, timeAFK
	GuiControl, Enable, timeAFKUD
	;Menu Tray, Icon, def.ico
	}
return

plotAFK:
;Sends Anti-AFK status to lower graph
if(toggle)
{
	if(sentLast == true)
	{
			XGraph_Plot(vGraph,0)
			global sentLast := false
	}
	else
	{
			XGraph_Plot(vGraph,29)
	}
}
else
{
	setTimer plotAFK, off
	vGraph := XGraph_Detach(vGraph) 
	vGraph := XGraph( vGraphv, 0x688443, 5, "0,5,0,5", 0x649e90,1 )
}
return

Afk:
;Runs on timer. CTRL+F for settimer
	WinGet active_id, ID, Toontown Rewritten [BETA]
	if(toggle)
	{
			ControlSend,,{Ctrl DOWN},ahk_id %active_id%
			sleep 60
			ControlSend,,{Ctrl UP},ahk_id %active_id%
			;OutputDebug  Anti-AFK Run
			global sentLast := true
	}
return