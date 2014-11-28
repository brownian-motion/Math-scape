--------------------------------------------------
--	sprites.lua
--
--  intended to facilitate sprite control as a player object
--  by adding :moveLeft(), :moveRight(), and :jump() to that object
--
--------------------------------------------------
require "composer";
local sprites = {}
sprites.JERKINESS_CORRECTION = -0.05;

function sprites.addDisplayControls(sprite)
	sprite.setSize = sprites.setSize
	sprite.getBoundingShape = sprites.getBoundingShape;
end

function sprites.addTouchControls(sprite)
	sprite.jump = sprites.jump
	sprite.moveLeft = sprites.moveLeft
	sprite.startMovingLeft = sprites.startMovingLeft
	sprite.stopMovingLeft = sprites.stopMovingLeft
	sprite.moveRight = sprites.moveRight
	sprite.startMovingRight = sprites.startMovingRight
	sprite.stopMovingRight = sprites.stopMovingRight
	sprite.isFixedRotation = true;
	sprite.freezeControl = sprites.freezeControl;
	sprite.returnControl = sprites.returnControl;
	sprite.assignControl = sprites.assignControl;
	sprite.updateSequence = sprites.updateSequence;
	--sprite.preCollision = sprites.preCollision
	--sprite.postCollision = sprites.postCollision
	--sprite:addEventListener( "preCollision", sprite )
	--sprite:addEventListener( "postCollision", sprite )
end

-- sprites:jump() is called when a sprite is told to jump.
-- It (currently) implements this by setting vertical velocity
-- to a constant value, rather than delivering an impulse
function sprites:jump( event )
	--print( (self.name or "Your sprite!") .. " just jumped!")
	if(not(event.name == "ai" or event.name == "tap" or (event.name == "touch" and event.phase == "ended") or (event.name == "key" and event.phase == "down"))) then
		return false;
	end
	self.linearDamping = 0;
	local vx , vy = self:getLinearVelocity()
	vy = -globals.verticalJumpSpeed * globals.pixelsPerMeter[composer.getSceneName("current")];
	-- vy = -self.height;
	--[[if(self.sequence~="jumping" and self.sequence~="jumping left") then
		self:setLinearVelocity( vx, vy )
		self:setSequence( "jumping" )
		self:play()
	end]]--
	if(not self.isJumping) then self.numJumps = 0; end
	if(not self.isJumping or (self.canDoubleJump and self.numJumps < 2)) then
		if(self.sequence=="walking left" or self.sequence=="standing left") then
			self:setSequence( "jumping left" )
		else
			self:setSequence( "jumping right" )
		end
		self:setLinearVelocity( vx, vy )
		self:play()
		self.numJumps = self.numJumps + 1;
		self.isJumping = true;
	end

	
end

--[[function sprites:jumpLeft( event )
	--print( (self.name or "Your sprite!") .. " just jumped!")
	if(not(event.name == "ai" or event.name == "tap" or (event.name == "touch" and event.phase == "ended") or (event.name == "key" and event.phase == "down"))) then
		return false;
	end
	self.linearDamping = 0;
	local vx , vy = self:getLinearVelocity()
	vy = -globals.verticalJumpSpeed * globals.pixelsPerMeter[composer.getSceneName("current")];
	-- vy = -self.height;
	if(self.sequence~="jumping left" and self.sequence~="jumping") then
		self:setLinearVelocity( vx, vy )
		self:setSequence( "jumping left" )
		self:play()
	end
	if(self.sequence~="jumping right" or self.sequence~="jumping left") then
		if(self.sequence=="walking left" or self.sequence=="standing left") then
			self:setLinearVelocity( vx, vy )
			self:setSequence( "jumping left" )
			self:play()
		else
			self:setLinearVelocity( vx, vy )
			self:setSequence( "jumping right" )
			self:play()
		end
	end
end]]--

function sprites:moveLeft( event )
	--print( (self.name or "Your sprite!") .. "just moved left!" .. "   phase: " .. event.phase)

	if(self.controller == "player" or (self.controller == "ai" and event.name == "ai")) then
		if(event.phase == "began" or event.phase == "down") then
			--move left every frame
			self:startMovingLeft()
			self:setSequence( "walking left" )
			self:play()
		end
		if(event.phase == "cancelled" or event.phase == "ended" or event.phase == "up") then
			--stop moving left every frame
			self:stopMovingLeft()
			self:setSequence( "standing left" )
			self:play()
		end
	end
