-- supply functions

-- spawn supply in update function
function check_supply_spawn()
  if (#supply<1 and #balloon<1 and rnd(100) > 98) add(supply, new_supply())
end
function check_balloon_spawn(obj)
  if (not obj.has_deployed and rnd(100) > 97) add(balloon, new_balloon(obj))
end

---------------
-- new balloon!
function new_balloon(supply)
  supply.has_deployed=true
  local obj = {x=supply.x, y=supply.y, dx=supply.dx, dy=1, sprite=37, t=0}
  obj.box = {x1=0,y1=3,x2=8,y2=8}
  sfx(09)

  obj.update=function(this)
    obj.t+=1
    -- hitting player?
    if (coll(this,p)) then
      sfx(10)
      p.resupply()
      balloon={}
    end

    -- parachute open?
    if obj.t < 20 then
      if t%5==0 then this.sprite=37 else this.sprite=38 end
    else
      this.dx = 0
      this.dy = 0.5
      if t%5==0 then this.sprite=39 else this.sprite=40 end
    end

    -- check for collisions with building
    check_building_hit(this, balloon)

    --move it
    this.x += this.dx
    this.y += this.dy

    -- offscreen?
    if (this.x < -10 or this.x > 138 or this.y > 138) del(balloon, this)
  end

  obj.draw=function(this)
    spr(this.sprite, this.x, this.y)
  end

  --bye bye
  obj.die=function(this)
    sfx(02)
    sfx(03)
    new_explosion(this.x,this.y)
    del(balloon, this)
  end

  --return the supply
  return obj
end

---------------
-- new supply!
function new_supply()
  local obj = {x=0, y=15, dx=1, dy=0, sprite=35, flipx=false, t=0, has_deployed=false}
  -- which side of screen to spawn from?
  if rnd(1)>0.5 then
    obj.x=128
    obj.dx=-1
  end
  obj.box = {x1=0,y1=3,x2=7,y2=7}

  obj.update = function(this)
    this.t+=1
    -- hitting player?
    if (p.dying==0 and coll(this,p)) then
      p.die()
      this.die(this)
    end

    -- animate jet
    if t%5==0 then this.sprite=35 else this.sprite=36 end

    --move it!
    if this.has_deployed then this.x += this.dx * 2 else this.x += this.dx end
    this.y += this.dy

    -- flip sprite based on direction
    this.flipx = this.dx>0

    -- emit balloon?
    -- check position across screen
    if this.dx<1 then screen_pos=this.x/128 else screen_pos = (128-this.x)/128 end
    if (screen_pos > .2 and screen_pos < .8) check_balloon_spawn(this)

    -- offscreen?
    if (this.x < -10 or this.x > 138) del(supply, this)
  end

  obj.draw = function(this)
    spr(this.sprite, this.x, this.y, 1, 1, this.flipx)
  end

  --bye bye
  obj.die = function(this)
    sfx(02)
    sfx(03)
    new_explosion(this.x,this.y)
    del(supply, this)
  end

  --return the supply
  return obj
end
