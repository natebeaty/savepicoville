-- enemies functions

-- spawn enemies in update function
function check_enemy_spawn(max)
  if (#enemies<max and rnd()>0.95) add(enemies,new_enemy(rnd(128),0))
end

-- new explosion
function new_explosion(x,y)
  local obj={x=x,y=y,t=10,sprite=32,debris={}}
  for i=1,5 do
    add(obj.debris,{x=x,y=y,dx=rnd(4)-2,dy=rnd(4)-2})
  end

  obj.update=function(this)
    this.t-=1
    if t%3==0 then this.sprite=32 else this.sprite=33 end
    for d in all(this.debris) do
      d.x+=d.dx
      d.y+=d.dy
    end
    if (this.t==0) del(explosions,this)
  end
  obj.draw=function(this)
    if (obj.t>8) spr(this.sprite,this.x,this.y)
    for d in all(this.debris) do
      pset(d.x,d.y,rnd(16))
    end
  end
  add(explosions,obj)
end

-- construct new enemy
function new_enemy(x,y)
  local obj={x=x,y=y,dx=0,dy=0.5,sprite=16,t=0}
  obj.box={x1=0,y1=2,x2=8,y2=8}

  obj.update=function(this)
    this.t+=1

    -- hitting player?
    if p.dying==0 and coll(this,p) then
      p.die()
      this.die(this)
    end

    -- hitting supply?
    foreach(supply,function(obj)
      if coll(this,obj) then
        obj.die(obj)
        this.die(this)
      end
    end)

    if t%4==0 then this.sprite=16 else this.sprite=17 end

    --herky jerk
    if this.t%3 and rnd()>0.95 then
      this.dx = (rnd(3)-1)*enemyspeed*0.25
      this.dy = (rnd(3)-1)*enemyspeed*0.25
    end

    --move it
    this.x += this.dx
    this.y += this.dy

    -- bounce from vertical edge
    if (this.y<-1 or this.y>110) then
      this.dy=-this.dy
    end
    -- delete if offstage horizontally
    if (this.x<-10 or this.x>138) then
      del(enemies,this)
    end

    -- offscreen?
    if (this.x < -10 or this.x > 138) del(enemies,this)
  end

  obj.draw = function(this)
    spr(this.sprite,this.x,this.y)
  end

  --bye bye
  obj.die=function(this)
    sfx(02)
    sfx(03)
    new_explosion(this.x,this.y)
    del(enemies,this)
  end

  --return the enemy
  return obj
end
