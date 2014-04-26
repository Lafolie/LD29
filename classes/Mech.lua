require "classes.Entity"
require "classes.Drawable"
require "classes.Actor"
require "classes.Living"
require "classes.Shader"

local vector = require "lib.hump.vector"
local registry = require "registry"

local function drawBbox(shape)
	local x1, y1, x2, y2 = shape:bbox()
	return love.graphics.rectangle("fill", x1, y1, x2-x1, y2-y1)
end

local keymap =
{
	[1] =
	{
		up = "w",
		down = "s",
		left = "a",
		right = "d",
		punch = " "
	},
	[2] =
	{
		up = "up",
		down = "down",
		left = "left",
		right = "right",
		punch = " "
	},
}

class "Mech" (Entity, Drawable, Actor, Living)
{
	__init__ = function(self, x, y, player)
		Entity.__init__(self)
		self.player = player
		self.pos = vector(x, y)
		self.gravity = 0

		self.imageTemplate = love.graphics.newImage("gfx/S_TempMech.png")
		self.shader = Shader("mechPaint.glsl")
		self.shader.uniforms.mask = love.graphics.newImage("gfx/M_TempMech.png")
		self.shader.uniforms.user_color = {1, 0, 1}

		self.imageOffset = -vector(self.imageTemplate:getDimensions())/2

		self.bodyOffset = vector(-3, -5)
		self.armOffset = vector(8, 0)
		self.fistOffset = vector(12, 0)

		self.body = self.pos + self.bodyOffset
		self.arm = self.pos + self.armOffset
		self.fist = self.pos + self.fistOffset

		self.body = HCShapes.newRectangleShape(self.body.x, self.body.y, 20, 19)
		self.arm = HCShapes.newRectangleShape(self.arm.x, self.arm.y, 6, 7)
		self.fist = HCShapes.newRectangleShape(self.fist.x, self.fist.y, 6, 7)
		
		self.damagingShapes = {}
		self.damagingShapes[self.fist] = { damage = 100, stuns = false, singleHit = true }

		registry.shapes.register(self, self.body)
		registry.shapes.register(self, self.arm)
		registry.shapes.register(self, self.fist)
	end,

	update = function(self, dt)
		local movement = vector(0, 0)
		if self.pos.y < 460 then
			-- gravitay
			self.gravity = self.gravity + 3 * dt
			movement.y = self.gravity
		else
			self.gravity = 0
		end

		if love.keyboard.isDown(keymap[self.player].up) then
			movement.y = movement.y - 50
			self.gravity = 0
		end
		if love.keyboard.isDown(keymap[self.player].down) then
			movement.y = movement.y + 50
		end
		if love.keyboard.isDown(keymap[self.player].left) then
			movement.x = movement.x - 50
		end
		if love.keyboard.isDown(keymap[self.player].right) then
			movement.x = movement.x + 50
		end
		if love.keyboard.isDown(keymap[self.player].punch) then
			self.damagingShapes[self.rightFist] = { damage = 100, stuns = false, singleHit = true }
		end

		if movement.x ~= 0 or movement.y ~= 0 then
			self.pos = self.pos + movement*dt

			if self.pos.y > 460 then self.pos.y = 460 end

			self.body:moveTo((self.pos + self.bodyOffset):unpack())
			self.arm:moveTo((self.pos + self.armOffset):unpack())
			self.fist:moveTo((self.pos + self.fistOffset):unpack())
		end
	end,

	collideWith = function(self, shape, other, dx, dy)
		if self.damagingShapes[shape] and class.isinstance(other, Living) then
			other:damage(self.damagingShapes[shape].damage)
			if self.damagingShapes[shape] then
				self.damagingShapes[shape] = false
			end
			
		end
	end,

	draw = function(self)
		love.graphics.setColor(255, 255, 255)
		self.shader:apply()
		love.graphics.draw(self.imageTemplate, (self.pos + self.imageOffset):unpack())
		self.shader:unapply()

		love.graphics.setColor(255, 255, 255, 50)
		drawBbox(self.body)
		drawBbox(self.arm)
		drawBbox(self.fist)
	end,
}
