-- supply functions

-- spawn supply in update function
function check_supply_spawn()
  if (#supply<1 and #balloon<1 and t%3==0 and rnd()>0.99) add(supply,new_supply())
end
function check_train_spawn()
  if (#trains<1 and t%3==0 and rnd()>0.9) add(trains,new_train())
end
function check_balloon_spawn(obj)
  if (not obj.has_deployed and rnd()>0.97) add(balloon,new_balloon(obj))
end

-- new balloon!
function new_balloon(supply)
  supply.has_deployed=true
  local obj={x=supply.x,y=supply.y,dx=supply.dx,dy=1,sprite=37,t=0}
  obj.box={x1=0,y1=3,x2=8,y2=8}
  sfx(09)

  obj.update=function(this)
    obj.t+=1
    -- hitting player?
    if (coll(this,p)) then
      sfx(10)
      p.resupply()
      balloon={}
    end

    -- check for collisions with enemies
    for grp in all({enemies,gremlins}) do
      for obj in all(grp) do
        if (coll(this,obj)) then
          obj.die(obj)
          this.die(this)
        end
      end
    end

    -- parachute open?
    if obj.t < 20 then
      if t%4<2 then this.sprite=37 else this.sprite=38 end
    else
      this.dx=0
      this.dy=0.5
      if t%4<2 then this.sprite=39 else this.sprite=40 end
    end

    -- check for collisions with building
    check_building_hit(this,balloon)

    -- bottom of stage? pop balloon
    if (this.y>112) this.die(this)

    --move it
    this.x += this.dx
    this.y += this.dy

    -- offscreen?
    if (this.x<-10 or this.x>138 or this.y>138) del(balloon,this)
  end

  obj.draw=function(this)
    spr(this.sprite,this.x,this.y)
  end

  --bye bye
  obj.die=function(this)
    sfx(02)
    new_explosion(this.x,this.y)
    del(balloon,this)
  end

  --return the supply
  return obj
end

-- new supply!
function new_supply()
  local obj={x=0,y=15,dx=1,dy=0,sprite=35,flipx=false,t=0,has_deployed=false}
  -- which side of screen to spawn from?
  if rnd(1)>0.35 then
    obj.x=128
    obj.dx=-1
  end
  obj.box={x1=0,y1=2,x2=9,y2=9}

  obj.update=function(this)
    this.t+=1
    -- hitting player?
    if (p.dying==0 and coll(this,p)) then
      p.die()
      this.die(this)
    end

    -- check for collisions with enemies
    for grp in all({enemies,gremlins}) do
      for obj in all(grp) do
        if (coll(this,obj)) then
          obj.die(obj)
          this.die(this)
        end
      end
    end

    -- animate jet
    if t%4<2 then this.sprite=35 else this.sprite=36 end

    --move it!
    if this.has_deployed then this.x += this.dx * 2 else this.x += this.dx end
    this.y += this.dy

    -- flip sprite based on direction
    this.flipx=this.dx>0

    -- emit balloon?
    -- check position across screen
    if this.dx<1 then screen_pos=this.x/128 else screen_pos=(128-this.x)/128 end
    if (screen_pos>0.2 and screen_pos<0.8) check_balloon_spawn(this)

    -- offscreen?
    if (is_offstage(this,10)) del(supply,this)
  end

  obj.draw=function(this)
    spr(this.sprite,this.x,this.y,1,1,this.flipx)
  end

  obj.die=function(this)
    sfx(02)
    new_explosion(this.x,this.y)
    del(supply,this)
  end

  --return the supply
  return obj
end

-- new train!
function new_train()
  local obj={x=-24,y=119,dx=1,dy=0,sprite=55,t=0,express=false}
  -- which side of screen to spawn from?
  if rnd()>0.3 then
    obj.x=130
    obj.dx=-1
  end
  if (rnd()>0.8) obj.express=true
  obj.box={x1=0,y1=2,x2=15,y2=8}

  obj.update=function(this)
    this.t+=1
    -- hitting player?
    if (p.dying==0 and coll(this,p)) then
      p.die()
    end

    --move it!
    if this.express then this.x+=this.dx*2 else this.x+=this.dx end
    this.y += this.dy

    -- offscreen?
    if (is_offstage(this,40)) del(trains,this)
  end

  obj.draw=function(this)
    -- draw train cars
    local offset=-8
    if (this.dx<0) offset=8
    -- make red if express
    if (this.express) pal(9,8)
    spr(this.sprite,this.x,this.y)
    spr(this.sprite,this.x+offset,this.y,1,1,true)
    spr(this.sprite,this.x+offset*2,this.y,1,1,true)
    if (this.express) pal(9,9)
  end

  return obj
end
