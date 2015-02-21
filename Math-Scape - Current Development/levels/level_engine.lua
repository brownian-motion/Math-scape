--[[
	level engine

	This is intended to be the main engine that will run all of the mechanics of a level.
	This way, the .lua files for each specific level can focus on their specific implementation
	differences. This will also take the load for multiple levels, greatly reducing redundancy.

	For now, the plan is to have this run the scene with data and functions from individual levels' files.
	An alternate implementation, which s not currently used, would be to use this as a parent constructor
	for children objects that implement individual levels.
--]]

local composer = require( "composer" )
local physics = require( "physics" )
local sprites = require( "sprites" )
local dusk = require( "Dusk.Dusk")
--local lib_data = require( "Dusk.dusk_core.load.data" )
local pauseOverlay = require( "pauseOverlay" )

--initialize the level object
local level = {}
--[[
--These will be set in the :create constructor using composer.getVariable()
level.num = 1;
level.name = "level"..level.num;
--]]
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

level.scene = composer.newScene("story mode")

-- -----------------------------------------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called.
-- -----------------------------------------------------------------------------------------------------------------

-- local forward references should go here

-- -------------------------------------------------------------------------------

local pixelsPerMeter --= globals.pixelsPerMeter[level.name]

-- "scene:create()"
function level.scene:create( event )

	loadSpecificLevelData();

    local sceneGroup = self.view

    --starts the physics so we can successfully add stuff. will be stopped at the end of create(), and started in show()
    --DO NOT add physics objects before this!
    --
    physics.start();
    physics.setScale( pixelsPerMeter );
    physics.setGravity(0,9.8*1.5);
    --]]

    level.layer = { background = display.newGroup() , map = display.newGroup() , buttonGui = display.newGroup() };
    
    --
    --we need this so that the scene object has control of everything inside of it
    generateBackground();
    --level.layer["background"]:insert(backgroundImage)
    --]]
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

    sceneGroup:insert( level.layer["background"] )
    sceneGroup:insert( level.layer["map"] )
    sceneGroup:insert( level.layer["buttonGui"] )

    --gameElements:addEventListener("tap",level.scene) 
    level.layer["background"]:addEventListener("touch",level.scene)
    --this will call <filename>.scene:tap() every time anything (*including the background or display objects) is tapped
    --this is preferrable to Runtime:addEventListener in that we don't have to get rid of it when we're done; it only exists with this scene's sceneGroup
    --this is also the same reason we don't define it outside of this method
    
    --level.setupPhysics(map);

    


    --if( system.pathForFile("levels/StickSprite.png") == nil) then print "nil file" else print "good file" end
    --
    local spriteSheet = graphics.newImageSheet( "assets/sprites/princess.png", {width = 23, height = 35, numFrames = 22, sheetContentHeight = 70, sheetContentWidth = 253} )
    local sequenceData = {
        {name="standing left", frames={8}},
        {name="walking left", frames={12,13}, time=500, loopCount=0},
        {name="walking right", frames={1,2}, time=500, loopCount=0},
        {name="standing right", frames={19}},
        {name="jumping", frames={1,3,4,5,6,7}, time=750, loopCount=1, loopDirection="bounce"},
        {name="jumping right", frames={1,3,4,5,6,7}, time=750, loopCount=1, loopDirection="bounce"},
        {name="jumping left", frames={12,14,15,16,17,18}, time=750, loopCount=1, loopDirection="bounce"},
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
    generatePlayerCharacter();
    --]]


    generateGUI();

    --Music
    local backgroundMusic = audio.loadStream("assets/music/Castle Halls.wav")
    level.backgroundMusic = backgroundMusic
    audio.setVolume(1.0)
    audio.play(level.backgroundMusic,{channel=1,loops=-1})

    --pauses physics so it's not running before stuff's on the screen.
    --DO NOT add physics objects after this!
    physics.pause();

    --level.printMapTraversal(map);
end

