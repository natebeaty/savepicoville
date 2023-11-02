--collision functions

-- get absolute coordinates of a hitbox
function abs_box(s)
  local box={}
  box.x1=s.box.x1+s.x
  box.y1=s.box.y1+s.y
  box.x2=s.box.x2+s.x
  box.y2=s.box.y2+s.y
  return box
end

-- check if object a and b are colliding (optional offset to reduce accuracy)
function coll(a,b,offset)
  offset=offset or 0
  local box_a=abs_box(a)
  local box_b=abs_box(b)
  local hit=true
  if box_a.x1>box_b.x2+offset or
    box_a.y1>box_b.y2+offset or
    box_b.x1>box_a.x2+offset or
    box_b.y1>box_a.y2+offset then
    hit=false
  end
  return hit
end

-- can sprite move in a direction?
function can_move(a,dx,dy)
  --where object is trying to be, relative to hitbox (a.box)
  local nx_l=a.x+dx+a.box.x1   --lft
  local nx_r=a.x+dx+a.box.x2   --rgt
  local ny_t=a.y+dy+a.box.y1   --top
  local ny_b=a.y+dy+a.box.y2   --btm

  --is that spot solid?
  local top_left_solid=solid(nx_l,ny_t)
  local btm_left_solid=solid(nx_l,ny_b)
  local top_right_solid=solid(nx_r,ny_t)
  local btm_right_solid=solid(nx_r,ny_b)

  --nothing solid means we can move into that spot
  return not (top_left_solid or
              btm_left_solid or
              top_right_solid or
              btm_right_solid)
end

--checks an x,y pixel coordinate
--against the map to see if it
--can be walked on or not
function solid(x,y)
  -- offstage?
  if (x<0 or x>128 or y<9) return true
  local mx=flr(x/8)
  local my=flr(y/8)
  local map_sprite=mget(mx,my)
  local flag=fget(map_sprite,0)
  return flag
end

--this checks to see if the
--player is next to a wall. if
--so, don't let them try to move
--in that direction.
function wall_check(a)

  if ((a.dx<0 and (solid(a.x-1,a.y) or solid(a.x-1,a.y+a.box.y2-1))) or (a.dx>0 and (solid(a.x+a.box.x2,a.y) or solid(a.x+a.box.x2,a.y+a.box.y2-1)))) p.dx=0
  if ((a.dy<0 and (solid(a.x,a.y-1) or solid(a.x+a.box.y2-1,a.y-1))) or (a.dy>0 and (solid(a.x,a.y+a.box.y2) or solid(a.x+a.box.x2-1,a.y+a.box.y2)))) p.dy=0

end