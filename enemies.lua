-- enemies functions

-- spawn enemies?
function check_enemy_spawn(max)
  if (#enemies<max and rnd()>0.95) add(enemies,new_enemy(rnd(128),0))
end

-- spawn gremlins?
function check_gremlin_spawn(obj,max)
  if obj.x>15 and obj.y>30 and obj.y<90 and obj.x<120 then
    if #gremlins<max and rnd()>0.95-level/1000 and not is_undamaged_brick(obj.x,obj.y,obj,"egg",true) then
      add(gremlins,new_gremlin(obj.x,obj.y))
    end
  end
end

-- construct new enemy
function new_enemy(x,y)
  local obj={x=x,y=y,dx=(rnd(3)-2)*0.75,dy=rnd(2)*0.75,sprite=16,t=0,mode="crab",chomp=0,chompcoords={}}
  obj.box={x1=-1,y1=1,x2=9,y2=9}

  obj.update=function(this)
    this.t+=1

    -- hitting player?
    if p.dying==0 and coll(this,p,-2) then
      p.die()
      this.die(this)
    end

    -- animate
    if this.t%4<2 then this.sprite=16 else this.sprite=17 end

    --herky jerk
    if this.t%10==0 and rnd()>0.95 then
      this.dx=(rnd(2)-1)*(enemyspeed*enemyspeed*49/10000+1)*0.75
      if this.y>50 then
        this.dy=(rnd(2)-1)*(enemyspeed*enemyspeed*49/10000+1)*0.75
      else
        this.dy=(rnd())*(enemyspeed*enemyspeed*49/10000+1)*0.75
      end
    end

    -- chomp?
    if this.t%8==0 and this.chomp==0 and flr(this.y+8)%8==0 and flr(this.x+8)%8==0 and rnd()>0.25 then
      local hit=is_undamaged_brick(this.x,this.y,this,enemies,true)
      if hit then
        this.chompcoords=hit
        this.chomp=70
      end
    end

    --move it unless chompin'
    if (this.chomp==0) then
      this.x+=this.dx
      this.y+=this.dy
      -- spawn gremlin egg?
      if (t%9==0) check_gremlin_spawn(this,max(0,flr(level/1.5)))
    else
      this.chomp-=1
      if this.chomp==0 then
        damage_brick(this.chompcoords.mx,this.chompcoords.my)
      end
    end

    -- bounce from vertical edge
    if (this.y<-1 or this.y>102) then
      this.dy=-this.dy
    end
    -- delete if offstage horizontally
    if (this.x<-10 or this.x>138) then
      del(enemies,this)
    end

    -- offscreen?
    if (this.x<-10 or this.x>138) del(enemies,this)
  end

  obj.draw=function(this)
    spr(this.sprite,this.x,this.y)
  end

  obj.die=function(this)
    sfx(02)
    sfx(03)
    new_explosion(this.x,this.y)
    del(enemies,this)
  end

  return obj
end

-- construct new gremlin
function new_gremlin(x,y)
  local obj={x=x,y=y,dx=0,dy=1,sprite=34,t=0,mode="egg",chomp=0,chompcoords={},bouncing=0}
  obj.box={x1=1,y1=1,x2=7,y2=7}

  obj.update=function(this)
    this.t+=1

    -- hitting player?
    if p.dying==0 and coll(this,p) then
      p.die()
      this.die(this)
    end

    -- animate egg or gremlin
    if this.mode=="egg" then
      if t%6<3 then this.flipx=true else this.flipx=false end
    elseif this.mode=="gremlin" then
      if t%6<3 then this.sprite=53 else this.sprite=54 end
    end

    --wandering gremlin
    if this.mode=="gremlin" then
      if this.t>10 and rnd()>0.98 then
        this.t=0
        this.dx=(rnd(2)-1)*(enemyspeed*enemyspeed*49/10000+1)*0.25
        this.dy=(rnd(2)-1)*(enemyspeed*enemyspeed*49/10000+1)*0.25
      end
      -- bounce from edges
      if (this.y<107 or this.y>124) then
        this.dy=-this.dy*0.5
      end
      if (this.x<10 or this.x>128) then
        this.dx=-this.dx
      end
    end

    --bounce egg off buildings
    if this.mode=="egg" then
      local hit=is_undamaged_brick(this.x+3,this.y+this.dy+6,this,"egg",true)
      if this.dy>0 and this.y<100 and hit then
        this.dy=0
        if rnd()>0.5 then this.dx=-0.33 else this.dx=0.33 end
        this.bouncing=1
      end
      if this.dy==0 and not hit then
        this.dy=1
        this.bouncing=0
        -- if (this.dx<0) this.x-=3
        this.dx=0
      end
    end

    --move it unless chompin'
    if (this.chomp==0) then
      this.x+=this.dx
      this.y+=this.dy
    else
      this.chomp-=1
      if this.chomp==0 then
        local chk=damage_brick(this.chompcoords.mx,this.chompcoords.my)
        -- if gremlin collapsed a building row, it destroyed the building, kill gremlin
        if (chk) this.die(this)
      end
    end

    -- turn into gremlin?
    if this.mode=="egg" and this.y>107 then
      sfx(16)
      this.mode="gremlin"
      this.dy=0
    end

    -- chomp?
    if this.mode=="gremlin" and this.chomp==0 and flr(this.x+8)%8==0 and this.y<=116 and rnd()>0.5 then
      local hit=is_undamaged_brick(this.x,this.y,this,gremlins,true)
      if hit then
        this.chompcoords=hit
        this.chomp=70
      end
    end

    -- offscreen?
    if (this.x<-10 or this.x>138) del(gremlins,this)
  end

  obj.draw=function(this)
    if this.bouncing>0 then
      local bb={0,0,1,2,3,3,2,1,0,0}
      spr(this.sprite,this.x,this.y-bb[this.bouncing%#bb+1],1,1,this.flipx)
      this.bouncing+=1
    else
      spr(this.sprite,this.x,this.y,1,1,this.flipx)
    end
    -- print(this.x.." "..this.y,20,20,7)
    -- print(this.dx.." "..this.dy,20,30,7)
  end

  obj.die=function(this)
    sfx(02)
    sfx(19)
    new_explosion(this.x,this.y)
    del(gremlins,this)
  end

  return obj
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