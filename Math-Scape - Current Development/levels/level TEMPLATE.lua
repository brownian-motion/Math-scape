local level = {}

local composer = require( "composer" )
local physics = require( "physics" )
local sprites = require( "sprites" )
local dusk = require( "Dusk.Dusk")

level.scene = composer.newScene("level1")

-- -----------------------------------------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called.
-- -----------------------------------------------------------------------------------------------------------------

-- local forward references should go here

-- -------------------------------------------------------------------------------

local pixelsPerMeter = globals.pixelsPerMeter["level1"]

-- "scene:create()"
function level.scene:create( event )

    local sceneGroup = self.view

    level.layer = { background = display.newGroup() , map = display.newGroup() , buttonGui = display.newGroup() };
    
    --
    --we need this so that the scene object has control of everything inside of it
    level.background = display.newRect( display.screenOriginX+display.actualContentWidth/2,display.screenOriginY+display.actualContentHeight/2, display.actualContentWidth, display.actualContentHeight )
    level.background:setFillColor(0.1,0.1,0.1)
    level.layer["background"]:insert(level.background)
    --]]

    --
    local map = dusk.buildMap("levels/Level1/level1.json");
    level.map = map;
    level.layer["map"] = map;
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
    
    

    --starts the physics so we can successfully add stuff. will be stopped at the end of create(), and started in show()
    --DO NOT add physics objects before this!
    physics.start();
    physics.setScale( pixelsPerMeter );

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
    local spriteSheet = graphics.newImageSheet( "assets/sprites/StickSprite.png", {width = 37, height = 50, numFrames = 2, sheetContentHeight = 50, sheetContentWidth = 74} )
    local sequenceData = {
        {name="walking left", frames={2}},
        {name="walking right", frames={1}},
        {name="standing left", frames={2}},
        {name="standing right", frames={1}},
    }   
    local sprite = display.newSprite( spriteSheet, sequenceData )
    level.sprite = sprite;
    physics.addBody(level.sprite, "dynamic", globals.playerPhysicsOptions)
    sprites.addTouchControls(level.sprite) --this adds :moveLeft(), :moveRight(), and :jump() to the sprite object
    map.layer["Foreground"]:insert(level.sprite)

    --sprite.x = display.contentWidth/2;
    --sprite.y = display.contentHeight/2 - 3*pixelsPerMeter;
    sprite.x = map.startLocation.x * map.data.tileHeight
    sprite.y = map.startLocation.y * map.data.tileHeight
    sprite:setSize(sprite, {height = 1.5*pixelsPerMeter})


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



    -- Initialize the scene here.
    -- Example: add display objects to "sceneGroup", add touch listeners, etc.
end


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
end 

--[[
--  <filename>.setupPhysics() will take a map imported from the Dusk engine,
--  will take the layer of tiles in the forground, and will add them as physical objects.
--]]
function level.setupPhysics( map )

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

    for index,value in ipairs(map.layer["Foreground"]) do
        physics.addBody(value, "static",  globals.platformPhysicsOptions);
        print("Adding physics to tile: Foreground: ("..index..": "..value..")")
    end
end

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
    --[[ --no longer needed; we'll just have them use their buttons
    if(event.x > display.contentWidth*(1-1/4)) then
        level.sprite:moveRight(event)
    elseif(event.x < display.contentWidth*1/4) then
        level.sprite:moveLeft(event)
    end
    --]]
    --print ( "touch at (" .. event.x .. ", " .. event.y .. ") with phase: " .. event.phase)
    if(event.phase == "ended") then 
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

        print ( "touch-based tap at (" .. event.x .. ", " .. event.y .. ") with phase: " .. event.phase)
    end

    return true;
end


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


-- -------------------------------------------------------------------------------

-- Listener setup

level.scene:addEventListener( "create", level.scene )
level.scene:addEventListener( "show", level.scene )
level.scene:addEventListener( "hide", level.scene )
level.scene:addEventListener( "destroy", level.scene )

-- -------------------------------------------------------------------------------

return level