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
#SingleInstance Force
#NoEnv
SendMode Input

OnMessage(0x5032, "Stop")

versionNumber=0.1

Startup()
Return

#Include %A_ScriptDir%\Include
#Include Startup.ahk
#Include Settings.ahk
#Include SubmitInput.ahk
#Include AddInput.ahk
#Include CheckInput.ahk
#Include Wait.ahk

#MaxThreads 100
#MaxThreadsPerHotkey 100
Search:
Exit=1
Gui, 3:Destroy
PostMessage, 0x5031,,,, % A_IsCompiled=1 ? "Loading.exe" : "Loading.ahk"
IfWinExist, ahk_id %SearchID% ; If the search window is already open, then do not open another instance of it
	Return
Gui, 1:Default
; Store the current clipboard so it can be restored later
Currclip=%ClipboardAll%
; Empty the clipboard so that if the user has not selected anything, the search text will be empty
clipboard=
; Copy selection
Send, ^c
Gui, Font, s20
Gui, Add, Edit, r1 w150 vusrin, %fullusrin%
Gui, Color, Black
Gui, -Caption +ToolWindow
Gui, Show, X0 Y0, Searchy: search
SearchID:=WinExist("A") ; Get the ID of the window so that it can be used to check later whether the window exists
; Now add a default button which allows the user to press enter to submit
; But it is not displayed because the GUI has already been shown
; Also, do not allow the user to access it by pressing tab (since tab is used to achieve other things)
Gui, Add, Button, -Tabstop Default, OK
Loop
{
	IfWinNotActive, ahk_id %SearchID% ; Close the search window if the user has deactivated it
	{
		Gui, 1:Destroy
		Break
	}
	If(A_ThisHotkey="CapsLock") ; If the user used CapsLock to summon the search window, then close the window if the CapsLock button is released (quasimodal mode)
	{
		GetKeyState, caps, Capslock, P
		If(caps="U")
			GoSub, ButtonOK
	}
	Sleep 50 ; Add a small pause which the user won't notice, but will make sure the loop doesn't take up too much CPU
}
Return

GuiContextMenu:
If A_GuiEvent=RightClick
	Menu, Searchy, Show ; Show the menu on right-click
Return

GuiEscape:
Gui, Destroy
Return

FadeOut:
Loop, 5
{
	WinSet, Transparent, % 255-A_Index*51, Searchy: search
	Sleep, 40
}
Gui, 1:Destroy
Return

Stop()
{
	global
	Stop=1
	Return
}

ButtonOK:
SubmitInput()
Return

Settings:
Settings()
Return

Modify:
; Update any changes made to the settings immediately
If(A_GuiControl="Browser")
{
	GuiControlGet, Browser
	IniWrite, %Browser%, config.ini, Settings, Browser
	GoSub, BrowserPath
}
Else If(A_GuiControl="Choice")
{
	GuiControlGet, Choice
	GuiControl,, output, % output%Choice% ; Change the output field to match the input
}
Else If(A_GuiControl="Output")
{
	GuiControlGet, output
	output%Choice%=%output%
	IniWrite, % output%Choice%, config.ini, Output, %Choice%
}
Else If(A_GuiControl="Hotkeynew")
{
	GuiControlGet, Hotkeynew
	IniWrite, %Hotkeynew%, config.ini, Settings, Hotkey
	If(Hotkey!="")
		Hotkey, %Hotkey%, Search, Off
	If(Hotkeynew!="")
		Hotkey, %Hotkeynew%, Search, On
	Hotkey=%Hotkeynew%
}
Else If(A_GuiControl="taskbar")
{
	GuiControlGet, taskbar
	IniWrite, %taskbar%, config.ini, Settings, Show taskbar icon
	If(taskbar=0)
		Menu, Tray, NoIcon
	Else
	{
		; Add the icon if it does not already exist
		Menu, Tray, Icon
		Menu, Tray, NoStandard
		Menu, Tray, Add, Settings, settings
		Menu, Tray, Add, Exit, Exit
	}
}
Else If(A_GuiControl="startup")
{
	GuiControlGet, startup
	IniWrite, %startup%, config.ini, Settings, Run on system startup
	IfExist, % A_Startup . "\Searchy.lnk"
		Temp=1
	Else
		Temp=0
	If(startup=1&&Temp=0) ; If the startup link does not exist but the startup box is checked, create the shortcut
		FileCreateShortcut, %A_ScriptFullPath%, % A_Startup . "\Searchy.lnk"
	If(startup=0&&Temp=1) ; If the startup link exists but the startup box is unchecked, delete the shortcut
		FileDelete, % A_Startup . "\Searchy.lnk"
}
Else If(A_GuiControl="quasimodal")
{
	GuiControlGet, quasimodal
	IniWrite, %quasimodal%, config.ini, Settings, Quasimodal
	If(quasimodal=1)
		Hotkey, CapsLock, Search, On
	Else
		Hotkey, CapsLock, Search, Off
}
Else If(A_GuiControl="update")
{
	GuiControlGet, update
	IniWrite, %update%, config.ini, Settings, Check for updates on startup
}
Return

BrowserPath:
If(Browser="Default")
	PathToBrowser=
Else If(Browser="Mozilla Firefox")
	PathToBrowser:=A_ProgramFiles . "\Mozilla Firefox\firefox.exe"
Else If(Browser="Google Chrome")
	PathToBrowser:=A_AppData . "\Local\Google\Chrome\chrome.exe"
Else If(Browser="Opera")
	PathToBrowser:=A_ProgramFiles . "\Opera\opera.exe"
