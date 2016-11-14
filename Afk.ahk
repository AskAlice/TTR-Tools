#Include XGraph.ahk
enableFeatureAFK= true
#Include Gui.ahk
!+1:: 
gosub, runAFK
return

startAFK(){
	OutputDebug TEST
gosub, runAFK
}
toggleAFK(){
	OutputDebug TEST
gosub, toggleAFK
}
runAFK:
if(!trampRunning && !gardening)
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
	TrayTip TTR Tools, "Anti AFK Started", 1
	guiText("txt","AFK Running. Triggers shown in spikes in lower graph")
	XGraph_Detach(vGraph) 
	global sentLast := false
	vGraph := XGraph( vGraphv, 0x83A654, 1, "0,5,0,5", 0xFAFAFA,2)
	Gosub, Afk
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
	sendJS("updateConsole('Anti AFK events will be logged here.', '#afk-console', 'clear')")
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
			sendJS("plotAFK(30);")		
			TrayTip TTR Tools, "AFK Sent", 1
			global sentLast := false
	}
	else
	{
			XGraph_Plot(vGraph,29)
				sendJS("plotAFK(3);")		
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
if((trampolineRunning || gardening) && toggle)
{
gosub, toggleAFK
return
}
	WinGet active_id, ID, Toontown Rewritten [BETA]
	if(toggle)
	{
			FormatTime, TimeString,, h:mm:ss
			GuiText("txt", "Triggered Anti-AFK at " . TimeString)
			ControlSend,,{Ctrl DOWN},ahk_id %active_id%
			sleep 60
			ControlSend,,{Ctrl UP},ahk_id %active_id%
			;OutputDebug  Anti-AFK Run
			global sentLast := true
	}
return