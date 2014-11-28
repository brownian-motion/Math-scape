-----------------------------------------------------------------------------------------
--
-- highScores.lua
--
-----------------------------------------------------------------------------------------

local highScores = {}
local globals = require("globals")
local composer = require("composer")
highScores.scene = composer.newScene("highScores")


function highScores.scene:create(event)

	local sceneGroup = self.view 
	--we need this so that the scene object has control of everything inside of it

	local options =
	{
	    --required parameters
	    width = 400,
	    height = 100,
	    numFrames = 2,
	}
	
	local title = display.newText{
		x=display.contentWidth/2,
		y=200,
		text="High Scores",
		fontSize=64
	}

	games = display.newText{
		x=display.contentWidth/2,
		y=display.contentHeight/2,
		text="",
		fontSize=32,
		width=300
	}
	scores = display.newText{
		x=display.contentWidth/2,
		y=display.contentHeight/2,
		text="",
		fontSize=32,
		width=300,
		align="right"
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
	sceneGroup:insert(games)
	sceneGroup:insert(scores)
	sceneGroup:insert(backButton)
end

function highScores.scene:destroy(event)
	for i = 1,table.getn(highScores.buttons) do
		highScores.buttons[i]:removeSelf()
	end
end

function highScores.scene:show( event )

	display.setDefault("background",0.1,0.1,0.1)

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
    	local ordered_keys = {}

		for k in pairs(globals.highscores) do
		    table.insert(ordered_keys, k)
		end

		games.text = ""
		scores.text = ""
		--problem: 2048 gets sorted to the end. This may be due to the use of an underscore (_2048).
		table.sort(ordered_keys)
		for i = 1, #ordered_keys do
		    local k, v = ordered_keys[i], globals.highscores[ ordered_keys[i] ]
		    games.text = games.text .. string.gsub(k, "_", "") .. "\n" -- also gets rid of any underscores
		    scores.text = scores.text .. v .. "\n"
		end
        -- Called when the scene is still off screen (but is about to come on screen).
    elseif ( phase == "did" ) then
        -- Called when the scene is now on screen.
        -- Insert code here to make the scene come alive.
        -- Example: start timers, begin animation, play audio, etc.
    end
end


-- "scene:hide()"
function highScores.scene:hide( event )

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
function highScores.newButton(rectArgs, textArgs)
	local button = display.newGroup()
	button.rect = display.newRect( unpack(rectArgs) )
	button:insert(button.rect)
	button.text = display.newText( textArgs )
	button:insert(button.rect)
	button.text:setFillColor(0)
	return button;
end
--]]

highScores.scene:addEventListener( "create", highScores.scene )
highScores.scene:addEventListener( "show", highScores.scene )
highScores.scene:addEventListener( "hide", highScores.scene )
highScores.scene:addEventListener( "destroy", highScores.scene )

return highScores;