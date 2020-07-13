package.cpath = ";./?51.dll;./debug/?.dll;" .. package.cpath
package.path = ";./socket/?.lua;" .. package.path
--require("iuplua")
--local iup
--iup = _G.iup
socket = require('socket')

local host, port = "localhost", 2222

client = socket.connect(host, port)



emu.registerbefore(function()
	client:send(emu.framecount() .. "\n")
	receive, data = client:receive()
	print(receive)
end)
--udp:send("teste123")


--emu.registerbefore(function()

--	emu.message(emu.framecount())

--end)