function generateBackground()
	level.background = display.newRect( display.screenOriginX+display.actualContentWidth/2,display.screenOriginY+display.actualContentHeight/2, display.actualContentWidth, display.actualContentHeight )
    level.background:setFillColor(0.1,0.1,0.1)
    local backgroundImage = display.newImage("assets/art/Background-for-levels-resized.jpg")--,display.actualContentWidth, display.actualContentHeight)
    sprites.setSize(nil, backgroundImage, {width = display.actualContentWidth});
    backgroundImage.x = display.contentCenterX
    backgroundImage.y = display.contentCenterY
    level.backgroundImage = backgroundImage;
    --backgroundImage:toBack( )
    level.layer["background"]:insert(level.background)
    level.layer["background"]:insert(backgroundImage);
end

--[[
	generateGui()

	This function creates the GUI that allows the player to interact with the story part of the game, including 
	movement controls and menu operations.
	Currently, this function assumes that the player is using a touch screen. It ignores functionality for
	PC or consoles such as OUYA.
--]]
function generateGUI()
	local buttonGui = level.layer["buttonGui"]
    level.buttonGui = buttonGui

	local pauseOptions =
    {
        isModal = true,
        effect = "slideDown",
        time = 200,
        params = {
            title="Paused",
            backButton = true,
            exitTo = "storyOpening",
            effect = "slideUp",
            time = 200,
            resetScene = false,
            currScene = "tileTestLevel",
            onReturn = function() audio.fade( { channel=1, time=1000, volume=1.0 } ) end
        }
    }
    level.pauseButton = widget.newButton{
        x = display.contentWidth/2, 
        y = display.contentHeight-100,
        --width = 400,
        --height = 100,
        id = "pause",
        label = "Pause",
        fontSize = 64,
        labelColor = { default={ 0, 0, 0, 1 }, over={ 0, 0, 0, 1 } },
        sheet = globals.buttonSheet,
        defaultFrame = 1,
        overFrame = 1,
        onEvent = function(event)
        if(event.phase == "ended") then
            composer.showOverlay( "pauseOverlay", pauseOptions )
            --Fade the music when the overlay is displayed
            audio.fade( { channel=1, time=500, volume=0.3 } )
        end
        return true;
        end,
    }
    buttonGui:insert(level.pauseButton)
    level.pauseButton:setFillColor(.5,.5,.9)

	level.buttonGui
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
        onEvent = function(event) level.playerSprite:moveLeft(event) return true; end,
    }
    buttonGui:insert(level.leftButton)


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
        onEvent = function(event) level.playerSprite:moveRight(event) return true; end,
    }
    buttonGui:insert(level.rightButton)

    level.doorButton = widget.newButton{
        --parent = sceneGroup,
        x = display.contentWidth -200, 
        y = display.contentHeight-250,
        --width = 400,
        --height = 100,
        id = "Enter Door",
        label = "Enter Door",
        fontSize = 64,
        labelColor = { default={ 0, 0, 0, 1 }, over={ 0, 0, 0, 1 } },
        sheet = globals.buttonSheet,
        defaultFrame = 1,
        overFrame = 1,
        onEvent = function(event) if(event.phase == "ended") then level.enterDoor(level.doorButton.door); return true; end return false; end,
    }
    level.doorButton:setFillColor( .5, .5, .9 );
    level.doorButton.alpha = 0.0;
    buttonGui:insert(level.doorButton)
end

function generatePlayerCharacter()
	local playerSprite = display.newSprite( spriteSheet, sequenceData )
    level.playerSprite = playerSprite;
    local playerSpritePhysicsOptions = table.copy(globals.playerPhysicsOptions)
    --
    playerSprite.simpleShape = {
         1/2,   -1/2,
         1/2,    1/2,
        -1/2,    1/2,
        -1/2,   -1/2,
    }--]]
    print( playerSprite.width .. " " .. playerSprite.height)
    sprites.addDisplayControls(playerSprite);
    playerSprite:setSize(playerSprite, {height = 1.2*pixelsPerMeter})
    playerSpritePhysicsOptions.shape = playerSprite:getBoundingShape();
    --spritePhysicsOptions.shape = { 50,-50 , 50,50 , -50,50 , -50,-50};
    print( playerSprite.width .. " " .. playerSprite.height)
    print( (playerSprite.width * playerSprite.xScale) .. " " .. (playerSprite.height * playerSprite.yScale) )
    physics.addBody(playerSprite, "dynamic", spritePhysicsOptions)
    sprites.addTouchControls(playerSprite) --this adds :moveLeft(), :moveRight(), and :jump() to the sprite object
    playerSprite:assignControl("player");
    playerSprite.x,playerSprite.y = 100,100 --default, if initialization doesn't work
    level.initializeSpritePosition(map, playerSprite, map.startLocation)

    playerSprite:addEventListener( "preCollision", level.spritePreCollision )
