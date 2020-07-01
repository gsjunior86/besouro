require "fight-info"
require "hitboxes"
require "NeuralNetwork"



Buttons = {
	"P1 Left",
	"P1 Right",
	"P1 Up",
	"P1 Down",
	"P1 Button 1",
	"P1 Button 2",
	"P1 Button 3",
	"P1 Button 4",
	"P1 Button 5",
	"P1 Button 6",
}

ai_moves = {
  l = {
    "P1 Left",
    "P1 Right",
	"P1 Up",
	"P1 Down",
	"P1 Up,P1 Right",
	"P1 Up,P1 Left",
	"P1 Down,P1 Left",
	"P1 Down,P1 Button 6",
	"P1 Button 1",
	"P1 Button 2",
	"P1 Button 3",
	"P1 Button 4",
	"P1 Button 5",
	"P1 Button 6"
  },
  r = {
    "P1 Right",
    "P1 Left",
	"P1 Up",
	"P1 Down",
	"P1 Up,P1 Left",
	"P1 Up,P1 Right",
	"P1 Down,P1 Right",
	"P1 Down,P1 Button 6",
	"P1 Button 1",
	"P1 Button 2",
	"P1 Button 3",
	"P1 Button 4",
	"P1 Button 5",
	"P1 Button 6"
  }
}

local move_queue = {}

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

network = NeuralNetwork.create(6,14,1,12,0.3)

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

function reset_attack_proj()
	
		player1_attack = 0
		player1_attack_down = 0
	
		player2_attack = 0
		player2_attack_down = 0
	
		player1_jump = 0
		player2_jump = 0
	
		proj_attack = 0
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


function get_players_info()
		
		player1.pos_x = player1_pos_x
		player1.jump = player1_jump
	
		player2.pos_x = player2_pos_x
		player2.jump = player2_jump
	
		player1.attack = player1_attack
		player1.attack_up = player1_attack_up
		player1.attack_down = player1_attack_down
	
		player2.attack = player2_attack
		player2.attack_up = player2_attack_up
		player2.attack_down = player2_attack_down
	
		player1.proj_attack = proj_attack
		player2.proj_attack = proj_attack
		
	
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
end

function compute_players_info()
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
			
		if(perc > 60) then
			players_distance = "close"
		elseif (perc < 60 and perc > 40) then
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
end


function clearJoypad()
	
        jp = {}
		--jp["P1 Button 1"] = false
	
		for i=1, #Buttons do
			jp[Buttons[i]] = false		
		end

        joypad.set(jp)
end

function delete_first(array)
  temp = {}
  for i=1,#array-1 do
    temp[i] = array[i+1]
  end
  return temp
end

function hadouken()
	move = {}	
	move[1] = "P1 Down"
	move[2] = "P1 Down,P1 Right"
	move[3] = "P1 Right,P1 Button 3"
	return move
end

function hadouken_fogo()
	move = {}	
	move[1] = "P1 Right"
	move[2] = "P1 Down"
	move[3] = "P1 Down,P1 Left"
	move[4] = "P1 Button 3"
	return move
end

function batata()
	move = {}	
	move[1] = "P1 Button 5"
	--move[2] = "P1 Left,P1 Down"
	--move[3] = "P1 Left"
	--move[4] = "P1 Button 4"
	return move
end


function execute_move()
	
	if(#move_queue == 0) then
		move_queue = hadouken()		
	end	
		
		a = {}
		for i in string.gmatch(move_queue[1], "([^,]+)") do
		   --print(i)
		   a[i] = true
		end
		
		joypad.set(a)
		move_queue = delete_first(move_queue)
end

function predict_move()
	dist_close = 0
	dist_far = 0
	foe_attack = player2.attack
	foe_attack_down = player2.attack_down
	foe_jump = player2.jump
	foe_projectile = player2.proj_attack
	
	if (players_distance == "close") then
		dist_close = 1
	else
		dist_far = 1
	end
	
	
	
	output = network:forewardPropagate(
			dist_close,
			dist_far,
			foe_attack,
			foe_attack_down,
			foe_jump,
			foe_projectile
		)
	
	b = 0
	b_i = 0
	for i=1,#output do
		if(output[i] > b) then
			b = output[i]
			b_i = i
		end
	end
	
	print("close: " .. dist_close .. " | " ..
		  "far: " .. dist_far .. " | " ..
		  "attack: " .. foe_attack .. " | " ..
		  "attack_down: " .. foe_attack_down .. " | " ..
		  "jump: " .. foe_jump .. " | " ..
		  "projectile: " .. foe_projectile .. " | ")
	
	print(output)

	--clearJoypad()
	
	
end


function compute_round()
	if(
			(memory.readbyte(0xFFCB01) > 0 and bit.band(memory.readbyte(0xFFCB02), 0x08) > 0)
		or((memory.readdword(0xFF8004) == 0x40000 and memory.readdword(0xFF8008) == 0x40000) or (memory.readword(0xFF8008) == 0x2 and memory.readword(0xFF800A) > 0))) then
			
		predict_move()
		
		define_winner(player1,player2)
		reset_attack_proj()
	end	
end

function print_info()
	p1_lado = player1.lado == 'l' and 'left' or 'right'
	p1_info = emu.framecount() .. "- Player 1 | Attack: " .. player1.attack .. " | Proj: " .. player1.proj_attack
	print(p1_info)
end



function draw_info()
	if (player1.life ~= nil) then
		--gui.box(0, 0, 30, 20, 000000,000000)
		gui.text(0,0,"Life: " .. player1.life)
		gui.text(0,10,"Special: " .. player1.special)
		lado = player1.lado == 'l' and 'left' or 'right'
		gui.text(0,20,"Side: " .. lado)
		gui.text(0,30,"Distance: " .. players_distance)
		gui.text(0,40,"Round: " .. player1.round)
		gui.text(0,50,"Victories: " .. player1.victory)
		gui.text(0,60,"Attack: " .. player1.attack)
		gui.text(0,70,"Attack Down: " .. player1.attack_down)
		gui.text(0,80,"Jump: " .. player1.jump)
		gui.text(0,90,"Projectile: " .. player1.proj_attack)
		
		
		
		gui.text(280,0,"Life: " .. player2.life)
		gui.text(280,10,"Special: " .. player2.special)
		lado = player1.lado == 'l' and 'left' or 'right'
		gui.text(280,20,"Side: " .. lado)
		gui.text(280,30,"Distance: " .. players_distance)
		gui.text(280,40,"Round: " .. player2.round)
		gui.text(280,50,"Victories: " .. player2.victory)
		gui.text(280,60,"Attack: " .. player2.attack)
		gui.text(280,70,"Attack Down: " .. player2.attack_down)
		gui.text(280,80,"Jump: " .. player2.jump)
		gui.text(280,90,"Projectile: " .. player2.proj_attack)
		
		--gui.text(0,70,"Projectile: " .. player1.proj)

	end
end

gui.register(function()
	gui.clearuncommitted()
	if(
			(memory.readbyte(0xFFCB01) > 0 and bit.band(memory.readbyte(0xFFCB02), 0x08) > 0)
		or((memory.readdword(0xFF8004) == 0x40000 and memory.readdword(0xFF8008) == 0x40000) or (memory.readword(0xFF8008) == 0x2 and memory.readword(0xFF800A) > 0))) then
		draw_info()
		render_hitboxes()
	end
end)

emu.registerstart(function()
	whatgame()
end)

emu.registerbefore(function()
	get_players_info()
	compute_players_info()
end)

emu.registerafter(function()
	update_OSD()
    update_hitboxes()
	compute_round()
end)


