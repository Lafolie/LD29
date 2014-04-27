class "Timer"
{
	__init__ = function(self, type, duration, callback)
		self.timer = 0
		self.type = type
		self.duration = duration
		self.callback = callback
		self.valid = true
	end,

	update = function(self, dt)
		if not self.valid then return end

		self.timer = self.timer + dt
		if self.timer >= self.duration then
			self.callback()

			if self.type == "periodic" then
				self.timer = 0
			elseif self.type == "once" then
				self.valid = false
			end
		end
	end,

	reset = function(self)
		self.timer = 0
		self.valid = true
	end,
}
