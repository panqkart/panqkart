---------
-- manifest read/write functions

-- copy environment to local scope
local env = ...

--- Writes the manifest to a file in json format
-- @param filename the filename to write to
function modgen.write_manifest(manifest, filename)
	-- migrate before exporting
	manifest.uid = manifest.uid or "" .. math.random(1000*1000)

	-- set mtime
	manifest.mtime = os.time()

	local file = env.io.open(filename,"wb")
	local json = minetest.write_json(manifest, true)

	file:write(json)
	file:close()
end

--- Reads a minfest from a json file
-- @param filename the filename of the manifest
function modgen.read_manifest(filename)
	local infile = io.open(filename, "rb")
	if not infile then
		-- no manifest file found
		return
	end

	local instr = infile:read("*a")
	infile:close()

	if instr then
		-- use existing manifest
		modgen.manifest = minetest.parse_json(instr)
	end
end
