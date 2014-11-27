local composer = require( "composer" )
local physics = require( "physics" )
local sprites = require( "sprites" )
local dusk = require( "Dusk.Dusk")
--local lib_data = require( "Dusk.dusk_core.load.data" )

--initialize the level object
local level = {}
level.num = 1;
level.name = "level"..level.num;
--[[
level.properties = {};
local properties_filename = "levels/"..level.name.."/"..level.name.."-properties.json";
if(system.pathForFile( properties_filename )) then
    --if properties found:
    level.properties.filename = properties_filename;
    level.properties = lib_data.get(level.properties.filename);
    --helpers.print_traversal(level.properties); --debug
else
    --if there are no properties, set defaults:
    level.properties.filename = nil;
end
level.properties.startingMap = level.properties.startingMap or (level.name..".json");
print( level.properties.startingMap );
--helpers.print_traversal(level,"level");
--]]

level.scene = composer.newScene(level.name)

-- -----------------------------------------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called.
-- -----------------------------------------------------------------------------------------------------------------

-- local forward references should go here

-- -------------------------------------------------------------------------------

local pixelsPerMeter = globals.pixelsPerMeter[level.name]

-- "scene:create()"
function level.scene:create( event )

    local sceneGroup = self.view

    --starts the physics so we can successfully add stuff. will be stopped at the end of create(), and started in show()
    --DO NOT add physics objects before this!
    --
    physics.start();
    physics.setScale( pixelsPerMeter );
    --]]

    level.layer = { background = display.newGroup() , map = display.newGroup() , buttonGui = display.newGroup() };
    
    --
    --we need this so that the scene object has control of everything inside of it
    level.background = display.newRect( display.screenOriginX+display.actualContentWidth/2,display.screenOriginY+display.actualContentHeight/2, display.actualContentWidth, display.actualContentHeight )
    level.background:setFillColor(0.1,0.1,0.1)
    level.layer["background"]:insert(level.background)
    --]]

    local filepath = "levels/level1/level1 - princess room.json"
    local filepath2 = "level1 - princess room.json"
    print("File \""..filepath.."\" exists: "..tostring(helpers.resourceExists(filepath)))
    print("File \""..filepath2.."\" exists: "..tostring(helpers.resourceExists(filepath2)))
    local filepath3 = "level1.lua"
    local filepath4 = "main.lua"
    print("File \""..filepath3.."\" exists: "..tostring(helpers.resourceExists(filepath3)))
    print("File \""..filepath4.."\" exists: "..tostring(helpers.resourceExists(filepath4)))
    --
    --local map = dusk.buildMap("levels/"..level.name.."/"..level.properties.startingMap);
    local map = dusk.buildMap("levels/level1/level1 - princess room.json");
    level.map = map;
    level.layer["map"] = display.newGroup( )
    level.layer["map"]:insert(map);
    --]]
    --[[
    local mapScale = pixelsPerMeter/map.data.tileHeight; --one tile is one meter
    map:scale(mapScale,mapScale);
    map.updateView()
    --]]

    --[[
    local gameElements = display.newGroup()
    level.gameElements = display.newGroup()
    sceneGroup:insert(gameElements)
    --]]

    --buttons appear ABOVE the game
    local buttonGui = level.layer["buttonGui"]
    level.buttonGui = buttonGui

    sceneGroup:insert( level.layer["background"] )
    sceneGroup:insert( level.layer["map"] )
    sceneGroup:insert( level.layer["buttonGui"] )

    --gameElements:addEventListener("tap",level.scene) 
    level.layer["background"]:addEventListener("touch",level.scene)
    --this will call <filename>.scene:tap() every time anything (*including the background or display objects) is tapped
    --this is preferrable to Runtime:addEventListener in that we don't have to get rid of it when we're done; it only exists with this scene's sceneGroup
    --this is also the same reason we don't define it outside of this method
    
    --level.setupPhysics(map);

    level.backButton = widget.newButton{
        x = display.contentWidth/2, 
        y = display.contentHeight-100,
        --width = 400,
        --height = 100,
        id = "back",
        label = "Back",
        fontSize = 64,
        labelColor = { default={ 0, 0, 0, 1 }, over={ 0, 0, 0, 1 } },
        sheet = globals.buttonSheet,
        defaultFrame = 1,
        overFrame = 1,
        onEvent = function(event) if(event.phase == "ended") then composer.gotoScene("comingSoon") end return true; end,
    }
    buttonGui:insert(level.backButton)
    level.backButton:setFillColor(.5,.5,.9)


    --if( system.pathForFile("levels/StickSprite.png") == nil) then print "nil file" else print "good file" end
    --
    local spriteSheet = graphics.newImageSheet( "assets/sprites/princess.png", {width = 23, height = 35, numFrames = 22, sheetContentHeight = 70, sheetContentWidth = 253} )
    local sequenceData = {
        {name="standing left", frames={8}},
        {name="walking left", frames={12,13}, time=500, loopCount=0},
        {name="walking right", frames={1,2}, time=500, loopCount=0},
        {name="standing right", frames={19}},
        {name="jumping", frames={1,3,4,5,6,7}, time=750, loopCount=1, loopDirection="bounce"},
    }  --]] 
    --[[
    local spriteSheetRight = graphics.newImageSheet("assets/sprites/yasuko_sheet.png", {width=18,height=35,numFrames=2,sheetContentHeight=105,sheetContentWidth=128})
    
    local spriteSheetLeft = graphics.newImageSheet("assets/sprites/yasuko_sheet_left.png", {width=18,height=35,numFrames=2,sheetContentHeight=105,sheetContentWidth=128}) 
    local sequenceData = {
        {name="walking left", sheet=spriteSheetLeft, frames={3}},
        {name="walking right", sheet=spriteSheetRight, frames={2}},
        {name="standing left", sheet=spriteSheetLeft, frames={2}},
        {name="standing right", sheet=spriteSheetRight, frames={7}},
    }--]]
    --local sprite = display.newSprite( spriteSheetRight, sequenceData )

    --
    local sprite = display.newSprite( spriteSheet, sequenceData )
    level.sprite = sprite;
    local spritePhysicsOptions = table.copy(globals.playerPhysicsOptions)
    --
    sprite.simpleShape = {
         1/2,   -1/2,
         1/2,    1/2,
        -1/2,    1/2,
        -1/2,   -1/2,
    }--]]
    print( sprite.width .. " " .. sprite.height)
    sprites.addDisplayControls(sprite);
    sprite:setSize(sprite, {height = 1.2*pixelsPerMeter})
    spritePhysicsOptions.shape = sprite:getBoundingShape();
    --spritePhysicsOptions.shape = { 50,-50 , 50,50 , -50,50 , -50,-50};
    print( sprite.width .. " " .. sprite.height)
    print( (sprite.width * sprite.xScale) .. " " .. (sprite.height * sprite.yScale) )
    physics.addBody(sprite, "dynamic", spritePhysicsOptions)
    sprites.addTouchControls(sprite) --this adds :moveLeft(), :moveRight(), and :jump() to the sprite object
    sprite:assignControl("player");
    sprite.x,sprite.y = 100,100 --default, if initialization doesn't work
    level.initializeSpritePosition(map, sprite, map.startLocation)

    sprite:addEventListener( "preCollision", level.spritePreCollision )
    --]]
    --level.sprite = {play = function() print("play"); end}


    level.leftButton = widget.newButton{
        --parent = sceneGroup,
        x = 200, 
        y = display.contentHeight-100,
        --width = 400,
        --height = 100,
        id = "<--",
        label = "<--",
        fontSize = 64,
        labelColor = { default={ 0, 0, 0, 1 }, over={ 0, 0, 0, 1 } },
        sheet = globals.buttonSheet,
        defaultFrame = 1,
        overFrame = 1,
        onEvent = function(event) level.sprite:moveLeft(event) return true; end,
    }
    buttonGui:insert(level.leftButton)
    level.backButton:setFillColor(.5,.5,.9)


    level.rightButton = widget.newButton{
        --parent = sceneGroup,
        x = display.contentWidth -200, 
        y = display.contentHeight-100,
        --width = 400,
        --height = 100,
        id = "-->",
        label = "-->",
        fontSize = 64,
        labelColor = { default={ 0, 0, 0, 1 }, over={ 0, 0, 0, 1 } },
        sheet = globals.buttonSheet,
        defaultFrame = 1,
        overFrame = 1,
        onEvent = function(event) level.sprite:moveRight(event) return true; end,
    }
    buttonGui:insert(level.rightButton)
    level.backButton:setFillColor(.5,.5,.9)


    --physics.start( )
    --physics.addBody( level.sprite, "dynamic", {density=d, friction=f, bounce=b [,filter=f], } )

    --pauses physics so it's not running before stuff's on the screen.
    --DO NOT add physics objects after this!
    physics.pause();

    --level.printMapTraversal(map);
    --[[
    local transition = map.layer["Object Layer 1"].object.Transition;
    for key, value in pairs(transition) do
        print("Transition element "..key.." has type "..type(value));
    end
    print( "transition.x: "..transition.x.." - "..transition.x/map.data.tileHeight);
    print( "transition.y: "..transition.y.." - "..transition.y/map.data.tileHeight);
    print( "transition.width: "..transition.width.." - "..transition.width/map.data.tileHeight);
    print( "transition.height: "..transition.height.." - "..transition.height/map.data.tileHeight);
    local tx,ty = map.layer[3].pixelsToTiles(transition.x,transition.y);
    print( "transition tile location: ("..tx..", "..ty..")");
    print( "sprite.x: "..sprite.x.." - "..sprite.x/map.data.tileHeight);
    print( "sprite.y: "..sprite.y.." - "..sprite.y/map.data.tileHeight);
    local tx,ty = map.layer[2].pixelsToTiles(sprite.x,sprite.y);
    print( "sprite tile location: ("..tx..", "..ty..")");
    --]]

    -- Initialize the scene here.
    -- Example: add display objects to "sceneGroup", add touch listeners, etc.
