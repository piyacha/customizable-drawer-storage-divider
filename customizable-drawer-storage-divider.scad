// For smooth render
$fa = 1;
$fs = 0.4;

//Models
Model="X"; //["X": X shape, "L": L shape, "T": T shape]

// (1mm per unit) Thickness of the Walls
Thickness = 2;
// (1mm per unit) Inner Width between the Walls
InnerWidth = 3;
// (1mm per unit) Height of the Walls
Height = 15;
// (1mm per unit) Length of the Walls
Length = 15;
// (1mm per unit) Slope to enchane the strength of structure
SlopeLength = 18;

// Not show in UI
Radius = 1 * 1;
ActualInnerWidth = InnerWidth + Radius;
ActualHeight = Height - Radius;
ActualLength = (Length+InnerWidth+Thickness+(Radius*2))*2 - Radius;

// Round each arm
module arm_with_radius() {
    translate([0, 0, ActualHeight / 2 + Thickness]) {
        minkowski() {
            cube([Thickness, ActualLength, ActualHeight], center = true);
            sphere(Radius);
        }
    }
}

// Central base with rounded edges
module base_with_radius() {
    translate([0, 0, Thickness / 2]) {
        minkowski() {
            cube([ActualInnerWidth * 2 + Thickness * 2, ActualLength, Thickness], center = true);
            sphere(Radius);
        }
    }
}

module inverted_wall(SlopeLength) {
    linear_extrude(height = Height+2) {
        // Original hollow wall
        difference() {
            translate([-SlopeLength, SlopeLength]) {
                square([2 * SlopeLength, 2 * SlopeLength], center = true); // Covers the inner circle
                circle(r = SlopeLength); // Subtract inner circle for alignment
            }
            translate([-SlopeLength, SlopeLength]) // Center the circle at (-Length, Length)
                circle(r = SlopeLength); // Full circle of radius Length

            translate([-SlopeLength, SlopeLength])
                circle(r = SlopeLength - Thickness); // Smaller inner circle to hollow it

            // Cut out right side
            translate([-1 * (SlopeLength * 2), 0])
                square([SlopeLength, (SlopeLength * 2)], center = false); 

            // Cut out upper side
            translate([-1 * (SlopeLength * 2), SlopeLength])
                square([(SlopeLength * 2), SlopeLength], center = false);
        }
    }
}

module main(){
    // Main
    union() {
        // ARM 1
        translate([-1 * (ActualInnerWidth + Thickness / 2), 0, 0])
            arm_with_radius();

        // ARM 2
        translate([ActualInnerWidth + Thickness / 2, 0, 0])
            arm_with_radius();

        // ARM 3
        translate([0, -1 * (ActualInnerWidth + Thickness / 2), 0])
            rotate([0, 0, 90])
            arm_with_radius();

        // ARM 4
        translate([0, ActualInnerWidth + Thickness / 2, 0])
            rotate([0, 0, 90])
            arm_with_radius();

        // Base 1
        base_with_radius();

        // Base 2
        rotate([0, 0, 90])
            base_with_radius();
            
        // Create inverted walls on all sides
        for (angle = [0, 90, 180, 270]) {
            transitionX = InnerWidth;
            transitionY = InnerWidth;
            if (angle == 0)  translate([-transitionX, transitionY, -Radius]) rotate([0, 0, angle]) inverted_wall(SlopeLength);
            if (angle == 90) translate([-transitionX, -transitionY, -Radius]) rotate([0, 0, angle]) inverted_wall(SlopeLength);
            if (angle == 180) translate([transitionX, -transitionY, -Radius]) rotate([0, 0, angle]) inverted_wall(SlopeLength);
            if (angle == 270) translate([transitionX, transitionY, -Radius]) rotate([0, 0, angle]) inverted_wall(SlopeLength);
        }
    }
}

main();
