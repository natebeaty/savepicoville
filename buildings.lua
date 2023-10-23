-- buildings

function building_update(chk)
  if t%chk==0 then
    -- blink undamaged building lights
    for i=1,#buildings do
      for h=1,buildings[i].height do
        for w=1,buildings[i].width do
          local map_x=buildings[i].x+w
          local map_y=14-buildings[i].height+h
          local map_sprite=mget(map_x,map_y)
          if (chk==1 or rnd()>0.98) and fget(map_sprite,1) and not fget(map_sprite,2) then
            mset(map_x, map_y, flr(rnd(5))+1)
          end
        end
      end
    end
  end
end

-- create randomized buildings
function make_buildings()
  -- reset to blue
  for x=0,16 do
    for y=0,14 do
      mset(x,y,8)
    end
  end

  -- generate random buildings
  buildings={}
  lastx=1
  for i=0,3 do
    building={
      height=flr(rnd(5)+3),
      width=flr(rnd(2))+2,
      x=lastx
    }
    lastx=lastx+building.width+(flr(rnd(3)))
    for n=1,building.height do
      for x=1,building.width do
        mset(building.x+x, 15-n, flr(rnd(5))+1)
      end
    end
    add(buildings, building)
  end
end

-- collision detection for building
function check_building_hit(obj,grp)
  local nx_l=obj.x+obj.dx+obj.box.x1
  local nx_r=obj.x+obj.dx+obj.box.x2
  local ny_t=obj.y+obj.dy+obj.box.y1
  local ny_b=obj.y+obj.dy+obj.box.y2
  -- set variable so we can use "or"
  local foo = is_undamaged_building(nx_l,ny_t,obj,grp) or
    is_undamaged_building(nx_l,ny_b,obj,grp) or
    is_undamaged_building(nx_r,ny_t,obj,grp) or
    is_undamaged_building(nx_r,ny_b,obj,grp)
end

function is_undamaged_building(x,y,obj,grp)
  local map_x=flr(x/8)
  local map_y=flr(y/8)
  local map_sprite=mget(map_x,map_y)
  if fget(map_sprite,1) and not fget(map_sprite,2) then
    -- remove object hitting building
    del(grp,obj)
    sfx(1)
    new_explosion(map_x*8,map_y*8)
    -- set random building damaged sprite
    mset(map_x,map_y,6+flr(rnd(2)))
    -- check building rows for collapse
    check_building_collapse()
    return true
  end
  return false
end

-- check for any building rows with all damage
function check_building_collapse()
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
        add(buildingcrash, {building=building,rowbusted=i})
      end
    end
  end
end

function new_rumblingrow(x,y,delay)
  local obj={x=x,y=y,delay=delay,t=0}
  obj.update=function(this)
    this.t+=1
    if (this.t > this.delay+15) del(rumblingrows, this)
  end
  obj.draw=function(this)
    local sprite=24
    if (this.t > this.delay+10) then
      if this.t%3==0 then sprite=28 else sprite=29 end
    elseif (this.t > this.delay+5) then
      if this.t%3==0 then sprite=26 else sprite=27 end
    else
      if this.t%3==0 then sprite=24 else sprite=25 end
    end
    spr(sprite,this.x,this.y)
  end
  return obj
end
