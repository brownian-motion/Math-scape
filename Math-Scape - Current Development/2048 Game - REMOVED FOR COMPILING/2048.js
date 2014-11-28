var grid;
//padding between the cells, and between the cells and the wall
var CELL_PADDING = 10; 
//size of each cell, adjusted for padding
var CELL_SIZE = (getWidth() - (5 * CELL_PADDING)) / 4;
//empty cells in the grid will be initialized with value 0
var EMPTY_CELL = 0;
//rect that is a backround for score (used for centering scoreText)
var scoreRect;
//text to display score in bottom right corner
var scoreText;
var score;
//displays 2048 during game, "Game Over!" if you lose, and "You Win!" if you win (you wont)
var titleText;
//animation steps it takes to complete a slide
var SLIDE_STEPS = 7;
//delay between steps of slide animation
var ANIMATION_DELAY_SLIDE = 12;
//animation steps it takes to complete a cell birth
var BIRTH_STEPS = 5;
//delay between steps of birth animation
var ANIMATION_DELAY_BIRTH = 8;
//flag so we don't allow multiple slides at once
var currentlyAnimating = false;
//number of cells with non zero value
var cellCount = 0;
//highest value on the board
var highestValue = 0;
//game over flag
var gameOver = false;


//maps a tiles value to it its color
var VAL_TO_COLOR = {
    0 : new Color(204, 192, 179),
    2 : new Color(238, 228, 218),
    4 : new Color(237, 224, 200),
    8 : new Color(242, 177, 121),
    16 : new Color(245, 149, 99),
    32 : new Color(246, 124, 95),
    64 : new Color(246, 94, 59),
    128: new Color(237, 207, 114),
    256: new Color(237, 204, 97),
    512: new Color(237, 200, 80),
    1024: new Color(237, 197, 63),
    //assumed color (never actually seen a 2048 lol)
    2048: new Color(237, 194, 46)
};

function start() {
    score = 0;
    grid = new Grid(4, 4);
    //canvas has height of 480, width of 400
    gridInit();
    keyDownMethod(keyHandler);
}

/**
 * Sets up grid for the first time, draws background and
 * empty cells.
 */
