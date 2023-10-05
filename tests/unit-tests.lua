module(..., package.seeall)  -- need this to make things visible

function testAdd()
	assert_equal(add(2,2), 4)
end 

function testSaveFunction()
	assert_equal(saveFile("testState"),"File already exists. Enter a different file name.")
end

state1 = {{0,0,0,0,0},
{0,1,1,0,0},
{0,1,1,0,0} ,
{0,0,0,0,0},
{0,0,0,0,0}}
gridSize = 5
function testNextIteration()
	assert_equal(calculateNextState(state1, gridSize), {{0,0,0,0,0},
	{0,1,1,0,0},
	{0,1,1,0,0} ,
	{0,0,0,0,0},
	{0,0,0,0,0}})
end

state2 = {{0,0,0,0,0},
{0,1,0,0,0},
{0,0,1,0,0},
{0,0,0,1,0},
{0,0,0,0,0}}

function testNextIteration2()
	assert_equal(calculateNextState(state2, gridSize), {{0,0,0,0,0},
	{0,0,0,0,0},
	{0,0,1,0,0},
	{0,0,0,0,0},
	{0,0,0,0,0}})
end