end

--
function level.initializeSpritePosition( map , sprite, tileLocation)
    sprite = sprite or level.sprite;
    map = map or level.map;
    tileLocation = tileLocation or map.startLocation;
    map.layer["Midground"]:insert(sprite)
    sprite.layer = "Midground";

    --helpers.print_traversal(tileLocation, "tileLocation");
    
    --sprite.x = display.contentWidth/2;
    --sprite.y = display.contentHeight/2 - 3*pixelsPerMeter;
    --sprite.x = map.startLocation.x * map.data.tileHeight
    --sprite.y = map.startLocation.y * map.data.tileHeight
    sprite.x, sprite.y = map.layer["Midground"].tilesToPixels(tileLocation.x, tileLocation.y)
end
--]]


-- "scene:show()"
function level.scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    local sprite = level.sprite

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen).
        
    elseif ( phase == "did" ) then
        -- Called when the scene is now on screen.
        -- Insert code here to make the scene come alive.
        -- Example: start timers, begin animation, play audio, etc.
        physics.start()
        physics.setDrawMode("normal")
        system.activate( "multitouch" )
        sprite:play()
        Runtime:addEventListener( "enterFrame", level.gameLoop )
    end
end

function level.gameLoop( event )
    --return; --DEBUG
    --
    local sprite = level.sprite;
    local map = level.map;

    --update speed according to buttons being pressed
    local vx,vy = sprite:getLinearVelocity( )
        if( sprite.isMovingLeft ) then vx = -globals.horizontalRunSpeed;
    elseif( sprite.isMovingRight) then vx =  globals.horizontalRunSpeed;
    else vx =  0; --print("zero");
    end
    --    print( (sprite.isMoving and "sprite.isMoving " or "") .. (sprite.isMovingLeft and "sprite.isMovingLeft " or "") .. (sprite.isMovingRight and "sprite.isMovingRight " or ""));
    sprite:setLinearVelocity( vx, vy )

    --update camera position based on player position
    map.positionCamera(sprite.x,sprite.y);

    --[[
    local transition = map.layer["Object Layer 1"].object.Transition;
    if( sprite.x < (transition.x + transition.width/2) and sprite.x > (transition.x - transition.width/2)
        and sprite.y < (transition.y + transition.height/2) and sprite.y > (transition.y - transition.height/2)) then
        print("SUCCESS");
        print("sprite.x: "..sprite.x);
        print("sprite.y: "..sprite.y);
        print("object.x: "..transition.x);
        print("object.y: "..transition.y);
    end
    --]]
    --
    for name,object in pairs(map.layer["Object Layer 1"].object) do
        if( sprite.x < (object.x + object.width/2) and sprite.x > (object.x - object.width/2)
            and sprite.y < (object.y + object.height/2) and sprite.y > (object.y - object.height/2)) then
            --[[
            print("SUCCESS");
            print("sprite.x: "..sprite.x);
            print("sprite.y: "..sprite.y);
            print("object.x: "..object.x);
            print("object.y: "..object.y);
            print("object._name: "..object._name);
            print("object._type: "..object._type);
            --]]
            --print("object.to: "..object.to);
            --print("object.from: "..object.from);
            --print("sprite.layer: "..sprite.layer);
            if(object._type == "LayerSwap" and sprite.layer == object.from) then
                --map.layer[object.from]:remove(sprite);
                map.layer[object.to]:insert(sprite);
                
                --print("put sprite into layer "..object.to);
                sprite.layer = object.to;
            end
        end
    end
    --]]
