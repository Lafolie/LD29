require "classes.Entity"
require "classes.Drawable"
require "classes.Actor"

local registry = require "registry"

local function drawBbox(shape)
	local x1, y1, x2, y2 = shape:bbox()
	return love.graphics.rectangle("fill", x1, y1, x2-x1, y2-y1)
end

class "Mech" (Entity, Drawable, Actor)
{
	__init__ = function(self, x, y)
		Entity.__init__(self)
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

	draw = function(self)
		drawBbox(self.body)
		drawBbox(self.rightArm)
		drawBbox(self.leftLeg)
		drawBbox(self.rightLeg)
	end,
}
