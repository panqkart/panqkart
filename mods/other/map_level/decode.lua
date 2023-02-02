local import_mod = ...

function import_mod.decode_uint16(str, ofs)
	ofs = ofs or 0
	local a, b = string.byte(str, ofs + 1, ofs + 2)
	return a + b * 0x100
end

local function lshift(x, by)
	return x * 2 ^ by
end

function import_mod.decode_uint32(data, offset)
	return (
		string.byte(data,1+offset) +
		lshift(string.byte(data,2+offset), 8) +
		lshift(string.byte(data,3+offset), 16) +
		lshift(string.byte(data,4+offset), 24)
	)
end