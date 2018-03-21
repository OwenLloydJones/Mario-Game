
-- Define variables
local ScreenW = display.contentWidth
local ScreenH = display.contentHeight
local motionX = 0
local motionY = 0
local score   = 0
local timeStart = 30 --< the length of the game
local timeLeft
local level = 1
local yesSound = audio.loadSound("Yes.wav")
local hitSound = audio.loadSound("Bang.wav")
local backgroundMusic = audio.loadStream("BackGroundMusic.mp3")
local backgroundMusicChannel = audio.play( backgroundMusic,{loops=-5})



function finalAlert( )
	-- Display the final screen showing the certificate
	-- and score
	alert = display.newImage('AlertBg.png')
	ScreenW = display.contentWidth
			ScreenH = display.contentHeight
			alert.x = ScreenW / 1.8
			alert.y = ScreenH / 1.55
	transition.from(alert, {time = 300, xScale = 0.3, yScale = 0.3})
	finalScore = display.newText(score.." pts" , 200, 100, native.systemFontBold, 28)
	finalScore:setTextColor(204, 152, 102)
	-- Display [quit] button
	quitBtn   = display.newImage('quitBtn.png')
	quitBtn.x = 100
	quitBtn.y = 280
	quitBtn:addEventListener('tap', quitApp)
	-- Display [restart] button
	reStartBtn = display.newImage('reStartBtn.png')
	reStartBtn.x = 100
	reStartBtn.y = 240
	reStartBtn:addEventListener('tap', reStart)
	
	



	-- make a group
	finalView = display.newGroup(alert, finalScore, quitBtn, reStartBtn)
	
	--display the help Button
helpBtn = display.newImage("helpBtn.png",430, 70)
helpBtn:addEventListener ("tap",showHelp)
--display the help graphic off screen
helpScreen = display.newImage("demoHelpScroll.png",250,-350)
helpScreen:addEventListener ("tap",hideHelp)
end

function showHelp()
transition.to(helpScreen, {time = 300, y = helpScreen.height/2})
end

function hideHelp()
transition.to(helpScreen, {time = 300, y = -helpScreen.height})
end



function quitApp( )
	-- Close down the app
	os.exit( )
end

function reStart( )
	-- Remove the last screen, calculate the new level,
	-- reset the scores and times, then go back to the game
	display.remove(finalView)
	timeLeft = timeStart
	local newLevel = math.round(score/10+.9)
	if newLevel>level then
		level = level + 1
		local backgroundMusic = audio.loadStream("BackGroundMusic.mp3")
		local backgroundMusicChannel = audio.play( backgroundMusic,{loops=-5})
	end
	score = 0
	game( )
end

function onCollision(self,event)
	-- Something has collided with the mario
	if ( event.phase == "began" ) then
	
		-- Check to see if the object is worth points
		-- and should have been collected
		if self.points <= 0 then
			ouch=display.newImage("marioOuch.png", mario.x, mario.y)
			transition.dissolve(ouch,mario, 1000, 0)
			audio.play(hitSound)
			else
			audio.play(yesSound)
		end
		-- Add the points and remove the object
		score = score + self.points
		self:removeSelf( )
	end
end

function update( )
	-- Update the score and time display
	timeLeft = math.round(timeLeft - 2/level)
	scoreDisplay.text = "Score:" .. score
	timeDisplay.text = "Time Left:" .. timeLeft
	-- Check to see if the time has finished
	if timeLeft <= 0 then
		audio.stop( )
		timer.cancel(dropItems)
		physics.pause( )
		Runtime:removeEventListener ("accelerometer", onAccelerate)
		Runtime:removeEventListener ("enterFrame", movemario)
		mario:removeSelf( )
		leftArrow:removeSelf( )
		rightArrow:removeSelf( )
		timeDisplay:removeSelf( )
		scoreDisplay:removeSelf( )
		finalAlert( )
	end
end

