package sge.interfaces;

import sge.physics.AABB;

/**
 * Not really used anymore, but it was for spacial indexing of non Entity objects...
 * @author fidgetwidget
 */

interface IHasBounds 
{

	function getBounds() :AABB;
	
}