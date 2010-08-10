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

SubmitInput()
{
	global
	Gui, 1:Default
	Gui, Submit, NoHide
	SetTimer, FadeOut, -1 ; Run FadeOut in a new thread
	fullusrin:=usrin ; If the first character of the input is a space, using the traditional equal sign operator seems to delete it, so an expression operator is used here instead
	If(usrin="set")
	{
		Settings()
		Return
	}
	If(usrin="caps")
	{
		SetStoreCapslockMode, Off
		Send, {CapsLock}
		Return
	}
	copiedtext=%clipboard%
	pos:=RegExMatch(usrin, "[^,] ") ; Find the first space which does not contain a comma before it
	If(pos!=0)
	{
		clipboard:=SubStr(usrin, pos+2) ; If such a space is found, then set the clipboard to be the text after that space and then delete it from usrin
		StringTrimRight, usrin, usrin, StrLen(usrin)-pos
	}
	If(SubStr(usrin, 1, 1)=A_Space||usrin="") ; If the first character is a space or there is no input
		Gosub, Define
	Else
	{
		StringReplace, usrin, usrin, %A_Space%,, 1 ; Delete any remaining spaces
		StringReplace, clipboard, clipboard, this, %copiedtext%, 1 ; Replace "this" with the selected text
		StringSplit, usrin, usrin, `, ; Split the input whenever a comma is encountered
		; Run the output for each of those inputs
		Loop, %usrin0%
		{
			usrin:=usrin%A_Index%
			foundinput=0
			Loop
			{
				If(A_Index=max)
				{
					IfWinExist, ahk_id %SettingsID% ; If the settings window exists, do not ask to add the input since this could cause conflicts
						Msgbox,, Searchy: Input not found, The input %usrin% was not found.
					Else
					{
						Found:=RegExMatch(copiedtext, "^http:.*|[A-Z]:\\") ; Check if there is a web address or a file path selected, and automatically display this in the InputBox
						addingInput=1
						InputBox, output, Searchy: Input not found, % Found!=0 ? "The input " . usrin . " was not found. Do you wish to add it with the following output?" : "The input " . usrin . " was not found. Please enter the desired output.",, 350, 150,,,,, % Found!=0 ? copiedtext :
						If(ErrorLevel=0)
						{
							input=%usrin%
							AddInput()
						}
						addingInput=0
					}
					Break
				}
				If(usrin=input%A_Index%)
				{
					foundinput=1
					StringCaseSense, On
					StringReplace, output, output%A_Index%, TEST, %clipboard% ; Replace "TEST" with the contents of the clipboard
					;StringCaseSense does not need to be turned off since it is automatically set to default (off) when a new thread starts
					; If the user has chosen "Default" as the browser (which makes PathToBrowser blank), the script just runs the URL and the OS automatically opens it using the default browser
					Found:=RegExMatch(output, "^http:.*") ; Check if the output contains a web address
					If(Found=0||PathToBrowser="")
						Run, "%output%",, UseErrorLevel
					Else
						Run, "%PathToBrowser%" "%output%",, UseErrorLevel
					If(ErrorLevel="ERROR")
						Msgbox,, Searchy: Error, There was an error running %output%.
					Break
				}
			}
		}
	}
	clipboard=%Currclip% ; Restore the user's clipboard
}

Define:
Exit=0
Destroyed=0
Stop=0
URL=
If(usrin!="") ; If the input is not empty, then the text after the first space must be the term to search for
	clipboard:=SubStr(usrin, 2)
Else If(clipboard="") ; If both the clipboard and the input is blank, there is nothing to search for so display an error message
{
	Msgbox,, Searchy: Error, The search term cannot be blank.
	Return
}
Run, % A_IsCompiled=1 ? "Run\Loading.exe" : "Run\Loading.ahk"
UrlDownloadToFile, http://www.google.com/dictionary?sl=en&tl=en&q=%clipboard%, Temp.html
FileRead, download, Temp.html
FileDelete, Temp.html
StringGetPos, startpos, download, dct-em ; Find the definition by Google Dictionary
If(ErrorLevel=0)
{
	startpos:=startpos+69
	endpos:=RegExMatch(download, "</span>", "", startpos)
	length:=endpos-startpos
}
Else
{
	; If a Google Dictionary definition is not found, get the web definition
	StringGetPos, startpos, download, gls
	If(ErrorLevel=0)
	{
		startpos:=startpos+22
		StringGetPos, endpos, download, <br,, %startpos%
		; Get the URL from Google Dictionary on which the definition is based
		StringGetPos, URLstartpos, download, <a,, %startpos%
		StringGetPos, URLendpos, download, </a,, %URLstartpos%
		length:=endpos-startpos+1
		URLlength:=URLendpos-URLstartpos
		URL:=SubStr(download, URLstartpos, URLlength)
		URL:=RegExReplace(URL, "<.+?>|\n") ; Delete any HTML markup elements or linefeeds
	}
	Else
	{
		; The input was not found
		download=The search term "%clipboard%" could not be found.
		startpos=1
		length:=StrLen(download)
	}
}
download:=SubStr(download, startpos, length)
download:=RegExReplace(download, "<.+?>") ; Delete any HTML markup elements
Gui, 3:Default
Gui, Font, cWhite s20
Gui, Color, Black
Gui, Margin, 20
Gui, Add, Text, Center cWhite vtext, % URL="" ? download : download . "`nFrom: " . URL

GuiControlGet, text, Pos ; Get the size of the control
If(textw>A_ScreenWidth) ; If the size is greater than the width of the screen, recreate the control with the width of the screen
{
	Gui, Destroy
	Gui, Font, cWhite s20
	Gui, Color, Black
	Gui, Margin, 20
	width:=A_ScreenWidth-40
	Gui, Add, Text, Center cWhite W%width%, % URL="" ? download : download . "`nFrom: " . URL
}
Gui, +Disabled +AlwaysOnTop -Caption +ToolWindow
If(Stop=1) ; If the user has dismissed the Loading window, do not show the definition
	Return
; If not, delete the Loading window now
DetectHiddenWindows, on
SetTitleMatchMode, 2
PostMessage, 0x5031,,,, % A_IsCompiled=1 ? "Loading.exe" : "Loading.ahk"

Gui, Show, Y0 NoActivate, Searchy: define
WinSet, Transparent, 200, Searchy: define

; Destroy the window if the user moves the mouse or clicks the left mouse button
MouseGetPos, xstart, ystart
Sleep, 1000
download=
Loop
{
	IfWinNotExist, Searchy: define
		Return
	GetKeyState, MouseClicked, LButton
	MouseGetPos, x, y
	If(x!=xstart||y!=ystart||MouseClicked="D")
	{
		Loop, 10
		{
			WinSet, Transparent, % 200-A_Index*20, Searchy: define
			Sleep, 40
		}
		Gui, 3:Destroy
		Return
	}
	If(Exit=1)
		Return
	Sleep 200
}
Return