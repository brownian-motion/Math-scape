-----------------------------------------------------------------------------------------
--
-- comingSoon.lua
--
-----------------------------------------------------------------------------------------

local comingSoon = {}
local composer = require("composer")
local spriteTestLevel = require("levels.spriteTestLevel")
local tileTestLevel = require("levels.tileTestLevel")
local level1 = require("levels.level1.level1")
local sprites = require "sprites";
comingSoon.scene = composer.newScene("comingSoon")

function comingSoon.scene:create(event)

	local sceneGroup = self.view 

	sceneGroup:addEventListener("tap",comingSoon.scene) --this will call comingSoon.scene:tap() every time anything (*including the background or display objects) is tapped
	--this is preferrable to Runtime:addEventListener in that we don't have to get rid of it when we're done; it only exists with this scene's sceneGroup

	--test of key handlers
	sceneGroup:addEventListener("key",comingSoon.scene)

	--we need this so that the scene object has control of everything inside of it
	--comingSoon.background = display.newRect( display.screenOriginX+display.actualContentWidth/2,display.screenOriginY+display.actualContentHeight/2, display.actualContentWidth, display.actualContentHeight )
	local background = comingSoon.background
	background = display.newImage( "assets/art/opening-cinematic.jpg" );
	sprites.setSize( {}, background, {height = display.actualContentHeight});
	background.anchorX, background.anchorY = 0,0;
	background.x, background.y = 0,(display.contentHeight- display.actualContentHeight)/2
	--background:setFillColor(0.1,0.1,0.1)
	sceneGroup:insert(background)
	
	comingSoon.title = display.newText{
		x=display.contentWidth/2,
		y=display.contentHeight/2-100,
		text="Coming Soon",
		fontSize=64
	}

	comingSoon.backButton = widget.newButton{
		x = display.contentWidth/2, 
	    y = display.contentHeight-100,
	    width = 400,
	    height = 100,
	    id = "back",
	    label = "Back",
	    fontSize = 64,
	    labelColor = { default={ 0, 0, 0, 1 }, over={ 0, 0, 0, 1 } },
	    sheet = globals.buttonSheet,
		defaultFrame = 1,
		overFrame = 2,
	    onEvent = function(event) if(event.phase == "ended") then composer.gotoScene("menu") end end,
	}

	
	comingSoon.textFade = display.newText{
		parent = sceneGroup,
		text = "Try out our story mode.",
		x = display.contentWidth/2,
		y = display.contentHeight*4/7 ,
		fontSize = 40,
		align="center",
	}
	comingSoon.textFade:setFillColor( 1,.5,.5 )
	comingSoon.alpha=0;

	comingSoon.mousePrompter = display.newText{
		parent = sceneGroup,
		text = "It's a work in progress, but we think you'll like it.",
		x = display.contentWidth/2,
		y = display.contentHeight*4/7 +50,
		fontSize = 40,
		align="center",
	}
	comingSoon.mousePrompter:setFillColor( 1,.5,.5 )
	comingSoon.alpha=0;

	--[[
	comingSoon.testLevelButton = widget.newButton {
		x = display.contentWidth*1/3,
		y = display.contentHeight*3/4,
		width = 600,
	    height = 100,
	    id="testLevel",
		label = "Go to a test screen",
		fontSize = 48,
		align = "center",
		labelColor = { default={ 0, 0, 0, 1 }, over={ 0, 0, 0, 1 } },
		sheet = globals.buttonSheet,
		defaultFrame = 1,
		overFrame = 2,
		onEvent = function(event) if(event.phase == "ended") then composer.gotoScene("spriteTestLevel") end end,
	}
	comingSoon.testLevelButton:setFillColor( .8,.3,.3 )
	--]]
	comingSoon.level1Button = widget.newButton {
		x = display.contentWidth*1/3,
		y = display.contentHeight*3/4,
		width = 600,
	    height = 100,
	    id="level1Button",
		label = "Go to level 1",
		fontSize = 48,
		align = "center",
		labelColor = { default={ 0, 0, 0, 1 }, over={ 0, 0, 0, 1 } },
		sheet = globals.buttonSheet,
		defaultFrame = 1,
		overFrame = 2,
		onEvent = function(event) if(event.phase == "ended") then composer.gotoScene("level1") end end,
	}
	comingSoon.level1Button:setFillColor( .8,.3,.3 )

	--[[
	comingSoon.testLevelButton2 = widget.newButton {
		x = display.contentWidth*2/3,
		y = display.contentHeight*3/4,
		width = 600,
	    height = 100,
	    id="testLevel2",
		label = "Go to test screen #2",
		fontSize = 48,
		align = "center",
		labelColor = { default={ 0, 0, 0, 1 }, over={ 0, 0, 0, 1 } },
		sheet = globals.buttonSheet,
		defaultFrame = 1,
		overFrame = 2,
		onEvent = function(event) if(event.phase == "ended") then composer.gotoScene("tileTestLevel") end end,
	}
	comingSoon.testLevelButton2:setFillColor( .3,.8,.3 )
	--]]

	sceneGroup:insert(comingSoon.title)
	sceneGroup:insert(comingSoon.backButton)
	--sceneGroup:insert(comingSoon.testLevelButton)
	sceneGroup:insert(comingSoon.level1Button)
	--sceneGroup:insert(comingSoon.testLevelButton2)
	--sceneGroup:insert(comingSoon.textFade)
	--sceneGroup:insert(comingSoon.mousePrompter)
	--not necessary do to the constructor's "parent" parameter
