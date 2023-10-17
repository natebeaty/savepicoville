
--player functions

function make_player()
  p={}
  p.x=24
  p.y=24
  p.dx=0 --player movement
  p.dy=-1
  p.w=7 --player dimensions
  p.h=7

  p.sprite=5 --player sprite

  -- max speed
  p.maxspd=3

  p.a=1 --acceleration

  --friction
  --1 = no slow down
  --0 = instant halt
  p.drg=0.8

  -- minimum speed
  p.minspd=0.2

end

function move_player()

  -- button pressed, accelerate
  if (btn(0)) p.dx-=p.a
  if (btn(1)) p.dx+=p.a
  if (btn(2)) p.dy-=p.a
  if (btn(3)) p.dy+=p.a

  -- max speed
  p.dx=mid(-p.maxspd,p.dx,p.maxspd)
  p.dy=mid(-p.maxspd,p.dy,p.maxspd)

  -- check if next to wall
  wall_check(p)

  -- can move?
  if (can_move(p,p.dx,p.dy)) then
    p.x+=p.dx
    p.y+=p.dy
  else
    -- find how close we can get moving in that direction
    tdx=p.dx
    tdy=p.dy

    while (not can_move(p,tdx,tdy)) do
      if (abs(tdx)<=0.1) then
        tdx=0
      else
       tdx*=0.9
      end
      if (abs(tdy)<=0.1) then
       tdy=0
      else
       tdy*=0.9
      end
    end

     -- move player incrementally
    p.x+=tdx
    p.y+=tdy
  end

  -- add drag
  if (abs(p.dx)>0) p.dx*=p.drg
  if (abs(p.dy)>0) p.dy*=p.drg

  -- make sure they don't drop below min speed
  if (abs(p.dx)<p.minspd) then
    if (p.dx<0) then p.dx=-p.minspd else p.dx=p.minspd end
  end
  if (abs(p.dy)<p.minspd) then
    if (p.dx<0) then p.dx=-p.minspd else p.dx=p.minspd end
  end

end
