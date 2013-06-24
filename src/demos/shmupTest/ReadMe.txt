This is a demo.

Move the player left and right with either A&D or LEFT&RIGHT.
Shoot with either SPACE or the Mouse Button.


NOTES:
There are a lot of inefficent things happeneing in this demo.
The goal of this demo was to find more potential issues, and discover features I should continue to add.

1) Currently each star is a seperate entity, rather then using particles and emitters. 	[Make Particles and Emitters]
2) Currently, collision detection for the bullets with Enemies loops through every bullet per enemey 
  (I attempted to use the quad tree, but ran into issues that need to be addressed) 	[Create an easy to use Collision check built into the EntityManagers]
3) Currently the players left and right position limits are external tests. 			[Add limits to the transform class]
4) Currently Enemies simply drift towards the bottom of the scene.						[Add relative Paths (MotionPath) or (MovementPattern)]