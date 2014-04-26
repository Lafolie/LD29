require "classes.Entity"
require "classes.Actor"
require "classes.Drawable"

local img

class "Bubble" (Entity, Actor, Drawable)
{
	__init__ = function(self, x, y, mx, my)
		Entity.__init__(self)
		if not img then
			img = love.graphics.newImage("gfx/particles/P_Bubble.png")
		end
		self.x, self.y = x, y
		self.mx, self.my = mx or 1, my or 1
		self.size = love.math.random()*0.5

		self.lifetime = love.math.random()*2+1
		self.vx, self.vy = love.math.random()*6-1.5, love.math.random()*6
	end,

	update = function(self, dt)
		self.lifetime = self.lifetime - dt
		self.x = self.x + self.mx * self.vx * dt
		self.y = self.y + self.my * self.vy * dt
		self.size = self.size + 0.25 * dt
		self.alpha = self.lifetime < 1 and math.floor(self.lifetime * 255) or 255
	end,

	dead = function(self)
		return self.lifetime <= 0
	end,

	draw = function(self)
		love.graphics.setColor(255, 255, 255, self.alpha)
		love.graphics.draw(img, self.x, self.y, 0, self.size)
	end,
}
