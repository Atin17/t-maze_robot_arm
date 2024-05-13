#! /usr/bin/wish

package require Tk

# Create a window

global ob

global bounds

proc init_test {} {
    global ob bounds

    set ob(level) 5
    set ob(can,x) 800.
    set ob(can,y) 800.
    set ob(radius) 10
    set ob(length) 100
    set ob(seed) 1
    puts [expr {srand($ob(seed))}]
    

    set ob(division_size) [expr { $ob(can,x) / $ob(level) }]
    set ob(width) [expr { $ob(division_size) / 5 }]

    wm title . "T-Shaped Maze"
    canvas .c -width $ob(can,x) -height $ob(can,y) -background black
    pack .c -expand yes -fill both

    make_grid

    # Create a pointer that starts at the bottom of the T
    set ob(pointer) [.c create oval 390 570 410 590 -fill black]

    # Bind mouse move event to move the pointer
    # bind .c <Motion> {moveTo %x %y}
}

proc make_grid {} {
    global ob bounds

    for {set i 0} {$i < $ob(level)} {incr i} {
        set x1 [expr { $ob(division_size) * $i }]
        set x2 [expr { $ob(division_size) * ($i + 1)}]
        for {set j 0} {$j < $ob(level)} {incr j} {
            set y1 [expr { $ob(division_size) * $j}]
            set y2 [expr { $ob(division_size) * ($j + 1)}]
            puts "${x1}_${y1}_${x2}_${y2}"
            set bounds($i,$j,x1) $x1
            set bounds($i,$j,x2) $x2
            set bounds($i,$j,y1) $y1
            set bounds($i,$j,y2) $y2
            set bounds($i,$j,orientation) "0"
            
        }
    }

    make_maze

    for {set i 0} {$i < $ob(level)} {incr i} {
        for {set j 0} {$j < $ob(level)} {incr j} {
            make_t $bounds($i,$j,x1) $bounds($i,$j,y1) $bounds($i,$j,x2) $bounds($i,$j,y2) $bounds($i,$j,orientation)
        }
    }
}

proc make_maze {} {
    puts "make_maze"
    global ob bounds

    set current_x 0
    set current_y [expr { $ob(level) - 1}]
    set current_orientation "N"

    set bounds($current_x,$current_y,orientation) "N"

    for {set i 0} {$i < $ob(length)} {incr i} {
        puts "${current_x}_${current_y}_${current_orientation}"
        switch $current_orientation {
            "N" -
            "S" {
                if { ([expr { $current_x - 1}] < 0 || $bounds([expr { $current_x - 1 }],$current_y,orientation) != "0") && 
                ([expr { $current_x + 1}] == $ob(level) || $bounds([expr { $current_x + 1 }],$current_y,orientation) != "0")} {
                    puts "exiting"
                    return
                } elseif { ([expr { $current_x - 1}] < 0 || $bounds([expr { $current_x - 1 }],$current_y,orientation) != "0") } {
                    set bounds([expr { $current_x + 1 }],$current_y,orientation) "E"
                    set current_orientation "E"
                    set current_x [expr { $current_x + 1 }]
                } elseif { ([expr { $current_x + 1}] == $ob(level) || $bounds([expr { $current_x + 1 }],$current_y,orientation) != "0") } {
                    set bounds([expr { $current_x - 1 }],$current_y,orientation) "W"
                    set current_orientation "W"
                    set current_x [expr { $current_x - 1 }]
                } else {
                    set random [expr {rand()}]
                    puts $random
                    if { $random > 0.5 } {
                        set bounds([expr { $current_x + 1 }],$current_y,orientation) "E"
                        set current_orientation "E"
                        set current_x [expr { $current_x + 1 }]
                    } else {
                        set bounds([expr { $current_x - 1 }],$current_y,orientation) "W"
                        set current_orientation "W"
                        set current_x [expr { $current_x - 1 }]
                    }
                }
            }

            "E" -
            "W" {
                if { ([expr { $current_y - 1}] < 0 || $bounds($current_x,[expr { $current_y - 1 }],orientation) != "0") && 
                ([expr { $current_y + 1}] == $ob(level) || $bounds($current_x,[expr { $current_y + 1 }],orientation) != "0")} {
                    return
                } elseif { ([expr { $current_y - 1}] < 0 || $bounds($current_x,[expr { $current_y - 1 }],orientation) != "0") } {
                    set bounds($current_x,[expr { $current_y + 1}],orientation) "S"
                    set current_orientation "S"
                    set current_y [expr { $current_y + 1 }]
                } elseif { ([expr { $current_y + 1}] == $ob(level) || $bounds($current_x,[expr { $current_y + 1 }],orientation) != "0") } {
                    set bounds($current_x,[expr { $current_y - 1}],orientation) "N"
                    set current_orientation "N"
                    set current_y [expr { $current_y - 1 }]
                } else {
                    set random [expr {rand()}]
                    puts $random
                    if { $random > 0.5 } {
                        set bounds($current_x,[expr { $current_y + 1}],orientation) "S"
                        set current_orientation "S"
                        set current_y [expr { $current_y + 1 }]
                    } else {
                        set bounds($current_x,[expr { $current_y - 1}],orientation) "N"
                        set current_orientation "N"
                        set current_y [expr { $current_y - 1 }]
                    }
                }
            }
        }
    }
}

