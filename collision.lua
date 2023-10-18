--collision functions

function abs_box(s)
  local box = {}
  box.x1 = s.box.x1 + s.x
  box.y1 = s.box.y1 + s.y
  box.x2 = s.box.x2 + s.x
  box.y2 = s.box.y2 + s.y
  return box
end

function coll(a,b)
 local box_a = abs_box(a)
 local box_b = abs_box(b)
 if box_a.x1 > box_b.x2 or
    box_a.y1 > box_b.y2 or
    box_b.x1 > box_a.x2 or
    box_b.y1 > box_a.y2 then
    return false
 end
 return true
end

--this function takes an object
--and a speed in the x and y
--directions. it uses those
--to check the four corners of
--the object to see it can move
--into that spot. (a map tile
--marked as solid would prevent
--movement into that spot.)
function can_move(a,dx,dy)

  --create variables for the
  --left, right, top, and bottom
  --coordinates of where the
  --object is trying to be.
  local nx_l=a.x+dx       --lft
  local nx_r=a.x+dx+a.box.x2   --rgt
  local ny_t=a.y+dy       --top
  local ny_b=a.y+dy+a.box.y2   --btm

  --now check each corner of
  --where the object is trying to
  --be and see if that spot is
  --solid or not.
  local top_left_solid=solid(nx_l,ny_t)
  local btm_left_solid=solid(nx_l,ny_b)
  local top_right_solid=solid(nx_r,ny_t)
  local btm_right_solid=solid(nx_r,ny_b)

  --if all of those locations are
  --not solid, the object can
  --move into that spot.
  return not (top_left_solid or
              btm_left_solid or
              top_right_solid or
              btm_right_solid)
end

--checks an x,y pixel coordinate
--against the map to see if it
--can be walked on or not
function solid(x,y)
  if (x<0) return true

 --pixel coords -> map coords
 local map_x=flr(x/8)
 local map_y=flr(y/8)

 --what sprite is at that spot?
 local map_sprite=mget(map_x,map_y)

 --what flag does it have?
 local flag=fget(map_sprite)

 --if the flag is 1, it's solid
 return flag==1
end

--this checks to see if the
--player is next to a wall. if
--so, don't let them try to move
--in that direction.
function wall_check(a)

  if ((a.dx<0 and (solid(a.x-1,a.y) or solid(a.x-1,a.y+a.box.y2-1))) or (a.dx>0 and (solid(a.x+a.box.x2,a.y) or solid(a.x+a.box.x2,a.y+a.box.y2-1)))) p.dx=0
  if ((a.dy<0 and (solid(a.x,a.y-1) or solid(a.x+a.box.y2-1,a.y-1))) or (a.dy>0 and (solid(a.x,a.y+a.box.y2) or solid(a.x+a.box.x2-1,a.y+a.box.y2)))) p.dy=0

 --going left?
 if (a.dx<0) then
  --check both left corners for
  --a wall.
  local wall_top_left=solid(a.x-1,a.y)
  local wall_btm_left=solid(a.x-1,a.y+a.box.y2)

  --if there is a wall in that
  --direction, set x movement
  --to 0.
  if (wall_top_left or wall_btm_left) then
   a.dx=0
  end

 --going right?
 elseif (a.dx>0) then
  --check both right corners for
  --a wall.
  local wall_top_right=solid(a.x+a.box.x2+1,a.y)
  local wall_btm_right=solid(a.x+a.box.x2+1,a.y+a.box.y2)

  --if there is a wall in that
  --direction, set x movement
  --to 0.
  if (wall_top_right or wall_btm_right) then
   a.dx=0
  end
 end

 --going up?
 if (a.dy<0) then
  --check both top corners for
  --a wall.
  local wall_top_left=solid(a.x,a.y-1)
  local wall_top_right=solid(a.x+a.box.x2,a.y-1)

  --if there is a wall in that
  --direction, set y movement
  --to 0.
  if (wall_top_left or wall_top_right) then
   a.dy=0
  end

 --going down?
 elseif (a.dy>0) then
  --check both bottom corners
  --for a wall.
  local wall_btm_left=solid(a.x,a.y+a.box.y2+1)
  local wall_btm_right=solid(a.x,a.y+a.box.y2+1)

  --if there is a wall in that
  --direction, set y movement
  --to 0.
  if (wall_btm_right or wall_btm_left) then
   a.dy=0
  end
 end

 --the two commented lines of
 --code below do the same thing
 --as all the lines of code
 --above, but are just condensed

  --if ((a.dx<0 and (solid(a.x-1,a.y) or solid(a.x-1,a.y+a.box.y2-1))) or (a.dx>0 and (solid(a.x+a.box.x2,a.y) or solid(a.x+a.box.x2,a.y+a.box.y2-1)))) p.dx=0
  --if ((a.dy<0 and (solid(a.x,a.y-1) or solid(a.x+a.box.y2-1,a.y-1))) or (a.dy>0 and (solid(a.x,a.y+a.box.y2) or solid(a.x+a.box.x2-1,a.y+a.box.y2)))) p.dy=0
end