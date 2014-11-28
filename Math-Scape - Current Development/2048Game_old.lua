local _2048Game = {} -- _2048 because 2048 would be a number
local composer = require("composer")
_2048Game.scene = composer.newScene("2048Game")


local grid
--padding between the cells, and between the cells and the wall
local CELL_PADDING = 10 
--size of each cell, adjusted for padding
local CELL_SIZE = (display.contentWidth - (5 * CELL_PADDING)) / 4
--empty cells in the grid will be initialized with value 0
local EMPTY_CELL = 0
--rect that is a backround for score (used for centering scoreText)
local scoreRect
--text to display score in bottom right corner
local scoreText
local score
--displays 2048 during game, "Game Over!" if you lose, and "You Win!" if you win (you wont)
local titleText
--animation steps it takes to complete a slide
local SLIDE_STEPS = 7
--delay between steps of slide animation
local ANIMATION_DELAY_SLIDE = 12
--animation steps it takes to complete a cell birth
local BIRTH_STEPS = 5
--delay between steps of birth animation
local ANIMATION_DELAY_BIRTH = 8
--flag so we don't allow multiple slides at once
local currentlyAnimating = false
--number of cells with non zero value
local cellCount = 0
--highest value on the board
local highestValue = 0
--game over flag
local gameOver = false


--maps a tiles value to it its color

local VAL_TO_COLOR = {
    _0 = {204, 192, 179},
    _2 = {238, 228, 218},
    _4 = {237, 224, 200},
    _8 = {242, 177, 121},
    _16 = {245, 149, 99},
    _32 = {246, 124, 95},
    _64 = {246, 94, 59},
    _128 = {237, 207, 114},
    _256 = {237, 204, 97},
    _512 = {237, 200, 80},
    _1024 = {237, 197, 63},
    --assumed color (never actually seen a 2048 lol)
    _2048 = {237, 194, 46}
}


function start()
    score = 0
    grid = {{}}
    --canvas has height of 480, width of 400
    gridInit()
    Runtime:addEventListener( "touch", swipeHandler )
    --keyDownMethod(keyHandler)
end

--[[
    Sets up grid for the first time, draws background and
    empty cells.
]]--
function gridInit() 
    --draw grey background
    local rect = display.newRect(display.contentWidth/2,display.contentHeight/2,display.getContentHeight, display.getContentHeight)
    rect:setFillColor(rgb(187, 173, 160))
    sceneGroup:insert(rect)
    
