-- buildings

-- blink lights
function building_blink(chk)
  if t%chk==0 then
    -- blink undamaged building lights
    for i=1,#buildings do
      for h=1,buildings[i].height do
        for w=1,buildings[i].width do
          local mx=buildings[i].x+w
          local my=14-buildings[i].height+h
          local map_sprite=mget(mx,my)
          if (chk==1 or rnd()>0.98) and fget(map_sprite,1) and not fget(map_sprite,2) then
            mset(mx,my,flr(rnd(5))+1)
          end
        end
      end
    end
  end
end

-- create randomized buildings
function make_buildings()
  rumblingrows={}
  -- reset all building tiles to sky
  for x=0,16 do
    for y=0,14 do
      mset(x,y,8)
    end
  end

  -- reset peopleleft
  peopleleft=0

  -- generate random buildings
  buildings={}
  lastx=1
  for i=1,4 do
    building={
      height=flr(rnd(6)+3),
      width=flr(rnd(2))+2,
      x=lastx
    }
    lastx=lastx+building.width+(flr(rnd(3)))
    for n=1,building.height do
      for x=1,building.width do
        mset(building.x+x,15-n,flr(rnd(5))+1)
      end
    end
    peopleleft+=building.height*building.width
    add(buildings,building)
  end
end

-- collision detection for building
function check_building_hit(obj,grp)
  local nx_l=obj.x+obj.dx+obj.box.x1
  local nx_r=obj.x+obj.dx+obj.box.x2
  local ny_t=obj.y+obj.dy+obj.box.y1
  local ny_b=obj.y+obj.dy+obj.box.y2
  local hit=is_undamaged_brick(nx_l,ny_t,obj,grp) or
    is_undamaged_brick(nx_l,ny_b,obj,grp) or
    is_undamaged_brick(nx_r,ny_t,obj,grp) or
    is_undamaged_brick(nx_r,ny_b,obj,grp)
  return hit
end

function is_undamaged_brick(x,y,obj,grp,keep)
  keep=keep or false
  local mx=flr(x/8)
  local my=flr(y/8)
  local map_sprite=mget(mx,my)
  local chk=fget(map_sprite,1) and not fget(map_sprite,2)
  -- make player
  if (grp=="player" or grp==balloon) chk=fget(map_sprite,1)
  if chk then
    if not keep then
      -- remove object hitting building
      if grp=="player" then p.die()
      else del(grp,obj) end
      sfx(1)
      new_explosion(mx*8,my*8)
      damage_brick(mx,my)
    end
    return {mx=mx,my=my}
  end
  return false
end

function damage_brick(mx,my)
  local chk=false
  -- sanity check if brick is undamaged (e.g. enemy was chomping when it crumbled)
  local map_sprite=mget(mx,my)
  if fget(map_sprite,1) and not fget(map_sprite,2) then
    -- set random damaged sprite
    mset(mx,my,6+flr(rnd(2)))
    -- check building rows for collapse
    chk=check_building_collapse()
  end
  return chk
end

-- check for any building rows with all damage
function check_building_collapse()
  local chk=false
  for building in all(buildings) do
    for i=1,building.height do
      rowbusted=true
      for j=1,building.width do
        local map_sprite=mget(building.x+j,14-building.height+i)
        -- any undamaged pieces? row is not busted
        if not fget(map_sprite,2) then
          rowbusted=false
        end
      end
      if rowbusted then
        chk=true
        -- collapsing rubble
        add(buildingcrash,{building=building,rowbusted=i})
      end
    end
  end
  return chk
end

-- row to collapse
function new_rumblingrow(x,y,delay)
  local obj={x=x,y=y,delay=delay,t=0}
  obj.update=function(this)
    this.t+=1
    if (this.t > this.delay+15) del(rumblingrows,this)
  end
  obj.draw=function(this)
    local sprite=24
    if (this.t>this.delay+10) then
      if this.t%3<2 then sprite=28 else sprite=29 end
    elseif (this.t>this.delay+5) then
      if this.t%3<2 then sprite=26 else sprite=27 end
    else
      if this.t%3<2 then sprite=24 else sprite=25 end
    end
    -- screen_shake(0.005)
    pset(this.x+rnd(10)-1,this.y+rnd(10)-1,1)
    pset(this.x+rnd(10)-1,this.y+rnd(10)-1,10)
    spr(sprite,this.x,this.y)
  end
  return obj
end

-- building update loop
function building_update()
  if #buildingcrash>0 then
    for obj in all(buildingcrash) do
      for i=1,obj.rowbusted do
        sfx(11)
        for j=1,obj.building.width do
          local mx=obj.building.x+j
          local my=14-obj.building.height+i
          mset(mx,my,8)
          add(rumblingrows,new_rumblingrow(mx*8,my*8,i*10))
        end
        -- any undamaged brick left?
        peopleleft-=obj.building.width
      end
      -- shorten building height
      obj.building.height-=obj.rowbusted
    end
    -- you killed picoville!
    if (peopleleft<=0) game_over()
    buildingcrash={}
  end
end