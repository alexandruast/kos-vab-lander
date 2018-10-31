@LAZYGLOBAL OFF.
CLEARSCREEN.

RUN PARAMS.
RUN COMMON.
RUN NUGGREAT.

GLOBAL impact_UTs_impactHeight IS LANDINGSITE_ELEVATION + SUICIDEBURN_UNTIL_GROUND_ALTITUDE.

LOCAL progLandTo is TRUE.
LOCAL steeringMag is STEERING_MAGNITUDE_MIN.

FUNCTION MainLoop {
    
  IF progLandTo {
    LOCAL impact_data is impact_UTs().
    LOCAL impactSite is ground_track(positionat(ship,impact_data["time"]),impact_data["time"]).
    
    LOCK trueRadar to ALT:RADAR - SHIP_RADAR_HEIGHT.
    LOCK gSeaLevel  to BODY:MU / ( BODY:RADIUS^2).
    LOCK gAltitude to BODY:MU / (BODY:RADIUS + SHIP:GEOPOSITION:TERRAINHEIGHT + trueRadar)^2.
    
    LOCK suicideBurnRadar to trueRadar - SUICIDEBURN_UNTIL_GROUND_ALTITUDE.
    LOCK pinPointDescentRadar to trueRadar - PPD_UNTIL_ALTITUDE.
    
    LOCK thrustDecel to (SHIP:AVAILABLETHRUST / SHIP:MASS) - gSeaLevel.
    LOCK stoppingDistance to SHIP:AIRSPEED^2 / (2 * thrustDecel).
    
    LOCK impactETA to trueRadar / ABS(SHIP:VERTICALSPEED).
    
    // This line is absolutely required, for special circumstances
    // where the velocity is very high, otherwise the ship 
    // will be short on thrust by missing a tick distance
    LOCK tickDistance to ABS(SHIP:AIRSPEED) * PROC_TICK_TIME.
    
    SAS OFF.
    
    SET STEERINGMANAGER:ROLLControlAngleRange TO 0.
    
    // Steering intensity
    IF VANG(SHIP:SRFRETROGRADE:VECTOR, LOOKDIRUP(SHIP:UP:FOREVECTOR,SHIP:FACING:UPVECTOR):VECTOR) > 1.5 {
      SET steeringMag to MIN(STEERING_MAGNITUDE_MIN + STEERING_DP_FACTOR * MAX(0, STEERING_MAX_DP_KPA - SHIP:Q * CONSTANT:ATMtokPa), STEERING_MAGNITUDE_MAX).
    } else {
      SET steeringMag to 4.25.
    }

    LOCK STEERING TO
      SHIP:SRFRETROGRADE:VECTOR:NORMALIZED * LANDINGSITE:ALTITUDEPOSITION(LANDINGSITE_ELEVATION):MAG
      -VXCL(
        SHIP:SRFRETROGRADE:VECTOR,
        VXCL(
          SHIP:UP:FOREVECTOR,
          LANDINGSITE:ALTITUDEPOSITION(LANDINGSITE_ELEVATION) * 1.28
          -impactSite:ALTITUDEPOSITION(LANDINGSITE_ELEVATION) * 0.50
        )
      ) * steeringMag.

    // Activate brakes when the angle between retrograde an UP is less than 15 deg.
    WHEN  BODY:ATM:EXISTS
          AND AIRBRAKES_ENABLED
          AND NOT BRAKES
          AND VANG(SHIP:SRFRETROGRADE:VECTOR, LOOKDIRUP(SHIP:UP:FOREVECTOR,SHIP:FACING:UPVECTOR):VECTOR) < 15 THEN { 
      BRAKES ON.
      PRINT "BRAKES ON " + ROUND(trueRadar,2) + "/" + ROUND(VERTICALSPEED,2).
    }
    
    // Activate parachutes when the angle between retrograde an facing UP is less than 5 deg.
    WHEN  BODY:ATM:EXISTS
          AND PARACHUTES_ENABLED
          AND NOT CHUTES
          AND VANG(SHIP:SRFRETROGRADE:VECTOR, LOOKDIRUP(SHIP:UP:FOREVECTOR,SHIP:FACING:UPVECTOR):VECTOR) < 5 THEN { 
      CHUTES ON.
      PRINT "CHUTES ON " + ROUND(trueRadar,2) + "/" + ROUND(VERTICALSPEED,2).
    }

    IF  (
          (BODY:ATM:EXISTS AND SHIP:AIRSPEED < SUICIDEBURN_ATM_AIRSPEED_MAX)
          OR NOT BODY:ATM:EXISTS
        )
        AND suicideBurnRadar < tickDistance + stoppingDistance * SUICIDEBURN_GRACE_MULTIPLIER {
      
      // Hoverslam burn must be done retrograde for math to work properly
      LOCK STEERING TO SHIP:SRFRETROGRADE.

      // Lock steering to UP and turn RCS on for translational only maneuvers when
      // the angle between retrograde and facing UP si less than 1.25 deg.
      WHEN VANG(SHIP:SRFRETROGRADE:VECTOR, LOOKDIRUP(SHIP:UP:FOREVECTOR,SHIP:FACING:UPVECTOR):VECTOR) < 1.25 THEN { 
        LOCK STEERING TO LOOKDIRUP(SHIP:UP:FOREVECTOR,SHIP:FACING:UPVECTOR).
        RCS ON.
        PRINT "RCS ON " + ROUND(trueRadar,2) + "/" + ROUND(VERTICALSPEED,2).
      }
      
      WHEN impactETA < 10 THEN {
        LEGS ON.
        PRINT "LEGS ON " + ROUND(trueRadar,2) + "/" + ROUND(VERTICALSPEED,2).
      }
      
      // ToDo: Use RCS translation for the rest of the descent for pinpoint accuracy
      
      StepSuicideBurn().
      set doExit to TRUE.
      wait 15.
    }
    
    IF TIME - currentUITime > UI_TICK_TIME {
      set currentUITime to TIME.
      // green arrow always points perpendicular to the object it's orbiting
      SET GREEN_ARROW:VEC TO SHIP:GEOPOSITION:POSITION.
      // blue arrow always points to steering direction
      SET BLUE_ARROW:VEC TO -STEERINGMANAGER:TARGET:VECTOR * SHIP:GEOPOSITION:POSITION:MAG.
      // red arrow points at impact_site
      SET RED_ARROW:VEC TO IMPACTSITE:POSITION.
      PRINT "IMPACT " + FLOOR(impactETA) + " STEERMAG " + ROUND(steeringMag, 2).
    }
  }
}

