# Bouncing Ball with VGA on Basys 3

An FPGA-based bouncing ball animation implemented in VHDL for the Digilent Basys 3 development board.

The design generates a 640 × 480 VGA output and displays a moving circular object on the screen. The ball position is updated once per video frame and its direction changes automatically when it reaches the screen boundaries.

## Hardware Demonstration

https://github.com/user-attachments/assets/d0cc0d34-213a-4a69-b10e-2e8620b36f33

## Features

* 640 × 480 VGA output
* Approximately 60 Hz refresh rate
* 25 MHz pixel clock generated from the 100 MHz board clock
* Horizontal and vertical synchronization signal generation
* Circular object rendering using the circle equation
* Frame-based ball movement
* Horizontal and vertical boundary detection
* Automatic direction change at screen edges
* 12-bit RGB output
* Synthesizable VHDL design
* Implemented on the Basys 3 FPGA board

## Hardware and Tools

| Item                          | Description            |
| ----------------------------- | ---------------------- |
| FPGA Board                    | Digilent Basys 3       |
| FPGA Device                   | Xilinx Artix-7 XC7A35T |
| Development Tool              | Vivado 2020.2          |
| Hardware Description Language | VHDL                   |
| Input Clock                   | 100 MHz                |
| Pixel Clock                   | 25 MHz                 |
| Display Resolution            | 640 × 480              |
| Ball Radius                   | 20 pixels              |

## Project Structure

```text
src/
├── BallEngine.vhd       # Controls ball position, movement and boundary detection
├── BouncingBall.vhd     # Top-level module and VGA pixel color generation
├── ClockDivider.vhd     # Generates the 25 MHz pixel clock
└── VGAController.vhd    # Generates VGA timing and synchronization signals
```

The top-level entity of the project is `bouncing_ball_top`, which is defined in `BouncingBall.vhd`.

## Design Architecture

```text
                      +------------------+
100 MHz Clock ------->|  Clock Divider   |
                      +------------------+
                               |
                               | 25 MHz Pixel Clock
                               v
                      +------------------+
                      |  VGA Controller  |
                      +------------------+
                        |      |       |
                        |      |       +------> Active Video
                        |      +--------------> Pixel Coordinates
                        +---------------------> HSYNC / VSYNC
                               |
                 +-------------+-------------+
                 |                           |
                 v                           v
        +------------------+        +------------------+
        |   Ball Engine    |        |  Pixel Renderer  |
        +------------------+        +------------------+
                 |                           |
                 | Ball Position             | RGB Output
                 +-------------------------->|
                                             v
                                         VGA Monitor
```

## Design Overview

The Basys 3 board provides a 100 MHz system clock. The `ClockDivider.vhd` module divides this clock by four to generate the 25 MHz pixel clock required by the VGA timing logic.

The `VGAController.vhd` module generates:

* Horizontal synchronization (`HSYNC`)
* Vertical synchronization (`VSYNC`)
* Horizontal pixel position
* Vertical pixel position
* Active video region signal

The `BallEngine.vhd` module stores the current ball position and movement direction. The position is updated once per video frame using the vertical synchronization signal.

The `BouncingBall.vhd` module connects all components and determines the RGB value of each pixel.

## VGA Timing

The design uses the following timing parameters for the 640 × 480 display mode.

### Horizontal Timing

| Region       | Pixel Clocks |
| ------------ | -----------: |
| Visible Area |          640 |
| Front Porch  |           16 |
| Sync Pulse   |           96 |
| Back Porch   |           48 |
| Total        |          800 |

### Vertical Timing

| Region       | Lines |
| ------------ | ----: |
| Visible Area |   480 |
| Front Porch  |    10 |
| Sync Pulse   |     2 |
| Back Porch   |    33 |
| Total        |   525 |

Using a 25 MHz pixel clock, the approximate refresh rate is:

```text
Refresh Rate = 25,000,000 / (800 × 525)
             ≈ 59.52 Hz
```

## Ball Rendering

The ball is rendered using the circle equation:

```text
(x - ball_x)² + (y - ball_y)² ≤ radius²
```

For each active pixel, the design calculates the horizontal and vertical distances between the current pixel and the center of the ball.

If the calculated squared distance is less than or equal to the squared radius, the pixel is displayed using the ball color. Otherwise, the background color is displayed.

The ball radius is set to 20 pixels.

## Ball Movement

The ball starts near the center of the screen:

```text
Initial position: (320, 240)
Initial direction: (+1, +1)
```

The ball position is updated by one pixel in both the horizontal and vertical directions for each video frame.

When the ball reaches one of the display boundaries, the corresponding movement direction is reversed.

```text
Horizontal boundary collision → Reverse horizontal direction
Vertical boundary collision   → Reverse vertical direction
```

Updating the position once per frame prevents the ball from moving at the 25 MHz pixel clock frequency and creates a visible animation.

## Display Colors

| Display Element | RGB Value |
| --------------- | --------- |
| Ball            | Red       |
| Background      | Dark Blue |
| Blanking Region | Black     |

Each color channel has a width of four bits, resulting in a 12-bit RGB output.

## Module Descriptions

### `ClockDivider.vhd`

Generates the 25 MHz pixel clock from the 100 MHz Basys 3 system clock.

### `VGAController.vhd`

Generates the VGA synchronization signals, pixel counters and active video signal for the 640 × 480 display area.

### `BallEngine.vhd`

Controls the ball coordinates and movement direction. It also detects collisions with the screen boundaries.

### `BouncingBall.vhd`

Contains the `bouncing_ball_top` entity. It connects the clock divider, VGA controller and ball engine modules and generates the final RGB output.

## Purpose

This project was developed to study the fundamentals of FPGA-based video generation and real-time graphics, including:

* VGA synchronization timing
* Pixel coordinate generation
* Frame-based animation
* Coordinate-based object rendering
* Boundary and collision detection
* Modular VHDL design

The project also provides a foundation for more advanced FPGA graphics applications such as multiple moving objects, user-controlled movement, simple games and real-time image processing.
