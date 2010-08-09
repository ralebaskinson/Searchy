/*  
	Searchy v0.1 - Quickly search for information online
	Copyright (C) 2009, 2010 Rale Baskinson
	ralebaskinson@gmail.com
	
	This file is part of Searchy.

    Searchy is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Searchy is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Searchy.  If not, see <http://www.gnu.org/licenses/>.
	
*/

#SingleInstance force
#NoEnv
#NoTrayIcon
SendMode Input
DetectHiddenWindows, on
SetTitleMatchMode, 2

OnMessage(0x5031, "Exit")
Run, % A_IsCompiled=1 ? "Run\WaitKey.exe" : "Run\WaitKey.ahk"

Gui, Font, cWhite s20
Gui, Color, Black
Gui, +Disabled +AlwaysOnTop -Caption +ToolWindow
Gui, Add, Text, load, Loading...
Gui, Show, Y0 NoActivate, Searchy: loading
Gui +LastFound
WinSet, Transparent, 220
; Slowly fades loading window in and out
Loop
{
	Sleep, 1000
	Loop, 15
	{
		WinSet, Transparent, % 220-A_Index*10
		Sleep, 50
	}
	Loop, 15
	{
		WinSet, Transparent, % 70+A_Index*10
		Sleep, 50
	}
}
Return

Exit()
{
	PostMessage, 0x5032,,,, % A_IsCompiled=1 ? "Searchy.exe" : "Searchy.ahk"
	ExitApp
}