// any combination af staging and parachutes will not be implemented
// in a real life descent and landing, they are triggered manually

run astlib.
set red_arrow:show to true.
set green_arrow:show to true.
set blue_arrow:show to true.

set dto_landingsite_impact to 0.
set prev_dto_landingsite_impact to dto_landingsite_impact.

local steering_intensity_max is 10.
local steering_speed_correction is 0.
local steering_altitude_correction is 0.
local steering_yaw_correction is 0.
local steering_pitch_correction is 0.
local steering_speed_pid is pidloop(0.008,0,0,-steering_intensity_max, +steering_intensity_max).
local steering_altitude_pid is pidloop(0.002,0,0,-steering_intensity_max, +steering_intensity_max).
// local steering_yaw_pid is pidloop(0.001,0.00005,0.02,-steering_intensity_max, +steering_intensity_max).
// local steering_pitch_pid is pidloop(0.001,0.00001,0.02,-steering_intensity_max, +steering_intensity_max).

local radar_height is 13.8156.
local height_offset is radar_height + 5.
local g_surface is body:mu / (body:radius^2).
local suicide_burn_until_v is 10.
local touchdown_v is 5.
local time_buffer is 0.5.
local suicideburn_triggered is false.
local brakes_triggered is false.
local droguechutes_triggered is false.
local parachutes_triggered is false.
local steering_control_triggered is false.
local aerobraking_enabled is true.

set aerobraking_enabled to false.

if aerobraking_enabled {
  set overshoot_factor to 1.280.
} else {
  set overshoot_factor to 1.220.
}


