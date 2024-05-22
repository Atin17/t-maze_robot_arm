#!/usr/bin/wish
package require Tk

wm withdraw .

# Create the start menu window
# Function to open the start menu
proc open_start_menu {} {
    # Create the start menu window
    toplevel .menu
    wm title .menu "Maze Game Menu"
    wm geometry .menu 400x300 ; # Set the menu window size to 400x300 pixels

    # Add start button
    button .menu.start -text "Start Game" -command {start_game; destroy .menu}
    pack .menu.start -padx 10 -pady 10

    # Add game mode selection
    label .menu.mode_label -text "Select Game Mode:"
    pack .menu.mode_label -padx 10 -pady 5
    radiobutton .menu.mode_sequential -text "Sequential" -variable mode -value sequential
    pack .menu.mode_sequential -padx 10 -pady 5
    radiobutton .menu.mode_incremental -text "Incremental" -variable mode -value incremental
    pack .menu.mode_incremental -padx 10 -pady 5

    # Add level increment selection for incremental mode
    label .menu.increment_label -text "Level Increment (for Incremental Mode):"
    pack .menu.increment_label -padx 10 -pady 5
    scale .menu.increment -from 1 -to 4 -orient horizontal -variable increment
    pack .menu.increment -padx 10 -pady 5

    # Add exit button
    button .menu.exit -text "Exit" -command {exit}
    pack .menu.exit -padx 10 -pady 10
}

