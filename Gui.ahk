#Include XGraph.ahk
toggle :=false
trampRunning :=false
if A_IsCompiled
{
  Menu, Tray, Icon, %A_ScriptFullPath%, -159
}
else
{
	Menu, Tray, Icon, def.ico
	Run, "C:\Program Files (x86)\Pandoc\pandoc.exe" README.md -o README.html
}
FileCreateDir,%A_AppData%\TTR-Tools\
FileInstall, README.html, %A_AppData%\TTR-Tools\README.html,1
FileInstall, style.html, %A_AppData%\TTR-Tools\style.html,1
FileInstall, README.html, %A_AppData%\TTR-Tools\README.html,1
Gui +AlwaysOnTop
Gui -DPIScale
Gui, Margin, 0, 0
Gui, Add, Text,h12 y5, Welcome to TTR Tools v1.0.1
Gui, font, s7
Gui, Add, Button, x+5 y0 ghelp, View Help
if(enableFeatureAFK || enableFeatureTrampoline)
{
	Gui, Add, Text, h15 x0, CTRL+ALT+SHIFT+
	if(enableFeatureAFK)
		Gui, Add, Text,vtxt2 h15 x+0, (1-AntiAFK)
	if(enableFeatureTrampoline)
		Gui, Add, Text, vtxt3 h15 x+0, (2-Trampoline) 
}
Gui, font,bold
Gui, font, 
	if(enableFeatureAFK || enableFeatureTrampoline)
	{
		Gui, Add, Text, x0 vstatusLabel, Status:
			if(enableFeatureAFK)
				Gui, Add, Text,x+3 vstatus, AntiAFK %toggle%
			if(enableFeatureTrampoline)
			Gui, Add, Text,x+3 vstatus2, Trampoline %trampRunning%
	}
	if(enableFeatureAFK || enableFeatureTrampoline)
{
	Gui, Add, Text, x0 vopts, Opts:
		if(enableFeatureTrampoline)
		{
			Gui, Add, checkbox,x+3 vspeedy gSave, Lagfix (>40)
			Gui, Add, checkbox,x+3 vrepeat Checked gSave, Repeat
		}
		if(enableFeatureAFK)
			{
				Gui, Add, Text, x+0 vtextAFK,| AFK Time (mins):
				Gui, Add, Edit, h16 x+3 vtimeAFK gSave number, 8
				Gui, Add, UpDown, vtimeAFKUD Range1-11, 8
		}
}
if(enableFeatureAFK || enableFeatureTrampoline)
{
	Gui, Add, Text,x0 vtxt w300 h15,Trampoline bot graph will plot when running
	if(enableFeatureTrampoline)
	{
		Gui, Add, Text, x0 w300 h310 hwndhGraph vGraph
		pGraph := XGraph( hGraph, 0x55daba, 5, "0,5,0,5", 0x649e90,5 )
	}
	Gui, Add, Text, x0 w300 h40 hwndvGraphv vvGraph
	vGraph := XGraph( vGraphv, 0x688443, 5, "5,5,5,5", 0x649e90,1 )
}
	Gui, Show,, TTR Tools
;if AFK label is created in current file (ie: if included in TTR-Tools)
AfkLabel = Afk
if(enableFeatureAFK)
{
	timeMS := timeAFK*60000
	SetTimer %AfkLabel%, %timeMS%
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
Save:	
	Gui, Submit, NoHide
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
	if(enableFeatureAFK || enableFeatureTrampoline)
	{
		if(enableFeatureAFK)
			GuiControl,,status,AntiAFK %toggle%
		if(enableFeatureTrampoline)
			GuiControl,,status2,Trampoline %trampRunning%
	}
return

;Debug information
^!+Home::
ListVars
return

helpGuiEscape:
helpGuiClose:
    Gui , help:Destroy
	return
GuiClose:		;close Gui to Exit
GuiEscape:		;press Esc to Exit
	ExitApp
	return