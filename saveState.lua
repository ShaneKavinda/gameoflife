-- saves the current game state

local composer = require("composer")
local scene = composer.newScene()

local lfs = require("lfs")
local widget = require("widget")
local json = require("json")

local fileNameTextBox
local errorText
local gameState

local function saveGameState(gameState)
    local fileName = fileNameTextBox.text

    -- Check if the file name is empty
    if fileName == "" then
        errorText.text = "File name cannot be empty"
        return true
    end

    -- Check if the file already exists
    local filePath = system.pathForFile(fileName .. ".json", system.DocumentsDirectory)
    local fileExists = lfs.attributes(filePath, "mode")

    if fileExists == "file" then
        errorText.text = "File already exists. Enter a different file name."
        errorText.enabled = true
    else
        local file = io.open(filePath, "w")

        if file then
            file:write(json.encode(gameState))
            io.close(file)
            print("Game state saved to " .. fileName .. ".json")
            composer.gotoScene("gameplay", { effect = "fade", time = 500 })
        else
            print("Error: Unable to open the file for writing")
        end
    end
end


-- Function that is triggered when save button is tapped.
local function onSaveButtonTap(event)
    composer.getVariable( "gameState" )
    saveGameState(gameState)
end


local function onFileNameTextBoxTap(event)
    errorText.text = ""
end


-- Allows the user to navigate back to the gameplay
local function cancelSave()
    composer.gotoScene("gameplay", { effect = "fade", time = 500 })
end


local function onFileNameFocus(event)
    if event.phase == "began" then
        -- Text box clicked; do nothing
    elseif event.phase == "editing" then
        -- Text box content is being edited; do nothing
    elseif event.phase == "submitted" then
        -- Text box submitted 
        native.setKeyboardFocus(nil)  -- Hide the keyboard
    end
end

-- Function to enable the native keyboard when the text box is tapped
local function onFileNameTap(event)
    if event.phase == "ended" then
        -- Set focus to the text box when tapped
        native.setKeyboardFocus(fileNameTextBox)
    end
end


function scene:create(event)
    local sceneGroup = self.view

    local grid = composer.getVariable( "grid" )
    local gridSize = composer.getVariable( "gridSize" )

    gameState = {
        grid,
        gridSize,
    }

    local saveText = display.newText({
        parent = sceneGroup,
        text = "Enter File Name:",
        x = display.contentCenterX,
        y = 100,
        fontSize = 24,
    })
    sceneGroup:insert(saveText)

    fileNameTextBox = native.newTextField(display.contentCenterX, 150, 200, 30)
    fileNameTextBox.inputType = "default"
    fileNameTextBox.placeholder = "Enter file name"
    fileNameTextBox:addEventListener("userInput", onFileNameFocus)
    fileNameTextBox:addEventListener("tap", onFileNameTap)  -- Add tap event listener

    sceneGroup:insert(fileNameTextBox)
    fileNameTextBox:addEventListener("tap", onFileNameTextBoxTap)

    local saveButton = widget.newButton({
        label = "Save State",
        x = display.contentCenterX,
        y = 200,
        onPress = onSaveButtonTap,
    })
    sceneGroup:insert(saveButton)

    errorText = display.newText({
        parent = sceneGroup,
        text = "",
        x = display.contentCenterX,
        y = 250,
        fontSize = 16,
        fillColor = { 1, 0, 0 },    -- color red for error messages
        enabled = false,
    })
    sceneGroup:insert(errorText)

    local cancelButton = widget.newButton({ -- add a button to cancel and go back to gameplay
        label = "Cancel",
        x = display.contentCenterX,
        y = display.contentHeight - 20,
        onPress = cancelSave,
    })
    sceneGroup:insert(cancelButton)
end

function scene:hide(event)
    if event.phase == "will" then
        -- Remove the text box when the scene is about to hide
        if fileNameTextBox then
            fileNameTextBox:removeSelf()
            fileNameTextBox = nil
        end
    end
end

scene:addEventListener("create", scene)
scene:addEventListener("hide", scene) 

return scene
