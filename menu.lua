-- Menu for the game [prompted at the start]

local composer = require("composer")
local scene = composer.newScene()

local widget = require("widget")

-- Add default values for the grid size and the animation speed
local gridSize = 5
local animationSpeed = 1

-- Variables for label display
local gridSizeLabel
local animationSpeedLabel

-- store the grid size chosen by the User
local function onGridSizeSlider(event)
    gridSize = event.value
    gridSizeLabel.text = "Grid Size: " .. gridSize
end

-- get the user input for the speed of the animation
local function onAnimationSlider(event)
    animationSpeed = event.value
    animationSpeedLabel.text = "Animation Speed: " .. animationSpeed
end

local function onStartButtonTap(event)
    -- store the grid size and the animation speed to be used throughout the app
    composer.setVariable("gridSize", gridSize)
    composer.setVariable("animationSpeed", animationSpeed)

    -- transition to the "gameplay" scene
    composer.gotoScene("gameplay", {effect="fade", time=500})
end

function scene:create(event)
    local sceneGroup = self.view

    --create and display title label
    local titleLabel = display.newText({
        text = "Game of Life",
        x = display.contentCenterX,
        y = 40,
        fontSize = 24,
        font = native.systemFontBold,
    })
    sceneGroup:insert(titleLabel)

    -- Create and display a label for grid size
    gridSizeLabel = display.newText({
        text = "Grid Size: " .. gridSize,
        x = display.contentCenterX,
        y = 100,
        fontSize = 18,
    })
    sceneGroup:insert(gridSizeLabel)

    -- Create a grid size slider
    local gridSizeSlider = widget.newSlider({
        x = display.contentCenterX,
        y = 150,
        width = 200,
        value = gridSize,
        listener = onGridSizeSlider,
    })
    sceneGroup:insert(gridSizeSlider)

    -- Create and display a label for animation speed
    animationSpeedLabel = display.newText({
        text = "Animation Speed: " .. animationSpeed,
        x = display.contentCenterX,
        y = 200,
        fontSize = 18,
    })
    sceneGroup:insert(animationSpeedLabel)

    -- Create an animation speed slider
    local animationSpeedSlider = widget.newSlider({
        x = display.contentCenterX,
        y = 250,
        width = 200,
        value = animationSpeed,
        listener = onAnimationSlider,
    })
    sceneGroup:insert(animationSpeedSlider)

    -- Create a "Start Game" button
    local startGameButton = widget.newButton({
        label = "Start Game",
        x = display.contentCenterX,
        y = 320,
        onPress = onStartButtonTap,
    })
    sceneGroup:insert(startGameButton)
end

scene:addEventListener("create", scene)

return scene