end

function loadSpecificLevelData()
	level.name = composer.getVariable(globals.GET_CURRENT_LEVEL_NAME)
	level.num = composer.getVariable(globals.GET_CURRENT_LEVEL_NUMBER)
	level.pixelsPerMeter = globals.pixelsPerMeter[level.name]
end

--
function level.initializeSpritePosition( map , sprite, tileLocation)
    sprite = sprite or level.playerSprite;
    map = map or level.map;
    tileLocation = tileLocation or map.startLocation;
    map.layer["Midground"]:insert(sprite)
    sprite.layer = "Midground";

    --helpers.print_traversal(tileLocation, "tileLocation");
    
    --sprite.x = display.contentWidth/2;
    --sprite.y = display.contentHeight/2 - 3*pixelsPerMeter;
    --sprite.x = map.startLocation.x * map.data.tileHeight
    --sprite.y = map.startLocation.y * map.data.tileHeight
    if(tileLocation._type == "SpriteInitializer") then
        sprite.x, sprite.y = tileLocation.x, tileLocation.y;
        print("SpriteInitializer for:"..tileLocation._name);
    else
        sprite.x, sprite.y = map.layer["Midground"].tilesToPixels(tileLocation.x, tileLocation.y)
    end
end
--]]


-- "scene:show()"
function level.scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    local sprite = level.playerSprite

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

        audio.play(level.backgroundMusic)
        audio.fade( { channel=1, time=1000, volume=1.0 } )
    end
end

function level.gameLoop( event )
    --return; --DEBUG
    --
    local sprite = level.playerSprite;
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
    --
    local doorFound = false;
    for layerIndex,layer in ipairs(map.layer) do
        for name,object in pairs(map.layer[layerIndex].object or {}) do
            if( object and not object.ignore
               and sprite.x < (object.x + object.width/2) and sprite.x > (object.x - object.width/2)
               and sprite.y < (object.y + object.height/2) and sprite.y > (object.y - object.height/2)) then
                if(object._type == "LayerSwap" and sprite.layer == object.from) then
                    --map.layer[object.from]:remove(sprite);
                    map.layer[object.to]:insert(sprite);
                    
                    --print("put sprite into layer "..object.to);
                    sprite.layer = object.to;
                elseif(object._type == "Trigger") then
                    level:handleTrigger(object);
                elseif((object._type == "Door" or object._type == "PuzzleDoor") and not object.ignore) then
                    doorFound = object;
                elseif(object._type == "PowerUp") then
                    level:handlePowerUp(object);
                end
            end
        end 
    end
    if(doorFound) then
        level.doorButton:setEnabled(true);
        level.doorButton.alpha = 1.0;
    else
        level.doorButton:setEnabled( false );
        level.doorButton.alpha = 0.0;
    end
    level.doorButton.door = doorFound;
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
    else
        local vx,vy = sprite:getLinearVelocity();
        if(other.y > sprite.y and vy > 0 and math.abs(sprite.x-other.x)<sprite.width/2) then --if(moving down and colliding with a block below me) then (not jumping) end
            sprite.isJumping = false;
            sprite.numJumps = 0;
            print(other.y .. " " .. sprite.y .. " " .. tostring(other._type));
            timer.performWithDelay( 50, function()
                --this is to prevent the princess from getting stuck on the floor as she walks
            	local CORRECTIVE_FORCE_STRENGTH = 0.01; 
            	sprite:applyForce(CORRECTIVE_FORCE_STRENGTH*(sprite.x-other.x)/math.abs(sprite.x-other.x),CORRECTIVE_FORCE_STRENGTH*(sprite.y-other.y)/math.abs(sprite.y-other.y),sprite.x,sprite.y) end
            );
        end
        sprite:updateSequence();
    end
end

