
mtt.register("iterator_next", function(callback)
	local pos = nil
	local pos1 = { x=4, y=0, z=0 }
	local pos2 = { x=4, y=0, z=1 }

	pos = modgen.iterator_next(pos1, pos2, pos)
	assert(4 == pos.x)
	assert(0 == pos.y)
	assert(0 == pos.z)

	pos = modgen.iterator_next(pos1, pos2, pos)
	assert(4 == pos.x)
	assert(0 == pos.y)
	assert(1 == pos.z)

	callback()
end)