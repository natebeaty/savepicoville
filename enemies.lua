-- enemies

-- spawn enemies in update function
function check_enemy_spawn(max)
  if (count(enemies)<max and rnd(100) > 95) add(enemies, new_enemy(rnd(128), -10))
end

-- construct new enemy
function new_enemy(x, y)
  local obj = {x=x, y=y, dx=0, dy=0.5, sprite=16, t=0, dying=0}
  obj.box = {x1=0,y1=3,x2=7,y2=7}

  obj.update = function(this)
    -- hitting player?
    if (this.dying==0 and p.dying==0 and coll(this,p)) then
      p.die()
      this.die(this)
    end

    if (this.dying>0) then
      this.dying-=1
      if t%3==0 then this.sprite=32 else this.sprite=33 end
      if this.dying==0 then
        del(enemies, this)
      end
    else
      if t%5==0 then this.sprite=16 else this.sprite=17 end

      --herky jerk
      if (rnd(100) > 97) this.dx = (rnd(5) - 2.5)/2
      if (rnd(100) > 98) this.dy = (rnd(3) - 1)/2
      --move it
      this.x += this.dx
      this.y += this.dy
      -- bounce from top
      if (this.y < -10) then
        this.dy = 1
        this.y = -10
      end
      -- offscreen?
      if (this.x < -10 or this.x > 138) del(enemies, this)
    end
  end

  obj.draw = function(this)
    spr(this.sprite, this.x, this.y)
  end

  --bye bye
  obj.die = function(this)
    sfx(02)
    sfx(03)
    this.dx = 0
    this.dy = 0
    this.dying=10
  end

  --return the enemy
  return obj
end
