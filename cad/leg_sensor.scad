
use <spacer.scad>
use <lib/polyScrewThread.scad>

$fn = 50;

ARM_THICKNESS = 3.8;

ARMS_SPACING = 20;
ARM_WIDTH = 20;

SUPPORT_HEIGHT = 30;
SUPPORT_DIAMETER = 7.7;

SCREW_DIAMETER = 2.7;

module piston() {
    clear = 0.2;
    difference() {
        cylinder(r = ARMS_SPACING / 2, h = SUPPORT_HEIGHT);

        // 1
        translate([0, 0, SUPPORT_HEIGHT - 20]) {
            cylinder(r = 3.7, h = 20);
        }

        // 2
        cylinder(r = 2.5, h = SUPPORT_HEIGHT);

        // 3
        cylinder(r = 6.5, h = 8.5);

        holes();
    }

    translate([0, 0, 3]) {
        torus(9.2);
    }
}

module external() {
    clear = 0.3;
    difference() {
        cylinder(r = 12.5, h = 17);

        translate([0, 0, -0.5]) {
            cylinder(r = ARMS_SPACING / 2 + clear, h = SUPPORT_HEIGHT + 1);
        }

        translate([0, 0, 3]) {
            torus(10.5, 1.2);
        }
    }

    difference() {
        translate([0, 0, -7.5]) {
            thread(25, 7.5);
        }

        translate([0, 0, -7.6]) {
            cylinder(r = 1.6, h = 20);
        }

        translate([0, 0, -2]) {
            cylinder(r = 2.5, h = 6, $fn = 6);
        }

        translate([0, 0, -7.5]) {
            cylinder(r = 4, h = 2);
        }
    }
}

module sensor() {
    clear = 0.92;

    scale([clear, clear, clear]) {
        cylinder(r = 6.5, h = 8.5);
        holes(false);
    }

    translate([0, 0, 8.5 / 2]) {
        torus();
    }
}

module torus(size = 5.5, radius = 1) {
    rotate_extrude(convexity = 10, $fn = 100) {
        translate([size, 0, 0]) {
            circle(r = radius, $fn = 100);
        }
    }
}

module holes(complete = true) {
    // Holes
    translate([0, 6.3, 0]) {
        hole(complete);
    }

    translate([0, -6.3, 0]) {
        hole(complete);
    }

    translate([6.3, 0, 0]) {
        hole(complete);
    }

    translate([-6.3, 0, 0]) {
        hole(complete);
    }
}

module hole(complete = true) {
    if (complete) {
        cylinder(r = 1.6, h = SUPPORT_HEIGHT);
        cylinder(r = 2.7, h = 15.5);
    } else {
        cylinder(r = 2.7, h = 8.5);
    }
}

module thread(diameter, height) {
    b_hg=0; //distance of knurled head

    $fn = 36;
    PI=3.141592;

    /* Screw thread parameters
    */
    t_od=diameter; // Thread outer diameter
    t_st=2.5; // Step/traveling per turn
    t_lf=55; // Step angle degrees
    t_ln=height; // Length of the threade section
    t_rs=PI/2; // Resolution
    t_se=1; // Thread ends style
    t_gp=0; // Gap between nut and bolt threads

    //cylinder(r = diameter / 2, h = height);
    screw_thread(t_od+t_gp, t_st, t_lf, t_ln, t_rs, t_se);
}

module base() {
    translate([0, 0, -7.5]) {
        //thread();
    }

    sensor();
}

//base();

//piston();

external();

