-----------------------------------------------------------------------------------------
--
-- 2048.lua
--
-----------------------------------------------------------------------------------------

local _2048 = {} -- _2048 because 2048 would be a number
local composer = require("composer")
_2048.scene = composer.newScene("2048")


-- -----------------------------------------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called.
-- -----------------------------------------------------------------------------------------------------------------

-- local forward references should go here

-- -------------------------------------------------------------------------------


-- "scene:create()"
function _2048.scene:create( event )

    local sceneGroup = self.view
    -- Initialize the scene here.
    -- Example: add display objects to "sceneGroup", add touch listeners, etc.

    local grid
    --padding between the cells, and between the cells and the wall
    local CELL_PADDING = 25 
    --size of each cell, adjusted for padding
    local CELL_SIZE = (display.contentHeight - (5 * CELL_PADDING)) / 4
    --empty cells in the grid will be initialized with value 0
    local EMPTY_CELL = 0
    --rect that is a backround for score (used for centering scoreText)
    local scoreRect
    --text to display score in bottom right corner
    local scoreText
    local score
    local bestRect
    --text to display score in bottom right corner
    local bestText
    local best
    --displays 2048 during game, "Game Over!" if you lose, and "You Win!" if you win (you wont)
    local titleText
    --animation steps it takes to complete a slide
    local SLIDE_STEPS = 7
    --delay between steps of slide animation
    local ANIMATION_DELAY_SLIDE = 3
    --animation steps it takes to complete a cell birth
    local BIRTH_STEPS = 5
    --delay between steps of birth animation
    local ANIMATION_DELAY_BIRTH = 2
    --flag so we don't allow multiple slides at once
    local currentlyAnimating = false
    --number of cells with non zero value
    local cellCount = 0
    --highest value on the board
    local highestValue = 0
    --game over flag
    local gameOver = false

    --[[local fonts = native.getFontNames()
    for i = 1, #fonts do
        print(fonts[i])
    end]]--  


    --maps a tiles value to it its color

    local VAL_TO_COLOR = {
        _0 = {204/255, 192/255, 179/255},
        _2 = {238/255, 228/255, 218/255},
        _4 = {237/255, 224/255, 200/255},
        _8 = {242/255, 177/255, 121/255},
        _16 = {245/255, 149/255, 99/255},
        _32 = {246/255, 124/255, 95/255},
        _64 = {246/255, 94/255, 59/255},
        _128 = {237/255, 207/255, 114/255},
        _256 = {237/255, 204/255, 97/255},
        _512 = {237/255, 200/255, 80/255},
        _1024 = {237/255, 197/255, 63/255},
        --assumed color (never actually seen a 2048 lol)
        _2048 = {237/255, 194/255, 46/255}
    }

    function VAL_TO_COLOR.RGB (name)
        return VAL_TO_COLOR[name][1],VAL_TO_COLOR[name][2],VAL_TO_COLOR[name][3]
    end

    function start()
        score = 0
        best = 0 -- THIS NEEDS TO BE FILLED WITH STORED DATA
        --grid = {{}}
        grid = {}
        for i = 1, 4 do
            grid[i] = {}

            for j = 1, 4 do
                grid[i][j] = {} -- Fill the values here
            end
        end
        --canvas has height of 480, width of 400
        gridInit()
        --Runtime:addEventListener( "touch", swipeHandler )
        --Runtime:removeEventListener( "key", inputs.onKeyEvent )
        --Runtime:addEventListener( "key", keyHandler )
        --keyDownMethod(keyHandler)
    end

    --[[
        Sets up grid for the first time, draws background and
        empty cells.
    ]]--
    function gridInit() 
        --draw grey background
        local rect = display.newRect(display.contentWidth/2,display.contentHeight/2,display.contentHeight, display.contentHeight)
        rect:setFillColor(187/255, 173/255, 160/255)
        sceneGroup:insert(rect)
        
    --[[
        This is a bit of a kludge. We draw a grid of grey empty cells over the 
        background, then do it again in the grid fill. These squares are static and
        will not move, while the other grid cells do. These are necessary for a 
        smooth animation sequence. I need to refactor some internal data structures
        to eliminate the need for these.
    ]]--
         
        for i = 1, 4 do
            for j = 1, 4 do
                local emptyCell = display.newRect(0, 0, CELL_SIZE, CELL_SIZE)
                emptyCell.x = ((display.contentWidth-display.contentHeight)/2) + ((j-1) * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING + CELL_SIZE/2
                emptyCell.y = ((i-1) * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING + CELL_SIZE/2
                emptyCell:setFillColor(VAL_TO_COLOR.RGB("_0"))
                sceneGroup:insert(emptyCell)
            end
        end
        
        
        --add "2048" at the bottom left corner
        --titleText = display.newText("2048", CELL_PADDING, display.contentWidth + ((display.contentHeight - display.contentWidth)/2) + (titleText.height / 3), "Arial", 50)
        
        local titleOptions = {
            text = "2048",     
            x = (display.contentWidth-display.contentHeight)/4,
            y = display.contentHeight/2,
            width = display.contentHeight,     --required for multi-line and alignment
            font = "Arial",   
            fontSize = 150,
            align = "center"  --new alignment parameter
        }
        titleText = display.newText(titleOptions)
        titleText:rotate( -90 )
        titleText:setFillColor(119/255,110/255,101/255)
        
        sceneGroup:insert(titleText)

        --add the score background
        --scoreRect = display.newRect(display.contentWidth - scoreRect.width - (CELL_PADDING), display.contentWidth + CELL_PADDING, 150, display.contentHeight - display.contentWidth - (2 * CELL_PADDING))
        scoreRect = display.newRect(display.contentWidth-((display.contentWidth-display.contentHeight)/4), 2*CELL_PADDING + (3/2)*CELL_SIZE, ((display.contentWidth-display.contentHeight)/2)-(2*CELL_PADDING), CELL_SIZE)
        scoreRect:setFillColor(187/255,173/255,160/255)
        sceneGroup:insert(scoreRect)
        --add score text
        --local scoreLabelText = display.newText("SCORE", scoreRect.x + (scoreRect.width /2) - (scoreLabelText.width / 2), scoreRect.y + scoreLabelText.height, "Arial", 11)
        local scoreLabelText = display.newText("SCORE", scoreRect.x, scoreRect.y - (scoreRect.height / 2) + 50 , "Arial", 50)
        scoreLabelText:setFillColor(238/255, 228/255, 218/255)
        sceneGroup:insert(scoreLabelText)
        --add score value text, set position every time we update it
        scoreText = display.newText("0", scoreRect.x, scoreRect.y + 50, "Arial", 100)
        scoreText:setFillColor(1)
        sceneGroup:insert(scoreText)

        --add the score background
        --scoreRect = display.newRect(display.contentWidth - scoreRect.width - (CELL_PADDING), display.contentWidth + CELL_PADDING, 150, display.contentHeight - display.contentWidth - (2 * CELL_PADDING))
        bestRect = display.newRect(display.contentWidth-((display.contentWidth-display.contentHeight)/4), 3*CELL_PADDING + (5/2)*CELL_SIZE, ((display.contentWidth-display.contentHeight)/2)-(2*CELL_PADDING), CELL_SIZE)
        bestRect:setFillColor(187/255,173/255,160/255)
        sceneGroup:insert(bestRect)
        --add score text
        --local bestLabelText = display.newText("SCORE", bestRect.x + (bestRect.width /2) - (bestLabelText.width / 2), bestRect.y + bestLabelText.height, "Arial", 11)
        local bestLabelText = display.newText("BEST", bestRect.x, bestRect.y - (bestRect.height / 2) + 50 , "Arial", 50)
        bestLabelText:setFillColor(238/255, 228/255, 218/255)
        sceneGroup:insert(bestLabelText)
        --add score value text, set position every time we update it
        bestText = display.newText("0", bestRect.x, bestRect.y + 50, "Arial", 100)
        bestText:setFillColor(1)
        sceneGroup:insert(bestText)
        
        --add empty cell squares
        for i = 1, 4 do
            for j = 1, 4 do
                local cell = {}
                --find the middle of each cell
                local cellX = ((display.contentWidth-display.contentHeight)/2) + ((j-1) * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING + CELL_SIZE/2
                local cellY = ((i-1) * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING + CELL_SIZE/2
                cell.row = i
                cell.col = j
                --size is grown by birth animation
                cell.rect = display.newRect(cellX, cellY, 0, 0)
                cell.value = 0
                cell.text = display.newText("", cellX, cellY, "Arial", 100)
                --neither rect nor text has been added to canvas, this doesn't matter
                cell.text:setFillColor(119/255,110/255,101/255)
                cell.rect:setFillColor(VAL_TO_COLOR.RGB("_0"))
                cell.hasCombined = false
                grid[i][j] = cell
            end
        end
        --add two random cells to grid
        addRandomCell()
        addRandomCell()
    end

    function printGrid()
        for i = 1, 4 do
            line = ""
            for j = 1, 4 do
                line = line..grid[i][j].value.." "
            end
            print(line)
        end
    end

    function addRandomCell() 
        --naive random, keep rolling until we land an empty cell
        local row = math.random(1, 4)
        local col = math.random(1, 4)
        while (grid[row][col].value ~= EMPTY_CELL) do
            row = math.random(1, 4)
            col = math.random(1, 4)
        end
        --get the rect at this particular cell
        local cell = grid[row][col]

        --if(cell.rect==nil) then
            --find the middle of each cell
            local cellX = ((display.contentWidth-display.contentHeight)/2) + ((col-1) * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING + CELL_SIZE/2
            local cellY = ((row-1) * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING + CELL_SIZE/2
            cell.row = row
            cell.col = col
            --size is grown by birth animation
            cell.rect = display.newRect(cellX, cellY, 0, 0)
            cell.value = 0
            --neither rect nor text has been added to canvas, this doesn't matter
            cell.rect:setFillColor(VAL_TO_COLOR.RGB("_0"))
        --end

        --determine whether new cell is a 2 or 4
        local chance = math.random(1, 100)
        if (chance < 75) then
            cell.rect:setFillColor(VAL_TO_COLOR.RGB("_2"))
            cell.value = 2
            cell.text.text = "2"
        else
            --rolled a four
            cell.rect:setFillColor(VAL_TO_COLOR.RGB("_4"))
            cell.value = 4
            cell.text.text = "4"
        end
        cell.rect.x = ((display.contentWidth-display.contentHeight)/2) + ((cell.col-1) * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING + CELL_SIZE/2
        cell.rect.y = ((cell.row-1) * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING + CELL_SIZE/2
        --controls the animation of the birth of new cells
        function birthAnimation() 
            local size = cell.rect.width
            local oldX = cell.rect.x
            local oldY = cell.rect.y
            if (size == CELL_SIZE) then
                timer.cancel(birthAnimationID)
                cell.text:setFillColor(119/255,110/255,101/255)
                cell.rect.x = ((display.contentWidth-display.contentHeight)/2) + ((cell.col-1) * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING + CELL_SIZE/2
                cell.rect.y = ((cell.row-1) * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING + CELL_SIZE/2
                cell.text.x = cell.rect.x
                cell.text.y = cell.rect.y
                sceneGroup:insert(cell.text)
                currentlyAnimating = false
            
            else 
                display.remove(cell.rect)
                cell.rect = display.newRect(0, 0, size + (CELL_SIZE / BIRTH_STEPS), size + (CELL_SIZE / BIRTH_STEPS))
                cell.rect.x = ((display.contentWidth-display.contentHeight)/2) + ((cell.col-1) * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING + CELL_SIZE/2
                cell.rect.y = ((cell.row-1) * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING + CELL_SIZE/2
                cell.rect:setFillColor(VAL_TO_COLOR.RGB("_"..cell.value))
                sceneGroup:insert(cell.rect)
            end
        end
        if (cellCount >= 2) then
            currentlyAnimating = true
            cell.rect = display.newRect(0, 0, 0, 0)
            cell.rect.x = ((display.contentWidth-display.contentHeight)/2) + ((cell.col-1) * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING + CELL_SIZE/2
            cell.rect.y = ((cell.row-1) * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING + CELL_SIZE/2
            cell.text.x = cell.rect.x
            cell.text.y = cell.rect.y
            sceneGroup:insert(cell.rect)
            birthAnimationID = timer.performWithDelay(ANIMATION_DELAY_BIRTH, birthAnimation, -1)
        else
            cell.rect = display.newRect(0, 0, CELL_SIZE, CELL_SIZE)
            cell.rect.x = ((display.contentWidth-display.contentHeight)/2) + ((cell.col-1) * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING + CELL_SIZE/2
            cell.rect.y = ((cell.row-1) * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING + CELL_SIZE/2
            cell.rect:setFillColor(VAL_TO_COLOR.RGB("_"..cell.value))
            cell.text.x = cell.rect.x
            cell.text.y = cell.rect.y
            sceneGroup:insert(cell.rect)
            sceneGroup:insert(cell.text)
            currentlyAnimating = false
        end
        cellCount = cellCount + 1
        --print("birth:")
        --printGrid()
    end


    --[[
    function keyHandler(e)
        if (!currentlyAnimating and !gameOver) then
            if(e.keyCode == Keyboard.DOWN) then
                currentlyAnimating = true
                shiftDown()
                break
            elseif(e.keyCode == Keyboard.UP) then
                currentlyAnimating = true
                shiftUp()
                break
            elseif(e.keyCode == Keyboard.RIGHT) then
                currentlyAnimating = true
                shiftRight()
                break
            elseif(e.keyCode == Keyboard.LEFT) then
                currentlyAnimating = true
                shiftLeft()
                break
            end
        end
    end
    ]]--

    function _2048.scene:onKeyEvent(event)
        if(event.keyName == "`" and event.phase == "down") then
                globals.debugConsole.isVisible = not globals.debugConsole.isVisible
        elseif (event.keyName == "menu" and event.phase == "down") then
                print ("menu button detected")
                globals.debugConsole.isVisible = not globals.debugConsole.isVisible
        elseif (not currentlyAnimating and not gameOver) then
            if     ((event.keyName == "up" or event.keyName == "") and event.phase == "down") then
                currentlyAnimating = true
                shiftUp()
            elseif ((event.keyName == "down" or event.keyName == "") and event.phase == "down") then
                currentlyAnimating = true
                shiftDown()
            elseif ((event.keyName == "left" or event.keyName == "") and event.phase == "down") then
                currentlyAnimating = true
                shiftLeft()
            elseif ((event.keyName == "right" or event.keyName == "") and event.phase == "down") then
                currentlyAnimating = true
                shiftRight()
            end
        end
        return false
    end

    --[[
    function swipeHandler( self, event )
        if event.phase == "ended" then
            if event.xStart < event.x and (event.x - event.xStart) >= 100 then
                currentlyAnimating = true
                shiftRight()
            elseif event.xStart > event.x and (event.xStart - event.x) >= 100 then
                currentlyAnimating = true
                shiftLeft()
            elseif event.yStart < event.y and (event.y - event.yStart) >= 100 then
                currentlyAnimating = true
                shiftDown()
            elseif event.yStart > event.y and (event.yStart - event.y) >= 100 then
                currentlyAnimating = true
                shiftUp()
            end
        end
    end
    ]]--

    function moveCell(cellFrom, cellTo)
        local oldRow = cellFrom.row
        local oldCol = cellFrom.col
        local oldX = cellFrom.rect.x
        local oldY = cellFrom.rect.y
        cellFrom.row = cellTo.row
        cellFrom.col = cellTo.col
        cellTo.row = oldRow
        cellTo.col = oldCol
        --cellTo.rect.setPosition(oldX, oldY)
        grid[cellTo.row][cellTo.col] = cellTo
        grid[cellFrom.row][cellFrom.col] = cellFrom
    end

    function combineCells(cellSingle, cellDouble)
        local doubleValue = cellSingle.value * 2
        cellSingle.value = 0
        cellDouble.value = doubleValue
        cellDouble.hasCombined = true
        
        if (doubleValue > highestValue) then
            highestValue = doubleValue
        end
    end

    function addToScore(inc)
        score = score + inc
        scoreText.text = score
        if(score>best) then
            best = score
            bestText.text = best
        end
    end

    --[[
        animation controller = {
            int initialX
            int initialY
            int finalX
            int finalY
            int dx
            int dy
            int combonationCount
            Cell cell
        }    
    ]]--

    function animateSlide(controllerList)
        local stepsLeft = SLIDE_STEPS
        --[[
            Actually animates the blocks. Steps through the controller list and moves
            each by dx, dy. Decrements stepsLeft. Stops itself when animation complete.
        ]]--
        function timerFunction()
            if (stepsLeft <= 0) then
                timer.cancel(timerFunctionID)
                for i = 1,#controllerList do
                    local controller = controllerList[i]
                    --check if we should combine cells
                    if (controller.combines == true) then
                        local cell = controller.cell
                        local cellDouble = controller.combinesWith
                        --remove this cell, upgrade the cell it combines with
                        cell.rect:setFillColor(VAL_TO_COLOR.RGB("_0"))
                        cell.value=0
                        cell.text.text = ""
                        display.remove(cell.rect)
                        --display.remove(cell.text)
                        cellCount = cellCount-1
                        cellDouble.text.text = cellDouble.value
                        cellDouble.text.x = cellDouble.rect.x
                        cellDouble.text.y = cellDouble.rect.y
                        cellDouble.rect:setFillColor(VAL_TO_COLOR.RGB("_"..cellDouble.value))
                        if (cellDouble.value > 4) then
                            cellDouble.text:setFillColor(1)
                        end
                        --update score
                        addToScore(cellDouble.value)
                    end
                end
                --add new cell
                if (highestValue == 2048) then
                    gameOver = true
                    print("You Win!")
                    titleText.text = "You Win!"
                    
                else
                    for i = 1, 4 do
                        for j = 1, 4 do
                            local cell = grid[i][j]
                            cell.hasCombined = false
                        end
                    end
                    addRandomCell()
                    if (cellCount == 16) then
                        --[[
                            if the sixteenth cell was just added (board is full), we have to do a full check to see
                            if a move is still possible. If it is, the game continues. If not, game over.
                        ]]--
                        if (not movePossible()) then
                            gameOver = true
                            print("Game Over!")
                            titleText.text = "Game Over!"
                        end
                    end
                end
            else
                for i = 1, #controllerList do
                    local controller = controllerList[i]
                    shiftCell(controller.cell, controller.dx, controller.dy)
                end
                stepsLeft = stepsLeft - 1
            end
        end
        --[[
            Caclulate dx, dy for each member of the controller list.
            naive, doesn't take into account cell combanations.
        ]]--
        for i = 1, #controllerList do
            local controller = controllerList[i]
            controller.dx = (controller.finalX - controller.initialX) / (SLIDE_STEPS)
            controller.dy = (controller.finalY - controller.initialY) / (SLIDE_STEPS)
        end
        timerFunctionID = timer.performWithDelay(ANIMATION_DELAY_SLIDE, timerFunction, -1)
        --print("move:")
        --printGrid()
    end

    --[[
        returns true if a move is still possible, ie there exist adjacent cells with the same value.
        returns false otherwise. Used in animateSlide for end of game check.
    ]]--
    function movePossible() 
        for i = 1, 4 do
            for j = 1, 4 do
                local cellVal = grid[i][j].value
                if (i > 1 and grid[i - 1][j].value == cellVal) then
                    return true
                end
                if (i < 4 and grid[i + 1][j].value == cellVal) then
                    return true
                end
                if (j > 1 and grid[i][j - 1].value == cellVal) then
                    return true
                end
                if (j < 4 and grid[i][j + 1].value == cellVal) then
                    return true
                end
            end
        end
        return false
    end


    --[[
        Moves a cell by dx, dy. Used for animating slides. Assume dx, dy is the amount
        to move the cell as defined by the bounding rectangle. Internal text will
        have to be moved a different amount
    ]]--
    function shiftCell(cell, dx, dy)
        --cell.rect.x = cell.rect.x + dx
        --cell.rect.y = cell.rect.y + dy
        cell.rect:translate(dx,dy)
        --use a raw setPos instead of move. not sure if performance difference.
        --cell.text.x = cell.text.x + dx
        --cell.text.y = cell.text.y + dy
        cell.text:translate(dx,dy)
    end


    --[[
        Shifts the entire grid down, combines blocks if necessary 
    ]]--
    function shiftDown()
        --[[Loop through the columns, starting at the bottom row. If cell is empty,
            move block into cell. If cell is occupied, check if blocks combine.
         ]]--
        local controllerList = {}
        for col = 1, 4 do
            for row = 4, 1, -1 do
                --look for occupied cell
                if grid[row][col].value ~= 0 then
                    local needsController = false
                    local cell = grid[row][col]
                    --init animation contoller with cell's initial info
                    local controller = {}
                    controller.cell = cell
                    controller.initialX = cell.rect.x
                    controller.initialY = cell.rect.y
                    controller.combines = false
                    while (cell.row < 4 and grid[cell.row + 1][col].value == 0) do
                        --update controller ending location
                        controller.finalX = ((display.contentWidth-display.contentHeight)/2) + ((cell.col-1) * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING + CELL_SIZE/2
                        controller.finalY = ((cell.row) * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING + CELL_SIZE/2
                        --move block as much as we are able to
                        moveCell(cell, grid[cell.row + 1][cell.col])
                        needsController = true
                    end
                    --combine blocks if possible
                    if (cell.row ~= 4 and cell.value == grid[cell.row + 1][col].value) then
                        if (grid[cell.row + 1][cell.col].hasCombined == false) then
                            controller.finalX = ((display.contentWidth-display.contentHeight)/2) + ((cell.col-1) * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING + CELL_SIZE/2
                            controller.finalY = ((cell.row) * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING + CELL_SIZE/2
                            needsController = true
                            controller.combines = true
                            controller.combinesWith = grid[cell.row + 1][cell.col]
                            combineCells(cell, grid[cell.row + 1][cell.col])
                        end
                    end
                    --push controller to be animated
                    if (needsController) then
                        table.insert(controllerList, controller)
                    end
                end
            end
        end
        if (#controllerList > 0) then
            animateSlide(controllerList)
        else
            currentlyAnimating = false
        end
    end

    function shiftUp()
        local controllerList = {}
        for col = 1, 4 do
            for row = 1, 4 do
                --look for occupied cell
                if (grid[row][col].value ~= 0) then
                    local cell = grid[row][col]
                    local needsController = false
                    local cell = grid[row][col]
                    --init animation contoller with cell's initial info
                    local controller = {}
                    controller.cell = cell
                    controller.initialX = cell.rect.x
                    controller.initialY = cell.rect.y
                    controller.combines = false
                    while (cell.row > 1 and grid[cell.row - 1][col].value == 0) do
                        --update controller ending location
                        controller.finalX = ((display.contentWidth-display.contentHeight)/2) + ((cell.col-1) * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING + CELL_SIZE/2
                        controller.finalY = ((cell.row-2) * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING + CELL_SIZE/2
                        needsController = true
                        --update data structure, to other blocks it appears this block has moved
                        moveCell(cell, grid[cell.row - 1][cell.col])
                    end
                    --combine blocks if possible
                    if (cell.row ~= 1 and cell.value == grid[cell.row - 1][col].value) then
                        if (grid[cell.row -1][cell.col].hasCombined == false) then
                            --update controller ending location, specify combo animation
                            controller.finalX = ((display.contentWidth-display.contentHeight)/2) + ((cell.col-1) * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING + CELL_SIZE/2
                            controller.finalY = ((cell.row-2) * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING + CELL_SIZE/2
                            needsController = true
                            controller.combines = true
                            controller.combinesWith = grid[cell.row - 1][cell.col]
                            combineCells(cell, grid[cell.row - 1][cell.col])
                        end
                    end
                    --push controller to be animated
                    if (needsController) then
                        table.insert(controllerList, controller)
                    end
                end
            end
        end
        if (#controllerList > 0) then
            
            animateSlide(controllerList)
        else
            currentlyAnimating = false
        end
    end

    function shiftLeft()
        local controllerList = {}
        for row = 1, 4 do
            for col = 1, 4 do
                --look for occupied cell
                if (grid[row][col].value ~= 0) then
                    local needsController = false
                    local cell = grid[row][col]
                    --init animation contoller with cell's initial info
                    local controller = {}
                    controller.cell = cell
                    controller.initialX = cell.rect.x
                    controller.initialY = cell.rect.y
                    controller.combines = false
                    while (cell.col > 1 and grid[cell.row][cell.col - 1].value == 0) do
                        --update controller ending location
                        controller.finalX = ((display.contentWidth-display.contentHeight)/2) + ((cell.col-2) * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING + CELL_SIZE/2
                        controller.finalY = ((cell.row-1) * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING + CELL_SIZE/2
                        needsController = true
                        --move block as much as we are able to
                        moveCell(cell, grid[cell.row][cell.col - 1])
                    end
                    --combine blocks if possible
                    if (cell.col ~= 1 and cell.value == grid[cell.row][cell.col - 1].value) then
                        if (grid[cell.row][cell.col - 1].hasCombined == false) then
                            --update controller ending location, specify combo animation
                            controller.finalX = ((display.contentWidth-display.contentHeight)/2) + ((cell.col-2) * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING + CELL_SIZE/2
                            controller.finalY = ((cell.row-1) * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING + CELL_SIZE/2
                            needsController = true
                            controller.combines = true
                            controller.combinesWith = grid[cell.row][cell.col - 1]
                            combineCells(cell, grid[cell.row][cell.col - 1])
                        end
                    end
                    --push controller to be animated
                    if (needsController) then
                        table.insert(controllerList, controller)
                    end
                end
            end
        end
        if (#controllerList > 0) then
            
            animateSlide(controllerList)
        else
            currentlyAnimating = false
        end
    end

    function shiftRight()
        local controllerList = {}
        for row = 1, 4 do
            for col = 4, 1, -1 do
                --look for occupied cell
                if (grid[row][col].value ~= 0) then
                    local needsController = false
                    local cell = grid[row][col]
                    --init animation contoller with cell's initial info
                    local controller = {}
                    controller.cell = cell
                    controller.initialX = cell.rect.x
                    controller.initialY = cell.rect.y
                    controller.combines = false
                    while (cell.col < 4 and grid[cell.row][cell.col + 1].value == 0) do
                        --update controller ending location
                        controller.finalX = ((display.contentWidth-display.contentHeight)/2) + ((cell.col) * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING + CELL_SIZE/2
                        controller.finalY = ((cell.row-1) * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING + CELL_SIZE/2
                        needsController = true
                        --move block as much as we are able to
                        moveCell(cell, grid[cell.row][cell.col + 1])
                    end
                    --combine blocks if possible
                    if (cell.col ~= 4 and cell.value == grid[cell.row][cell.col + 1].value) then
                        if (grid[cell.row][cell.col + 1].hasCombined == false) then
                            --update controller ending location, specify combo animation
                            controller.finalX = ((display.contentWidth-display.contentHeight)/2) + ((cell.col) * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING + CELL_SIZE/2
                            controller.finalY = ((cell.row-1) * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING + CELL_SIZE/2
                            needsController = true
                            controller.combines = true
                            controller.combinesWith = grid[cell.row][cell.col + 1]
                            combineCells(cell, grid[cell.row][cell.col + 1])
                        end
                    end
                    --push controller to be animated
                    if (needsController) then
                        table.insert(controllerList, controller)
                    end
                end
            end
        end
        if (#controllerList > 0) then
            animateSlide(controllerList)
        else
            currentlyAnimating = false
        end
    end





end


-- "scene:show()"
function _2048.scene:show( event )

	--display.setDefault("background",1,1,.9)

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen).
    elseif ( phase == "did" ) then
        -- Called when the scene is now on screen.
        -- Insert code here to make the scene come alive.
        -- Example: start timers, begin animation, play audio, etc.

        start()
    end
end


-- "scene:hide()"
function _2048.scene:hide( event )

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
function _2048.scene:destroy( event )

    local sceneGroup = self.view

    -- Called prior to the removal of scene's view ("sceneGroup").
    -- Insert code here to clean up the scene.
    -- Example: remove display objects, save state, etc.
end


-- -------------------------------------------------------------------------------

-- Listener setup
_2048.scene:addEventListener( "create", _2048.scene )
_2048.scene:addEventListener( "show", _2048.scene )
_2048.scene:addEventListener( "hide", _2048.scene )
_2048.scene:addEventListener( "destroy", _2048.scene )

-- -------------------------------------------------------------------------------

return _2048