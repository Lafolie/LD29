local registry = {}
registry.shapes = {}
registry.entities = {}

local shapes = setmetatable({}, {__mode = "kv"})
local entities = setmetatable({}, {__mode = "v"})

--- SHAPES ---
function registry.shapes.register(entity, shape)
	collider:addShape(shape)
	shapes[shape] = entity
end

function registry.shapes.unregister(shape)
	collider:remove(shape)
	shapes[shape] = nil
end

function registry.shapes.getEntity(shape)
	return shapes[shape]
end

--- ENTITIES ---
function registry.entities.register(entity)
	table.insert(entities, entity)
end

function registry.entities.iterate()
	return ipairs(entities)
end

return registry
