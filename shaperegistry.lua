local registry = {}

local shapes = setmetatable({}, {__mode = "kv"})

function registry.register(entity, shape)
	shapes[shape] = entity
end

function registry.unregister(shape)
	shapes[shape] = nil
end

function registry.getEntity(shape)
	return shapes[shape]
end

return registry