function level:handleTrigger(trigger)
    --print("triggered!");
    --helpers.print_traversal(trigger);
    if(not trigger.sprung) then
        if(trigger._name == "StartCutscene") then
            local sprite = level.playerSprite;
            sprite:freezeControl();
            sprite:moveRight({name="ai",phase="ended"});
            sprite:moveLeft({name="ai",phase="ended"});
            timer.performWithDelay( 3*1000, function() level.playerSprite:returnControl(); end );
            trigger.sprung = true;
        end
        print("TRIGGER SPRUNG: "..trigger._name);
    end
end

function level:handlePowerUp(powerUp)
    if(powerUp._name == "JumpBoots") then
        level.playerSprite.canDoubleJump = true;
        print("JUMP BOOTS FOUND");
        powerUp:removeSelf()
        powerUp.ignore = true;
    end
    print("POWER UP FOUND ".. powerUp._name);
end



function level:setUpSpecificMap(map, name)
    --helpers.print_traversal(map);
    map.aiSprites = {}
    if(name == "level1 - castle") then
        local physicsOptions = table.copy(globals.playerPhysicsOptions);
        local guardSpriteSheet = graphics.newImageSheet( "assets/sprites/guard.png", {width = 17, height = 29, numFrames=10, sheetContentWidth=17*5, sheetContentHeight=29*2} )
        local guardSequenceData = {
            {name="standing",frames={6}},
            {name="standing left", frames={7}},
            {name="walking left", frames={7,9}, time=500, loopCount=0},
            {name="walking right", frames={8,10}, time=500, loopCount=0},
            {name="standing right", frames={8}},
            {name="jumping", frames={9}, time=750, loopCount=1, loopDirection="bounce"},
            {name="jumping right", frames={10,8,10}, time=750, loopCount=1, loopDirection="bounce"},
            {name="jumping left", frames={9,7,9}, time=750, loopCount=1, loopDirection="bounce"},
        }
        local guardSprite = display.newSprite( guardSpriteSheet, guardSequenceData )
        sprites.addDisplayControls(guardSprite);
        guardSprite:setSize(guardSprite,{height = pixelsPerMeter * 1.4})
        physicsOptions.shape = guardSprite:getBoundingShape();
        physics.addBody( guardSprite, "dynamic",physicsOptions )
        sprites.addTouchControls(guardSprite);
        guardSprite:assignControl("ai");
        map.layer["Midground"]:insert( guardSprite ); guardSprite.layer = "Midground";
        local guardSpriteInitializer = map.layer["Object Layer 1"].object["Guard Sprite 1"];
        level.initializeSpritePosition(map,guardSprite,guardSpriteInitializer);
        table.insert( map.aiSprites, guardSprite );

        local prisonerSpriteSheet = graphics.newImageSheet( "assets/sprites/prisoner.png", {width = 17, height = 29, numFrames=10, sheetContentWidth=17*5, sheetContentHeight=29*2} )
        local prisonerSequenceData = {
            {name="standing",frames={1}},
            {name="standing left", frames={2}},
            {name="walking left", frames={2,4}, time=500, loopCount=0},
            {name="walking right", frames={3,5}, time=500, loopCount=0},
            {name="standing right", frames={3}},
            {name="jumping", frames={4}, time=750, loopCount=1, loopDirection="bounce"},
            {name="jumping right", frames={5,3,5}, time=750, loopCount=1, loopDirection="bounce"},
            {name="jumping left", frames={4,2,4}, time=750, loopCount=1, loopDirection="bounce"},
        }
        local prisonerSprite = display.newSprite( prisonerSpriteSheet, prisonerSequenceData );
        sprites.addDisplayControls(prisonerSprite);
        prisonerSprite:setSize(prisonerSprite,{height = pixelsPerMeter * 1.4})
        physicsOptions.shape = prisonerSprite:getBoundingShape();
        physics.addBody( prisonerSprite, "dynamic", physicsOptions )
        sprites.addTouchControls(prisonerSprite);
        prisonerSprite:assignControl("ai");
        map.layer["Background"]:insert( prisonerSprite ); prisonerSprite.layer = "Background";
        local prisonerSpriteInitializer = map.layer["Object Layer 1"].object["Prisoner Sprite"];
        level.initializeSpritePosition(map,prisonerSprite,prisonerSpriteInitializer);
        table.insert( map.aiSprites, prisonerSprite);
        level.backgroundImage.alpha = 1;
        level.backgroundImage.y = display.actualContentHeight - level.backgroundImage.height;
    elseif(name == "level1 - hallway") then
        level.backgroundImage.alpha = 0;
    end
