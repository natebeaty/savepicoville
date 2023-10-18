--save new york!

function _init()
  bullets={}
  enemies={}
  gameover=false
  mx,my=0,0 --movement
  cx,cy=0,0 --camera
  t=0
  transition_speed=0.25
  make_player()
end

function _update()
  t+=1
  if (t%15==0) then
    if (p.dy!=0 or p.dx!=0) p.fuel-=1
    t=0
  end
  move_player()
  player_fire()
  check_enemy_spawn()
  if (count(enemies)>2 and rnd(100) > 95) add(enemies, new_enemy(rnd(128), -10))
  -- update_map()
  foreach(bullets, function(obj)
    obj.update(obj)
  end)
  foreach(enemies, function(obj)
    obj.update(obj)
  end)
end

function game_over()
  gameover=true
end

function _draw()
  if gameover then return end
  cls()

  -- update_camera()

  --draw the map from tile 0,0
  --at screen coordinate 0,0 and
  --draw 16 tiles wide and tall
  map(0,0,0,0,128,32)

  --draw the player's sprite at
  --p.x,p.y
  spr(p.sprite, p.x, p.y, 1, 1, p.flipx, p.flipy)

  -- update_map()
  foreach(bullets, function(obj)
    obj.draw(obj)
  end)
  foreach(enemies, function(obj)
    obj.draw(obj)
  end)

  rectfill(0,0,128,8,14)
  print("fuel:"..p.fuel, 4, 2, 1)
  print("score:"..p.score, 50, 2, 1)
  print(p.life, 100, 2, 1)
end
