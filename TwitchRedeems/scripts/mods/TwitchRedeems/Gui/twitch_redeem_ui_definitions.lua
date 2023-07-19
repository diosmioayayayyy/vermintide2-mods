local mod = get_mod("TwitchRedeems")

local scenegraph_definition = {
	root = {
		is_root = true,
		size = {
			1920,
			1080
		},
		position = {
			0,
			0,
			UILayer.popup + 1
		}
	},
	screen = {
		scale = "fit",
		size = {
			1920,
			1080
		},
		position = {
			0,
			0,
			UILayer.popup + 1
		}
	},
	base_area = {
		vertical_alignment = "bottom",
		parent = "screen",
		horizontal_alignment = "center",
		size = {
			800,
			128
		},
		position = {
			0,
			210,
			1
		}
	},
	vote_icon_rect = {
		vertical_alignment = "top",
		parent = "base_area",
		horizontal_alignment = "center",
		size = {
			56,
			56
		},
		position = {
			0,
			41,
			10
		}
	},
	vote_icon = {
		vertical_alignment = "center",
		parent = "vote_icon_rect",
		horizontal_alignment = "center",
		size = {
			56,
			56
		},
		position = {
			0,
			0,
			-1
		}
	},
	vote_text_rect = {
		vertical_alignment = "center",
		parent = "base_area",
		horizontal_alignment = "center",
		size = {
			260,
			42
		},
		position = {
			0,
			30,
			10
		}
	},
	timer_rect = {
		vertical_alignment = "center",
		parent = "base_area",
		horizontal_alignment = "center",
		size = {
			48,
			32
		},
		position = {
			0,
			-50,
			10
		}
	},
	portrait_a = {
		vertical_alignment = "center",
		parent = "base_area",
		horizontal_alignment = "center",
		size = {
			96,
			72
		},
		position = {
			-240,
			52,
			10
		}
	},
	portrait_b = {
		vertical_alignment = "center",
		parent = "base_area",
		horizontal_alignment = "center",
		size = {
			96,
			72
		},
		position = {
			-144,
			52,
			10
		}
	},
	portrait_c = {
		vertical_alignment = "center",
		parent = "base_area",
		horizontal_alignment = "center",
		size = {
			96,
			72
		},
		position = {
			240,
			52,
			10
		}
	},
	portrait_d = {
		vertical_alignment = "center",
		parent = "base_area",
		horizontal_alignment = "center",
		size = {
			96,
			72
		},
		position = {
			336,
			52,
			10
		}
	},
	vote_input_a = {
		vertical_alignment = "bottom",
		parent = "portrait_a",
		horizontal_alignment = "left",
		size = {
			48,
			32
		},
		position = {
			-24,
			-67,
			20
		}
	},
	vote_input_b = {
		vertical_alignment = "bottom",
		parent = "portrait_b",
		horizontal_alignment = "left",
		size = {
			48,
			32
		},
		position = {
			-24,
			-67,
			20
		}
	},
	vote_input_c = {
		vertical_alignment = "bottom",
		parent = "portrait_c",
		horizontal_alignment = "left",
		size = {
			48,
			32
		},
		position = {
			-24,
			-67,
			20
		}
	},
	vote_input_d = {
		vertical_alignment = "bottom",
		parent = "portrait_d",
		horizontal_alignment = "left",
		size = {
			48,
			32
		},
		position = {
			-24,
			-67,
			20
		}
	},
	mc_divider = {
		vertical_alignment = "center",
		parent = "base_area",
		horizontal_alignment = "center",
		size = {
			160,
			25
		},
		position = {
			0,
			0,
			1
		}
	},
	mc_twitch_icon_small = {
		vertical_alignment = "center",
		parent = "mc_divider",
		horizontal_alignment = "center",
		size = {
			27,
			27
		},
		position = {
			0,
			0,
			1
		}
	},
	result_area = {
		vertical_alignment = "bottom",
		parent = "screen",
		horizontal_alignment = "center",
		size = {
			650,
			100
		},
		position = {
			0,
			285,
			0
		}
	},
	mcr_divider = {
		vertical_alignment = "center",
		parent = "result_area",
		horizontal_alignment = "center",
		size = {
			211,
			25
		},
		position = {
			0,
			0,
			1
		}
	},
	mcr_twitch_icon_small = {
		vertical_alignment = "center",
		parent = "mcr_divider",
		horizontal_alignment = "center",
		size = {
			27,
			27
		},
		position = {
			0,
			2,
			1
		}
	},
	result_icon_rect = {
		vertical_alignment = "top",
		parent = "result_area",
		horizontal_alignment = "center",
		size = {
			56,
			56
		},
		position = {
			0,
			48,
			10
		}
	},
	result_icon = {
		vertical_alignment = "center",
		parent = "result_icon_rect",
		horizontal_alignment = "center",
		size = {
			48,
			48
		},
		position = {
			0,
			0,
			-1
		}
	},
	winner_portrait = {
		vertical_alignment = "center",
		parent = "result_area",
		horizontal_alignment = "center",
		size = {
			96,
			72
		},
		position = {
			48,
			-52,
			1
		}
	},
	result_text = {
		vertical_alignment = "center",
		parent = "result_area",
		horizontal_alignment = "center",
		size = {
			800,
			36
		},
		position = {
			0,
			28,
			1
		}
	},
	result_description_text = {
		vertical_alignment = "center",
		parent = "result_area",
		horizontal_alignment = "center",
		size = {
			800,
			36
		},
		position = {
			0,
			-64,
			1
		}
	},
	winner_name = {
		vertical_alignment = "center",
		parent = "result_area",
		horizontal_alignment = "center",
		size = {
			640,
			24
		},
		position = {
			0,
			-28,
			1
		}
	},
	sv_timer_rect = {
		vertical_alignment = "center",
		parent = "base_area",
		horizontal_alignment = "center",
		size = {
			48,
			32
		},
		position = {
			0,
			37,
			10
		}
	},
	result_bar_fg = {
		vertical_alignment = "center",
		parent = "base_area",
		horizontal_alignment = "center",
		size = {
			459,
			36
		},
		position = {
			0,
			-0,
			7
		}
	},
	result_bar_fg2 = {
		vertical_alignment = "center",
		parent = "base_area",
		horizontal_alignment = "center",
		size = {
			463,
			38
		},
		position = {
			0,
			-2,
			8
		}
	},
	result_bar_mid = {
		vertical_alignment = "bottom",
		parent = "result_bar_fg",
		horizontal_alignment = "center",
		size = {
			0,
			0
		},
		position = {
			-1,
			0,
			0
		}
	},
	result_bar_glass = {
		vertical_alignment = "top",
		parent = "result_bar_fg",
		horizontal_alignment = "center",
		size = {
			394,
			4
		},
		position = {
			0,
			-6,
			-1
		}
	},
	result_bar_bg = {
		vertical_alignment = "center",
		parent = "result_bar_fg",
		horizontal_alignment = "center",
		size = {
			394,
			36
		},
		position = {
			0,
			-0,
			-6
		}
	},
	sv_twitch_icon_small = {
		vertical_alignment = "center",
		parent = "result_bar_mid",
		horizontal_alignment = "center",
		size = {
			29,
			29
		},
		position = {
			1,
			16,
			10
		}
	},
	result_a_bar = {
		vertical_alignment = "bottom",
		parent = "result_bar_mid",
		horizontal_alignment = "right",
		size = {
			197,
			36
		},
		position = {
			0,
			0,
			-2
		}
	},
	result_a_bar_edge = {
		vertical_alignment = "center",
		parent = "result_a_bar",
		horizontal_alignment = "left",
		size = {
			36,
			36
		},
		position = {
			-36,
			0,
			-1
		}
	},
	result_bar_a_eyes = {
		vertical_alignment = "center",
		parent = "result_bar_fg",
		horizontal_alignment = "left",
		size = {
			75,
			20
		},
		position = {
			-22,
			-3,
			8
		}
	},
	result_b_bar = {
		vertical_alignment = "bottom",
		parent = "result_bar_mid",
		horizontal_alignment = "left",
		size = {
			197,
			36
		},
		position = {
			0,
			-0,
			-2
		}
	},
	result_b_bar_edge = {
		vertical_alignment = "center",
		parent = "result_b_bar",
		horizontal_alignment = "right",
		size = {
			36,
			36
		},
		position = {
			36,
			-0,
			-1
		}
	},
	result_bar_b_eyes = {
		vertical_alignment = "center",
		parent = "result_bar_fg",
		horizontal_alignment = "right",
		size = {
			75,
			20
		},
		position = {
			22,
			-3,
			8
		}
	},
	vote_icon_a = {
		vertical_alignment = "center",
		parent = "result_bar_fg",
		horizontal_alignment = "left",
		size = {
			48,
			48
		},
		position = {
			-60,
			0,
			-1
		}
	},
	vote_icon_rect_a = {
		vertical_alignment = "center",
		parent = "vote_icon_a",
		horizontal_alignment = "center",
		size = {
			56,
			56
		},
		position = {
			0,
			0,
			4
		}
	},
	vote_text_rect_a = {
		vertical_alignment = "bottom",
		parent = "vote_icon_a",
		horizontal_alignment = "left",
		size = {
			240,
			24
		},
		position = {
			0,
			-30,
			10
		}
	},
	vote_input_text_a = {
		vertical_alignment = "center",
		parent = "base_area",
		horizontal_alignment = "center",
		size = {
			60,
			30
		},
		position = {
			-207,
			32,
			10
		}
	},
	vote_icon_b = {
		vertical_alignment = "center",
		parent = "result_bar_fg",
		horizontal_alignment = "right",
		size = {
			48,
			48
		},
		position = {
			60,
			0,
			-1
		}
	},
	vote_icon_rect_b = {
		vertical_alignment = "center",
		parent = "vote_icon_b",
		horizontal_alignment = "center",
		size = {
			56,
			56
		},
		position = {
			0,
			0,
			4
		}
	},
	vote_text_rect_b = {
		vertical_alignment = "bottom",
		parent = "vote_icon_b",
		horizontal_alignment = "right",
		size = {
			240,
			24
		},
		position = {
			0,
			-30,
			10
		}
	},
	vote_input_text_b = {
		vertical_alignment = "center",
		parent = "base_area",
		horizontal_alignment = "center",
		size = {
			60,
			30
		},
		position = {
			207,
			32,
			10
		}
	},
	sv_result_area = {
		vertical_alignment = "bottom",
		parent = "screen",
		horizontal_alignment = "center",
		size = {
			650,
			135
		},
		position = {
			0,
			180,
			0
		}
	},
	sv_divider = {
		vertical_alignment = "center",
		parent = "sv_result_area",
		horizontal_alignment = "center",
		size = {
			211,
			26
		},
		position = {
			0,
			0,
			1
		}
	},
	svr_twitch_icon_small = {
		vertical_alignment = "center",
		parent = "sv_divider",
		horizontal_alignment = "center",
		size = {
			27,
			27
		},
		position = {
			0,
			2,
			1
		}
	},
	sv_result_icon_rect = {
		vertical_alignment = "top",
		parent = "sv_result_area",
		horizontal_alignment = "center",
		size = {
			56,
			56
		},
		position = {
			0,
			26,
			10
		}
	},
	sv_result_icon = {
		vertical_alignment = "center",
		parent = "sv_result_icon_rect",
		horizontal_alignment = "center",
		size = {
			48,
			48
		},
		position = {
			0,
			0,
			-1
		}
	},
	sv_result_text = {
		vertical_alignment = "center",
		parent = "sv_result_area",
		horizontal_alignment = "center",
		size = {
			640,
			24
		},
		position = {
			0,
			-32,
			1
		}
	}
}


