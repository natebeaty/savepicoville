--bullets functions

function new_bullet(x,y,dx,dy)
  local obj = {x=x,y=y,len=3}
  obj.box = {x1=-2,y1=-2,x2=2,y2=2} --collision box
  obj.dx=dx*obj.len*2
  obj.dy=dy*obj.len*2
  obj.dx=minspeed(obj.dx,obj.len*2)
  obj.dy=minspeed(obj.dy,obj.len*2)

  -- update loop
  obj.update=function(this)
    -- check for collisions with enemy
    for obj in all(enemies) do
      if (coll(this,obj)) then
        p.score+=2
        enemies_killed+=1
        obj.die(obj)
        del(bullets,this)
        check_level()
      end
    end
    -- check for collisions with supply
    for grp in all({supply,balloon}) do
      for obj in all(grp) do
        if (coll(this,obj)) then
          obj.die(obj)
          del(bullets,this)
        end
      end
    end

    -- check for collisions with building
    check_building_hit(this,bullets)

    --move the bullet
    this.x += obj.dx
    this.y += obj.dy
  end

  -- draw loop
  obj.draw=function(this)
    line(this.x-obj.dx,this.y-obj.dy,this.x,this.y,1)
  end

  --return the bullet
  return obj
end
