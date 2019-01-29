package en.b;

import mt.MLib;

class Missile extends en.Bullet {
	var target			: Entity;
	var ang				: Float;
	var precision		: Float;
	var active			: Bool;
	var lastX			: Float;
	var lastY			: Float;

	var quad			: en.Quad;

	public function new(x,y, q:en.Quad, t:Entity) {
		super(x,y);
		quad = q;
		maxRange = 300;
		target = t;
		active = false;
		ang = Math.atan2(target.y-y, target.x-x);
		precision = 0;
		spd = 1.5;
		radius = 10;

		var d = rnd(3,8);
		var a = ang + rnd(MLib.PI*0.5, MLib.PI*0.8, true);
		dx = Math.cos(a)*d;
		dy = Math.sin(a)*d;
		frict = 0.9;
		cd.setF("launch", rnd(7,10));

		//spr.alpha = 0;
		//spr.setScale(0);
		spr.set("missile");
		spr.blendMode = Alpha;
	}


	override public function setPosition(x, y) {
		super.setPosition(x, y);
		lastX = x;
		lastY = y;
	}

	override function onHit(e:Entity) {
		super.onHit(e);

		if( Std.is(e, en.m.Zergling) )
			return;

		destroy();
		e.hit(8);
		Game.ME.fx.explosion(e.x+rnd(0,7,true), e.y+rnd(0,7,true), 1);
		playSpatial( Assets.one([Assets.SBANK.explode03]), x,y, 200, 0.2 );
	}

	override function updateRender() {
		super.updateRender();
		spr.rotation = ang;
	}


	override function onDispose() {
		super.onDispose();
		quad = null;
	}

	override function update() {
		lastX = x;
		lastY = y;

		super.update();

		if( !active && !cd.has("launch") && !cd.has("ignite") ) {
			cd.setF("ignite", 5);
			cd.onComplete("ignite", function() {
				Game.ME.fx.ignite(x,y, ang);
				active = true;
			});
		}

		if( !active && cd.has("ignite") ) {
			dx*=0.7;
			dy*=0.7;
		}

		if( active ) {
			Game.ME.fx.missileTail(lastX, lastY, x,y);
			if( target.destroyed ) {
				var t = quad.getAttackTarget();
				if( t!=null ) {
					precision = 1;
					target = t;
					dx*=0.2;
					dy*=0.2;
				}
			}
			else if( !cd.has("lockDir") ) {
				var ta = Math.atan2(target.y-y, target.x-x);
				precision = MLib.fmin(1,precision);
				ang += mt.deepnight.Lib.angularSubstractionRad(ta, ang)*(0.3+0.7*precision);
				precision+=0.04;
			}
			dx+=Math.cos(ang)*spd;
			dy+=Math.sin(ang)*spd;

			if( MLib.dist2Sq(target.x-x, target.y-y)<=25*25 ) {
				cd.setF("lockDir", rnd(5,8));
				dx*=0.9;
				dy*=0.9;
				precision = 0.5;
			}
		}

		if( spr.scaleX<1 )
			spr.scaleX = spr.scaleY = spr.scaleX + 0.1;
	}
}
