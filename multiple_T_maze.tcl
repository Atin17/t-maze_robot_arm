#! /usr/bin/wish

package require Tk

# Create a window
wm title . "T-Shaped Maze Generator"
canvas .c -width 1920 -height 1080 -background white
pack .c -expand yes -fill both

# Initialize random seed
expr {srand([clock seconds])}

set barWidth 80
set barCoordChange 100
set overlapCheck 40

# Base T structure
set bars {
    {950 440 950 640 v} 
    {850 400 1050 400 h}  
}

# Helper function to calculate the absolute value
proc absValue {x} {
    if {$x < 0} {
        return [expr {-$x}]
    }
    return $x
}

set pointer_id ""

proc drawEverything {} {
    global bars .c pointer_id barWidth

    .c delete all  ;# Clear the canvas

    # Draw the bars
    foreach bar $bars {
        lassign $bar startX startY endX endY orientation
        .c create line $startX $startY $endX $endY -width $barWidth -fill black
    }

    # Create or recreate the pointer
    if {$pointer_id != "" && [.c exists $pointer_id]} {
        .c coords $pointer_id 950 530 970 550
    } else {
        set pointer_id [.c create oval 950 530 970 550 -fill white]
    }
}

# Function to check for duplicate or overlapping bars within a range of ±20
proc isDuplicateBar {newBar newBars} {
    global overlapCheck
    foreach bar $newBars {
        set startX1 [lindex $bar 0]
        set startY1 [lindex $bar 1]
        set endX1 [lindex $bar 2]
        set endY1 [lindex $bar 3]
        set orientation1 [lindex $bar 4]

        set startX2 [lindex $newBar 0]
        set startY2 [lindex $newBar 1]
        set endX2 [lindex $newBar 2]
        set endY2 [lindex $newBar 3]
        set orientation2 [lindex $newBar 4]

        #puts $bar
        #puts $newBar

        if {$orientation1 == "v" && $orientation2 == "h"} {
            if {([absValue [expr {$startX1 - $startX2}]] <= $overlapCheck || [absValue [expr {$endX1 - $endX2}]] <= $overlapCheck) &&
                ($startY1 <= $endY2 && $endY2 <= $endY1)} {
                return 1
            }
        } elseif {$orientation1 == "h" && $orientation2 == "v"} {
            if {([absValue [expr {$startY1 - $startY2}]] <= $overlapCheck || [absValue [expr {$endY1 - $endY2}]] <= $overlapCheck) &&
                ($startX1 <= $endX2 && $endX2 <= $endX1)} {
                return 1
            }
        } elseif {$orientation1 == "v" && $orientation2 == "v"} {
            if {[absValue [expr {$endY1 - $startY2}]] <= 20 && [absValue [expr {$endX1 - $startX2}]] > 80} {
                return 1
            }
        } elseif {$orientation1 == "h" && $orientation2 == "h"} {
            if {[absValue [expr {$endX1 - $startX2}]] <= 20 && [absValue [expr {$endY1 - $startY2}]] > 80} {
                return 1
            }
        }


    }
    return 0
}

# Function to add a bar at a random end of the last level's bars
# Function to add a bar at a random end of the last level's bars
proc expandMaze {level} {
        global bars barWidth barCoordChange

        if {$level <= 1} {
            return
        }

        set newBars {}
        set lastBar [lindex $bars end]
        lassign $lastBar startX startY endX endY orientation

        if {$orientation == "v"} {
            set newBar [list [expr {$endX - $barCoordChange}] [expr {$endY + $barWidth / 2}] [expr {$endX + $barCoordChange}] [expr {$endY + $barWidth / 2}] h]  ;# Top horizontal
            if {$endX >= $barCoordChange && [expr {$endX + $barCoordChange}] <= 1600 && $endY <= 1560} {
                lappend newBars $newBar
            }
            set newBar [list [expr {$startX - $barCoordChange}] [expr {$startY - $barWidth / 2}] [expr {$startX + $barCoordChange}] [expr {$startY - $barWidth / 2}] h]  ;# Bottom horizontal
            if {$startX >= $barCoordChange && [expr {$startX + $barCoordChange}] <= 1600 && $startY >= $barWidth} {
                lappend newBars $newBar
            }
        } elseif {$orientation == "h"} {
            set newBar [list [expr {$startX - $barWidth / 2}] [expr {$startY - $barCoordChange}] [expr {$startX - $barWidth / 2}] [expr {$startY + $barCoordChange}] v]  ;# Left vertical
            if {$startY >= $barCoordChange && [expr {$startY + $barCoordChange}] <= 1600 && $startX >= $barWidth} {
                lappend newBars $newBar
            }
            set newBar [list [expr {$endX + $barWidth / 2}] [expr {$startY - $barCoordChange}] [expr {$endX + $barWidth / 2}] [expr {$startY + $barCoordChange}] v]  ;# Right vertical
            if {$startY >= $barCoordChange && [expr {$startY + $barCoordChange}] <= 1600 && $endX <= 1560} {
                lappend newBars $newBar
            }
        }

        # Keep trying to add a unique new bar until successful
        while {[llength $newBars] > 0} {
            set idx [expr {int(rand() * [llength $newBars])}]
            set candidateBar [lindex $newBars $idx]

            if {![isDuplicateBar $candidateBar $bars]} {
                lappend bars $candidateBar
                break
            } else {
                set newBars [lreplace $newBars $idx $idx]
            }
        }

        # Recurse to the next level
        expandMaze [expr {$level - 1}]
    }

# Function to check if a point is inside any bar
proc isInsideBar {x y} {
    global bars
    foreach bar $bars {
        lassign $bar startX startY endX endY orientation
        if {$orientation == "h" && $x >= $startX && $x <= $endX && $y >= [expr {$startY - 20}] && $y <= [expr {$startY + 20}]} {
            return 1
        } elseif {$orientation == "v" && $y >= $startY && $y <= $endY && $x >= [expr {$startX - 20}] && $x <= [expr {$startX + 20}]} {
            return 1
        }
    }
    return 0
}

proc movePointerWithMouse {x y} {
    global pointer_id .c

    if {[isInsideBar $x $y]} {
        set pos [.c coords $pointer_id]
        if {[llength $pos] != 4} {
            puts "Invalid pointer coordinates"
            puts [llength $pos]
            return
        }
        lassign $pos x1 y1 x2 y2
        set dx [expr {$x - ($x1 + $x2) / 2}]
        set dy [expr {$y - ($y1 + $y2) / 2}]
        .c coords $pointer_id [expr {$x1 + $dx}] [expr {$y1 + $dy}] [expr {$x2 + $dx}] [expr {$y2 + $dy}]
    }
}

expandMaze 30
drawEverything 

bind . <B1-Motion> {+movePointerWithMouse %x %y}
focus -force .