end 

local lastx, lasty;
function level.spritePreCollision(event)
    local sprite = event.target
    local other = event.other
    --print("sprite.layer: "..sprite.layer)
    --if(other.layer) then print("other.layer.name: "..other.layer.name) end
    --if(other.tileX ~= lastx and other.tileY ~= lasty) then helpers.print_traversal(other); end
    if(other.tileX and other.tileY) then lastx,lasty = other.tileX,other.tileY; end
    if(other.layer and (other.layer.name ~= sprite.layer) and not (other.isLayerInsensitive or other.layer.isLayerInsensitive)) then
        event.contact.isEnabled = false; --disables this particular collision
    end
end

-- now made irrelevant by helpers.printTraversal
--[[
function level.printMapTraversal( map )

    print("Map has "..map.numChildren.." children.")

    for key, value in pairs(map.layer) do
        print("Map layer: "..key.." has size: "..table.getn(value));
    end

    for key, value in pairs(map) do
        print("Map element: "..key.." has type: "..type(value));
    end

    for index, value in ipairs(map) do
        print("Map element at index: "..index.." has type: "..type(value));
    end

    for key, value in pairs(map.data) do
        print("Map.data element: "..key.." has type: "..type(value));
    end

    for key, value in pairs(map.props) do
        print("Map.props element: "..key.." has type: "..type(value));
    end
end
--]]

