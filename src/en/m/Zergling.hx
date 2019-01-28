package en.m;

import mt.MLib;

class Zergling extends en.Mob {
	var originX			: Float;
	var originY			: Float;

	var ang				: Float;
	var tx				: Float;
	var ty				: Float;
	var precision		: Float;
	public var dir		= 1;
	var shadow			: mt.heaps.slib.HSprite;

	public function new(x,y, e:Null<Creeper>) {
		super(x,y);
		originX = e==null ? x+rnd(3,5,true) : e.x;
		originY = e==null ? y+rnd(3,5,true) : e.y;
		tx = x;
		ty = y;
		ang = 0;
		precision = 0;
		initLife(2);
		prio = 1;
		spd = rnd(0.2, 0.4);

		shadow = Assets.lib.h_get("dropShadow", 0.5,0.5);
		Game.ME.scroller.add(shadow, Const.DP_MOB_SHADOWS);
		shadow.alpha = Const.SHADOW;

		Game.ME.scroller.add(spr, Const.DP_FLYERS);
		spr.anim.setGlobalSpeed(0.2);

		spr.anim.registerStateAnim("zerglingStun", 1, function() return isStunned());
		spr.anim.registerStateAnim("zergling", 0);
	}

	public function stun() {
		cd.setF("stun", secToFrames(20));
		Game.ME.fx.stun(x,y);
	}

	function isStunned() return cd!=null && cd.has("stun");

	override function onDie() {
		super.onDie();

		Game.ME.level.addDirt(x,y, "hole", rnd(0.8, 0.9));

		for(i in 0...2) {
			var a = rnd(0,6.28);
			var d = rnd(0, 20);
			Game.ME.level.addDirt(x+Math.cos(a)*d, y+Math.sin(a)*d, "creepSplatter", 1);
		}
		Game.ME.fx.explosion(x,y, 7);

		playSpatial( Assets.one([
			Assets.SBANK.death01,
			Assets.SBANK.death02,
			Assets.SBANK.death03,
		]), x,y, 200, 0.7);
	}

	override function onDispose() {
		super.onDispose();
		shadow.remove();
	}

	public function creep(canMutate:Bool) {
		if( canMutate && !isStunned() ) {
			var found = false;
			var d = 200;
			for(e in en.m.Creeper.ALL)
				if( distSqr(e)<=d*d ) {
					found = true;
					break;
				}
			if( !found )
				new en.m.Creeper(x,y);
		}

		Game.ME.level.addCreepArea(cx,cy, canMutate ? irnd(2,3) : 1);
		Game.ME.fx.gibs(x,y, "creepGib");

		destroy();
	}


	override function updateRender() {
		super.updateRender();
		spr.scaleX = dir;
		if( shadow!=null )
			shadow.setPosition(spr.x, spr.y + 12);

		spr.x += Math.cos(ftime*0.05) * 1;
		spr.y += Math.cos(ftime*0.1) * 2;
	}

	override function update() {
		super.update();

		if( MLib.dist2Sq(tx-x, ty-y)<=5*5 ) {
			var tries = 100;
			do {
				if( cd.has("fixed") ) {
					tx = originX + rnd(0,70,true);
					ty = originY + rnd(0,70,true);
				}
				else {
					tx = x + rnd(30,100,true);
					ty = y + rnd(30,100,true);
				}
			} while( !Game.ME.isPlayArea(tx,ty) && tries-->0 );
			if( tries<=0 ) {
				tx = originX;
				ty = originY;
			}
			precision = 0;
			cd.setF("idle", rnd(15,30));
		}

		if( !cd.has("idle") && !isStunned() ) {
			var ta = Math.atan2(ty-y, tx-x);
			ang += mt.deepnight.Lib.angularSubstractionRad(ta,ang)*(0.1+precision*0.9);
			precision = MLib.fmin(1, precision+0.05);
			dx+=Math.cos(ang)*spd;
			dy+=Math.sin(ang)*spd;
		}

		if( !isStunned() ) {
			if( dx<-0.1 ) dir = -1;
			if( dx>-0.1 ) dir = 1;

			if( !cd.hasSetF("shake", 9) ) {
				for(e in Scenery.ALL)
					if( e.isColliding(this) )
						e.shake();
			}

			if( !cd.hasSetF("ccheck", 30) ) {
				var level = Game.ME.level;
				if( !level.hasCreep(cx-1,cy) && !level.hasCreep(cx+1,cy) && !level.hasCreep(cx,cy-1) && !level.hasCreep(cx,cy+1) ) {
					if( !cd.has("fixed") )
						creep(true);
				}
			}
		}
	}
}
