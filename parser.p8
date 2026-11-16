mode_slow	= false
mode_fast	= false
mode_input	= false
mode_pause	= false
mode_page	= false

--[[
the idea is for this function to be called for both screen_buffer and line_buffer.
mode slow and mode fast, pause only work for the line_buffer though.
--]]

function reset()
	mode_slow	= false
	mode_fast	= false
	mode_input	= false
	mode_pause	= false
	mode_page	= false
end

-- makes changes to modes and returns a write buffer.
function parse(text)
	text = text or ""

	local buffer = ""

	for i=1,#text do
		char = sub(text,i,i)
		
		if char == "\\" then
			capital = true
		elseif char == "@" then
			mode_input = not mode_input
		elseif char == "#" then
			mode_pause = true --cancels immediately
		elseif char == "$" then
			mode_slow = not mode_slow
		elseif char == "^" then
			mode_fast = not mode_fast
		else
			buffer = buffer .. char
		end
	end
	return buffer -- what to write
end
