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

--text with bg
function bgtxt(str,x,y,clr,bg)
  rectfill(x-2,y-1,x+#str*4,y+5,bg)
  print(str,x,y,clr)
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
  camy=0
  level=1
  titlesel=1
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
  --blink fuel if low (and game isn't over)
  print("fuel:"..flr(p.fuel),4,2,(mode=="game" and t%40<20 and p.fuel<p.lowfuel and 7 or 9))
  print("score:"..p.score.."0",48,2,9)
  for i=1,p.life do
    spr(56,124-i*6,0)
  end
end

function check_level()
  --currently super basic difficulty ramp based on original game
  if enemieskilled>=(level==1 and 10 or 16) then
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
  mode="game"
  empty_stage()
  music(-1)
  sfx(05)
end

function about_page()
  mode="about"
  t=0
  camy=0
  cama=1
  --initial set of clouds
  clouds={
    {spr=128,x=50,y=-10,dx=0.7},
    {spr=128,x=-50,y=6,dx=0.35},
    {spr=166,x=50,y=24,dx=-0.3},
    {spr=166,x=-50,y=34,dx=0.5}
  }
  --randoclouds
  for i=1,5 do
    add(clouds,new_cloud())
  end
  userscrolled=false
end

function new_cloud()
  local x=rnd()>0.5 and -100 or 130
  local spd=(rnd(5)+1)/10
  return {
    spr=rnd()>0.5 and 128 or 166,
    x=x,
    y=-5+8*rnd(6),
    dx=rnd()>0.5 and -spd or spd
  }
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
  make_buildings(mode=="title" and 3 or nil)
end

function restart()
  t=0
  titlesel=1
  enemieskilled=0
  p.reset()
  mode="title"
  empty_stage()
  music(0,2500)
end

function _update()
  t+=1
  building_update()

  if mode=="about" then
    --clouds
    for cloud in all(clouds) do
      cloud.x+=cloud.dx
      if (cloud.dx<0 and cloud.x<-130) or (cloud.dx>0 and cloud.x>130) then
        del(clouds,cloud)
        add(clouds,new_cloud())
      end
    end

    --autoscroll if user hasn't scrolled manually
    if not userscrolled and t>60 then
      camy+=1
    end

    --arrow keys scroll up + down with inertia
    if btn(2) or btn(3) then
      userscrolled=true
      cama+=1
      if btn(2) then
        camy-=1*cama
      else
        camy+=1*cama
      end
    else
      cama=1
    end

    camy=mid(0,camy,128)

    --action button goes to title
    if t>5 and (btnp(4) or btnp(5)) then
      sfx(18)
      camera()
      t=0
      titlesel=1
      mode="title"
    end
  end

  if mode=="title" then

    building_blink(4)
    check_enemy_spawn(5)
    check_train_spawn()
    for grp in all({enemies,gremlins,rumblingrows,trains}) do
      for obj in all(grp) do
        obj:update()
      end
    end
    --either action button runs selected menu item
    if t>5 and (btnp(4) or btnp(5)) then
      sfx(18)
      if (titlesel==1) start_game()
      if (titlesel==2) then
        about_page()
      end
    end
    --up/down changes menu item
    if t>5 and (btnp(2) or btnp(3)) then
      sfx(17)
      titlesel=(titlesel==1 and 2 or 1)
    end

  elseif mode=="bonus" then

    for grp in all({explosions,rumblingrows,trains}) do
      for obj in all(grp) do
        obj:update()
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
      if (t>10 and (btnp(4) or btnp(5))) then
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
        obj:update()
      end
    end

  elseif mode=="game over" then

    building_blink(1)
    for grp in all({enemies,gremlins,supply,balloon,explosions,rumblingrows,trains}) do
      for obj in all(grp) do
        obj:update()
      end
    end
    if (t>10 and (btnp(4) or btnp(5))) then
      sfx(18)
      restart()
    end

  end
end

-- draw!
function _draw()
  cls()
  --draw the stage including generated buildings
  map(0,0,0,0,128,32)

  if mode=="about" then
    cls(12)

    --clouds
    for cloud in all(clouds) do
      --different sprite widths for clouds
      local w=cloud.spr==128 and 12 or 10
      spr(cloud.spr,cloud.x,cloud.y,w,2)
    end

    --print title gfx
    ?introgfx,0,0
    ?titlegfx,5,1
    pal(7,1)
    spr(73,50,120,4,1)
    fillp(▤)
    circfill(44,122,2,1)
    circfill(82,122,2,1)
    fillp()
    pal()

    --bottom bg
    rectfill(0,128,128,256,13)
    --borders
    rectfill(0,128,128,156,1)
    rectfill(0,128,10,256,1)
    rectfill(118,128,128,256,1)
    rectfill(0,242,128,256,1)
    --rounded corners
    pset(11,157,1)
    pset(117,157,1)
    pset(11,241,1)
    pset(117,241,1)

    --glow eyes
    if t%5>2 and t%8<3 then
      spr(69,40,48,2,2)
      spr(71,64,48,2,2)
      pset()
    elseif t%8>3 and t%8<7 then
      spr(101,40,48,2,2)
      spr(103,64,48,2,2)
    end

    centertxt("oh no! picoville is under",133,9)
    centertxt("attack! fight back the mutants",140,9)
    centertxt("and save the townspeople",147,9)

    spr(t%10<5 and 16 or 17,37,160)
    print("20 points",52,162,7)

    spr(34,37,170,1,1,t%10<5 and true or false)
    print("50 points",52,172,7)

    pal(13,5)
    spr(t%10<5 and 53 or 54,37,180)
    print("90 points",52,182,7)
    pal(13,13)

    spr(t%10<5 and 39 or 40,37,190)
    print("400 fuel",52,192,7)

    spr(56,37,200)
    print("every 1000",52,202,7)

    spr(01,37,211)
    print("10 points",52,212,7)
    print("each round",52,219,7)

    --pan down
    camera(0,camy)
    centertxt("back to title",231,7,1)
    centertxt("nate beaty 2023",247,9)
  end

  if mode=="title" then

    for grp in all({enemies,gremlins,rumblingrows,trains}) do
      for obj in all(grp) do
        obj:draw()
      end
    end
    rectfill(0,0,128,8,1)
    pal(7,12)
    spr(73,32,2,4,1)
    pal()
    print("presents",65,2,12)
    ?titlegfx,7,12
    bgtxt("play",73,51,7,(titlesel==1 and 1 or 12))
    bgtxt("about",71,59,7,(titlesel==2 and 1 or 12))
    --hi-score with shadow
    centertxt("hi-score:"..pad(hiscore.."0",6),113,1,2)
    centertxt("hi-score:"..pad(hiscore.."0",6),114,9)

  elseif mode=="game" then

    for grp in all({bullets,enemies,gremlins,supply,balloon,explosions,rumblingrows,trains}) do
      for obj in all(grp) do
        obj:draw()
      end
    end
    p.draw()
    status_bar()

  elseif mode=="bonus" then

    for grp in all({explosions,rumblingrows,trains}) do
      for obj in all(grp) do
        obj:draw()
      end
    end
    status_bar()
    print("level "..level.." complete",32,28,1)
    if bonuscheck.y<16 and t%30<15 then
      print("bonus points",40,38,1)
    end

  elseif mode=="game over" then

    for grp in all({enemies,gremlins,supply,balloon,explosions,rumblingrows,trains}) do
      for obj in all(grp) do
        obj:draw()
      end
    end
    rectfill(0,0,128,8,1)
    centertxt("score:"..p.score.."0",2,9)
    spr(64,45,18,5,4)
    centertxt("restart",52,7,1)
  end

end
