--save chicago!

function _init()
  mode="title"
  explosions={}
  bullets={}
  enemies={}
  supply={}
  balloon={}
  gameover=false
  mx,my=0,0 --movement
  cx,cy=0,0 --camera
  t=0
  transition_speed=0.25
  make_player()
  make_buildings()
  music(00, 2500)
end

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
  make_buildings()
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

    if (p.dying==0 and t%2==0) then
      -- moving? reduce fuel
      if (p.dy!=0 or p.dx!=0) p.fuel-=1
        if (p.fuel==0) then
          p.die()
        end
    end

    move_player()
    player_fire()
    check_enemy_spawn(2)
    check_supply_spawn()
    update_map()
    foreach({bullets,enemies,supply,balloon,explosions}, function(grp)
      foreach(grp, function(obj)
        obj.update(obj)
      end)
    end)

  elseif mode=="game over" then

    foreach({supply,balloon,explosions}, function(grp)
      foreach(grp, function(obj)
        obj.update(obj)
      end)
    end)
    if (t>5 and btn(4)) then
      restart()
    end

  end
end

function make_buildings()
  -- reset to blue
  for x=0,16 do
    for y=0,14 do
      mset(x,y,8)
    end
  end

  -- random buildings
  buildings={}
  for i=0,3 do
    building={
      rows={},
      width=flr(rnd(2))+2,
      x=3+(i*3+flr(rnd(2)))
    }
    for n=1,flr(rnd(5)+3) do
      row={}
      for x=1,building.width do
        add(row, {
          sprite=flr(rnd(5))+1,
          dmg=0
        })
      end
      add(building.rows, row)
    end
    add(buildings, building)
  end
  -- write to map
  foreach(buildings, function(building)
    i=0
    foreach(building.rows, function(row)
      i+=1
      for j=1,building.width do
        mset(building.x+j, 15-i, row[j].sprite)
        -- spr(row[j].sprite, building.x+8*j, 120-(8*i))
      end
    end)
  end)
end

function draw_bg()
  map(0,0,0,0,128,32)
end

-- draw!
function _draw()
  cls()
  draw_bg()

  if mode=="title" then

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

    --draw player
    if (p.dying==0) then
      spr(p.sprite, p.x, p.y, 1, 1, p.flipx, p.flipy)
    end

    update_map()
    foreach({bullets,enemies,supply,balloon,explosions}, function(grp)
      foreach(grp, function(obj)
        obj.draw(obj)
      end)
    end)

    --status bar
    rectfill(0,0,128,8,14)
    print("fuel:"..p.fuel, 4, 2, 1)
    print("score:"..p.score, 50, 2, 1)
    print(p.life, 100, 2, 1)

  elseif mode=="game over" then

      rectfill(0,0,128,8,14)
      print("score:"..p.score, 50, 2, 1)
      -- print("beaty softworks presents",17,2,1)
      print("game  over",44,24,1)
      print("🅾️ restart",44,43,7)

      foreach({supply,balloon,explosions}, function(grp)
        foreach(grp, function(obj)
          obj.draw(obj)
        end)
      end)
  end
end
