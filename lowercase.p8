-- lowercase library
--[[
	each letter is a 4x8 pixel map stored as a 32-bit number. the bits from right
	to left draw the letter starting at the top left corner and drawing each
	column. so... 0x0000.00ff is first column 0xff00.0000 is fourth column

	print a capital letter by using a backslash in the text string. note that
	a backslash must itself be escaped with a backslash, so
	enter "\\e" to print capital letter e. note that this adds
	a character for each capital letter, so the length of the
	string in data may not match the length of the string on screen.
]]

-- define letters and bitmaps
local alphabet="abcdefghijklmnopqrstuvwxyz"

-- combine letters and bitmaps
-- in a single table
local images={
	0x001e.120c,0x000c.121f, --a b
	0x0012.120c,0x001f.120c, --c d
	0x0014.1a0c,0x0005.1e04, --e f
	0x001e.2a2c,0x001c.021f, --g h
	0x0000.001d,0x0000.1d20, --i j
	0x0016.081f,0x0000.100f, --k l
	0x001e.061e,0x001c.021e, --m n
	0x000c.120c,0x001c.123e, --o p
	0x003e.121c,0x0002.021c, --q r
	0x0000.1a16,0x0012.0f02, --s t
	0x001e.100e,0x000e.180e, --u v
	0x001e.181e,0x0012.0c12, --w x
	0x001e.282e,0x0000.161a  --y z
}

function get_alphadict()
	local alphadict = {}

	for i=1,#images do
		alphadict[sub(alphabet,i,i)] = images[i]
	end

	return alphadict
end

function draw_image(image, x, y, col)
	if image == nil then
		return
	end

	local x = x or 0
	local y = y or 0
	local col = col or 7

	for i=0,31 do
		if band(image,shl(0x0000.0001,i))!=0 then
			pset(x,y+i%8,col)
		end

		if i%8==7 then x+=1 end
	end
end

-- print a single character, uppercase or lowercase.
function cprint(char,x,y,case,col)
	x = x or 0
	y = y or 0
	col = col or 7
	case = case or 'lower'

	local alphadict = get_alphadict()

	local retval = 0

	if case == 'upper' or alphadict[char] == nil then
		print(char, x, y, col)
	else
		draw_image(alphadict[char], x, y, col)
	end
end

--[[
print multiple characters. Uppercase characters are prefixed by \\
directives (real control characters, same as print):
	"\f" + hex digit  set color, e.g. "\f8red \f7white"
	"\n"              newline (back to the starting x, down 8)
	"\t"              tab (next multiple of 16 pixels from the starting x)
]]
function cprintline(text,x,y,col)
	local alphadict = get_alphadict()

	text = text or ""

	x = x or 0
	y = y or 0
	col = col or 7

	local x0 = x
	local capital=false
	local l=1

	while l<=#text do
		local letter=sub(text,l,l)
		l+=1

		if capital then
			print(letter,x,y,col)
			x+=4
			capital=false
		elseif letter=="\\" then
			capital=true
		elseif letter=="\f" then
			col=tonum("0x"..sub(text,l,l)) or col
			l+=1
		elseif letter=="\n" then
			x=x0
			y+=8
		elseif letter=="\t" then
			x=x0+(flr((x-x0)/16)+1)*16
		elseif alphadict[letter]==nil then
			print(letter,x,y,col)
			x+=4
		else
			draw_image(alphadict[letter], x, y, col)
			x+=4
		end
	end
end
-- end lowercase library
