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

CheckInput(input)
{
	global
	If(input="")
	{
		MsgBox,, Searchy: Error, The input cannot be blank.
		Return "error"
	}
	If(input="set"||input="error"||input="caps")
	{
		Msgbox,, Searchy: Error, The input cannot be "%input%".
		Return "error"
	}
	Loop, % max-1 ; Check if the input already exists
	{
		If(input=input%A_Index%)
		{
			Msgbox,, Searchy: Error, The input %input% already exists.
			Return "error"
		}
	}
}