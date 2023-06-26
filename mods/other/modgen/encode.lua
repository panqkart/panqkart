-- https://gist.github.com/mebens/938502
local function rshift(x, by)
	return math.floor(x / 2 ^ by)
end

-- https://stackoverflow.com/a/32387452
local function bitand(a, b)
	local result = 0
	local bitval = 1
	while a > 0 and b > 0 do
	  if a % 2 == 1 and b % 2 == 1 then -- test the rightmost bits
		  result = result + bitval      -- set the current bit
	  end
	  bitval = bitval * 2 -- shift left
	  a = math.floor(a/2) -- shift right
	  b = math.floor(b/2)
	end
	return result
end

function modgen.encode_uint16(int)
	local a, b = int % 0x100, int / 0x100
	return string.char(a, b)
end

function modgen.encode_uint32(v)
	local b1 = bitand(v, 0xFF)
	local b2 = bitand( rshift(v, 8), 0xFF )
	local b3 = bitand( rshift(v, 16), 0xFF )
	local b4 = bitand( rshift(v, 24), 0xFF )
	return string.char(b1, b2, b3, b4)
end
