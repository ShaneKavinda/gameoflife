-- gameplay.lua

local composer = require("composer")
local scene = composer.newScene()

local widget = require("widget")

-- Get grid size and animation speed from menu.lua
local gridSize = composer.getVariable("gridSize")
local animationSpeed = composer.getVariable("animationSpeed")

-- Get game state from scene loadState
local gameState = composer.getVariable("gameState")

-- Create a 2D grid to represent the Game of Life
local grid = {}
local cellSize = math.min(display.actualContentHeight, display.actualContentWidth)/gridSize  -- Size of each cell in pixels
local cellGroup = display.newGroup()  -- Group to hold cell objects
local isPaused = false  -- Flag to pause or resume the simulation

local sceneGroup  -- Declare sceneGroup to make it accessible across functions

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

-- Store the reference to the active timer
local activeTimer = nil

-- Function to advance the simulation
local function advanceSimulation()
   

    -- Clear the active timer if it exists
    if activeTimer then
        timer.cancel(activeTimer)
    end

    if not isPaused then
        local delay = animationSpeed * 1000  -- Convert animation speed to milliseconds
        calculateNextState()
        updateDisplay()
        -- Store the reference to the new timer
        activeTimer = timer.performWithDelay(delay, advanceSimulation)
    end
end


-- Function to handle the "Pause" button tap event
local function pauseButtonTap(event)
    isPaused = not isPaused
    local sceneGroup = event.target.parent  -- Get the parent group of the button

    local pauseButton = sceneGroup.pauseButton
    local saveStateButton = sceneGroup.saveStateButton

    if isPaused then
        pauseButton:setLabel("Resume")
        saveStateButton:setEnabled(true)  -- Enable the "Save State" button when paused
    else
        pauseButton:setLabel("Pause")
        saveStateButton:setEnabled(false)  -- Disable the "Save State" button when resumed
        advanceSimulation()  -- Resume the simulation when unpaused
    end

    return true  -- Prevents touch propagation to objects below the button
end

-- Function to handle the "Save State" button tap event
local function saveStateButtonTap(event)
    local sceneGroup = event.target.parent  -- Get the parent group of the button
    local filePath = system.pathForFile("game_state.txt", system.DocumentsDirectory)
    local file = io.open(filePath, "w")

    if file then
        for i = 1, gridSize do
            for j = 1, gridSize do
                file:write(grid[i][j] .. " ")
            end
            file:write("\n")
        end
        io.close(file)
        print("Game state saved to game_state.txt")
    else
        print("Error: Unable to open the file for writing")
    end

    return true  -- Prevents touch propagation to objects below the button
end

-- Function to handle the "Main Menu" button tap event
local function gotoMainMenu(event)
     -- store the grid size and the animation speed to be used throughout the app
     composer.setVariable("gridSize", gridSize)
     composer.setVariable("animationSpeed", animationSpeed)
    -- go to the scene "Menu"
    composer.gotoScene( "menu",{effect="fade", time=500} )
end

-- Function to initialize the grid from a provided game state string
local function initializeGridFromState(gameState)
    -- Split the gameState string into rows
    local rows = {}
    for row in string.gmatch(gameState, "[^\n]+") do
        table.insert(rows, row)
    end

    -- Initialize the grid based on the parsed rows
    for i = 1, gridSize do
        grid[i] = {}
        local rowValues = {}
        for value in string.gmatch(rows[i], "%S+") do
            table.insert(rowValues, tonumber(value))
        end

        if #rowValues >= gridSize then
            for j = 1, gridSize do
                grid[i][j] = rowValues[j]
            end
        else
            print("Error: Invalid game state format.")
            -- You might want to handle this error condition in an appropriate way
        end
    end
end

-- start a the game with a new randomized seed
function startNewGame()
    initializeGridRandomly()
    updateDisplay()
end

function scene:create(event)
    local sceneGroup = self.view

    local gameState = composer.getVariable( gameState )
    if gameState then
        initializeGridFromState(gameState)  -- use the loaded game state to initialize the grid
    else
        initializeGridRandomly()
    end

    createCells()
    sceneGroup:insert(cellGroup)

    local pauseButton = widget.newButton({
        label = "Pause",
        x = display.contentCenterX/4,
        y = display.contentHeight - 50,
        onPress = pauseButtonTap,
    })
    sceneGroup:insert(pauseButton)

    local saveStateButton = widget.newButton({  -- Create a "Save State" button
        label = "Save State",
        x = display.contentCenterX + display.actualContentWidth/4,
        y = display.contentHeight - 50,
        enabled = false,  -- Initially disabled when not paused
        onPress = saveStateButtonTap,
    })
    sceneGroup:insert(saveStateButton)

    local homeButton = widget.newButton( {
        label = "Main Menu",
        x = display.contentCenterX/4,
        y = display.contentHeight - 20,
        onPress = gotoMainMenu,
    } )
    sceneGroup:insert(homeButton)

    local newGameButton = widget.newButton({
        label = "New Game",
        x = display.contentCenterX + display.actualContentWidth/4,
        y = display.contentHeight - 20,
        onPress = startNewGame,
    })
    sceneGroup:insert(newGameButton)

    -- Store the buttons in scene properties
    sceneGroup.pauseButton = pauseButton
    sceneGroup.saveStateButton = saveStateButton

    advanceSimulation()
end

scene:addEventListener("create", scene)

return scene
