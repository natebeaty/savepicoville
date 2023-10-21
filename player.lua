--player functions

function make_player()
  p={}
  p.x=4 --player position
  p.y=112
  p.dx=0 --player movement
  p.dy=0
  p.box={x1=0,y1=0,x2=7,y2=7}  --collision box
  p.life="♥♥♥"
  p.fuel=999
  p.score=0
  p.dying=0

  p.last_flipx=true
  p.flipx=false --flip sprite horizontal
  p.flipy=false --flip sprite vertical
  p.sprite_neutral=18 --player sprite, neutral
  p.sprite=p.sprite_neutral --current player sprite

  p.maxspd=4 --max speed
  p.minspd=1 --min speed

  p.a=.8 --acceleration

  --friction (1=none, 0=instant)
  p.drg=0.1

  p.die=function()
    sfx(01)
    p.life=sub(p.life,0,#p.life-1)
    if (p.life=="") then
      game_over()
    else
      p.dying=10
      p.dx=0
      p.dy=0
    end
  end

  p.respawn=function()
    p.last_flipx=true
    p.x=4
    p.y=112
  end
end

function move_player()
  if (p.dying>0) then
    p.dying-=1
    if t%3==0 then p.sprite=32 else p.sprite=33 end
    if p.dying==0 then
      p.respawn()
    end
  else

    -- check for button presses to get sprite, flip, and direction
    if (btn(0)) then
      p.last_flipx=false
      p.flipx=false
      if p.dx<0 then p.dx-=p.a else p.dx=-p.minspd end
      if (not btn(2) and not btn(3)) then
        p.dy=0
        p.sprite=19
        p.flipy=false
      else
        p.flipx=true
        if (p.dy<0) then p.sprite=20 else p.sprite=21 end
      end
    end
    if (btn(1)) then
      p.last_flipx=true
      p.flipx=true
      if p.dx>0 then p.dx+=p.a else p.dx=p.minspd end
      if (not btn(2) and not btn(3)) then
        p.dy=0
        p.sprite=19
        p.flipy=false
      else
        p.flipx=false
        if (p.dy<0) then p.sprite=20 else p.sprite=21 end
      end
    end
    if (btn(2)) then
      p.flipy=false
      if p.dy<0 then p.dy-=p.a else p.dy=-p.minspd end
      if (not btn(0) and not btn(1)) then
        p.dx=0
        p.sprite=18
        p.flipx=false
      else
        p.sprite=20
        if (p.dx<0) then p.flipx=true else p.flipx=false end
      end
    end
    if (btn(3)) then
      p.flipy=true
      if p.dy>0 then p.dy+=p.a else p.dy=p.minspd end
      if (not btn(0) and not btn(1)) then
        p.dx=0
        p.sprite=18
        p.flipx=true
      else
        p.flipy=false
        p.sprite=21
      end
    end

    --limit to max speed
    p.dx=mid(-p.maxspd, p.dx, p.maxspd)
    p.dy=mid(-p.maxspd, p.dy, p.maxspd)

    --check if next to wall
    wall_check(p)

    --can move?
    if (can_move(p,p.dx,p.dy)) then
      p.x+=p.dx
      p.y+=p.dy
    end

    --add drag
    if (abs(p.dx)>0) p.dx*=p.drg
    if (abs(p.dy)>0) p.dy*=p.drg

    --make sure they don't drop below min speed
    if (abs(p.dx)!=0 and abs(p.dx)<p.minspd) then
      if (p.dx<0) then p.dx=-p.minspd else p.dx=p.minspd end
    end
    if (abs(p.dy)!=0 and abs(p.dy)<p.minspd) then
      if (p.dy<0) then p.dy=-p.minspd else p.dy=p.minspd end
    end

    --neutral state if not moving
    if (p.dx==0 and p.dy==0) then
      p.sprite=p.sprite_neutral
      p.flipy=false
      p.flipx=p.last_flipx
    end
  end
end
