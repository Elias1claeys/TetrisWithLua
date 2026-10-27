--- Declarations
local grid = {} --- The Tetris grid
local shape = {} --- The current Tetris shape that is falling
local startX = 4 --- The starting X position of the shape
local startY = 0 --- The starting Y position of the shape
local score = 0 --- The player's score
local inputTime = 0 --- Time since last input
local fallTime = 0 --- Time since last fall
local fallInterval = 500 --- Time interval for the shape to fall
local gameOver = false --- Game over flag

--- Create a new color
--- @return color # A new color object
function newColor(r, g, b)
    return {
        r = r,
        g = g,
        b = b
    }
end

--- Create a new grid box
--- @return gridBox # A new grid box object
function newGridBox(x, y)
    return {
        x = x,
        y = y,
        color = newColor(211, 211, 211),
        isOccupied = false
    }
end

--- Creates the grid 
function initializeGrid()
    for x = 0, 9 do
    grid[x] = {}
        for y = 0, 21 do
            grid[x][y] = newGridBox(x, y)
        end
    end
    chooseBlocks()
end

--- Chooses a random block shape to spawn
function chooseBlocks()

    --- @param pieces defines the different Tetris pieces + colors
    local pieces = 
    {
        {
            -- O
            cells = {
                {1,1},
                {1,1}
            },
            color = newColor(255, 255, 0)
        },
        {
            -- T
            cells = {
                {0,1,0},
                {1,1,1}
            },
            color = newColor(255, 0, 255)
        },
        {
            -- Z
            cells = {
                {1,1,0},
                {0,1,1}
            },
            color = newColor(255, 0, 0)
        },
        {
            -- S
            cells = {
                {0,1,1},
                {1,1,0}
            },
            color = newColor(0, 255, 0)
        },
        {
            -- L
            cells = {
                {1,0,0},
                {1,1,1}
            },
            color = newColor(0, 0, 255)
        },
        {
            -- J
            cells = {
                {0,0,1},
                {1,1,1}
            },
            color = newColor(255, 165, 0)
        },
        {
            -- I
            cells = {
                {1,1,1,1}
            },
            color = newColor(0, 255, 255)
        }
    }

    --- @param shape selects a random piece from the pieces table
    shape = pieces[math.random(#pieces)]

    --- Check if I can place the shape in the grid
    --- If I can't it means that the top has been reached and the game is over
    if IsGridOccupied(shape.cells) then
        gameOver = true
    else
        --- Put the shape in the grid
        PutShapeInGrid()
    end
end

--- Puts the current shape inside the grid
--- @param startX # The starting X position of the shape
--- @param startY # The starting Y position of the shape
function PutShapeInGrid()
    for y = 1, #shape.cells do
        for x = 1, #shape.cells[y] do
            if shape.cells[y][x] == 1 then
                --- @param grid.color # becomes the shape color
                --- @param grid.isOccupied # becomes true
                grid[startX + x - 1][startY + y - 1].color = shape.color
                grid[startX + x - 1][startY + y - 1].isOccupied = true
            end
        end
    end
end

--- Checks if the grid is occupied at the given cells
function IsGridOccupied(cells)
    for y = 1, #cells do
        for x = 1, #cells[y] do
            if cells[y][x] == 1 and grid[startX + x - 1][startY + y - 1].isOccupied then
                return true
            end
        end
    end

    return false
end

--- Draws the game
function Paint(GAME_ENGINE)
    GAME_ENGINE:SetColor(211, 211, 211);
    GAME_ENGINE:FillRect(0, 0, 300, 600)

    --- Paint all of the cells from the grid
    DrawBoxes(GAME_ENGINE)

    GAME_ENGINE:SetColor(0, 0, 0);

    --- If the game is over display "Game Over!"
    if gameOver then
        GAME_ENGINE:DrawString("Game Over!", 65, 250); 
    end

    GAME_ENGINE:DrawString("Score:", 25, 10);
    GAME_ENGINE:DrawString(tostring(score), 145, 10);
    GAME_ENGINE:DrawRect(25, 55, 275, 580)
end

--- Paint all of the cells from the grid
function DrawBoxes(GAME_ENGINE)
    for x = 0, 9 do
        for y = 0, 21 do
            local box = grid[x][y]

            local left = 25 + box.x * 25
            local top  = 30 + box.y * 25

            --- Fills in a cell with a color
            --- If it is occupied the color of the original cell
            --- Otherwise paint it lightGray
            GAME_ENGINE:SetColor(box.color.r, box.color.g, box.color.b)
            GAME_ENGINE:FillRect(left, top, left + 25, top + 25)
            
            --- If the box is occupied draw a darker border around it
            if box.isOccupied then

                GAME_ENGINE:SetColor(
                  math.floor(box.color.r * 0.5),
                  math.floor(box.color.g * 0.5),
                  math.floor(box.color.b * 0.5)
                )

                GAME_ENGINE:DrawRect(left, top, left + 25, top + 25)
            end
        end
    end
end

--- Updates the game
function Update( GAME_ENGINE )

    --- If the game is over then stop updating
    if gameOver then
        return
    end
    
    --- @param falltime # wait time before the game updates
	fallTime = fallTime + GAME_ENGINE:GetFrameDelay()

    --- Increase the speed of the game based on the score
    local level = math.floor(score / 1000)
    fallInterval = math.max(500 - level * 25, 0)

    --- Update the game when the fall time exceeds the fall interval
    if(fallTime > fallInterval) then
        ---Lets the shape fall down
        fall()
        fallTime = 0
    end
end

--- Lets the shape fall down by one unit
function fall()
    --- Remove the shape from the grid
    --- Otherwise it will leave a trail
    clearShapeFromGrid()

    --- Move the shape down by one unit
    startY = startY + 1

    --- Check if the shape can be moved Down
    --- Has it reached the bottem
    --- Or is there another shape in the way
    if startY + #shape.cells > 22 or IsGridOccupied(shape.cells) then

        startY = startY - 1

        --- Put the shape back in the grid
        PutShapeInGrid()

        --- Check if the player cleared a line
        ClearLine()

        --- Reset the shape position to the top
        startX = 4
        startY = 0

        --- Pick a new shape
        chooseBlocks()
        return
    end

    --- Draw the shape at his new position
    PutShapeInGrid()
end

--- Removes the shape from the grid
function clearShapeFromGrid()
    for y = 1, #shape.cells do
        for x = 1, #shape.cells[y] do
            if shape.cells[y][x] == 1 then
                grid[startX + x - 1][startY + y - 1].color = newColor(211, 211, 211)
                grid[startX + x - 1][startY + y - 1].isOccupied = false
            end
        end
    end
end

--- Check if there is a full line and clear it
function ClearLine()
    --- Go trought every row
    for y = 0, 21 do
        local isFull = true

        --- Check if every cell in the row is filled in
        --- If one is empty then the row is not full
        for x = 0, 9 do
            if not grid[x][y].isOccupied then
                isFull = false
                break
            end
        end

        --- The row is full
        if isFull then 
            
            --- Increase the score
            score = score + 100

            --- Move every row above the full row down by one
            for y2 = y, 1, -1 do
                for x = 0, 9 do
                    grid[x][y2].isOccupied = grid[x][y2 - 1].isOccupied
                    grid[x][y2].color = grid[x][y2 - 1].color
                end  
            end

            --- Clear the top row
            for x = 0, 9 do
                grid[x][0].isOccupied = false
                grid[x][0].color = newColor(211, 211, 211)
            end
        end
    end
end

--- Check for keyboard input
function CheckKeyBoard(GAME_ENGINE)
    
    --- Last time a key was pressed
    inputTime = inputTime + GAME_ENGINE:GetFrameDelay()

    if(inputTime > 100) then

        --- Only allow movement if the game is not over
        if gameOver == false then

            --- Move Left
            if(GAME_ENGINE:IsKeyDown(37)) then -- Left Arrow

                --- Check if player hasn't hit the left wall
                if(startX > 0) then
                    --- Remove the shape from the grid
                    clearShapeFromGrid()

                    --- Move the shape left by one unit
                    startX = startX - 1

                    --- If the grid is occupied move it back
                    if IsGridOccupied(shape.cells) then
                        startX = startX + 1
                    end

                    --- Put the shape back in the grid
                    PutShapeInGrid()
                end
            end

            --- Move Right
            if(GAME_ENGINE:IsKeyDown(39)) then -- Right Arrow

                --- Check if player hasn't hit the right wall
                if(startX < 10 - #shape.cells[1]) then

                    --- Remove the shape from the grid
                    clearShapeFromGrid()

                    --- Move the shape right by one unit
                    startX = startX + 1

                    --- If the grid is occupied move it back
                    if IsGridOccupied(shape.cells) then
                        startX = startX - 1
                    end

                    --- Put the shape back in the grid
                    PutShapeInGrid()
                end
            end

            --- Rotate
            if(GAME_ENGINE:IsKeyDown(38)) then -- Up Arrow
                rotate()
            end

            --- Fast Fall
            if(GAME_ENGINE:IsKeyDown(40)) then -- Down Arrow
                fall()
            end
        end

        --- Restart the game
        if(GAME_ENGINE:IsKeyDown(82)) then -- R Key
            Restart()
        end

        inputTime = 0
    end
end

--- Rotates the shape
function rotate()
    --- Remove the shape from the grid
    clearShapeFromGrid()

    --- @param newCells # Create a new table for the rotated shape
    local newCells = {}
    local rows = #shape.cells
    local cols = #shape.cells[1]

    --- Rotate the shape 90 degrees clockwise
    for x = 1, cols do
        newCells[x] = {}
        for y = 1, rows do
            newCells[x][y] = shape.cells[rows - y + 1][x]
        end
    end

    --- Make sure the shape doesn't get stuck in the right wall
    if startX + #newCells[1] > 9 then
            --- Else move it back a litle
            startX = 9 - #newCells[1]
    end

    --- If the new rotated shape doesn't collide with anything then apply the rotation
    if not IsGridOccupied(newCells) then
        shape.cells = newCells
    end
    
    --- Put the shape back in the grid
    PutShapeInGrid()
end

--- Restarts the game
function Restart()

    --- Reset all variables
    gameOver = false
    score = 0
    startX = 4
    startY = 0

    --- Clear the grid
	for x = 0, 9 do
        for y = 0, 21 do
            grid[x][y].isOccupied = false
            grid[x][y].color = newColor(211, 211, 211)
        end
    end

    --- Pick a new starting shape
    chooseBlocks()
end