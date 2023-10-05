local composer = require("composer")
local scene = composer.newScene()

local widget = require("widget")
local lfs = require("lfs")  -- Include the "lfs" library for file operations
local json = require("json")  -- Include the "json" library for JSON parsing

local savedStates = {}  -- Table to store saved game state filenames

local sceneGroup
local scrollView  -- Declare scrollView to make it accessible across functions

-- Function to list all saved game state files
local function listSavedStates()
    local path = system.pathForFile("", system.DocumentsDirectory)  -- Get the documents directory path
    savedStates = {}  -- Clear the list of saved states
    for file in lfs.dir(path) do
        if file:match("%.json$") then
            table.insert(savedStates, file)  -- Add filenames with .json extension to savedStates
        end
    end
end

-- Function to load a selected game state and return to gameplay.lua
local function loadSelectedState(event)
    local target = event.target
    local selectedState = target:getLabel()  -- Get the selected state's filename

    -- Create the full file path to the selected state
    local filePath = system.pathForFile(selectedState, system.DocumentsDirectory)

    -- Read the JSON data from the selected state file
    local file = io.open(filePath, "r")

    if file then
        local jsonString = file:read("*a")  -- Read the entire file as a string
        io.close(file)

        -- Decode the JSON string into a Lua table
        local loadedData = json.decode(jsonString)


        if loadedData then
            -- The 'loadedData' variable now contains your loaded Lua table
            print("JSON data loaded successfully.")
            composer.setVariable( "gridSize", loadedData[2] )
            composer.setVariable( "gameState", loadedData[1] )
            -- You can access the loaded data as needed, e.g., loadedData.gridSize and loadedData.grid

            -- Store the selected state's data in a global variable to access it in gameplay.lua
            composer.setVariable("loadedGameState", loadedData)
            composer.removeScene("loadState")
            composer.gotoScene("gameplay", { effect = "fade", time = 500 })  -- Transition to gameplay.lua
        else
            print("Error: Unable to decode JSON data.")
        end
    else
        print("Error: Unable to open the file for reading")
    end

    return true
end

-- Allows the user to navigate back to the Menu
local function cancelLoad()
    composer.gotoScene("menu", { effect = "fade", time = 500 })
end


-- Function to create the scroll view
local function createScrollView()
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
end

function scene:create(event)
    sceneGroup = self.view

    listSavedStates()  -- List all saved game states in the documents directory

    -- Create a scrollView widget to list saved game states
    scrollView = widget.newScrollView({
        top = 100,
        left = 0,
        width = display.contentWidth,
        height = display.contentHeight - 200,
        scrollWidth = display.contentWidth,
        scrollHeight = 0,  -- This will be calculated dynamically based on the content
        hideScrollBar = false,
        backgroundColor = { 0, 0, 0 }, -- Set the background color to black
    })

    createScrollView()  -- Create the initial scrollView

    sceneGroup:insert(scrollView)

    local cancelButton = widget.newButton({
        label = "Cancel",
        x = display.contentCenterX,
        y = display.contentHeight - 10,
        onPress = cancelLoad,
    })
    sceneGroup:insert(cancelButton)
end

scene:addEventListener("create", scene)

return scene
