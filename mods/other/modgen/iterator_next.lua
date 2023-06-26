
function modgen.iterator_next(pos1, pos2, pos)
	if not pos then
		pos = {x = pos1.x, y = pos1.y, z = pos1.z}
	else
		pos.x = pos.x + 1
		if pos.x > pos2.x then
			pos.x = pos1.x
			pos.z = pos.z + 1
			if pos.z > pos2.z then
				pos.z = pos1.z
				pos.y = pos.y + 1
				if pos.y > pos2.y then
					pos = nil
				end
			end
		end
	end
	return pos
end
