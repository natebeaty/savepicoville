
--player functions

function make_player()
  p={}
  p.x=24 --start position
  p.y=24
  p.dx=0 --player movement
  p.dy=0
  p.w=8 --player dimensions
  p.h=8

  p.flipx = false -- flip sprite x?
  p.flipy = false -- flip sprite y?

  p.sprite=18 --player sprite

  -- max speed
  p.maxspd=4
  -- minimum speed
  p.minspd=1

  p.a=.8 --acceleration

  --friction
  --1 = no slow down
  --0 = instant halt
  p.drg=0.1

end

function move_player()
  -- button pressed, accelerate
  if (btn(0)) then
    p.flipx = false
    if p.dx<0 then p.dx-=p.a else p.dx=-p.minspd end
    if (not btn(2) and not btn(3)) then
      p.dy=0
      p.sprite = 19
      p.flipy = false
    else
      p.sprite = 20
      p.flipx = true
      if (p.dy<0) then p.flipy = false else p.flipy = true end
    end
  end
  if (btn(1)) then
    p.flipx = true
    if p.dx>0 then p.dx+=p.a else p.dx=p.minspd end
    if (not btn(2) and not btn(3)) then
      p.dy=0
      p.sprite = 19
      p.flipy = false
    else
      p.sprite = 20
      p.flipx = false
      if (p.dy<0) then p.flipy = false else p.flipy = true end
    end
  end
  if (btn(2)) then
    p.flipy = false
    if p.dy<0 then p.dy-=p.a else p.dy=-p.minspd end
    if (not btn(0) and not btn(1)) then
      p.dx=0
      p.sprite = 18
      p.flipx = false
    else
      p.sprite = 20
      if (p.dx<0) then p.flipx = true else p.flipx = false end
    end
  end
  if (btn(3)) then
    p.flipy = true
    if p.dy>0 then p.dy+=p.a else p.dy=p.minspd end
    if (not btn(0) and not btn(1)) then
      p.dx=0
      p.sprite = 18
      p.flipx = true
    else
      p.sprite = 20
    end
  end

  -- max speed
  p.dx=mid(-p.maxspd, p.dx, p.maxspd)
  p.dy=mid(-p.maxspd, p.dy, p.maxspd)

  -- check if next to wall
  wall_check(p)

  -- can move?
  if (can_move(p,p.dx,p.dy)) then
    p.x+=p.dx
    p.y+=p.dy
  end

  -- add drag
  if (abs(p.dx)>0) p.dx*=p.drg
  if (abs(p.dy)>0) p.dy*=p.drg

  -- make sure they don't drop below min speed
  if (abs(p.dx)!=0 and abs(p.dx)<p.minspd) then
    if (p.dx<0) then p.dx=-p.minspd else p.dx=p.minspd end
  end
  if (abs(p.dy)!=0 and abs(p.dy)<p.minspd) then
    if (p.dy<0) then p.dy=-p.minspd else p.dy=p.minspd end
  end

end
