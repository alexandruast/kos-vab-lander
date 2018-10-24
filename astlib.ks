on ABORT {
  set do_exit to true.
  preserve.
}

function safe_stage {
    wait until stage:ready.
    stage.
}

// Launchpad coordinates
set pad_latitude to -0.0972077635067718.
set pad_longitude to -74.5576726244574.
set pad_elevation to 72.5137703449.
set pad_latlng to latlng(pad_latitude, pad_longitude).

// VAB coordinates
set vab_latitude to -0.0966689182221281.
set vab_longitude to -74.6185288120572.
set vab_elevation to 175.601955831866.
set vab_latlng to latlng(vab_latitude, vab_longitude).

set landingsite to vab_latlng.
set landingsite_elevation to vab_elevation. 

set red_arrow to vecdraw().
set red_arrow:scale to 5.
set red_arrow:color to rgb(255,0,0).

set green_arrow to vecdraw().
set green_arrow:scale to 5.
set green_arrow:color to rgb(0,255,0).

set blue_arrow to vecdraw().
set blue_arrow:scale to 5.
set blue_arrow:color to rgb(0,0,255).

set pink_arrow1 to vecdraw().
set pink_arrow1:scale to 1.
set pink_arrow1:color to rgb(255,128,192).

set pink_arrow2 to vecdraw().
set pink_arrow2:scale to 1.
set pink_arrow2:color to rgb(255,128,192).

set white_arrow1 to vecdraw().
set white_arrow1:scale to 1.
set white_arrow1:color to rgb(255,128,0).

set current_time to missiontime.
// set tick_time to 0.25.
set tick_time to 0.25.

local p_sas is SAS.
local p_sasmode is SASMODE.

local p_rcs is RCS.

set do_exit to false.

// Courtesy of <i_have_no_ideea_from_whom_i_copied_this_code>
// -----------------------------------------------------------------------------
FUNCTION impact_UTs {//returns the UTs of the ship's impact, NOTE: only works for non hyperbolic orbits
	PARAMETER minError IS 1.
	IF NOT (DEFINED impact_UTs_impactHeight) { GLOBAL impact_UTs_impactHeight IS 0. }
	LOCAL startTime IS TIME:SECONDS.
	LOCAL craftOrbit IS SHIP:ORBIT.
	LOCAL sma IS craftOrbit:SEMIMAJORAXIS.
	LOCAL ecc IS craftOrbit:ECCENTRICITY.
	LOCAL craftTA IS craftOrbit:TRUEANOMALY.
	LOCAL orbitPeriod IS craftOrbit:PERIOD.
	LOCAL impactUTs IS time_betwene_two_ta(ecc,orbitPeriod,craftTA,alt_to_ta(sma,ecc,SHIP:BODY,impact_UTs_impactHeight)[1]) + startTime.
	LOCAL newImpactHeight IS ground_track(POSITIONAT(SHIP,impactUTs),impactUTs):TERRAINHEIGHT.
	SET impact_UTs_impactHeight TO (impact_UTs_impactHeight + newImpactHeight) / 2.
	RETURN LEX("time",impactUTs,//the UTs of the ship's impact
	"impactHeight",impact_UTs_impactHeight,//the aprox altitude of the ship's impact
	"converged",((ABS(impact_UTs_impactHeight - newImpactHeight) * 2) < minError)).//will be true when the change in impactHeight between runs is less than the minError
}

FUNCTION alt_to_ta {//returns a list of the true anomalies of the 2 points where the craft's orbit passes the given altitude
	PARAMETER sma,ecc,bodyIn,altIn.
	LOCAL rad IS altIn + bodyIn:RADIUS.
	LOCAL taOfAlt IS ARCCOS((-sma * ecc^2 + sma - rad) / (ecc * rad)).
	RETURN LIST(taOfAlt,360-taOfAlt).//first true anomaly will be as orbit goes from PE to AP
}

FUNCTION time_betwene_two_ta {//returns the difference in time between 2 true anomalies, traveling from taDeg1 to taDeg2
	PARAMETER ecc,periodIn,taDeg1,taDeg2.

	LOCAL maDeg1 IS ta_to_ma(ecc,taDeg1).
	LOCAL maDeg2 IS ta_to_ma(ecc,taDeg2).

	LOCAL timeDiff IS periodIn * ((maDeg2 - maDeg1) / 360).

	RETURN MOD(timeDiff + periodIn, periodIn).
}

FUNCTION ta_to_ma {//converts a true anomaly(degrees) to the mean anomaly (degrees) NOTE: only works for non hyperbolic orbits
	PARAMETER ecc,taDeg.
	LOCAL eaDeg IS ARCTAN2(SQRT(1-ecc^2) * SIN(taDeg), ecc + COS(taDeg)).
	LOCAL maDeg IS eaDeg - (ecc * SIN(eaDeg) * CONSTANT:RADtoDEG).
	RETURN MOD(maDeg + 360,360).
}

FUNCTION ground_track {	//returns the geocoordinates of the position vector at a given time(UTs) adjusting for planetary rotation over time
	PARAMETER pos,posTime,localBody IS SHIP:BODY.
	LOCAL rotationalDir IS VDOT(localBody:NORTH:FOREVECTOR,localBody:ANGULARVEL). //the number of radians the body will rotate in one second
	LOCAL posLATLNG IS localBody:GEOPOSITIONOF(pos).
	LOCAL timeDif IS posTime - TIME:SECONDS.
	LOCAL longitudeShift IS rotationalDir * timeDif * CONSTANT:RADtoDEG.
	LOCAL newLNG IS MOD(posLATLNG:LNG + longitudeShift ,360).
	IF newLNG < - 180 { SET newLNG TO newLNG + 360. }
	IF newLNG > 180 { SET newLNG TO newLNG - 360. }
	RETURN LATLNG(posLATLNG:LAT,newLNG).
}

// -----------------------------------------------------------------------------

// Find terrestrial distance between two coordinates
function dto_latlng {
	parameter d_from is ship:geoposition.
  parameter d_to   is landingsite.
	// Courtesy of Dunbaratu
	local v1 is d_from:position - ship:body:position. // vector from body center to spot on surface.
	local v2 to d_to:position - ship:body:position. // vector from body center to spot on surface.
	return vang(v1, v2) * constant:degtorad * body:radius. // distance of the circumference arc between the two vectors on a circle of the body's radius.
}

// Return mid point between two coordinates
function midpoint {
	parameter a.
	parameter b.
	local dLon is b:lng - a:lng.
  local Bx is cos(b:lat) * cos(dLon).
  local By is cos(b:lat) * sin(dLon).
  local lat is arctan2(sin(a:lat) + sin(b:lat), sqrt((cos(a:lat) + Bx) * (cos(a:lat) + Bx) + By * By)).
  local lng is a:lng + arctan2(By, cos(a:lat) + Bx).
	return latlng(lat,lng).
}

function safe_exit {
  set red_arrow:show to false.
  set green_arrow:show to false.
  set blue_arrow:show to false.
	set pink_arrow1:show to false.
	set pink_arrow2:show to false.
  set white_arrow1:show to false.
  unlock THROTTLE.
  unlock STEERING.
  set ship:control:neutralize to true.
  if p_sas {
    SAS ON.
    set SASMODE to "STABILITYASSIST".
  }
	if p_rcs {
		RCS ON.
	}
  print "[info] ship controls released".
}