end

function comingSoon.scene:destroy(event)
	for i = 1,table.getn(comingSoon.buttons) do
		comingSoon.buttons[i]:removeSelf()
	end
end

function comingSoon.scene:tap(event)
	print("tap (".. event.x .. ", " .. event.y .. ")")

	local tapText = display.newText{
		parent = self.view,
		text = "tap",
		fontSize = 30,
		align = "left",
		x = event.x,
		y = event.y,
	}
	helpers.spriteFadeOut(tapText)

	return true;
end

function comingSoon.scene:key(event)
	print(event.key)
	return true;
end

local hasCalledWithPhase = { will = false, did = false }

function comingSoon.scene:show( event )

	--display.setDefault("background",0.1,0.1,0.1)

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" and not hasCalledWithPhase["will"]) then
        -- Called when the scene is still off screen (but is about to come on screen).
        comingSoon.textFade.alpha=0
        comingSoon.mousePrompter.alpha=0;
        --print "will"
        hasCalledWithPhase["will"] = true
    elseif ( phase == "did" and not hasCalledWithPhase["did"]) then
        -- Called when the scene is now on screen.
        -- Insert code here to make the scene come alive.
        -- Example: start timers, begin animation, play audio, etc.
        helpers.spriteFadeIn(comingSoon.textFade,1000) --if we wanted to, we could work it so transition.to's params has the timer in {onComplete = }
        timer.performWithDelay( 1250, function() helpers.spriteFadeIn(comingSoon.mousePrompter,1000) end)
        --print "did"
        hasCalledWithPhase["did"] = true
    end
    return true
end


-- "scene:hide()"
function comingSoon.scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is on screen (but is about to go off screen).
        -- Insert code here to "pause" the scene.
        -- Example: stop timers, stop animation, stop audio, etc.
        --print "hide->will"
    elseif ( phase == "did" ) then
        -- Called immediately after scene goes off screen.
        --print "hide->did"
    end

    hasCalledWithPhase.will , hasCalledWithPhase.did = false , false;

    --return true
end
--[[
function comingSoon.newButton(rectArgs, textArgs)
	local button = display.newGroup()
	button.rect = display.newRect( unpack(rectArgs) )
	button:insert(button.rect)
	button.text = display.newText( textArgs )
	button:insert(button.rect)
	button.text:setFillColor(0)
	return button;
end
--]]

comingSoon.scene:addEventListener( "create", comingSoon.scene )
comingSoon.scene:addEventListener( "show", comingSoon.scene )
comingSoon.scene:addEventListener( "hide", comingSoon.scene )
comingSoon.scene:addEventListener( "destroy", comingSoon.scene )

return comingSoon;