end

function sprites:moveRight( event )
	--print( (self.name or "Your sprite!") .. "just moved right!" .. "   phase: " .. event.phase)

	if(event.phase == "began" or event.phase == "down") then
		--move right every frame
		self:startMovingRight()
		self:setSequence( "walking right" )
		self:play()
	end
	if(event.phase == "cancelled" or event.phase == "ended" or event.phase == "up") then
		--stop moving right every frame
		self:stopMovingRight()
		self:setSequence( "standing right" )
		self:play()
	end
end

function sprites:startMovingLeft()
	self.linearDamping = 0;
	local vx , vy = self:getLinearVelocity()
	vx = -globals.horizontalRunSpeed; --negative to move left
	vy = vy + sprites.JERKINESS_CORRECTION; --pushed up just a bit to prevent getting stuck
	self:setLinearVelocity( vx, vy )
	self.isMovingLeft = true
	self.isMoving = true
	self.isMovingRight = false
	--print("starting moving left");
end

function sprites:stopMovingLeft()
	self.isMovingLeft = false
	self.isMoving = false
	self.isMovingRight = false
	--print("stopping moving left");
end

function sprites:startMovingRight()
	self.linearDamping = 0;
	local vx , vy = self:getLinearVelocity()
	vx = globals.horizontalRunSpeed; --positive to move right
	vy = vy + sprites.JERKINESS_CORRECTION; --pushed up just a bit to prevent getting stuck
	self:setLinearVelocity( vx, vy )
	self.isMovingLeft = false
	self.isMoving = true
	self.isMovingRight = true
	--print("starting moving right");
end

function sprites:stopMovingRight()
	self.isMovingLeft = false
	self.isMoving = false
	self.isMovingRight = false
	--print("stopping moving right");
end

--setSpriteSize takes a sprite and a table of options.
--if only width or height is specified, then the whole image is scaled preserving the aspect ratio.
--if both width and height are specified, then the image is stretched to that size.
function sprites:setSize( spriteObj, dimensionTable )
	--print( spriteObj.width);
    local yMult, xMult;
    if(dimensionTable.height) then
        yMult = (dimensionTable.height) / (spriteObj.height)  --intended size / current sprite size
    end
    if(dimensionTable.width) then
        xMult = (dimensionTable.width) / (spriteObj.width)  --intended size / current sprite size
    end

    if(not xMult) then
        spriteObj.yScale = yMult
        spriteObj.xScale = yMult
    elseif(not yMult) then
        spriteObj.yScale = xMult
        spriteObj.xScale = xMult
    else
        spriteObj.yScale = yMult
        spriteObj.xScale = xMult
    end
end

--
function sprites:getBoundingShape()
	local simpleShape = {};
	if(self.simpleShape) then 
		simpleShape = self.simpleShape
	else
		simpleShape = {
			 1/2,	-1/2,
			 1/2,	 1/2,
			-1/2,	 1/2,
			-1/2,	-1/2,
		}
		--print("default bounding box set for sprite "..(sprite.name or ""))
	end
	--print("generating shape bounding box...")
	local trueShape = {
		self.width*self.xScale*simpleShape[1],	self.height*self.yScale*simpleShape[2],
		self.width*self.xScale*simpleShape[3],	self.height*self.yScale*simpleShape[4],
		self.width*self.xScale*simpleShape[5],	self.height*self.yScale*simpleShape[6],
		self.width*self.xScale*simpleShape[7],	self.height*self.yScale*simpleShape[8],
	}
	--helpers.print_traversal( simpleShape )
	--helpers.print_traversal( trueShape )
	return trueShape;
end
--]]

function sprites:freezeControl()
	self.controller = "ai";
end

function sprites:returnControl()
	self.controller = "player";
end

function sprites:assignControl( controller )
	self.controller = controller;
end

function sprites:updateSequence()

end

--[[ --not really needed, with our gameLoop() implementation
function sprites:preCollision( event )
	print("preCollision with " .. (event.other.name or event.other._type))
	if(event.other._type == "tile") then
		self.linearDamping = 1;
	end
end

function sprites:postCollision( event )
	print("preCollision with " .. (event.other.name or event.other._type))
	if(event.other._type == "tile") then
		self.linearDamping = 0;
	end
end
--]]


return sprites;