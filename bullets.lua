--bullets functions

function new_bullet(x,y,dx,dy)
  local obj = {
    x=x,
    y=y,
    len=3
  }
  --collision box
  obj.box = {x1=0,y1=0,x2=obj.len,y2=obj.len}
  -- bullet direction
  obj.dx=dx*obj.len*2
  obj.dy=dy*obj.len*2

  -- update loop
  obj.update = function(this)
    -- check for collisions with enemy
    foreach(enemies, function(obj)
      if (obj.dying==0 and coll(this,obj)) then
        p.score+=1
        obj.die(obj)
        del(bullets, this)
      end
    end)
    -- check for collisions with supply
    foreach(supply, function(obj)
      if (obj.dying==0 and coll(this,obj)) then
        obj.die(obj)
        del(bullets, this)
      end
    end)

    -- check for collisions with building
    check_building_hit(this,bullets)

    --move the bullet
    this.x += obj.dx
    this.y += obj.dy
  end

  -- draw loop
  obj.draw = function(this)
    line(this.x-obj.dx, this.y-obj.dy, this.x, this.y, 1)
  end

  --return the bullet
  return obj
end

function check_building_hit(obj,grp)
  local nx_l=obj.x+obj.dx+obj.box.x1
  local nx_r=obj.x+obj.dx+obj.box.x2
  local ny_t=obj.y+obj.dy+obj.box.y1
  local ny_b=obj.y+obj.dy+obj.box.y2
  local foo = chk_bldg(nx_l,ny_t,obj,grp) or
    chk_bldg(nx_l,ny_b,obj,grp) or
    chk_bldg(nx_r,ny_t,obj,grp) or
    chk_bldg(nx_r,ny_b,obj,grp)
end
function chk_bldg(x,y,obj,grp)
  local map_x=flr(x/8)
  local map_y=flr(y/8)
  local map_sprite=mget(map_x,map_y)
  if (fget(map_sprite,1) and not fget(map_sprite,2)) then
    del(grp,obj)
    sfx(1)
    new_explosion(map_x*8,map_y*8)
    mset(map_x,map_y,6+flr(rnd(2)))
    fset(map_x,map_y,2,true)
    return true
  end
  return false
end

function player_fire()
  if btnp(4, 0) then
    if (abs(p.dx)+abs(p.dy) != 0) then
      sfx(00)
      add(bullets, new_bullet(p.x+3, p.y+4, p.dx, p.dy))
    end
  end
end