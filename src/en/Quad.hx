package en;

class Quad extends Entity {
	public static var ALL : Array<Quad> = [];

	public var id		: Int;
	var bodyShadow		: HSprite;
	var head			: HSprite;
	var tx				: Null<Float>;
	var ty				: Null<Float>;
	public var z		: Float;

	var legsA			: Array<en.Leg>;
	var legsB			: Array<en.Leg>;
	public var bodyX	: Float;
	public var bodyY	: Float;
	var bodyAng			: Float;
	var recoil			: Float;
	var moveA			: Bool;

	var missiles		: Int;
	public var skin		: Int;

	var target			: Null<Entity>;

	public var vol(get,never)	: Float; inline function get_vol() return isActive()?1.0 : 0.15;

	public function new(id, x,y, sk) {
		super(x,y);
		ALL.push(this);
		this.id = id;
		skin = M.imin(1,sk);
		frict = 0.6;
		bodyAng = 0;
		tx = ty = null;
		moveA = true;
		z = 0;
		recoil = 0;
		missiles = 0;

		bodyShadow = Assets.lib.h_get("bodyShadow",0.5,0.5);
		Game.ME.scroller.add(bodyShadow, Const.DP_BODY);
		bodyShadow.alpha = Const.SHADOW;

		spr.set("body", skin);
		Game.ME.scroller.add(spr, Const.DP_BODY);


		head = Assets.lib.h_get("head",skin,0.5,0.5);
		Game.ME.scroller.add(head, Const.DP_BODY);


		legsA = [new Leg(this), new Leg(this)];
		legsB = [new Leg(this), new Leg(this)];
	}

	override public function setPosition(x, y) {
		super.setPosition(x, y);
		bodyX = x;
		bodyY = y;
	}

	override function onDispose() {
		super.onDispose();

		ALL.remove(this);

		for(e in legsA) e.destroy();
		for(e in legsB) e.destroy();
		bodyShadow.remove();
		head.remove();
		target = null;
	}

	override function updateRender() {
		super.updateRender();

		spr.x = bodyX;
		spr.y = bodyY-5;
		spr.rotation = bodyAng;
		spr.setScale(1 + z*0.1);

		if( head!=null ) {
			head.x = spr.x;
			head.y = spr.y - 3;
			head.setScale(1 + z*0.25);
			if( recoil==1 )
				head.set("headGlow", skin);
			else
				head.set("head", skin);
			if( target==null )
				head.rotation += M.radSubstract(spr.rotation, head.rotation) * 0.1;

			head.x -= Math.cos(head.rotation)*recoil*4;
			head.y -= Math.sin(head.rotation)*recoil*4;
			spr.x -= Math.cos(head.rotation)*recoil*2;
			spr.y -= Math.sin(head.rotation)*recoil*2;
			recoil*=0.7;

			bodyShadow.setPosition(spr.x, spr.y+10);
			bodyShadow.rotation = spr.rotation;
		}
	}

	public inline function isActive() return this==Game.ME.current;


	public function getAttackTarget() {
		if( Game.ME.ended )
			return null;

		var target : Entity = null;
		var minDist = 50*50;
		var maxDist = Const.SHOOT_RANGE*Const.SHOOT_RANGE;
		var all = [];
		for(e in en.Mob.ALL) {
			var d = distSqr(e);
			if( !e.destroyed && d>=minDist && d<=maxDist )
				switch( id ) {
					case 0 :
						all.push(e);

					case 1 :
						if( !Std.is(e,en.m.Zergling) )
							all.push(e);
				}
		}

		if( all.length==0 )
			return null;

		all.sort(function(a,b) {
			if( a.prio==b.prio )
				return Reflect.compare(distSqr(a), distSqr(b));
			else
				return (id==0?-1:1) * Reflect.compare(a.prio,b.prio);
		});

		return all[0];
	}