local timer_text_style = {
	font_size = 60,
	upper_case = true,
	localize = false,
	use_shadow = true,
	horizontal_alignment = "center",
	vertical_alignment = "center",
	font_type = "hell_shark",
	text_color = Colors.get_color_table_with_alpha("white", 255),
	offset = {
		0,
		0,
		2
	}
}
local hero_vote_text_style = {
	font_size = 26,
	upper_case = true,
	localize = false,
	use_shadow = true,
	horizontal_alignment = "center",
	vertical_alignment = "center",
	font_type = "hell_shark",
	text_color = Colors.get_color_table_with_alpha("cheeseburger", 255),
	offset = {
		-2,
		0,
		2
	}
}
local vote_text_style = {
	font_size = 8,
	upper_case = true,
	localize = false,
	use_shadow = true,
	horizontal_alignment = "center",
	vertical_alignment = "center",
	dynamic_font_size = true,
	font_type = "hell_shark",
	text_color = Colors.get_color_table_with_alpha("white", 255),
	offset = {
		-2,
		0,
		2
	}
}
local result_text_style = table.clone(vote_text_style)
result_text_style.font_size = 24
result_text_style.text_color = Colors.get_color_table_with_alpha("twitch", 255)
local result_text_description_style = table.clone(vote_text_style)
result_text_description_style.font_size = 20
result_text_description_style.text_color = Colors.get_color_table_with_alpha("white", 255)
local winner_text_style = table.clone(vote_text_style)
winner_text_style.localize = false
winner_text_style.font_size = 24
local vote_text_left_style = table.clone(vote_text_style)
vote_text_left_style.horizontal_alignment = "left"
vote_text_left_style.font_size = 20
--vote_text_left_style.text_color = { 255, 0, 255, 255 }
local vote_text_right_style = table.clone(vote_text_style)
vote_text_right_style.horizontal_alignment = "right"
vote_text_right_style.font_size = 24
local portrait_scale = 0.8
local portrait_glow_style = {
	offset = {
		-54 * portrait_scale,
		-64 * portrait_scale,
		0
	},
	texture_size = {
		108 * portrait_scale,
		130 * portrait_scale
	},
	color = {
		255,
		255,
		255,
		255
	}
}

