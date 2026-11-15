#include script.p8
#include lowercase.p8

char_x = 0
char_y = 0

function _draw()
	cls()

	for i=1,#script do
		cprint(script[i],0,char_y)
		char_y += 8
	end
