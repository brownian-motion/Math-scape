-----------------------------------------------------------------------------------------
--
-- minigames.lua
--
-----------------------------------------------------------------------------------------

local minigames = {}
local composer = require("composer")
local asteroids = require("asteroids")
local _2048 = require("2048")
local globals = require("globals")
local tiles = require("tiles")
minigames.scene = composer.newScene("minigames")

function minigames.scene:create(event)

	local sceneGroup = self.view 
	--we need this so that the scene object has control of everything inside of it
	
	local title = display.newText{
		x=display.contentWidth/2,
		y=200,
		text="Minigames",
		fontSize=64
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
	    onEvent = function(event) if(event.phase == "ended") then composer.gotoScene("menu") end end
	}

	--[[
	local asteroidsButton = widget.newButton{
		x = display.contentWidth/2-250, 
	    y = display.contentHeight/2,
	    width = 400,
	    height = 100,
	    id = "asteroids",
	    label = "Asteroids",
	    fontSize = 64,
	    labelColor = { default={ 0, 0, 0, 1 }, over={ 0, 0, 0, 1 } },
	    sheet = globals.buttonSheet,
		defaultFrame = 1,
		overFrame = 2,
	    onEvent = function(event) if(event.phase == "ended") then composer.gotoScene("asteroids") end end
	}
	]]--
	local _2048Button = widget.newButton{
		x = display.contentWidth/2-250, 
	    y = display.contentHeight/2,
	    width = 400,
	    height = 100,
	    id = "2048",
	    label = "2048",
	    fontSize = 64,
	    labelColor = { default={ 0, 0, 0, 1 }, over={ 0, 0, 0, 1 } },
	    sheet = globals.buttonSheet,
		defaultFrame = 1,
		overFrame = 2,
	    onEvent = function(event) if(event.phase == "ended") then composer.gotoScene("2048") end end
	}
	local tilesButton = widget.newButton{
		x = display.contentWidth/2+250, 
	    y = display.contentHeight/2,
	    width = 400,
	    height = 100,
	    id = "tiles",
	    label = "Tiles",
	    fontSize = 64,
	    labelColor = { default={ 0, 0, 0, 1 }, over={ 0, 0, 0, 1 } },
	    sheet = globals.buttonSheet,
		defaultFrame = 1,
		overFrame = 2,
	    onEvent = function(event) if(event.phase == "ended") then composer.gotoScene("tiles") end end
	}
	sceneGroup:insert(title)
	sceneGroup:insert(backButton)
	--sceneGroup:insert(asteroidsButton)
	sceneGroup:insert(_2048Button)
	sceneGroup:insert(tilesButton)
end

function minigames.scene:destroy(event)
	for i = 1,table.getn(minigames.buttons) do
		minigames.buttons[i]:removeSelf()
	end
end

function minigames.scene:show( event )

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
function minigames.scene:hide( event )

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
function minigames.newButton(rectArgs, textArgs)
	local button = display.newGroup()
	button.rect = display.newRect( unpack(rectArgs) )
	button:insert(button.rect)
	button.text = display.newText( textArgs )
	button:insert(button.rect)
	button.text:setFillColor(0)
	return button;
end
--]]

minigames.scene:addEventListener( "create", minigames.scene )
minigames.scene:addEventListener( "show", minigames.scene )
minigames.scene:addEventListener( "hide", minigames.scene )
minigames.scene:addEventListener( "destroy", minigames.scene )

return minigames;