local spriteTestLevel = {}

local composer = require( "composer" )
local physics = require( "physics" )
local sprites = require( "sprites" )

spriteTestLevel.scene = composer.newScene("spriteTestLevel")

-- -----------------------------------------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called.
-- -----------------------------------------------------------------------------------------------------------------

-- local forward references should go here

-- -------------------------------------------------------------------------------

local pixelsPerMeter = globals.pixelsPerMeter["spriteTestLevel"]

-- "scene:create()"
function spriteTestLevel.scene:create( event )

    local sceneGroup = self.view
    
    local gameElements = display.newGroup()
    spriteTestLevel.gameElements = display.newGroup()
    sceneGroup:insert(gameElements)

    --buttons appear ABOVE the game
    local buttonGui = display.newGroup( )
    spriteTestLevel.buttonGui = buttonGui
    sceneGroup:insert(buttonGui)

    --gameElements:addEventListener("tap",spriteTestLevel.scene) 
    gameElements:addEventListener("touch",spriteTestLevel.scene) --no longer needed; also, it has a bug where touching still makes a tap event
    --this will call comingSoon.scene:tap() every time anything (*including the background or display objects) is tapped
    --this is preferrable to Runtime:addEventListener in that we don't have to get rid of it when we're done; it only exists with this scene's sceneGroup
    --this is also the same reason we don't define it outside of this method

    --we need this so that the scene object has control of everything inside of it
    spriteTestLevel.background = display.newRect( display.screenOriginX+display.actualContentWidth/2,display.screenOriginY+display.actualContentHeight/2, display.actualContentWidth, display.actualContentHeight )
    spriteTestLevel.background:setFillColor(0.1,0.1,0.1)
    gameElements:insert(spriteTestLevel.background)

    --starts the physics so we can successfully add stuff. will be stopped at the end of create(), and started in show()
    --DO NOT add physics objects before this!
    physics.start();
    physics.setScale( pixelsPerMeter );
    physics.setGravity( 0, 9.8);

    spriteTestLevel.backButton = widget.newButton{
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
    buttonGui:insert(spriteTestLevel.backButton)
    spriteTestLevel.backButton:setFillColor(.5,.5,.9)


    --if( system.pathForFile("levels/StickSprite.png") == nil) then print "nil file" else print "good file" end
    local spriteSheet = graphics.newImageSheet( "levels/StickSprite.png", {width = 37, height = 50, numFrames = 2, sheetContentHeight = 50, sheetContentWidth = 74} )
    local sequenceData = {
        {name="walking left", frames={2}},
        {name="walking right", frames={1}},
        {name="standing left", frames={2}},
        {name="standing right", frames={1}},
    }   
    spriteTestLevel.sprite = display.newSprite( spriteSheet, sequenceData )
    physics.addBody(spriteTestLevel.sprite, "dynamic", globals.playerPhysicsOptions)
    gameElements:insert(spriteTestLevel.sprite)

    sprites.addTouchControls(spriteTestLevel.sprite) --this adds :moveLeft(), :moveRight(), and :jump() to the sprite object


    local giantPlatform = display.newRect( sceneGroup, display.contentWidth/2, display.contentHeight/2 + 200, 800, 200 )
    physics.addBody(giantPlatform, "static", globals.platformPhysicsOptions )
    giantPlatform._type = "tile";
    spriteTestLevel.giantPlatform = giantPlatform;

    local sidePlatform1 = display.newRect( sceneGroup, display.contentWidth/2 + 400, display.contentHeight/2 + 100, 400, 100 )
    physics.addBody(sidePlatform1, "static", globals.platformPhysicsOptions )
    sidePlatform1._type = "tile";
    spriteTestLevel.sidePlatform1 = sidePlatform1;

    local sidePlatform2 = display.newRect( sceneGroup, display.contentWidth/2 - 400, display.contentHeight/2 + 100, 400, 100 )
    physics.addBody(sidePlatform2, "static", globals.platformPhysicsOptions )
    sidePlatform2._type = "tile";
    spriteTestLevel.sidePlatform2 = sidePlatform2;


    spriteTestLevel.leftButton = widget.newButton{
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
        onEvent = function(event) spriteTestLevel.sprite:moveLeft(event) return true; end,
    }
    buttonGui:insert(spriteTestLevel.leftButton)
    spriteTestLevel.backButton:setFillColor(.5,.5,.9)


    spriteTestLevel.rightButton = widget.newButton{
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
        onEvent = function(event) spriteTestLevel.sprite:moveRight(event) return true; end,
    }
    buttonGui:insert(spriteTestLevel.rightButton)
    spriteTestLevel.backButton:setFillColor(.5,.5,.9)


    --physics.start( )
    --physics.addBody( spriteTestLevel.sprite, "dynamic", {density=d, friction=f, bounce=b [,filter=f], } )

    --pauses physics so it's not running before stuff's on the screen.
    --DO NOT add physics objects after this!
    physics.pause();



    -- Initialize the scene here.
    -- Example: add display objects to "sceneGroup", add touch listeners, etc.
end


-- "scene:show()"
function spriteTestLevel.scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    local sprite = spriteTestLevel.sprite

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen).
        sprite:play()
        sprite.x = display.contentWidth/2;
        sprite.y = display.contentHeight/2 - 3*pixelsPerMeter;
        sprite:setSize(sprite, {height = 1.5*pixelsPerMeter})
    elseif ( phase == "did" ) then
        -- Called when the scene is now on screen.
        -- Insert code here to make the scene come alive.
        -- Example: start timers, begin animation, play audio, etc.
        physics.start()
        physics.setDrawMode("normal")
        system.activate( "multitouch" )
        physics.addBody(spriteTestLevel.giantPlatform, "static", globals.platformPhysicsOptions )
        physics.addBody(spriteTestLevel.sidePlatform1, "static", globals.platformPhysicsOptions )
        physics.addBody(spriteTestLevel.sidePlatform2, "static", globals.platformPhysicsOptions )
        Runtime:addEventListener( "enterFrame", spriteTestLevel.gameLoop )
    end
