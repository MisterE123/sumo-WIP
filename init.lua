
sumo = {}
sumo.invincible = {}
dofile(minetest.get_modpath("sumo") .. "/settings.lua")

-- local value settings
local player_speed = sumo.player_speed -- when in the minigame, though players will be a little faster when running
local player_jump = sumo.player_jump -- when in the minigame, though players can jump a little higher when running



  arena_lib.register_minigame("sumo", {
      prefix = "[Sumo] ",
      hub_spawn_point = { x = 0, y = 20, z = 0 },
      show_minimap = false,
      time_mode = 2,
      join_while_in_progress = false,
      keep_inventory = false,
      in_game_physics = {
        speed = player_speed,
        jump = player_jump,
        sneak = false,
    	},
      load_time = 4,
      hotbar = {
        slots = 1,
        background_image = "sumo_gui_hotbar.png"
      },

      disabled_damage_types = {"punch","fall","set_hp"},
      properties = {
        jail_spawn = {x = 0, y = 0, z = 0},
        lives = 3,
    
      
      },
      temp_properties = {
        speed = player_speed,
        jump = player_jump,
      },

      player_properties = {
        run_start_time = 0.0,
        running = false,
        run_timeout = 3, --players can't run for 3 sec after match start
        lives = 3,
      },
  })


if not minetest.get_modpath("lib_chatcmdbuilder") then
    dofile(minetest.get_modpath("sumo") .. "/chatcmdbuilder.lua")
end

dofile(minetest.get_modpath("sumo") .. "/commands.lua")
dofile(minetest.get_modpath("sumo") .. "/items.lua")
dofile(minetest.get_modpath("sumo") .. "/minigame_manager.lua")
dofile(minetest.get_modpath("sumo") .. "/nodes.lua")
dofile(minetest.get_modpath("sumo") .. "/privs.lua")


