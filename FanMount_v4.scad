FOREVER = 1000;
MAIN_FAN_SIZE = 40;
$fn = 60;

/**
Useful to cut away half of everything past a point.
vector is normalized and used as the direction in which lies the returned shape.
Currently only works well with cardinal directions, unless you enable
SPHERE mode, in which case there's a bit of curvature, and you may want
to increase $fn.
*/
module halfDomain(vector = [0,0,1], FOREVER = 1000, SPHERE = false) {
    v = vector / norm(vector);
    if (SPHERE) {
        translate(v * FOREVER/2)
          sphere(d=FOREVER, center=true);
    } else {
        translate(v * FOREVER/2)
          cube(FOREVER, center=true);
    }
}

/* [Hotend] */

// Hotend's heatsink diameter
heatsinkDiameter = 25;  // [15:29]
// Length of the clamp
clampLength = 30;  // [18.125:0.125:32.5]
// Z-Probe screw notch
zProbeScrew = 0;  // [1:Present, 0:Absent]
// Height of the Z-Probe Screw
zProbeScrewHeight = 12;  // [0:26]

// Size of anchor nub
ANCHOR_SZ = 1;

/* [Fans] */

// Number of fans
sideFanType = 3;  // [0:None, 1:Single, 2: Double, 3: 40mm]
// Side fan mouth size
widerMouth = 0;  // [1:Bigger, 0:Normal]

// E3D V6 chinese clone placeholder
% union() {
  cylinder(30, heatsinkDiameter / 2, heatsinkDiameter / 2, $fn = 200);
  translate([0, 0, 30]) cylinder(6, 3, 3);
  translate([-14.5, -10, 36]) cube([20, 20, 10]);
  translate([0, 0, 46]) cylinder(4, 3, 3);
  translate([0, 0, 50]) cylinder(3, 3, 0.4);
}

module e3d() {
  translate([0, 0, -1]) cylinder(32, heatsinkDiameter / 2, heatsinkDiameter / 2, $fn = 200);
}

module sideCurve40() {
  intersection() {
    translate([-5 + (30 - clampLength), -20, 0]) cube([clampLength, 8, 25]);
    translate([20, 30, -1]) cylinder(32, 50, 50, $fn = 500);
  }
}

module topCurve40(cut = true) {
  difference() {
    difference() {
      translate([20, -20, 24.5]) rotate([0, 0, 90]) cube([33.25, 14, 15.5]);
      translate([1, 0, 38.8275]) rotate([90, 0, 0]) cylinder(44, 15, 15, true, $fn = 200);
    }
    if (cut) {
      e3d();
      translate([20, -21, 0]) rotate([0, -90, 0]) cube([50, 7.75, 15]);
    }
  }
}

module topCurve40Corner() {
  intersection() {
    translate([0, -15, 0]) topCurve40(false);
    translate([0, 0, 25]) sideCurve40();
    translate([20, -21, 0]) rotate([0, -90, 0]) cube([50, 7.75, 15]);
  }
}

module m3Hole() {
  cylinder(16, 1.5, 1.5, $fn = 50);
}

module mainBody() {
  // Hot end attachment & 40mm fan mount
  difference() {
    union() {
      // Hot end attachment
      difference() {
        translate([-3, -13.25, 0]) cube([25, 26.5, 25]);
        e3d();
      }

      // Fan mount
      translate([25, -20, 0]) rotate([0, -90, 0]) cube([40, 40, 6]);

      // Side curves
      difference() {
        union() {
          sideCurve40();
          mirror([0, 1, 0]) sideCurve40();
        }
        difference() {
          e3d();
          translate([0,0,ANCHOR_SZ])
            halfDomain([0,0,-1]);
        }
      }

      // Top curve
      topCurve40(true);
      topCurve40Corner();
      mirror([0, 1, 0]) topCurve40Corner();
    }
    // Fan funnel
    hull() {
      translate([5, 0, 11]) rotate([0, 75, 0]) cylinder(30, 11, 12.5, $fn = 100);
      translate([26, 0, 20]) rotate([0, 90, 0]) cylinder(1, 18, 18, $fn = 100);
    }
    // M3 holes
    translate([10, -16, 4]) rotate([0, 90, 0]) m3Hole();
    mirror([0, 1, 0]) translate([10, -16, 4]) rotate([0, 90, 0]) m3Hole();
    translate([10, -16, 36]) rotate([0, 90, 0]) m3Hole();
    mirror([0, 1, 0]) translate([10, -16, 36]) rotate([0, 90, 0]) m3Hole();
  }
}

