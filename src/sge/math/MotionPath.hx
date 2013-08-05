package sge.math;

/**
 * ...
 * @author fidgetwidget
 */
class MotionPath
{
	
	// Transform From -> To values
	public var fromPosition			: Vector2D;
	public var toPosition			: Vector2D;
	public var fromRotation			: Float;
	public var toRotation			: Float;
	public var fromScale			: Vector2D;
	public var toScale				: Vector2D;
	
	// Motion From -> To values
	public var fromVelocity			: Vector2D;
	public var toVelocity			: Vector2D;
	public var fromAcceleration		: Vector2D;
	public var toAcceleration		: Vector2D;
	public var fromFriction			: Vector2D;
	public var toFriction			: Vector2D;	
	public var fromAngularVelocity	: Float;
	public var toAngularVelocity	: Float;
	public var fromAngularAccel		: Float;
	public var toAngularAccel		: Float;
	public var fromAngularFriction	: Float;
	public var toAngularFriction	: Float;

	public function new()  { }
	
	public function applyTransform( transform : Transform, progress : Float ) : Void 
	{
		// position
		if ( fromPosition != null && toPosition != null ) {
			lerp_vector2D( fromPosition, toPosition, progress, transform.position );
		}
		// rotation
		if ( fromRotation != toRotation ) {
			transform.rotation = lerp_float( fromRotation, toRotation, progress );
		}
		// scale
		if ( fromScale != null && toScale != null ) {
			lerp_vector2D( fromScale, toScale, progress, transform.scale );
		}
	}
	
	public function applyMotion( motion : Motion, progress : Float ) : Void 
	{
		// velocity
		if ( fromVelocity != null && toVelocity != null ) {
			lerp_vector2D( fromVelocity, toVelocity, progress, motion.velocity );
		}
		// acceleration
		if ( fromAcceleration != null && toAcceleration != null ) {
			lerp_vector2D( fromAcceleration, toAcceleration, progress, motion.acceleration );
		}
		// friction
		if ( fromFriction != null && toFriction != null ) {
			lerp_vector2D( fromFriction, toFriction, progress, motion.friction );
		}
		// angular velocity
		if ( fromAngularVelocity != toAngularVelocity ) {
			motion.angularVelocity = lerp_float( fromAngularVelocity, toAngularVelocity, progress );
		}
		// angular acceleration
		if ( fromAngularAccel != toAngularAccel ) {
			motion.angularAcceleration = lerp_float( fromAngularAccel, toAngularAccel, progress );
		}
		// angular friction
		if ( fromAngularFriction != toAngularFriction ) {
			motion.angularFriction = lerp_float( fromAngularFriction, toAngularFriction, progress );
		}
	}
	
	/// Linear Interpret for Float
	public static function lerp_float( from:Float, to:Float, progress:Float ) :Float 
	{
		return from + (to - from) * progress;
	}
	/// Linear Interpret for Vector2D with optional result var
	public static function lerp_vector2D( from:Vector2D, to:Vector2D, progress:Float, output:Vector2D = null ) :Vector2D
	{
		if (output == null) {
			output = new Vector2D();
		}
		output.x = lerp_float(from.x, to.x, progress);
		output.y = lerp_float(from.y, to.y, progress);
		return output;
	}
}