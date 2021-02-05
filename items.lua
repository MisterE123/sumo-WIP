local stick_knockback = sumo.stick_knockback --multiplier for how hard the stick hits
local stick_vault_reach = sumo.stick_vault_reach -- how close to the pointed node must the player be to vault
local stick_vault_timeout = sumo.stick_vault_timeout --(float)--in seconds
local allow_swap_distance = sumo.allow_swap_distance -- if an opponent is within this distance, then if the player uses the pushstick with the shift key pressed, the players switch positions.
local stick_pointing_distance = sumo.stick_pointing_distance
local stick_push_timeout = sumo.stick_push_timeout --(float)--in seconds
sumo.timeouts={}
sumo.jumpouts = {}
sumo.push_hud = {}
sumo.jump_hud = {}



minetest.register_craftitem("sumo:pushstick", {
    description = "Push Stick",
    inventory_image = "default_stick.png",
    stack_max = 1,
    wield_scale = {x = 2, y = 2, z = 2},
    on_drop = function() end,
    range = stick_pointing_distance,

    on_use = function(itemstack, user, pointed_thing)
        
        
        --local imeta = itemstack:get_meta()
        local p_name = user:get_player_name()
        local last_push_time = sumo.timeouts[p_name] or 0.0
        local current_time = minetest.get_us_time()/1000000.0

        local time_from_last_push = current_time-last_push_time

        
        local force = 1 --hey, lets give the jitter-clickers "something" but not much: force of 2 is tiny, which makes jitterclicking completely ineffectual

        if time_from_last_push > stick_push_timeout then
            local time_factor = 0
            if time_from_last_push >= 0.3 and time_from_last_push < 0.4 then
                time_factor = 4
            elseif time_from_last_push >=  0.4 and time_from_last_push <  0.5 then
                time_factor = 9
            elseif time_from_last_push >= 0.5 and time_from_last_push < 0.7 then
                time_factor = 14

            elseif time_from_last_push >  0.7 then
                time_factor = 20
            elseif time_from_last_push > 2.0 then
                time_factor = 25
            end
            force = stick_knockback + time_factor
        end

        
        
        local sound = 'swish'..math.random(1,4)
        minetest.sound_play(sound, {
            pos = user:get_pos(),
            max_hear_distance = 5,
            gain = 10.0,
        })

        if pointed_thing == nil then return end
        if pointed_thing.type == 'node' then return end
        if not pointed_thing.type == 'object' then return end

        if pointed_thing.type == 'object' then
            
            --this only works on players
            if minetest.is_player(pointed_thing.ref) == true then

                local dir = user:get_look_dir()
                local keys = user:get_player_control()
                local swap = false
                local hitted_pos = pointed_thing.ref:get_pos()
                local hitter_pos = user:get_pos()

                if keys.sneak and vector.distance(hitted_pos,hitter_pos) < allow_swap_distance then --swap if pressing shift
                    swap = true
                    user:move_to(hitted_pos, true)
                    local pointed_name = pointed_thing.ref:get_player_name()
                    if not sumo.invincible[pointed_name] then
                        pointed_thing.ref:move_to(hitter_pos, true)
                        pointed_thing.ref:add_player_velocity(vector.multiply({x = -dir.x, y = dir.y, z= -dir.z}, (force + 1)* 0.6 )) --switch positions, and throw the target with 0.6X normal force
                        sumo.timeouts[p_name] = current_time
                        local sound = 'swish'..math.random(1,4)
                        minetest.sound_play(sound, {
                            to_player = pointed_thing.ref:get_player_name(),
                            pos = user:get_pos(),
                            gain = 10.0,
                        })
                    end

                else --not pressing shift, add velocity "force"

                    local pointed_name = pointed_thing.ref:get_player_name()
                    if not sumo.invincible[pointed_name] then
                        pointed_thing.ref:add_player_velocity(vector.multiply(dir, force))
                        sumo.timeouts[p_name] = current_time
                        
                        local sound = 'thwack2' --TODO: get the other 2 thwack souds into the game (where did they go anyways?!)
                        minetest.sound_play(sound, {
                            pos = user:get_pos(),
                            max_hear_distance = 10,
                            gain = 10.0,
                        })
                        minetest.sound_play(sound, {
                            to_player = pointed_thing.ref:get_player_name(),
                            pos = user:get_pos(),
                            gain = 10.0,
                        })
                        local sound = 'hurt'..math.random(1,2)
                        minetest.sound_play(sound, {
                            to_player = pointed_thing.ref:get_player_name(),
                            pos = user:get_pos(),
                            gain = 10.0,
                        })
                    end
                    
                end

            end
        end
        
        
    
    end,

    on_place = function(itemstack, placer, pointed_thing)


        local p_name = placer:get_player_name()
        local last_jump_time = sumo.jumpouts[p_name] or 0.0
        local current_time = minetest.get_us_time()/1000000.0 --microsec converted to sec

        
        local time_from_last_jump = current_time-last_jump_time
        
        if pointed_thing.type == 'node' then
            if vector.distance(pointed_thing.under, placer:get_pos()) < stick_vault_reach then

                if last_jump_time == 0.0 or time_from_last_jump >= stick_vault_timeout then
                    local lookvect = placer:get_look_dir()
                    local pushvect = vector.normalize( {x=lookvect.x, z=lookvect.z, y= math.sqrt(1-(lookvect.y*lookvect.y))})
                    --gives a unit vector that is 90 deg offset in the vert direction
                    local force = 10 * vector.length(vector.normalize( {x=lookvect.x, z=lookvect.z, y= 0}))
                    sumo.jumpouts[p_name] = current_time
                    placer:add_player_velocity(vector.multiply(pushvect, force))
                    --update the staff time for next check
                    local sound = 'jump'..math.random(1,2)
                    minetest.sound_play(sound, {
                        pos = placer:get_pos(),
                        max_hear_distance = 10,
                        gain = 10.0,
                    })
                end
            end
        end
        
    end,

})





