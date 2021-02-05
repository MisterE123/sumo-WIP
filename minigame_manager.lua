local movement_timeout = sumo.movement_timeout --for how long players may run (and jump a little extra too)
local cage_positions = {
    {x = 0, y = -1, z = 0}, --bottom
    {x = 0, y = 3, z = 0}, --top
    {x = 1, y = 0, z = 0},--  +X
    {x = 1, y = 1, z = 0},
    {x = 1, y = 2, z = 0},
    {x = -1, y = 0, z = 0},--  -x
    {x = -1, y = 1, z = 0},
    {x = -1, y = 2, z = 0},
    {x = 0, y = 0, z = 1},--  +Z
    {x = 0, y = 1, z = 1},
    {x = 0, y = 2, z = 1},
    {x = 0, y = 0, z = -1},--  -Z
    {x = 0, y = 1, z = -1},
    {x = 0, y = 2, z = -1},} -- cage postions are relative vectors to spawn fulclips at





local function spawn_cage(pos)
    for _,vect in pairs(cage_positions) do 
        local n_pos = vector.add(pos,vect)
        local node = minetest.get_node(n_pos)
        if node.name == 'air' or node.name == "sumo:fullclip" then 
            minetest.set_node(n_pos, {name="sumo:fullclip"})
        end
    end
end


local function rem_cage(pos)
    for _,vect in pairs(cage_positions) do 
        local n_pos = vector.add(pos,vect)
        local node = minetest.get_node(n_pos)
        if node.name == 'sumo:fullclip' then 
            minetest.set_node(n_pos, {name="air"})
        end
    end
end





local function send_message(arena,num_str)
    arena_lib.HUD_send_msg_all("title", arena, num_str, 1,nil,0xFF0000)
    --arena_lib.HUD_send_msg_all(HUD_type, arena, msg, <duration>, <sound>, <color>)
end

arena_lib.on_load("sumo", function(arena)


    --send controls statement
    for pl_name, stats in pairs(arena.players) do
        ---minetest.log('First: '..dump(pl_name).. " is "..type(pl_name))
        sumo.invincible[pl_name] = true

        local message = 'Controls: '
        minetest.chat_send_player(pl_name,message)
        message = minetest.colorize('Red', '[Punch]: ')..minetest.colorize('Green', 'Push other players ').. " Timeout: 0.3 sec"
        minetest.chat_send_player(pl_name,message)
        message = minetest.colorize('Red', '[Punch]+[Sneak]: ')..minetest.colorize('Green', 'Exchange places ').. " Timeout: 0.3 sec"
        minetest.chat_send_player(pl_name,message)
        message = minetest.colorize('Red', '[Place]: ')..minetest.colorize('Green', 'Vault ').. " Timeout: 1 sec"
        minetest.chat_send_player(pl_name,message)
        message = minetest.colorize('Red', '[Aux (e)]: ')..minetest.colorize('Green', 'Run! ').. " Timeout: 5 sec"
        minetest.chat_send_player(pl_name,message)
        arena.players[pl_name].lives = arena.lives
        local player = minetest.get_player_by_name(pl_name)
        local pos = player:get_pos()
        
        --minetest.log('Second: '..dump(pl_name).. " is "..type(pl_name))
        minetest.after(.2,function(pl_name,pos)
            --minetest.log('Third: '..dump(pl_name).. " is "..type(pl_name))
            local player = minetest.get_player_by_name(pl_name)
            if player and arena_lib.is_player_in_arena(pl_name, 'sumo') then
                player:move_to(pos)
            end
        end,pl_name,pos)
            
    end

    --countdown timer, give item at appropriate time
    send_message(arena,'3')
    minetest.after(1, function(arena)
        
        send_message(arena,'2')
        minetest.after(1, function(arena)
            send_message(arena,'1')
            minetest.after(1, function(arena)
                arena_lib.HUD_send_msg_all("title", arena, "Fight!", 1,nil,0x00FF00)

                local item = ItemStack("sumo:pushstick")
                

                for pl_name, stats in pairs(arena.players) do
                    sumo.invincible[pl_name] = false
                    local player = minetest.get_player_by_name(pl_name)
                    player:get_inventory():set_stack("main", 1, item)
                    
                    
                end
                


            end, arena)
    
        end, arena)
    
    end, arena)

end)

--this is necessary beacuse it is required by arena_lib for timed games
arena_lib.on_time_tick('sumo', function(arena)


    --handle speed boosts
    for pl_name, stats in pairs(arena.players) do
        local player = minetest.get_player_by_name(pl_name)
        local keys = player:get_player_control()
        local set_run_speed = false -- a marker to tell whether to set to the run speed or not

        

        if stats.run_timeout > 0 then
            arena.players[pl_name].run_timeout = arena.players[pl_name].run_timeout - 1
        end

        if keys.aux1 and stats.run_timeout <= 0 then
            set_run_speed = true
            if stats.running == false then
                arena.players[pl_name].running = true
                arena.players[pl_name].run_start_time = minetest.get_gametime()
            end
            local start_run_time = arena.players[pl_name].run_start_time
            local current_time = minetest.get_gametime()
            

            if current_time - start_run_time > movement_timeout then
                set_run_speed = false
                arena.players[pl_name].running = false
                arena.players[pl_name].run_timeout = 5
            end
        end

        if set_run_speed == true and not sumo.invincible[pl_name] then
            player:set_physics_override({
                speed = arena.speed * 1.4,
                jump = arena.jump * 1.3,
            })
        else
            player:set_physics_override({
                speed = arena.speed,
                jump = arena.jump,
            })
            arena.players[pl_name].running = false
        end


        
        --handle messages
        if arena.in_game and not arena.in_celebration and not arena.players[pl_name].invincible then
            local c = 0x00FF00
            if arena.current_time < 60 then
                c = 0xFFFF00
            end
            if arena.current_time < 10 then
                c = 0xFF0000
            end
            local message = " Time Left: "..arena.current_time
            if arena.players[pl_name].run_timeout > 0 then
                message = 'Run Timeout: '..arena.players[pl_name].run_timeout..message
            end
            if arena.players[pl_name].running == true then
                message = 'Running... '..message
            end
            message = message.." Lives:"..arena.players[pl_name].lives
            if arena.current_time < arena.initial_time - 1 then
                arena_lib.HUD_send_msg('hotbar', pl_name, message, 1,nil,c)
            end
            if arena.players[pl_name].invincible then
                arena_lib.HUD_send_msg('broadcast', pl_name, "Invincible", 1,nil,c)
            end
        end

    end
        

        

            
    
end)