Else If(Browser="Safari")
	PathToBrowser:=A_AppData . "\Local\Google\Chrome\chrome.exe"
Else If(Browser="Internet Explorer")
	PathToBrowser:=A_ProgramFiles . "\Internet Explorer\iexplore.exe"
Else If(Browser="Other")
{
	Gui 2:+OwnDialogs
	InputBox, PathToBrowser, Searchy: Browser, Please enter the path to your browser of choice:,, 320, 140,,,,, %PathToBrowser%
	IfNotExist, %PathToBrowser%
	{
		Msgbox, 4, Searchy: Error, The path to the browser %PathToBrowser% does not exist. Do you want to add it anyways?
		IfMsgBox, No
			ErrorLevel=1
	}
	If(ErrorLevel=1) ; If the user cancelled the InputBox or answered no to the Msgbox above, restore the browser to the default values
	{
		IniRead, Browser, config.ini, Settings, Browser
		GuiControl, ChooseString, Browser, %Browser%
	}
}
IniWrite, %PathToBrowser%, config.ini, Settings, Path to browser
Return

2ButtonEditinput:
Gui 2:+OwnDialogs
InputBox, inputTemp, Searchy: Edit input, Please modify the input as required:,, 300, 140,,,,, % input%Choice%
If(ErrorLevel=0)
{
	Wait_Start() ; Create an overlay to say that it is loading
	input=%inputTemp%
	GuiControlGet, output
	StoreChoice=%Choice%
	error:=CheckInput(input) ; Check if the input is valid
	If(error="error")
		Return
	Gosub, DeleteInput
	Choice=%StoreChoice%
	AddInput()
	Control, Delete, %StoreChoice%,, ahk_id %ListboxHwnd% ; Remove the old input from the listbox
	GuiControl,, Choice, % input%StoreNum% ; Add the new input
	GuiControl, Choose, Choice, |%StoreNum% ; Select the new input
	Wait_Stop() ; Close the overlay
}
Return

2GuiEscape:
2ButtonCancel:
2GuiClose:
FileMove, config.ini.backup, config.ini, 1 ; Restore the backup file
Gui 2:Destroy
Startup() ; Reload all variables from config.ini
Return

DeleteInput:
num:=Choice+1
Loop, % max-num
{
	input%Choice%:=input%num%
	IniWrite, % input%Choice%, config.ini, Input, %Choice%
	output%Choice%:=output%num%
	IniWrite, % output%Choice%, config.ini, Output, %Choice%
	Choice++
	num++
}
max--
; Delete the last number
input%max%:=
IniDelete, config.ini, Input, %max%
output%max%:=
IniDelete, config.ini, Output, %max%
Return

2Button-:
Gui, 2:Default
Wait_Start() ; Create an overlay to show that it is loading
Control, Delete, %Choice%,, ahk_id %ListboxHwnd% ; Remove the input from the listbox
StoreChoice=%Choice%
Gosub, DeleteInput
If(StoreChoice=max)
	StoreChoice:=max-1
GuiControl, Choose, Choice, |%StoreChoice% ; Choose the next item (or the last item if the deleted item was the last)
Wait_Stop() ; Close the overlay
Return

2ButtonManuallyedithotkey:
Gui 2:+OwnDialogs
InputBox, Hotkeynew, Searchy: Hotkey, Please enter your desired hotkey:,, 250, 140,,,,, % Hotkeynew="" ? Hotkey : Hotkeynew
If(ErrorLevel=0)
{
	If(Hotkeynew="CapsLock")
	{
		MsgBox,, Searchy: Error, The hotkey cannot be CapsLock. This is reserved for quasimodal mode.
		Hotkeynew=%Hotkey%
		Return
	}
	IniWrite, %Hotkeynew%, config.ini, Settings, Hotkey
	If(Hotkey!="")
		Hotkey, %Hotkey%, Search, Off
	If(Hotkeynew!="")
		Hotkey, %Hotkeynew%, Search, On
	IfNotInString, Hotkeynew, # ; Enable or disable the Hotkey box based on whether there is a Windows key, since it does not support the Windows key
	{
		GuiControl,, Hotkeynew, %Hotkeynew%
		If(HotkeyDisabled=1)
		{
			HotkeyDisabled=0
			GuiControl, Enable, Hotkeynew
		}
	}
	Else
	{
		If(Hotkeynew!=Hotkey&&HotkeyDisabled!=1)
		{
			MsgBox,, Searchy, The box to edit your hotkey has been disabled because it does`nnot support the Windows key. Your hotkey will still be in effect.
			GuiControl,, Hotkeynew,
			GuiControl, Disable, Hotkeynew
			HotkeyDisabled=1
		}
	}
	Hotkey=%Hotkeynew%
}
Return

2ButtonOK:
Gui, Destroy
Return

2Button+:
Gui 2:+OwnDialogs
error=0
InputBox, input, Searchy: Add website, Please enter the input:,, 320, 140
If(ErrorLevel=0)
{
	error:=CheckInput(input)
	If(error="error")
		Return
	InputBox, output, Searchy: Add website, Please enter the output:,, 320, 140
	If(ErrorLevel=0)
	{
		Wait_Start() ; Create an overlay to say that it is loading
		AddInput()
		GuiControl,, Choice, % input%StoreNum% ; Add the new input
		GuiControl, Choose, Choice, |%StoreNum% ; Select the new input
		Wait_Stop() ; Close the overlay
	}
}
Return

Exit:
ExitApp