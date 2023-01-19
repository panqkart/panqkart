--[[
RandomMessages mod by arsdragonfly.
CTF version by the MT-CTF team: https://github.com/MT-CTF/capturetheflag/tree/master/mods/other/random_messages
arsdragonfly@gmail.com
6/19/2013
--]]
--Time between two subsequent messages.
local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)

local MESSAGE_INTERVAL = 0

math.randomseed(os.time())

random_messages = {}
random_messages.messages = {} --This table contains all messages.

function random_messages.initialize() --Set the interval in minetest.conf.
	minetest.settings:set("random_messages_interval", 60)
	minetest.settings:write();
	return 60
end

function random_messages.set_interval() -- Read the interval from minetest.conf and set it if it doesn't exist
	MESSAGE_INTERVAL = tonumber(minetest.settings:get("random_messages_interval"))
							or random_messages.initialize()
end

function random_messages.check_params(name,func,params)
	local stat, msg = func(params)
	if not stat then
		minetest.chat_send_player(name,msg)
		return false
	end
	return true
end

-- TODO: add translations.
function random_messages.read_messages()
	random_messages.messages = {
		"PanqKart was released in June 28, 2022, developed by Panquesito7, Crystal741, and Pixel852,\namong other contributors and people. Anyone else is free to contribute and make improvements to the game.",
		"Looking for the source code? Want to contribute? Come check it out at github.com/panqkart/panqkart",
		"You can upgrade your vehicles to make them faster! Check your inventory to upgrade your car. Note that this will result in acceleration and turn speed decrease.",
		"Get in-game bronze, silver, and gold coins by getting in the top 3 places\non a race. This is used to upgrade your car, buy new cars, and more!",
		"Like our game? Don't hesitate to support our work by donating! Donating includes perks such as double coins, early access to new features, VIP house, and prioritized\nfeatures/maps, no matter the amount! Use /donate for more information.",
		"We're still working on adding new features and maps to the game. Stay tuned for new additions to the game.",
		"Our hosting is powered by the awesome service of great community volunteers! Thanks to them, we were able to make this game possible.",
		"There are a few secrets on the map which can give you coins and amazing perks! Try to find them.",
		"Wanna give feedback, report bugs, or chat with us? Feel free to mail us at halfpacho@gmail.com or by joining our Discord server.",
		"Read our rules frequently, show them to other users, or report users who are breaking the rules to us.\nWe might update our rules soon, so stay tuned for any new changes.",
		"Share the game with your friends and give feedback at the ContentDB page! This will help us know what would you like to see in the next releases.",
		"Have any new level idea? Don't hesitate and come discuss this with us at Discord. A new guide for creating maps will be added very soon.",
		"Don't go onto the grass! It will slow down your speed by half, depending on your vehicle's speed.",
		"We have a Discord community. There you can talk with your friends regarding the game,\nmake suggestions, report bugs, and directly to the server users from Discord. Join today: https://discord.gg/HEweZuF3Vv",
		"Get ready to compete against the A.I. bots, either locally and with other players! Stay tuned: they'll be added soon."
	}
end

function random_messages.display_message(message_number)
	local msg = random_messages.messages[message_number] or message_number
	if msg then
		for _,player in ipairs(minetest.get_connected_players()) do
			minetest.chat_send_player(player:get_player_name(), minetest.colorize("#808080", msg))
		end
	end
end

function random_messages.show_message()
	local message = random_messages.messages[math.random(1, #random_messages.messages)]
	random_messages.display_message(message)
end

function random_messages.list_messages()
	local str = ""
	for k,v in pairs(random_messages.messages) do
		str = str .. k .. " | " .. v .. "\n"
	end
	return str
end

function random_messages.remove_message(k)
	table.remove(random_messages.messages,k)
	random_messages.save_messages()
end

function random_messages.add_message(t)
	table.insert(random_messages.messages,table.concat(t," ",2))
	random_messages.save_messages()
end

function random_messages.save_messages()
	local output = io.open(minetest.get_worldpath().."/random_messages","w")
	for k,v in pairs(random_messages.messages) do
		output:write(v .. "\n")
	end
	io.close(output)
end

--When server starts:
random_messages.set_interval()
random_messages.read_messages()

local function step(dtime)
	random_messages.show_message()
	minetest.after(MESSAGE_INTERVAL, step)
end
minetest.after(MESSAGE_INTERVAL, step)

local register_chatcommand_table = {
	params = "viewmessages | removemessage <number> | addmessage <number>",
	privs = {server = true},
	description = S("View and/or alter the server's random messages"),
	func = function(name,param)
		local t = string.split(param, " ")
		if t[1] == "viewmessages" then
			minetest.chat_send_player(name,random_messages.list_messages())
		elseif t[1] == "removemessage" then
			if not random_messages.check_params(
			name,
			function (params)
				if not tonumber(params[2]) or
				random_messages.messages[tonumber(params[2])] == nil then
					return false, S("ERROR: No such message.")
				end
				return true
			end,
			t) then return end
			random_messages.remove_message(t[2])
		elseif t[1] == "addmessage" then
			if not t[2] then
				minetest.chat_send_player(name, S("ERROR: No message."))
			else
				random_messages.add_message(t)
			end
		else
				minetest.chat_send_player(name, S("ERROR: Invalid command."))
		end
	end
}

minetest.register_chatcommand("random_messages", register_chatcommand_table)
minetest.register_chatcommand("rmessages", register_chatcommand_table)
