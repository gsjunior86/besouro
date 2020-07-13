emu.registerbefore(function ()
	if(emu.framecount() % 2 == 0) then
		a ={}
		a["P2 Button 6"] = true
		joypad.set(a)	
	else
		a ={}
		a["P2 Button 6"] = false
		joypad.set(a)	
	end
end)