--[[ --deprecated, now using :touch()
--if the player taps a part of the screen that isn't a button, this will make the player's sprite jump
function level.scene:tap( event )
    --if(event.x > display.contentWidth*(1-1/4) or event.x < display.contentWidth*1/4) then return; end
    print ( "tap at (" .. event.x .. ", " .. event.y .. ")");
    local tapText = display.newText{
        parent = self.view,
        text = "tap again",
        fontSize = 30,
        align = "left",
        x = event.x,
        y = event.y,
    }
    helpers.spriteFadeOut(tapText,1000)

    level.sprite:jump ( event );

    return true;
end
--]]

--if touching the side of the screen, this will make the player's sprite move towards that side
function level.scene:touch( event )
    local sprite = level.sprite;
    local map = level.map;
    --[[ --no longer needed; we'll just have them use their buttons
    if(event.x > display.contentWidth*(1-1/4)) then
        level.sprite:moveRight(event)
    elseif(event.x < display.contentWidth*1/4) then
        level.sprite:moveLeft(event)
    end
    --]]
    --print ( "touch at (" .. event.x .. ", " .. event.y .. ") with phase: " .. event.phase)
    if(event.phase == "ended") then
        --[[
        local tapText = display.newText{
            parent = self.view,
            text = "tap again",
            fontSize = 30,
            align = "left",
            x = event.x,
            y = event.y,
        }
        helpers.spriteFadeOut(tapText,1000)
        --]]
        local spriteShouldStillJump = true;
        --
        for name,object in pairs(map.layer["Object Layer 1"].object) do
            --assuming rectangular object:
        if( sprite.x < (object.x + object.width/2) and sprite.x > (object.x - object.width/2)
                and sprite.y < (object.y + object.height/2) and sprite.y > (object.y - object.height/2)) then
                if(object._type == "Door") then
                    level.enterDoor(object);
                    spriteShouldStillJump = false;
                    return true;
                end
            end
        end
        --
        if(spriteShouldStillJump) then level.sprite:jump ( event ); end;
        --]]
        print ( "touch-based tap at (" .. event.x .. ", " .. event.y .. ") with phase: " .. event.phase)
        
    end

    return true;
