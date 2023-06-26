--[[
	## StreetsMod 2.0 ##
	Submod: roadmarkings
	Optional: true
	Category: Roads
]]

--These register the sections in the workshop that these will be placed into
streets.labels.sections = {
	{ name = "centerlines", friendlyname = "Center Lines" },
	{ name = "centerlinecorners", friendlyname = "Center Line Corners/Junctions" },
	{ name = "sidelines", friendlyname = "Side Lines" },
	{ name = "arrows", friendlyname = "Arrows" },
	{ name = "symbols", friendlyname = "Symbols" },
	{ name = "other", friendlyname = "Other" }
}


-- CENTER LINES

-- Normal Lines

streets.register_road_marking({
	name = "dashed_{color}_center_line",
	friendlyname = "Dashed Center Line",
	tex = "streets_dashed_center_line.png",
	section = "centerlines",
	dye_needed = 1,
	rotation = { r90 = 1 },
	basic = true,
})

streets.register_road_marking({
	name = "solid_{color}_center_line",
	friendlyname = "Solid Center Line",
	tex = "streets_solid_center_line.png",
	section = "centerlines",
	dye_needed = 2,
	rotation = { r90 = 1 },
	basic = true,
})


-- Wide Lines

streets.register_road_marking({
	name = "dashed_{color}_center_line_wide",
	friendlyname = "Dashed Center Line Wide",
	tex = "streets_dashed_center_line_wide.png",
	section = "centerlines",
	dye_needed = 2,
	rotation = { r90 = 1 },
})

streets.register_road_marking({
	name = "solid_{color}_center_line_wide",
	friendlyname = "Solid Center Line Wide",
	tex = "streets_solid_center_line_wide.png",
	section = "centerlines",
	dye_needed = 4,
	rotation = { r90 = 1 },
})


-- Double Lines

streets.register_road_marking({
	name = "double_dashed_{color}_center_line",
	friendlyname = "Double Dashed Center Line",
	tex = "streets_double_dashed_center_line.png",
	section = "centerlines",
	dye_needed = 2,
	rotation = { r90 = 1 },
})

streets.register_road_marking({
	name = "double_solid_{color}_center_line",
	friendlyname = "Double Solid Center Line",
	tex = "streets_double_solid_center_line.png",
	section = "centerlines",
	dye_needed = 4,
	rotation = { r90 = 1 },
	basic = true,
})

streets.register_road_marking({
	name = "mixed_{color}_center_line",
	friendlyname = "Solid/Dashed Center Line",
	tex = "streets_mixed_center_line.png",
	section = "centerlines",
	dye_needed = 3,
	rotation = { r90 = 1, r180 = 1, r270 = 1 },
})

streets.register_road_marking({
	name = "solid_{color}_line_offset",
	friendlyname = "Solid Line Offset",
	tex = "streets_solid_line_offset.png",
	section = "centerlines",
	dye_needed = 2,
	rotation = { r90 = 1, r180 = 1, r270 = 1 },
})


--CENTER LINE CORNERS

--Normal Lines

streets.register_road_marking({
	name = "solid_{color}_center_line_corner",
	friendlyname = "Solid Center Line Corner",
	tex = "streets_solid_center_line_corner.png",
	section = "centerlinecorners",
	dye_needed = 2,
	rotation = { r90 = 1, r180 = 1, r270 = 1 },
})

streets.register_road_marking({
	name = "solid_{color}_center_line_tjunction",
	friendlyname = "Solid Center Line T-Junction",
	tex = "streets_solid_center_line_tjunction.png",
	section = "centerlinecorners",
	dye_needed = 3,
	rotation = { r90 = 1, r180 = 1, r270 = 1 },
})

streets.register_road_marking({
	name = "solid_{color}_center_line_crossing",
	friendlyname = "Solid Center Line Crossing",
	tex = "streets_solid_center_line_crossing.png",
	section = "centerlinecorners",
	dye_needed = 4,
})


--Wide Lines

streets.register_road_marking({
	name = "solid_{color}_center_line_wide_corner",
	friendlyname = "Solid Center Line Wide Corner",
	tex = "streets_solid_center_line_wide_corner.png",
	section = "centerlinecorners",
	dye_needed = 4,
	rotation = { r90 = 1, r180 = 1, r270 = 1 },
})

