package ;

import nme.ui.Keyboard;


import demos.brickBreaker.BreakerScene;
import demos.cameraTest.CameraTestScene;
import demos.physicsTest.PhysicsTestScene;
import demos.platformer.PlatformScene;
import demos.pong.PongScene;

import sge.core.Engine;
import sge.io.Input;
import sge.random.Rand;


/**
 * Game
 * - Do any front loading stuff here
 * @author fidgetwidget
 */

class Game extends Engine { 
	
	private var _physicsScene:PhysicsTestScene;
	private var _cameraScene:CameraTestScene;
	
	private var _platformerScene:PlatformScene;
	private var _pongScene:PongScene;
	private var _brickBreakerScene:BreakerScene;
	
	public function new(root) {	
		
		super(root);
	}
	
	override public function init() {
		
		super.init();
		
		_physicsScene = new PhysicsTestScene();
		this.addScene(_physicsScene);
		
		_pongScene = new PongScene();
		this.addScene(_pongScene, true);
		
		_cameraScene = new CameraTestScene();
		this.addScene(_cameraScene);
		
		_brickBreakerScene = new BreakerScene();
		this.addScene(_brickBreakerScene);
		
		_platformerScene = new PlatformScene();
		this.addScene(_platformerScene);
		
	}
	
	
	override private function _preUpdate():Void 
	{
		
		if ( Input.isKeyDown(Keyboard.CONTROL) ) {
			
			if (Input.isKeyDown(Keyboard.G) ) {
				this.readyScene( _physicsScene.id );
			}
			if (Input.isKeyDown(Keyboard.I) ) {
				this.readyScene( _pongScene.id );
			}
			if (Input.isKeyDown(Keyboard.J) ) {
				this.readyScene( _cameraScene.id );
			}
			if (Input.isKeyDown(Keyboard.K) ) {
				this.readyScene( _platformerScene.id );
			}			
			if (Input.isKeyDown(Keyboard.L) ) {
				this.readyScene( _brickBreakerScene.id );
			}
			
		}
		
		
		super._preUpdate();
	}
	
}