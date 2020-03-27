//--------------------------------
//FlexCase Enclosure / Housing
//--------------------------------

// BOSL library
include <BOSL/constants.scad>
use <BOSL/shapes.scad>
use <BOSL/masks.scad>
use <BOSL/transforms.scad>

$fn = 40;

sleeveHullThickness = 2;

//Customize Screw blocks
//---------------------------
screwBlockWidth = 10;

// to avoid render problems (z-fighting) due to identical surfaces when using difference():
difference_overlap = 0.1; 

//===========================================================
// Public Modules
//===========================================================
/**
* Creates the cover of the housing / enclosure
* 
* @param trayWidth The Width (x) of the housing (outer dimension)
* @param trayLength The Length (y) of the housing (outer dimension)
* @param effectiveHeight The height (z) of the housing cover (outer dimension). Overlapping sleeve is not included.
* @param coverSleeveOverlap the overlap of the cover sleeve over the tray
* @param hullThickness The thickness of the hull
* @param cornerRadius Radius of the corners/edges
* @param screwDiameter The diameter of the screw threading
*/
module cover(trayWidth, trayLength, effectiveHeight, coverSleeveOverlap, hullThickness, cornerRadius, screwDiameter) {
    width = trayWidth + 2*sleeveHullThickness;
    length = trayLength + 2*sleeveHullThickness;
    height = effectiveHeight + coverSleeveOverlap;
    
    difference() {
        rawCover();
        screwHoles();
    }
    
    // sub-module
    module rawCover() {
        sleeveTolerance= 0.4;
        difference() {
            // raw block
            cuboid([width,length,height], fillet=cornerRadius, edges=EDGES_Z_ALL);
            
            // clearance as in tray:
            translate([0,0,hullThickness/2 + difference_overlap/2]) 
                cuboid([trayWidth-2*hullThickness,trayLength-2*hullThickness,height-hullThickness + difference_overlap], fillet=cornerRadius, edges=EDGES_Z_ALL);
            
            // sleeve clearance
            translate([0,0,(height-coverSleeveOverlap + difference_overlap)/2])
                cuboid([width-2*sleeveHullThickness + sleeveTolerance,length-2*sleeveHullThickness + sleeveTolerance, coverSleeveOverlap + difference_overlap], fillet=cornerRadius, edges=EDGES_Z_ALL);
        } 
        
        screwBlocks();
    }
    
    // sub-module
    module screwBlocks() {
        screwBlockHeight = height-coverSleeveOverlap-hullThickness;
        
        moveX = (width-screwBlockWidth)/2 -sleeveHullThickness- hullThickness;
        moveY = (length-screwBlockWidth)/2-sleeveHullThickness - hullThickness;
        moveZ = -(height/2 - hullThickness) +screwBlockHeight/2;
        
        translate([moveX, moveY, moveZ]) cuboid([screwBlockWidth,screwBlockWidth, screwBlockHeight], fillet=cornerRadius, edges=EDGE_FR_LF);
        translate([-moveX, moveY, moveZ]) cuboid([screwBlockWidth,screwBlockWidth, screwBlockHeight], fillet=cornerRadius, edges=EDGE_FR_RT);
        translate([moveX, -moveY, moveZ]) cuboid([screwBlockWidth,screwBlockWidth, screwBlockHeight], fillet=cornerRadius, edges=EDGE_BK_LF);
        translate([-moveX, -moveY, moveZ]) cuboid([screwBlockWidth,screwBlockWidth, screwBlockHeight], fillet=cornerRadius, edges=EDGE_BK_RT);
    }
    
    // sub-module
    module screwHoles() {
        // Add & place screw blocks in the corners:
        x_toMove = (width-screwBlockWidth)/2 -sleeveHullThickness- hullThickness;
        y_toMove = (length-screwBlockWidth)/2 -sleeveHullThickness- hullThickness;
        z_toMove = (height)/2;
        
        // Screw holes
        holeDiameter = screwDiameter + 0.33;        
        translate([x_toMove, y_toMove, -z_toMove]) zcyl(l= height * 10, d=holeDiameter);
        translate([-x_toMove, y_toMove, -z_toMove]) zcyl(l=height * 10, d=holeDiameter);
        translate([x_toMove, -y_toMove, -z_toMove]) zcyl(l=height * 10, d=holeDiameter);
        translate([-x_toMove, -y_toMove, -z_toMove]) zcyl(l=height * 10, d=holeDiameter);
    }
}


