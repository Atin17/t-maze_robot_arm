# T-Maze Game

T-Maze Game is an interactive game built with Tcl/Tk. The game involves navigating through a series of T-shaped mazes with two different game modes: sequential and incremental.

## Features

- **Two Game Modes**:
  - **Sequential Mode**: The level increases by one each time you reach the target.
  - **Incremental Mode**: The level increases by a specified amount (e.g., +2, +3, +4) each time you reach the target.
- **Start Menu**: Select the game mode and level increment before starting the game.
- **Interactive Gameplay**: Use the mouse to navigate through the T-shaped maze.

## Requirements

- Tcl/Tk 8.6 or higher

## Installation

1. Ensure you have Tcl/Tk installed on your system. You can download it from [ActiveState Tcl](https://www.activestate.com/products/tcl/).
2. Clone this repository:
    ```sh
    git clone https://github.com/atin17/maze-game.git
    cd maze-game
    ```

## Usage

1. Run the game script:
    ```sh
    tclsh maze_game.tcl
    ```

2. The start menu will appear with the following options:
    - **Start Game**: Begin the game with the selected options.
    - **Select Game Mode**: Choose between Sequential and Incremental mode.
    - **Level Increment**: Specify the level increment for Incremental mode.
    - **Exit**: Close the game.

3. After starting the game, navigate through the maze using the mouse. Reach the target to advance to the next level.

## Game Modes

### Sequential Mode

In Sequential Mode, the level increases by one each time you reach the target.

### Incremental Mode

In Incremental Mode, the level increases by the specified amount each time you reach the target. You can choose the increment value from the start menu.
