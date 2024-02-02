--
-- Formspec elements list. Do not update this by hand, it is auto-generated
-- by make_elements.py.
--

local a = {}
a[1] = {"w", "number"}
a[2] = {"h", "number"}
a[3] = {a[1], a[2]}
a[4] = {{"x", "number"}, {"y", "number"}}
a[5] = {{a[4]}}
a[6] = {}
a[7] = {a[6]}
a[8] = {"scrollbar_name", "string"}
a[9] = {"orientation", "string"}
a[10] = {"inventory_location", "string"}
a[11] = {"list_name", "string"}
a[12] = {"slot_bg_normal", "string"}
a[13] = {"slot_bg_hover", "string"}
a[14] = {"slot_border", "string"}
a[15] = {"tooltip_text", "string"}
a[16] = {"bgcolor", "string"}
a[17] = {"fontcolor", "string"}
a[18] = {"gui_element_name", "string"}
a[19] = {"texture_name", "string"}
a[20] = {"middle_x", "number"}
a[21] = {"middle_y", "number"}
a[22] = {a[20], a[21], {"middle_x2", "number"}, {"middle_y2", "number"}}
a[23] = {a[20], a[21]}
a[24] = {a[20]}
a[25] = {a[4], a[3], a[19]}
a[26] = {"name", "string"}
a[27] = {"frame_count", "number"}
a[28] = {"frame_duration", "number"}
a[29] = {"frame_start", "number"}
a[30] = {"mesh", "string"}
a[31] = {{{"textures", "string"}, "..."}}
a[32] = {{"rotation_x", "number"}, {"rotation_y", "number"}}
a[33] = {"continuous", "boolean"}
a[34] = {"mouse_control", "boolean"}
a[35] = {{"frame_loop_begin", "number"}, {"frame_loop_end", "number"}}
a[36] = {"item_name", "string"}
a[37] = {"fullscreen", "fullscreen"}
a[38] = {"auto_clip", "boolean"}
a[39] = {"label", "string"}
a[40] = {{a[4], a[3], a[26], a[39]}}
a[41] = {"default", "string"}
a[42] = {a[4], a[3], a[26], a[39], a[41]}
a[43] = {{a[4], a[39]}}
a[44] = {"noclip", "boolean"}
a[45] = {"drawborder", "boolean"}
a[46] = {{a[4], a[3], a[19], a[26], a[39], a[44], a[45], {"pressed_texture_name", "string"}}, {a[4], a[3], a[19], a[26], a[39], a[44], a[45]}, {a[4], a[3], a[19], a[26], a[39]}}
a[47] = {{{"listelems", "string"}, "..."}}
a[48] = {"selected_idx", "number"}
a[49] = {"transparent", "boolean"}
a[50] = {{{"captions", "string"}, "..."}}
a[51] = {"current_tab", "number"}
a[52] = {"draw_border", "boolean"}
a[53] = {{{"items", "string"}, "..."}}
a[54] = {"index_event", "boolean"}
a[55] = {"value", "number"}
a[56] = {{"opts", "table"}, "..."}
a[57] = {{a[56]}}
a[58] = {{"props", "table"}, "..."}
a[59] = {a[26]}
a[60] = {{{{{"selectors", "string"}, "..."}}, a[58]}, {a[59], a[58]}}
return {["formspec_version"] = {{{"version", "number"}}}, ["size"] = {{a[3]}, {{a[1], a[2], {"fixed_size", "boolean"}}}}, ["position"] = a[5], ["anchor"] = a[5], ["padding"] = a[5], ["no_prepend"] = a[7], ["real_coordinates"] = {{{"bool", "boolean"}}}, ["container"] = a[5], ["container_end"] = a[7], ["scroll_container"] = {{a[4], a[3], a[8], a[9], {"scroll_factor", "number"}}, {a[4], a[3], a[8], a[9]}}, ["scroll_container_end"] = a[7], ["list"] = {{a[10], a[11], a[4], a[3], {"starting_item_index", "number"}}, {a[10], a[11], a[4], a[3]}}, ["listring"] = {{a[10], a[11]}, a[6]}, ["listcolors"] = {{a[12], a[13], a[14], {"tooltip_bgcolor", "string"}, {"tooltip_fontcolor", "string"}}, {a[12], a[13], a[14]}, {a[12], a[13]}}, ["tooltip"] = {{a[4], a[3], a[15], a[16], a[17]}, {a[4], a[3], a[15], a[16]}, {a[18], a[15], a[16], a[17]}, {a[4], a[3], a[15]}, {a[18], a[15], a[16]}, {a[18], a[15]}}, ["image"] = {{a[4], a[3], a[19], a[22]}, {a[4], a[3], a[19], a[23]}, {a[4], a[3], a[19], a[24]}, a[25]}, ["animated_image"] = {{a[4], a[3], a[26], a[19], a[27], a[28], a[29], a[22]}, {a[4], a[3], a[26], a[19], a[27], a[28], a[29], a[23]}, {a[4], a[3], a[26], a[19], a[27], a[28], a[29], a[24]}, {a[4], a[3], a[26], a[19], a[27], a[28], a[29]}, {a[4], a[3], a[26], a[19], a[27], a[28]}}, ["model"] = {{a[4], a[3], a[26], a[30], a[31], a[32], a[33], a[34], a[35], {"animation_speed", "number"}}, {a[4], a[3], a[26], a[30], a[31], a[32], a[33], a[34], a[35]}, {a[4], a[3], a[26], a[30], a[31], a[32], a[33], a[34]}, {a[4], a[3], a[26], a[30], a[31], a[32], a[33]}, {a[4], a[3], a[26], a[30], a[31], a[32]}, {a[4], a[3], a[26], a[30], a[31]}}, ["item_image"] = {{a[4], a[3], a[36]}}, ["bgcolor"] = {{a[16], a[37], {"fbgcolor", "string"}}, {a[16], a[37]}, {a[16]}}, ["background"] = {{a[4], a[3], a[19], a[38]}, a[25]}, ["background9"] = {{a[4], a[3], a[19], a[38], a[22]}, {a[4], a[3], a[19], a[38], a[23]}, {a[4], a[3], a[19], a[38], a[24]}}, ["pwdfield"] = a[40], ["field"] = {a[42], {a[26], a[39], a[41]}}, ["field_enter_after_edit"] = {{a[26], {"enter_after_edit", "boolean"}}}, ["field_close_on_enter"] = {{a[26], {"close_on_enter", "boolean"}}}, ["textarea"] = {a[42]}, ["label"] = a[43], ["hypertext"] = {{a[4], a[3], a[26], {"text", "string"}}}, ["vertlabel"] = a[43], ["button"] = a[40], ["image_button"] = a[46], ["item_image_button"] = {{a[4], a[3], a[36], a[26], a[39]}}, ["button_exit"] = a[40], ["image_button_exit"] = a[46], ["textlist"] = {{a[4], a[3], a[26], a[47], a[48], a[49]}, {a[4], a[3], a[26], a[47], a[48]}, {a[4], a[3], a[26], a[47]}}, ["tabheader"] = {{a[4], a[2], a[26], a[50], a[51], a[49], a[52]}, {a[4], a[3], a[26], a[50], a[51], a[49], a[52]}, {a[4], a[26], a[50], a[51], a[49], a[52]}, {a[4], a[26], a[50], a[51]}}, ["box"] = {{a[4], a[3], {"color", "string"}}}, ["dropdown"] = {{a[4], a[3], a[26], a[53], a[48], a[54]}, {a[4], a[1], a[26], a[53], a[48], a[54]}, {a[4], a[3], a[26], a[53], a[48]}, {a[4], a[1], a[26], a[53], a[48]}}, ["checkbox"] = {{a[4], a[26], a[39], {"selected", "boolean"}}, {a[4], a[26], a[39]}}, ["scrollbar"] = {{a[4], a[3], a[9], a[26], a[55], {{"scrollbar_bg", "string"}, {"slider", "string"}, {"arrow_up", "string"}, {"arrow_down", "string"}}}, {a[4], a[3], a[9], a[26], a[55]}}, ["scrollbaroptions"] = a[57], ["table"] = {{a[4], a[3], a[26], {{{"cells", "string"}, "..."}}, a[48]}}, ["tableoptions"] = a[57], ["tablecolumns"] = {{{{{"type", "string"}, a[56]}, "..."}}}, ["style"] = a[60], ["style_type"] = a[60], ["set_focus"] = {{a[26], {"force", "boolean"}}, a[59]}}
