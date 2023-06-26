local pos1 = { x=0, y=0, z=0 }
local pos2 = { x=30, y=30, z=30 }

local function do_emerge(callback)
  minetest.emerge_area(pos1, pos2, function(blockpos, _, calls_remaining)
    minetest.log("action", "Emerged blockpos: " .. minetest.pos_to_string(blockpos))
    if calls_remaining == 0 then
      callback()
    end
  end)
end

local function do_export(callback)
  modgen.export("", pos1, pos2, true, false, function(data)
    minetest.log("action", "Exported " .. data.bytes .. " bytes of data")
    callback()
  end)
end

local function do_exit_success()
  -- just exit gracefully
  minetest.request_shutdown("success")
end

minetest.after(0.5, function()
  -- commence pyramid of doom
  do_emerge(function()
    do_export(function()
      do_exit_success()
    end)
  end)
end)
