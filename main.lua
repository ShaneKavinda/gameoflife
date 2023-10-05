-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here

-- Perform unit testing

require("lunatest") --import the test framework
require("modules.myFunctions") -- import the code to test
require("tests.Mytests") -- import the tests and run them

-- start program code
local composer = require("composer")

composer.gotoScene( "menu", {effect="fade", time=500} )