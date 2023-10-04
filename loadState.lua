local composer = require("composer")
local scene = composer.newScene()

local widget = require("widget")
local lfs = require("lfs")  -- Include the "lfs" library for file operations

local savedStates = {}  -- Table to store saved game states
local scrollView  -- Declare scrollView to make it accessible across functions

-- Function to list all saved game state files
local function listSavedStates()
    local path = system.pathForFile("", system.DocumentsDirectory)  -- Get the documents directory path

    for file in lfs.dir(path) do
        if file:match("%.txt$") then
            table.insert(savedStates, file)  -- Add .txt files to the savedStates table
        end
    end
end

-- Function to load a selected game state and switch to gameplay.lua
local function loadSelectedState(event)
    local target = event.target
    local selectedState = target.label  -- Get the selected state's filename

    -- Construct the full file path
    local filePath = system.pathForFile(selectedState, system.DocumentsDirectory)

    -- Check if the file exists
    local fileExists = io.open(filePath, "r")

    if fileExists then
        io.close(fileExists)

        -- Read the selected state file
        local file = io.open(filePath, "r")
        if file then
            local gameState = file:read("*a")  -- Read the entire file as the game state
            io.close(file)

            -- Store the selected state's game state string in a global variable to access it in gameplay.lua
            composer.setVariable("loadedGameState", gameState)

            composer.gotoScene("gameplay", { effect = "fade", time = 500 })  -- Transition to gameplay.lua
        else
            print("Error: Unable to open the selected file for reading")
        end
    else
        print("Error: The selected file does not exist")
    end
end

function scene:create(event)
    local sceneGroup = self.view

    listSavedStates()  -- List all saved game states in the documents directory

    -- Create a scrollView widget to list saved game states
    scrollView = widget.newScrollView({
        top = 100,
        left = 0,
        width = display.contentWidth,
        height = display.contentHeight - 100,
        scrollWidth = display.contentWidth,
        scrollHeight = 0,  -- This will be calculated dynamically based on the content
        hideScrollBar = false,
    })

    local yOffset = 0  -- Initialize the vertical offset for positioning buttons

    -- Create buttons for each saved state and add action listeners
    for i, stateFilename in ipairs(savedStates) do
        local stateButton = widget.newButton({
            label = stateFilename,
            x = display.contentCenterX,
            y = yOffset + 50,
            onRelease = loadSelectedState,  -- Assign the loadSelectedState function as the release event
        })
        scrollView:insert(stateButton)
        yOffset = yOffset + 60
    end

    scrollView:setScrollHeight(yOffset)  -- Set the scrollHeight based on the content

    sceneGroup:insert(scrollView)
end

scene:addEventListener("create", scene)

return scene
