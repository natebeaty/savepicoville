--save new york

function _init()
  mx,my=0,0 --movement
  cx,cy=0,0 --camera
  transition_speed=0.25
  make_player()
end

function _update()
  move_player()
  update_map()
end

function _draw()
  cls()

  -- update_camera()

  --draw the map from tile 0,0
  --at screen coordinate 0,0 and
  --draw 16 tiles wide and tall
  map(0,0,0,0,128,32)

  --draw the player's sprite at
  --p.x,p.y
  spr(p.sprite,p.x,p.y)
end
