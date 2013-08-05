This is a demo to test shape collisions, and re-uses some of the features in test1s TestScene

Clicking the mouse will create Block entities at that position.
Holding CTRL and clicking will create Block's as circle shapes instead of boxes.

Pressing T will change the players collider to a Box
Pressing Y will change the players collider to a Circle (default)

Use WASD or the ARROW keys to move the Player 
- by default, the camera will follow the player.
Pressing F will toggle between the following camera, and a free camera.
When the camera is free, to move the camera, hold down SPACE, and click drag.

Pressing 1 will display the bounding boxes for all the shapes and a red line representing the shapes velocity.
Pressing 2 will display the scenes quad tree bounds currently in use.

When a shape collides with the edge (excluding the player), the camera will shake.