minetest.register_on_player_hpchange(function(player, hp_change,reason)
    local pl_name = player:get_player_name()
    if arena_lib.is_player_in_arena(pl_name, 'sumo') then
        local arena = arena_lib.get_arena_by_player(pl_name)
        local hp = player:get_hp()
        if arena.in_celebration then --protect winners from damage
            return 0
        end
        if reason.type ~= "node_damage" then return 0 end
        if sumo.invincible[pl_name] then return 0 end --protects players from dying twice in a row
        if hp + hp_change <= 0 then --dont ever kill players, but if a damage *would* kill them, then eliminate them, and set their health back to normal
            
            sumo.invincible[pl_name] = true
            local player = minetest.get_player_by_name(pl_name)
            local inv = player:get_inventory()
            local taken = inv:remove_item("main", ItemStack("sumo:pushstick"))

            minetest.after(2,function(pl_name)
                sumo.invincible[pl_name] = false
                if arena_lib.is_player_in_arena(pl_name, 'sumo') then
                    local arena = arena_lib.get_arena_by_player(pl_name)
                    if arena.in_game == true then
                        arena_lib.HUD_send_msg("title", pl_name,'Fight!', 2,nil,0x00FF00)
                        local player = minetest.get_player_by_name(pl_name)
                        local sp_pos = arena_lib.get_random_spawner(arena)
                        
                        if player then
                            player:move_to(sp_pos, false)
                            player:get_inventory():set_stack("main", 1, ItemStack("sumo:pushstick"))
                            minetest.after(2,function(pl_name)
                                sumo.invincible[pl_name] = false

                            end,pl_name)
                        end
                    end
                end
            end,pl_name)

            arena.players[pl_name].lives = arena.players[pl_name].lives - 1
            if arena.players[pl_name].lives == 0 then
                arena_lib.remove_player_from_arena(pl_name, 1)
                arena_lib.HUD_hide('hotbar', pl_name)
            else
                arena_lib.HUD_send_msg("title", pl_name,'You Died! Lives: '.. arena.players[pl_name].lives , 2,nil,0xFF1100)
                
                
                
                minetest.sound_play('sumo_elim', {
                    to_player = pl_name,
                    gain = 2.0,
                })
                
                player:move_to(arena.jail_pos, false)
                
                
                

            end
            player:set_hp(20)
            return 0
        else
            return hp_change --if it would not kill players then apply damage as normal
        end


    else
        return hp_change
    end


end, true)


--if the game times out
arena_lib.on_timeout('sumo', function(arena)
    local winner_names = {}
    for p_name, p_stats in pairs(arena.players) do
        table.insert(winner_names, p_name)
    end
    --arena_lib.load_celebration('sumo', arena, winner_names)
    arena_lib.force_arena_ending('sumo', arena,'timeout')

end)



arena_lib.on_death('sumo', function(arena, p_name, reason)
    arena.players[p_name].lives = arena.players[p_name].lives - 1
    if arena.players[p_name].lives == 0 then
        arena_lib.remove_player_from_arena(p_name, 1)
        arena_lib.HUD_hide('hotbar', p_name)
    else
        arena_lib.HUD_send_msg("title", p_name,'You Died! Lives: '.. arena.players[p_name].lives , 2,nil,0xFF1100)
        local sp_pos = arena_lib.get_random_spawner(arena)
        local player = minetest.get_player_by_name(p_name)
        minetest.sound_play('sumo_elim', {
            to_player = p_name,
            gain = 2.0,
        })
        if player then
            player:move_to(sp_pos, false)
        end

    end
end)


arena_lib.on_celebration('sumo', function(arena, winner_name)
    arena_lib.HUD_hide('hotbar', arena)

end)

arena_lib.on_quit('sumo', function(arena, pl_name, is_forced)
    arena_lib.HUD_hide('hotbar', pl_name)
end)


arena_lib.on_eliminate('sumo', function(arena, p_name)

    minetest.sound_play('sumo_lose', {
        to_player = p_name,
        gain = 2.0,
    })
    --minetest.chat_send_all(dump(arena))

    local count = 0
    local sound = 'sumo_elim'
    for p_name,data in pairs(arena.players) do
        count = count + 1
    end
    if count == 1 then
        sound = 'sumo_win'
    end

    for p_name, stats in pairs(arena.players) do


        minetest.sound_play(sound, {
            to_player = p_name,
            gain = 2.0,
        })
    end


end)

--remove stick if in inv when joinplayer
minetest.register_on_joinplayer(function(player)
	local inv = player:get_inventory()
	local stack = ItemStack("sumo:pushstick")
	local taken = inv:remove_item("main", stack)

end)
