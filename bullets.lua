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
    -- check for collisions with enemies
    for grp in all({enemies,gremlins}) do
      for obj in all(grp) do
        if (coll(this,obj)) then
          if obj.mode=="egg" then
            p.score+=5
          elseif obj.mode=="gremlin" then
            p.score+=9
          else
            p.score+=2
          end
          enemieskilled+=1
          obj.die(obj)
          del(bullets,this)
          check_level()
        end
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
    this.x += this.dx
    this.y += this.dy

    -- offstage?
    if (is_offstage(this, 20)) del(bullets, this)
  end

  -- draw loop
  obj.draw=function(this)
    line(this.x-obj.dx,this.y-obj.dy,this.x,this.y,1)
  end

  --return the bullet
  return obj
end

function new_man_bullet(x,y,dx,dy)
  local obj = {x=x,y=y,len=1}
  obj.box = {x1=-2,y1=-2,x2=2,y2=2} --collision box
  obj.dx=dx*obj.len*2
  obj.dy=dy*obj.len*2
  obj.dx=minspeed(obj.dx,obj.len*2)
  obj.dy=minspeed(obj.dy,obj.len*2)
  if obj.dx==0 and obj.dy==0 then
    if p.flipx then obj.dx=-2 else obj.dx=2 end
  end

  -- update loop
  obj.update=function(this)
    -- check for collisions with enemies
    for grp in all({gremlins}) do
      for obj in all(grp) do
        if (coll(this,obj)) then
          p.score+=9
          enemieskilled+=1
          obj.die(obj)
          del(bullets,this)
          check_level()
        end
      end
    end

    -- trains stop bullets
    for grp in all({trains}) do
      for obj in all(grp) do
        if (coll(this,obj)) then
          del(bullets,this)
        end
      end
    end


    --move the bullet
    this.x += this.dx
    this.y += this.dy

    -- constrain bullets to subway
    local msprite=getmapsprite(this.x,this.y)
    if not fget(msprite,3) then
      del(bullets,this)
    end
  end

  -- draw loop
  obj.draw=function(this)
    line(this.x-obj.dx,this.y-obj.dy,this.x,this.y,7)
  end

  --return the bullet
  return obj
end
