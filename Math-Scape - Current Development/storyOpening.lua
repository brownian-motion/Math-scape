-----------------------------------------------------------------------------------------
--
-- storyOpening.lua
--
-----------------------------------------------------------------------------------------

local storyOpening = {}
local composer = require("composer")
local level1 = require("levels.level1.level1")
local levelEngine = require("levels.level_engine")
local sprites = require "sprites";
storyOpening.scene = composer.newScene("storyOpening")

function storyOpening.scene:create(event)

	local sceneGroup = self.view 

	sceneGroup:addEventListener("tap",storyOpening.scene) --this will call storyOpening.scene:tap() every time anything (*including the background or display objects) is tapped
	--this is preferrable to Runtime:addEventListener in that we don't have to get rid of it when we're done; it only exists with this scene's sceneGroup

	--test of key handlers
	sceneGroup:addEventListener("key",storyOpening.scene)

	--we need this so that the scene object has control of everything inside of it
	storyOpening.farBackground = display.newRect( display.screenOriginX+display.actualContentWidth/2,display.screenOriginY+display.actualContentHeight/2, display.actualContentWidth, display.actualContentHeight )
	storyOpening.farBackground:setFillColor(0.1,0.1,0.1);
	storyOpening.background = display.newImage( "assets/art/opening-cinematic.jpg" );
	local background = storyOpening.background;
	sprites.setSize( {}, background, {height = display.actualContentHeight});
	background.anchorX, background.anchorY = 0,0;
	background.x, background.y = (-background.width*background.xScale+display.actualContentWidth),(display.contentHeight- display.actualContentHeight)/2
	--background:setFillColor(0.1,0.1,0.1)
	background.alpha = 0;

	--[[
	storyOpening.title = display.newText{
		x=display.contentWidth/2,
		y=display.contentHeight/2-100,
		text="Coming Soon",
		fontSize=64
	}
	--]]

	--
	storyOpening.backButton = widget.newButton{
		x = display.contentWidth -250, 
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
	storyOpening.backButton.alpha = 0.0;
	storyOpening.backButton:setEnabled(false);
	--]]

	local textColorRGB = { 1.0, .95, .95 }

	--start text group one
	storyOpening.textGroupOne = display.newGroup()
	storyOpening.textFade1 = storyOpening.newShadowText{
		parent = storyOpening.textGroupOne,
		text = "I was trapped in a castle.",
		x = display.contentWidth/2,
		y = display.contentHeight*2/7 ,
		fontSize = display.contentHeight/20,
		align="center",
	}
	storyOpening.textFade1:setFillColor( unpack(textColorRGB) )
	storyOpening.textFade1.alpha=0;

	storyOpening.textFade2 = storyOpening.newShadowText{
		parent = storyOpening.textGroupOne,
		text = "The view was nice, but being trapped gets old after a while.",
		x = display.contentWidth/2,
		y = display.contentHeight*4/7,
		fontSize = display.contentHeight/20,
		align="center",
	}
	storyOpening.textFade2:setFillColor( unpack(textColorRGB) )
	storyOpening.textFade2.alpha=0;

	storyOpening.textFade3 = storyOpening.newShadowText{
		parent = storyOpening.textGroupOne,
		text = "I waited for a prince to save me.",
		x = display.contentWidth/2,
		y = display.contentHeight*5/7,
		fontSize = display.contentHeight/20,
		align="center",
	}
	storyOpening.textFade3:setFillColor( unpack(textColorRGB))
	storyOpening.textFade3.alpha=0;
	--end text group one

	--start text group two
	storyOpening.textGroupTwo = display.newGroup()
	storyOpening.textFade4 = storyOpening.newShadowText{
		parent = storyOpening.textGroupTwo,
		text = "I waited for days...",
		x = display.contentWidth/2,
		y = display.contentHeight*2/8 ,
		fontSize = display.contentHeight/20,
		align="center",
	}
	storyOpening.textFade4:setFillColor( unpack(textColorRGB) )
	storyOpening.textFade4.alpha=0;

	storyOpening.textFade5 = storyOpening.newShadowText{
		parent = storyOpening.textGroupTwo,
		text = "But no one came.",
		x = display.contentWidth/2,
		y = display.contentHeight*4/8,
		fontSize = display.contentHeight/20,
		align="center",
	}
	storyOpening.textFade5:setFillColor( unpack(textColorRGB) )
	storyOpening.textFade5.alpha=0;

	storyOpening.textFade6 = storyOpening.newShadowText{
		parent = storyOpening.textGroupTwo,
		text = "I resolved to rescue\nMYSELF.",
		x = display.contentWidth/2,
		y = display.contentHeight*6/7,
		fontSize = display.contentHeight/20,
		align="center",
	}
	storyOpening.textFade6:setFillColor( unpack(textColorRGB) )
	storyOpening.textFade6.alpha=0;
	--end text group two

	--[[
	storyOpening.testLevelButton = widget.newButton {
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
	storyOpening.testLevelButton:setFillColor( .8,.3,.3 )
	--]]
	storyOpening.level1Button = widget.newButton {
		x = 250,
		y = display.contentHeight-100,
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
		onEvent = function(event) if(event.phase == "ended") then 
			composer.setVariable(globals.GET_CURRENT_LEVEL_NAME,"level1");
			composer.setVariable(globals.GET_CURRENT_LEVEL_NUMBER,1);
			composer.gotoScene("story mode"); end end,
	}
	storyOpening.level1Button:setFillColor( .8,.3,.3 )
	storyOpening.level1Button:setEnabled( false )
	storyOpening.level1Button.alpha = 0;


	--[[
	storyOpening.testLevelButton2 = widget.newButton {
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
	storyOpening.testLevelButton2:setFillColor( .3,.8,.3 )
	--]]

	sceneGroup:insert(storyOpening.farBackground)
	sceneGroup:insert(storyOpening.background)

	--sceneGroup:insert(storyOpening.title)
	sceneGroup:insert(storyOpening.backButton)
	--sceneGroup:insert(storyOpening.testLevelButton)
	sceneGroup:insert(storyOpening.level1Button)
	--sceneGroup:insert(storyOpening.testLevelButton2)
	--sceneGroup:insert(storyOpening.textFade)
	--sceneGroup:insert(storyOpening.mousePrompter)
	sceneGroup:insert(storyOpening.textGroupOne)
	sceneGroup:insert(storyOpening.textGroupTwo)
	--not necessary do to the constructor's "parent" parameter
end

function storyOpening.scene:destroy(event)
	for i = 1,table.getn(storyOpening.buttons) do
		storyOpening.buttons[i]:removeSelf()
	end
end

function storyOpening.scene:tap(event)
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

function storyOpening.scene:key(event)
	print(event.key)
	    if(event.keyName == "space") then transition.resume("start");
	elseif(event.keyName == "back") then composer.gotoScene("menu");
	end
	return true;
end

local hasCalledWithPhase = { will = false, did = false }

function storyOpening.scene:show( event )

	--display.setDefault("background",0.1,0.1,0.1)

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" and not hasCalledWithPhase["will"]) then
        -- Called when the scene is still off screen (but is about to come on screen).
        --print "will"
        hasCalledWithPhase["will"] = true
        transition.to( storyOpening.background, {tag = "fade in", time = 5000, alpha = 1.0, transition=easing.inQuad , onComplete = function() transition.resume("textFade1") end} )
        transition.to( storyOpening.background, {tag="cinematic pan",
        	x = 0;
        	time = 25000,
        	transition = easing.inOutSine,
        	})
        transition.to( storyOpening.textFade1, {tag = "textFade1", time = 1000, alpha = 1.0, transition=easing.inQuad , onComplete = function() timer.performWithDelay(1000, function() transition.resume("textFade2") end) end} )
        transition.to( storyOpening.textFade2, {tag = "textFade2", time = 1000, alpha = 1.0, transition=easing.inQuad , onComplete = function() timer.performWithDelay(1000, function() transition.resume("textFade3") end) end} )
        transition.to( storyOpening.textFade3, {tag = "textFade3", time = 1000, alpha = 1.0, transition=easing.inQuad , onComplete = function() timer.performWithDelay(2000, function() transition.resume("textGroupOne") end) end} )
        transition.to( storyOpening.textGroupOne, {tag = "textGroupOne", time = 1000, alpha = 0.0, transition=easing.outQuad , onComplete = function() timer.performWithDelay(1000, function() transition.resume("textFade4") end) end} )
        transition.to( storyOpening.textFade4, {tag = "textFade4", time = 1000, alpha = 1.0, transition=easing.inQuad , onComplete = function() timer.performWithDelay(1000, function() transition.resume("textFade5") end) end} )
        transition.to( storyOpening.textFade5, {tag = "textFade5", time = 1000, alpha = 1.0, transition=easing.inQuad , onComplete = function() timer.performWithDelay(1000, function() transition.resume("textFade6") end) end} )
        transition.to( storyOpening.textFade6, {tag = "textFade6", time = 1000, alpha = 1.0, transition=easing.inQuad , onComplete = function() timer.performWithDelay(1000, function() transition.resume("textGroupTwo") end) end} )
        transition.to( storyOpening.textGroupTwo, {tag = "textGroupTwo", time = 1000, alpha = 1.0, transition=easing.outQuad , onComplete = function() timer.performWithDelay(1000, function() transition.resume("start") end) end} )
        transition.to( storyOpening.level1Button, {tag = "start", time = 500, alpha = 1.0, onComplete = function() storyOpening.level1Button:setEnabled(true) end})
        transition.to( storyOpening.backButton, {tag = "start", time = 500, alpha = 0.3, onComplete = function() storyOpening.backButton:setEnabled(true) end})
        transition.pause()
    elseif ( phase == "did" and not hasCalledWithPhase["did"]) then
        -- Called when the scene is now on screen.
        -- Insert code here to make the scene come alive.
        -- Example: start timers, begin animation, play audio, etc.
        --helpers.spriteFadeIn(storyOpening.textFade,1000) --if we wanted to, we could work it so transition.to's params has the timer in {onComplete = }
        --timer.performWithDelay( 1250, function() helpers.spriteFadeIn(storyOpening.mousePrompter,1000) end)
        local background = storyOpening.background;
        transition.resume("fade in")
        transition.resume("cinematic pan")
        --print "did"
        hasCalledWithPhase["did"] = true
    end
    return true
end


-- "scene:hide()"
function storyOpening.scene:hide( event )

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

function storyOpening.newShadowText( textOptions )
	local group = display.newGroup( );

	local parent = textOptions.parent;
	textOptions.parent = nil;
	if(parent) then parent:insert(group); end

	local offset = textOptions.offset or 3;
	textOptions.offset = nil;
	local text = display.newText( textOptions )

	textOptions.x = textOptions.x + offset;
	textOptions.y = textOptions.y + offset;

	local shadow = display.newText( textOptions )

	group:insert(shadow);
	group.shadow=shadow;
	group:insert(text);
	group.text = text;

	function group:setFillColor( ... )
		text:setFillColor( ... );
	end

	shadow:setFillColor( .1, .1, .1);

	return group;
end
--[[
function storyOpening.newButton(rectArgs, textArgs)
	local button = display.newGroup()
	button.rect = display.newRect( unpack(rectArgs) )
	button:insert(button.rect)
	button.text = display.newText( textArgs )
	button:insert(button.rect)
	button.text:setFillColor(0)
	return button;
end
--]]

storyOpening.scene:addEventListener( "create", storyOpening.scene )
storyOpening.scene:addEventListener( "show", storyOpening.scene )
storyOpening.scene:addEventListener( "hide", storyOpening.scene )
storyOpening.scene:addEventListener( "destroy", storyOpening.scene )

return storyOpening;