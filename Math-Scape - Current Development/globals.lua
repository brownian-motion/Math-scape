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
-- globals.lua
--
-----------------------------------------------------------------------------------------

local helpers = require("helpers")

local globals = {}

globals.resetScores = {_2048=0, Tiles=0}
if helpers.fileExists("scores.json") then
	globals.highscores = helpers.loadTable("scores.json")
else
	globals.highscores = globals.resetScores
	helpers.saveTable(globals.highscores, "scores.json")
end


globals.buttonSheet = graphics.newImageSheet( "button.png" , { width = 400, height = 100, numFrames = 2,})

globals.platformPhysicsOptions = {density = 1,  friction = 1, bounce = 0}
globals.playerPhysicsOptions = {density = 1,  friction = 0, bounce = 0}

--units of METERS per second
globals.verticalJumpSpeed = 8; --should be positive. this is just magnitude; it'll get scalar direction later
globals.horizontalRunSpeed = 200;

globals.pixelsPerMeter = { default = 100, spriteTestLevel = 80, tileTestLevel = 32 , level1 = 40};

globals.DOOR_ENTRY_ANIMATION_DELAY = 2000; --2 seconds to enter door
globals.DOOR_EXIT_ANIMATION_DELAY = 1000; --1 second to enter the level from a door

--these are keys to use when accessing composer for the current level's name and number
globals.GET_CURRENT_LEVEL_NAME = "getCurrentLevelName"
globals.GET_CURRENT_LEVEL_NUMBER = "getCurrentLevelNumber"

return globals;