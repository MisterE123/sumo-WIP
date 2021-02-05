ChatCmdBuilder.new("sumo", function(cmd)

  -- create arena
  cmd:sub("create :arena", function(name, arena)
      arena_lib.create_arena(name, "sumo", arena)
  end)

  cmd:sub("create :arena :minplayers:int :maxplayers:int", function(name, arena, min_players, max_players)
      arena_lib.create_arena(name, "sumo", arena, min_players, max_players)
  end)

  -- remove arena
  cmd:sub("remove :arena", function(name, arena)
      arena_lib.remove_arena(name, "sumo", arena)
  end)

  -- list of the arenas
  cmd:sub("list", function(name)
      arena_lib.print_arenas(name, "sumo")
  end)

  -- info about an arena
  cmd:sub("info :arena", function(sender, arena)
      arena_lib.print_arena_info(sender, "sumo", arena)
  end)

  -- enter editor mode
  cmd:sub("edit :arena", function(sender, arena)
      arena_lib.enter_editor(sender, "sumo", arena)
  end)

  -- enable and disable arenas
  cmd:sub("enable :arena", function(name, arena)
      arena_lib.enable_arena(name, "sumo", arena)
  end)

  cmd:sub("disable :arena", function(name, arena)
      arena_lib.disable_arena(name, "sumo", arena)
  end)

end, {
  description = [[

    (/help sumo)

    Use this to configure your arena:
    - create <arena name> [min players] [max players]
    - edit <arena name>
    - enable <arena name>

    Other commands:
    - remove <arena name>
    - disable <arena>
    ]],
  privs = { sumo_admin = true }
})
