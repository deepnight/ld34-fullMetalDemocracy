import dn.heaps.HParticle;

class Fx extends dn.Process {
	var pool : ParticlePool;
	var addSb			: h2d.SpriteBatch;
	// var adds			: Array<HParticle>;

	var normalSb		: h2d.SpriteBatch;
	// var normals			: Array<HParticle>;

	var lib(get,never)	: SpriteLib; inline function get_lib() return Assets.lib;

	public function new() {
		super(Game.ME);

		addSb = new h2d.SpriteBatch(Assets.lib.tile);
		Game.ME.scroller.add(addSb, Const.DP_FX);
		addSb.blendMode = Add;
		addSb.hasRotationScale = true;

		normalSb = new h2d.SpriteBatch(Assets.lib.tile);
		Game.ME.scroller.add(normalSb, Const.DP_FX);
		normalSb.hasRotationScale = true;

		pool = new ParticlePool(Assets.lib.tile, 1024, Const.FPS);
		// adds = HParticle.initPool(addSb, 400);
		// normals = HParticle.initPool(normalSb, 300);
	}

	override public function onDispose() {
		super.onDispose();
		pool.dispose();
		addSb.remove();
		normalSb.remove();
	}

	function alloc(t:h2d.Tile, x:Float, y:Float, ?additive=true) {
		// var p = HParticle.allocFromPool(additive?adds:normals, t, x,y);
		var p = pool.alloc(additive?addSb:normalSb, t, x,y);
		p.setCenterRatio(0.5,0.5);
		return p;
	}

	public function shoot(x,y, a) {
		var p = alloc(lib.getTile("blueGlow"), x,y);
		p.setScale( rnd(1.5,3) );
		p.alpha = rnd(0.2, 0.5);
		p.ds = 0.2;
		p.scaleMul = 0.93;
		p.lifeF = 0;

		var p = alloc(lib.getTile("whiteSmoke"), x+rnd(0,10,true),y+rnd(0,10,true), true);
		p.setScale( rnd(1,1.5) );
		p.rotation = rnd(0,6.28);
		p.alpha = rnd(0.1, 0.2);
		p.moveAng(a, rnd(0.5,3));
		p.frict = 0.96;
		p.dr = rnd(0,0.02,true);
		p.fadeOutSpeed = 0.01;
		p.scaleMul = 0.98;
		p.lifeF = rnd(20,40);
	}

	public function hit(x,y) {
		var p = alloc(lib.getTile("redGlow"), x,y);
		p.setScale( rnd(2.5,4) );
		p.alpha = rnd(0.2, 0.5);
		p.ds = 0.2;
		p.scaleMul = 0.93;
		p.lifeF = 0;

		var p = alloc(lib.getTile("explosion"), x,y, true);
		p.setScale(rnd(0.3,0.4));
		p.alpha = 0.2;
		p.scaleMul = 1.005;
		p.lifeF = 1;
	}

	public function stun(x,y) {
		var p = alloc(lib.getTile("blueGlow"), x,y);
		p.setScale( rnd(2.5,4) );
		p.alpha = rnd(0.2, 0.5);
		p.ds = 0.4;
		p.dsFrict = 0.9;
		p.lifeF = 2;
	}

	public function smokeFoot(x,y) {
		var p = alloc(lib.getTile("smokeCircle"), x,y, false);
		p.alpha = rnd(0.2, 0.5);
		p.ds = 0.5;
		p.scaleMul = 0.8;
		p.lifeF = 0;
	}

	public function marker(x,y) {
		#if debug
		var p = alloc(lib.getTile("bulletEnemy"), x,y);
		p.lifeF = 3;
		#end
	}

	public function gibs(x,y, k:String, ?n=30) {
		for(i in 0...n) {
			var p = alloc(lib.getTileRandom(k), x+rnd(0,10,true),y+rnd(0,10,true), false);
			p.alpha = rnd(0.5,1);
			p.setScale(rnd(0.5,1.5));
			p.dx = rnd(1,4,true);
			p.dy = i<=4 ? -rnd(7,12) : -rnd(2,6);
			p.gy = rnd(0.3, 0.5);
			p.frict = 0.95;
			p.lifeF = rnd(30,90);
			p.rotation = rnd(0,6.28);
			p.dr = rnd(0,0.25,true);
			p.groundY = y+rnd(0,40);
			p.onBounce = function() {
				p.dr = 0;
				p.rotation = 0;
			}
		}
	}

