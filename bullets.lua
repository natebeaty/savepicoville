--bullets functions

function new_bullet(x,y,dx,dy)
  local obj = {
    x=x,
    y=y,
    len=3
  }
  --collision box
  obj.box = {x1=0,y1=0,x2=2,y2=2}
  -- bullet direction
  obj.dx=dx*obj.len*2
  obj.dy=dy*obj.len*2

  -- update loop
  obj.update = function(this)
    -- check for collisions with enemy
    foreach(enemies, function(obj)
      if (obj.dying==0 and coll(this,obj)) then
        p.score+=10
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

function player_fire()
  if btnp(4, 0) then
    if (abs(p.dx)+abs(p.dy) != 0) then
      sfx(00)
      add(bullets, new_bullet(p.x+3, p.y+4, p.dx, p.dy))
    end
  end
end