streets.register_road_marking({
	name = "solid_{color}_center_line_wide_tjunction",
	friendlyname = "Solid Center Line Wide T-Junction",
	tex = "streets_solid_center_line_wide_tjunction.png",
	section = "centerlinecorners",
	dye_needed = 6,
	rotation = { r90 = 1, r180 = 1, r270 = 1 },
})

streets.register_road_marking({
	name = "solid_{color}_center_line_wide_crossing",
	friendlyname = "Solid Center Line Wide Crossing",
	tex = "streets_solid_center_line_wide_crossing.png",
	section = "centerlinecorners",
	dye_needed = 8,
})


--Double Lines

streets.register_road_marking({
	name = "double_solid_{color}_center_line_corner",
	friendlyname = "Double Solid Center Line Corner",
	tex = "streets_double_solid_center_line_corner.png",
	section = "centerlinecorners",
	dye_needed = 4,
	rotation = { r90 = 1, r180 = 1, r270 = 1 },
})

streets.register_road_marking({
	name = "double_solid_{color}_center_line_tjunction",
	friendlyname = "Double Solid Center Line T-Junction",
	tex = "streets_double_solid_center_line_tjunction.png",
	section = "centerlinecorners",
	dye_needed = 6,
	rotation = { r90 = 1, r180 = 1, r270 = 1 },
})

streets.register_road_marking({
	name = "double_solid_{color}_center_line_crossing",
	friendlyname = "Double Solid Center Line Crossing",
	tex = "streets_double_solid_center_line_crossing.png",
	section = "centerlinecorners",
	dye_needed = 8,
})

--SIDE LINES

--Normal Lines

streets.register_road_marking({
	name = "solid_{color}_side_line",
	friendlyname = "Solid Side Line",
	tex = "streets_solid_side_line.png",
	section = "sidelines",
	dye_needed = 2,
	rotation = { r90 = 1, r180 = 1, r270 = 1 },
	basic = true,
	basic_rotation = { r180 = 1 },
})

streets.register_road_marking({
	name = "solid_{color}_side_line_corner",
	friendlyname = "Solid Side Line Corner",
	tex = "streets_solid_side_line_corner.png",
	section = "sidelines",
	dye_needed = 4,
	rotation = { r90 = 1, r180 = 1, r270 = 1 },
})

streets.register_road_marking({
	name = "dashed_{color}_side_line",
	friendlyname = "Dashed Side Line",
	tex = "streets_dashed_side_line.png",
	section = "sidelines",
	dye_needed = 1,
	rotation = { r90 = 1, r180 = 1, r270 = 1 },
})


--Wide Lines

streets.register_road_marking({
	name = "solid_{color}_side_line_wide",
	friendlyname = "Solid Side Line Wide",
	tex = "streets_solid_side_line_wide.png",
	section = "sidelines",
	dye_needed = 4,
	rotation = { r90 = 1, r180 = 1, r270 = 1 },
	basic = true,
	basic_rotation = { r180 = 1 },
})

streets.register_road_marking({
	name = "solid_{color}_side_line_wide_corner",
	friendlyname = "Solid Side Line Wide Corner",
	tex = "streets_solid_side_line_wide_corner.png",
	section = "sidelines",
	dye_needed = 8,
	rotation = { r90 = 1, r180 = 1, r270 = 1 },
})

streets.register_road_marking({
	name = "dashed_{color}_side_line_wide",
	friendlyname = "Dashed Side Line Wide",
	tex = "streets_dashed_side_line_wide.png",
	section = "sidelines",
	dye_needed = 2,
	rotation = { r90 = 1, r180 = 1, r270 = 1 },
})


--Special

streets.register_road_marking({
	name = "solid_{color}_side_line_combinated_corner",
	friendlyname = "Solid Side Line Combinated Corner",
	tex = "streets_solid_side_line_combinated_corner.png",
	section = "sidelines",
	dye_needed = 6,
	rotation = { r90 = 1, r180 = 1, r270 = 1 },
})

streets.register_road_marking({
	name = "solid_{color}_side_line_combinated_corner_flipped",
	friendlyname = "Solid Side Line Combinated Corner (Flipped)",
	tex = "streets_solid_side_line_combinated_corner.png^[transformFX",
	section = "sidelines",
	dye_needed = 6,
	rotation = { r90 = 1, r180 = 1, r270 = 1 },
})



--ARROWS

streets.register_road_marking({
	name = "{color}_arrow_straight",
	friendlyname = "Arrow Straight",
	tex = "streets_arrow_straight.png",
	section = "arrows",
	dye_needed = 2,
	rotation = { r90 = 1, r180 = 1, r270 = 1 },
})