local function create_vertical_window_divider(scenegraph_id, size)
	local widget = {
		element = {
			passes = {
				{
					texture_id = "edge",
					style_id = "edge",
					pass_type = "tiled_texture"
				},
				{
					texture_id = "edge_holder_top",
					style_id = "edge_holder_top",
					pass_type = "texture"
				},
				{
					texture_id = "edge_holder_bottom",
					style_id = "edge_holder_bottom",
					pass_type = "texture"
				}
			}
		},
		content = {
			edge = "menu_frame_09_divider_vertical",
			edge_holder_top = "menu_frame_09_divider_top",
			edge_holder_bottom = "menu_frame_09_divider_bottom"
		},
		style = {
			edge = {
				color = {
					255,
					255,
					255,
					255
				},
				offset = {
					0,
					6,
					6
				},
				size = {
					4,
					size[2] - 7
				},
				texture_tiling_size = {
					4,
					size[2] - 7
				}
			},
			edge_holder_top = {
				color = {
					255,
					255,
					255,
					255
				},
				offset = {
					-6,
					size[2] - 7,
					10
				},
				size = {
					14,
					7
				}
			},
			edge_holder_bottom = {
				color = {
					255,
					255,
					255,
					255
				},
				offset = {
					-6,
					3,
					10
				},
				size = {
					14,
					7
				}
			}
		},
		scenegraph_id = scenegraph_id,
		offset = {
			0,
			-4,
			0
		}
	}

	return widget
