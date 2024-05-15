#! /usr/bin/wish

package require Tk

wm title . "T-Shaped Maze Generator"
canvas .c -width 1600 -height 1600 -background white
pack .c -expand yes -fill both

expr {srand([clock seconds])}

set bars {
    {800 500 800 700 v} 
    {700 400 900 400 h}  
}

set pointer_id ""

proc drawEverything {} {
    global bars .c pointer_id

    .c delete all  ;# Clear the canvas

    foreach bar $bars {
        lassign $bar startX startY endX endY orientation
        .c create line $startX $startY $endX $endY -width 40 -fill black
    }

    if {$pointer_id != "" && [.c exists $pointer_id]} {
        .c coords $pointer_id 800 600 815 615
    } else {
        set pointer_id [.c create oval 800 600 815 615 -fill white]
    }
}

proc isDuplicateBar {newBar newBars} {
    foreach bar $newBars {
        if {[lindex $bar 0] == [lindex $newBar 0] &&
            [lindex $bar 1] == [lindex $newBar 1] &&
            [lindex $bar 2] == [lindex $newBar 2] &&
            [lindex $bar 3] == [lindex $newBar 3]} {
            return 1
        }
    }

 
    return 0
}

proc expandMaze {level} {
    global bars
    if {$level <= 1} {
        return
    }

    set newBars {}
    foreach bar $bars {
        lassign $bar startX startY endX endY orientation
        if {$orientation == "v"} {
            set newBar [list [expr {$endX - 100}] $endY [expr {$endX + 100}] $endY h]  ;# Top horizontal
            if {![isDuplicateBar $newBar $newBars] && $endX >= 0 && $endX <= 1600 } {
                    lappend newBars $newBar
                }
            set newBar [list [expr {$endX - 100}] $startY [expr {$endX + 100}] $startY h]  ;# bottom horizontal
            if {![isDuplicateBar $newBar $newBars] && $endX >= 0 && $endX <= 1600} {
                    lappend newBars $newBar
                }
        } elseif {$orientation == "h"} {
            set newBar [list $startX [expr {$startY - 100}] $startX [expr {$startY + 100}] v]  ;# left vertical
            if {![isDuplicateBar $newBar $newBars] && $startY >= 0 && $startY <= 1600} {
                    lappend newBars $newBar
                }
            set newBar [list $endX [expr {$startY - 100}] $endX [expr {$startY + 100}] v]     ;# right vertical
            if {![isDuplicateBar $newBar $newBars] && $startY >= 0 && $startY <= 1600} {
                    lappend newBars $newBar
                }
        }
    }

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

    expandMaze [expr {$level - 1}]
}

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

expandMaze 20
drawEverything 

bind . <B1-Motion> {+movePointerWithMouse %x %y}
focus -force .
