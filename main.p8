pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
#include lowercase.p8
#include script.p8
#include cursor.p8

mode_slow = false
mode_fast = false
mode_input = false
mode_delay = false
mode_dialog = false
mode_skip = false
mode_full_skip = false -- full skip when holding right.

acc_amt_default = 1.0 

screen_buffer = {""}
swap_buffer = {""}

dialog_color = 'd'
ui_color = 5

page_idx = 1
line_idx = 1
-- Current Y = (line_idx - 1) * 8
char_idx = 1

state = "printing" -- input, delay, page.

write_buffer = "" -- the contents of this get appended to screen_buffer every frame.

acc = 0

lines = {0,8,16,24,32,40,48,56,64,72,80,88,96,104,112,120} -- use as a helper for positioning debug elements etc.

debug = false

delay = 0
delay_amt = 60 -- frames

history = {{""}}
history_idx = 1
return_state = "idle"

g_state = "main" -- main, title, save, load.

function get_acc_amt()
	if mode_slow then
		return acc_amt_default * 2.0
	elseif mode_fast then
		return acc_amt_default * 0.5
	else
		return acc_amt_default * 1.0
	end
end

function gs_main_update()
	update_cursor()

	if btn(1) then
		mode_full_skip = true
	else
		mode_full_skip = false
	end

	if btnp(0) then
		debug = not debug
	end

	if state == "printing" then
		local acc_amt = get_acc_amt() -- we keep this here in case it changes due to mode. Only apply that on the next pass.
		local page = script[page_idx]
		local lin = page[line_idx]

		if btnp(5) and not mode_skip and not mode_full_skip then
			mode_skip = true
			acc = 0
		end

		if not mode_skip and not mode_full_skip then
			acc += 1
		end

		local stopped_at_input = false

		while state == "printing" and char_idx <= #lin+1 and (acc >= acc_amt or mode_skip == true or mode_full_skip == true) do
			local done = false

			while done != true do

				-- skip tabs.
				if sub(lin,char_idx,char_idx+3) == "    " then
					write_buffer = write_buffer .. "    "
					char_idx += 4
				end

				local char = sub(lin,char_idx,char_idx)
				if char == "\\" then
					write_buffer = write_buffer .. "\\"
				elseif char == "@" then
					mode_skip = false

					if not mode_full_skip then
						state = "input"
						show_cursor(1)
					end

					done = true
				elseif char == "#" then
					mode_slow = not mode_slow
				elseif char == "$" then
					mode_fast = not mode_fast
				elseif char == "^" then
					if not mode_full_skip then
						state = "delay"
					end
					done = true
				elseif char == "\"" then
					if mode_dialog == false then
						write_buffer = write_buffer .. "\f" .. dialog_color .. "\""
						mode_dialog = true
						done = true
					else
						write_buffer = write_buffer .. "\"\f7"
						mode_dialog = false
						done = true
					end
				else
					write_buffer = write_buffer .. char
					done = true
				end

				char_idx += 1

			end

			if not mode_skip and not mode_full_skip then
				acc -= acc_amt
			end
		end

		if char_idx > #lin+1 and state == "printing" then
			char_idx = 1

			-- flush write buffer right now if there is anything left unwritten.
			screen_buffer[line_idx] = screen_buffer[line_idx] .. write_buffer
			write_buffer = ""

			line_idx += 1
			screen_buffer[line_idx] = screen_buffer[line_idx] or ""

			-- handle edge case where dialog doesn't close on the same line.
			if mode_dialog == true then
				write_buffer = write_buffer .. "\f" .. dialog_color
			end
		end

		if line_idx > #page then
			if page_idx >= #script then
				state = "done"
			else
				state = "input-page"
				show_cursor(2)
			end
		end
	
		screen_buffer[line_idx] = screen_buffer[line_idx] .. write_buffer
		write_buffer = ""

	elseif state == "input" then
		if btnp(4) then
			g_state = "save"
			show_cursor(2)
		end

		if btnp(2) then
			swap_buffer = screen_buffer
			return_state = "input"

			screen_buffer = history[history_idx]
			state = "history"
			hide_cursor()
		end

		if btnp(5) or mode_full_skip == true then
			state = "printing"
			hide_cursor()
		end

	elseif state == "input-page" then
		if btnp(4) then
			g_state = "save"
			show_cursor(2)
		end
		if btnp(2) then
			swap_buffer = screen_buffer
			return_state = "input-page"

			screen_buffer = history[history_idx]
			state = "history"
			hide_cursor()
		end

		if btnp(5) or mode_full_skip then
			line_idx = 1
			page_idx += 1

			history[history_idx] = screen_buffer
			history_idx += 1

			screen_buffer = {""}

			state = "printing"
			hide_cursor()
		end

	elseif state == "delay" then
		delay += 1
		if delay >= delay_amt then
			state = "printing"
			delay = 0
		end

	elseif state == "history" then
		if btnp(2) and (history_idx-1 > 0 and #history == 1 or history_idx-1 > 1) then
			history_idx -= 1
			screen_buffer = history[history_idx]
		end

		if btnp(3) then
			if history_idx+1 > #history then
				screen_buffer = swap_buffer

				-- we might need enter state instead
				if return_state == "input" then
					show_cursor(1) 
				elseif return_state == "input-page" then
					show_cursor(2)
				end

				state = return_state


				history_idx = #history+1
			else
				history_idx += 1
				screen_buffer = history[history_idx]
			end
		end
	end
end

function get_save_files()
	saves = {
	{
		dd = "16",
		mm = "03",
		yy = "26",
		hh = "13",
		mi = "42",
		ss = "24",
		page = 4,
		lin = 4,
		ch = "01",
		preview = "\\sample save file texts, 32 chars"
	},
	{
		dd = "21",
		mm = "07",
		yy = "26",
		hh = "18",
		mi = "07",
		ss = "53",
		page = 27,
		lin = 6,
		ch = "03",
		preview = "\\sample save file texts, 32 chars"
	},
	{
		dd = "04",
		mm = "10",
		yy = "26",
		hh = "22",
		mi = "31",
		ss = "09",
		page = 8,
		lin = 2,
		ch = "07",
		preview = "\\sample save file texts, 32 chars"
	},
	{
		dd = "17",
		mm = "11",
		yy = "26",
		hh = "23",
		mi = "16",
		ss = "42",
		page = 34,
		lin = 8,
		ch = "12",
		preview = "\\sample save file texts, 32 chars"
	}
}
	
	return saves;
end

selection = 1

function gs_save_update()
	-- temporary
	if not cursor_show then
		show_cursor(2)
	end

	local saves = get_save_files()

	if btnp(4) then
		selection = 1
		g_state = "main"
		if state == "printing" then
			hide_cursor()
		end
	end

	if btnp(5) then
		local save = saves[selection]
		print_buffer = ""
		screen_buffer = {""} 
		page_idx = save.page
		line_idx = save.lin

		for i=1,line_idx-1 do
			screen_buffer[i] = script[page_idx][i]
		end

		screen_buffer[line_idx] = ""

		if line_idx == #script[page_idx] then
			state = "input-page"
			show_cursor(2)
		else
			state = "input"
			show_cursor(1)
		end

		g_state = "main"
	end

	if btnp(3) then
		selection = (selection % #saves) + 1
		show_cursor(2)
	end

	if btnp(2) then
		selection = (selection - 2) % #saves + 1
		show_cursor(2)
	end

	--[[
	if btnp(3) then
		selection = min(selection + 1, #saves)
		show_cursor(2)
	end

	if btnp(2) then
		selection = max(1, selection - 1)
		show_cursor(2)
	end
	]]--

	update_cursor()
end

function gs_save_draw()
	cls()

	print("save to file...",0,lines[1], 13)

	local saves = get_save_files()
	local y = 3

	for i=1,#saves do
		local save = saves[i]
		if i == selection then
			draw_cursor(0, lines[y])
			print("file " .. i .. ": " .. save.dd .. "-" .. save.mm .. "-" .. save.yy .. " " .. save.hh .. ":" .. save.mi .. ":" .. save.ss .. " ch:" .. save.ch, 4, lines[y], 12)
			cprintline(save.preview, 0, lines[y+1], 12)
		else
			print("file " .. i .. ": " .. save.dd .. "-" .. save.mm .. "-" .. save.yy .. " " .. save.hh .. ":" .. save.mi .. ":" .. save.ss  .. " ch:" .. save.ch, 4, lines[y], ui_color)
			cprintline(save.preview, 0, lines[y+1], 7)
		end

		y += 3
	end

	print("❎ save, 🅾️ back", 0, lines[16], 13)
end

function _update60()
	if g_state == "main" then
		gs_main_update()
	elseif g_state == "save" then
		gs_save_update()
	end
end


function gs_main_draw()
	cls()
	local x = 0
	local y = 0

	for i=1,#screen_buffer do
		y = (i-1)*8
		x = cprintline(screen_buffer[i],0,y)
	end

	draw_cursor(x,y)

	if debug == true then
		local write_speed = "normal"
		if mode_full_skip == true then
			write_speed = "skip"
		elseif mode_slow == true then
			write_speed = "slow"
		elseif mode_fast == true then
			write_speed = "fast"
		end

		if state=="input" or state=="printing" or state=="input-page" then
			local cur_line = script[page_idx][line_idx]
			local cur_len = cur_line and #cur_line or 0
			cprintline("page " .. page_idx .. " / " .. #script,0, lines[12], ui_color)
			cprintline("line " .. line_idx .. " / " .. #script[page_idx],0, lines[13], ui_color)
			cprintline("char " .. char_idx .. " / " .. cur_len,0, lines[14], ui_color)
			cprintline("speed: " .. write_speed, 0, lines[15], ui_color)

		end
		cprintline("state: " .. state, 0, lines[16], ui_color)
	end

	if state == "history" then
		if debug == false and #screen_buffer < 16 then
			print("page " .. history_idx-1 .. " / " .. #history-1, 0, lines[16], ui_color)
		end

		-- ensure LOG isn't covered by text, most likely won't be.
		local screen_buffer_start = sub(screen_buffer[1], 1, 3)
		if screen_buffer_start == "   " or screen_buffer_start == "" then
			print("log",0,0,ui_color) 
		end
	end
end

function _draw()
	if g_state == "main" then
		gs_main_draw()
	elseif g_state == "save" then
		gs_save_draw()
	end
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