module sideMount() {
  translate([-5, -50, 15]) hull() {
    cube([30, 30, 1.25]);
    translate([0, 0, 15]) cube([30, 30, 1.25]);
  }
}

module sideBodyHollowed() {
  // 30mm fan mount
  union() {
    difference() {
      // Shell
      hull() {
        sideMount();
        translate([-6, -36.25, 40]) cube([22.5, 16.25, 1]);
      }
      // Hollow
      hull() {
        translate([0.9, -5.3, 3]) scale([0.9, 0.8, 0.9]) sideMount();
        translate([-5, -35.45, 40]) rotate([5, 0, 0]) scale([0.85, 0.9, 1]) cube([22.5, 16.25, 1.5]);
      }
    }
    
    translate([0, 0, -1]) difference() {
      // Shell
      hull() {
        translate([-6, -36.25, 40]) cube([22.5, 16.25, 2]);
        translate([-7.75, -19.6, 50.75]) scale([1.25, 1.25, 1.25]) rotate([-45, 0, 0]) if (widerMouth) {
            translate([0, -1.25, 0]) cube([15, 6.5, 1]);
        } else {
            translate([0, -0.25, 0]) cube([15, 4.5, 1]);
        }
      }
      // Hollow
      hull() {
        translate([-5, -35.45, 38]) rotate([5, 0, 0]) scale([0.9, 0.9, 2.5]) cube([22.5, 16.25, 1.5]);
        translate([-6, -19.6, 50]) rotate([-45, 0, 0]) if (widerMouth) {
           translate([0, -1, 0]) cube([15, 6, 2]);
        } else {
            cube([15, 4, 2]);
        }
      }
   }
  }
}

module sideBodyHoles() {
  translate([10, -35, 20]) cylinder(15, 13.5, 10, $fn = 100, true);
  translate([22, -22.5, 12]) union() {
    translate([0, 0, 0]) m3Hole();
    translate([0, -24, 0]) m3Hole();
    translate([-24, 0, 0]) m3Hole();
    translate([-24, -24, 0]) m3Hole();
  }
}

module sideBody() {
  difference() {
    sideBodyHollowed();
    sideBodyHoles();
  }
}

