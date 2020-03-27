
use <FlexCase-Housing.scad>

// BOSL library (e.g. for cable holes)
include <BOSL/constants.scad>
use <BOSL/shapes.scad>
use <BOSL/transforms.scad>

$fn = 40;

//Customize parameters
//-------------------------------------------
enclosureWidth = 80;
enclusureLength = 120;
enclusureHeightTray = 30;
enclusureHeightCover = 3;
coverSleeveOverlap = 4.0;
hullThickness = 2;
cornerRadius = 2.5;
screwDiameter = 4;

// The cover of the housing:
translate([enclosureWidth / 2 + 10, 0, (enclusureHeightCover + coverSleeveOverlap/2])
    cover(enclosureWidth, enclusureLength, enclusureHeightCover,coverSleeveOverlap, hullThickness, cornerRadius, screwDiameter);

// The tray of the housing:
translate([-enclosureWidth / 2 -10, 0, enclusureHeightTray/2]) 
    tray(enclosureWidth, enclusureLength, enclusureHeightTray, hullThickness, cornerRadius, screwDiameter);
