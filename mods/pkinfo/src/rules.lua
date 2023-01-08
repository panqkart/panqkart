minetest.get_modpath('pkinfo')

rules = [[
1. No swearing and dating. We do not allow any kind of bad words or stuff like pretending to be 'best friends'.
2. No using hacked or modified clients. Use the only and official Minetest client.
3. Be respectful with everyone. Do not be rude.
4. Do not spam or use full-CAPS.
5. Avoid controversial topics, such as religion, politics, and traditions. This includes topics such as the Ukraine war or COVID-19.
6. Do not share your password with anyone on the server. If we find someone doing this, they might pontentially lose their account for security reasons.
7. Preferably, do not leave while in a race. If you need to leave urgently, feel free to do so.
8. Do not impersonate any member of our community. Doing so will result in an immediate ban from both the Discord and the Minetest servers.
9. Do not bully or make fun of anyone.
10. Have common sense. This is a kid/family-friendly community.
11. Report or ping a staff if someone's breaking the rules. Our staff are always there to check the chat if all is OK.
12. Staff always have the final decision.
]]



minetest.register_chatcommand("rules", {
	description = "Rules Command",
	privs = {
        interact=true
    },
	func = function(name)
        minetest.show_formspec(name, "pkinfo:rules",
        "size[16,6.3]" ..
        "label[0,0;"..minetest.colorize("#02a2f7", "Server Rules").." | Not following this rules will result in a kick, ban, or a permanent ban, depending on the situation.]"..
        "background[0,0;16,0.6;pk_dark_bg.png]"..
        "label[0,0.8;"..rules.."]"..
        "background[0,0.8;16,5;pk_background.png]"..
        "image_button_exit[6,5.9;2,0.7;pk_dark_bg.png;done;"..minetest.colorize("#FF0000", "Close").."]"..
        "image_button[8,5.9;2,0.7;pk_dark_bg.png;about;"..minetest.colorize("#02a2f7", "About us").."]"
    )
	end
})


minetest.register_on_joinplayer(function(player)
	minetest.show_formspec(player:get_player_name(), "pkinfo:rules",
        "size[16,6.3]" ..
        "label[0,0;"..minetest.colorize("#02a2f7", "Server Rules").." | Not following this rules will result in a kick, ban, or a permanent ban, depending on the situation.]"..
        "background[0,0;16,0.6;pk_dark_bg.png]"..
        "label[0,0.8;"..rules.."]"..
        "background[0,0.8;16,5;pk_background.png]"..
        "image_button_exit[6,5.9;2,0.7;pk_dark_bg.png;done;"..minetest.colorize("#FF0000", "Close").."]"..
        "image_button[8,5.9;2,0.7;pk_dark_bg.png;about;"..minetest.colorize("#02a2f7", "About us").."]"
    )
end)