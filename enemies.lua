-- enemies functions

-- spawn enemies in update function
function check_enemy_spawn(max)
  if (#enemies<max and rnd(100) > 95) add(enemies, new_enemy(rnd(128), -10))
end

-- new explosion
function new_explosion(x,y)
  local obj={x=x,y=y,t=10,sprite=32}
  obj.update=function(this)
    this.t-=1
    if t%3==0 then this.sprite=32 else this.sprite=33 end
    if (this.t==0) del(explosions, this)
  end
  obj.draw=function(this)
    spr(this.sprite,this.x,this.y)
  end
  add(explosions, obj)
end

-- construct new enemy
function new_enemy(x,y)
  local obj={x=x, y=y, dx=0, dy=0.5, sprite=16, t=0, drg=0.9}
  obj.box={x1=0,y1=2,x2=8,y2=8}

  obj.update=function(this)
    -- hitting player?
    if p.dying==0 and coll(this,p) then
      p.die()
      this.die(this)
    end

    -- hitting supply?
    foreach(supply, function(obj)
      if coll(this,obj) then
        obj.die(obj)
        this.die(this)
      end
    end)

    if t%4==0 then this.sprite=16 else this.sprite=17 end

    --herky jerk
    if (rnd() > 0.97) this.dx = (rnd(4) - 2.5)/3.5
    if (rnd() > 0.98) this.dy = (rnd(2) - 1)/3.5

    --move it
    this.x += this.dx
    this.y += this.dy

    -- if (abs(this.dx)>0) this.dx*=this.drg
    -- if (abs(this.dy)>0) this.dy*=this.drg

    -- bounce from top
    if (this.y < -10) then
      this.dy = 1
      this.y = -10
    end

    -- offscreen?
    if (this.x < -10 or this.x > 138) del(enemies, this)
  end

  obj.draw = function(this)
    spr(this.sprite, this.x, this.y)
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
