Wee Dig Dug: Design
===================

## Overview

The game is designed similar to a **Model-View-Controller (MVC)** framework.
This architecture is a common way of designing applications with a User Interface.
A **MVC** framework works in the following way:

* Each component is responsible for a particular task, and only that component is allowed to perform that task.
* The **Model** is the internal representation of the application, and it is responsible to maintain the state of the application at any time.
* The **View** is the GUI. It works by reading the **Model** and displaying the graphical representation of the model on the screen.
* The **Controller** is the component that is responsible for listening to user input and updating the model accordingly.
* **MVC** components interact with each other the following way:

`TODO: Insert MVC image`

## Controller (controller.s)

The **Controller** mainly contains interrupt handlers, and it is also the entry point for the game.
In is, we do the following:

* Initialize timer and timer match registers for periodic interrupts.
* Listen for UART0 interrupt, read the keystrokes and perform the corresponding action
* Listen for External Interrupt Button press and PAUSE the game.

The controller is a relatively small component, responsible mainly for updating the **Model** via subroutines exposed by the **Model**.

## Model (model.s)

The **Model** maintains the internal representation of the board and triggers **View** updates. It exposed routines that allows the
**Controller** to trigger updates on the **Model**.

### Implementation

The **Model** consists of an __"array"__ (created using the `FILL` directive) of size 19 X 15 bytes, each byte representing a grain
of sand.
The **Model** also consists of `DCD` tables to hold information of sprites. These tables are structured similar to <tt>C</tt> `struct`s.
They look like this:

```
SPRITE
	DCD [0-18]	; Holds X coordinate of the sprite
	DCD [0-14]	; Holds Y coordinate of the sprite
	DCD {1,4}	; Holds Number of lives the sprite has
	DCD [0-3]	; Code for direction the sprite is moving/facing
	DCD [0-18]	; Previous X coordinate of sprite
	DCD [0-14]	; Previous Y coordinate of sprite
	DCD [0-18]	; Original X position (to reset when respawning)
	DCD [0-14]	; Original Y position
```

### Uses

The model will maintain the following information:

1. Position and state of all sprites on board
2. Position of all the sand using an array
3. Score/Level

### Subroutines

The model contains subroutines that will:

* Initialize model (board and sprites)
* Manipulate model
	* Reset model
	* Remove sprite
	* Change sprite direction
	* Remove sand and change score

### Design

The model consists of:

1. The board: 40 X 64 array of "blocks".
	* The board is a 40 X 64 byte array of blocks, each byte representing a boolean for sand, i.e, 1 = "sand" and 0 = "no sand".
	* The array is created by reserving 40*64 = 2560 bytes of space in static memory by using the SPACE or FILL directives.
	* **NOTE:** The size of the array can be changed to make the game more space efficient. This can be addressed in later versions of the game
	* **NOTE:** The size of the board can be changed also, as the final game should work regardless of size.

2. The sprites:
	* Each type of sprite (Dug, his pump, Pookas and Fygars) maintains a position (the top left corner in GUI) and a state,
	(direction of movement, velocity, DEAD or not).
	* The character sprites (Dug, the Pookas and the Fygars) are each of size 4 X 4 blocks (hence occupying 16 blocks).
	* Dug's pump is a sprite of height 1 block and variable length. This sprite has an additional state variable to hold length.
	The length cannot exceed 4 blocks (**NOTE:** To be revised).

## gui.s

The GUI reads the model and displays it.

### Uses

The GUI is responsible for the following:

* Maintain the state of the screen, i.e., hold representation for Main Menu and Game
* Update itself as and when model is updated.
* Maintain a accurate representation of the model.

### Subroutines

The GUI file will have subroutines that will:

* Draw GUI
* Update GUI

### Design

1. Sand:
	* Each block in the model represents one block of sand in the GUI.
	* The sand is 4 X 4 "pixels" in the GUI.
2. Character Sprites:
	* Each character sprite is 16 X 16 "pixels" in the GUI.
3. Draw/Update:
	* The draw and update subroutines will print all variables in the model based on the pre-defined size of the sprites.


## controller.s

The controller is the module that will control both, the GUI and the model.
It will mainly contain:

* The interrupt handlers for user input and timer.
* Collision detection subroutine
* Update sprite positions subroutine
* Generate pump subroutine.

### Design:

1. For user input:
	* Use FIQ Interrupts to handle user input/keystrokes, as implemented in Lab 6.
2. For game update:
	* On timer interrupt, the controller has to perform collision detection and handling, and update position of sprites.

#### Detecting collisions:

The controller will detect collision detection by the following simple procedure:
	* Read coordinate of each sprite in the model.
	* For each sprite, do the following:
		* For the Dug Sprite:
			* Sum up the byte values of all the blocks occupied by Dug on the Game board. Add to High Score.
			* Set all blocks occupied by Dug to 0
			* If blocks occupied by Dug overlap with that of either of the Pookas or Fygars, decrement Dug's life by 1,
			 reset game.
			* If collision with wall, do not update position.
		* For the enemy sprites:
			* If collision with wall, set random direction.



