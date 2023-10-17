--camera/map functions

function update_map()
  mx=flr(p.x/16)*16
  my=flr(p.y/16)*16
end

function update_camera()
 
 --normally we'd just set cx,cy
 --to mx*8,my*8 which would snap
 --the camera to the current map
 --location. instead we're going
 --to smoothly change cx,cy over
 --time to match mx*8,my*8. we
 --will be reducing the distance
 --between cx,cy and mx*8,my*8
 --by a percentage each time, so
 --when they are far apart, it
 --will change a lot, but as
 --cx,cy gets closer and closer,
 --they'll change less and less.
 --this makes it seem like the 
 --camera smoothly slows down 
 --to a stop when moving.
 
 --first we need to know how far
 --from cx,cy is from mx*8,my*8.
 cx_diff=mx*8-cx
 cy_diff=my*8-cy
 
 --it's not worth dealing with
 --tiny amounts of difference
 --between the camera and map
 --location, so just set it to
 --zero if the difference is
 --low enough.
 if (abs(cx_diff)<0.1) cx_diff=0
 if (abs(cy_diff)<0.1) cy_diff=0
 
 --instead of reducing the
 --distance by a set amount each
 --time, we're going to reduce
 --the distance by a percentage
 --of the distance. this means
 --when it's far away, the
 --camera will move a lot, but
 --as it gets closer, it will
 --only move a little each time.
 --we find that percentage by
 --multiplying the difference
 --in distance by the transition
 --speed that was set in _init()
 cx_diff*=transition_speed
 cy_diff*=transition_speed
 
 --now we add that reduced
 --distance to cx,cy to move
 --them closer to mx*8,my*8
 cx+=cx_diff
 cy+=cy_diff
 
 camera(cx,cy)
end