function newItem( )
	-- Spawn a new item
	-- The items are held in a table (names) as their filenames
	-- The scores are held in the table (points)
	local names = {"Apple00", "Apple01", "Apple02", "Ball"}
	local points = {-1, 1, 5, 1, -1, 0, -1, -1 ,-1 ,math.random(-5,5), math.random(0,10)}
	local i = math.random(#names)
	local name = names[i]
	obj = display.newImage(name .. ".png")
	obj.myName = name
	obj.points = points[i]
	obj.collision=onCollision
	obj:addEventListener("collision", obj)
	physics.addBody(obj,"dynamic")
	obj.rotation=math.random( 0, 360 )
	obj.x = math.random( 100, ScreenW-50 )
	obj.y = -50
	update ( )
end

function onAccelerate( event )
	-- Determine the direction to move
	-- Reverse to be more realistic with tilt
	motionX =  10 * -event.xGravity
	motionY =  10 * -event.yGravity
end

function movemario (event)
	-- Move the mario each time a frame is triggered
	-- Use the Y value due to the rotated screen
	mario.x = mario.x + motionY
	mario.y = mario.y + motionX
	wrap ( )
end

function wrap (event)
	-- Stop the mario at the edge
	if mario.x < 30 then
		mario.x = 30
	elseif mario.x > ScreenW-30 then
		mario.x = ScreenW-30
	end
	if mario.y > 270 then
		mario.y = 270
	elseif mario.y < 70 then
		mario.y = 70
	end
end

function left( )
	-- move the mario image to the left
	motionY = -10
end

function right( )
	-- move the mario image to the right
	motionY = 10
end

function stop(event)
	-- Stop the mario from constantly moving
	if event.phase == "ended" then
		motionY = 0
	end
end

--Structure
function dothings( )
	Runtime:addEventListener ("accelerometer", onAccelerate)
	Runtime:addEventListener ("enterFrame", movemario)
	Runtime:addEventListener("touch",stop)
	-- drop things faster per level
	--	L1=2secs; L2=1secs; L3=0.6Sec; L4=0.5sec
	dropItems = timer.performWithDelay(2000/level, newItem, 100)
end

function addPhysics( )
	-- Set up the physics library
	local physics = require"physics"
	physics.setDrawMode("normal")
	physics.start( )
end

function HUD ( )
	-- Create the Heads Up display (Score & Time)
	score = 0
	timeLeft = timeStart
	scoreDisplay = display.newText("Score:" .. score, 100, 50 ,native.systemFont, 20)
	scoreDisplay:setTextColor(0,0,0)
	timeDisplay = display.newText("Time Left:" .. timeLeft, 300, 50, native.systemFont, 20)
	timeDisplay:setTextColor(0, 0, 0)
		quitBtn2   = display.newImage('helpBtn.png', 430, 70)

end

function drawBackground( )
	-- Display the background
	background = display.newImage ("background.png")
	ScreenW = display.contentWidth
			ScreenH = display.contentHeight
			background.x = ScreenW / 2
			background.y = ScreenH / 2
	-- Display the mario
	mario = display.newImage ("mario.png", 210, 270)
	physics.addBody( mario,"static",{radius=30})
	-- Display arrows
	leftArrow= display.newImage ("left.png", 40, 270)
	leftArrow:addEventListener("touch",left)
	rightArrow= display.newImage ("right.png", 435, 270)
	rightArrow:addEventListener("touch",right)
	--add level numbers
	level1 = display.newImage ("1.png",40,60)
	level2 = display.newImage ("2.png",40,110)
	level3 = display.newImage ("3.png",40,160)
	level4 = display.newImage ("4.png",40,210)
	

	if level < 2 then
		level2No= display.newImage ("NoEntry.png", 40, 110)
	end
	if level < 3 then
		level3No= display.newImage ("NoEntry.png", 40, 160)
	end
	if level < 4 then
		level4No= display.newImage ("NoEntry.png", 40, 210)
	end
	
end

function game( )
	-- create the game screen
	addPhysics( )
	drawBackground( )
	HUD ( )
	dothings( )
	
	--display the help Button
helpBtn = display.newImage("helpBtn.png",430, 70)
helpBtn:addEventListener ("tap",showHelp)
--display the help graphic off screen
helpScreen = display.newImage("demoHelpScroll.png",250,-350)
helpScreen:addEventListener ("tap",hideHelp)
end

function showHelp()
transition.to(helpScreen, {time = 300, y = helpScreen.height/2})
end

function hideHelp()
transition.to(helpScreen, {time = 300, y = -helpScreen.height})

end

function introScreen( )
	-- Display the background
	background = display.newImage ("IntroScreen.png")
	ScreenW = display.contentWidth
			ScreenH = display.contentHeight
			background.x = ScreenW / 2
			background.y = ScreenH / 2
	-- Display the play button at the top right
	playBtn = display.newImage ("playBtn.png", 225, 230)
	playBtn:addEventListener('tap', game)
	
	quitBtn2   = display.newImage('quitBtn2.png', 225, 400)
	quitBtn2.x = 225
	quitBtn2.y = 260
	quitBtn2:addEventListener('tap', quitApp)
	
--display the credits Button
	CreditsBtn = display.newImage("CreditsBtn.png",350, 250)
	CreditsBtn:addEventListener ("tap",showCredits)
--display the credits graphic off screen
	CreditsScreen = display.newImage("CreditsScreen.png",250, -350)
	CreditsScreen:addEventListener ("tap",hideCredits)

--display the help Button
	helpBtn = display.newImage("helpBtn.png",430, 70)
	helpBtn:addEventListener ("tap",showHelp)
--display the help graphic off screen
	helpScreen = display.newImage("demoHelpScroll.png",250,-350)
	helpScreen:addEventListener ("tap",hideHelp)
end

function showCredits()
transition.to(CreditsScreen, {time = 300, y = CreditsScreen.height/1.5})
end

function hideCredits()
transition.to(CreditsScreen, {time = 300, y = -CreditsScreen.height})
end
	



function showHelp()
transition.to(helpScreen, {time = 300, y = helpScreen.height/2})
end

function hideHelp()
transition.to(helpScreen, {time = 300, y = -helpScreen.height})
end






	


--Call
	introScreen( )