FUNCTION StepSuicideBurn {
  PRINT "HVS START " + ROUND(trueRadar,2) + "/" + ROUND(VERTICALSPEED,2).
  // Proportional throttle type1 - default
  LOCK THROTTLE TO (-VERTICALSPEED/ABS(VERTICALSPEED) * stoppingDistance) / MAX(0.0001, suicideBurnRadar).
  // Proportional throttle type2 - better low end throttle modulationmodulation for pinpoint accuracy, more dV needed
  // LOCK THROTTLE TO (-VERTICALSPEED/ABS(VERTICALSPEED) * (((AIRSPEED - SUICIDEBURN_UNTIL_VSPEED/4)^2 / MAX(0.0001, suicideBurnRadar) + gSeaLevel) * SHIP:MASS)) / MAX(0.0001, SHIP:AVAILABLETHRUST).  
  WAIT UNTIL -SHIP:VERTICALSPEED < SUICIDEBURN_UNTIL_VSPEED.
  PRINT "HVS END " + ROUND(trueRadar,2) + "/" + ROUND(VERTICALSPEED,2).

  PRINT "PPD START " + ROUND(trueRadar,2) + "/" + ROUND(VERTICALSPEED,2).
  // Proportional throttle type1 - default
  LOCK THROTTLE TO (-VERTICALSPEED/ABS(VERTICALSPEED) * stoppingDistance) / MAX(0.0001, pinPointDescentRadar).
  // Proportional throttle type2 - better low end throttle modulation for pinpoint accuracy, more dV needed
  // LOCK THROTTLE TO (-VERTICALSPEED/ABS(VERTICALSPEED) * (((AIRSPEED - PPD_UNTIL_VSPEED/4)^2 / MAX(0.0001, (2 * pinPointDescentRadar)) + gSeaLevel) * SHIP:MASS)) / MAX(0.0001, SHIP:AVAILABLETHRUST).
  WAIT UNTIL -SHIP:VERTICALSPEED < PPD_UNTIL_VSPEED.
  PRINT "PPD END " + ROUND(trueRadar,2) + "/" + ROUND(VERTICALSPEED,2).
  
  PRINT "TDW START " + ROUND(trueRadar,2) + "/" + ROUND(VERTICALSPEED,2).
  LOCK THROTTLE TO 0.95/(MAX(0.0001, SHIP:AVAILABLETHRUST) / SHIP:MASS / gAltitude).
  WAIT UNTIL SHIP:STATUS = "LANDED" OR SHIP:STATUS = "SPLASHED".
  PRINT "TDW END " + ROUND(trueRadar,2) + "/" + ROUND(VERTICALSPEED,2).
  LOCK THROTTLE TO 0.
  
  wait 10.
  LOCK STEERING TO "KILL".
  RCS OFF.
}

until doExit {
  IF TIME - currentProcTime > PROC_TICK_TIME {
    set currentProcTime to TIME.
    MainLoop().
  }
}

SafeExit().
