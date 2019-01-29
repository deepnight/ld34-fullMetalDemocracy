package en.b;

class MachineGun extends en.Bullet {
	var target			: Entity;
	public function new(x,y,a, t) {
		super(x,y);

		target = t;
		maxRange = Const.SHOOT_RANGE*1.5;
		spd = 20;
		moveAng(a,spd);
		radius = spd;
		maxTime = secToFrames(2);

		spr.set("bulletHero");
		spr.blendMode = Add;
		frict = 1;
	}

	override function onHit(e) {
		if( e!=target )
			return;

		super.onHit(e);

		destroy();
		Game.ME.fx.hit(e.x+rnd(0,4,true), e.y+rnd(0,4,true));
		if( e.is(en.m.Creeper) )
			if( Std.random(3)==0 )
				e.hit(3);
			else
				e.hit(0);
		else
			e.hit(1);

		if( !cd.hasSetF("hole",4) )
			Game.ME.level.addBulletHole(x,y);
	}

	override function update() {
		super.update();
	}
}
