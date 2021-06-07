package.cpath = ";./?51.dll;./debug/?.dll;" .. package.cpath
package.path = ";./socket/?.lua;" .. package.path

require "fight-info"
require "hitboxes"
require "NeuralNetwork"
require "math"

socket = require('socket')
local host, port = "localhost", 2222
client = nil
training = true

Buttons = {
	"Left",
	"Right",
	"Up",
	"Down",
	"Button 1",
	"Button 2",
	"Button 3",
	"Button 4",
	"Button 5",
	"Button 6",
}

local training_set = {}

local player1 = {}
local player2 = {}

player1.round = 0
player1.victory = 0

player2.round = 0
player2.victory = 0

local round = 1
local computed = false
local players_distance = 0
local last_frame = 0

globals.draw_axis = true
globals.draw_pushboxes = false
globals.draw_throwable_boxes = false
globals.draw_pushboxes = false

network = NeuralNetwork.create(6,12,1,12,0.3)

local g = nil

local function any_true(condition)
	for n = 1, #condition do
		if condition[n] == true then return true end
	end
end

local game_sets = {
	{
		games = {"sfa"},
		round_start = function() return any_true({
			memory.readdword(0xFF8004) == 0x40000 and memory.readdword(0xFF8008) == 0x40000,
			memory.readword(0xFF8008) == 0x2 and memory.readword(0xFF800A) > 0
		}) end
	}
}


function send_data(set)
	--print(g.round_start())
	if(client == nil) then
		client = socket.connect(host, port)
		print("Trying to connect to Besouro Server...")
		return 0
	else
		client:send(format_training_set(set) .. "\n")
		local line, err = client:receive()
		return line
	end


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

local function array_has_value(src_arr, str)
	for i=1,#src_arr do
		if(src_arr[i] == str) then
			return true
		end
	end

	return false
end

function get_pressed_keys(pressed_buttons)

		keys = {}

		j = 1
		for key, value in pairs(pressed_buttons) do
			keys[j] = key
			j = j + 1
		end

		moves = Buttons
		if( player1.lado == 'r') then
			--moves = ai_moves.r
		end

		label = {}
		for x=1, #moves do
			if(array_has_value(keys,moves[x])) then
				label[x] = 1
			else
				label[x] = 0
			end
		end

		str_label = ""

		for x=1,#label do
			str_label = str_label ..label[x] .. ","
		end

		return string.sub(str_label,0,#str_label-1)

end

function format_training_set(set)
	label = get_pressed_keys(joypad.getdown())
	set_str = emu.framecount() .. "," .. set.op .. "," .. tonumber(set.dist) .. "," .. player1.life .. "," .. player1.special .. ",".. player2.life .. "," .. player2.special .. "," .. set.player_jump .. ",".. set.foe_attack .. "," .. set.foe_attack_down .. "," .. set.foe_jump .. "," .. set.foe_projectile
	--.. "|".. label
	return set_str
end



function whichgame()
	for _, module in ipairs(game_sets) do
		for _, shortname in ipairs(module.games) do
			if emu.romname() == shortname or emu.parentname() == shortname then
				print("Game Detected:  " .. emu.gamename())
				g = module
				return
			end
		end
	end
	print("Could not detect game: " .. emu.gamename())
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

		if(tonumber(player1.pos_x) < tonumber(player2.pos_x)) then
			--emu.message("lado esquerdo")
			player1.lado = "l"
			player2.lado = "r"
		else
			player1.lado = "r"
			player2.lado = "l"
			--emu.message("lado direito")
		end
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

function compute_round()
	if(g.round_start()) then
		predict_move()
		define_winner(player1,player2)

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

function predict_move()
	training_set.op = "b"
	training_set.dist = players_distance
	training_set.player_jump = player1.jump
	training_set.foe_attack = player2.attack
	training_set.foe_attack_down = player2.attack_down
	training_set.foe_jump = player2.jump
	training_set.foe_projectile = player2.proj_attack

	resp = tonumber(send_data(training_set))

	last_frame = emu.framecount()
	--print(resp)
    if(resp > 0) then
        clearJoypad()
        jp = {}
        jp["P1 " .. Buttons[resp]] = true
       -- jp["P2 Button 4"] = true
        joypad.set(jp)
    end
end

function send_after_frame()
	if(g.round_start()) then
		training_set.op = "a"
		training_set.dist = players_distance
		training_set.player_jump = player1.jump
		training_set.foe_attack = player2.attack
		training_set.foe_attack_down = player2.attack_down
		training_set.foe_jump = player2.jump
		training_set.foe_projectile = player2.proj_attack

		resp = tonumber(send_data(training_set))
	end

end

function draw_info()
	p1_lado = player1.lado == 'l' and 'left' or 'right'
	p2_lado = player2.lado == 'l' and 'left' or 'right'
	if (player1.life ~= nil) then
		--gui.box(0, 0, 30, 20, 000000,000000)
		gui.text(0,0,"Life: " .. player1.life)
		gui.text(0,10,"Special: " .. player1.special)
		lado = player1.lado == 'l' and 'left' or 'right'
		gui.text(0,20,"Side: " .. p1_lado)
		gui.text(0,30,"Distance: " .. players_distance)
		gui.text(0,40,"Round: " .. player1.round)
		gui.text(0,50,"Victories: " .. player1.victory)
		gui.text(0,60,"Attack: " .. player1.attack)
		gui.text(0,70,"Attack Down: " .. player1.attack_down)
		gui.text(0,80,"Jump: " .. player1.jump)
		gui.text(0,90,"Projectile: " .. player1.proj_attack)



		gui.text(280,0,"Life: " .. player2.life)
		gui.text(280,10,"Special: " .. player2.special)
		lado = player2.lado == 'l' and 'left' or 'right'
		gui.text(280,20,"Side: " .. p2_lado)
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
	if(g.round_start()) then
		draw_info()
		render_hitboxes()
	end
end)

emu.registerstart(function()
	whatgame()
	whichgame()
	obj = savestate.create(1)
    savestate.load(obj)
    clearJoypad()
end)

emu.registerbefore(function()
  get_players_info()
  compute_players_info()
end)

emu.registerafter(function()
     send_after_frame()
     reset_attack_proj()
     update_OSD()
     update_hitboxes()
     print(joypad.getdown())
     --clearJoypad()

end)


while true do
  compute_round()
  emu.frameadvance()
end



