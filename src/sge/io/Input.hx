package sge.io;

import nme.display.Stage;
import nme.display.Tilesheet;
import nme.events.KeyboardEvent;
import nme.events.MouseEvent;
import nme.geom.Point;
import nme.ui.Keyboard;
import nme.ui.Mouse;
#if (cpp || neko || display)
import nme.events.JoystickEvent;
#end

/**
 * Concept Taken from Flixel
 * Uses .ui.nme.ui.Keyboard enum instead of strings for value checking
 * @author fidgetwidget
 */

typedef InputState = { 
	var current:Int;
	var last:Int;
}

class Input 
{

	public static function init( stage:Stage ) 
	{
		_keys = new Array();		
		initKeys();		
		_mouse = { current:0, last:0 };
		_mouseCursor = new Point();		
		_stage = stage;
		
		_stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		_stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		_stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		_stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		
#if (cpp || neko || display)
		_btns = new Array();		
		_lAxis = new Point();
		_rAxis = new Point();
		_hat = new Point();
		initBtns();

		_stage.addEventListener(JoystickEvent.AXIS_MOVE, onAxisMove);
		_stage.addEventListener(JoystickEvent.HAT_MOVE, onHatMove);
		_stage.addEventListener(JoystickEvent.BUTTON_UP, onButtonUp);
		_stage.addEventListener(JoystickEvent.BUTTON_DOWN, onButtonDown);
#end

	}
	
	public static function update() : Void {
		
		// nme.ui.Keyboard
		for ( i in 0..._keys.length ) {
			
			var o = _keys[i];
			if (o == null) continue;
			
			if ( (o.last == -1) 
			  && (o.current == -1 ) ) {
				o.current = 0;
			}			
			else 
			if ( (o.last == 2) 
			  && (o.current == 2) ) {
				o.current = 1;
			}
			
			o.last = o.current;
		}
		
		// Mouse
		if ( (_mouse.last == -1) 
		  && (_mouse.current == -1 ) ) {
			_mouse.current = 0;
		}			
		else 
		if ( (_mouse.last == 2) 
		  && (_mouse.current == 2) ) {
			_mouse.current = 1;
		}
		
		_mouse.last = _mouse.current;
		
		_mouseCursor.x = _stage.mouseX;
		_mouseCursor.y = _stage.mouseY;
		
#if (cpp || neko || display)
		// Joystick
		for ( i in 0..._btns.length ) {
			var o = _btns[i];
			if (o == null) continue;
			
			if ( (o.last == -1) 
			  && (o.current == -1 ) ) {
				o.current = 0;
			}			
			else 
			if ( (o.last == 2) 
			  && (o.current == 2) ) {
				o.current = 1;
			}
			
			o.last = o.current;
		}
#end
	}
	
	public static function reset() : Void {
		
		for ( i in 0..._keys.length ) {
			
			var o = _keys[i];
			if (o == null) continue;
			
			o.current = o.last = 0;
		}
		
		_mouse.current = _mouse.last = 0;
		
#if (cpp || neko || display)
		for ( i in 0..._btns.length ) {
			
			var o = _btns[i];
			if (o == null) continue;
			
			o.current = o.last = 0;
		}
#end
	}
	
	
	/* --- nme.ui.Keyboard --- */
	
	public static function isKeyDown( keyCode:Int ) :Bool {
		return _keys[keyCode].current > 0; // 1 or 2
	}
	public static function isKeyUp( keyCode:Int ) :Bool {
		return _keys[keyCode].current < 1; // 0 or -1
	}
	public static function isKeyPressed( keyCode:Int ) :Bool {
		return _keys[keyCode].current == 2;
	}
	public static function isKeyReleased( keyCode:Int ) :Bool {
		return _keys[keyCode].current == -1;
	}
	
	private static function onKeyDown( e:KeyboardEvent ) :Void {
		
		var keyCode = e.keyCode;
		var o = _keys[keyCode];
		if ( o == null ) return;
		
		if ( o.current > 0 ) {
			o.current = 1; // is down
		}
		else {
			o.current = 2; // just pressed
		}
		
	}
	
