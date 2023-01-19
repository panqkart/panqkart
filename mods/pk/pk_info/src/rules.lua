local S = pk_info.S
local _rules = "" -- luacheck: ignore

local rules = {
    S("1. No swearing and dating. We do not allow any kind of bad") .. " " .. S("words or stuff like pretending to be 'best friends'."),
    S("2. No using hacked or modified clients.") .. " " .. S("Use the only official Minetest client."),
    S("3. Be respectful to everyone. Do not be rude."),
    S("4. Do not spam or use full-CAPS."),
    S("5. Avoid controversial topics, such as religion, politics, and") .. " " .. S("traditions. This includes topics such as the Ukraine war or COVID-19."),
    S("6. Do not share your password with anyone on the server. If we find someone doing") .. " " .. S("this, they might potentially lose their account for security reasons."),
    S("7. Preferably, do not leave while in a race. If") .. " " .. S("you need to leave urgently, feel free to do so."),
    S("8. Do not impersonate any member of our community. Doing so will result in an") .. " " .. S("immediate ban from both the Discord and the Minetest servers."),
    S("9. Do not bully or make fun of anyone."),
    S("10. Have common sense. This is a kid/family-friendly community."),
    S("11. Report or ping a staff if someone's breaking the rules.") .. " " .. S("Our staff are always there to check the chat if all is OK."),
    S("12. Staff always have the final decision.")
}

for i = 1, #rules do
	rules[i] = minetest.formspec_escape(rules[i])
end
_rules = table.concat(rules, "\n")

--- @brief Shows the rules formspec.
--- @param name userdata the player that will receive the formspec
--- @return string formspec the rules formspec
local function rules_formspec(name)
    local formspec = {
        "size[16,6.3]" ..
        "label[0,0;" .. minetest.colorize("#02a2f7", S("Server Rules")) .. " | " .. S("Not following these rules will result in a kick, ban, or permanent ban, depending on the situation.") .. "]"..
        "background[0,0;16,0.6;pk_info_dark_bg.png]"..
        "label[0,0.8;".. _rules .."]"..
        "background[0,0.8;16,5;pk_info_background.png]"..
        "image_button_exit[6,5.9;2,0.7;pk_info_dark_bg.png;done;" .. minetest.colorize("#FF0000", S("Close")) .. "]"..
        "image_button[8,5.9;2,0.7;pk_info_dark_bg.png;about;" .. minetest.colorize("#02a2f7", S("About")) .."]"
    }

    return table.concat(formspec, "")
end

minetest.register_chatcommand("rules", {
	description = S("Full server rules."),
	privs = { interact = true },
	func = function(name)
        minetest.show_formspec(name, "pk_info:rules", rules_formspec(name))
    end
})

minetest.register_on_joinplayer(function(player)
	minetest.show_formspec(player:get_player_name(), "pk_info:rules", rules_formspec(player))
end)
