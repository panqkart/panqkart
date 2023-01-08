minetest.get_modpath('pkinfo')

about = [[
Anything that makes you feel uncomfortable, any changes you want to be made, bugs, etc., just report it to us, and we will help you ASAP.
This game was developed by David Leal (Panquesito7), Crystal741, Pixel852, among other Minetest contributors/developers.

Thanks to everyone else who has contributed to this game! It's very appreciated.
These rules might change in the future, without any later notice or announcement. We suggest you stay up-to-date with the rules being changed.
Big changes in the rules will be announced in our Discord server. Stay tuned for any new updates.

Like our game? Donate so we can keep the doing more for you and this game! https://en.liberapay.com/Panquesito7

Join our Discord community to stay tuned about new updates, chat with our community, share your maps, races, and so much more.
Discord: https://discord.gg/HEweZuF3Vv
]]

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "pkinfo:rules" then

        if fields.about then
            name = player:get_player_name()
            minetest.show_formspec(name, "pkinfo:about",
                "size[16,6.3]" ..
                "label[0,0;"..minetest.colorize("#02a2f7", "About").."]"..
                "background[0,0;16,0.6;pk_dark_bg.png]"..
                "label[0,0.8;"..about.."]"..
                "background[0,0.8;16,5;pk_background.png]"..
                "image_button_exit[7,5.9;2,0.7;pk_dark_bg.png;close;"..minetest.colorize("#02a2f7", "Close").."]"
            )

        end

    end
end)

