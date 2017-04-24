Wee Dig Dug: Design
===

# Overview

The game is designed similar to a **Model-View-Controller (MVC)** framework.
This architecture is a common way of designing applications with a User Interface.
A **MVC** framework works in the following way:

* Each component is responsible for a particular task, and only that component is allowed to perform that task.
* The **Model** is the internal representation of the application, and it is responsible to maintain the state of the application at any time.
* The **View** is the GUI. It works by reading the **Model** and displaying the graphical representation of the model on the screen.
* The **Controller** is the component that is responsible for listening to user input and updating the model accordingly.
* **MVC** components interact with each other the following way:

`TODO: Insert MVC image`

# Controller (controller.s)

The **Controller** mainly contains interrupt handlers, and it is also the entry point for the game.
In is, we do the following:

* Initialize timer and timer match registers for periodic interrupts.
* Listen for UART0 interrupt, read the keystrokes and perform the corresponding action
* Listen for External Interrupt Button press and PAUSE the game.

The controller is a relatively small component, responsible mainly for updating the **Model** via subroutines exposed by the **Model**.

# Model (model.s)

The **Model** maintains the internal representation of the board and triggers **View** updates. It exposed routines that allows the
**Controller** to trigger updates on the **Model**.

## Implementation

The **Model** consists of an ___"array"___ (created using the `FILL` directive) of size $19 \times 15$ bytes, each byte representing a grain
of sand.

The **Model** also consists of `DCD` tables to hold information of sprites. These tables are structured similar to **C `struct`s**.
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

There are also staticaly defined regions of memory that keep track of the various states the game could possibly be in, for example, `PAUSE`, `GAME_OVER`.
The **Model** is also responsible for keeping track of other variables of the game, such as, `LEVEL`, `HIGH_SCORE`, `CURRENT_SCORE` and `TIME`.

## Operations

Operations that are defined by the **Model** are:

* Initialize and reset model.
* Move sprites and update entire model.
* Handle and detect collisions.
* Get if sand exists at given (x,y) coordinate on the board.
* Clear sand at given coordinate (x,y).
* Toggle game states (`BEGIN_GAME`,`PAUSE`, `GAME_OVER`, `RUNNING`).
* Update individual sprites.
* Spawn sprites.

## 
