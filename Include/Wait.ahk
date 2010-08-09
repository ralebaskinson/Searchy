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

Wait_Start()
{
	global
	Gui, 4:+owner2
	Gui, 2:+Disabled ; Prevent the user from activating the settings window
	Gui, 4:Default
	Gui -Caption +Disabled Border
	Gui, Add, Text,, Please wait...
	Gui, Show
	Gui, 2:Default
}

Wait_Stop()
{
	global
	Gui, 2:-Disabled ; Re-enable the settings window
	Gui, 4:Destroy
}