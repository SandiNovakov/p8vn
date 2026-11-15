cursors = {
	{
		speed = 4, width = 4,
		frames = {
			"■",
			"■",
			"■",
			"■",
			"■",
			"■",
			"⁙",
			"•",
			"",
			"",
			"",
			"",
			"",
			"",
			"•",
			"⁙",
		}
	},
	{
		speed = 4, width = 4,
		frames = {
			"▶",
			"▶",
			"▶",
			"▶",
			"▶",
			"▶",
			"+",
			"•",
			"",
			"",
			"",
			"",
			"",
			"",
			"•",
			"+",
		}
	},
	{
		speed = 4, width = 4,
		frames = {
			"▶",
			"▶",
			"▶",
			"▶",
			"▶",
			"▶",
			">",
			"•",
			"",
			"",
			"",
			"",
			"",
			"",
			"•",
			">",
		}
	},
	{
		speed = 4, width = 8,
		frames = {
			"█",
			"█",
			"█",
			"█",
			"█",
			"█",
			"█",
			"▥",
			"…",
			"",
			"",
			"",
			"",
			"",
			"",
			"…",
			"▥",
		}
	}
}

cur = 1
cur_frame = 1
cur_i = 0 -- counted
cursor_show = false
cursor_x = 0
cursor_y = 0

function show_cursor(cur_idx)
	cur_frame = 1
	cur = cur_idx

	cursor_show = true
end

function hide_cursor()
	cursor_show = false
	cur_frame = 1
	cur_i = 1
end