streets.register_road_marking({
	name = "{color}_arrow_left",
	friendlyname = "Arrow Left",
	tex = "streets_arrow_right.png^[transformFX",
	section = "arrows",
	dye_needed = 2,
	rotation = { r90 = 1, r180 = 1, r270 = 1 },
})

streets.register_road_marking({
	name = "{color}_arrow_right",
	friendlyname = "Arrow Right",
	tex = "streets_arrow_right.png",
	section = "arrows",
	dye_needed = 2,
	rotation = { r90 = 1, r180 = 1, r270 = 1 },
})

streets.register_road_marking({
	name = "{color}_arrow_left_straight",
	friendlyname = "Arrow Left And Straight",
	tex = "streets_arrow_right_straight.png^[transformFX",
	section = "arrows",
	dye_needed = 2,
	rotation = { r90 = 1, r180 = 1, r270 = 1 },
})

streets.register_road_marking({
	name = "{color}_arrow_right_straight",
	friendlyname = "Arrow Right And Straight",
	tex = "streets_arrow_right_straight.png",
	section = "arrows",
	dye_needed = 2,
	rotation = { r90 = 1, r180 = 1, r270 = 1 },
})

streets.register_road_marking({
	name = "{color}_arrow_left_right_straight",
	friendlyname = "Arrow Left, Right And Straight",
	tex = "streets_arrow_right_straight.png^[transformFX^streets_arrow_right_straight.png",
	section = "arrows",
	dye_needed = 2,
	rotation = { r90 = 1, r180 = 1, r270 = 1 },
})

streets.register_road_marking({
	name = "{color}_arrow_left_right",
	friendlyname = "Arrow Left And Right",
	tex = "streets_arrow_left_right.png",
	section = "arrows",
	dye_needed = 2,
	rotation = { r90 = 1, r180 = 1, r270 = 1 },
})


--SYMBOLS

streets.register_road_marking({
	name = "{color}_parking",
	friendlyname = "Parking",
	tex = "streets_parking.png",
	section = "symbols",
	dye_needed = 3,
	rotation = { r90 = 1, r180 = 1, r270 = 1 },
})

streets.register_road_marking({
	name = "{color}_cross",
	friendlyname = "Cross",
	tex = "streets_cross.png",
	section = "symbols",
	dye_needed = 4,
})

--OTHER

streets.register_road_marking({
	name = "solid_{color}_stripe",
	friendlyname = "Solid Stripe",
	tex = "streets_solid_stripe.png",
	section = "other",
	dye_needed = 4,
	rotation = { r90 = 1 },
})

streets.register_road_marking({
	name = "solid_{color}_diagonal_line",
	friendlyname = "Solid Diagonal Line",
	tex = "streets_solid_diagonal_line.png",
	section = "other",
	dye_needed = 2,
	rotation = { r90 = 1 },
})

streets.register_road_marking({
	name = "double_solid_{color}_diagonal_line",
	friendlyname = "Double Solid White Diagonal Line",
	tex = "streets_double_solid_diagonal_line.png",
	section = "other",
	dye_needed = 4,
	rotation = { r90 = 1 },
})

streets.register_road_marking({
	name = "{color}_halt_line_center_corner",
	friendlyname = "Halt Line Center Corner",
	tex = "streets_halt_line_center_corner.png",
	section = "other",
	dye_needed = 4,
	rotation = { r90 = 1, r180 = 1, r270 = 1 },
})

streets.register_road_marking({
	name = "{color}_halt_line_center_corner_wide",
	friendlyname = "Halt Line Center Corner Wide",
	tex = "streets_halt_line_center_corner_wide.png",
	section = "other",
	dye_needed = 6,
	rotation = { r90 = 1, r180 = 1, r270 = 1 },
})

streets.register_road_marking({
	name = "{color}_halt_line_center_corner_flipped",
	friendlyname = "Halt Line Center Corner (Flipped)",
	tex = "streets_halt_line_center_corner.png^[transformFX",
	section = "other",
	dye_needed = 4,
	rotation = { r90 = 1, r180 = 1, r270 = 1 },
})

streets.register_road_marking({
	name = "{color}_halt_line_center_corner_wide_flipped",
	friendlyname = "Halt Line Center Corner Wide (Flipped)",
	tex = "streets_halt_line_center_corner_wide.png^[transformFX",
	section = "other",
	dye_needed = 6,
	rotation = { r90 = 1, r180 = 1, r270 = 1 },
})