function gridInit() {
    //draw grey background
    var rect = new Rectangle(getWidth(), getWidth());
    rect.setPosition(0,0);
    rect.setColor(new Color(187, 173, 160));
    add(rect);
    
    /**
     * This is a bit of a kludge. We draw a grid of grey empty cells over the 
     * background, then do it again in the grid fill. These squares are static and
     * will not move, while the other grid cells do. These are necessary for a 
     * smooth animation sequence. I need to refactor some internal data structures
     * to eliminate the need for these.
     */
     
    for (var i = 0; i < 4; i++) {
        for (var j = 0; j < 4; j++) {
            var emptyCell = new Rectangle(CELL_SIZE, CELL_SIZE);
            emptyCell.setPosition((j * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING,
                                  (i * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING);
            emptyCell.setColor(VAL_TO_COLOR[0]);
            add(emptyCell);
        }
    }
    
    
    //add "2048" at the bottom left corner
    titleText = new Text("2048", "50pt Arial");
    titleText.setColor(new Color(119,110,101));
    titleText.setPosition(CELL_PADDING ,
                          getWidth() + ((getHeight() - getWidth())/2) + (titleText.getHeight() / 3)) ;
    add(titleText);
    //add the score background
    scoreRect = new Rectangle(150,
                                  getHeight() - getWidth() - (2 * CELL_PADDING));
    scoreRect.setColor(new Color(187,173,160));
    scoreRect.setPosition(getWidth() - scoreRect.getWidth() - (CELL_PADDING),
                          getWidth() + CELL_PADDING);
    add(scoreRect);
    //add score text
    var scoreLabelText = new Text("SCORE", "11pt Arial");
    scoreLabelText.setColor(new Color(238, 228, 218));
    scoreLabelText.setPosition(scoreRect.getX() + (scoreRect.getWidth() /2) - (scoreLabelText.getWidth() / 2),
                          scoreRect.getY() + scoreLabelText.getHeight());
    add(scoreLabelText);
    //add score value text, set position every time we update it
    scoreText = new Text("0", "20pt Arial");
    scoreText.setPosition(scoreRect.getX() + (scoreRect.getWidth() /2) - (scoreText.getWidth() / 2),
                          scoreRect.getY() + (scoreRect.getHeight() / 2) + (scoreText.getHeight() / 3) + CELL_PADDING);
    scoreText.setColor(Color.WHITE);
    add(scoreText);
    
    //add empty cell squares
    for (var i = 0; i < 4; i++) {
        for (var j = 0; j < 4; j++) {
            var cell = {};
            //find the middle of each cell
            var cellX = ((j * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING) + (CELL_SIZE / 2);
            var cellY = ((i * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING) + (CELL_SIZE / 2);
            cell.row = i;
            cell.col = j;
            //size is grown by birth animation
            cell.rect = new Rectangle(0, 0);
            cell.value = 0;
            cell.text = new Text("", "30pt Arial");
            //neither rect nor text has been added to canvas, this doesn't matter
            cell.text.setPosition(cellX, cellY);
            cell.text.setColor(new Color(119,110,101));
            cell.rect.setColor(VAL_TO_COLOR[0]);
            cell.rect.setPosition(cellX, cellY);
            cell.hasCombined = false;
            grid.set(i, j, cell);
        }
    }
    //add two random cells to grid
    addRandomCell();
    addRandomCell();
}

function addRandomCell() {
    //naive random, keep rolling until we land an empty cell
    var row = Randomizer.nextInt(0, 3);
    var col = Randomizer.nextInt(0, 3);
    while (grid.get(row, col).value != EMPTY_CELL) {
        row = Randomizer.nextInt(0, 3);
        col = Randomizer.nextInt(0, 3);
    }
    //get the rect at this particular cell
    var cell = grid.get(row, col);
    //determine whether new cell is a 2 or 4
    var chance = Randomizer.nextInt(1, 100);
    if (chance < 75) {
        cell.rect.setColor(VAL_TO_COLOR[2]);
        cell.value = 2;
        cell.text.setText("2");
    } else {
        //rolled a four
        cell.rect.setColor(VAL_TO_COLOR[4]);
        cell.value = 4;
        cell.text.setText("4");
    }
    cell.rect.setPosition(((cell.col * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING) + (CELL_SIZE / 2),
                          ((cell.row * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING) + (CELL_SIZE / 2));
    //controls the animation of the birth of new cells
    var birthAnimation = function() {
        var size = cell.rect.getWidth();
        var oldX = cell.rect.getX();
        var oldY = cell.rect.getY();
        if (size == CELL_SIZE) {
            stopTimer(birthAnimation);
            cell.text.setColor(new Color(119,110,101));
            cell.text.setPosition(cell.rect.getX() + (CELL_SIZE / 2) - (cell.text.getWidth() / 2), 
                                  cell.rect.getY() + (CELL_SIZE / 2) + (cell.text.getHeight() / 3));
            add(cell.text);
            cell.rect.setPosition((cell.col * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING,
                              (cell.row * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING);
            currentlyAnimating = false;
        }
        else {
            remove(cell.rect);
            cell.rect = new Rectangle(size + (CELL_SIZE / BIRTH_STEPS),
                                      size + (CELL_SIZE / BIRTH_STEPS));
            cell.rect.setPosition(oldX - ((CELL_SIZE / BIRTH_STEPS) / 2),
                                  oldY - ((CELL_SIZE / BIRTH_STEPS) / 2));
            cell.rect.setColor(VAL_TO_COLOR[cell.value]);
            add(cell.rect);
        }
    }
    if (cellCount >= 2) {
        currentlyAnimating = true;
        cell.rect = new Rectangle(0, 0);
        cell.rect.setPosition(((cell.col * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING) + (CELL_SIZE / 2),
                              ((cell.row * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING) + (CELL_SIZE / 2));
        add(cell.rect);
        setTimer(birthAnimation, ANIMATION_DELAY_BIRTH);
    } else {
        cell.rect = new Rectangle(CELL_SIZE, CELL_SIZE);
        cell.rect.setPosition((cell.col * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING,
                              (cell.row * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING);
        cell.rect.setColor(VAL_TO_COLOR[cell.value]);
        cell.text.setPosition(cell.rect.getX() + (CELL_SIZE / 2) - (cell.text.getWidth() / 2), 
                              cell.rect.getY() + (CELL_SIZE / 2) + cell.text.getHeight() / 3);
        add(cell.rect);
        add(cell.text);
        currentlyAnimating = false;
    }
    cellCount++;
    
}



function keyHandler(e) {
    if (!currentlyAnimating && !gameOver) {
        switch (e.keyCode) {
            case Keyboard.DOWN:
                currentlyAnimating = true;
                shiftDown();
                break;
            case Keyboard.UP:
                currentlyAnimating = true;
                shiftUp();
                break;
            case Keyboard.RIGHT:
                currentlyAnimating = true;
                shiftRight();
                break;
            case Keyboard.LEFT:
                currentlyAnimating = true;
                shiftLeft();
                break;
        }
    }
    
}

function moveCell(cellFrom, cellTo) {
    var oldRow = cellFrom.row;
    var oldCol = cellFrom.col;
    var oldX = cellFrom.rect.getX();
    var oldY = cellFrom.rect.getY();
    cellFrom.row = cellTo.row;
    cellFrom.col = cellTo.col;
    cellTo.row = oldRow;
    cellTo.col = oldCol;
    //cellTo.rect.setPosition(oldX, oldY);
    grid.set(cellTo.row, cellTo.col, cellTo);
    grid.set(cellFrom.row, cellFrom.col, cellFrom);
}

function combineCells(cellSingle, cellDouble) {
    var doubleValue = cellSingle.value * 2;
    cellSingle.value = 0;
    cellDouble.value = doubleValue;
    cellDouble.hasCombined = true;
    
    if (doubleValue > highestValue) {
        highestValue = doubleValue;
    }
}

function addToScore(inc) {
    score += inc;
    scoreText.setText(score);
    scoreText.setPosition(scoreRect.getX() + (scoreRect.getWidth() /2) - (scoreText.getWidth() / 2),
                          scoreRect.getY() + (scoreRect.getHeight() / 2) + (scoreText.getHeight() / 3) + CELL_PADDING);
}

/**
 * animation controller = {
 *      int initialX;
 *      int initialY;
 *      int finalX;
 *      int finalY;
 *      int dx;
 *      int dy;
 *      int combonationCount
 *      Cell cell;
 *  }    
 * 
 */

function animateSlide(controllerList) {
    var stepsLeft = SLIDE_STEPS;
    /**
     * Actually animates the blocks. Steps through the controller list and moves
     * each by dx, dy. Decrements stepsLeft. Stops itself when animation complete.
     */
    var timerFunction = function () {
        if (stepsLeft <= 0) {
            stopTimer(timerFunction);
            for (var i = 0; i < controllerList.length; i++) {
                var controller = controllerList[i];
                //check if we should combine cells
                if (controller.combines == true) {
                    var cell = controller.cell;
                    var cellDouble = controller.combinesWith;
                    //remove this cell, upgrade the cell it combines with
                    cell.rect.setColor(VAL_TO_COLOR[0])
                    cell.text.setText("");
                    remove(cell.rect);
                    remove(cell.text);
                    cellCount--;
                    cellDouble.text.setText(cellDouble.value);
                    cellDouble.text.setPosition(cellDouble.rect.getX() + (CELL_SIZE / 2) - (cellDouble.text.getWidth() / 2),
                                                cellDouble.rect.getY() + (CELL_SIZE / 2) + cellDouble.text.getHeight() / 3);
                    cellDouble.rect.setColor(VAL_TO_COLOR[cellDouble.value]);
                    if (cellDouble.value > 4) {
                        cellDouble.text.setColor(Color.WHITE);
                    }
                    //update score
                    addToScore(cellDouble.value);
                }
            }
            //add new cell
            if (highestValue == 2048) {
                gameOver = true;
                println("You Win!");
                titleText.setText("You Win!");
                titleText.setFont("30pt Arial");
                titleText.setPosition(CELL_PADDING ,
                          getWidth() + ((getHeight() - getWidth())/2) + (titleText.getHeight() / 3)) ;
            } else {
                for (var i = 0; i < 4; i++) {
                    for (var j = 0; j < 4; j++) { 
                        var cell = grid.get(i, j);
                        cell.hasCombined = false;
                    }
                }
                addRandomCell();
                if (cellCount == 16) {
                    /* if the sixteenth cell was just added (board is full), we have to do a full check to see
                     * if a move is still possible. If it is, the game continues. If not, game over.
                     */
                    if (!movePossible()) {
                        gameOver = true;
                        println("Game Over!");
                        titleText.setText("Game Over!");
                        titleText.setFont("30pt Arial");
                        titleText.setPosition(CELL_PADDING ,
                              getWidth() + ((getHeight() - getWidth())/2) + (titleText.getHeight() / 3)) ;
                    }
                }
            }
        } else {
            for (var i = 0; i < controllerList.length; i++) {
                var controller = controllerList[i];
                shiftCell(controller.cell, controller.dx, controller.dy);
            }
            stepsLeft--;
        }
    }
    /**
     * Caclulate dx, dy for each member of the controller list.
     * naive, doesn't take into account cell combanations.
     */
    for (var i = 0; i < controllerList.length; i++) {
        var controller = controllerList[i];
        controller.dx = (controller.finalX - controller.initialX) / (SLIDE_STEPS);
        controller.dy = (controller.finalY - controller.initialY) / (SLIDE_STEPS);
    }
    setTimer(timerFunction, ANIMATION_DELAY_SLIDE);
}

/**
 * returns true if a move is still possible, ie there exist adjacent cells with the same value.
 * returns false otherwise. Used in animateSlide for end of game check.
 */
function movePossible() {
    for (var i = 0; i < 4; i++) {
        for (var j = 0; j < 4; j++) {
            var cellVal = grid.get(i, j).value;
            if (i > 0 && grid.get(i - 1, j).value == cellVal) {
                return true;
            }
            if (i < 3 && grid.get(i + 1, j).value == cellVal) {
                return true;
            }
            if (j > 0 && grid.get(i, j - 1).value == cellVal) {
                return true;
            }
            if (j < 3 && grid.get(i, j + 1).value == cellVal) {
                return true;
            }
        }
    }
    return false;
}


/**
 * Moves a cell by dx, dy. Used for animating slides. Assume dx, dy is the amount
 * to move the cell as defined by the bounding rectangle. Internal text will
 * have to be moved a different amount
 */
function shiftCell(cell, dx, dy) {
    cell.rect.move(dx, dy);
    //use a raw setPos instead of move. not sure if performance difference.
    cell.text.move(dx, dy)
}


/**
 * Shifts the entire grid down, combines blocks if necessary 
 */
function shiftDown() {
    /* Loop through the columns, starting at the bottom row. If cell is empty,
     * move block into cell. If cell is occupied, check if blocks combine.
     */
    var controllerList = [];
    for (var col = 0; col < 4; col++) {
        for (var row = 3; row >= 0; row--) {
            //look for occupied cell
            if (grid.get(row, col).value != 0) {
                var needsController = false;
                var cell = grid.get(row, col);
                //init animation contoller with cell's initial info
                var controller = {};
                controller.cell = cell;
                controller.initialX = cell.rect.getX();
                controller.initialY = cell.rect.getY();
                controller.combines = false;
                while (cell.row < 3 && grid.get(cell.row + 1, col).value == 0) {
                    //update controller ending location
                    controller.finalX = (cell.col * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING;
                    controller.finalY = ((cell.row + 1) * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING;
                    //move block as much as we are able to
                    moveCell(cell, grid.get(cell.row + 1, cell.col));
                    needsController = true;
                }
                //combine blocks if possible
                if (cell.row != 3 && cell.value == grid.get(cell.row + 1, col).value) {
                    if (grid.get(cell.row + 1, cell.col).hasCombined == false) {
                        controller.finalX = (cell.col * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING;
                        controller.finalY = ((cell.row + 1) * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING;
                        needsController = true;
                        controller.combines = true;
                        controller.combinesWith = grid.get(cell.row + 1, cell.col);
                        combineCells(cell, grid.get(cell.row + 1, cell.col));
                    }
                }
                //push controller to be animated
                if (needsController) {
                    controllerList.push(controller);
                }
            }
        }
    }
    if (controllerList.length > 0) {
        animateSlide(controllerList);
    } else {
        currentlyAnimating = false;
    }
}

function shiftUp() {
    var controllerList = [];
    for (var col = 0; col < 4; col++) {
        for (var row = 0; row < 4; row++) {
            //look for occupied cell
            if (grid.get(row, col).value != 0) {
                var cell = grid.get(row, col);
                var needsController = false;
                var cell = grid.get(row, col);
                //init animation contoller with cell's initial info
                var controller = {};
                controller.cell = cell;
                controller.initialX = cell.rect.getX();
                controller.initialY = cell.rect.getY();
                controller.combines = false;
                while (cell.row > 0 && grid.get(cell.row - 1, col).value == 0) {
                    //update controller ending location
                    controller.finalX = (cell.col * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING;
                    controller.finalY = ((cell.row - 1) * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING;
                    needsController = true;
                    //update data structure, to other blocks it appears this block has moved
                    moveCell(cell, grid.get(cell.row - 1, cell.col));
                }
                //combine blocks if possible
                if (cell.row != 0 && cell.value == grid.get(cell.row - 1, col).value) {
                    if (grid.get(cell.row -1, cell.col).hasCombined == false) {
                        //update controller ending location, specify combo animation
                        controller.finalX = (cell.col * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING;
                        controller.finalY = ((cell.row - 1) * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING;
                        needsController = true;
                        controller.combines = true;
                        controller.combinesWith = grid.get(cell.row - 1, cell.col);
                        combineCells(cell, grid.get(cell.row - 1, cell.col));
                    }
                }
                //push controller to be animated
                if (needsController) {
                    controllerList.push(controller);
                }
            }
        }
    }
    if (controllerList.length > 0) {
        
        animateSlide(controllerList);
    } else {
        currentlyAnimating = false;
    }
}

function shiftLeft() {
    var controllerList = [];
    for (var row = 0; row < 4; row++) {
        for (var col = 0; col < 4; col++) {
            //look for occupied cell
            if (grid.get(row, col).value != 0) {
                var needsController = false;
                var cell = grid.get(row, col);
                //init animation contoller with cell's initial info
                var controller = {};
                controller.cell = cell;
                controller.initialX = cell.rect.getX();
                controller.initialY = cell.rect.getY();
                controller.combines = false;
                while (cell.col > 0 && grid.get(cell.row, cell.col - 1).value == 0) {
                    //update controller ending location
                    controller.finalX = ((cell.col - 1) * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING;
                    controller.finalY = (cell.row * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING;
                    needsController = true;
                    //move block as much as we are able to
                    moveCell(cell, grid.get(cell.row, cell.col - 1));
                }
                //combine blocks if possible
                if (cell.col != 0 && cell.value == grid.get(cell.row, cell.col - 1).value) {
                    if (grid.get(cell.row, cell.col - 1).hasCombined == false) {
                        //update controller ending location, specify combo animation
                        controller.finalX = ((cell.col - 1) * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING;
                        controller.finalY = (cell.row * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING;
                        needsController = true;
                        controller.combines = true;
                        controller.combinesWith = grid.get(cell.row, cell.col - 1);
                        combineCells(cell, grid.get(cell.row, cell.col - 1));
                    }
                }
                //push controller to be animated
                if (needsController) {
                    controllerList.push(controller);
                }
            }
        }
    }
    if (controllerList.length > 0) {
        
        animateSlide(controllerList);
    } else {
        currentlyAnimating = false;
    }
}

function shiftRight() {
    var controllerList = [];
    for (var row = 0; row < 4; row++) {
        for (var col = 3; col >= 0; col--) {
            //look for occupied cell
            if (grid.get(row, col).value != 0) {
                var needsController = false;
                var cell = grid.get(row, col);
                //init animation contoller with cell's initial info
                var controller = {};
                controller.cell = cell;
                controller.initialX = cell.rect.getX();
                controller.initialY = cell.rect.getY();
                controller.combines = false;
                while (cell.col < 3 && grid.get(cell.row, cell.col + 1).value == 0) {
                    //update controller ending location
                    controller.finalX = ((cell.col + 1) * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING;
                    controller.finalY = (cell.row * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING;
                    needsController = true;
                    //move block as much as we are able to
                    moveCell(cell, grid.get(cell.row, cell.col + 1));
                }
                //combine blocks if possible
                if (cell.col != 3 && cell.value == grid.get(cell.row, cell.col + 1).value) {
                    if (grid.get(cell.row, cell.col + 1).hasCombined == false) {
                        //update controller ending location, specify combo animation
                        controller.finalX = ((cell.col + 1) * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING;
                        controller.finalY = (cell.row * (CELL_SIZE + CELL_PADDING)) + CELL_PADDING;
                        needsController = true;
                        controller.combines = true;
                        controller.combinesWith = grid.get(cell.row, cell.col + 1);
                        combineCells(cell, grid.get(cell.row, cell.col + 1));
                    }
                }
                //push controller to be animated
                if (needsController) {
                    controllerList.push(controller);
                }
            }
        }
    }
    if (controllerList.length > 0) {
        animateSlide(controllerList);
    } else {
        currentlyAnimating = false;
    }
}




