package en;

class Bullet extends Entity {
	var maxTime			: Float;
	var maxRange		: Float;
	var ox				: Float;
	var oy				: Float;
	public function new(x,y) {
		super(x,y);

		maxRange = 190;
		maxTime = secToFrames(3);
		spr.set("bulletHero");
		spr.blendMode = Add;
		Game.ME.scroller.add(spr, Const.DP_BULLET);
		frict = 1;
		ox = x;
		oy = y;
	}

	function onHit(e:Entity) {}

	public function moveAng(a:Float, s:Float) {
		dx = Math.cos(a)*s;
		dy = Math.sin(a)*s;
	}

	override function update() {
		super.update();

		for(e in en.Mob.ALL)
			if( isColliding(e) )
				onHit(e);


		if( ftime>=maxTime || mt.deepnight.Lib.distanceSqr(x,y,ox,oy)>=maxRange*maxRange ) {
			Game.ME.level.addBulletHole(x,y);
			Game.ME.fx.explosion(x,y,1);
			destroy();
		}
	}
}