end

function level.scene:key( event )
    if(not level.sprite) then return false; end
    if(event.keyName == "right") then
        level.sprite:moveRight(event);
        return true;
    elseif(event.keyName == "left") then
        level.sprite:moveLeft(event);
        return true;
    elseif(event.keyName == "space") then
        level.sprite:jump(event);
        return true;
    elseif(event.keyName == "up") then
        level.sprite:jump(event);
        return true;
    end
    return false;
    --print("HELLO");
end

-- level.enterDoor( door ) executes the transition from the current map to the map
-- specified by the door, and moves the level's sprite to the specified location
--
-- currently, there is no accompanying animation
--
function level.enterDoor( door )
    local sprite = level.sprite;
    --local spriteDestination = door.toLocation or newMap.startLocation
    if(not(door.toMap) or door.toMap == "") then
        --staying in same map
        --spriteDestination = spriteDestination or {sprite.x,sprite.y}
    else
        --moving to another map
        local newMapData = dusk.loadMap("levels/"..level.name.."/"..door.toMap..".json");
        --helpers.print_traversal(newMapData,"map");
        print( door.toMap )
        --local newMapData = dusk.loadMap("levels/level1/"..door.toMap..".json");
        --local newMapData = dusk.loadMap("levels/level1/level1 - castle.json");

        local spriteDestination = (type(door.toLocation) == "table") and door.toLocation or ((type(newMapData.properties.startLocation) == "table") and newMapData.properties.startLocation or {x=0,y=0});
        local spriteDestinationDoor = nil;
        --if I'm trying to go to a specific door, then get that specific door from the map data
        if(door.toDoor and string.len(door.toDoor) > 0) then
            print("found a request for a door! Name: "..door.toDoor);
            for layerIndex,layer in ipairs(newMapData.layers) do
                if(not(spriteDestinationDoor) and layer.objects) then
                    for index,object in ipairs(layer.objects) do
                        print("Found an object: "..object.name);
                        if(object.name == door.toDoor) then
                            print("found the door!");
                            spriteDestinationDoor = object;
                            spriteDestination = {   x=(object.x + 0.5*object.width)/newMapData.stats.tileHeight,
                                                    y=object.y/newMapData.stats.tileHeight
                                                };
                            break;
                        end
                    end
                end
            end
        end

        helpers.print_traversal(spriteDestination,"spriteDestination");

        local newMap = dusk.buildMap( newMapData );
        level.map:destroy();  --take out the current map
        level.map = newMap;  --apply the current map
        level.layer["map"]:insert(newMap);
        level.initializeSpritePosition( newMap, sprite, spriteDestination )

        
    end
end
--]]
-- "scene:hide()"
function level.scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is on screen (but is about to go off screen).
        -- Insert code here to "pause" the scene.
        -- Example: stop timers, stop animation, stop audio, etc.
        Runtime:removeEventListener( "enterFrame", level.gameLoop )
        physics.pause()
        system.deactivate( "multitouch" )
    elseif ( phase == "did" ) then
        -- Called immediately after scene goes off screen.
    end
end


-- "scene:destroy()"
function level.scene:destroy( event )

    local sceneGroup = self.view

    -- Called prior to the removal of scene's view ("sceneGroup").
    -- Insert code here to clean up the scene.
    -- Example: remove display objects, save state, etc.
    physics.stop()
end


-- ------------------------------------------------------------------------------

-- Listener setup

level.scene:addEventListener( "create", level.scene )
level.scene:addEventListener( "show", level.scene )
level.scene:addEventListener( "hide", level.scene )
level.scene:addEventListener( "destroy", level.scene )

-- -------------------------------------------------------------------------------

return level