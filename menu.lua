-- Menu for the game [prompted at the start]

local composer = require("composer")
local scene = composer.newScene()

local widget = require("widget")

local gridSize = 5
local animationSpeed = 1

-- Variables for label display
local gridSizeLabel
local animationSpeedLabel

local gridSizeSlider
local animationSpeedSlider

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

-- Function to update gridSize and animationSpeed when sliders change
local function updateSettings()
    gridSize = gridSizeSlider.value
    animationSpeed = animationSpeedSlider.value
end

local function onStartButtonTap(event)
    -- store the grid size and the animation speed to be used throughout the app
    updateSettings()
    composer.setVariable("gridSize", gridSize)
    composer.setVariable("animationSpeed", animationSpeed)

    -- transition to the "gameplay" scene
    composer.gotoScene("gameplay", {effect="fade", time=500, params ={reload = true}})
    return true
end

local function onLoadGameButtonTap(event)
    composer.gotoScene("loadState", { effect = "fade", time = 500 })
    return true
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
    titleLabel:setFillColor(0.2,1.0,0.6)  -- change text colour to a green
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
    gridSizeSlider = widget.newSlider({
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
    animationSpeedSlider = widget.newSlider({
        x = display.contentCenterX,
        y = 250,
        width = 200,
        value = animationSpeed,
        listener = onAnimationSlider,
    })
    sceneGroup:insert(animationSpeedSlider)

    local startButton = widget.newButton({
        label = "Start Game",
        x = display.contentCenterX,
        y = 300,
        onPress = onStartButtonTap,
    })
    sceneGroup:insert(startButton)

    local loadGameButton = widget.newButton({
        label = "Load Game",
        x = display.contentCenterX,
        y = 360,
        onPress = onLoadGameButtonTap,
    })
    sceneGroup:insert(loadGameButton)
    
end

function scene:show(event)
    gridSize = composer.setVariable( "gridSize", gridSizeSlider.value )
    animationSpeed =composer.setVariable( "animationSpeed", animationSpeedSlider.value )
end


scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
return scene
