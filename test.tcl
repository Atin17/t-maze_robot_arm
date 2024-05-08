#! /usr/bin/wish

package require Tk

# Create a window
wm title . "T-Shaped Maze"
canvas .c -width 800 -height 800 -background black
pack .c -expand yes -fill both

# Coordinates for the T-shaped maze paths and boundaries
set startX 400
set startY 600
set endX 400
set endY 200
set armLeftX 200
set armRightX 600
set armY 200

# Draw the T-shaped maze
.c create line $startX $startY $startX $endY -width 40 -fill white   ;# Vertical arm
.c create line $armLeftX $armY $armRightX $armY -width 40 -fill white ;# Horizontal arm

# Create a pointer that starts at the bottom of the T
set pointer [.c create oval 390 570 410 590 -fill black]

# Function to move the pointer to a specific position within boundaries
proc moveTo {x y} {
    global pointer .c
    # Define boundaries of the T-shaped maze
    set verticalTop 240
    set verticalBottom 600
    set horizontalLeft 200
    set horizontalRight 600
    set horizontalTop 200
    set horizontalBottom 240
	set horizontalMiddleTop 380
	set horizontalMiddleBottom 420

    # Get current position of the pointer
    set pos [.c coords $pointer]
    set centerX [expr {([lindex $pos 0] + [lindex $pos 2]) / 2}]
    set centerY [expr {([lindex $pos 1] + [lindex $pos 3]) / 2}]

    # Check if movement is within vertical bounds of the T-shape
    if {$y >= $verticalTop && $y <= $verticalBottom} {
        if {$x >= $horizontalMiddleTop && $x <= $horizontalMiddleBottom} {
            set dx [expr {$x - $centerX}]
            set dy [expr {$y - $centerY}]
            .c move $pointer $dx $dy
        }
    }


    # Check if movement is within horizontal bounds of the T-shape
    if {$y >= $horizontalTop && $y <= $horizontalBottom} {
        if {$x >= $horizontalLeft && $x <= $horizontalRight} {
            set dx [expr {$x - $centerX}]
            set dy [expr {$y - $centerY}]
            .c move $pointer $dx $dy
        }
    }
}

# Bind mouse move event to move the pointer
bind . <Motion> {+moveTo %x %y}

# More complex movements and integration with robotic control need to be added
