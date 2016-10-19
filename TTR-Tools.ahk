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
SetBatchLines, -1
if not A_IsAdmin
{
   Run *RunAs "%A_ScriptFullPath%"  ; Requires v1.0.92.01+
   ExitApp
}
Process, priority, , High



;Enable features for GUI to recognize
enableFeatureAFK := true
enableFeatureTrampoline := true
#include Gui.ahk


;Anti AFK Hotkey
#Include Afk.ahk
#include TrampolineBot.ahk