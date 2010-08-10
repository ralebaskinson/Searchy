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

Startup()
{
	global
	SetWorkingDir, %A_ScriptDir%
	If(A_IsCompiled!=1)
		Menu, Tray, Icon, Searchy.ico
	; Create the config file if it doesn't exist
	IfNotExist, config.ini
	{
		FileAppend,
		(
			Searchy v%versionNumber%`nDo not modify this file unless you know what you are doing.`nTo apply any changes made directly to this configuration file, Searchy needs to be restarted.`n
		), config.ini
		IniWrite, a, config.ini, Input, 1
		IniWrite, g, config.ini, Input, 2
		IniWrite, go, config.ini, Input, 3
		IniWrite, w, config.ini, Input, 4
		IniWrite, y, config.ini, Input, 5
		FileAppend, `n, config.ini
		IniWrite, http://www.answers.com/TEST, config.ini, Output, 1
		IniWrite, http://www.google.com/search?q=TEST, config.ini, Output, 2
		IniWrite, TEST, config.ini, Output, 3
		IniWrite, http://en.wikipedia.org/wiki/Special:Search?search=TEST, config.ini, Output, 4
		IniWrite, http://www.youtube.com/results?search_query=TEST, config.ini, Output, 5
		FileAppend, `n, config.ini
		IniWrite, Default, config.ini, Settings, Browser
		IniWrite, ^space, config.ini, Settings, Hotkey
		IniWrite, 1, config.ini, Settings, Show taskbar icon
		IniWrite, 0, config.ini, Settings, Run on system startup
		IniWrite, 0, config.ini, Settings, Quasimodal
		IniWrite, %A_Space%, config.ini, Settings, Path to browser
		IniWrite, 1, config.ini, Settings, Check for updates on startup
	}
	; Load the configuration into RAM
	IniRead, Browser, config.ini, Settings, Browser
	If(Browser!="Default")
	{
		IniRead, PathToBrowser, config.ini, Settings, Path to browser
		IfNotExist, %PathToBrowser%
			Msgbox,, Searchy: Error, The path to the browser "%PathToBrowser%" does not exist. Please modify the settings accordingly.
	}
	
	IniRead, taskbar, config.ini, Settings, Show taskbar icon
	If(taskbar=0)
		Menu, Tray, NoIcon
	Else
	{
		Menu, Tray, Icon
		Menu, Tray, NoStandard
		Menu, Tray, Add, Settings, settings
		Menu, Tray, Add, Exit, Exit
	}
	
	IniRead, startup, config.ini, Settings, Run on system startup
	IfExist, % A_Startup . "\Searchy.lnk"
		Temp=1
	Else
		Temp=0
	If(startup=1&&Temp=0) ; If the startup link does not exist but startup is 1, create the shortcut
		FileCreateShortcut, %A_ScriptFullPath%, % A_Startup . "\Searchy.lnk"
	If(startup=0&&Temp=1) ; If the startup link exists but startup is 0, delete the shortcut
		FileDelete, % A_Startup . "\Searchy.lnk"
	
	IniRead, quasimodal, config.ini, Settings, Quasimodal
	If(quasimodal=1)
		Hotkey, CapsLock, Search, On
	; Load the inputs and outputs
	Loop
	{
		IniRead, input%A_Index%, config.ini, Input, %A_Index%
		if(input%A_Index%="ERROR") ; If the last input has been reached
		{
			input%A_Index%=
			max:=A_Index
			Break
		}
		IniRead, output%A_Index%, config.ini, Output, %A_Index%
	}
	IniRead, Hotkey, config.ini, Settings, Hotkey
	Hotkey, %Hotkey%, Search, On
	Menu, Searchy, Add, Settings, Settings
	Menu, Searchy, Add, Exit, Exit
	
	IniRead, update, config.ini, Settings, Check for updates on startup
	If(update=1)
		CheckForUpdates()
}

CheckForUpdates()
{
	global versionNumber
	URLDownloadToFile, http://github.com/ralebaskinson/Searchy/raw/master/Version.txt, LatestVersion.txt
	FileReadLine, latestVersion, LatestVersion.txt, 1
	FileDelete, LatestVersion.txt
	If(latestVersion>versionNumber)
	{
		IfMsgBox, Yes
		{
			If(PathToBrowser="")
				Run, "http://github.com/downloads/ralebaskinson/Searchy/v%currVersion%.zip"
			Else Run, "%PathToBrowser%" "http://github.com/downloads/ralebaskinson/Searchy/v%currVersion%.zip"
		}
	}
}