# Function to start the game
proc start_game {} {
    global path level max_level_length cell_width cell_height

    # Create the main game window
    toplevel .game
    wm title .game "T-Maze"

    # Create a canvas widget
    canvas .game.c -width 1800 -height 1000 -background white
    pack .game.c -expand true -fill both

    # Set up global variables and constants
    set canvas_width 1800
    set canvas_height 1000
    set grid_width 9
    set grid_height 5
    set cell_width [expr {$canvas_width / $grid_width}]
    set cell_height [expr {$canvas_height / $grid_height}]
    set half_cell_width [expr {$cell_width / 2}]
    set half_cell_height [expr {$cell_height / 2}]
    set line_width 80
    set short_arm_length [expr {$line_width / 2}]
    set pointer_size 20
    array set t_boundaries {}
    set level 1
    set max_level_length [llength $path]

    # Function to get cell coordinates
    proc get_cell_coords {i j} {
        global cell_width cell_height half_cell_width half_cell_height
        set x [expr {$i * $cell_width + $half_cell_width}]
        set y [expr {$j * $cell_height + $half_cell_height}]
        return [list $x $y]
    }

    # Function to draw T shapes and record boundaries
    proc make_t {x1 y1 x2 y2 orientation colour} {
        global line_width t_boundaries

        set x_middle [expr {($x2 + $x1) / 2}]
        set y_middle [expr {($y2 + $y1) / 2}]

        switch $orientation {
            "N" {
                .game.c create line $x_middle $y2 $x_middle $y_middle -width $line_width -fill $colour   ;# Vertical arm
                .game.c create line $x1 $y_middle $x2 $y_middle -width $line_width -fill $colour ;# Horizontal arm
                set t_boundaries($x1,$y1) "N"
            }
            "S" {
                .game.c create line $x_middle $y1 $x_middle $y_middle -width $line_width -fill $colour   ;# Vertical arm
                .game.c create line $x1 $y_middle $x2 $y_middle -width $line_width -fill $colour ;# Horizontal arm
                set t_boundaries($x1,$y1) "S"
            }
            "E" {
                .game.c create line $x_middle $y1 $x_middle $y2 -width $line_width -fill $colour   ;# Vertical arm
                .game.c create line $x1 $y_middle $x_middle $y_middle -width $line_width -fill $colour ;# Horizontal arm
                set t_boundaries($x1,$y1) "E"
            }
            "W" {
                .game.c create line $x_middle $y1 $x_middle $y2 -width $line_width -fill $colour   ;# Vertical arm
                .game.c create line $x_middle $y_middle $x2 $y_middle -width $line_width -fill $colour ;# Horizontal arm
                set t_boundaries($x1,$y1) "W"
            }
        }
    }

    # Function to draw the path
    proc draw_path {path level_length} {
        global cell_width cell_height
        .game.c delete all

        array unset t_boundaries
        for {set i 0} {$i < $level_length} {incr i} {
            set current [lindex $path $i]
            set next [lindex $path $i+1]

            set direction1 [lindex $current 2]
            set direction2 [lindex $next 2]

            set x1 [expr { $cell_width * [lindex $current 1] }]
            set x2 [expr { $cell_width * ([lindex $current 1] + 1)}]

            set y1 [expr { $cell_height * [lindex $current 0]}]
            set y2 [expr { $cell_height * ([lindex $current 0] + 1)}]

            if {$direction1 == "up"} {
                set orientation "S"
            } elseif {$direction1 == "down"} {
                set orientation "N"
            } elseif {$direction1 == "left"} {
                set orientation "E"
            } elseif {$direction1 == "right"} {
                set orientation "W"
            }

            if {$i == $level_length - 1} {
                make_t $x1 $y1 $x2 $y2 $orientation "green"
            } else {
                make_t $x1 $y1 $x2 $y2 $orientation "black"
            }
        }
        create_pointer
    }

    proc make_star {x y color size} {

        set pi 3.1415926535897931

        set points {}
        set counter 0
        set increment [expr {$pi / 5}]

        for {set i [expr {$pi * -1 / 2}]} { $i < [expr {3 * $pi / 2}]} {set i [expr {$i + $increment}]} {
            if {$counter % 2 == 0} {
                set r $size
            } else {
                set r [expr {$size / 2}]
            }
            set cos [expr {cos($i)}]
            set sin [expr {sin($i)}]
            lappend points [expr {$x + $r * $cos}]
            lappend points [expr {$y + $r * $sin}]

            incr counter
        }
        
        .game.c create polygon $points -fill $color
    }

    proc check_pointer_position {} {
        global pointer path level max_level_length mode increment cell_width cell_height
        set coords [.game.c coords $pointer]
        set cx [expr {([lindex $coords 0] + [lindex $coords 2]) / 2}]
        set cy [expr {([lindex $coords 1] + [lindex $coords 3]) / 2}]
        set final_cell [lindex $path [expr {$level * 2  - 1}]]
        set final_x [expr { int($cx / $cell_width)}]
        set final_y [expr { int($cy / $cell_height)}]
        puts "$final_cell $final_x $final_y"

        if {$final_x == [lindex $final_cell 1] && $final_y == [lindex $final_cell 0]} {
            if {$mode == "sequential"} {
                incr level
            } else {
                incr level $increment
                puts $level
            }
            if {$level * 2 > $max_level_length} {
                puts "Congratulations! You've completed all levels."
                exit
            }
            after 500 [list draw_path $path [expr {$level * 2}]]
        }
    }

    # Function to initialize the pointer
    proc create_pointer {} {
        global pointer
        if {[info exists pointer]} {
            .game.c delete $pointer
        }
        set pointer [.game.c create oval 890 490 910 510 -fill white]
        bind .game.c <B1-Motion> {move_pointer %x %y}
    }

    # Function to move the pointer within boundaries
    proc isInsideBar {x y} {
        global t_boundaries pointer cell_width cell_height line_width

        set pointer_size 20
        set coords [.game.c coords $pointer]
        set cx [expr {([lindex $coords 0] + [lindex $coords 2]) / 2}]
        set cy [expr {([lindex $coords 1] + [lindex $coords 3]) / 2}]

        set cell_x [expr {int($cx / $cell_width)}]
        set cell_y [expr {int($cy / $cell_height)}]

        set x1 [expr { $cell_width * $cell_x}]
        set x2 [expr { $cell_width * ($cell_x + 1)}]

        set y1 [expr { $cell_height * $cell_y}]
        set y2 [expr { $cell_height * ($cell_y + 1)}]

        if {![info exists t_boundaries($x1,$y1)]} {
            return 0
        }
        set orientation [lindex $t_boundaries($x1,$y1)] 

        set x_middle [expr { ($x2 + $x1) / 2 }]
        set y_middle [expr { ($y2 + $y1) / 2 }]

        switch $orientation {
            "N" {
                return [expr {($x >= $x_middle - $line_width / 2) && ($x <= $x_middle + $line_width / 2) && ($y > [expr {$y_middle + $line_width / 2}]) ||
                              ($y < [expr {$y_middle + $line_width / 2}]) && ($y > [expr {$y_middle - $line_width / 2}])}]
            }
            "S" {
                return  [expr {($x >= $x_middle - $line_width / 2) && ($x <= $x_middle + $line_width / 2) && ($y < [expr {$y_middle - $line_width / 2}]) ||
                              ($y < [expr {$y_middle + $line_width / 2}]) && ($y > [expr {$y_middle - $line_width / 2}]) }]
            }
            "E" {
                return  [expr {($x > $x_middle - $line_width / 2) && ($x < $x_middle + $line_width / 2) ||
                              ($x < [expr {$x_middle - $line_width / 2}]) && ($y > [expr {$y_middle - $line_width / 2}]) && ($y < [expr {$y_middle + $line_width / 2}]) }]
            }
            "W" {
                return [expr {($x > $x_middle - $line_width / 2) && ($x < $x_middle + $line_width / 2) ||
                              ($x > [expr {$x_middle + $line_width / 2}]) && ($y > [expr {$y_middle - $line_width / 2}]) && ($y < [expr {$y_middle + $line_width / 2}]) }]
            }
        }
    }

    proc move_pointer {x y} {
        global ob .game.c pointer

        if {$x >= 1799} {
            set x 1799
        }
        # puts "$x $y"

        if {[isInsideBar $x $y]} {
            set pos [.game.c coords $pointer]
            lassign $pos x1 y1 x2 y2
            set dx [expr {$x - ($x1 + $x2) / 2}]
            set dy [expr {$y - ($y1 + $y2) / 2}]
            .game.c coords $pointer [expr {$x1 + $dx}] [expr {$y1 + $dy}] [expr {$x2 + $dx}] [expr {$y2 + $dy}]
            check_pointer_position
        }
    }

    # Draw the initial path
    draw_path $path 2

    # Create and bind the pointer
    create_pointer
}

# Given path
set path {
    {2 4 up}
    {2 3 up}
    {2 2 right}
    {3 2 right}
    {3 3 down}
    {4 3 right}
    {4 4 left}
    {3 4 right}
    {3 5 down}
    {4 5 right}
    {4 6 down}
    {3 6 left}
    {2 6 left}
    {1 6 left}
    {0 6 left}
    {0 5 up}
    {1 5 down}
    {1 4 up}
    {1 3 up}
    {1 2 up}
    {0 2 left}
    {0 1 up}
    {1 1 right}
    {2 1 left}
    {2 0 up}
    {1 0 left}
    {0 0 left}
}

# Initialize global variables
set level 1
set mode "sequential"
set increment 1
array set t_boundaries {}

set canvas_width 1800
set canvas_height 1000
set grid_width 9
set grid_height 5

set cell_width [expr {$canvas_width / $grid_width}]
set cell_height [expr {$canvas_height / $grid_height}]
set half_cell_width [expr {$cell_width / 2}]
set half_cell_height [expr {$cell_height / 2}]
set line_width 80
# Open the start menu
open_start_menu

# Start the Tk event loop

