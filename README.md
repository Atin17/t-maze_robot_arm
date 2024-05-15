# T-Shaped Maze Generator

The T-shaped Maze Generator is a Tcl/Tk script designed to create a dynamic T-shaped maze. The maze complexity increases with levels, allowing for an interactive experience with a pointer that can only move within the defined maze boundaries.

## Features

- Generates a T-shaped maze that becomes more complex with each level.
- Includes a movable pointer that responds to mouse movements but is confined within the maze boundaries.
- Allows the expansion of the maze up to a specified number of levels through recursive function calls.

## How It Works

### Initialization

1. **Window and Canvas Setup**:
   - A Tk window is created with a canvas of size 1600x1600 pixels.
   - The canvas background is set to white.

2. **Random Seed Initialization**:
   - The random seed is initialized to ensure different random outcomes in each session for the placement of new maze bars.

### Maze Structure

- **Base Structure**: The script starts with a basic T-shape composed of one vertical and one horizontal bar.
- **Expansion Logic**: Additional bars are added recursively at random ends of the existing bars to increase the maze's complexity.

### Drawing the Maze

- **`drawEverything` Procedure**:
   - Clears the canvas and redraws the maze.
   - Ensures the pointer is redrawn or repositioned correctly after clearing the canvas.

### Pointer Management

- A pointer is created and placed within the maze.
- **Movement Control**:
   - The pointer can only move within the maze's bars, restricted by `isInsideBar` checks.
   - Movement is driven by mouse events (`<B1-Motion>`), allowing real-time interaction.

### Maze Expansion

- **`expandMaze` Procedure**:
   - Determines potential new bar positions based on the current bar orientations.
   - Ensures no duplicate bars are added and that bars do not extend outside the canvas boundaries.
   - Randomly selects a new bar to add from the potential positions.
   - Recursively calls itself until the desired maze complexity (level) is reached.

### Collision and Boundary Detection

- **`isInsideBar` Function**:
   - Checks if the given point (mouse cursor position) is within any of the maze bars before allowing the pointer to move to that position.

## Usage

- **Running the Script**: Simply run the script using a Tcl/Tk interpreter.
- **Interacting with the Maze**: Click and drag within the canvas to move the pointer along the maze paths.
