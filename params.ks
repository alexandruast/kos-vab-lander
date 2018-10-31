// Constants
GLOBAL KERBIN_g is 9.80774584216104.
GLOBAL STEERING_MAGNITUDE_MAX IS 10.
GLOBAL STEERING_MAGNITUDE_MIN IS 1.25.
GLOBAL STEERING_MAX_DP_KPA is 32.
GLOBAL STEERING_MIN_DP_KPA is 12.
GLOBAL STEERING_DP_FACTOR is (STEERING_MAGNITUDE_MAX - STEERING_MAGNITUDE_MIN) / (STEERING_MAX_DP_KPA - STEERING_MIN_DP_KPA).

// Launchpad coordinates
GLOBAL PAD_LATITUDE IS -0.0972077635067718.
GLOBAL PAD_LONGITUDE IS -74.6187524481403.
GLOBAL PAD_ELEVATION IS 72.5137703449.
GLOBAL PAD IS LATLNG(PAD_LATITUDE, PAD_LONGITUDE).

// VAB coordinates
GLOBAL VAB_LATITUDE IS -0.0967799450338743.
GLOBAL VAB_LONGITUDE IS -74.6185288120572.
GLOBAL VAB_ELEVATION IS 175.601955831866.
GLOBAL VAB IS LATLNG(VAB_LATITUDE, VAB_LONGITUDE).

// Ship information
GLOBAL SHIP_DRAG_COEFFICIENT IS 0.21.
GLOBAL SHIP_RADAR_HEIGHT IS 13.8156.

// Landing site coordinates
GLOBAL LANDINGSITE IS VAB.
GLOBAL LANDINGSITE_ELEVATION IS VAB_ELEVATION.

// Altitude where vehicle should be above the landing site,
// and with 0 horizontal velocity
GLOBAL GLIDE_TOWARDS_ALTITUDE IS 3000.

// Airbrakes works by triggering BRAKES to ON, if you have them equipped
GLOBAL AIRBRAKES_ENABLED IS TRUE.

// Parachute staging will work by triggering CHUTES to on, if you have them equipped
GLOBAL PARACHUTES_ENABLED IS FALSE.

// Suicide burn parameters
// If a body has atmosphere, do not trigger a hoverslam burn until airspeed
GLOBAL SUICIDEBURN_ATM_AIRSPEED_MAX IS 1000.

// SUICIDEBURN_UNTIL_GROUND_ALTITUDE states at which altitude above ground
// the aggressive suicide burn will stop, with a remaining
// vertical velocity of SUICIDEBURN_STOP_VSPEED
GLOBAL SUICIDEBURN_UNTIL_GROUND_ALTITUDE IS 50.
GLOBAL SUICIDEBURN_UNTIL_VSPEED IS 10.

// Pinpoint descent parameters
// PPD_UNTIL_ALTITUDE states at which altitude above landing site
// the pinpoint descending burn will stop, with a remaining
// vertical velocity of PPD_UNTIL_VSPEED
GLOBAL PPD_UNTIL_ALTITUDE IS 1.5.
GLOBAL PPD_UNTIL_VSPEED IS 1.25.

// SUICIDEBURN_GRACE_MULTIPLIER is used to multiply the stopping_distance,
// to leave some room for error
GLOBAL SUICIDEBURN_GRACE_MULTIPLIER IS 1.

// processing interval
GLOBAL PROC_TICK_TIME IS 0.25.

// console ui refresh interval
GLOBAL UI_TICK_TIME IS 1. 

// Show debug messages and draw vectors on screen
GLOBAL DEBUG_ON IS TRUE.
