--player functions

---------------
-- new player!
function make_player()
  p={}
  p.x=4
  p.y=121
  p.dx=0
  p.dy=0
  p.life="♥♥♥"
  p.fuel=999
  p.lowfuel=300
  p.score=0
  p.dying=0
  p.mode="man"
  p.boxman={x1=2,y1=1,x2=5,y2=6} --collision box
  p.boxplane={x1=0,y1=0,x2=7,y2=7}
  p.box=p.boxman

  p.flipx=false --flip horizontal
  p.flipy=false --flip vertical
  p.sprite=0

  p.maxspd=1 --max speed
  p.minspd=1 --min speed
  p.a=0.25 --acceleration
  p.drg=0.95 --friction (1=none,0=instant)

  p.resupply=function()
    p.fuel+=400
    if (p.fuel>999) p.fuel=999
  end

  p.die=function()
    sfx(01)
    p.life=sub(p.life,0,#p.life-1)
    if (p.life=="") then
      game_over()
    else
      new_explosion(p.x,p.y)
      p.dying=10
      p.dx=0
      p.dy=0
    end
  end

  p.respawn=function()
    p.fuel=999
    p.mode="man"
    p.x=4
    p.y=121
    p.dx=0
    p.dy=0
  end

  p.draw=function()
    if p.dying==0 then
      if p.mode=="man" then
        spr(0,p.x,p.y)
        spr(18,4,112)
      else
        spr(p.sprite,p.x,p.y,1,1,p.flipx,p.flipy)
      end
    end
    -- print(p.x..","..p.y,40,10,5)
    -- print(p.dx..","..p.dy,40,20,5)
  end

  -- player update
  p.update=function()
    if (p.dying>0) then

      p.dying-=1
      if p.dying==0 then
        p.respawn()
      end

    else

      if p.mode=="man" and p.y<120 then
        p.mode="plane"
        p.x=4
        p.y=110
        p.dy=-1
        p.box=p.boxplane
        sfx(10)
      elseif p.mode=="plane" and p.y>112 then
        if p.x>16 then
          p.die()
        else
          p.mode="man"
          p.x=4
          p.y=121
          p.dy=0
          p.box=p.boxman
          sfx(10)
        end
      end

      if p.mode=="man" then
        p.maxspd=2
        p.drg=0.3
      else
        p.maxspd=2.5
        p.drg=0.95 --friction (1=none,0=instant)
      end

      -- fuel check
      if (t%2==0) then
        -- moving? reduce fuel
        if p.mode=="man" then
          p.fuel-=0.1
        else
          if (p.dy~=0 or p.dx~=0) then p.fuel-=(abs(p.dx)+abs(p.dy)) else p.fuel-=0.5 end
        end
        -- low fuel klaxon
        if (p.fuel<p.lowfuel and t%40==0) sfx(13)
        p.fuel=max(p.fuel,0)
        if (p.fuel==0) p.die()
      end

      -- check for button presses to get sprite, flip, and direction
      -- left
      if btn(0) then
        p.flipx=true
        p.dx-=p.a
        if (p.dx>0 and p.dx<p.minspd) p.dx=-0.1
        if (not btn(2) and not btn(3)) then
          p.dy=0
          p.sprite=19
          p.flipy=false
        else
          p.flipx=true
          if (p.dy<0) then p.sprite=20 else p.sprite=21 end
        end
      end
      -- right
      if btn(1) then
        p.flipx=false
        p.dx+=p.a
        if (p.dx<0 and abs(p.dx)<p.minspd) p.dx=0.1
        if not btn(2) and not btn(3) then
          p.dy=0
          p.sprite=19
          p.flipy=false
        else
          p.flipx=false
          if (p.dy<0) then p.sprite=20 else p.sprite=21 end
        end
      end
      -- up
      if btn(2) then
        p.flipy=false
        p.dy-=p.a
        if (p.dy>0 and p.dy<p.minspd) p.dy=-0.1
        if not btn(0) and not btn(1) then
          p.dx=0
          p.sprite=18
          p.flipx=false
        else
          p.sprite=20
          if (p.dx<0) then p.flipx=true else p.flipx=false end
        end
      end
      -- down
      if btn(3) then
        p.flipy=true
        p.dy+=p.a
        if (p.dy<0 and p.dy>-p.minspd) p.dy=0.1
        if not btn(0) and not btn(1) then
          p.dx=0
          p.sprite=18
          p.flipx=true
        else
          p.flipy=false
          p.sprite=21
        end
      end
      -- fire
      if p.mode=="plane" and btnp(4,0) then
        if (abs(p.dx)~=0 or abs(p.dy)~=0) then
          sfx(00)
          local dx=p.dx
          local dy=p.dy
          -- support for quick turn and shoots when direction doesn't match flipx/flipy
          if p.dy==0 and ((p.flipx and p.dx>0) or (not p.flipx and p.dx<0)) then dx=p.dx*-1 end
          if p.dx==0 and ((p.flipy and p.dy<0) or (not p.flipy and p.dy>0)) then dy=p.dy*-1 end
          add(bullets,new_bullet(p.x+3,p.y+4,dx,dy))
        end
      end

      --limit to max speed
      p.dx=mid(-p.maxspd,p.dx,p.maxspd)
      p.dy=mid(-p.maxspd,p.dy,p.maxspd)

      --check if next to wall
      wall_check(p)

      check_building_hit(p,"player")

      --can move?
      if (can_move(p,p.dx,p.dy)) then
        p.x+=p.dx
        p.y+=p.dy
        -- if no buttons pushed, ensure sprite is facing direction
        if not btn(0) and not btn(1) and not btn(2) and not btn(3) then
          --up=sprite18 --down=sprite18,flipy
          if p.dx==0 and p.dy<0 then p.sprite=18 p.flipy=false end
          if p.dx==0 and p.dy>0 then p.sprite=18 p.flipy=true end
          --right=sprite19 --left=sprite19,flipx
          if p.dx>0 and p.dy==0 then p.sprite=19 p.flipx=false end
          if p.dx<0 and p.dy==0 then p.sprite=19 p.flipx=true end
          --upright=sprite20 --upleft=sprite20,flipx
          if p.dx>0 and p.dy<0 then p.sprite=20 p.flipx=false end
          if p.dx<0 and p.dy<0 then p.sprite=20 p.flipx=true end
          --downright=sprite21 --downleft=sprite21,flipx
          if p.dx>0 and p.dy>0 then p.sprite=21 p.flipx=false end
          if p.dx<0 and p.dy>0 then p.sprite=21 p.flipx=true end
        end
      end

      --add drag
      if (abs(p.dx)>0) p.dx*=p.drg
      if (abs(p.dy)>0) p.dy*=p.drg

      --make sure they don't drop below min speed
      if p.mode=="plane" then
        p.dx=minspeed(p.dx,p.minspd)
        p.dy=minspeed(p.dy,p.minspd)
      end

    end
  end

end
