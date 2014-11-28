-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------

local menu = {}
local composer = require("composer")
local screenSwap = require("screenSwap")
local game = require("game")
local storyOpening = require("storyOpening")
local minigames = require("minigames")
local highScores = require("highScores")
local options = require("options")
local globals = require("globals")
menu.scene = composer.newScene("menu")

function menu.scene:create(event)

	local sceneGroup = self.view 
	--we need this so that the scene object has control of everything inside of it

	--[[menu.buttons[1] = menu.newButton({display.contentWidth/2, display.contentHeight/2-180, 400, 100} ,
									{text="Button1",x=display.contentWidth/2,y=display.contentHeight/2-180,fontSize=60,fontAlign="center"})
	-- we can assign event listeners to specific objects
	--menu.buttons[1]:addEventListener( "mouse", function() menu.buttons[1].rect:setFillColor(.5) end )
	menu.buttons[1]:addEventListener( "tap", function() menu.buttons[1].rect:setFillColor(1,0,0) end )


	menu.buttons[2] = menu.newButton({display.contentWidth/2, display.contentHeight/2-60, 400, 100} ,
									{text="pull up another screen",x=display.contentWidth/2,y=display.contentHeight/2-60,fontSize=60,fontAlign="center"})
	menu.buttons[2]:addEventListener("tap",
		function()
			menu.clearScreen();
			display.newText({text="done",x=display.contentWidth/2,y=display.contentHeight/2,fontSize=60,fontAlign="center"}):setFillColor(1);
		end
	);

	menu.buttons[3] = menu.newButton({display.contentWidth/2, display.contentHeight/2+60, 400, 100} ,
									{text="Button3",x=display.contentWidth/2,y=display.contentHeight/2+60,fontSize=60,fontAlign="center"})

	menu.buttons[4] = menu.newButton({display.contentWidth/2, display.contentHeight/2+180, 400, 100} ,
									{text="Button4",x=display.contentWidth/2,y=display.contentHeight/2+180,fontSize=60,fontAlign="center"})
	]]--
	
	--this is much nicer than what we had before
	local button1 = widget.newButton{
		x = display.contentWidth/2, 
	    y = display.contentHeight/2-180,
	    width = 400,
	    height = 100,
	    id = "button1",
	    label = "Story Mode",
	    fontSize = 64,
	    labelColor = { default={ 0, 0, 0, 1 }, over={ 0, 0, 0, 1 } },
	    sheet = globals.buttonSheet,
		defaultFrame = 1,
		overFrame = 2,
	    onEvent = function(event) if(event.phase == "ended") then  composer.gotoScene("storyOpening") --[[print("switching to 'storyOpening' with phase "..event.phase);--]] end end
	}
	local button2 = widget.newButton{
		x = display.contentWidth/2, 
	    y = display.contentHeight/2-60,
	    width = 400,
	    height = 100,
	    id = "button2",
	    label = "Quick Play",
	    fontSize = 64,
	    labelColor = { default={ 0, 0, 0, 1 }, over={ 0, 0, 0, 1 } },
	    sheet = globals.buttonSheet,
		defaultFrame = 1,
		overFrame = 2,
	    onEvent = function(event) if(event.phase == "ended") then composer.gotoScene("minigames") end end
	}
	local button3 = widget.newButton{
		x = display.contentWidth/2, 
	    y = display.contentHeight/2+60,
	    width = 400,
	    height = 100,
	    id = "button3",
	    label = "High Scores",
	    fontSize = 64,
	    labelColor = { default={ 0, 0, 0, 1 }, over={ 0, 0, 0, 1 } },
	    sheet = globals.buttonSheet,
		defaultFrame = 1,
		overFrame = 2,
	    onEvent = function(event) if(event.phase == "ended") then composer.gotoScene("highScores") end end
	}
	local button4 = widget.newButton{
		x = display.contentWidth/2, 
	    y = display.contentHeight/2+180,
	    width = 400,
	    height = 100,
	    id = "button4",
	    label = "Options",
	    fontSize = 64,
	    labelColor = { default={ 0, 0, 0, 1 }, over={ 0, 0, 0, 1 } },
	    sheet = globals.buttonSheet,
		defaultFrame = 1,
		overFrame = 2,
	    onEvent = function(event) if(event.phase == "ended") then composer.gotoScene("options") end end
	}
	local myImage = display.newImage( "assets/Background.png" , display.contentWidth/2, display.contentHeight/2)
	myImage.width=display.contentWidth;
	myImage.height=display.contentHeight;
	myImage.isVisible = true;

	sceneGroup:insert(myImage)
	sceneGroup:insert(button1)
	sceneGroup:insert(button2)
	sceneGroup:insert(button3)
	sceneGroup:insert(button4)
end

function menu.scene:destroy(event)
	for i = 1,table.getn(menu.buttons) do
		menu.buttons[i]:removeSelf()
	end
end

function menu.scene:show( event )
	--local g = graphics.newGradient( {255,0,0}, {128,0,0}, "down" )

	display.setDefault("background",0.5,0,0)

    local sceneGroup = self.view
    --sceneGroup:insert(0,1,g)
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
function menu.scene:hide( event )

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
function menu.newButton(rectArgs, textArgs)
	local button = display.newGroup()
	button.rect = display.newRect( unpack(rectArgs) )
	button:insert(button.rect)
	button.text = display.newText( textArgs )
	button:insert(button.rect)
	button.text:setFillColor(0)
	return button;
end
--]]

menu.scene:addEventListener( "create", menu.scene )
menu.scene:addEventListener( "show", menu.scene )
menu.scene:addEventListener( "hide", menu.scene )
menu.scene:addEventListener( "destroy", menu.scene )

return menu;