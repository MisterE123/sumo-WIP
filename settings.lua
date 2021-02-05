-- speed when in the minigame (players will be a little faster when running)
sumo.player_speed = 2 
--------------------------------------
-- jump when in the minigame (players can jump a little higher when running)
sumo.player_jump = 1.3 
--------------------------------------
--how long players may run (and jump a little extra too) before triggering the run cooldown
sumo.movement_timeout = 5 
--------------------------------------
--the base value of how hard the stick hits, though hit force may be up to 30 more than this
sumo.stick_knockback = 25 
--------------------------------------
-- how close to the pointed node must the player be to vault
sumo.stick_vault_reach = 3 
--------------------------------------
-- timer for how long the vault cannot be used after it is used
sumo.stick_vault_timeout = 1.0 --(float)--in seconds
--------------------------------------
-- if an opponent is within this distance, then if the player uses the pushstick with the shift key pressed, the players switch positions.
sumo.allow_swap_distance = 6 
--------------------------------------
--the distance that players may select other players while holding the stick
sumo.stick_pointing_distance = 7
--------------------------------------
--the cooldown for pushing other players with the stick. If a player re-clicks sooner than this many seconds, they will not have an effect to speak of
sumo.stick_push_timeout = 0.3 --(float)--in seconds
--------------------------------------
