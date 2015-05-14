display.setStatusBar(display.HiddenStatusBar)

-- Physics

local physics = require("physics")
physics.start()

-- Graphics
-- [Background]
local gameBg

-- [Splash]
local splashBg

-- [Title View]
local titleBg
local playButton
local titleView

-- Instructions
local ins

-- Dodger Dude Thing Guy
local player

-- Platforms
local platforms = {}

-- Alert View
local alertView

-- Sounds
local mainMenuMusic = audio.loadStream("odyssey.mp3")
local music1 = audio.loadStream("bensound-memories.mp3")
local music2 = audio.loadStream("dream-culture.mp3")
local music3 = audio.loadStream("bensound-goinghigher.mp3")
local gameOverMusic = audio.loadStream("easy-lemon.mp3")

-- Variables
local timerSrc
local colorSrc
local yPos = 0
local speed = 1
local up = false
local impulse = -60
local lastRandom = 0
local scale = 16

local red = math.floor(math.random() * 255)
local green = math.floor(math.random() * 255)
local blue = math.floor(math.random() * 255)
local redflip = false
local greenflip = false
local blueflip = false

local Main = {}
local startButtonListeners = {}
local showCredits = {}
local showGameView = {}
local gameListeners = {}
local createBlock = {}
local movePlayer = {}
local increaseSpeed = {}
local update = {}
local alert = {}

function Main()
	titleBg = display.newImage("background.png")
	titleBg:scale(display.contentWidth, display.contentHeight)
	titleBg:translate(titleBg.contentWidth / 2, titleBg.contentHeight / 2)
	titleBg:setFillColor(red / 255, green / 255, blue / 255)
	playButton = display.newImage("play.png")
	playButton:translate(playButton.width / 2 + 10, playButton.height * 3)
	titleView = display.newGroup()
	titleView:insert(titleBg)
	titleView:insert(playButton)

	startButtonListeners('add')
end

function startButtonListeners(action)
	if (action=='add') then
		playButton:addEventListener('tap', showGameView)
	else
		playButton:removeEventListener('tap', showGameView)
	end
end

function showGameView:tap(e)
	gameBg = display.newImage("background.png")
	gameBg:scale(display.contentWidth, display.contentHeight)
	gameBg:translate(gameBg.contentWidth / 2, gameBg.contentHeight / 2)
	gameBg:setFillColor(red / 255, green / 255, blue / 255)

	transition.to(titleView, {time = 300, x = -titleView.height, onComplete = function() startButtonListeners('rmv') display.remove(titleView) titleView = nil end})
	ins = display.newImage("ins.png", 160, 270)
	transition.from(ins, {time = 200, alpha = 0.1, onComplete = function() timer.performWithDelay(2000, function() transition.to(ins, {time = 200, alpha = 0.1, onComplete = function() display.remove(ins) ins = nil end}) end) end})
	scoreTF = display.newText('0', 450, 5, 'Fjalla', 14)
	scoreTF:setTextColor(255, 255, 255)
	player = display.newImage('player.png', 200, 200)
	player:scale(scale, scale)

	local right = display.newRect(8, 240, 16, display.actualContentHeight)
	right:setFillColor(255, 255, 255)
	local left = display.newRect(display.actualContentWidth - 8, 240, 16, display.actualContentHeight)
	left:setFillColor(255, 255, 255)

	blocks = display.newGroup()
	gameListeners('add')
	--audio.play(music1, {loops = -1, channel = 1}) 
end

function gameListeners(action)
	if (action == 'add') then
		gameBg:addEventListener('touch', movePlayer)
		Runtime:addEventListener('enterFrame', update)
		timerSrc = timer.performWithDelay(2000, createBlock, 0)
		colorSrc = timer.performWithDelay(1000, color, 0)
		player:addEventListener('collision', onCollision)
	else
		gameBg:addEventListener('touch', movePlayer)
		Runtime:removeEventListener('enterFrame', update)
		timer.cancel(timerSrc)
		timerSrc = nil
		timer.cancel(colorSrc)
		colorSrc = nil
		player:removeEventListener('collision', onCollision)
	end
end

function createBlock()
	if (ins == nil) then
		local b1, b2
		local rnd = lastRandom + math.floor(math.random() * 3) + 1
		if (rnd > 3) then
			rnd = rnd - 4
		end
		local yp = yPos
		lastRandom = rnd
		b1 = display.newImage('player.png', display.contentWidth - (player.contentWidth * rnd) - 32, yp)
		b2 = display.newImage('player.png', (player.contentWidth * rnd) + 32, yp)
		b1:scale(scale, scale)
		b2:scale(scale, scale)
		b1.name = 'block'
		b2.name = 'block'
		physics.addBody(b1, 'kinematic')
		physics.addBody(b2, 'kinematic')
		b1.isSensor = true
		b2.isSensor = true
		blocks:insert(b1)
		blocks:insert(b2)
	end
end

function movePlayer(e)
	if (e.phase == 'begin') then
		up = true
	end
	if (e.phase == 'end') then
		up = false
		impulse = -60
	end
end

function update(e)
	if (up) then
		impulse = impulse - 3
		player:setLinearVelocity(0, impulse)
	end

	if (blocks ~= nil) then
		for i = 1, blocks.numChildren do
			blocks[i].y = blocks[i].y + speed
		end
	end

	scoreTF.text = tostring(tonumber(scoreTF.text) + 1)
end

function onCollision(e)
	display.remove(player)
end

function color()
	if (redflip == true) then
		red = red - math.floor(math.random() * 5)
	else
		red = red + math.floor(math.random() * 5)
	end
	if (greenflip == true) then
		green = green - math.floor(math.random() * 5)
	else
		green = green + math.floor(math.random() * 5)
	end
	if (blueflip == true) then
		blue = blue - math.floor(math.random() * 5)
	else
		blue = blue + math.floor(math.random() * 5)
	end

	if (red > 255) then
		redflip = true
	end
	if (red < 0) then
		redflip = false
	end
	if (green > 255) then
		greenflip = true
	end
	if (green < 0) then
		greenflip = false
	end
	if (blue > 255) then
		blueflip = true
	end
	if (blue < 0) then
		blueflip = false
	end

	if (gameBg ~= nil) then
		gameBg:setFillColor(red / 255, green / 255, blue / 255)
	end
end

Main()