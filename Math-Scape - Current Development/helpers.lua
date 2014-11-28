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
-- helpers.lua
--
-----------------------------------------------------------------------------------------

local helpers = {}
local json = require("json")

function helpers.print_traversal(object, head)
    if(not head) then print "\nTRAVERSAL START:"; end
    if(table.getn(object) > 100) then
        print( tostring(head) .. " is very long... not printing all items." );
        return;
    end
    for key,value in pairs(object) do
        print( (head and head or "") ..".".. key.." is type ".. type(value) .. ((type(value) == "number" or type(value) == "string")and (": "..value.."") or ""))
        if(type(value) == "table" and key ~= "_class" and key ~= "__index") then
            helpers.print_traversal(value, (head and (head..".") or "")..key)
        end
    end
end

function helpers.lerp(start, final, percent)
    return (1-percent)*start + (percent)*final;
end

function helpers.map(value, startMin, startMax, finalMin, finalMax)
    return ((value-startMin)/(startMax-startMin))*(finalMax-finalMin)+finalMin;
end

function helpers.tableContains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

function helpers.saveTable(t, filename)
    local path = system.pathForFile( filename, system.DocumentsDirectory)
    local file = io.open(path, "w")
    if file then
        local contents = json.encode(t)
        file:write( contents )
        io.close( file )
        return true
    else
        return false
    end 
end

function helpers.loadTable(filename)
    local path = system.pathForFile( filename, system.DocumentsDirectory)
    local contents = ""
    local myTable = {}
    local file = io.open( path, "r" )
    if file then
        -- read all contents of file into a string
        local contents = file:read( "*a" )
        myTable = json.decode(contents);
        io.close( file )
        return myTable 
    end
    return nil
end

function helpers.fileExists(fileName)
    local path = system.pathForFile( fileName, system.DocumentsDirectory )
    local exists = false

    if (path) then -- file may exist wont know until you open it
        local fileHandle = io.open( path, "r" )
        if (fileHandle) then -- nil if no file found
            exists = true
            io.close(fileHandle)
        end
    end

    return(exists)
end

function helpers.resourceExists(fileName)
    local path = system.pathForFile( fileName, system.ResourceDirectory )
    local exists = false

    if (path) then -- file may exist wont know until you open it
        local fileHandle = io.open( path, "r" )
        if (fileHandle) then -- nil if no file found
            exists = true
            io.close(fileHandle)
        end
    end

    return(exists)
end

--the following were used in the Virtual Controller exercise, but could still be useful:
--
helpers.updateSprite = function (spriteObj, x, y, xScale, yScale, alpha)
    spriteObj.x = x;
    spriteObj.y = y;
    spriteObj.xScale = xScale;
    spriteObj.yScale = yScale;
    spriteObj.alpha = alpha;
end

-- Fade out the sprite alpha over 500ms
helpers.spriteFadeOut = function (spriteObj, duration)
    spriteObj.alpha = 1;
    transition.to(spriteObj, { time=duration and duration or 500, alpha=0 })
end

-- Fade in the sprite alpha over 500ms
helpers.spriteFadeIn = function (spriteObj, duration)
    spriteObj.alpha = 0;
    transition.to(spriteObj, { time=duration and duration or 500, alpha=1 })
end

-- Auto fade the sprite based on the phase, fade In if down, fade out if up
helpers.spriteFadeAuto = function (phase, spriteObj, duration)
        if (phase == "down") then
            helpers.spriteFadeIn(spriteObj,duration)
        elseif (phase == "up") then
            helpers.spriteFadeOut(spriteObj,duration)        
        end
end

-- Invert auto fade the sprite based on the phase, fade In if up, fade out if down
helpers.spriteFadeAutoInv = function (phase, spriteObj, duration)
        if (phase == "up") then
            helpers.spriteFadeIn(spriteObj,duration)
        elseif (phase == "down") then
            helpers.spriteFadeOut(spriteObj,duration)        
        end
end --]]

return helpers;