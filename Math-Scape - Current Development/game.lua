-----------------------------------------------------------------------------------------
--
-- game.lua
--
-----------------------------------------------------------------------------------------

local game = {}
local composer = require("composer")
game.scene = composer.newScene("game")

function game.scene:create(event)

	local sceneGroup = self.view 
	--we need this so that the scene object has control of everything inside of it

	--[[game.buttons[1] = game.newButton({display.contentWidth/2, display.contentHeight/2-180, 400, 100} ,
									{text="Button1",x=display.contentWidth/2,y=display.contentHeight/2-180,fontSize=60,fontAlign="center"})
	-- we can assign event listeners to specific objects
	--game.buttons[1]:addEventListener( "mouse", function() game.buttons[1].rect:setFillColor(.5) end )
	game.buttons[1]:addEventListener( "tap", function() game.buttons[1].rect:setFillColor(1,0,0) end )


	game.buttons[2] = game.newButton({display.contentWidth/2, display.contentHeight/2-60, 400, 100} ,
									{text="pull up another screen",x=display.contentWidth/2,y=display.contentHeight/2-60,fontSize=60,fontAlign="center"})
	game.buttons[2]:addEventListener("tap",
		function()
			game.clearScreen();
			display.newText({text="done",x=display.contentWidth/2,y=display.contentHeight/2,fontSize=60,fontAlign="center"}):setFillColor(1);
		end
	);

	game.buttons[3] = game.newButton({display.contentWidth/2, display.contentHeight/2+60, 400, 100} ,
									{text="Button3",x=display.contentWidth/2,y=display.contentHeight/2+60,fontSize=60,fontAlign="center"})

	game.buttons[4] = game.newButton({display.contentWidth/2, display.contentHeight/2+180, 400, 100} ,
									{text="Button4",x=display.contentWidth/2,y=display.contentHeight/2+180,fontSize=60,fontAlign="center"})
	]]--

	local options =
	{
	    --required parameters
	    width = 400,
	    height = 100,
	    numFrames = 2,
	}

	local options2 =
	{
	    --required parameters
	    width = 100,
	    height = 100,
	    numFrames = 2,
	}

	local buttonSheet = graphics.newImageSheet( "button.png", options )
	local buttonSheetUP = graphics.newImageSheet( "upArrow.png", options2 )
	local buttonSheetDOWN = graphics.newImageSheet( "downArrow.png", options2 )
	local buttonSheetLEFT = graphics.newImageSheet( "leftArrow.png", options2 )
	local buttonSheetRIGHT = graphics.newImageSheet( "rightArrow.png", options2 )
	local buttonSheetRound = graphics.newImageSheet( "roundButton.png", options2 )
	
	local comingSoon = display.newText{
		x=display.contentWidth/2,
		y=display.contentHeight/2-100,
		text="Coming Soon",
		fontSize="64"
	}

	local backButton = widget.newButton{
		x = display.contentWidth/2, 
	    y = display.contentHeight/2+100,
	    width = 400,
	    height = 100,
	    id = "upArrow",
	    label = "Back",
	    fontSize = 64,
	    labelColor = { default={ 0, 0, 0, 1 }, over={ 0, 0, 0, 1 } },
	    sheet = buttonSheet,
		defaultFrame = 1,
		overFrame = 2,
	    onEvent = function() composer.gotoScene("menu") end
	}

	local upArrow = widget.newButton{
		x = 200, 
	    y = display.contentHeight-300,
	    width = 100,
	    height = 100,
	    id = "upArrow",
	    label = "",
	    fontSize = 64,
	    labelColor = { default={ 0, 0, 0, 1 }, over={ 0, 0, 0, 1 } },
	    sheet = buttonSheetUP,
		defaultFrame = 1,
		overFrame = 2,
	    --onEvent = function() composer.gotoScene("screenSwap") end
	}

	local downArrow = widget.newButton{
		x = 200, 
	    y = display.contentHeight-100,
	    width = 100,
	    height = 100,
	    id = "upArrow",
	    label = "",
	    fontSize = 64,
	    labelColor = { default={ 0, 0, 0, 1 }, over={ 0, 0, 0, 1 } },
	    sheet = buttonSheetDOWN,
		defaultFrame = 1,
		overFrame = 2,
	    --onEvent = function() composer.gotoScene("screenSwap") end
	}

	local leftArrow = widget.newButton{
		x = 100, 
	    y = display.contentHeight-200,
	    width = 100,
	    height = 100,
	    id = "upArrow",
	    label = "",
	    fontSize = 64,
	    labelColor = { default={ 0, 0, 0, 1 }, over={ 0, 0, 0, 1 } },
	    sheet = buttonSheetLEFT,
		defaultFrame = 1,
		overFrame = 2,
	    --onEvent = function() composer.gotoScene("screenSwap") end
	}

	local rightArrow = widget.newButton{
		x = 300, 
	    y = display.contentHeight-200,
	    width = 100,
	    height = 100,
	    id = "upArrow",
	    label = "",
	    fontSize = 64,
	    labelColor = { default={ 0, 0, 0, 1 }, over={ 0, 0, 0, 1 } },
	    sheet = buttonSheetRIGHT,
		defaultFrame = 1,
		overFrame = 2,
	    --onEvent = function() composer.gotoScene("screenSwap") end
	}

	local aButton = widget.newButton{
		x = display.contentWidth-150, 
	    y = display.contentHeight-250,
	    width = 100,
	    height = 100,
	    id = "aButton",
	    label = "A",
	    fontSize = 64,
	    labelColor = { default={ 0, 0, 0, 1 }, over={ 0, 0, 0, 1 } },
	    sheet = buttonSheetRound,
		defaultFrame = 1,
		overFrame = 2,
	    --onEvent = function() composer.gotoScene("screenSwap") end
	}

	local bButton = widget.newButton{
		x = display.contentWidth-250, 
	    y = display.contentHeight-150,
	    width = 100,
	    height = 100,
	    id = "bButton",
	    label = "B",
	    fontSize = 64,
	    labelColor = { default={ 0, 0, 0, 1 }, over={ 0, 0, 0, 1 } },
	    sheet = buttonSheetRound,
		defaultFrame = 1,
		overFrame = 2,
	    --onEvent = function() composer.gotoScene("screenSwap") end
	}

	sceneGroup:insert(comingSoon)
	sceneGroup:insert(backButton)
	sceneGroup:insert(upArrow)
	sceneGroup:insert(downArrow)
	sceneGroup:insert(leftArrow)
	sceneGroup:insert(rightArrow)
	sceneGroup:insert(aButton)
	sceneGroup:insert(bButton)
end

function game.scene:destroy(event)
	for i = 1,table.getn(game.buttons) do
		game.buttons[i]:removeSelf()
	end
end

function game.scene:show( event )

	display.setDefault("background",0.5,0,0)

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
function game.scene:hide( event )

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
function game.newButton(rectArgs, textArgs)
	local button = display.newGroup()
	button.rect = display.newRect( unpack(rectArgs) )
	button:insert(button.rect)
	button.text = display.newText( textArgs )
	button:insert(button.rect)
	button.text:setFillColor(0)
	return button;
end
--]]

game.scene:addEventListener( "create", game.scene )
game.scene:addEventListener( "show", game.scene )
game.scene:addEventListener( "hide", game.scene )
game.scene:addEventListener( "destroy", game.scene )

return game;