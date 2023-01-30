local import_mod = ...

function import_mod.uid_check(manifest)
	local world_uid = import_mod.storage:get_string("uid")
	if world_uid ~= "" and world_uid ~= manifest.uid then
	-- abort if the uids don't match, something fishy might be going on
	error("modgen uids don't match, aborting for your safety!")
	end

	-- write modgen uid to world-storage
	import_mod.storage:set_string("uid", manifest.uid)
end