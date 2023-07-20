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
			1000,
			120
		},
		position = {
			0,
			210,
			1
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
			-150,
			210
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
			17, -- Redeem Title position
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

	vote_icon_a = {
		vertical_alignment = "center",
		parent = "result_bar_fg",
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
  text_redeemed_by = {
		vertical_alignment = "bottom",
		parent = "vote_icon_a",
		horizontal_alignment = "left",
		size = {
			240,
			24
		},
		position = {
			-200,
			-5, -- User text position up/down
			10
		}
	},
  sv_twitch_icon_small = {
		vertical_alignment = "center",
		parent = "vote_icon_a",
		horizontal_alignment = "center",
		size = {
			29,
			29
		},
		position = {
			-250,
			-15,
			10
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
			-60,
			-5, -- User text position up/down
			10
		}
	},
}

local timer_text_style = {
	font_size = 40,
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

local vote_text_left_style = table.clone(vote_text_style)
vote_text_left_style.horizontal_alignment = "left"
vote_text_left_style.font_size = 20
--vote_text_left_style.text_color = { 255, 0, 255, 255 }


local streaming_icon = "twitch_icon_small"

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
			vote_text_a = UIWidgets.create_simple_text("vote_text_a_default_text", "vote_text_rect_a", nil, nil, vote_text_left_style),
			text_redeemed_by = UIWidgets.create_simple_text("vote_text_a_default_text", "text_redeemed_by", nil, nil, vote_text_left_style),
			twitch_icon_small = UIWidgets.create_simple_texture(streaming_icon, "sv_twitch_icon_small")
		}
	}
}
