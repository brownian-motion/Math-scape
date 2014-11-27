-----------------------------------------------------------------------------------------
--
-- asteroids.lua
--
-----------------------------------------------------------------------------------------

local asteroids = {}
local composer = require("composer")
asteroids.scene = composer.newScene("asteroids")


function asteroids.scene:create(event)

	local sceneGroup = self.view 
	--we need this so that the scene object has control of everything inside of it

	local optionsSquare =
	{
	    --required parameters
	    width = 100,
	    height = 100,
	    numFrames = 2,
	}

	local buttonSheetRound = graphics.newImageSheet( "roundButton.png", optionsSquare )

	local title = display.newText{
		x=display.contentWidth/2,
		y=display.contentHeight/2-100,
		text="Defend Your City!",
		fontSize=64
	}

	local startButton = widget.newButton{
		x=display.contentWidth/2,
		y=display.contentHeight/2+100,
	    width = 100,
	    height = 100,
	    id = "start",
	    label = "Begin",
	    fontSize = 64,
	    labelColor = { default={ 0, 0, 0, 1 }, over={ 0, 0, 0, 1 } },
	    sheet = globals.buttonSheet,
		defaultFrame = 1,
		overFrame = 2,
	    onEvent = function() asteroids.beginGame() end
	}

	local backButton = widget.newButton{
		x = display.contentWidth/2, 
	    y = display.contentHeight-200,
	    width = 400,
	    height = 100,
	    id = "back",
	    label = "Back",
	    fontSize = 64,
	    labelColor = { default={ 0, 0, 0, 1 }, over={ 0, 0, 0, 1 } },
	    sheet = globals.buttonSheet,
		defaultFrame = 1,
		overFrame = 2,
	    onEvent = function() composer.gotoScene("menu") end
	}

	sceneGroup:insert(title)
	sceneGroup:insert(startButton)
	sceneGroup:insert(backButton)

	local menuButton 
	function asteroids.beginGame()
		display.remove(title)
		display.remove(startButton)
		menuButton = widget.newButton{
			x = 100, 
		    y = 100,
		    width = 100,
		    height = 100,
		    id = "menu",
		    label = "",
		    fontSize = 64,
		    labelColor = { default={ 0, 0, 0, 1 }, over={ 0, 0, 0, 1 } },
		    sheet = buttonSheetRound,
			defaultFrame = 1,
			overFrame = 2,
		    onEvent = function() asteroids.pause() end
		}
		sceneGroup:insert(menuButton)
	end

	function asteroids.pause()
		local dim = display.newRect( display.contentWidth/2, display.contentHeight/2, display.contentWidth, display.contentHeight )
		dim:setFillColor( 0, 0, 0, 0.5 )
		menuButton:setEnabled(false)
	end
end

function asteroids.scene:destroy(event)
	for i = 1,table.getn(asteroids.buttons) do
		asteroids.buttons[i]:removeSelf()
	end
end

function asteroids.scene:show( event )

	display.setDefault("background",0.1,0.1,0.1)

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
function asteroids.scene:hide( event )

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
--[[
function asteroids.newButton(rectArgs, textArgs)
	local button = display.newGroup()
	button.rect = display.newRect( unpack(rectArgs) )
	button:insert(button.rect)
	button.text = display.newText( textArgs )
	button:insert(button.rect)
	button.text:setFillColor(0)
	return button;
end
--]]

asteroids.scene:addEventListener( "create", asteroids.scene )
asteroids.scene:addEventListener( "show", asteroids.scene )
asteroids.scene:addEventListener( "hide", asteroids.scene )
asteroids.scene:addEventListener( "destroy", asteroids.scene )

return asteroids;