--HUD indicator for sumo pushstick strength (color based)

minetest.register_globalstep(function(dtime)

    for _,player in ipairs(minetest.get_connected_players()) do
        local pl_name = player:get_player_name()
        local inv = player:get_inventory()
        local stack = ItemStack("sumo:pushstick")
        if inv:contains_item('main', stack) then

            --Push HUD
            local last_push_time = sumo.timeouts[pl_name] or 0.0
            local current_time = minetest.get_us_time()/1000000.0
            local time_from_last_push = current_time-last_push_time
            local push_color = "#ff000088" --bright red
            if time_from_last_push >= 0.3 and time_from_last_push < 0.4 then
                push_color = "#ff150088" --orange red
            elseif time_from_last_push >=  0.4 and time_from_last_push <  0.5 then
                push_color = "#ff330088" --orange
            elseif time_from_last_push >= 0.5 and time_from_last_push < 0.7 then
                push_color = "#f2ff0088" --yellow
            elseif time_from_last_push >=  0.7 then
                push_color = "#8cff0088" --yellow green
            elseif time_from_last_push >= 2.0 then
                push_color = "#66ff0088" --green

            end


            --Thank you, ElCeejo, for giving this HUD code that *actually* works :P
            if not sumo.push_hud[pl_name] then
                sumo.push_hud[pl_name] =player:hud_add({
                    hud_elem_type = "image",
                    position = {x = 0, y = 1},
                    name = "sumo_hud_push",
                    text = "sumo_hud_push.png^[colorize:"..push_color,
                    scale = {x = 3, y = 3},
                    alignment = {x = 1, y = -1},
                    offset = {x = 5, y = -5}
                  })
            else
                player:hud_change(sumo.push_hud[pl_name], "text", "sumo_hud_push.png^[colorize:"..push_color)
            end


            --Jump HUD

            

            local last_jump_time = sumo.jumpouts[pl_name] or 0.0
            local current_time = minetest.get_us_time()/1000000.0 --microsec converted to sec
            local time_from_last_jump = current_time-last_jump_time

            local jump_color = "#ff000088" --red

            if last_jump_time == 0.0 or time_from_last_jump >= stick_vault_timeout then --jump *would* work now
                jump_color = "#66ff0088" --green

            end

            if not sumo.jump_hud[pl_name] then
                
                sumo.jump_hud[pl_name] =player:hud_add({
                    hud_elem_type = "image",
                    position = {x = 0, y = 1},
                    name = "sumo_hud_jump",
                    text = "sumo_hud_jump.png^[colorize:"..jump_color,
                    scale = {x = 3, y = 3},
                    alignment = {x = 1, y = -1},
                    offset = {x = 75, y = -5}
                  })
            else
                player:hud_change(sumo.jump_hud[pl_name], "text", "sumo_hud_jump.png^[colorize:"..jump_color)
            end



        else
            if sumo.push_hud[pl_name] then
                player:hud_remove(sumo.push_hud[pl_name])
                sumo.push_hud[pl_name] = nil
            end
            if sumo.jump_hud then
                player:hud_remove(sumo.jump_hud[pl_name])
                sumo.jump_hud[pl_name] = nil
            end
        end
    end
end)




                