/**
* Creates the tray of the housing / enclosure
*
* @param width The Width (x) of the housing (outer dimension)
* @param length The Length (y) of the housing (outer dimension)
* @param height The height (z) of the housing tray (outer dimension)
* @param hullThickness The thickness of the hull
* @param cornerRadius Radius of the corners/edges
* @param screwDiameter The diameter of the screw threading
*/
module tray(width, length, height, hullThickness, cornerRadius, screwDiameter) {
    _printInnerDimensions("Tray", width, length, height, hullThickness);
    _enclusure_half(width, length, height, hullThickness, cornerRadius, true, screwDiameter);
}

//===========================================================
// Private / Internal Modules
//===========================================================

/**
Computes and logs the inner dimensions of the housing
*/
module _printInnerDimensions(component, width, length, height, hullThickness) {
    echo("Computed inner dimensions for ", component);
    echo("maximum width=", width - 2* hullThickness);
    echo("minimum width (between screwblocks)=", width -2* screwBlockWidth - 2* hullThickness);
    echo("maximum length=", length - 2* hullThickness);
    echo("minimum length (between screwblocks)=", length -2* screwBlockWidth - 2* hullThickness);
    echo("height=", height - hullThickness);
}


/**
Creates a half part with screw blocks of the enclosure.
*/
module _enclusure_half(width, length, height, hullThickness, cornerRadius, withThreadingHole, screwDiameter) {
    difference() {
        _raw_block(width, length, height, cornerRadius);
        translate([0, 0, (hullThickness + difference_overlap)/2]) _raw_block(width-2*hullThickness, length-2*hullThickness, height- hullThickness + difference_overlap, cornerRadius);
    }
    
    // Add & place screw blocks in the corners:
    x_toMove = (width-screwBlockWidth)/2 -hullThickness;
    y_toMove = (length-screwBlockWidth)/2 -hullThickness;
    z_toMove = (hullThickness)/2;
    for(x=[x_toMove, -x_toMove]) {
       for(y=[y_toMove, -y_toMove]) {
           if((x>0) && (y<0)) {
               zRotation = -90;
               putScrewBlock(zRotation, x, y, z_toMove);
           }
           if((x>0) && (y>0)) {
               zRotation = 0;
               putScrewBlock(zRotation, x, y, z_toMove);
           }
           if((x<0) && (y>0)) {
               zRotation = 90;
               putScrewBlock(zRotation, x, y, z_toMove);
           }
           if((x<0) && (y<0)) {
               zRotation = 180;
               putScrewBlock(zRotation, x, y, z_toMove);
           }
       }
    }
    
    // sub-module
    module putScrewBlock(zRotation, x, y, z) {
        translate([x, y, z_toMove]) rotate([0,0,zRotation]) // rotate & move to corner
                _raw_screw_block(screwBlockWidth, height - hullThickness, hullThickness, cornerRadius, withThreadingHole, screwDiameter);
    }
}


/**
Creates a screw block.
*/
module _raw_screw_block(width, height, hullThickness, cornerRadius, withThreadingHole, screwDiameter) {
    difference() {
        translate([-width/2, -width/2, -height/2]) // center the block
            difference() { // create block with one rounded edge:
                cube([width, width, height], center=false);
                fillet_mask_z(l=height, r=cornerRadius, align=V_UP);
            } 

        //create metric screw hole   
        if(withThreadingHole) {
            holeDiameter = screwDiameter - 1.0; // make it smaller so that the screw has enough grip
            //(height+difference_overlap)/2
            translate([0, 0, (hullThickness + difference_overlap)/2]) 
                zcyl(l= height - hullThickness + difference_overlap, d=holeDiameter);
        }
    }
}


/**
Creates a raw block with rounded edges - e.g. to create the enclosing tray or top.
*/
module _raw_block(width, length, height, cornerRadius) {
    hull() {
        // base body
        cube([width - 2*cornerRadius, length- 2*cornerRadius, height], center=true);

        // for rounded edges:
        for(x=[-width/2 + cornerRadius, width/2 - cornerRadius]) {
           for(y=[-length/2 + cornerRadius, length/2 - cornerRadius]) {
               translate([x, y, 0])
               cylinder(h=height, r=cornerRadius, center=true);       
           }
        }
    }
}