--[[
    This is a bit of a kludge. We draw a grid of grey empty cells over the 
    background, then do it again in the grid fill. These squares are static and
    will not move, while the other grid cells do. These are necessary for a 
    smooth animation sequence. I need to refactor some internal data structures
    to eliminate the need for these.
]]--
     
    for i = 0, 4 do
        for j = 0, 4 do
            local emptyCell = display.newRect((j * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING, (i * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING, CELL_SIZE, CELL_SIZE)
            emptyCell:setFillColor(VAL_TO_COLOR["_0"])
            sceneGroup:insert(emptyCell)
        end
    end
    
    
    --add "2048" at the bottom left corner
    titleText = display.newText("2048", CELL_PADDING, display.contentWidth + ((display.contentHeight - display.contentWidth)/2) + (titleText.height / 3), "Arial", 50)
    titleText:setFillColor(rgb(119,110,101))
    sceneGroup:insert(titleText)
    --add the score background
    scoreRect = display.newRect(display.contentWidth - scoreRect.width - (CELL_PADDING), display.contentWidth + CELL_PADDING, 150, display.contentHeight - display.contentWidth - (2 * CELL_PADDING))
    scoreRect:setFillColor(rgb(187,173,160))
    sceneGroup:insert(scoreRect)
    --add score text
    local scoreLabelText = display.newText("SCORE", scoreRect.x + (scoreRect.width /2) - (scoreLabelText.width / 2), scoreRect.y + scoreLabelText.height, "Arial", 11)
    scoreLabelText:setFillColor(rgb(238, 228, 218))
    sceneGroup:insert(scoreLabelText)
    --add score value text, set position every time we update it
    scoreText = display.newText("0", scoreRect.x + (scoreRect.width /2) - (scoreText.width / 2), scoreRect.y + (scoreRect.height / 2) + (scoreText.height / 3) + CELL_PADDING, "Arial", 20)
    scoreText.setColor(1)
    sceneGroup:insert(scoreText)
    
    --add empty cell squares
    for i = 0, 4 do
        for j = 0, 4 do
            local cell = {}
            --find the middle of each cell
            local cellX = ((j * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING) + (CELL_SIZE / 2)
            local cellY = ((i * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING) + (CELL_SIZE / 2)
            cell.row = i
            cell.col = j
            --size is grown by birth animation
            cell.rect = display.newRect(cellX, cellY, 0, 0)
            cell.value = 0
            cell.text = display.newText("", cellX, cellY, "Arial", 30)
            --neither rect nor text has been added to canvas, this doesn't matter
            cell.text:setFillColor(rgb(119,110,101))
            cell.rect:setFillColor(VAL_TO_COLOR["_0"])
            cell.hasCombined = false
            grid[i][j] = cell
        end
    end
    --add two random cells to grid
    addRandomCell()
    addRandomCell()
end

function addRandomCell() 
    --naive random, keep rolling until we land an empty cell
    local row = Randomizer.nextInt(0, 3)
    local col = Randomizer.nextInt(0, 3)
    while (grid[row][col].value ~= EMPTY_CELL) do
        row = Randomizer.nextInt(0, 3)
        col = Randomizer.nextInt(0, 3)
    end
    --get the rect at this particular cell
    local cell = grid[row][col]
    --determine whether new cell is a 2 or 4
    local chance = Randomizer.nextInt(1, 100)
    if (chance < 75) then
        cell.rect.setFillColor(VAL_TO_COLOR["_2"])
        cell.value = 2
        cell.text.text = "2"
    else
        --rolled a four
        cell.rect:setFillColor(VAL_TO_COLOR["_4"])
        cell.value = 4
        cell.text.text = "4"
    end
    cell.rect.setPosition(((cell.col * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING) + (CELL_SIZE / 2),
                          ((cell.row * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING) + (CELL_SIZE / 2))
    --controls the animation of the birth of new cells
    local birthAnimation = function() 
        local size = cell.rect.width()
        local oldX = cell.rect.x()
        local oldY = cell.rect.y()
        if (size == CELL_SIZE) then
            stopTimer(birthAnimation)
            cell.text:setFillColor(rgb(119,110,101))
            cell.text.x = cell.rect.x + (CELL_SIZE / 2) - (cell.text.width() / 2)
            cell.text.y = cell.rect.y + (CELL_SIZE / 2) + (cell.text.height() / 3)
            sceneGroup:insert(text)
            cell.rect.x = (cell.col * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING
            cell.rect.x = (cell.row * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING
            currentlyAnimating = false
        
        else 
            display.remove(cell.rect)
            cell.rect = display.newRect(oldX - ((CELL_SIZE / BIRTH_STEPS) / 2), oldY - ((CELL_SIZE / BIRTH_STEPS) / 2), size + (CELL_SIZE / BIRTH_STEPS), size + (CELL_SIZE / BIRTH_STEPS))
            cell.rect:setFillColor(VAL_TO_COLOR["_"..cell.value])
            sceneGroup:insert(cell.rect)
        end
    end
    if (cellCount >= 2) then
        currentlyAnimating = true
        cell.rect = display.newRect(((cell.col * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING) + (CELL_SIZE / 2), ((cell.row * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING) + (CELL_SIZE / 2), 0, 0)
        sceneGroup:insert(cell.rect)
        setTimer(birthAnimation, ANIMATION_DELAY_BIRTH)
    else
        cell.rect = display.newRect((cell.col * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING, (cell.row * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING, CELL_SIZE, CELL_SIZE)
        cell.rect:setFillColor(VAL_TO_COLOR["_"..cell.value])
        cell.text.x = cell.rect.x + (CELL_SIZE / 2) - (cell.text.width() / 2)
        cell.text.y = cell.rect.y + (CELL_SIZE / 2) + cell.text.height() / 3
        sceneGroup:insert(cell.rect)
        sceneGroup:insert(cell.text)
        currentlyAnimating = false
    end
    cellCount = cellCount + 1
    
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
    scoreText.x = scoreRect.x + (scoreRect.width /2) - (scoreText.width / 2)
    scoreText.y = scoreRect.y + (scoreRect.height / 2) + (scoreText.height / 3) + CELL_PADDING
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
    local timerFunction = function ()
        if (stepsLeft <= 0) then
            stopTimer(timerFunction)
            for i = 0,controllerList.length,1 do
                local controller = controllerList[i]
                --check if we should combine cells
                if (controller.combines == true) then
                    local cell = controller.cell
                    local cellDouble = controller.combinesWith
                    --remove this cell, upgrade the cell it combines with
                    cell.rect:setFillColor(VAL_TO_COLOR["_0"])
                    cell.text.text = ""
                    display.remove(cell.rect)
                    display.remove(cell.text)
                    cellCount = cellCount-1
                    cellDouble.text.text = cellDouble.value
                    cellDouble.text.x = cellDouble.rect.x + (CELL_SIZE / 2) - (cellDouble.text.width / 2)
                    cellDouble.text.y = cellDouble.rect.y + (CELL_SIZE / 2) + cellDouble.text.height / 3
                    cellDouble.rect:setFillColor(VAL_TO_COLOR["_"..cellDouble.value])
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
                titleText.font = "Arial"
                titleText.fontSize = 30
                titleText.x = CELL_PADDING
                titleText.y = display.contentWidth + ((display.contentHeight - display.contentWidth)/2) + (titleText.height / 3) 
            else
                for i = 0, 4, 1 do
                    for j = 0, 4 do
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
                        titleText.font = "Arial"
                        titleText.fontSize = 30
                        titleText.x = CELL_PADDING
                        titleText.y = display.contentWidth + ((display.contentHeight - display.contentWidth)/2) + (titleText.height / 3)
                    end
                end
            end
        else
            for i = 0, controllerList.length do
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
    for i = 0, controllerList.length do
        local controller = controllerList[i]
        controller.dx = (controller.finalX - controller.initialX) / (SLIDE_STEPS)
        controller.dy = (controller.finalY - controller.initialY) / (SLIDE_STEPS)
    end
    setTimer(timerFunction, ANIMATION_DELAY_SLIDE)
end

--[[
    returns true if a move is still possible, ie there exist adjacent cells with the same value.
    returns false otherwise. Used in animateSlide for end of game check.
]]--
function movePossible() 
    for i = 0, 4 do
        for j = 0, 4 do
            local cellVal = grid[i][j].value
            if (i > 0 and grid[i - 1][j].value == cellVal) then
                return true
            end
            if (i < 3 and grid[i + 1][j].value == cellVal) then
                return true
            end
            if (j > 0 and grid[i][j - 1].value == cellVal) then
                return true
            end
            if (j < 3 and grid[i][j + 1].value == cellVal) then
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
    cell.rect.move(dx, dy)
    --use a raw setPos instead of move. not sure if performance difference.
    cell.text.move(dx, dy)
end


--[[
    Shifts the entire grid down, combines blocks if necessary 
]]--
function shiftDown()
    --[[Loop through the columns, starting at the bottom row. If cell is empty,
        move block into cell. If cell is occupied, check if blocks combine.
     ]]--
    local controllerList = {}
    for col = 0, 4 do
        for row = 3, 0, -1 do
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
                while (cell.row < 3 and grid[cell.row + 1][col].value == 0) do
                    --update controller ending location
                    controller.finalX = (cell.col * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING
                    controller.finalY = ((cell.row + 1) * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING
                    --move block as much as we are able to
                    moveCell(cell, grid[cell.row + 1][cell.col])
                    needsController = true
                end
                --combine blocks if possible
                if (cell.row ~= 3 and cell.value == grid[cell.row + 1][col].value) then
                    if (grid[cell.row + 1][cell.col].hasCombined == false) then
                        controller.finalX = (cell.col * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING
                        controller.finalY = ((cell.row + 1) * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING
                        needsController = true
                        controller.combines = true
                        controller.combinesWith = grid[cell.row + 1][cell.col]
                        combineCells(cell, grid[cell.row + 1][cell.col])
                    end
                end
                --push controller to be animated
                if (needsController) then
                    controllerList.push(controller)
                end
            end
        end
    end
    if (controllerList.length > 0) then
        animateSlide(controllerList)
    else
        currentlyAnimating = false
    end
end

function shiftUp()
    local controllerList = {}
    for col = 0, 4 do
        for row = 0, 4 do
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
                while (cell.row > 0 and grid[cell.row - 1][col].value == 0) do
                    --update controller ending location
                    controller.finalX = (cell.col * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING
                    controller.finalY = ((cell.row - 1) * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING
                    needsController = true
                    --update data structure, to other blocks it appears this block has moved
                    moveCell(cell, grid[cell.row - 1][cell.col])
                end
                --combine blocks if possible
                if (cell.row ~= 0 and cell.value == grid[cell.row - 1][col].value) then
                    if (grid[cell.row -1][cell.col].hasCombined == false) then
                        --update controller ending location, specify combo animation
                        controller.finalX = (cell.col * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING
                        controller.finalY = ((cell.row - 1) * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING
                        needsController = true
                        controller.combines = true
                        controller.combinesWith = grid[cell.row - 1][cell.col]
                        combineCells(cell, grid[cell.row - 1][cell.col])
                    end
                end
                --push controller to be animated
                if (needsController) then
                    controllerList.push(controller)
                end
            end
        end
    end
    if (controllerList.length > 0) then
        
        animateSlide(controllerList)
    else
        currentlyAnimating = false
    end
end

function shiftLeft()
    local controllerList = {}
    for row = 0, 4 do
        for col = 0, 4 do
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
                while (cell.col > 0 and grid[cell.row][cell.col - 1].value == 0) do
                    --update controller ending location
                    controller.finalX = ((cell.col - 1) * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING
                    controller.finalY = (cell.row * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING
                    needsController = true
                    --move block as much as we are able to
                    moveCell(cell, grid[cell.row][cell.col - 1])
                end
                --combine blocks if possible
                if (cell.col ~= 0 and cell.value == grid[cell.row][cell.col - 1].value) then
                    if (grid[cell.row][cell.col - 1].hasCombined == false) then
                        --update controller ending location, specify combo animation
                        controller.finalX = ((cell.col - 1) * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING
                        controller.finalY = (cell.row * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING
                        needsController = true
                        controller.combines = true
                        controller.combinesWith = grid[cell.row][cell.col - 1]
                        combineCells(cell, grid[cell.row][cell.col - 1])
                    end
                end
                --push controller to be animated
                if (needsController) then
                    controllerList.push(controller)
                end
            end
        end
    end
    if (controllerList.length > 0) then
        
        animateSlide(controllerList)
    else
        currentlyAnimating = false
    end
end

function shiftRight()
    local controllerList = {}
    for row = 0, 4 do
        for col = 3, 0, -1 do
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
                while (cell.col < 3 and grid[cell.row][cell.col + 1].value == 0) do
                    --update controller ending location
                    controller.finalX = ((cell.col + 1) * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING
                    controller.finalY = (cell.row * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING
                    needsController = true
                    --move block as much as we are able to
                    moveCell(cell, grid[cell.row][cell.col + 1])
                end
                --combine blocks if possible
                if (cell.col ~= 3 and cell.value == grid[cell.row][cell.col + 1].value) then
                    if (grid[cell.row][cell.col + 1].hasCombined == false) then
                        --update controller ending location, specify combo animation
                        controller.finalX = ((cell.col + 1) * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING
                        controller.finalY = (cell.row * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING
                        needsController = true
                        controller.combines = true
                        controller.combinesWith = grid[cell.row][cell.col + 1]
                        combineCells(cell, grid[cell.row][cell.col + 1])
                    end
                end
                --push controller to be animated
                if (needsController) then
                    controllerList.push(controller)
                end
            end
        end
    end
    if (controllerList.length > 0) then
        animateSlide(controllerList)
    else
        currentlyAnimating = false
    end
end