	public function shakeGibs(x,y, k:String) {
		for(i in 0...1) {
			var p = alloc(lib.getTileRandom(k), x+rnd(0,20,true),y+rnd(0,20,true), false);
			p.alpha = rnd(0.5,1);
			p.setScale(rnd(0.5,1.5));
			p.dx = rnd(0,2,true);
			p.dy = -rnd(1,3);
			p.gy = rnd(0.3, 0.5);
			p.frict = 0.94;
			p.lifeF = rnd(5,30);
			p.rotation = rnd(0,6.28);
			p.dr = rnd(0,0.25,true);
			p.groundY = y+rnd(0,40);
			p.onBounce = function() {
				p.dr = 0;
				p.rotation = 0;
			}
		}
	}

	public function burn(x,y) {
		if( Game.ME.itime%5==0 ) {
			var p = alloc(lib.getTileRandom("spark"), x,y);
			p.setScale( rnd(1,2) );
			p.scaleMul = rnd(0.9, 1);
			p.dy = -rnd(0,0.5);
			p.frict = 0.94;
			p.fadeIn( rnd(0.4, 1), 0.1 );
			p.fadeOutSpeed = rnd(0.03, 0.10);
			p.lifeF = rnd(0,30);
		}

		if( Game.ME.itime%10==0 ) {
			var p = alloc(lib.getTileRandom("blackSmoke"), x,y, false);
			p.setScale( rnd(1.5,3) );
			p.scaleMul = rnd(0.97, 0.99);
			p.gy = -rnd(0.1,0.3);
			p.frict = 0.8;
			p.fadeIn( rnd(0.3, 0.5), 0.02 );
			p.fadeOutSpeed = rnd(0.03, 0.05);
			p.lifeF = rnd(30,60);

		}
	}


	public function explosion(x,y, n:Int) {
		var p = alloc(lib.getTile("redGlow"), x,y);
		p.setScale( rnd(2.5,4) );
		p.alpha = rnd(0.4, 0.7);
		p.ds = 0.2;
		p.scaleMul = 0.93;
		p.lifeF = 0;

		var p = alloc(lib.getTile("explosion"), x,y, true);
		p.setScale(n==1 ? 0.6 : 1);
		p.alpha = n==1 ? 0.7 : 1;
		p.scaleMul = 1.005;
		p.lifeF = 1;

		for(i in 0...n-1) {
			var p = alloc(lib.getTile("explosion"), x+rnd(4,16,true), y+rnd(4,16,true), true);
			p.setScale(rnd(0.75, 0.9));
			p.scaleMul = 0.89;
			p.lifeF = 0;
			p.delayF = 1 + i + irnd(0,1);
		}
	}

	public function ignite(x,y, a) {
		var p = alloc(lib.getTile("redGlow"), x,y);
		p.setScale(0.6);
		p.rotation = a;
		p.alpha = rnd(0.7, 1);
		p.scaleMul = 1.005;
		p.lifeF = 0;
	}


	//public function missileTail(x,y, a) {
	public function missileTail(lx:Float,ly:Float,x:Float,y:Float) {
		var p = alloc(lib.getTile("missileSmoke"), lx,ly);
		p.alpha = 0.5;
		p.rotation = Math.atan2(y-ly, x-lx);
		p.setScale( (3+dn.Lib.distance(lx,ly, x,y))/p.t.width );
		//p.moveAng(a, 1);
		p.frict = 0.9;
		p.fadeOutSpeed = 0.01;
		p.lifeF = 3;
	}

	public function spawn(x,y) {
		var p = alloc(lib.getTile("smokeCircle"), x,y, false);
		p.alpha = rnd(0.8, 1);
		p.ds = 0.5;
		p.scaleMul = 0.8;
		p.lifeF = 0;
	}


	public function blood(x,y) {
		for(i in 0...20) {
			var p = alloc(lib.getTileRandom("blood"), x,y, false);
			p.setScale( rnd(0.5,1) );
			p.lifeF = rnd(5,20);
			p.dx = rnd(0,2.4, true);
			p.dy = -rnd(1,4);
			p.gy = 0.25;
			p.frict = 0.95;
			p.groundY = y + rnd(0,4,true);
			p.bounceMul = 0;
		}
	}


	public function resist(e:Entity) {
		var p = alloc(lib.getTile("resist"), e.x, e.y);
		p.setScale(2);
		p.lifeF = 5;
		p.ds = 0.2;
		p.dsFrict = 0.8;
	}

	override public function update() {
		super.update();

		pool.update(tmod);
	}


}