	private static function onKeyUp( e:KeyboardEvent ) :Void {
		
		var keyCode = e.keyCode;
		var o = _keys[keyCode];
		if ( o == null ) return;
		
		if ( o.current > 0 ) {
			o.current = -1; // just released
		}
		else {
			o.current = 0; // is up
		}
		
	}
	
	private static function addKey( KeyCode:Int ) :Void {
		
		_keys[KeyCode] = { current:0, last:0 };
		
	}
	
	
	// Add all of the nme.ui.Keyboard values to the map
	private static function initKeys() :Void {
		
		addKey(nme.ui.Keyboard.A); // 65
		addKey(nme.ui.Keyboard.B); // 66
		addKey(nme.ui.Keyboard.C); // 67
		addKey(nme.ui.Keyboard.D); // 68
		addKey(nme.ui.Keyboard.E); // 69
		addKey(nme.ui.Keyboard.F); // 70
		addKey(nme.ui.Keyboard.G); // 71
		addKey(nme.ui.Keyboard.H); // 72
		addKey(nme.ui.Keyboard.I); // 73
		addKey(nme.ui.Keyboard.J); // 74
		addKey(nme.ui.Keyboard.K); // 75
		addKey(nme.ui.Keyboard.L); // 76
		addKey(nme.ui.Keyboard.M); // 77
		addKey(nme.ui.Keyboard.N); // 78
		addKey(nme.ui.Keyboard.O); // 79
		addKey(nme.ui.Keyboard.P); // 80
		addKey(nme.ui.Keyboard.Q); // 81
		addKey(nme.ui.Keyboard.R); // 82
		addKey(nme.ui.Keyboard.S); // 83
		addKey(nme.ui.Keyboard.T); // 84
		addKey(nme.ui.Keyboard.U); // 85
		addKey(nme.ui.Keyboard.V); // 86
		addKey(nme.ui.Keyboard.W); // 87
		addKey(nme.ui.Keyboard.X); // 88
		addKey(nme.ui.Keyboard.Y); // 89
		addKey(nme.ui.Keyboard.Z); // 90
		addKey(nme.ui.Keyboard.BACKSPACE); // 8
		addKey(nme.ui.Keyboard.CAPS_LOCK); // 20		
		addKey(nme.ui.Keyboard.CONTROL); // 17
		addKey(nme.ui.Keyboard.DELETE); // 46
		addKey(nme.ui.Keyboard.DOWN); // 40
		addKey(nme.ui.Keyboard.END); // 35
		addKey(nme.ui.Keyboard.ENTER); // 13		
		addKey(nme.ui.Keyboard.ESCAPE); // 27
		addKey(nme.ui.Keyboard.F1); // 112
		addKey(nme.ui.Keyboard.F2); // 113
		addKey(nme.ui.Keyboard.F3); // 114
		addKey(nme.ui.Keyboard.F4); // 115
		addKey(nme.ui.Keyboard.F5); // 116
		addKey(nme.ui.Keyboard.F6); // 117
		addKey(nme.ui.Keyboard.F7); // 118
		addKey(nme.ui.Keyboard.F8); // 119
		addKey(nme.ui.Keyboard.F9); // 120
		addKey(nme.ui.Keyboard.F10); // 121
		addKey(nme.ui.Keyboard.F11); // 122
		addKey(nme.ui.Keyboard.F12); // 123
		addKey(nme.ui.Keyboard.F13); // 124
		addKey(nme.ui.Keyboard.F14); // 125
		addKey(nme.ui.Keyboard.F15); // 126
		addKey(nme.ui.Keyboard.HOME); // 36
		addKey(nme.ui.Keyboard.INSERT); // 45
		addKey(nme.ui.Keyboard.LEFT); // 37		
		addKey(nme.ui.Keyboard.NUMPAD_0); // 96
		addKey(nme.ui.Keyboard.NUMPAD_1); // 97
		addKey(nme.ui.Keyboard.NUMPAD_2); // 98
		addKey(nme.ui.Keyboard.NUMPAD_3); // 99
		addKey(nme.ui.Keyboard.NUMPAD_4); // 100
		addKey(nme.ui.Keyboard.NUMPAD_5); // 101
		addKey(nme.ui.Keyboard.NUMPAD_6); // 102
		addKey(nme.ui.Keyboard.NUMPAD_7); // 103
		addKey(nme.ui.Keyboard.NUMPAD_8); // 104
		addKey(nme.ui.Keyboard.NUMPAD_9); // 105
		addKey(nme.ui.Keyboard.NUMPAD_ADD); // 107
		addKey(nme.ui.Keyboard.NUMPAD_DECIMAL); // 110
		addKey(nme.ui.Keyboard.NUMPAD_DIVIDE); // 111
		addKey(nme.ui.Keyboard.NUMPAD_ENTER); // 108
		addKey(nme.ui.Keyboard.NUMPAD_MULTIPLY); // 106
		addKey(nme.ui.Keyboard.NUMPAD_SUBTRACT); // 109
		addKey(nme.ui.Keyboard.PAGE_DOWN); // 34
		addKey(nme.ui.Keyboard.PAGE_UP); // 33		
		addKey(nme.ui.Keyboard.RIGHT); // 39		
		addKey(nme.ui.Keyboard.SHIFT); // 16		
		addKey(nme.ui.Keyboard.SPACE); // 32
		addKey(nme.ui.Keyboard.TAB); // 9
		addKey(nme.ui.Keyboard.UP); // 38
		
		// not supported in html5 build
#if !js
		addKey(nme.ui.Keyboard.ALTERNATE); // 18
		addKey(nme.ui.Keyboard.BACKQUOTE); // 192
		addKey(nme.ui.Keyboard.BACKSLASH); // 220
		addKey(nme.ui.Keyboard.COMMA); // 188
		addKey(nme.ui.Keyboard.COMMAND); // 15
		addKey(nme.ui.Keyboard.EQUAL); // 187
		addKey(nme.ui.Keyboard.LEFTBRACKET); // 219
		addKey(nme.ui.Keyboard.MINUS); // 189
		addKey(nme.ui.Keyboard.NUMBER_0); // 48
		addKey(nme.ui.Keyboard.NUMBER_1); // 49
		addKey(nme.ui.Keyboard.NUMBER_2); // 50
		addKey(nme.ui.Keyboard.NUMBER_3); // 51
		addKey(nme.ui.Keyboard.NUMBER_4); // 52
		addKey(nme.ui.Keyboard.NUMBER_5); // 53
		addKey(nme.ui.Keyboard.NUMBER_6); // 54
		addKey(nme.ui.Keyboard.NUMBER_7); // 55
		addKey(nme.ui.Keyboard.NUMBER_8); // 56
		addKey(nme.ui.Keyboard.NUMBER_9); // 57
		addKey(nme.ui.Keyboard.NUMPAD); // 21
		addKey(nme.ui.Keyboard.RIGHTBRACKET); // 221
		addKey(nme.ui.Keyboard.SEMICOLON); // 186
		addKey(nme.ui.Keyboard.PERIOD); // 190
		addKey(nme.ui.Keyboard.QUOTE); // 222
		addKey(nme.ui.Keyboard.SLASH); // 191	
#end
	}
	