	override function update() {
		super.update();

		// if( isActive() )
			// mt.flash.Sfx.setSpatialSettings(x,y); // TODO unsupported

		var spd = 1.1;
		#if debug
		if( Key.isDown(Key.SHIFT) ) spd = 4;
		#end

		if( isActive() ) {
			if( Key.isDown(Key.LEFT) ) dx-=spd*tmod;
			if( Key.isDown(Key.RIGHT) ) dx+=spd*tmod;
			if( Key.isDown(Key.UP) ) dy-=spd*tmod;
			if( Key.isDown(Key.DOWN) ) dy+=spd*tmod;
			if( Key.isPressed(Key.SPACE) )
				Game.ME.switchCurrent();
		}

		// Tracking
		if( tx==null || ty==null ) {
		}
		else {
			var a = Math.atan2(ty-y, tx-x);
			dx+=Math.cos(a)*spd*tmod;
			dy+=Math.sin(a)*spd*tmod;
			if( dn.Lib.distanceSqr(x,y, tx,ty)<=10*10 ) {
				tx = ty = null;
				cd.setF("idle", rnd(60,90));
			}
		}


		// Repel
		for(e in ALL)
			if( e!=this && !e.destroyed ) {
				var a = Math.atan2(e.y-y, e.x-x);
				var d = M.dist2(e.x-x, e.y-y);
				if( d<=60 ) {
					var r = 0.3;
					dx+=-Math.cos(a)*r*tmod;
					dy+=-Math.sin(a)*r*tmod;
					e.dx+=Math.cos(a)*r*tmod;
					e.dy+=Math.sin(a)*r*tmod;
				}
			}

		var m = 40;
		if( x<m ) {
			dx+=spd*1.5*tmod;
		}


		// Target an enemy
		target = getAttackTarget();
		if( target!=null ) {
			var a = Math.atan2(target.y-head.y, target.x-head.x);
			var d = M.radSubstract(a, head.rotation);
			head.rotation += id==0 ? d*0.30 : d*0.08;
			if( M.fabs(d)<=0.15 ) {
				head.rotation = a;

				switch( id ) {
					case 0 :
						// Gatling
						if( !cd.hasSetF("shoot",rnd(2,5)) && !target.cd.has("resist") ) {
							if( !cd.hasSetS("sfxMG", 0.1) )
								playSpatial( Assets.SBANK.shoot01(), x,y,200,0.2 );
							var e = new en.b.MachineGun(head.x+Math.cos(a)*20 + rnd(0,5,true), head.y+Math.sin(a)*20+rnd(0,5,true), a, target);
							Game.ME.fx.shoot(e.x, e.y, a);
							recoil = 1;
						}

					case 1 :
						// Missiles
						if( !cd.hasSetF("shoot",irnd(1,2)) && missiles>0 ) {
							if( !cd.hasSetS("sfxMiss", 0.1) )
								playSpatial(
									Assets.one([Assets.SBANK.missile01,Assets.SBANK.missile02]),
									x,y, 200, 0.2
								);
							missiles--;
							cd.setF("missileReload", secToFrames(1));
							var ma = a + Math.PI*0.5*(Std.random(2)*2-1);
							var e = new en.b.Missile(head.x + Math.cos(a)*10 + Math.cos(ma)*15, head.y + Math.sin(a)*10 + Math.sin(ma)*15, this, target);
							Game.ME.fx.shoot(e.x, e.y, a);
							recoil = 1;
						}
				}
			}
		}

		if( missiles<=0 && !cd.has("missileReload") )
			missiles = 16;



		// Legs / body animations
		var a = Math.atan2(dy,dx);
		var offX = Math.cos(a)*10;
		var offY = Math.sin(a)*10;
		if( M.fabs(dx)<=0.01*tmod ) dx = 0;
		if( M.fabs(dy)<=0.01*tmod ) dy = 0;
		if( dx==0 && dy==0 )
			offX = offY = 0;

		if( !cd.has("legMoving") ) {
			var d = 50;
			if( moveA && ( legsA[0].inBadPosition() || legsA[1].inBadPosition() ) ) {
				legsA[0].setAngPos(bodyAng-M.PI*0.75, d);
				legsA[1].setAngPos(bodyAng+M.PI*0.25, d);
				moveA = !moveA;
			}
			else if( !moveA && ( legsB[0].inBadPosition() || legsB[1].inBadPosition() ) ) {
				legsB[0].setAngPos(bodyAng-M.PI*0.25, d);
				legsB[1].setAngPos(bodyAng+M.PI*0.75, d);
				moveA = !moveA;
			}
		}

		z*=0.8;

		bodyX = x + ( ( legsA[0].x + legsA[1].x + legsB[0].x + legsB[1].x ) / 4 - x ) * 0.5;
		bodyY = y + ( ( legsA[0].y + legsA[1].y + legsB[0].y + legsB[1].y ) / 4 - y ) * 0.5 - recoil*1;

		if( M.fabs(dx)>=0.1 || M.fabs(dy)>=0.1 )
			bodyAng += M.radSubstract(Math.atan2(dy,dx), bodyAng) * 0.03*tmod;
	}
}