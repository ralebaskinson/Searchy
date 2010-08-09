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

Settings()
{
	global
	IfWinExist, ahk_id %SettingsID% ; If the settings window is already open, then activate it
	{
		WinActivate
		Return
	}
	If(addingInput=1)
	{
		Msgbox,, Searchy: Error, An input is being added. Please try again after a few seconds.
		Return
	}
	FileCopy, config.ini, config.ini.backup, 1
	Gui, 2:Default
	Gui, Add, Text,, Searchy v0.1
	Gui, Add, Tab2, h250 w280, Websites|General
	Gui, Tab
	; Add OK and Cancel buttons which are displayed in all tabs
	Gui, Add, Button, x150 y+20 w60 Default, &OK
	Gui, Add, Button, x+20 w60	, &Cancel
	
	Gui, Tab, 1
	Gui, Add, Text, Section, Input:
	; Add the first input by default
	Gui, Add, Listbox, h180 w80 Sort gModify vChoice HwndListboxHwnd +AltSubmit
	; Add the inputs
	Loop, % max-1
		GuiControl,, Choice, % input%A_Index%
	GuiControl, Choose, Choice, |1 ; Choose the first input
	Gui, Add, Text, ys, Output:
	Gui, Add, Edit, w160 r3 voutput gModify
	Gui, Add, Button, w25 Section, +
	Gui, Add, Button, w25 ys, -
	Gui, Add, Button, w60 xs, &Edit input
	
	Gui, Tab, 2
	Gui, Add, Text,, Browser:
	Gui, Add, DropDownList, vBrowser gModify Sort, Default|Other
	; Add the following browsers to the DropDownList based on if their default installation path exists
	IfExist, % A_ProgramFiles . "\Mozilla Firefox\firefox.exe"
		GuiControl,, Browser, Mozilla Firefox
	EnvGet, user, UserProfile
	IfExist, % user . "\AppData\Local\Google\Chrome\Application\chrome.exe"
		GuiControl,, Browser, Google Chrome
	IfExist, % A_ProgramFiles . "\Opera\opera.exe"
		GuiControl,, Browser, Opera
	IfExist, % A_ProgramFiles . "\Apple\Safari\safari.exe"
		GuiControl,, Browser, Safari
	IfExist % A_ProgramFiles . "\Internet Explorer\iexplore.exe"
		GuiControl,, Browser, Internet Explorer
		
	GuiControl, ChooseString, Browser, %Browser%

	Gui, Add, Text, y+20, Hotkey:
	Gui, Add, Hotkey, Limit 1 w100 gModify vHotkeynew Section, %Hotkey%
	IfInString, Hotkey, # ; Disable the Hotkey box if the hotkey contains the Windows key, since it does not support the Windows key
	{
		HotkeyDisabled=1
		GuiControl, Disable, Hotkeynew
	}
	Gui, Add, Button, w120 ys x+30, &Manually edit hotkey
	Gui, Add, Checkbox, Checked%taskbar% xs y+20 vtaskbar gModify, Show taskbar icon
	Gui, Add, Checkbox, Checked%startup% vstartup gModify, Run on system startup
	Gui, Add, Checkbox, Checked%quasimodal% vquasimodal gModify, Quasimodal
	Gui, Add, Checkbox, Checked%update% vupdate gModify, Check for updates on startup
	Gui, Show,, Searchy: Settings
	GuiControl, Focus, Choice ; Put focus on the Listbox
	
	SettingsID:=WinExist("A") ; Get the ID of the window so that it can be used to check later whether the window exists
}