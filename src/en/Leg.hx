package en;

import mt.MLib;

class Leg extends Entity {
	public static var ALL : Array<Leg> = [];

	var quad			: Quad;

	public var tx		: Float;
	public var ty		: Float;
	public var z		: Float;
	var arm				: mt.heaps.slib.HSprite;
	var footBox			: mt.heaps.slib.HSprite;
	var bodyBox			: mt.heaps.slib.HSprite;
	var legShadow		: mt.heaps.slib.HSprite;

	public function new(q) {
		super(0,0);
		ALL.push(this);
		quad = q;
		setPos(quad.x, quad.y);
		spr.set("foot", quad.skin);
		frict = 0.6;
		radius = 20;
		z = 0;

		arm = Assets.lib.h_get("leg", 0.5,0.5);
		Game.ME.scroller.add(arm, Const.DP_ARMS);

		footBox = Assets.lib.h_get("joint", 0.5,0.5);
		Game.ME.scroller.add(footBox, Const.DP_ARMS);

		bodyBox = Assets.lib.h_get("legBox", 0.,0.5);
		Game.ME.scroller.add(bodyBox, Const.DP_ARMS);

		legShadow = Assets.lib.h_get("legShadow", 0.5,0.5);
		Game.ME.scroller.add(legShadow, Const.DP_BG);
		legShadow.alpha = Const.SHADOW;
	}

	override public function setPos(x, y) {
		super.setPos(x, y);
		tx = x;
		ty = y;
	}


	public function setAngPos(a:Float, d:Float) {
		tx = quad.x + Math.cos(a)*d;
		ty = quad.y + Math.sin(a)*d;
	}

	public function moveTo(xx,yy) {
		tx = xx;
		ty = yy;
	}


	override function onDispose() {
		super.onDispose();
		quad = null;
		ALL.remove(this);
		arm.remove();
		footBox.remove();
		bodyBox.remove();
	}

	public function isMoving() {
		return dx!=0 || dy!=0;
	}

	override function updateRender() {
		super.updateRender();

		if( arm!=null ) {
			var a = Math.atan2(y-quad.bodyY, x-quad.bodyX);
			var r = 10;
			var bx = quad.bodyX + Math.cos(a)*r;
			var by = quad.bodyY + Math.sin(a)*r;
			arm.setPos(x + (bx-x)*0.5, y + (by-y)*0.5);
			arm.scaleX = mt.deepnight.Lib.distance(bx,by, x,y) / arm.tile.width;
			arm.rotation = a;

			footBox.setPos(x-Math.cos(a)*5,y-Math.sin(a)*5);
			footBox.rotation = a+MLib.PI;
			footBox.setScale(1+z*0.7);

			bodyBox.setPos(bx,by);
			bodyBox.rotation = a;
			//bodyBox.setScale(1+z*0.5);
			bodyBox.scaleX = mt.deepnight.Lib.distance(bx,by, x,y)*0.4 / bodyBox.tile.width;

			spr.setScale(1+z*0.4);
			spr.y+=5;

			legShadow.setPos(arm.x, arm.y+5);
			legShadow.rotation = arm.rotation;
			legShadow.scaleX = arm.scaleX;
		}
	}

	public function inBadPosition() {
		var d = mt.deepnight.Lib.distanceSqr(x, y, quad.x, quad.y);
		return d<=30*30 || d>=50*50;
	}

	override function update() {
		super.update();

		if( MLib.fabs(x-tx)<=5 && MLib.fabs(y-ty)<=5 ) {
			if( dx!=0 || dy!=0 ) {
				mt.flash.Sfx.playOne([
					Assets.SBANK.step01,
					Assets.SBANK.step02,
					Assets.SBANK.step03,
				], 0.2*quad.vol);
				var s = Assets.lib.h_get("smokeCircle",0.5,0.5);
				Game.ME.scroller.add(s, Const.DP_BG);
				s.setPos(x,y);
				Game.ME.level.addDirt(x,y, "hole", rnd(0.05, 0.2));
				createChildProcess( function(p) {
					s.alpha*=0.7;
					s.scale(1.04);
				});
				for(e in en.Mob.ALL)
					if( e.is(en.m.Zergling) && isColliding(e) && !Game.ME.ended )
						e.hit(10);

				for(e in en.Human.ALL)
					if( isColliding(e) )
						e.hit(1);
			}

			tx = x;
			ty = y;
			dx = dy = 0;
			z*=0.7;
		}
		else {
			var spd = 5.2;
			//var spd = quad.id==0 ? 5.5 : 3.6;
			var a = Math.atan2(ty-y, tx-x);
			dx+=Math.cos(a)*spd;
			dy+=Math.sin(a)*spd;
			quad.cd.set("legMoving", 4);
			//quad.cd.set("legMoving", quad.id==0 ? 4 : 6);
			quad.z+=0.1;
			if( z<=1 )
				z+=0.2;
		}

		if( itime%15==0 )
			for(e in Scenery.ALL)
				if( e.isColliding(this) )
					e.explode();
	}
}