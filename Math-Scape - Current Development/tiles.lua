--local image = display.newImageRect( "flower.jpg", display.contentWidth, display.contentHeight/2 )
--image.x = display.contentCenterX
--image.y = display.contentCenterY-display.contentHeight/4

local tiles = {} -- _2048 because 2048 would be a number
local composer = require("composer")
local pauseOverlay=require("pauseOverlay")
local widget = require( "widget" )
tiles.scene = composer.newScene("tiles")


-- -----------------------------------------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called.
-- -----------------------------------------------------------------------------------------------------------------

-- local forward references should go here

-- -------------------------------------------------------------------------------


-- "scene:create()"
function tiles.scene:create( event )

    local sceneGroup = self.view

    -- Initialize the scene here.
    -- Example: add display objects to "sceneGroup", add touch listeners, etc.

    globals.highscores = helpers.loadTable("scores.json")
    local score = 0
    local best = globals.highscores.Tiles or 0
    local lives = 3
    local countdown = 30


    display.setDefault("background",1,1,.9)

    local options =
    {
    -- The params below are required

        width = 640*3/2,
        height = 480*3/2,
        numFrames = 1,

        -- The params below are optional; used for dynamic resolution support

        sheetContentWidth = 640*3/2,  -- width of original 1x size of entire sheet
        sheetContentHeight = 480*3/2  -- height of original 1x size of entire sheet
    }



    local imageSheet = graphics.newImageSheet( "flower.jpg", options )


    local myImage = display.newImage( imageSheet, 1 )
    sceneGroup:insert(myImage)


    -- position the image
    myImage:translate( display.contentWidth/2,myImage.contentHeight/2+20)


    local scoreTextLabel = display.newText("Score",display.contentWidth/8,display.contentHeight/2-400, "Arial", 64)
    scoreTextLabel:setFillColor( 0 )
    sceneGroup:insert(scoreTextLabel)
    local scoreText = display.newText("0",display.contentWidth/8,display.contentHeight/2-300, "Arial", 128)
    scoreText:setFillColor( 0 )
    sceneGroup:insert(scoreText)
    local bestTextLabel = display.newText("Best",display.contentWidth/8,display.contentHeight/2-50, "Arial", 64)
    bestTextLabel:setFillColor( 0 )
    sceneGroup:insert(bestTextLabel)
    local bestText = display.newText(best,display.contentWidth/8,display.contentHeight/2+50, "Arial", 128)
    bestText:setFillColor( 0 )
    sceneGroup:insert(bestText)

    local livesTextLabel = display.newText("Lives",7*display.contentWidth/8,display.contentHeight/2-400, "Arial", 64)
    livesTextLabel:setFillColor( 0 )
    sceneGroup:insert(livesTextLabel)
    local livesText = display.newText(lives,7*display.contentWidth/8,display.contentHeight/2-300, "Arial", 128)
    livesText:setFillColor( 0 )
    sceneGroup:insert(livesText)
    local timeTextLabel = display.newText("Time",7*display.contentWidth/8,display.contentHeight/2-50, "Arial", 64)
    timeTextLabel:setFillColor( 0 )
    sceneGroup:insert(timeTextLabel)
    local timeText = display.newText("0",7*display.contentWidth/8,display.contentHeight/2+50, "Arial", 128)
    timeText:setFillColor( 0 )
    sceneGroup:insert(timeText)


    -- must have at LEAST 9 questions in the bank
    -- otherwise everything dies (we don't really know what will happen)
    local questionBank = {
        {q="There are 34 students sitting on the bleachers and 10 students sitting on the floor.\nWhat is the unsimplified ratio of the number of students sitting on the bleachers to the number of students sitting on the floor?", a="34:10"},
        {q="Erik's Pizzeria made 18 thin-crust pizzas and 20 thick-crust pizzas.\nWhat is the simplified ratio of the of thick-crust pizzas to the number of thin-crust pizzas?", a="10:9"},
        {q="There are 24 men and 9 women participating in a triathlon.\nWhat is the simplified ratio of the number of women participating to the number of men participating?", a="3:8"},
        {q="In a science class, the ratio of girls to boys is 5 to 8.\nIf there are 15 girls, how many boys are there?", a="24"},
        {q="The ratio of boys to girls in a particular organization is 2 to 3.\nIf there are a total of 20 students in the organization, how many girls are there?", a="8"},
        {q="The scale on a map is 6cm : 10km.\nIf the actual distance between two cities is 60km, how far apart (in cm) are the cities on the map?", a="36"},
        {q="The scale on a map is 6cm : 12km.\nIf the two cities are 9cm apart on the map, what is the actual distance (in km) between the two cities?", a="18"},
        {q="The ratio of girls to boys at the park is 3 to 4.\nThere are 12 boys at the park. What is the total number of children at the park?", a="21"},
        {q="There are 100 people working in the office. 40 of those workers are women.\nWhat is the ratio of men to women in the office?", a="3:2"},
        {q="50 men are currently on staff at a company.\nIf there are 70 people on staff, what is the ratio of women to men in the office?", a="2:5"}
    }

    local questions = {}
    local pastIndices = {}
    while #questions < 9 do
        local index = math.random(#questionBank)
        if(not helpers.tableContains(pastIndices,index)) then
            table.insert(questions, questionBank[index])
            table.insert(pastIndices, index)
        end
    end

    function shuffle(t)
        math.randomseed(os.time())
        assert(t, "table.shuffle() expected a table, got nil")
        local ret = table.copy(t)
        local iterations = #ret
        local j
        for i = iterations, 2, -1 do
                j = math.random(i)
                ret[i], ret[j] = ret[j], ret[i]
        end
        return ret
    end

    local questionsShuffled = shuffle(questions)

    local questionNum = 1
    local questionText = display.newText( {text=questionsShuffled[questionNum].q, x=display.contentWidth/2, y=display.contentHeight-250, width=display.contentWidth, font="Arial", fontSize=32, align="center"})
    questionText:setFillColor(0)
    sceneGroup:insert(questionText)

    local function updateTime()
        --timeText.text = math.round((system.getTimer()-questionStart)/1000)
        timeText.text = timeText.text + 1
    end

    local function restartTimer()
        if(timerID) then
            timer.cancel( timerID )
        end
        timeText.text = 0
        timerID = timer.performWithDelay( 1000, updateTime, -1 )
        if(pauseOptions) then
            pauseOptions.timer = timerID
        end
    end

    restartTimer()

    local tileButtons = {}

    local loseOptions =
    {
        isModal = true,
        effect = "slideDown",
        time = 200,
        params = {
            title="Game Over",
            backButton = false,
            exitTo = "minigames",
            effect = "slideUp",
            time = 200,
            currScene = "tiles",
            resetScene = true
        }
    }

    for i = 1, 9 do
        local button = widget.newButton
        {
            x=display.contentWidth/2 + (((i-1)%3 - 1) * (213*3/2)),
            y=(20+(160*3/4)) + (math.floor((i-1)/3)) * (160*3/2),
            width = 213*3/2,
            height = 160*3/2,
            defaultFile = "a"..i..".png",
            overFile = "a"..i..".png",
            label = questions[i].a,
            labelColor = { default={ .2, .2, .2 } },
            fontSize=64,
            --onEvent = handleButtonEvent
            onRelease = function(event)
                if(event.target:getLabel() == questionsShuffled[questionNum].a) then
                    event.target:removeSelf()
                    nextQuestion()
                    timeText.text = 0
                else
                    display.setDefault("background",1,0,0)
                    local function resetBackground()
                        display.setDefault("background",1,1,.9)
                    end
                    timer.performWithDelay(100, resetBackground)
                    lives = lives-1
                    livesText.text = lives
                    if(lives<=0) then
                        timer.cancel( timerID )
                        globals.highscores.Tiles = best
                        helpers.saveTable(globals.highscores, "scores.json")
                        composer.showOverlay( "pauseOverlay", loseOptions )
                    end
                end
            end
        }
        table.insert( tileButtons, button )
        sceneGroup:insert(button)
    end

    local winOptions =
    {
        isModal = true,
        effect = "slideDown",
        time = 200,
        params = {
            title="You Win!",
            backButton = false,
            exitTo = "minigames",
            effect = "slideUp",
            time = 200,
            currScene = "tiles",
            resetScene = true
        }
    }

    function nextQuestion()
        score = score + countdown - timeText.text
        scoreText.text = score
        if(score>best) then
            best = score
            bestText.text = best
        end

        if(questionNum<9) then
            questionNum = questionNum + 1.
            local function transitionFinished()
                questionText.x = -display.contentWidth*2
                questionText.y = display.contentHeight-250
                questionText.text = questionsShuffled[questionNum].q
            end
            transition.to( questionText, { time=250, y=0,alpha=0, onComplete=transitionFinished} )
            transition.to( questionText, { delay=250, time=500,x=display.contentWidth/2,y=display.contentHeight-250, alpha=1  } )
            restartTimer()
        else
            transition.to( questionText, { time=250, y=0,alpha=0} )
            timer.cancel( timerID )
            composer.showOverlay( "pauseOverlay", winOptions )
            globals.highscores.Tiles = best
            helpers.saveTable(globals.highscores, "scores.json")
        end
    end


    local pauseOptions =
    {
        isModal = true,
        effect = "slideDown",
        time = 200,
        params = {
            title="Paused",
            backButton = true,
            exitTo = "minigames",
            effect = "slideUp",
            time = 200,
            currScene = "tiles",
            resetScene = true,
            timer = timerID
        }
    }
    local pauseButton = widget.newButton{
        x = display.contentWidth/2, 
        y = display.contentHeight-100,
        --width = 400,
        --height = 100,
        id = "pause",
        label = "Pause",
        fontSize = 64,
        labelColor = { default={ 0, 0, 0, 1 }, over={ 0, 0, 0, 1 } },
        sheet = globals.buttonSheet,
        defaultFrame = 1,
        overFrame = 1,
        onRelease = function(event) timer.pause(timerID) composer.showOverlay( "pauseOverlay", pauseOptions ) end,
    }
    pauseButton:setFillColor( .5,.5,.6 )
    sceneGroup:insert(pauseButton)

end


-- "scene:show()"
function tiles.scene:show( event )
    -- Called when the scene is now on screen.
    -- Insert code here to make the scene come alive.
    -- Example: start timers, begin animation, play audio, etc.

    local sceneGroup = self.view

    local phase = event.phase
    if ( phase == "will" ) then
    -- Called when the scene is still off screen (but is about to come on screen).
    elseif ( phase == "did" ) then
    --local myImage = display.newImage( "flower.jpg"  )
    end

end


-- "scene:hide()"
function tiles.scene:hide( event )

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
function tiles.scene:destroy( event )

    local sceneGroup = self.view

    -- Called prior to the removal of scene's view ("sceneGroup").
    -- Insert code here to clean up the scene.
    -- Example: remove display objects, save state, etc.
end





-- -------------------------------------------------------------------------------

-- Listener setup
tiles.scene:addEventListener( "create", tiles.scene )
tiles.scene:addEventListener( "show", tiles.scene )
tiles.scene:addEventListener( "hide", tiles.scene )
tiles.scene:addEventListener( "destroy", tiles.scene )

-- -------------------------------------------------------------------------------

return tiles