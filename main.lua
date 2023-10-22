--save chicago!

function _init()
  mode="title"
  explosions={}
  buildingcrash={}
  rumblingrows={}
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

  if #buildingcrash>0 then
    for obj in all(buildingcrash) do
      for i=1,obj.rowbusted do
        sfx(11)
        for j=1,obj.building.width do
          local mx=obj.building.x+j
          local my=14-#obj.building.rows+i
          mset(mx, my, 8)
          add(rumblingrows, new_rumblingrow(mx*8,my*8,i*10))
        end
      end
    end
    buildingcrash={}
  end
  for obj in all(enemies) do
    obj.update(obj)
  end


  if mode=="title" then

    check_enemy_spawn(5)
    for obj in all(enemies) do
      obj.update(obj)
    end
    -- enough time has elapsed and btn is pressed
    if t>5 and btn(4) then
      start_game()
    end

  elseif mode=="game" then

    if (p.dying==0 and t%2==0) then
      -- moving? reduce fuel
      if (p.dy!=0 or p.dx!=0) p.fuel-=1
      if (p.fuel==0) p.die()
    end

    move_player()
    player_fire()
    check_enemy_spawn(2)
    check_supply_spawn()
    update_map()
    for grp in all({bullets,enemies,supply,balloon,explosions,rumblingrows}) do
      for obj in all(grp) do
        obj.update(obj)
      end
    end

  elseif mode=="game over" then

    for grp in all({supply,balloon,explosions,rumblingrows}) do
      for obj in all(grp) do
        obj.update(obj)
      end
    end
    if (t>5 and btn(4)) then
      restart()
    end

  end
end

function draw_bg()
  map(0,0,0,0,128,32)
end

-- draw!
function _draw()
  cls()
  draw_bg()

  if mode=="title" then

    for obj in all(enemies) do
      obj.draw(obj)
    end
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
    for grp in all({bullets,enemies,supply,balloon,explosions,rumblingrows}) do
      for obj in all(grp) do
        obj.draw(obj)
      end
    end

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

      for grp in all({supply,balloon,explosions}) do
        for obj in all(grp) do
          obj.draw(obj)
        end
      end
  end
end
