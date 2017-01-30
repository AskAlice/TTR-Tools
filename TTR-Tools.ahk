/*
TODO BEFORE 1.1.0 RELEASE:
Finish the webapp
Make sure the webapp works on compiled

*/
/*
Welcome to TTR Tools. 
To check version number, look in config.ahk and default-conf.ini
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
SetBatchLines, -1
if not A_IsAdmin
{
   Run *RunAs "%A_ScriptFullPath%"  ; Requires v1.0.92.01+
   ExitApp
}
Process, priority, , High

;Enable features for GUI to recognize
enableFeatureAFK := true
enableFeatureGarden:=true
#Include Afk.ahk
#include TrampolineBot.ahk
#Include Garden.ahk
#Include Teleport.ahk
#include Gui.ahk
F9::

return

;Anti AFK Hotkey