until do_exit {

  if missiontime - current_time > tick_time {
    set current_time to missiontime.
    clearscreen.

    if altitude < 50000 and periapsis < 0 and throttle = 0 {
      
      if not steering_control_triggered {
        SAS OFF.
        RCS ON.
        // initially point retrograde
        set nav_direction to -VXCL(UP:VECTOR, VELOCITY:SURFACE).
        lock steering to nav_direction.
        set steering_control_triggered to true.
      }

      local impact_data is impact_UTs().
      local impactsite is ground_track(positionat(ship,impact_data["time"]),impact_data["time"]).
      local impact_eta is impact_data["time"] - time:seconds.

      local g is body:mu / (body:radius + altitude + radar_height)^2.
      local a_total IS MAXTHRUST/MASS - g.
      local t_toV0 IS (AIRSPEED / a_total).

      local target_yaw_latlng is latlng(impactsite:lat, landingsite:lng).
      local target_pitch_latlng is latlng(landingsite:lat, impactsite:lng).
      local dto_landingsite_target_yaw to dto_latlng(target_yaw_latlng, landingsite).
      local dto_landingsite_target_pitch to dto_latlng(target_pitch_latlng, landingsite).
      local dto_landingsite_impact is dto_latlng(impactsite, landingsite).

      local steering_speed_correction is steering_intensity_max - abs(steering_speed_pid:UPDATE(TIME:SECONDS, AIRSPEED)).
      local steering_altitude_correction is abs(steering_altitude_pid:UPDATE(TIME:SECONDS, altitude - ship:geoposition:terrainheight - landingsite_elevation)).
      // local steering_yaw_correction is abs(steering_yaw_pid:UPDATE(TIME:SECONDS,dto_landingsite_target_yaw)).
      // local steering_pitch_correction is abs(steering_pitch_pid:UPDATE(TIME:SECONDS, dto_landingsite_target_pitch)).
      
      local steering_intensity_correction is min(steering_altitude_correction, steering_speed_correction).

      print "[info] steering handled by flight computer!".
      set nav_direction to -SHIP:VELOCITY:SURFACE:NORMALIZED * landingsite:altitudeposition(landingsite_elevation):MAG - VXCL(SHIP:VELOCITY:SURFACE, VXCL(SHIP:UP:FOREVECTOR, landingsite:altitudeposition(landingsite_elevation) * overshoot_factor - impactsite:altitudeposition(landingsite_elevation))) * steering_intensity_correction.

      if aerobraking_enabled {
        if altitude < 15000 and dto_landingsite_target_pitch < 450 and dto_landingsite_target_yaw < 150 and not brakes_triggered {
          BRAKES ON.
          set brakes_triggered to true.
        }
        
        if altitude < 2500 and dto_landingsite_target_pitch < 100 and dto_landingsite_target_yaw < 25 and not droguechutes_triggered {
          safe_stage().
          set droguechutes_triggered to true.
        }

        if altitude < 1000 and dto_landingsite_target_pitch < 25 and dto_landingsite_target_yaw < 25 and not parachutes_triggered {
          safe_stage().
          set parachutes_triggered to true.
        }
      }

      // suicide burn
      if alt:radar >= height_offset {
        if impact_eta <= t_toV0 + time_buffer and altitude < 4700 and not suicideburn_triggered {
          
          lock THROTTLE TO 0.
          print "[info] thrusters handled by flight computer!".
          
          GEAR ON.
          LEGS ON.
          
          unlock STEERING.
          SAS ON.
          wait time_buffer.
          SET SASMODE to "RETROGRADE".
          
          print "[info] doing suicide burn...".
          until -VERTICALSPEED < suicide_burn_until_v {
            local g is body:mu / (body:radius + altitude)^2.
            local acc is (airspeed - 1)^2 / (2 * (alt:radar - height_offset)).
            local thrust is (acc + g) * ship:mass.
            LOCK THROTTLE TO thrust / maxthrust.
          }

          print "[info] killing the last bit of dV...".
          until -VERTICALSPEED <= touchdown_v {
            local g is body:mu / (body:radius + altitude)^2.
            local acc is (airspeed - 1)^2 / (2 * (alt:radar - height_offset)).
            local thrust is (acc + g) * ship:mass.
            LOCK THROTTLE TO thrust / maxthrust.
          }

          print "[info] gently touching down...".
          SAS OFF.
          lock steering to lookdirup(ship:up:forevector,ship:facing:upvector).
          until ship:status = "LANDED" or ship:status = "SPLASHED" {
            if maxthrust > 0 and VERTICALSPEED < 0 {
              local g is body:mu / (body:radius + altitude)^2.
              LOCK THROTTLE TO 0.85/(maxthrust/ship:mass/g).
            }
          }
          lock throttle to 0.
          wait 0.5.
          set do_exit to true.
        } else {
          print "[info] suicide burn in " + round((impact_eta - t_toV0 - time_buffer),2) + " seconds".
        }
      }

      // debug arrows
      set green_arrow:vec to ship:geoposition:position.
      set blue_arrow:vec to -nav_direction.
      set red_arrow:vec to impactsite:position.

      print "[info] impact eta: " + round(impact_eta,2).
      print "[info] distance between landing site and impact: " + round(dto_landingsite_impact,2).
      print "[info] total correction from last loop: " + round(prev_dto_landingsite_impact - dto_landingsite_impact,2).
      print "[info] steering intensity correction: " + steering_intensity_correction.
      print "[info] speed correction pid: " + steering_speed_correction.
      print "[info] air speed: " + airspeed.
      print "[info] yaw   component: " + dto_landingsite_target_yaw.
      // print "[info] yaw correction pid:" + steering_yaw_correction.
      print "[info] pitch component: " + dto_landingsite_target_pitch.
      // print "[info] pitch correction pid:" + steering_pitch_correction.
      print "[info] altitude correction pid: " + steering_altitude_correction.
      print "[info] ground speed: " + groundspeed.

      set prev_dto_landingsite_impact to dto_landingsite_impact.
    } else {
      print "[info] waiting for altitude < 50000m, periapsis < 0m and zero throttle...".
      wait 1.
    } 
  }
}

safe_exit().
