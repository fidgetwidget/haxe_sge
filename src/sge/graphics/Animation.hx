package sge.graphics;

/**
 * ...
 * @author ...
 */
class Animation
{

	/*
	 * Properties
	 */
	public var name				: String;
	public var frames			: Array<Int>;
	public var framerate		: Int;
	public var loop				: Bool;
	public var currentFrame		(get, never) : Int;
	
	public var onComplete		: Dynamic;	// on complete callback
	public var onLoop			: Dynamic;		// on loop callback
	
	
	/*
	 * Members
	 */
	private var _paused			: Bool = true;
	private var _complete		: Bool = false;
	private var _delta			: Float = 0;
	private var _currentIndex	: Int;
	
	/// Static Id for use in constructor
	private static var uniqueId	: Int = 0;

	public function new( name:String = "", frames:Array<Int> = null, framerate:Int = 30, loop:Bool = false, onComplete:Dynamic = null ) 
	{
		if (name.length < 1) {
			name = "Anim_" + uniqueId;
			uniqueId++;
		}
		if (frames == null) {
			frames = [];
		}
		
		this.name = name;
		this.frames = frames;
		this.framerate = framerate;
		this.loop = loop;
		
		this.onComplete = onComplete;
	}
	
	public function play( reset:Bool = false ) :Void 
	{
		if (reset) {
			_currentIndex = 0;
		}
		_paused = false;
	}
	public function pause() :Void { _paused = true; }
	
	public function update ( delta:Float ) :Void 
	{
		if (_paused || _complete) { return; }
		_delta += delta * framerate;
		
		if ( _delta >= 1 ) {
			
			while (_delta >= 1) {
				_currentIndex++;
				_delta--;
				
				if (_currentIndex >= frames.length) {
					if (loop) {					// Loop
						_currentIndex = 0;
						if (onLoop != null) {
							onLoop(this);		// callback onLoop
						}
					} else {					// Complete
						_currentIndex = frames.length - 1;
						_complete = true;
						if (onComplete != null) {
							onComplete(this); 	// callback onComplete
						}
						break;
					}
				}	// endif
				
			}	// endwhile
			
		} // endif
		
	}
	
	/*
	 * Getters & Setters
	 */
	private function get_currentFrame() :Void { return frames[_currentIndex]; }
	
}