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

page_idx = 1
line_idx = 1
-- Current Y = (line_idx - 1) * 8
char_idx = 1

state = "printing" -- input, delay, page.

write_buffer = "" -- the contents of this get appended to screen_buffer every frame.

acc = 0

lines = {0,8,16,24,32,40,48,56,64,72,80,88,96,104,112,120}

debug = false

delay = 0
delay_amt = 60 -- frames

function get_acc_amt()
	if mode_slow then
		return acc_amt_default * 2.0
	elseif mode_fast then
		return acc_amt_default * 0.5
	else
		return acc_amt_default * 1.0
	end
end

function _update60()
	update_cursor()

	if btn(1) then
		mode_full_skip = true
	else
		mode_full_skip = false
	end

	if btnp(4) then
		debug = not debug
	end

	if state == "printing" then
		acc += 1
		local acc_amt = get_acc_amt() -- we keep this here in case it changes due to mode. Only apply that on the next pass.
		local page = script[page_idx]
		local lin = page[line_idx]

		if btnp(5) and not mode_skip and not mode_full_skip then
			mode_skip = true
			acc = 0
		end

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
					if mode_skip == true then
						mode_skip = false
					end
			
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
						write_buffer = write_buffer .. "\ff\""
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

			if not mode_skip then
				acc -= acc_amt
			end
		end

		if char_idx > #lin+1 then
			char_idx = 1

			-- flush write buffer right now if there is anything left unwritten.
			screen_buffer[line_idx] = screen_buffer[line_idx] .. write_buffer
			write_buffer = ""

			line_idx += 1
			screen_buffer[line_idx] = screen_buffer[line_idx] or ""

			-- handle edge case where dialog doesn't close on the same line.
			if mode_dialog == true then
				write_buffer = write_buffer .. "\ff"
			end
		end

		if line_idx > #page then
			if page_idx >= #script then
				state = "done"
			else
				state = "input-page"
				show_cursor(4)
			end
		end

	end

	if state == "input" then
		if btnp(5) or mode_full_skip == true then
			state = "printing"
			hide_cursor()
		end
	end

	if state == "input-page" then
		

		if btnp(5) or mode_full_skip then
			line_idx = 1
			page_idx += 1
			screen_buffer = {""}
			state = "printing"
			hide_cursor()
		end
	end

	if state == "delay" then
		delay += 1
		if delay >= delay_amt then
			state = "printing"
			delay = 0
		end
	end

	screen_buffer[line_idx] = screen_buffer[line_idx] .. write_buffer
	write_buffer = ""
end

function _draw()
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

		if state != "done" then
			local cur_line = script[page_idx][line_idx]
			local cur_len = cur_line and #cur_line or 0
			cprintline("page " .. page_idx .. " / " .. #script,0, lines[12], 13)
			cprintline("line " .. line_idx .. " / " .. #script[page_idx],0, lines[13], 13)
			cprintline("char " .. char_idx .. " / " .. cur_len,0, lines[14], 13)
			cprintline("speed: " .. write_speed, 0, lines[15], 13)

		end
		cprintline("state: " .. state, 0, lines[16], 13)
	end
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
