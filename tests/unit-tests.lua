module(..., package.seeall)  -- need this to make things visible


function test_SaveFunction()
	assert_equal(saveFile("testState"),"File already exists. Enter a different file name.")
end


-- Test if the program counts neighbours correctly
case1 = {{1,1,1}, {1,0,0}, {0,0,0}}
function test_countNeighbours()
	assert_equal(countNeighbors(case1), 4)
end

case2 = {{0,0,1}, {0,0,1}, {0,0,0}}
function test_countNeighbours2()
	assert_equal(countNeighbors(case2), 2)
end

case3 = {{1,1,1}, {0,1,1}, {1,0,0}}
function test_countNeighbours3()
	assert_equal(countNeighbors(case3), 5)
end

-- check if the cell remains alive in the next state

function test_isAliveNext1()
	local neighbours = 0
	assert_equal(isAliveNext(neighbours),"dead")
end

function test_isAliveNext2()
	local neighbours = 3
	assert_equal(isAliveNext(neighbours),"alive")
end

function test_isAliveNext3()
	local neighbours = 7
	assert_equal(isAliveNext(neighbours),"dead")
end
