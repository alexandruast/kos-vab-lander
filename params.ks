// Constants
GLOBAL KERBIN_g is 9.80774584216104.
GLOBAL STEERING_MAGNITUDE_MAX IS 10.
GLOBAL STEERING_MAGNITUDE_MIN IS 1.25.
GLOBAL STEERING_MAX_DP_KPA is 32.
GLOBAL STEERING_MIN_DP_KPA is 12.
GLOBAL STEERING_DP_FACTOR is (STEERING_MAGNITUDE_MAX - STEERING_MAGNITUDE_MIN) / (STEERING_MAX_DP_KPA - STEERING_MIN_DP_KPA).

// Launch pad coordinates
GLOBAL LAUNCHPAD_LATITUDE IS -0.0972077975273179.
GLOBAL LAUNCHPAD_LONGITUDE IS -74.55767719525.
GLOBAL LAUNCHPAD_ELEVATION IS 72.5137703449.
GLOBAL LAUNCHPAD IS LATLNG(LAUNCHPAD_LATITUDE, LAUNCHPAD_LONGITUDE).

// VAB coordinates
GLOBAL VAB_LATITUDE IS -0.0967799450338743.
GLOBAL VAB_LONGITUDE IS -74.6185288120572.
GLOBAL VAB_ELEVATION IS 175.601955831866.
GLOBAL VAB IS LATLNG(VAB_LATITUDE, VAB_LONGITUDE).

// Landing pad coordinates
GLOBAL LANDINGPAD_LATITUDE IS    0.079.
GLOBAL LANDINGPAD_LONGITUDE IS -74.632.
GLOBAL LANDINGPAD_ELEVATION IS  64.75.
GLOBAL LANDINGPAD IS LATLNG(LANDINGPAD_LATITUDE, LANDINGPAD_LONGITUDE).

// Ship information
GLOBAL SHIP_DRAG_COEFFICIENT IS 0.21.
GLOBAL SHIP_RADAR_HEIGHT IS 13.8156.

// Landing site coordinates
GLOBAL LANDINGSITE IS PAD.
GLOBAL LANDINGSITE_ELEVATION IS PAD_ELEVATION.

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
