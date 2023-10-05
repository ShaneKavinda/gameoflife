local json = require("json")

function add(a, b)
	return(a+b)
end 


function saveFile(fileName)
    local filePath = system.pathForFile(fileName .. ".json", system.DocumentsDirectory)
    local file = io.open(filePath, "r")

    if file then
        io.close(file)
        return "File already exists. Enter a different file name."
    else
        local gameState = {
            gridSize = 5,
            grid = {{0,0,0,0,0},
            {0,1,1,0,0},
            {0,1,1,0,0} ,
            {0,0,0,0,0},
            {0,0,0,0,0} },
        }

        local file = io.open(filePath, "w")

        if file then
            file:write(json.encode(gameState))
            io.close(file)
            return "Game state saved to " .. fileName .. ".json"
        else
            return "Error: Unable to open the file for writing"
        end
    end
    file = nil
end

function calculateNextState(grid, gridSize)
    local newGrid = {}
    for row = 1, gridSize do
        newGrid[row] = {}
        for column = 1, gridSize do
            -- Check the neighbors
            local neighbours = 0
            for i = -1, 1 do
                for j = -1, 1 do
                    -- Calculate the neighbor's position with wrap-around
                    local n_row = ((row + i - 1 - 1) % gridSize) + 1
                    local n_col = ((column + j - 1 - 1) % gridSize) + 1
                    if not (i == 0 and j == 0) and (grid[n_row][n_col] == 1) then
                        neighbours = neighbours + 1
                    end
                end
            end

            -- Check if the cell will be alive in the next iteration
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

    return newGrid
end
