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


function countNeighbors(grid)
    local neighbours = 0
    for i = 1,3 do
        for j = 1,3 do
            if not (i == 2 and j == 2) and (grid[i][j] == 1) then
                neighbours = neighbours + 1
            end
        end
    end
    return neighbours
end

function isAliveNext(neighbours)
   if neighbours == 3 then
        return "alive"
   else
        return "dead"
   end
end
