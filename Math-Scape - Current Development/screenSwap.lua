-----------------------------------------------------------------------------------------
--
-- screenSwap.lua
--
-----------------------------------------------------------------------------------------

local screenSwap = {scene = "Derp"}

local composer = require("composer")

local globals = require("globals")

local temp = composer.newScene("screenSwap")

screenSwap.scene = temp

-- -----------------------------------------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called.
-- -----------------------------------------------------------------------------------------------------------------

-- local forward references should go here

-- -------------------------------------------------------------------------------


-- "scene:create()"
function screenSwap.scene:create( event )

    local sceneGroup = self.view
	
	--this is much nicer than what we had before
	local button2 = widget.newButton{
		x = display.contentWidth/2, 
	    y = display.contentHeight/2+180,
	    width = 400,
	    height = 100,
	    id = "button1",
	    label = "Go to scene 1",
	    fontSize = 60,
	    labelColor = { default={ 0, 0, 0, 1 }, over={ 0, 0, 0, 1 } },
	    sheet = globals.ButtonSheet,
		defaultFrame = 1,
		overFrame = 2,
	    onEvent = function() composer.gotoScene("menu") end
	}

    sceneGroup:insert( button2)
    -- Initialize the scene here.
    -- Example: add display objects to "sceneGroup", add touch listeners, etc.
end


-- "scene:show()"
function screenSwap.scene:show( event )

    display.setDefault("background",0,0,0.5)

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen).
    elseif ( phase == "did" ) then
        -- Called when the scene is now on screen.
        -- Insert code here to make the scene come alive.
        -- Example: start timers, begin animation, play audio, etc.
    end
end


-- "scene:hide()"
function screenSwap.scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is on screen (but is about to go off screen).
        -- Insert code here to "pause" the scene.
        -- Example: stop timers, stop animation, stop audio, etc.
    elseif ( phase == "did" ) then
        -- Called immediately after scene goes off screen.
    end
end


-- "scene:destroy()"
function screenSwap.scene:destroy( event )

    local sceneGroup = self.view

    -- Called prior to the removal of scene's view ("sceneGroup").
    -- Insert code here to clean up the scene.
    -- Example: remove display objects, save state, etc.
end


-- -------------------------------------------------------------------------------

-- Listener setup
screenSwap.scene:addEventListener( "create", screenSwap.scene )
screenSwap.scene:addEventListener( "show", screenSwap.scene )
screenSwap.scene:addEventListener( "hide", screenSwap.scene )
screenSwap.scene:addEventListener( "destroy", screenSwap.scene )

-- -------------------------------------------------------------------------------

return screenSwap