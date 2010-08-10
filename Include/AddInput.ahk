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

AddInput()
{
	global
	num=2
	Loop, % max-1
	{
		If(input>input%A_Index%)
		{
			If(input<input%num%) ; If the input is next in order to input%A_Index% but comes before input%num% (which is the next input), then insert the input into here
			{
				StoreNum=%num%
				ShiftOneUp(num)
				num=%StoreNum%
				input%num%=%input%
				output%num%=%output%
				IniWrite, %input%, config.ini, Input, %num%
				IniWrite, %output%, config.ini, Output, %num%
				Return
			}
			Else If(A_Index=(max-1)) ; If the last input has been reached, and the new input is greater than that, add it as the last input
			{
				input%max%=%input%
				output%max%=%output%
				IniWrite, %input%, config.ini, Input, %max%
				IniWrite, %output%, config.ini, Output, %max%
				max++
				Return
			}
		}
		Else ; If the input is not next in alphabetical order to anything, then add it as the first input
		{
			ShiftOneUp(1)
			input1=%input%
			output1=%output%
			IniWrite, %input%, config.ini, Input, 1
			IniWrite, %output%, config.ini, Output, 1
			Return
		}
		num++
	}
}

ShiftOneUp(num)
{
	global
	count:=max-num
	numplus=%max%
	num:=max-1
	Loop, %count%
	{
		input%numplus%:=input%num%
		IniWrite, % input%numplus%, config.ini, Input, %numplus%
		output%numplus%:=output%num%
		IniWrite, % output%numplus%, config.ini, Output, %numplus%
		numplus--
		num--
	}
	max++
}