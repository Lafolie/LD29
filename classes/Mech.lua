require "classes.Entity"
require "classes.Drawable"
require "classes.Actor"
require "classes.Living"

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
	},
	[2] =
	{
		up = "up",
		down = "down",
		left = "left",
		right = "right",
	},
}

class "Mech" (Entity, Drawable, Actor, Living)
{
	__init__ = function(self, x, y, player)
		Entity.__init__(self)
		self.player = player
		self.x, self.y = x, y

		self.body = HCShapes.newRectangleShape(self.x-30, self.y-75,
			60, 150)
		self.rightArm = HCShapes.newRectangleShape(self.x+30, self.y-10,
			60, 15)
		self.leftLeg = HCShapes.newRectangleShape(self.x-20, self.y+75,
			15, 60)
		self.rightLeg = HCShapes.newRectangleShape(self.x+5, self.y+75,
			15, 60)

		registry.shapes.register(self, self.body)
		registry.shapes.register(self, self.rightArm)
		registry.shapes.register(self, self.leftLeg)
		registry.shapes.register(self, self.rightArm)
	end,

	update = function(self, dt)
		if love.keyboard.isDown(keymap[self.player].up) then
			self.y = self.y - 50 * dt
		end
	end,

	collideWith = function(self, shape, other, dx, dy)
		if shape == self.fist and class.isinstance(other, Living) then
			other:damage(9001)
		end
	end,

	draw = function(self)
		love.graphics.setColor(255, 255, 255)
		drawBbox(self.body)
		drawBbox(self.rightArm)
		drawBbox(self.leftLeg)
		drawBbox(self.rightLeg)

		love.graphics.setColor(255, 0, 0)
		love.graphics.point(self.x, self.y)
	end,
}
