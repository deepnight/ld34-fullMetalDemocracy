import mt.heaps.slib.*;
import mt.MLib;
import mt.deepnight.Lib;

class Scenery {
	public static var ALL : Array<Scenery> = [];

	var cd				: mt.Cooldown;
	public var spr		: HSprite;
	var exploded		: Bool;
	public var x		: Float;
	public var y		: Float;
	var burning			: Bool;
	public var partId	: String;
	public var solid	: Bool;
	public var burnable	: Bool;
	public var destroyed = false;
	public var creeped = false;

	public function new(k:String, front:Bool, x:Float,y:Float) {
		cd = new mt.Cooldown(Const.FPS);
		ALL.push(this);
		exploded = false;
		partId = "plank";
		burnable = true;
		this.x = x;
		this.y = y;

		spr = Assets.lib.h_getRandom(k);
		spr.setCenterRatio(0.5,0.5);
		Game.ME.scroller.add(spr, front ? Const.DP_BG_FRONTS : Const.DP_BG);
		spr.setPosition(x,y);
	}

	inline function rnd(min,max,?sign) return Lib.rnd(min,max,sign);
	inline function irnd(min,max,?sign) return Lib.irnd(min,max,sign);

	public inline function isColliding(e:Entity) {
		return !exploded && mt.deepnight.Lib.distanceSqr(Std.int(x), Std.int(y), e.x, e.y) <= 30*30;
	}

	public function isTree() {
		return spr.groupName=="tree" || spr.groupName=="treeCreep";
	}

	public function explode() {
		if( solid ) {
			shake();
			return;
		}
		if( exploded )
			return;

		exploded = true;

		if( !isTree() )
			(Std.random(2)==0 ? Assets.SBANK.explode01() : Assets.SBANK.explode02() ).playSpatial(x,y, 200, 0.2);


		if( !isTree() )
			Game.ME.fx.explosion(x,y,3);
		Game.ME.fx.gibs(x,y, partId, isTree()?15:30);
		burning = burnable && Std.random(100)<30;

		for(i in 0...(isTree()?10:30)) {
			var a = Lib.rnd(0,6.28);
			var d = Lib.rnd(0, 30);
			Game.ME.level.addDirt(x+Math.cos(a)*d, y+Math.sin(a)*d, partId, Lib.rnd(0.5,1));
		}

		if( spr.lib.exists("d"+spr.groupName, spr.frame) )
			spr.set("d"+spr.groupName, spr.frame);
		else
			destroy();
	}

	public function shake() {
		if( solid ) {
			cd.setF("shake", rnd(10,20));
			Game.ME.fx.shakeGibs(x,y, partId);
		}
	}

	public function destroy() {
		destroyed = true;
	}

	public function dispose() {
		spr.remove();
		ALL.remove(this);
	}

	public function update() {
		cd.update(Game.ME.tmod);

		// optim
		if( !Game.ME.isOnScreen(x,y) ) {
			spr.visible = false;
			return;
		}

		spr.visible = true;

		if( !creeped && Game.ME.level.hasCreep(Std.int(x/Const.GRID), Std.int(y/Const.GRID)) ) {
			creeped = true;
			if( spr.groupName=="tree" )
				spr.set("treeCreep", spr.lib.getRandomFrame("treeCreep"));
			if( spr.groupName=="house2x2" ) {
				explode();
			}
		}

		if( burning )
			Game.ME.fx.burn(x+rnd(0,9,true), y+rnd(0,9,true));

		if( cd.has("shake") ) {
			var r = cd.getF("shake") / cd.getInitialValueF("shake");
			// var r = cd.get("shake") / cd.getInitialValue("shake");
			spr.x = x + Math.cos(Game.ME.ftime*1)*r*0.6;
			spr.y = y + Math.sin(Game.ME.ftime*0.7)*r*0.6;
		}
		else
			spr.setPosition(x,y);
	}
}