	/* --- Mouse --- */
	
	public static var mouseX(getMouseX, never):Float;
	public static var mouseY(getMouseY, never):Float;
	
	public static function getMouseX() :Float { return _mouseCursor.x; }
	public static function getMouseY() :Float { return _mouseCursor.y; }
	
	public static function getMousePoint() :Point { return _mouseCursor; }
	
	public static function isMouseDown( ) :Bool {
		return _mouse.current > 0; // 1 or 2
	}
	public static function isMouseUp( ) :Bool {
		return _mouse.current < 1; // 0 or -1
	}
	public static function isMousePressed( ) :Bool {
		return _mouse.current == 2;
	}
	public static function isMouseReleased( ) :Bool {
		return _mouse.current == -1;
	}
	
	private static function onMouseDown( e:MouseEvent ) :Void {
		
		if ( _mouse.current > 0) {
			_mouse.current = 1; // is down
		} 
		else {
			_mouse.current = 2; // just pressed
		}
		
	}
	
	private static function onMouseUp( e:MouseEvent ) :Void {
		
		if ( _mouse.current > 0) {
			_mouse.current = -1; // just released
		} 
		else {
			_mouse.current = 0; // is up
		}
	}
	
	private static var _total 		: Int = 256;
	private static var _keys 		: Array<InputState>;		
	private static var _mouse 		: InputState;
	private static var _mouseCursor : Point;
	private static var _stage 		: Stage;
	
	
	
#if (cpp || neko || display)
	/* --- Joystick --- */
	
