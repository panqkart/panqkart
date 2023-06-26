
-- used as callback from already exported mods
function modgen.register_import_mod(manifest, modpath)

	if manifest.version ~= modgen.version then
		-- hard-fail if the versions don't match
		error("modgen and modgen_export versions don't match, try up- or downgrading the modgen mod")
	end

	-- copy manifest data
	modgen.manifest = manifest

	if modgen.enable_inplace_save then
		-- set export target to import-mod directly if the files are accessible
		modgen.export_path = modpath
	end
end
