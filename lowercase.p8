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

-- config
dialog_mode=true      -- check for " to mark dialogue
dialog_mode_color=15   -- color of dialogue text and the " marks
ignore_at=true        -- skip @ symbols entirely
in_dialog=false        -- internal: currently inside quotes

-- returns text with @ symbols and
-- escape backslashes removed, leaving
-- only the characters that are drawn.
-- an escaped character (like \\e or
-- \\@) is kept, only its backslash goes.
function cstrip(text)
 text = text or ""
 local out=""
 local esc=false
 for l=1,#text do
  local ch=sub(text,l,l)
  if ch=="\\" and not esc then
   esc=true
  elseif ch=="@" and not esc then
   -- skip
  else
   out..=ch
   esc=false
  end
 end
 return out
end

-- returns the total x length of text
-- in pixels (visible characters * 4)
function cwidth(text)
 return #cstrip(text)*4
end

-- print each letter in text
-- using the lower case font.
-- if col is supplied, it overrides
-- dialog mode coloring.
function cprint(text,x,y,col)
-- define letters and bitmaps
alphabet="abcdefghijklmnopqrstuvwxyz"
images={
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

-- combine letters and bitmaps
-- in a single table
alphadict={}
for i=1,#images do
 alphadict[sub(alphabet,i,i)]=images[i]
end
 text = text or ""
 x = x or 0
 y = y or 0
 local col_given = col != nil
 col = col or 7
 capital=false
 for l=1,#text do
  letter=sub(text,l,l)
  local c=col
  if dialog_mode then
   if letter=="\"" and not capital then
    in_dialog=not in_dialog
    if not col_given then c=dialog_mode_color end
   elseif in_dialog then
    if not col_given then c=dialog_mode_color end
   end
  end
  if ignore_at and letter=="@" and not capital then
   -- do nothing
  elseif letter=="\\" and not capital then
   capital=true
  elseif capital or alphadict[letter]==nil then
   print(letter,x,y,c)
   x+=4
   capital=false
  else
   image=alphadict[letter]
   for i=0,31 do
    if band(image,shl(0x0000.0001,i))!=0 then
     pset(x,y+i%8,c)
    end
    if i%8==7 then x+=1 end
   end
  end
 end
end
-- end lowercase library
