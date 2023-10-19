--save new york!

function game_over()
  t=0
  enemies={}
  p.respawn()
  sfx(04)
  mode="game over"
end

function start_game()
  music(-1)
  sfx(05)
  enemies={}
  mode="game"
end

function restart()
  t=0
  p.score=0
  p.life="♥♥♥"
  mode="title"
  music(00, 2500)
end

function _init()
  mode="title"
  bullets={}
  enemies={}
  gameover=false
  mx,my=0,0 --movement
  cx,cy=0,0 --camera
  t=0
  transition_speed=0.25
  make_player()
  music(00, 2500)
end

function _update()
  t+=1

  if mode=="title" then

    check_enemy_spawn(5)
    foreach(enemies, function(obj)
      obj.update(obj)
    end)
    if (t>5 and btn(4)) then
      start_game()
    end

  elseif mode=="game" then

    if (t%15==0) then
      -- moving?
      if (p.dy!=0 or p.dx!=0) p.fuel-=1
    end

    move_player()
    player_fire()
    check_enemy_spawn(2)
    --update_map()
    foreach(bullets, function(obj)
      obj.update(obj)
    end)
    foreach(enemies, function(obj)
      obj.update(obj)
    end)

  elseif mode=="game over" then

    if (t>5 and btn(4)) then
      restart()
    end

  end
end

-- draw!
function _draw()
  cls()

  if mode=="title" then

    map(0,0,0,0,128,32)
    foreach(enemies, function(obj)
      obj.draw(obj)
    end)
    rectfill(0,0,128,8,14)
    print("beaty softworks presents",17,2,1)
    print("save chicago!",40,24,1)
    print("save chicago!",40,23,7)
    print("🅾️ start game",40,43,7)

  elseif mode=="game" then

    --update_camera()
    map(0,0,0,0,128,32)

    --draw player
    spr(p.sprite, p.x, p.y, 1, 1, p.flipx, p.flipy)

    --update_map()
    foreach(bullets, function(obj)
      obj.draw(obj)
    end)
    foreach(enemies, function(obj)
      obj.draw(obj)
    end)

    --status bar
    rectfill(0,0,128,8,14)
    print("fuel:"..p.fuel, 4, 2, 1)
    print("score:"..p.score, 50, 2, 1)
    print(p.life, 100, 2, 1)

  elseif mode=="game over" then

      map(0,0,0,0,128,32)
      rectfill(0,0,128,8,14)
      print("score:"..p.score, 50, 2, 1)
      -- print("beaty softworks presents",17,2,1)
      print("game  over",44,24,1)
      print("🅾️ restart",44,43,7)

  end
end
