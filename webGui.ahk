
SendMode Input

#Include Webapp.ahk
__Webapp_AppStart:
;<< Header End >>


;Get our HTML DOM object
iWebCtrl := getDOM()

;Change App name on run-time
setAppName("TTR Tools Web GUI Beta")


; Our custom protocol's url event handler
app_call(args) {
	MsgBox %args%
	if InStr(args,"msgbox/hello")
		MsgBox Hello world!
	else if InStr(args,"soundplay/ding")
		SoundPlay, %A_WinDir%\Media\ding.wav
}


; function to run when page is loaded
app_page(NewURL) {
	wb := getDOM()
	
	if InStr(NewURL,"index.html") {
		Sleep, 10
		x := wb.document.getElementById("ahk_info")
		x.innerHTML := "<i>Webapp.ahk is currently running on " . GetAHK_EnvInfo() . ".</i>"
	}
	OutputDebug Starting
	;SetTimer updateToggles, 1500
}
sendJS(js) {
wb := getDOM()
try wb.Navigate("javascript:" . js)
catch e{
OutputDebug error %e%
}
}
; Functions to be called from the html/js source
/*gardenLabel = startGarden
trampolineLabel = startTrampoline
afkLabel = startAFK
switchTo(mode){
	OutputDebug test %mode%
	if(mode == "t")
	{
		if(!looping)
			startTrampoline()
		else
			exitTrampoline()
			sleep, 500
	}
	if(mode =="a")
	{
		if(!toggle)
			startAFK()
		else
			toggleAFK()
			sleep, 500
	}
	if(mode == "g")
	{
		if(!gardening)
			startGarden()
		else
			exitGardening()
			sleep, 500
	}
}
*/
documentReady(){

}
updateToggles(afk,tram,gard){
	wb := getDOM()
	sendJS("clearStatus();")
	sleep, 50
	if(afk && wb.Document.getElementById("afk-switch").checked != afk)
	{
			sendJS("updateStatus('a', true)")
		OutputDebug Updated AFK
	}else if(tram && wb.Document.getElementById("trampoline-switch").checked != tram)
	{
			sendJS("updateStatus('t', true)")
			OutputDebug Updated Trampoline %afk% %tram%
	}else
	if(gard && wb.Document.getElementById("garden-switch").checked !=gard)
	{
		sendJS("updateStatus('g', true)")
	}
sleep, 50
}
updateSetting(setting,value){
	OutputDebug ran s,%setting%v,%value%
	if(setting == "water"){
	;Times to water, adjust as your bucket upgrades.
		if(value is digit)
		{
			MsgBox Value is %value%
		}
		else
			sendJS("alert('Not a number! Error!')")
	}
	if(setting == "replant"){
	;Replant plants (boolean) - True = destroy plant and plant new, False = just water plant and move on
		if(value != "0" && value != 0 && value != "false")
		{
		 GuiControl,TTRTools:,replant,1
		}
		else
		GuiControl,TTRTools:,replant,0
	}	
	if(setting == "interval"){
	;AFK Interval (minutes)
		if(value is digit)
		{
			global timeAFK
			global timeAFKUD
			GuiControl,TTRTools:,timeAFK,%value%
			GuiControl,TTRTools:,timeAFKUD,%value%
		}
		else
			sendJS("alert('Not a number! Error!')")

	}
	if(setting == "repeat"){
	;Repeat Trampoline bot (full auto)
	OutputDebug repeat
		if(value != "0" && value != 0 && value != "false")
		{
		 MsgBox,,, "It's True!"
		}
		else
		MsgBox,,, "It's False!"
	}
}
Hello() {
	MsgBox Hello from JS_AHK :)
}
Run(t) {
	Run, %t%
}
GetAHK_EnvInfo(){
	return "AutoHotkey v" . A_AhkVersion . " " . (A_IsUnicode?"Unicode":"ANSI") . " " . (A_PtrSize*8) . "-bit"
}
Multiply(a,b) {
	;MsgBox % a " * " b " = " a*b
	return a * b
}
MyButton1() {
	wb := getDOM()
	MsgBox % wb.Document.getElementById("MyTextBox").Value
}
MyButton2() {
	wb := getDOM()
	FormatTime, TimeString, %A_Now%, dddd MMMM d, yyyy HH:mm:ss
    Random, x, %min%, %max%
	data := "AHK Version " A_AhkVersion " - " (A_IsUnicode ? "Unicode" : "Ansi") " " (A_PtrSize == 4 ? "32" : "64") "bit`nCurrent time: " TimeString "`nRandom number: " x
	wb.Document.getElementById("MyTextBox").value := data
}