	public static var lAxisX(getLAxisX, never):Float;
	public static var lAxisY(getLAxisY, never):Float;
	public static var rAxisX(getRAxisX, never):Float;
	public static var rAxisY(getRAxisY, never):Float;
	public static var lTrigger(getLTrigger, never):Float;
	public static var rTrigger(getRTrigger, never):Float;
	public static var hatX(getHatX, never):Float;
	public static var hatY(getHatY, never):Float;
	
	public static function getLAxisX() :Float { return _lAxis.x; }
	public static function getLAxisY() :Float { return _lAxis.y; }
	public static function getRAxisX() :Float { return _rAxis.x; }
	public static function getRAxisY() :Float { return _rAxis.y; }
	public static function getLTrigger() :Float { return _lTrigger; }
	public static function getRTrigger() :Float { return _rTrigger; }
	public static function getHatX() :Float { return _hat.x; }
	public static function getHatY() :Float { return _hat.y; }
	
	public static function getLeftAxis() :Point { return _lAxis; }
	public static function getRightAxis() :Point { return _rAxis; }
	public static function getHatPoint() :Point { return _hat; }
	
	public static function isButtonDown( btnCode:Int ) :Bool {
		return _btns[btnCode].current > 0; // 1 or 2
	}
	public static function isButtonUp( btnCode:Int ) :Bool {
		return _btns[btnCode].current < 1; // 0 or -1
	}
	public static function isButtonPressed( btnCode:Int ) :Bool {
		return _btns[btnCode].current == 2;
	}
	public static function isButtonReleased( btnCode:Int ) :Bool {
		return _btns[btnCode].current == -1;
	}	
	
	private static function onAxisMove( e:JoystickEvent ) :Void {
		_lAxis.x = e.axis[0];
		_lAxis.y = e.axis[1];
		_rAxis.x = e.axis[3];
		_rAxis.y = e.axis[4];
		_lTrigger = e.axis[2] > 0 ? e.axis[2] : 0;
		_rTrigger = e.axis[2] < 0 ? -e.axis[2] : 0;
	}
	private static function onHatMove( e:JoystickEvent ) :Void {
		_hat.x = e.x;
		_hat.y = e.y;
	}
	
	private static function addButton( btnCode:Int ) :Void {
		_btns[btnCode] = { current:0, last:0 };
	}	
	
	private static function onButtonDown( e:JoystickEvent ) :Void {
		var btnCode = e.id;		
		var o = _btns[btnCode];
		if ( o == null ) return;
		
		if ( o.current > 0 ) {
			o.current = 1; // is down
		}
		else {
			o.current = 2; // just pressed
		}
	}
	
	private static function onButtonUp( e:JoystickEvent ) :Void {
		var btnCode = e.id;
		var o = _btns[btnCode];
		if ( o == null ) return;
		
		if ( o.current > 0 ) {
			o.current = -1; // just released
		}
		else {
			o.current = 0; // is up
		}
	}
	
	public static function initBtns() :Void {
		
	}
	
	private static var _btns 		: Array<InputState>;
	private static var _lAxis 		: Point;
	private static var _rAxis 		: Point;
	private static var _lTrigger	: Float;
	private static var _rTrigger	: Float;
	private static var _hat 		: Point;
	
#end
	
}