/**
Note that WALL_THICKNESS isn't perfectly accurate, because of the complexity of the corners; it's more of a guideline.
*/
module side40mm(SIZE = 40,
        HEIGHT = 52,
        SLANT = 30,
        CUTOFF_OFFSET_Y = 0,
        OUTCROP = 8,
        OUTCROP_ANGLE = 36,
        OUTCROP_OFFSET_Z = -7,
        WALL_THICKNESS = 1) {
            
    SKEW = 0.1;
    SIDE_OFFSET_X = (SKEW*SIZE)-10;
    module sub(SIZE, HEIGHT, SLANT, CUTOFF_OFFSET_Y, OUTCROP, OUTCROP_ANGLE, OUTCROP_OFFSET_Z, MAIN_FAN_SIZE) {
        CUTOFF = CUTOFF_OFFSET_Y + SLANT;
        translate([0,MAIN_FAN_SIZE/2 - SLANT,0])
        translate([0,CUTOFF,0])
        difference() {
            translate([0,-CUTOFF,0])
              linear_extrude(height = HEIGHT * ((SIZE + SLANT)/(SIZE+OUTCROP)), center = false, convexity = 10, scale=0)
              translate([-SIZE * SKEW,SLANT,0])
              square(SIZE);
            translate([0,0,MAIN_FAN_SIZE+OUTCROP_OFFSET_Z])
            difference() {
              translate([0,-FOREVER/2,0])
                cube(FOREVER, center=true);
              rotate([OUTCROP_ANGLE, 0, 0])
                translate([0,FOREVER/2,0])
                cube(FOREVER, center=true);
            }
            translate([0,-OUTCROP-FOREVER/2,0])
              cube(FOREVER, center=true);
        }
    }
    
    MOUNT_SX = SIZE;
    MOUNT_SY = SIZE;
    MOUNT_SZ = 7;
    MOUNT_HOLE_INSET = 4;
    MOUNT_RADIAL_THICKNESS = 2*MOUNT_HOLE_INSET;
    MOUNT_CYLINDER_HOLE_DIAM = MOUNT_SX - 4;
    SCREW_HOLE_DIAM = 3;
    SCREW_HOLE_DEPTH = 13;
    SCREW_SHEATH_THICKNESS = 2;
    
    translate([SIDE_OFFSET_X,0,0])
    difference() {
        union() {
            difference() {
                sub(SIZE, HEIGHT, SLANT, CUTOFF_OFFSET_Y, OUTCROP, OUTCROP_ANGLE, OUTCROP_OFFSET_Z, MAIN_FAN_SIZE);
                translate([WALL_THICKNESS-2*SKEW,0,0])
                  sub(SIZE-2*WALL_THICKNESS, HEIGHT-WALL_THICKNESS, SLANT, CUTOFF_OFFSET_Y, OUTCROP+WALL_THICKNESS, OUTCROP_ANGLE, OUTCROP_OFFSET_Z-2*WALL_THICKNESS, MAIN_FAN_SIZE+2*WALL_THICKNESS);
            }
            
            translate([SIZE*(1/2 - SKEW), MOUNT_SY/2 + MAIN_FAN_SIZE/2, MOUNT_SZ/2]) {
                difference() { // Fan mount
                    union() {
                        cube([MOUNT_SX, MOUNT_SY, MOUNT_SZ], center=true);
                        if (MOUNT_SX < 35) { // Kinda ad-hoc; tweak if incorrect
                            translate([MOUNT_SX/2,MOUNT_SY/(2*3) - MOUNT_SY/2, MOUNT_SZ/2])
                              cube([(35-MOUNT_SX)*2, MOUNT_SY/3, MOUNT_SZ*2], center=true);
                        }
                    }
                    cube([MOUNT_SX-2*MOUNT_RADIAL_THICKNESS, MOUNT_SY-2*MOUNT_RADIAL_THICKNESS, FOREVER], center=true);
                    cylinder(d=MOUNT_CYLINDER_HOLE_DIAM, h=FOREVER, center=true);
                }
                for (i=[0:3]) { // Screw sheathes
                    rotate([0,0,90*i])
                      translate([MOUNT_SX/2-MOUNT_HOLE_INSET, MOUNT_SY/2-MOUNT_HOLE_INSET, SCREW_HOLE_DEPTH/2 - MOUNT_SZ/2])
                      translate([0,0,SCREW_SHEATH_THICKNESS/2])
                      cylinder(d=SCREW_HOLE_DIAM+2*SCREW_SHEATH_THICKNESS, h=SCREW_HOLE_DEPTH+SCREW_SHEATH_THICKNESS, center=true);
                }
            }
        }
        
        translate([SIZE*(1/2 - SKEW), MOUNT_SY/2 + MAIN_FAN_SIZE/2, SCREW_HOLE_DEPTH/2]) { // Fan mount holes
            for (i=[0:3]) {
                rotate([0,0,90*i])
                  translate([MOUNT_SX/2-MOUNT_HOLE_INSET, MOUNT_SY/2-MOUNT_HOLE_INSET, 0])
                  cylinder(d=SCREW_HOLE_DIAM, h=SCREW_HOLE_DEPTH, center=true);
            }
        }
    }
}

module finalPiece() {
  union() {
    mainBody();
    if (sideFanType == 0) {
    } else if (sideFanType == 1) {
        sideBody();
    } else if (sideFanType == 2) {
        sideBody();
        mirror([0, 1, 0]) sideBody();
    } else if (sideFanType == 3) {
        mirror([0, 1, 0]) side40mm();
    } else {
    }
  }
}

if (zProbeScrew) {
  difference() {
      finalPiece();
      translate([-9, 11.75, -1]) cube([10, 5, zProbeScrewHeight + 1]);
  }
} else {
  finalPiece();
}