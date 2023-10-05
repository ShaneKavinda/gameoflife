-- saves the current game state

local composer = require("composer")
local scene = composer.newScene()

local widget = require("widget")
local json = require("json")

local fileNameTextBox
local errorText

local function saveGameState()
    local fileName = fileNameTextBox.text

    -- Check if the file name already exists
    local filePath = system.pathForFile(fileName .. ".json", system.DocumentsDirectory)
    local file = io.open(filePath, "r")

    if file then
        io.close(file)
        errorText.text = "File already exists. Enter a different file name."
        errorText.enabled = true
    else
        local gameState = {
            gridSize = gridSize,
            grid = grid,
        }

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

local function onFileNameTextBoxTap(event)
    errorText.text = ""
end

function scene:create(event)
    local sceneGroup = self.view

    local background = display.newRect(sceneGroup, display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight)
    background:setFillColor(0.5)

    local saveText = display.newText({
        parent = sceneGroup,
        text = "Enter File Name:",
        x = display.contentCenterX,
        y = 100,
        fontSize = 24,
    })

    fileNameTextBox = native.newTextField(display.contentCenterX, 150, 200, 30)
    sceneGroup:insert(fileNameTextBox)
    fileNameTextBox:addEventListener("tap", onFileNameTextBoxTap)

    local saveButton = widget.newButton({
        label = "Save State",
        x = display.contentCenterX,
        y = 200,
        onPress = saveGameState,
    })
    sceneGroup:insert(saveButton)

    errorText = display.newText({
        parent = sceneGroup,
        text = "",
        x = display.contentCenterX,
        y = 250,
        fontSize = 16,
        fillColor = { 1, 0, 0 },
        enabled = false,
    })
    sceneGroup:insert(errorText)
end

scene:addEventListener("create", scene)

return scene
