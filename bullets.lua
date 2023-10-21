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

    -- check for collisions with building
    check_building_hit(this)

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

function check_building_hit(obj)
  local nx_l=obj.x+obj.dx+obj.box.x1
  local nx_r=obj.x+obj.dx+obj.box.x2
  local ny_t=obj.y+obj.dy+obj.box.y1
  local ny_b=obj.y+obj.dy+obj.box.y2
  chk_bldg(nx_l,ny_t,obj)
  chk_bldg(nx_l,ny_b,obj)
  chk_bldg(nx_r,ny_t,obj)
  chk_bldg(nx_r,ny_b,obj)
end
function chk_bldg(x,y,o)
  local map_x=flr(x/8)
  local map_y=flr(y/8)
  local map_sprite=mget(map_x,map_y)
  if (fget(map_sprite,1) and not fget(map_sprite,2)) then
    del(bullets, o)
    mset(map_x,map_y,8)
    fset(map_x,map_y,2,true)
  end
end

function player_fire()
  if btnp(4, 0) then
    if (abs(p.dx)+abs(p.dy) != 0) then
      sfx(00)
      add(bullets, new_bullet(p.x+3, p.y+4, p.dx, p.dy))
    end
  end
end