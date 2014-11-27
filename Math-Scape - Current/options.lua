-----------------------------------------------------------------------------------------
--
-- options.lua
--
-----------------------------------------------------------------------------------------

local options = {}
local composer = require("composer")
local globals = require("globals")
options.scene = composer.newScene("options")

function options.scene:create(event)

	local sceneGroup = self.view 
	--we need this so that the scene object has control of everything inside of it
	
	local title = display.newText{
		x=display.contentWidth/2,
		y=200,
		text="Options",
		fontSize=64
	}
	sceneGroup:insert(title)

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
	    onEvent = function(event) if(event.phase=="ended") then composer.gotoScene("menu") end end
	}
	sceneGroup:insert(backButton)

	local toggleDebug = widget.newButton{
		x = display.contentWidth/2, 
	    y = display.contentHeight/2-200,
	    width = 400,
	    height = 100,
	    id = "toggleDebug",
	    label = "Toggle Debug",
	    fontSize = 64,
	    labelColor = { default={ 0, 0, 0, 1 }, over={ 0, 0, 0, 1 } },
	    sheet = globals.buttonSheet,
		defaultFrame = 1,
		overFrame = 2,
	    onRelease = function() globals.debugConsole.isVisible = not globals.debugConsole.isVisible end
	}
	sceneGroup:insert(toggleDebug)

	local clearScores = widget.newButton{
		x = display.contentWidth/2, 
	    y = display.contentHeight/2-50,
	    width = 400,
	    height = 100,
	    id = "clearScores",
	    label = "Clear Scores",
	    fontSize = 64,
	    labelColor = { default={ 0, 0, 0, 1 }, over={ 0, 0, 0, 1 } },
	    sheet = globals.buttonSheet,
		defaultFrame = 1,
		overFrame = 2,
	    onEvent = function(event) if(event.phase=="ended") then showDialog() end end
	}
	sceneGroup:insert(clearScores)

	function showDialog()
		backButton:setEnabled( false )
		toggleDebug:setEnabled( false )
		clearScores:setEnabled( false )
		dialog = display.newText{
			x=display.contentWidth/2,
			y=display.contentHeight/2+50,
			text="This will clear all high scores. Are you sure?",
			fontSize=32
		}
		sceneGroup:insert(dialog)
		yes = widget.newButton{
			x = display.contentWidth/2-250, 
		    y = display.contentHeight/2+150,
		    width = 400,
		    height = 100,
		    id = "yes",
		    label = "I'm Sure",
		    fontSize = 64,
		    labelColor = { default={ 0, 0, 0, 1 }, over={ 0, 0, 0, 1 } },
		    sheet = globals.buttonSheet,
			defaultFrame = 1,
			overFrame = 2,
		    onEvent = function(event) if(event.phase=="ended") then globals.highscores = globals.resetScores helpers.saveTable(globals.highscores, "scores.json") hideDialog(true) end end
		}
		sceneGroup:insert(dialog)
		no = widget.newButton{
			x = display.contentWidth/2+250, 
		    y = display.contentHeight/2+150,
		    width = 400,
		    height = 100,
		    id = "no",
		    label = "Nevermind",
		    fontSize = 64,
		    labelColor = { default={ 0, 0, 0, 1 }, over={ 0, 0, 0, 1 } },
		    sheet = globals.buttonSheet,
			defaultFrame = 1,
			overFrame = 2,
		    onEvent = function(event) if(event.phase=="ended") then hideDialog(false) end end
		}
		sceneGroup:insert(dialog)
	end

	function hideDialog(cleared)
		clearScores:setEnabled( true )
		toggleDebug:setEnabled( true )
		backButton:setEnabled( true )
		if(cleared) then
			dialog.text = "High scores have been cleared."
		else
			dialog.text = ""
		end
		display.remove(yes)
		display.remove(no)

	end
end

function options.scene:destroy(event)
	for i = 1,table.getn(options.buttons) do
		options.buttons[i]:removeSelf()
	end
end

function options.scene:show( event )

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
function options.scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    display.remove(dialog)

    if ( phase == "will" ) then
        -- Called when the scene is on screen (but is about to go off screen).
        -- Insert code here to "pause" the scene.
        -- Example: stop timers, stop animation, stop audio, etc.
    elseif ( phase == "did" ) then
        -- Called immediately after scene goes off screen.
    end
end
--[[
function options.newButton(rectArgs, textArgs)
	local button = display.newGroup()
	button.rect = display.newRect( unpack(rectArgs) )
	button:insert(button.rect)
	button.text = display.newText( textArgs )
	button:insert(button.rect)
	button.text:setFillColor(0)
	return button;
end
--]]

options.scene:addEventListener( "create", options.scene )
options.scene:addEventListener( "show", options.scene )
options.scene:addEventListener( "hide", options.scene )
options.scene:addEventListener( "destroy", options.scene )

return options;