end

function spriteTestLevel.gameLoop( event )
    local sprite = spriteTestLevel.sprite;
    local vx,vy = sprite:getLinearVelocity( )
        if( sprite.isMovingLeft ) then vx = -globals.horizontalRunSpeed;
    elseif( sprite.isMovingRight) then vx =  globals.horizontalRunSpeed;
    else vx =  0; --print("zero");
    end

--    print( (sprite.isMoving and "sprite.isMoving " or "") .. (sprite.isMovingLeft and "sprite.isMovingLeft " or "") .. (sprite.isMovingRight and "sprite.isMovingRight " or ""));
    spriteTestLevel.sprite:setLinearVelocity( vx, vy )
end 

--[[ --deprecated, now using :touch()
--if the player taps a part of the screen that isn't a button, this will make the player's sprite jump
function spriteTestLevel.scene:tap( event )
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

    spriteTestLevel.sprite:jump ( event );

    return true;
end
--]]

--if touching the side of the screen, this will make the player's sprite move towards that side
function spriteTestLevel.scene:touch( event )
    --[[ --no longer needed; we'll just have them use their buttons
    if(event.x > display.contentWidth*(1-1/4)) then
        spriteTestLevel.sprite:moveRight(event)
    elseif(event.x < display.contentWidth*1/4) then
        spriteTestLevel.sprite:moveLeft(event)
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

        spriteTestLevel.sprite:jump ( event );

        print ( "touch-based tap at (" .. event.x .. ", " .. event.y .. ") with phase: " .. event.phase)
    end

    return true;
end


-- "scene:hide()"
function spriteTestLevel.scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is on screen (but is about to go off screen).
        -- Insert code here to "pause" the scene.
        -- Example: stop timers, stop animation, stop audio, etc.
        Runtime:removeEventListener( "enterFrame", spriteTestLevel.gameLoop )
        physics.pause()
        system.deactivate( "multitouch" )
        --physics.remove(whatever you need)
        physics.removeBody(spriteTestLevel.giantPlatform)
        physics.removeBody(spriteTestLevel.sidePlatform1)
        physics.removeBody(spriteTestLevel.sidePlatform2)
    elseif ( phase == "did" ) then
        -- Called immediately after scene goes off screen.
    end
end


-- "scene:destroy()"
function spriteTestLevel.scene:destroy( event )

    local sceneGroup = self.view

    -- Called prior to the removal of scene's view ("sceneGroup").
    -- Insert code here to clean up the scene.
    -- Example: remove display objects, save state, etc.
    physics.stop()
end


-- -------------------------------------------------------------------------------

-- Listener setup

spriteTestLevel.scene:addEventListener( "create", spriteTestLevel.scene )
spriteTestLevel.scene:addEventListener( "show", spriteTestLevel.scene )
spriteTestLevel.scene:addEventListener( "hide", spriteTestLevel.scene )
spriteTestLevel.scene:addEventListener( "destroy", spriteTestLevel.scene )

-- -------------------------------------------------------------------------------

return spriteTestLevel