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
        if file:match("%.json$") then
            table.insert(savedStates, file:sub(1, -6))  -- Remove ".json" extension and add to savedStates
        end
    end
end

-- Function to load a selected game state and return to gameplay.lua
local function loadSelectedState(event)
    local target = event.target
    local selectedState = target.label  -- Get the selected state's filename

    -- Store the selected state's filename in a global variable to access it in gameplay.lua
    composer.setVariable("selectedState", selectedState)

    composer.gotoScene("gameplay", { effect = "fade", time = 500 })  -- Transition back to gameplay.lua
end

-- Allows the user to navigate back to the Menu
local function cancelLoad()
    composer.gotoScene("menu", { effect = "fade", time = 500 })
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
        backgroundColor = { 0, 0, 0 }, -- Set the background color to black
    })

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

    
    local cancelButton = widget.newButton({
        label = "Cancel",
        x = display.contentCenterX,
        y = display.contentHeight - 20,
        onPress = cancelLoad,
    })
    sceneGroup:insert(cancelButton)

end

scene:addEventListener("create", scene)

return scene
