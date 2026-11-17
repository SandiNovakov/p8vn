cursors = {
	{
		speed = 4, width = 4,
		frames = {
			"",
			"•",
			"⁙",
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
		}
	},
	{
		speed = 4, width = 4,
		frames = {
			"",
			"•",
			"+",
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
		}
	},
	{
		speed = 4, width = 4,
		frames = {
			"",
			"•",
			">",
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
		}
	},
	{
		speed = 4, width = 8,
		frames = {
			"",
			"…",
			"▥",
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
		}
	}
}

cur = 1
cur_frame = 1
cur_i = 0
cursor_show = false
cursor_x = 0
cursor_y = 0

function show_cursor(cur_idx)
	cur_frame = 1
	cur = cur_idx
	cur_i = 0

	cursor_show = true
end

function update_cursor()
	local c = cursors[cur]

	if not cursor_show then
		return
	end

	cur_i += 1

	if cur_i >= 4 then
		cur_i = 0
		cur_frame = (cur_frame % #c.frames) + 1
	end
end

function draw_cursor(x,y)
	local c = cursors[cur]

	if not cursor_show then
		return
	end

	
	if x > 128-c.width then
		x = 0
		y += 8
	end


	print(c.frames[cur_frame], x, y, 12)
end

function hide_cursor()
	cursor_show = false
	cur_frame = 1
end
