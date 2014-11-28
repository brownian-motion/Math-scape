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
-- inputs.lua
--
-----------------------------------------------------------------------------------------

globals = require "globals"
helpers = require "helpers"
composer = require "composer"

local inputs = {}

-- Called when an axis event has been received.
function inputs.onAxisEvent(event)
	--print("===== onKeyEvent ======")
	
    if event.device then
		--print( event.axis.descriptor .. ": Normalized Value = " .. tostring(event.normalizedValue) )
		--print("### device.descriptor = " .. tostring(event.device.descriptor))
		--print("### device.type = " .. tostring(event.device.type))
		--print("### device.productName = " .. tostring(event.device.productName))
		--print("### device.aliasName = " .. tostring(event.device.aliasName))
		--print("### device.androidDeviceId = " .. tostring(event.device.androidDeviceId))
		--print("### device.permanentStringId = " .. tostring(event.device.permanentStringId))
		--print("### device.canVibrate = " .. tostring(event.device.canVibrate))
		--print("### device.isConnected = " .. tostring(event.device.isConnected))
	else
		print("### device = nil")
		return false;
	end
	
	local index = 1
	
	if (tostring(event.device.descriptor) == "Joystick 1") then
		index = 1;
	elseif (tostring(event.device.descriptor) == "Joystick 2") then
		index = 2;
	elseif (tostring(event.device.descriptor) == "Joystick 3") then
		index = 3;
	elseif (tostring(event.device.descriptor) == "Joystick 4") then
		index = 4;
	end
	
	
		
    
	if (event.axis.number == 1) then
		--print("LX found")"
	end
	
	if (event.axis.number == 2) then
		--print("LY found")
	end
	
	if (event.axis.number == 4) then
		--print("RX found")
	end
	
	if (event.axis.number == 5) then
		--print("RY found")
	end
    --
	if (event.axis.number == 3) then
		--print("LT found")
	end
	
		if (event.axis.number == 6) then
		--print("RT found")
	end
	
	
--print("what=" .. tostring(event.axis.descriptor))
	
end

-- Called when a key event has been received.
function inputs.onKeyEvent(event)
	print("===== onKeyEvent ======")
	
    print("Key '" .. event.keyName .. "' has key code: " .. tostring(event.nativeKeyCode) .. " phase: " .. event.phase);
	
	if event.device then
		--print("### device.displayName = " .. tostring(event.device.displayName))
		--print("### device.descriptor = " .. tostring(event.device.descriptor))
		--print("### device.type = " .. tostring(event.device.type))
		--print("### device.productName = " .. tostring(event.device.productName))
		--print("### device.aliasName = " .. tostring(event.device.aliasName))
		--print("### device.androidDeviceId = " .. tostring(event.device.androidDeviceId))
		--print("### device.permanentStringId = " .. tostring(event.device.permanentStringId))
		--print("### device.canVibrate = " .. tostring(event.device.canVibrate))
		--print("### device.isConnected = " .. tostring(event.device.isConnected))
	else
		print("### device = nil")
		--return false;
	end

	--pass event to current scene
	--print "YO";
	local currentSceneName = composer.getSceneName( "current" )
	local currentScene = composer.getScene(currentSceneName);
	if(currentScene) then
		if(type(currentScene.key) == "function") then
			if(currentScene:key(event)) then return true; end --if(handled by scene) then return true
		elseif(type(currentScene.onKeyEvent) == "function") then
			if(currentScene:onKeyEvent(event) ) then return true; end --if(handled by scene) then return true
		else
			--if our scene doesn't have a listener
			print "CURRENT SCENE DOES NOT HAVE A KEY LISTENER";
		end
	else
		print "NO SCENE TO HANDLE KEY EVENT";
	end

	--default w/ back button
	if(event.keyName == 'back') then 
		composer.gotoScene( composer.getSceneName('last') );
	end

	--NOTHING SHOULD HAPPEN BELOW THIS MARK!!!
	
	local index = 1
	--[[
	if (tostring(event.device.descriptor) == "Joystick 1") then
		index = 1;
	elseif (tostring(event.device.descriptor) == "Joystick 2") then
		index = 2;
	elseif (tostring(event.device.descriptor) == "Joystick 3") then
		index = 3;
	elseif (tostring(event.device.descriptor) == "Joystick 4") then
		index = 4;
	end

	if(		event.keyName == "left"		) then
		if(		event.phase == "down") then
			--globals.player:applyLinearImpulse( -100, 0, globals.player.x, globals.player.y )
		elseif(	event.phase == "up") then

		end
	elseif(	event.keyName == "right"	) then
		if(		event.phase == "down") then
			--globals.player:applyLinearImpulse(  100, 0, globals.player.x, globals.player.y )
		elseif(	event.phase == "up") then

		end
	elseif(	event.keyName == "down"		) then
		if(		event.phase == "down") then
			--globals.player:applyLinearImpulse( 0,  100, globals.player.x, globals.player.y )
		elseif(	event.phase == "up") then

		end
	elseif(	event.keyName == "up"		) then
		if(		event.phase == "down") then
			--globals.player:applyLinearImpulse( -100, 0, globals.player.x, globals.player.y )
		elseif(	event.phase == "up") then

		end
	end
    
	--System Button / Pause Menu
    if (event.keyName == "menu") then
    	if (event.phase == "up") then
    		print ("menu button detected")
    	end
    end
    --]]
	
	return false
end

return inputs;