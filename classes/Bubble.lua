require "classes.Entity"
require "classes.Actor"
require "classes.Drawable"

local img = love.graphics.newImage("gfx/particles/P_Bubble.png")

class "Bubble" (Entity, Actor, Drawable)
{
	__init__ = function(self, x, y, mx, my)
		Entity.__init__(self)
		self.x, self.y = x, y
		self.mx, self.my = mx or 1, my or 1

		self.lifetime = love.math.random()*2+1
		self.vx, self.vy = love.math.random()*3-1.5, love.math.random()*5
	end,

	update = function(self, dt)
		self.lifetime = self.lifetime - dt
		self.x = self.x + self.mx * self.vx * dt
		self.y = self.y + self.my * self.vy * dt
	end,

	dead = function(self)
		return self.lifetime <= 0
	end,

	draw = function(self)
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(img, self.x, self.y, 0, 0.5)
	end,
}
