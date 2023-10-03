-- gameplay.lua

local composer = require("composer")
local scene = composer.newScene()

local widget = require("widget")

-- Get grid size and animation speed from menu.lua
local gridSize = composer.getVariable("gridSize")
local animationSpeed = composer.getVariable("animationSpeed")

-- Create a 2D grid to represent the Game of Life
local grid = {}
local cellSize = math.min(display.actualContentHeight, display.actualContentWidth)/gridSize  -- Size of each cell in pixels
local cellGroup = display.newGroup()  -- Group to hold cell objects
local isPaused = false  -- Flag to pause or resume the simulation

-- Function to initialize the grid with random values
local function initializeGridRandomly()
    for i = 1, gridSize do
        grid[i] = {}
        for j = 1, gridSize do
            grid[i][j] = math.random(0, 1)
        end
    end
end

-- Function to create cells based on the grid
local function createCells()
    for i = 1, gridSize do
        for j = 1, gridSize do
            local cell = display.newRect(
                (j - 0.5) * cellSize,
                (i - 0.5) * cellSize,
                cellSize,
                cellSize
            )
            cell.anchorX, cell.anchorY = 0.5, 0.5
            cell:setFillColor(grid[i][j], grid[i][j], grid[i][j])
            cellGroup:insert(cell)

            -- Toggle cell state when tapped
            cell:addEventListener("tap", function(event)
                if not isPaused then
                    if grid[i][j] == 0 then
                        grid[i][j] = 1
                        cell:setFillColor(1, 1, 1)
                    else
                        grid[i][j] = 0
                        cell:setFillColor(0, 0, 0)
                    end
                end
            end)
        end
    end
end


-- Function to calculate the next state of the grid based on Game of Life rules
-- renamed the function next_iter to a more concise function name.
local function calculateNextState()
    local newGrid = {}
    for row = 1, gridSize do
        newGrid[row] = {}
        for column = 1, gridSize do 
            --check the neighbours
            neighbours = 0
            for i = -1, 1 do
                for j = -1, 1 do
                    -- we take modulus to account for wrap around of the 2D array
                    -- if we are on row = 1;
                    -- neighbouring rows should be 3 and 5;
                    -- when i = -1; n_row = (1 + -1 -1) % 5 + 1 = (-1 % 5) + 1 = 4 + 1 = 5
                    n_row = ((row + i - 1) % gridSize) + 1
                    n_col = ((column + j - 1) % gridSize) + 1
                    if not(i == 0 and j == 0) and (grid[n_row][n_col] == 1) then
                        neighbours = neighbours + 1
                    end
                end
            end
    
            -- check if the cell will be alive in the next iteration
            if grid[row][column] == 1 then
                if neighbours < 2 or neighbours > 3 then
                    newGrid[row][column] = 0
                else
                    newGrid[row][column] = 1
                end
            else
                if neighbours == 3 then
                    newGrid[row][column] = 1
                else
                    newGrid[row][column] = 0
                end
            end
        end
    end

    grid = newGrid
end

-- Function to update the display with the current grid state
local function updateDisplay()
    for i = 1, gridSize do
        for j = 1, gridSize do
            local cell = cellGroup[(i - 1) * gridSize + j]
            cell:setFillColor(grid[i][j], grid[i][j], grid[i][j])
        end
    end
end

-- Function to advance the simulation
local function advanceSimulation()
    calculateNextState()
    updateDisplay()

    if not isPaused then
        local delay = animationSpeed * 1000  -- Convert animation speed to milliseconds
        timer.performWithDelay(delay, advanceSimulation)
    end
end

-- Function to toggle pause/resume of the simulation
local function togglePause()
    isPaused = not isPaused
end

function scene:create(event)
    local sceneGroup = self.view

    initializeGridRandomly()
    createCells()
    sceneGroup:insert(cellGroup)

    local pauseButton = widget.newButton({
        label = "Pause",
        x = display.contentCenterX,
        y = display.contentHeight - 50,
        onPress = togglePause,
    })
    sceneGroup:insert(pauseButton)

    advanceSimulation()
end

scene:addEventListener("create", scene)

return scene
