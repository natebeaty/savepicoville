-- bullets

new_bullet = function(x,y,dx,dy)
  local obj = {
    x=x,
    y=y,
    len=4
  }
  --collision box
  obj.box = {x1=0,y1=0,x2=obj.len,y2=obj.len}
  -- bullet direction
  obj.dx=dx*obj.len
  obj.dy=dy*obj.len

  obj.update = function(this)
    -- check for collisions with enemy
    foreach(enemies, function(obj)
      if (obj.dying==0 and coll(this,obj)) then
        p.score+=1
        obj.die(obj)
        del(bullets, this)
      end
    end)
    --move the bullet
    this.x += obj.dx * obj.len/1.5
    this.y += obj.dy * obj.len/1.5
  end

  obj.draw = function(this)
    line(this.x-obj.dx, this.y-obj.dy, this.x+obj.dx*obj.len, this.y+obj.dy*obj.len, 1)
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