-- License: WTFPL


rules = {}

local S = minetest.get_translator(minetest.get_current_modname())

local items = {
	S("Welcome to the official PanqKart server!"),
	S("We're glad you're here. In this server, we have some rules:"),
	"",
	S("1. No swearing and dating. We do not allow any kind of bad") .. "\n" .. S("words or stuff like pretending to be 'best friends'."),
	"", S("2. No using hacked or modified clients.") .. "\n" .. S("Use the only and official Minetest client."),
	"",  S("3. Be respectful with everyone. Do not be rude."),
	S("4. Do not spam or use full-CAPS."),
	"", S("5. Avoid controversial topics, such as religion, politics, and") .. "\n" .. S("traditions. This includes topics such as the Ukraine war or COVID-19."),
	"",  S("6. Do not share your password with anyone on the server. If we find someone doing") .. "\n" .. S("this, they might pontentially lose their account for security reasons."),
	"",  S("7. Preferably, do not leave while in a race. If") .. "\n" .. S("you need to leave urgently, feel free to do so."),
	"", S("8. Do not impersonate any member of our community. Doing so will result in an") .. "\n" .. S("immediate ban from both the Discord and the Minetest servers."),
	"", S("9. Do not bully or make fun of anyone."),
	S("10. Have common sense. This is a kid/family-friendly community."),
	"", S("11. Report or ping a staff if someone's breaking the rules.") .. "\n" .. S("Our staff are always there to check the chat if all is OK."),
	S("12. Staff always have the final decision."),
	"",
	S("Not following these rules will result in a kick,") .. "\n" .. S("ban, or a permanent ban, depending on the situation."),
	"", S("Anything that makes you feel uncomfortable, any changes you want to be made,") .. "\n" .. S("bugs, etc., just report it to us, and we will help you ASAP."),
	"",
	"",
	S("This game was developed by David Leal (Panquesito7), Crystal741,") .. "\n" .. S("Pixel852, among other Minetest contributors/developers."),
	"", S("Thanks to everyone else who has") .. "\n" .. S("contributed to this game! It's very appreciated."),
	"",
	S("These rules might change in the future, without any later notice or") .. "\n" .. S("announcement. We suggest you stay up-to-date with the rules being changed."),
	"", S("Big changes in the rules will be announced in our") .. "\n" .. S("Discord server. Stay tuned for any new updates."),
	"",
	"",
	S("Like our game? Donate so we can keep the doing more for") .."\n" .. S("you and this game!") .. "\n" .. S("https://en.liberapay.com/Panquesito7"),
	"",
	S("Join our Discord community to stay tuned about new updates, chat with our community,") .. "\n" .. S("share your maps, races, and so much more: https://discord.gg/HEweZuF3Vv"), -- PENDING DISCORD LINK
}

for i = 1, #items do
	items[i] = minetest.formspec_escape(items[i])
end
rules.txt = table.concat(items, ",")

if minetest.global_exists("sfinv") then
	sfinv.register_page("rules:rules", {
		title = S("Rules"),
		get = function(self, player, context)
			return sfinv.make_formspec(player, context,
				"label[0,0;" .. S("Hey! If you're looking to see the server rules,") .. "\n" .. S("please use /rules in the chat. Thank you!") .. "]", false)
		end
	})
end

local function can_grant_interact(player)
	local pname = player:get_player_name()
	return not minetest.check_player_privs(pname, { interact = true }) and
			not minetest.check_player_privs(pname, { fly = true })
end

local function has_password(pname)
	local handler = minetest.get_auth_handler()
	local auth = handler.get_auth(pname)
	return auth and not minetest.check_password_entry(pname, auth.password, "")
end

function rules.show(player)
	local pname = player:get_player_name()
	local fs = "size[8,8.6]bgcolor[#080808BB;true]" ..
			"textlist[0.1,0.1;7.8,7.9;msg;" .. rules.txt .. ";-1;true]"

	if not has_password(pname) then
		fs = fs .. "box[4,8.1;3.1,0.7;#900]"
		fs = fs .. "label[4.2,8.2;" .. S("Please set a password") .. "]"
		fs = fs .. "button_exit[0.5,7.6;3.5,2;ok;" .. S("Okay") .. "]"
	elseif not can_grant_interact(player) then
		fs = fs .. "button_exit[0.5,7.6;7,2;ok;" .. S("Okay") .. "]"
	else
		local yes = minetest.formspec_escape(S("Yes, let me play!"))
		local no = minetest.formspec_escape(S("No, get me out of here!"))

		fs = fs .. "button_exit[0.5,7.6;3.5,2;no;" .. no .. "]"
		fs = fs .. "button_exit[4,7.6;3.5,2;yes;" .. yes .. "]"
	end

	minetest.show_formspec(pname, "rules:rules", fs)
end

function rules.show_pwd(pname, msg)
	msg = msg or S("You must set a password to be able to play")

	minetest.show_formspec(pname, "rules:pwd",  [[
			size[8,3]
			no_prepends[]
			bgcolor[#600]
			pwdfield[0.8,1.5;7,1;pwd;" .. S("Password") .. "]"
			button[0.5,2;7,2;setpwd;" .. S("Set") .. "]"
			label[0.2,0.2;]] .. minetest.formspec_escape(msg) .. "]")

			--]]
end

minetest.register_chatcommand("rules", {
	func = function(pname, param)
		if param ~= "" and
				minetest.check_player_privs(pname, { kick = true }) then
			pname = param
		end

		local player = minetest.get_player_by_name(pname)
		if player then
			rules.show(player)
			return true, S("Rules shown.")
		else
			return false, S("Player @1 does not exist or is not online", pname)
		end
	end
})

minetest.register_on_newplayer(function(player)
	local pname = player:get_player_name()

	local privs = minetest.get_player_privs(pname)
	if privs.interact and privs.fly then
		privs.interact = false
		minetest.set_player_privs(pname, privs)
	end

	if not has_password(pname) then
		privs.shout = false
		privs.interact = false
		privs.kick = false
		privs.ban = false
		minetest.set_player_privs(pname, privs)
		rules.show_pwd(pname)
	elseif can_grant_interact(player) then
		rules.show(player)
	end
end)

minetest.register_on_player_receive_fields(function(player, form, fields)
	if form == "rules:pwd" then
		local pname = player:get_player_name()
		if fields.setpwd then
			local handler = minetest.get_auth_handler()
			if not fields.pwd or fields.pwd:trim() == "" then
				rules.show_pwd(pname)
			elseif #fields.pwd < 5 then
				rules.show_pwd(pname, S("Needs at least 5 characters"))
			else
				handler.set_password(pname,
						minetest.get_password_hash(pname, fields.pwd))
				rules.show(player)
			end
		else
			minetest.kick_player(pname,
				S("You need to set a password to play on this server."))
		end

		return true
	end

	if form ~= "rules:rules" then
		return
	end

	local pname = player:get_player_name()
	if not can_grant_interact(player) or not has_password(pname) then
		return true
	end

	if fields.msg then
		return true
	elseif not fields.yes or fields.no then
		minetest.kick_player(pname,
			S("You need to agree to the rules to play on this server.\nPlease rejoin and confirm another time."))
		return true
	end

	local privs = minetest.get_player_privs(pname)
	privs.shout = true
	privs.interact = true
	minetest.set_player_privs(pname, privs)

	minetest.chat_send_player(pname, S("Welcome, @1! You have now permission to play!", pname))

	return true
end)