end

--if touching the side of the screen, this will make the player's sprite move towards that side
function level.scene:touch( event )
    local sprite = level.playerSprite;
    local map = level.map;
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
        --[[
        for name,object in pairs(map.layer["Object Layer 1"].object) do
            --assuming rectangular object:
            if( sprite.x < (object.x + object.width/2) and sprite.x > (object.x - object.width/2)
              and sprite.y < (object.y + object.height/2) and sprite.y > (object.y - object.height/2)) then
                if(object._type == "Door" or (object._type == "PuzzleDoor" and not object.ignore)) then
                    level.enterDoor(object);
                    spriteShouldStillJump = false;
                    return true;
                end
            end
        end
        --]]
        if(spriteShouldStillJump) then level.playerSprite:jump ( event ); end;
        --]]
        print ( "touch-based tap at (" .. event.x .. ", " .. event.y .. ") with phase: " .. event.phase)
        
    end

    return true;
end

--these controls should possibly be moved to a character-control file/class
function level.scene:key( event )
    if(not level.playerSprite) then return false; end
    if(event.keyName == "right" or event.keyName == "") then
        level.playerSprite:moveRight(event);
        return true;
    elseif(event.keyName == "left" or event.keyName == "") then
        level.playerSprite:moveLeft(event);
        return true;
    elseif(event.keyName == "space") then
        level.playerSprite:jump(event);
        return true;
    elseif(event.keyName == "up" or event.keyName == "") then
        level.playerSprite:jump(event);
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
    local sprite = level.playerSprite;

    if(door._type == "PuzzleDoor" and not door.ignore and not door.passed) then
        level.enterPuzzleDoor(door);
        return false;
    end

    if(door._type == "SlidingDoor" and not door.ignore) then
        --animate the tiles comprising the door sliding up
        return true;
    end

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
                spriteDestinationDoor = spriteDestinationDoor or layer.object(door.toDoor);
                if(spriteDestinationDoor) then

	                print("found the door!");
	                spriteDestinationDoor = object;
	                spriteDestination = {   x=(object.x + 0.5*object.width)/newMapData.stats.tileHeight,
	                                        y=object.y/newMapData.stats.tileHeight
	                                    };
	                break;
            	end
            end
        end
        --this now assumes that we have definitely found a door; otherwise, it sends us to (0,0)

        --start the animation of entering a door.
        local doorLayer = level.map.layer["Background_Doors"];
        local doorLoc = {}; doorLoc.x, doorLoc.y = doorLayer.pixelsToTiles(door.x,door.y)
	    doorLayer._unlockTile(doorLoc.x, doorLoc.y);
	    --print("   +++++    ");
	    --helpers.print_traversal(doorLayer.tile(doorLoc.x, doorLoc.y));
	    --print("   +++++    ");
	    doorLayer.tile(doorLoc.x, doorLoc.y):setAlternateGID();

        --move into the new map AFTER the animation has been started
        timer.performWithDelay( globals.DOOR_ENTRY_ANIMATION_DELAY, 
        	function( event )
		        helpers.print_traversal(spriteDestination,"spriteDestination");
		        physics.pause();
		        local newMap = dusk.buildMap( newMapData );
		        level.map:destroy();  --take out the current map
		        level.map = newMap;  --apply the new map
		        level.layer["map"]:insert(newMap);
		        level.initializeSpritePosition( newMap, sprite, spriteDestination )
		        level:setUpSpecificMap(level.map, door.toMap);
		        physics.start();
	    	end
	    );
        
    end
end

function level.enterPuzzleDoor( door )
    if(door._type == "PuzzleDoor" and not door.ignore) then
        local puzzleName = tostring(door.puzzle);
        local options = {effect= "fromTop", time = 400};
        options.params = door
        options.params.onReturn = level.name; --current scene name
        require(puzzleName) --just makes sure that it's loaded
        composer.gotoScene(puzzleName, options);
        return true;
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
        --Fade out music
        audio.fadeOut({channel="1",time=1000})
        audio.stop()
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