local import_mod = ...

function import_mod.register_mapgen(manifest)
	minetest.register_on_generated(function(minp)
		import_mod.load_chunk(import_mod.get_chunkpos(minp), manifest)
	end)
end
