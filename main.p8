pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
#include lowercase.p8
#include cursor.p8
#include script.p8

line_y_height = 8
debug = false

acc_amt = 10.0

pages = script --every bracket inside is a page, every entry is a line.
lines = {} -- stores the lines for the current page, might be unoptimal but idc.
words = "" -- stores the current line. Not printed on it's own, fed to print_buffer.

print_buffer = "" -- if print_buffer is not empty, the manager will print new words.

line_buffer = "" -- current state of printed line.
screen_buffer = {} -- screen_buffer is printed immediately on every refresh.

state = "printing" -- printing, idle.

page_idx = 0
line_idx = 0
letter_idx = 0

screen_line_y = 0 -- increments with each line, until page count is cleared.

acc = 0

function replace_char(txt,char,rep)
 --avoid errors if params missing
 txt=txt and txt or ""
 rep=rep and rep or " "
 
 for i=1,#txt do
  if txt[i]==char then
   txt=sub(txt,1,i-1)..rep..sub(txt,i+1,#txt)
  end
 end
 return txt
end

function advance_page()
	hide_cursor()

	screen_buffer = {}
	line_idx = 0

	page_idx += 1
	lines = pages[page_idx]

	advance_line()
end

function advance_line()
	hide_cursor()

	letter_idx = 0

	line_idx += 1

	words = lines[line_idx]
	print_buffer = words

	state = "printing"
end

function _update60()
	if btnp(4) then
		debug = not debug
	end

	if state == "printing" and print_buffer != "" then
		if letter_idx > #print_buffer then
			screen_buffer[#screen_buffer+1] = replace_char(print_buffer,"@","")
			print_buffer = ""
			line_buffer = ""

			if line_idx+1 > #lines then
				if page_idx+1 > #pages then
					state = "done"
				else
					state = "idle-page"
					show_cursor(4)
				end
			else
				advance_line()
			end
			return
		end

		-- skip: reveal everything up to the next @ (or the end of the line)
		if btnp(5) then
			repeat
				letter_idx += 1

				letter = sub(print_buffer, letter_idx, letter_idx)
				if letter == "@" then
					state = "idle-line"
					show_cursor(flr(rnd(3)+1))
					return
				end

				line_buffer = line_buffer .. letter
			until letter_idx > #print_buffer
			return
		end

		acc += 1

		while acc >= acc_amt do
			acc -= acc_amt

			repeat
				letter_idx += 1

				letter = sub(print_buffer, letter_idx, letter_idx)
				if letter == "@" then
					state = "idle-line"
					show_cursor(flr(rnd(3)+1))
					return
				end

				line_buffer = line_buffer .. letter
			until letter != "\\"

		end

	end
	
	if state == "idle-page" then
		if btnp(5) then
			advance_page()
		end
	end

	if state == "idle-line" then
		if btnp(5) then
			state = "printing"
		end
	end

	if cursor_show == true then
		local c = cursors[cur]

		cur_i += 1

		if cur_i == c.speed*2 then
			cur_frame = (cur_frame % #c.frames) + 1
			cur_i = 1
		end
	end
end

function _draw_cursor(current_line, y)
	local x = cwidth(current_line)

	local c = cursors[cur]

	-- make sure cursor doesn't go off-screen
	if x > 128 - c.width then
		x = 0
		y += line_y_height
	end

	print(c.frames[cur_frame],x,y,12)

	if debug == true then
		cprint("cursor_x:   " .. x, 0, 11 * line_y_height, 5)
	end
end

function _draw()
	cls()

	in_dialog = false
	screen_line_y = 0

	for i=1,#screen_buffer do
		cprint(screen_buffer[i],0,screen_line_y * line_y_height)

		-- draw cursor
		if cursor_show == true and i == #screen_buffer and #line_buffer == 0 then
			_draw_cursor(screen_buffer[i], screen_line_y * line_y_height)
		end

		screen_line_y += 1
	end

	local char_x = 0

	if #line_buffer > 0 then
		cprint(line_buffer, 0, screen_line_y * line_y_height)
		if cursor_show == true then
			_draw_cursor(line_buffer, screen_line_y * line_y_height)
		end
	end

	if debug == true then
		cprint("page_idx:   " .. page_idx, 0, 12 * line_y_height, 5)
		cprint("line_idx:   " .. line_idx, 0, 13 * line_y_height, 5)
		cprint("letter_idx: " .. letter_idx, 0, 14 * line_y_height, 5)
		cprint("state:      " .. state, 0, 15 * line_y_height, 5)
	end

end

function _init()
	advance_page()
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
