--player functions

---------------
-- new player!
function make_player()
  p={}
  p.x=4
  p.y=113
  p.dx=0
  p.dy=0
  p.fuel=999
  p.lowfuel=300
  p.life=3
  p.score=0
  p.extralife=0
  p.dying=0
  p.mode="man"
  p.boxman={x1=2,y1=1,x2=5,y2=6} --collision box
  p.boxplane={x1=0,y1=0,x2=7,y2=7}
  p.box=p.boxman
  p.dir="n"
  p.smokes={{x=0,y=0},{x=0,y=0},{x=0,y=0},{x=0,y=0}}

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

  p.reset=function()
    p.fuel=999
    p.mode="man"
    p.score=0
    p.extralife=0
    p.life=3
  end

  p.scored=function(points)
    p.score+=points
    p.extralife+=points
    -- extra life?
    if p.extralife>=100 then
      p.extralife=0
      if (p.life<5) then
        sfx(15)
        p.life+=1
      end
    end
  end

  p.die=function()
    new_explosion(p.x,p.y)
    if p.mode=="plane" then
      sfx(01)
    else
      sfx(14)
    end
    p.life-=1
    if (p.life==0) then
      game_over()
    else
      p.dying=10
      p.dx=0
      p.dy=0
    end
  end

  p.respawn=function()
    p.fuel=999
    p.mode="man"
    p.x=4
    p.y=113
    p.dx=0
    p.dy=0
  end

  --smoke from back of plane (this is a mess! but it works?)
  p.smoke=function()
    if p.dir=="n" then
      p.smokes[t%#p.smokes]={x=p.x+3,y=p.y-p.dy*1.5+rnd(2)+6}
    elseif p.dir=="s" then
      p.smokes[t%#p.smokes]={x=p.x+3,y=p.y-p.dy*1.5-rnd(2)-1}
    elseif p.dir=="w" then
      p.smokes[t%#p.smokes]={x=p.x-p.dx*1.5+rnd(2)+4,y=p.y+4}
    elseif p.dir=="e" then
      p.smokes[t%#p.smokes]={x=p.x-p.dx*1.5-rnd(2)+2,y=p.y+4}
    elseif p.dir=="se" then
      p.smokes[t%#p.smokes]={x=p.x-p.dx*1.5-rnd(2),y=p.y-p.dy*1.5-rnd(2)}
    elseif p.dir=="sw" then
      p.smokes[t%#p.smokes]={x=p.x+p.dx*1.5+8+rnd(2),y=p.y-p.dy*1.5+2-rnd(2)}
    elseif p.dir=="nw" then
      p.smokes[t%#p.smokes]={x=p.x+p.dx*1.5+8+rnd(2),y=p.y-p.dy*1.5+6-rnd(2)}
    elseif p.dir=="ne" then
      p.smokes[t%#p.smokes]={x=p.x-p.dx*1.5-rnd(2),y=p.y-p.dy*1.5+6+rnd(2)}
    end
  end

  --player update
  p.update=function()
    --wait a spell before respawn
    if (p.dying>0) then

      p.dying-=1
      if p.dying==0 then
        p.respawn()
      end

    else

      --switch between man/plane?
      if p.mode=="man" and p.y<112 then
        p.mode="plane"
        p.x=4
        p.y=102
        p.dy=-1
        p.box=p.boxplane
        sfx(10)
      elseif p.mode=="plane" and p.y>104 then
        if p.x>16 then
          p.die()
        else
          p.mode="man"
          p.x=4
          p.y=113
          p.dy=0
          p.box=p.boxman
          sfx(10)
        end
      end

      --man slow, plane fast
      if p.mode=="man" then
        p.maxspd=2
        p.drg=0.4
      else
        p.maxspd=2.5
        p.drg=0.95
      end

      --fuel check
      if (t%2==0) then
        if p.mode=="man" then
          --manfuel
          p.fuel-=0.1
        else
          --planefuel (empties faster based on velocity)
          if (p.dy~=0 or p.dx~=0) then p.fuel-=(abs(p.dx)+abs(p.dy)) else p.fuel-=0.5 end
        end
        --low fuel klaxon
        if (p.fuel<p.lowfuel and t%40==0) sfx(13)
        p.fuel=max(p.fuel,0)
        --out of fuel!
        if (p.fuel==0) p.die()
      end

      -- check for button presses to get sprite, flip, and direction (another mess that could be greatly simplified)
      if btn(0) then --left
        p.flipx=true
        p.dx-=p.a
        if (p.dx>0 and p.dx<p.minspd) p.dx=-0.1
        if (not btn(2) and not btn(3)) then
          p.dy=0
          p.sprite=19
          p.flipy=false
          p.dir="w"
        else
          p.flipx=true
          if (p.dy<0) then
            p.sprite=20
            p.dir="sw"
          else
            p.sprite=21
            p.dir="nw"
          end
        end
      elseif btn(1) then --right
        p.flipx=false
        p.dx+=p.a
        if (p.dx<0 and abs(p.dx)<p.minspd) p.dx=0.1
        if not btn(2) and not btn(3) then
          p.dy=0
          p.sprite=19
          p.flipy=false
          p.dir="e"
        else
          p.flipx=false
          if (p.dy<0) then
            p.sprite=20
            p.dir="se"
          else
            p.sprite=21
            p.dir="ne"
          end
        end
      end

      if btn(2) then --up
        p.flipy=false
        p.dy-=p.a
        if (p.dy>0 and p.dy<p.minspd) p.dy=-0.1
        if not btn(0) and not btn(1) then
          p.dx=0
          p.sprite=18
          p.flipx=false
          p.dir="n"
        else
          p.sprite=20
          if (p.dx<0) then
            p.flipx=true
            p.dir="nw"
          else
            p.flipx=false
            p.dir="ne"
          end
        end
      elseif btn(3) then --down
        p.flipy=true
        p.dy+=p.a
        if (p.dy<0 and p.dy>-p.minspd) p.dy=0.1
        if not btn(0) and not btn(1) then
          p.dx=0
          p.sprite=18
          p.dir="s"
        else
          p.sprite=21
          p.flipy=false
          if (p.dx<0) then
            p.dir="sw"
          else
            p.dir="se"
          end
        end
      end

      --pewpew
      if btnp(4) or btnp(5) then
        if mode=="game" and (p.mode=="man" or abs(p.dx)~=0 or abs(p.dy)~=0) then
          sfx(00)
          local dx=p.dx
          local dy=p.dy
          -- support for quick turn and shoots when direction doesn't match flipx/flipy
          if p.dy==0 and ((p.flipx and p.dx>0) or (not p.flipx and p.dx<0)) then dx=p.dx*-1 end
          if p.dx==0 and ((p.flipy and p.dy<0) or (not p.flipy and p.dy>0)) then dy=p.dy*-1 end
          if p.mode=="plane" then
            add(bullets,new_bullet(p.x+3,p.y+4,dx,dy))
          else
            add(bullets,new_man_bullet(p.x+3,p.y+4,dx,dy))
          end
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
        p.smoke()
        --if no buttons pushed, ensure sprite is facing direction (could be simplified with using 8 sprites and no flip!)
        if not btn(0) and not btn(1) and not btn(2) and not btn(3) then
          --up=sprite18 --down=sprite18,flipy
          if p.dx==0 and p.dy<0 then p.sprite=18 p.flipy=false p.dir="n" end
          if p.dx==0 and p.dy>0 then p.sprite=18 p.flipy=true p.dir="s" end
          --right=sprite19 --left=sprite19,flipx
          if p.dx>0 and p.dy==0 then p.sprite=19 p.flipx=false p.dir="e" end
          if p.dx<0 and p.dy==0 then p.sprite=19 p.flipx=true p.dir="w" end
          --upright=sprite20 --upleft=sprite20,flipx
          if p.dx>0 and p.dy<0 then p.sprite=20 p.flipx=false p.dir="ne" end
          if p.dx<0 and p.dy<0 then p.sprite=20 p.flipx=true p.dir="nw" end
          --downright=sprite21 --downleft=sprite21,flipx
          if p.dx>0 and p.dy>0 then p.sprite=21 p.flipx=false p.dir="se" end
          if p.dx<0 and p.dy>0 then p.sprite=21 p.flipx=true p.dir="sw" end
        end
      else
        p.dx=0
        p.dy=0
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

  --player draw
  p.draw=function()
    if p.dying==0 then
      if p.mode=="man" then
        spr(0,p.x,p.y,1,1,p.flipx)
        --draw docked plane if man
        spr(18,4,104)
      else
        if abs(p.dx)>0 or abs(p.dy)>0 then
          for i=1,3 do
            pset(p.smokes[i].x+rnd(2),p.smokes[i].y+rnd(2),6)
          end
        end
        spr(p.sprite,p.x,p.y,1,1,p.flipx,p.flipy)
      end
    end
    -- print(p.dir,10,10,7)
    -- print(p.x..","..p.y,40,10,5)
    -- print(p.dx..","..p.dy,40,20,5)
  end

end
