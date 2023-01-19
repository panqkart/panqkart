local S = pk_info.S
local _about = "" -- luacheck: ignore

local about = {
	S("Anything that makes you feel uncomfortable, any changes you want to be made,") .. " " .. S("bugs, etc., just report it to us, and we will help you ASAP."),
	S("This game was developed by David Leal (Panquesito7), Crystal741,") .. " " .. S("Pixel852, among other Minetest contributors/developers."),
	S("Thanks to everyone else who has") .. " " .. S("contributed to this game! It's very appreciated.") .. "\n",
	S("These rules might change in the future, without any later notice or")  .. " " .. S("announcement. We suggest you stay up-to-date with the rules being changed."),
    S("Big changes in the rules will be announced in our") .. " " .. S("Discord server. Stay tuned for any new updates.") .. "\n",
	S("Like our game? Donate so we can keep doing more for") .. " " .. S("you and this game! https://github.com/sponsors/Panquesito7"),
	S("Join our Discord community to stay tuned about new updates, chat with our community,") .. " " .. S("share your maps, races, and so much more.") .. "\n",
    S("We hope to see you there! https://discord.gg/HEweZuF3Vv")
}

for i = 1, #about do
    about[i] = minetest.formspec_escape(about[i])
end
_about = table.concat(about, "\n")

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "pk_info:rules" then
        if fields.about then
            local name = player:get_player_name()
            minetest.show_formspec(name, "pk_info:about",
                "size[16,6.3]" ..
                "label[0,0;" .. minetest.colorize("#02a2f7", S("About")).."]"..
                "background[0,0;16,0.6;pk_info_dark_bg.png]"..
                "label[0,0.8;" .. _about .. "]"..
                "background[0,0.8;16,5;pk_info_background.png]"..
                "image_button_exit[7,5.9;2,0.7;pk_info_dark_bg.png;close;" .. minetest.colorize("#02a2f7", S("Close")).."]"
            )
        end
    end
end)