proc make_t { x1 y1 x2 y2 orientation } {
    global ob
    switch $orientation {
        "N" {
            # Coordinates for the T-shaped maze paths and boundaries
            set x_middle [expr { ($x2 + $x1) / 2 }]
            set y_middle [expr { ($y2 + $y1) / 2 }]
            
            .c create line $x_middle $y2 $x_middle $y_middle -width $ob(width) -fill white   ;# Vertical arm
            .c create line $x1 $y_middle $x2 $y_middle -width $ob(width) -fill white ;# Horizontal arm
        }

        "S" {
            # Coordinates for the T-shaped maze paths and boundaries
            set x_middle [expr { ($x2 + $x1) / 2 }]
            set y_middle [expr { ($y2 + $y1) / 2 }]

            .c create line $x_middle $y1 $x_middle $y_middle -width $ob(width) -fill white   ;# Vertical arm
            .c create line $x1 $y_middle $x2 $y_middle -width $ob(width) -fill white ;# Horizontal arm
        }

        "E" {
            # Coordinates for the T-shaped maze paths and boundaries
            set x_middle [expr { ($x2 + $x1) / 2 }]
            set y_middle [expr { ($y2 + $y1) / 2 }]

            .c create line $x_middle $y1 $x_middle $y2 -width $ob(width) -fill white   ;# Vertical arm
            .c create line $x1 $y_middle $x_middle $y_middle -width $ob(width) -fill white ;# Horizontal arm
        }

        "W" {
            # Coordinates for the T-shaped maze paths and boundaries
            set x_middle [expr { ($x2 + $x1) / 2 }]
            set y_middle [expr { ($y2 + $y1) / 2 }]

            .c create line $x_middle $y1 $x_middle $y2 -width $ob(width) -fill white   ;# Vertical arm
            .c create line $x2 $y_middle $x_middle $y_middle -width $ob(width) -fill white ;# Horizontal arm
        }
    }
}

# Function to move the pointer to a specific position within boundaries
proc moveTo {x y} {
    global ob bounds

    # Get current position of the pointer
    set pos [.c coords $ob(pointer)]

    # get current spot
    set current_tile_x [expr { int($x / $ob(division_size)) }]
    set current_tile_y [expr { int($y / $ob(division_size)) }]
    if {$current_tile_x >= $ob(level)} {
        set current_tile_x [expr { $ob(level) - 1}]
    }
    if {$current_tile_y >= $ob(level)} {
        set current_tile_y [expr { $ob(level) - 1}]
    }
    puts "${current_tile_x}_${current_tile_y}"

    # Define boundaries of the T-shaped maze
    # set verticalTop 240
    # set verticalBottom 600
    # set horizontalLeft 200
    # set horizontalRight 600
    # set horizontalTop 200
    # set horizontalBottom 240
    # set horizontalMiddleTop 380
    # set horizontalMiddleBottom 420

    switch $bounds($current_tile_x,$current_tile_y,orientation) {
        "N" {
            # Define boundaries of the T-shaped maze
            set x_middle [expr { ($bounds($current_tile_x,$current_tile_y,x2) + $bounds($current_tile_x,$current_tile_y,x1)) / 2 }]
            set y_middle [expr { ($bounds($current_tile_x,$current_tile_y,y2) + $bounds($current_tile_x,$current_tile_y,y1)) / 2 }]

            # set verticalTop [expr { $y_middle + ($ob(width) / 2)}]
            # set verticalBottom $bounds($current_tile_x,$current_tile_y,y2)
            # set horizontalLeft $bounds($current_tile_x,$current_tile_y,x1)
            # set horizontalRight $bounds($current_tile_x,$current_tile_y,x2)
            # set horizontalTop [expr { $y_middle - ($ob(width) / 2)}]
            # set horizontalBottom [expr { $y_middle + ($ob(width) / 2)}]
            # set horizontalMiddleTop [expr { $x_middle - ($ob(width) / 2)}]
            # set horizontalMiddleBottom [expr { $x_middle + ($ob(width) / 2)}]

            set x1 [expr {$x - $ob(radius)}]
            set x2 [expr {$x + $ob(radius)}]
            set y1 [expr {$y - $ob(radius)}]
            set y2 [expr {$y + $ob(radius)}]
            .c coords $ob(pointer) $x1 $y1 $x2 $y2
        }
    }
    
    
    # # Check if movement is within vertical bounds of the T-shape
    # if {$y >= $verticalTop && $y <= $verticalBottom} {
    #     if {$x >= $horizontalMiddleTop && $x <= $horizontalMiddleBottom} {
    #         # .c coords $ob(pointer) $x1 $y1 $x2 $y2
    #         puts "in bounds"
    #     }
    # }
    # # Check if movement is within horizontal bounds of the T-shape
    # if {$y >= $horizontalTop && $y <= $horizontalBottom} {
    #     set x1 [expr {$x1 - $ob(radius)}]
    #     # .c coords $ob(pointer) $x1 $y1 $x2 $y2
    #     puts "in bounds"
    #     if {$x >= $horizontalLeft && $x <= $horizontalRight} {
            
    #     }
    # }
}


init_test