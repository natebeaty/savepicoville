-- enemies

-- spawn enemies in update function
check_enemy_spawn = function()
  if (count(enemies)<2 and rnd(100) > 95) add(enemies, new_enemy(rnd(128), -10))
end

-- construct new enemy
new_enemy = function(x, y)
  local obj = {x=x, y=y, dx=0, dy=0.5, sprite=16, t=0}
  obj.box = {x1=0,y1=3,x2=7,y2=7}

  obj.update = function(this)
    this.t+=1
    if (this.t>5) then
      this.sprite+=1
      this.t=0
    end
    if (this.sprite)>17 this.sprite=16

    if (rnd(100) > 97) this.dx = (rnd(5) - 2.5)/2
    if (rnd(100) > 97) this.dy = (rnd(3) - 1.5)/2
    --move the enemy
    this.x += this.dx
    this.y += this.dy
    if (this.y < -10) then
      this.dy = 0.5
      this.y = -10
    end
    -- offscreen?
    if (this.x < -10 or this.x > 138) del(enemies, this)
  end

  obj.draw = function(this)
    spr(this.sprite, this.x, this.y)
  end

  --bye bye
  obj.die = function(this)
    del(enemies, this)
  end

  --return the enemy
  return obj
end
