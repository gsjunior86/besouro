require "fight-info"
require "hitboxes"



local player1 = {}
local player2 = {}

player1.round = 0
player1.victory = 0

player2.round = 0
player2.victory = 0

local round = 1
local computed = false
local players_distance = 0

globals.draw_axis = true
globals.draw_pushboxes = false
globals.draw_throwable_boxes = false
globals.draw_pushboxes = false

function reset_values()
	p1v = player1.victory
	p2v = player2.victory
	player1 = {}
	player2 = {}
	player1.round = 0
	player2.round = 0
	player1.victory = p1v
	player2.victory = p2v
	round = 1
end

function define_winner(p1,p2)
	if(p1.life ~= "-" and p2.life == "-" and computed == false)then
		p1.round = p1.round + 1
		computed = true
		emu.message("Player 1 ganhou o round ".. round)
		round = round + 1
	elseif(p2.life ~= "-" and p1.life == "-" and computed == false) then
		p2.round = p2.round + 1
		computed = true
		emu.message("Player 2 ganhou o round " .. round)
		round = round + 1
	end
	
	if(p1.round == 2) then
		p1.victory = p1.victory + 1
		reset_values()
	elseif(p2.round == 2) then
		p2.victory = p2.victory + 1
		reset_values()
	end
	
	--if(p1.round == 2 or p2.round == 2) then
	--	reset_values()
	--end
end


emu.registerafter(function()
 				
  update_OSD()
  update_hitboxes()
  

	if(memory.readbyte(0xFFCB01) > 0 and bit.band(memory.readbyte(0xFFCB02), 0x08) > 0) then
		--print("oioioi")
		player1.pos_x = player1_pos_x
		player1.pos_y = player1_pos_y
		player2.pos_x = player2_pos_x
		player2.pos_y = player2_pos_y
		
		
			
		for p = 1, game.nplayers do
				local p = player[p]
				if(p.side == -1) then
					for _, text in pairs(p.text) do
						if(_ == 1) then
							player1.special = string.sub(text.val,1,-5)
						end
						if(_ == 2) then
							player1.life = string.sub(text.val,1,-5)
						end
					end	
				elseif(p.side == 1) then
					for _, text in pairs(p.text) do
						if(_ == 1) then
							player2.special = string.sub(text.val,1,-5)
						end
						if(_ == 2) then
							player2.life = string.sub(text.val,1,-5)
						end
					end
				end

		end
		
		--print(player1.pos_x .. " | " .. player2.pos_x)

		if(player1.life == "144" and player2.life == "144" ) then
			computed = false
		end
			
		players_distance = tonumber(player1.pos_x) - tonumber(player2.pos_x)
			
		if(players_distance < 0) then
			players_distance = players_distance * -1
		end
		players_distance = players_distance - 40
		dif = emu.screenwidth() - players_distance
		perc = (dif * 100) / emu.screenwidth()
			
		if(perc > 76) then
			players_distance = "close"
		elseif (perc < 76 and perc > 50) then
			players_distance = "medium"
		else
			players_distance = "far"
		end
			
		if(tonumber(player1.pos_x) < tonumber(player2.pos_x)) then
			--emu.message("lado esquerdo")
			player1.lado = "l"
		else
			player1.lado = "r"
			--emu.message("lado direito")
		end
		--draw_info()	
		define_winner(player1,player2)
	end
	
end)


function draw_info()
	if (player1.life ~= nil) then
		--gui.box(0, 0, 30, 20, 000000,000000)
		gui.text(0,0,"Life: " .. player1.life)
		gui.text(0,10,"Special: " .. player1.special)
		lado = player1.lado == 'l' and 'left' or 'right'
		gui.text(0,20,"Lado: " .. lado)
		gui.text(0,30,"Distance: " .. players_distance)
		gui.text(0,40,"Round: " .. player1.round)
		gui.text(0,50,"Victories: " .. player1.victory)

	end
end

gui.register(function()
	gui.clearuncommitted()
	draw_info()
	render_hitboxes()
end)

emu.registerstart(function()
	whatgame()
end)

