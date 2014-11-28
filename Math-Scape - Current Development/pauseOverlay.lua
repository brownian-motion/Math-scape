local pauseOverlay = {}
local composer = require("composer")
pauseOverlay.scene = composer.newScene("pauseOverlay")


function catchBackgroundOverlay(event)
	return true
end
 
-- Called when the scene's view does not exist:
function pauseOverlay.scene:create( event )
	local sceneGroup = self.view

	local title = event.params.title
	local backButton = event.params.backButton
	local onReturn = event.params.onReturn; --to be called when the back button is pressed
	local exitTo = event.params.exitTo
	local effect = event.params.effect
	local time = event.params.time
	local currScene = event.params.currScene
	local resetScene = event.params.resetScene
	local timerID = event.params.timer
	require(exitTo)

	local backgroundOverlay = display.newRect( display.contentWidth/2, display.contentHeight/2, display.contentWidth, display.contentHeight )
	backgroundOverlay:setFillColor(0, 0, 0, .9)
	sceneGroup:insert(backgroundOverlay)

	titleText = display.newText(title, display.contentWidth/2, display.contentHeight/3, "Arial", 200)
    titleText:setFillColor(.8,.8,.8)
    sceneGroup:insert(titleText)


	exitButton = widget.newButton{
		x = display.contentWidth/2, 
		y = 2*display.contentHeight/3,
		width = 400,
		height = 100,
		id = "exit",
		label = "Exit",
		fontSize = 64,
		labelColor = { default={ 0, 0, 0, 1 }, over={ 0, 0, 0, 1 } },
		sheet = globals.buttonSheet,
		defaultFrame = 1,
		overFrame = 2,
		onRelease = function() composer.hideOverlay(true); composer.gotoScene(exitTo) if(resetScene) then composer.removeScene(currScene, true) end end
	}
	sceneGroup:insert(exitButton)
	if(backButton) then
        exitButton.x = 2*display.contentWidth/3
	    backButton = widget.newButton{
			x = display.contentWidth/3, 
			y = 2*display.contentHeight/3,
			width = 400,
			height = 100,
			id = "back",
			label = "Back",
			fontSize = 64,
			labelColor = { default={ 0, 0, 0, 1 }, over={ 0, 0, 0, 1 } },
			sheet = globals.buttonSheet,
			defaultFrame = 1,
			overFrame = 2,
			onRelease = function() 
				if(timerID) then
					timer.resume( timerID )
				end
				composer.hideOverlay(true, effect, time)
				if(type(onReturn) == "function") then onReturn(); end
			end
		}
		sceneGroup:insert(backButton)
    end
end

-- Called immediately after scene has moved onscreen:
function pauseOverlay.scene:show( event )
	local sceneGroup = self.view

end
 
 
-- Called when scene is about to move offscreen:
function pauseOverlay.scene:hide( event )
	local sceneGroup = self.view
 
end
 
 
-- Called prior to the removal of scene's "view" (display group)
function pauseOverlay.scene:destroy( event )
	local sceneGroup = self.view

end

-- "createScene" event is dispatched if scene's view does not exist
pauseOverlay.scene:addEventListener( "create", scene )
 
-- "enterScene" event is dispatched whenever scene transition has finished
pauseOverlay.scene:addEventListener( "show", scene )
 
-- "exitScene" event is dispatched before next scene's transition begins
pauseOverlay.scene:addEventListener( "hide", scene )
 
-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
pauseOverlay.scene:addEventListener( "destroy", scene )

return pauseOverlay.scene