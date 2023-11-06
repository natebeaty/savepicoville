--save picoville!

--ensure min speeds, pos or neg
function minspeed(spd,minspd)
  if (abs(spd)~=0 and abs(spd)<minspd) then
    if spd<0 then spd=-minspd else spd=minspd end
  end
  return spd
end

--zero pad a number
function pad(string,length)
  string=""..string
  if (#string==length) return string
  return "0"..pad(string,length-1)
end

--center text with optional bg color
function centertxt(str,y,clr,bg)
  if (bg) rectfill(64-(#str*2)-2,y-1,64+(#str*2),y+5,bg)
  print(str,64-#str*2,y,clr)
end

--get map sprite at a pixel location
function getmapsprite(x,y)
  local mx=flr(x/8)
  local my=flr(y/8)
  local map_sprite=mget(mx,my)
  return map_sprite
end

--check if object offstage
function is_offstage(obj,offset)
  offset=offset or 0
  return obj.x<0-offset or obj.x>128+offset or obj.x<0-offset or obj.y>128+offset
end

--ye olde screen rattle
function screen_shake()
  local offset_x=1-rnd(2)
  local offset_y=1-rnd(2)
  camera(offset_x,offset_y)
end

function _init()
  cartdata("savepicoville") --persistent hiscore
  t=0
  level=1
  hiscore=dget(0) or 0
  enemieskilled=0
  titleshadowclr={13,14,9,14,13}
  enemyspeed=1
  mode="title"
  peopleleft=100
  bonuscheck={x=0,y=15}
  bonuslastbrick=nil
  empty_stage()
  make_player()
  music(0,2500)
end

function game_over()
  t=0
  hiscore=max(hiscore,p.score)
  dset(0,hiscore) --record hiscore in cartdata
  level=1
  p.respawn()
  sfx(04)
  mode="game over"
end

--stats on top of screen
function status_bar()
  rectfill(0,0,128,8,1)
  local fuelclr=9
  --blink fuel if low (and game isn't over)
  if (mode=="game" and t%40<20 and p.fuel<p.lowfuel) fuelclr=7
  print("fuel:"..flr(p.fuel),4,2,fuelclr)
  print("score:"..p.score.."0",48,2,9)
  for i=1,p.life do
    spr(56,124-i*6,0)
  end
end

function check_level()
  --currently super basic difficulty ramp based on original game
  if ((level==1 and enemieskilled>=10) or enemieskilled>=16) then
    level_finished()
  end
end

function level_finished()
  t=0
  enemieskilled=0
  enemyspeed=level
  bullets={}
  mode="bonus"
  -- set min/max starting points for bonuscheck
  for building in all(buildings) do
    bonuscheck.y = min(bonuscheck.y,14-building.height)
    bonuscheck.x = max(bonuscheck.x,building.x+building.width)
  end
end

function next_level()
  t=0
  level+=1
  enemies={}
  gremlins={}
  supply={}
  balloon={}
  p.respawn()
  mode="game"
end

function start_game()
  empty_stage()
  music(-1)
  sfx(05)
  mode="game"
end

--clear out stage actors
function empty_stage()
  enemies={}
  gremlins={}
  supply={}
  balloon={}
  bullets={}
  trains={}
  explosions={}
  buildingcrash={}
  rumblingrows={}
  make_buildings()
end

function restart()
  t=0
  enemieskilled=0
  p.reset()
  mode="title"
  empty_stage()
  music(0,2500)
end

function _update()
  t+=1
  building_update()

  if mode=="title" then

    building_blink(4)
    check_enemy_spawn(5)
    check_train_spawn()
    for grp in all({enemies,gremlins,rumblingrows,trains}) do
      for obj in all(grp) do
        obj.update(obj)
      end
    end
    -- enough time has elapsed and btn is pressed
    if t>5 and btn(4) then
      start_game()
    end

  elseif mode=="bonus" then

    for grp in all({explosions,rumblingrows,trains}) do
      for obj in all(grp) do
        obj.update(obj)
      end
    end
    -- set last bonus brick that flashed white to dark
    if bonuslastbrick~=nil then
      mset(bonuslastbrick.x,bonuslastbrick.y,05)
      bonuslastbrick=nil
    end
    -- tally bonus points
    if (bonuscheck.y<16) then
      local map_sprite=mget(bonuscheck.x,bonuscheck.y)
      -- skip tiles until brick
      while map_sprite>5 and bonuscheck.y<16 do
        bonuscheck.x-=1
        if bonuscheck.x<0 then
          bonuscheck.y+=1
          bonuscheck.x=15
        end
        map_sprite=mget(bonuscheck.x,bonuscheck.y)
      end
      -- unbroken brick
      p.scored(1)
      bonuslastbrick={x=bonuscheck.x,y=bonuscheck.y}
      sfx(12)
      mset(bonuscheck.x,bonuscheck.y,map_sprite+47) --white flash
      bonuscheck.x-=1
      if bonuscheck.x<0 then
        bonuscheck.y+=1
        bonuscheck.x=15
      end
    else
      building_blink(1)
      if (t>10 and btnp(4)) then
        next_level()
      end
    end

  elseif mode=="game" then

    p.update()
    building_blink(3)
    check_enemy_spawn(level+1)
    check_supply_spawn()
    check_train_spawn()
    for grp in all({bullets,enemies,gremlins,supply,balloon,explosions,rumblingrows,trains}) do
      for obj in all(grp) do
        obj.update(obj)
      end
    end

  elseif mode=="game over" then

    building_blink(1)
    for grp in all({enemies,gremlins,supply,balloon,explosions,rumblingrows,trains}) do
      for obj in all(grp) do
        obj.update(obj)
      end
    end
    if (t>10 and btnp(4)) then
      restart()
    end

  end
end

-- draw!
function _draw()
  cls()
  --draw the stage including generated buildings
  map(0,0,0,0,128,32)

  if mode=="title" then

    for grp in all({enemies,gremlins,rumblingrows,trains}) do
      for obj in all(grp) do
        obj.draw(obj)
      end
    end
    rectfill(0,0,128,8,1)
    centertxt("clixel presents",2,12)
    if (t%6==0) then
      -- rotate shadow colors
      local foo=deli(titleshadowclr,1)
      add(titleshadowclr,foo)
    end
    pal(13,titleshadowclr[1])
    spr(64,19,24,12,1)
    pal(13,titleshadowclr[2])
    spr(64,19,23,12,1)
    pal(13,10)
    spr(64,19,22,12,1)
    pal()
    centertxt("🅾️ start game",42,1)
    centertxt("hi-score:"..pad(hiscore.."0",6),113,1,2)
    centertxt("hi-score:"..pad(hiscore.."0",6),114,9)

  elseif mode=="game" then

    for grp in all({bullets,enemies,gremlins,supply,balloon,explosions,rumblingrows,trains}) do
      for obj in all(grp) do
        obj.draw(obj)
      end
    end
    p.draw()
    status_bar()

  elseif mode=="bonus" then

    for grp in all({explosions,rumblingrows,trains}) do
      for obj in all(grp) do
        obj.draw(obj)
      end
    end
    status_bar()
    print("level "..level.." complete",32,28,1)
    if bonuscheck.y<16 and t%30<15 then
      print("bonus points",40,42,1)
    end

  elseif mode=="game over" then

    for grp in all({enemies,gremlins,supply,balloon,explosions,rumblingrows,trains}) do
      for obj in all(grp) do
        obj.draw(obj)
      end
    end
    rectfill(0,0,128,8,1)
    centertxt("score:"..p.score.."0",2,9)
    centertxt("game  over",28,1)
    centertxt("🅾️ restart",42,1)
  end

end
