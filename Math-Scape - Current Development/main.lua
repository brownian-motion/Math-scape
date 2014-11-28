-- Copyright (C) 2012, 2013 OUYA, Inc.
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--    http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

--these are each tables produced by running each of the specified files, which return a table containing functions (or variables, in the case of globals.lua).
widget = require "widget"
globals = require "globals"
helpers = require "helpers"
inputs = require "inputs"
--ui = require "ui" --deleted: it was just a table and a return statement. We can make a new file for each menu
composer = require "composer"
menu = require "menu"
testScreenTwo = require "screenSwap"


--[[
--displays lines on the edges of the display (it's a way to check if the config is set correctly)
display.newLine( 	0,						0,						0,						display.contentHeight	).strokeWidth= 5
display.newLine(	0,						display.contentHeight ,	display.contentWidth,	display.contentHeight	).strokeWidth= 5
display.newLine(	display.contentWidth,	display.contentHeight ,	display.contentWidth,	0 						).strokeWidth= 5
display.newLine(	display.contentWidth,	0 ,						0,						0 						).strokeWidth= 5
]]--

--menu.buildScreen()
composer.gotoScene("menu")
--composer.loadScene("screenSwap")

-- Add the key event listener.
Runtime:addEventListener( "key", inputs.onKeyEvent )

-- Add the axis event listener.
Runtime:addEventListener( "axis", inputs.onAxisEvent )


local debug = display.newText({x=0,y=0,text="DEBUG",fontSize="22",align="left", width=display.contentWidth}) --it is neccesary to specify width in order for multi-line text to display properly on apple devices
debug.x = display.contentWidth/2
debug.y = display.contentHeight - debug.height/2
printToBuildConsole = print;
debug.isVisible = false
globals.debugConsole = debug

function print(text)
	text = tostring(text);
	if(debug.contentHeight > display.contentHeight) then
		debug.text = debug.text:sub(debug.text:find("\n")+1).."\n"..text;
	else
		debug.text = debug.text.."\n"..text
	end
	debug.x = display.contentWidth/2
	debug.y = display.contentHeight - debug.height/2
	printToBuildConsole(text) --so that we can still see it in the editor
end

print("Debug console test")