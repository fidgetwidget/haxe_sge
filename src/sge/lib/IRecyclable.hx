package sge.lib;

/**
 * ...
 * @author fidgetwidget
 */
interface IRecyclable 
{

	function free() :Void; // Free's up the object for Recycling(Reuse)
	
	function get_free() :Bool;				// Get whether or not the object is ready for reuse
	function set_free( free:Bool ) :Bool;	// Set whether or not the object is ready for reuse
	
}