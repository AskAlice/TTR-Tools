#Include Gui.ahk
SendMode Input
checkWindowTP(byref active_id){
width := 816
height := 639
outputDebug, windowName %windowName%
WinGet id, ID, %windowName%
active_id := id
IfWinExist %windowName%
	{
		WinActivate ; use the window found above
		WinGetPos,winX,winY,curWidth,curHeight
		if(curWidth != width || curHeight != height)
			WinMove, %windowName%, , ,  , width, height
		return true
	}
	else{
		TrayTip TTR Tools, "Toontown Application not open", 1, 1
		guiText("txt", "Toontown not open")
		return false
	}
}

safeClickTP(x,y){
	checkWindowTP(active_id)
	MouseGetPos, mouseX, mouseY
	MouseMove, x, y
	sleep,25
	ControlClick,X%x% Y%y%,ahk_id %active_id%,,,1, NA
	ControlSend,, {Ctrl},ahk_id %active_id%
}
tpClick(x, y){
	OutputDebug checking window
checkWindowTP(active_id)
OutputDebug window checked %windowName%
PixelGetColor,bookOpenCheck,40,315, RGB
bookDist := RGB_Euclidian_Distance(bookOpenCheck,0x0D2666)
if(bookDist > 5)
	safeClickTP(780,595)
Sleep, 170
safeClickTP(685,180)
safeClickTP(x,y)
}
F5::
InputBox, uReqq, Teleport to:, Please enter the location you wish to teleport to.,,315,130
if ErrorLevel
    return
else {
	StringLower uReq, uReqq
	if(uReq == "aa" || RegExMatch(uReq,"(acorn)") || RegExMatch(uReq,"(acres)")  || RegExMatch(uReq,"(chip)")) || RegExMatch(uReq,"(dale)"){
		;Chip & Dale's Acorn Acres
		tpClick(465,420)
		return
	}
	if(uReq == "bbhq" || RegExMatch(uReq,"(boss)")){
		;Bossbot HQ
		tpClick(610,415)
		return
	}
	if(uReq == "cbhq" || RegExMatch(uReq,"(cash)")){
		;Cashbot HQ
		tpClick(212,131)
		return
	}
	if(uReq == "dd" || RegExMatch(uReq,"(dock)")){
		;donald's dock
		tpClick(585,300)
		return
	}
	if(uReq == "ddl" || RegExMatch(uReq,"(dream)")){
		;Donald's Dreamland
		tpClick(383,152)
		return
	}
	if(uReq == "dg"  || RegExMatch(uReq,"(gardens)")  || RegExMatch(uReq,"(daisy)")) {
		;daisy gardens
		tpClick(325,395)
		return
	}
	if(uReq == "e" || uReq == "estate" || uReq == "home"){
			;estate
			tpClick(450,495)
			return
	}
	if(uReq == "gs" || RegExMatch(uReq,"(speedway)") || RegExMatch(uReq,"(goofy)")){
		;Goofy Speedway
		tpClick(256,280)
		return
	}
	if(uReq == "lbhq" || RegExMatch(uReq,"(law)")){
		;Lawbot HQ
		tpClick(620,128)
		return
	}
	if(uReq == "mml" || RegExMatch(uReq,"(minnie)") || RegExMatch(uReq,"(melodyland)")){
		;Minnie's Melodyland
		tpClick(445,240)
		return
	}
	if(uReq == "p" ||  RegExMatch(uReq,"(play)")){
		;Playground
		tpClick(575,485)
		return
	}
	if(uReq == "sbhq" || RegExMatch(uReq,"(sell)")){
		;Sellbot HQ
		tpClick(210,420)
		return
	}
	if(uReq == "ttc" || RegExMatch(uReq,"(central)") || || RegExMatch(uReq,"(toontown)")){
		;Toontown Central
		tpClick(415,305)
		return
	}
	MsgBox, ,TTR-Tools,No locations found.
}
return