end

local VOTE_TEXTS = {
	standard_vote = {
		"#A",
		"#B"
	},
	multiple_choice = {
		"#A",
		"#B",
		"#C",
		"#D",
		"#E"
	}
}
local streaming_icon = "twitch_icon_small"

mod:echo("REBUILD UI TITWHTC REDEEM")

return {
	vote_texts = VOTE_TEXTS,
	scenegraph_definition = scenegraph_definition,
	settings = {
		vote_icon_padding = 10
	},
	widgets = {
		standard_vote = {
			background = UIWidgets.create_simple_texture("tab_menu_bg_02", "base_area"),
			timer = UIWidgets.create_simple_text("timer_default_text", "sv_timer_rect", nil, nil, timer_text_style),
			vote_icon_rect_a = UIWidgets.create_simple_texture("item_frame", "vote_icon_rect_a"),
			vote_icon_a = UIWidgets.create_simple_texture("markus_mercenary_crit_chance", "vote_icon_a"),
			vote_text_a = UIWidgets.create_simple_text("vote_text_a_default_text", "vote_text_rect_a", nil, nil, vote_text_left_style),
			vote_input_text_a = UIWidgets.create_simple_text(VOTE_TEXTS.standard_vote[1], "vote_input_text_a", nil, nil, hero_vote_text_style),
			result_bar_fg = UIWidgets.create_simple_texture("crafting_button_fg", "result_bar_fg"),
			result_bar_glass = UIWidgets.create_simple_texture("button_glass_01", "result_bar_glass"),
			result_bar_bg = UIWidgets.create_simple_rect("result_bar_bg", {
				255,
				0,
				0,
				0
			}),
			result_bar_fg2 = UIWidgets.create_rect_with_frame("result_bar_fg2", scenegraph_definition.result_bar_fg2.size, {
				0,
				0,
				0,
				0
			}, "menu_frame_09"),
			result_bar_divier = create_vertical_window_divider("result_bar_mid", {
				4,
				40
			}),
			result_a_bar_edge = UIWidgets.create_simple_uv_texture("experience_bar_edge_glow", {
				{
					1,
					1
				},
				{
					0,
					0
				}
			}, "result_a_bar_edge"),
			result_a_bar = UIWidgets.create_simple_uv_texture("experience_bar_fill", {
				{
					1,
					1
				},
				{
					0,
					0
				}
			}, "result_a_bar"),
			result_bar_a_eyes = UIWidgets.create_simple_texture("mission_objective_glow_02", "result_bar_a_eyes"),
			twitch_icon_small = UIWidgets.create_simple_texture(streaming_icon, "sv_twitch_icon_small")
		}
	}
}
