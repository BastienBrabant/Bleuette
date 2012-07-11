
$fn = 50;

BODY_THICKNESS = 5;
BODY_SERVO_HOLE_DIAMETER = 6;

BODY_WIDTH = 100;
BODY_LENGTH = 320;

SUPPORT_SPACE = 65.0;

RADIUS = 7;

module leg_support(length = 25, width = 30) {

    translate([0, length / 2 , 0]) {
        difference() {
            union() {
                union() {
                    cube(size = [width, length, BODY_THICKNESS], center = true);

                    translate([0, length / 2, 0]) {
                        cylinder(r = width / 2, h = BODY_THICKNESS, center = true);
                    }
                }

                difference() {
                    translate([0, - length / 2 + RADIUS / 2, 0]) {
                        cube(size = [width + RADIUS * 2, RADIUS, BODY_THICKNESS], center = true);
                    }

                    translate([(width + RADIUS * 2) / 2, (- length / 2 + RADIUS / 2) + RADIUS / 2, -5]) {
                        cylinder(r = RADIUS, h = 20);
                    }

                    translate([- (width + RADIUS * 2) / 2, (- length / 2 + RADIUS / 2) + RADIUS / 2, -5]) {
                        cylinder(r = RADIUS, h = 20);
                    }
                }
            }

            // Hole
            translate([0, length / 2, -1]) {
                cylinder(r = BODY_SERVO_HOLE_DIAMETER / 2, h = BODY_THICKNESS + 5, center = true);
            }
        }
    }
}

module rbox(width, length, thickness = BODY_THICKNESS) {

    cube(size = [length - RADIUS * 2, width, thickness], center = true);
    cube(size = [length, width - RADIUS * 2, thickness], center = true);

    // Rounded corner
    translate([ length / 2 - RADIUS, width / 2 - RADIUS, - thickness / 2 ]) {
        cylinder(r = RADIUS, h = thickness);
    }

    translate([ length / 2 - RADIUS, - (width / 2 - RADIUS), - thickness / 2 ]) {
        cylinder(r = RADIUS, h = thickness);
    }

    translate([ - (length / 2 - RADIUS), width / 2 - RADIUS, - thickness / 2 ]) {
        cylinder(r = RADIUS, h = thickness);
    }

    translate([ -(length / 2 - RADIUS), - (width / 2 - RADIUS), - thickness / 2 ]) {
        cylinder(r = RADIUS, h = thickness);
    }
}

module body() {

    width = BODY_WIDTH;
    length = BODY_LENGTH;
    thickness = BODY_THICKNESS;

    rbox(width, length, thickness);

    // Leg support
    translate([0, width / 2, 0]) {
        leg_support();
    }

    translate([0, - width / 2, 0]) {
        rotate([0, 0, 180]) {
            leg_support();
        }
    }

    translate([length / 2 - 30, width / 2, 0]) {
        leg_support();
    }

    translate([length / 2 - 30, - width / 2, 0]) {
        rotate([0, 0, 180]) {
            leg_support();
        }
    }

    translate([- (length / 2 - 30), width / 2, 0]) {
        leg_support();
    }

    translate([- (length / 2 - 30), - width / 2, 0]) {
        rotate([0, 0, 180]) {
            leg_support();
        }
    }
}

module body_support() {

    width = 50;
    length = BODY_LENGTH;
    thickness = BODY_THICKNESS;

    leg_length = BODY_WIDTH / 2 - width / 2 + 25;

    rbox(width, length, thickness);

    // Leg support
    translate([0, width / 2, 0]) {
        leg_support(leg_length);
    }

    translate([0, - width / 2, 0]) {
        rotate([0, 0, 180]) {
            leg_support(leg_length);
        }
    }

    translate([length / 2 - 30, width / 2, 0]) {
        leg_support(leg_length);
    }

    translate([length / 2 - 30, - width / 2, 0]) {
        rotate([0, 0, 180]) {
            leg_support(leg_length);
        }
    }

    translate([- (length / 2 - 30), width / 2, 0]) {
        leg_support(leg_length);
    }

    translate([- (length / 2 - 30), - width / 2, 0]) {
        rotate([0, 0, 180]) {
            leg_support(leg_length);
        }
    }
}

if (1) {
    body();

    translate([0, 0, SUPPORT_SPACE]) {
        body_support();
    }
} else {
    leg_support();
}

