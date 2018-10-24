## kos-vab-lander
### Land a rocket on the VAB!

### Requirements:
  - trajectories mod - for manually adjusting impact point
  - kos - obviously

Steps:
  - put the .ks files in Ships/Script directory.
  - create a rocket with 3 or 4 control fins at the bottom, and with about 600 dV
  - set your rocket to orbit using the debug menu: cheats -> set orbit
  - perform a retrograde burn visually assisted by trajectories mod, so that
    the impact point is above KSC.
  - run the following commands in kos console:
  ```
  switch to 0.
  run land.
  ```
 


You can also put drogue chutes and/or airbrakes, then enable airbrakes in code:
```
set aerobraking_enabled to true.
```

Demo video: https://www.youtube.com/watch?v=eU0OfJBgCrs  
Reddit: https://www.reddit.com/r/Kos/comments/9qzvq4/glide_towards_and_land_on_the_vab_from_orbit/

Have fun!
