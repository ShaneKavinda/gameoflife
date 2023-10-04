-- loadState.lua

local composer = require("composer")
local scene = composer.newScene()

local widget = require("widget")
local lfs = require("lfs")  -- lua file system module

local savedStates = {}  -- Table to store saved game states

-- Function to list all saved game state files
local function listSavedStates()
    local path = system.pathForFile("", system.DocumentsDirectory)  -- Get the documents directory path
    for file in lfs.dir(path) do
        if file:match("%.txt$") then
            table.insert(savedStates, file)  -- Add .txt files to the savedStates table
        end
    end
end

-- Function to load a selected game state and return to gameplay.lua
local function loadSelectedState(event)
    local target = event.target
    local selectedState = target.label  -- Get the selected state's filename

    -- Store the selected state's filename in a global variable to access it in gameplay.lua
    composer.setVariable("selectedState", selectedState)

    -- Read the contents of the selected file
    local filePath = system.pathForFile(selectedState, system.DocumentsDirectory)
    local file = io.open(filePath, "r")

    if file then
        -- Read the file content into a global variable (gameState)
        composer.setVariable("gameState", file:read("*all"))
        io.close(file)

        -- Transition back to gameplay.lua
        composer.gotoScene("gameplay", { effect = "fade", time = 500 })
    else
        print("Error: Unable to open the selected file for reading")
    end
end


-- Create a scrollView widget to list saved game states
local scrollView = widget.newScrollView({
    top = 100,
    left = 0,
    width = display.contentWidth,
    height = display.contentHeight - 100,
    scrollWidth = display.contentWidth,
    scrollHeight = 0,  -- This will be calculated dynamically based on the content
    hideScrollBar = false,
})

function scene:create(event)
    local sceneGroup = self.view

    listSavedStates()  -- List all saved game states in the documents directory

    local yOffset = 0  -- Initialize the vertical offset for positioning buttons

    -- Create buttons for each saved state
    for i, stateFilename in ipairs(savedStates) do
        local stateButton = widget.newButton({
            label = stateFilename,
            x = display.contentCenterX,
            y = yOffset + 50,
            onRelease = loadSelectedState,
        })
        scrollView:insert(stateButton)
        yOffset = yOffset + 60
    end

    scrollView:setScrollHeight(yOffset)  -- Set the scrollHeight based on the content

    sceneGroup:insert(scrollView)
end

scene:addEventListener("create", scene)

return scene
